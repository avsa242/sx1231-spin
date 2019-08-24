{
    --------------------------------------------
    Filename: wireless.transceiver.sx1231.spi.spin
    Author: Jesse Burt
    Description: Driver for the Semtech SX1231 UHF Transceiver IC
    Copyright (c) 2019
    Started Apr 19, 2019
    Updated Aug 23, 2019
    See end of file for terms of use.
    --------------------------------------------
}

CON

' SX1231 Oscillator Frequency
    FXOSC                   = 32_000_000
    FSTEP                   = FXOSC / (1 << 19)

' Sequencer operating modes
    OPMODE_AUTO             = 0
    OPMODE_MANUAL           = 1
    OPMODE_SLEEP            = 0
    OPMODE_STDBY            = 1
    OPMODE_FS               = 2
    OPMODE_TX               = 3
    OPMODE_RX               = 4

' Data processing modes
    DATAMODE_PACKET         = 0
    DATAMODE_CONT_W_SYNC    = 2
    DATAMODE_CONT_WO_SYNC   = 3

' Modulation types
    MOD_FSK                 = 0
    MOD_OOK                 = 1

' Gaussian modulation shaping filters
    BT_NONE                 = 0
    BT_1_0                  = 1
    BT_0_5                  = 2
    BT_0_3                  = 3

' AFC method/routine
    AFC_STANDARD            = 0
    AFC_IMPROVED            = 1

' LNA Gain
    LNA_AGC                 = 0
    LNA_HIGH                = 1

' Sync word read/write operation
    SW_READ                 = 0
    SW_WRITE                = 1

' DC-free encoding/decoding
    DCFREE_NONE             = %00
    DCFREE_MANCH            = %01
    DCFREE_WHITE            = %10

' Address matching
    ADDRCHK_NONE            = %00
    ADDRCHK_CHK_NO_BCAST    = %01
    ADDRCHK_CHK_BCAST       = %10

VAR

    byte _CS, _MOSI, _MISO, _SCK

OBJ

    spi : "com.spi.4w"                                              'PASM SPI Driver
    core: "core.con.sx1231"
    time: "time"                                                    'Basic timing functions

PUB Null
''This is not a top-level object

PUB Start(CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN) : okay

    okay := Startx(CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN, core#CLK_DELAY, core#CPOL)

PUB Startx(CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN, SCK_DELAY, SCK_CPOL): okay
    if SCK_DELAY => 1 and lookdown(SCK_CPOL: 0, 1)
        if okay := spi.start (SCK_DELAY, SCK_CPOL)                  'SPI Object Started?
            _CS := CS_PIN
            _MOSI := MOSI_PIN
            _MISO := MISO_PIN
            _SCK := SCK_PIN

            outa[_CS] := 1
            dira[_CS] := 1
            outa[_SCK] := 0
            dira[_SCK] := 1
            time.MSleep (10)

            case Version
                $21, $22, $23, $24:                                 'Is it really an SX1231?
                    return okay
                OTHER:
                    return FALSE


    return FALSE                                                    'If we got here, something went wrong

PUB Stop

    spi.stop

PUB AbortListen | tmp
' Abort listen mode when used together with Listen(FALSE)
    readRegX (core#OPMODE, 1, @tmp)
    tmp &= core#MASK_LISTENABORT
    tmp := (tmp | (1 << core#FLD_LISTENABORT)) & core#OPMODE_MASK
    writeRegX (core#OPMODE, 1, @tmp)

PUB AddressCheck(method) | tmp
' Enable address checking/matching/filtering
'   Valid values:
'       ADDRCHK_NONE (%00): No address check
'       ADDRCHK_CHK_NO_BCAST (%01): Check address, but ignore broadcast addresses
'       ADDRCHK_CHK_00_BCAST (%10): Check address, and also respond to broadcast address
'   Any other value polls the chip and returns the current setting
    tmp := $00
    readRegX(core#PACKETCONFIG1, 1, @tmp)
    case method
        ADDRCHK_NONE, ADDRCHK_CHK_NO_BCAST, ADDRCHK_CHK_BCAST:
            method <<= core#FLD_ADDRESSFILTERING
        OTHER:
            result := ((tmp >> core#FLD_ADDRESSFILTERING) & core#BITS_ADDRESSFILTERING)
            return

    tmp &= core#MASK_ADDRESSFILTERING
    tmp := (tmp | method) & core#PACKETCONFIG1_MASK
    writeRegX(core#PACKETCONFIG1, 1, @tmp)

PUB AFCMethod(method) | tmp
' Set AFC method/routine
'   Valid values:
'       AFC_STANDARD (0): Standard AFC routine
'       AFC_IMPROVED (1): Improved AFC routine, for signals with modulation index < 2
'   Any other value polls the chip and returns the current setting
    readRegX (core#AFCCTRL, 1, @tmp)
    case method
        AFC_STANDARD, AFC_IMPROVED:
            method := method << core#FLD_AFCLOWBETAON
        OTHER:
            return (tmp >> core#FLD_AFCLOWBETAON) & %1

    tmp := (tmp | method) & core#AFCCTRL_MASK
    writeRegX (core#AFCCTRL, 1, @tmp)

PUB BattLow
' Battery low detector
'   Returns TRUE if battery low, FALSE otherwise
    readRegX (core#LOWBAT, 1, @result)
    result := ((result >> core#FLD_LOWBATMONITOR) & %1)* TRUE

PUB BitRate(bps) | tmp
' Set on-air data rate, in bits per second
'   Valid values:
'       1_200..300_000
'   Any other value polls the chip and returns the current setting
'   NOTE: Result will be rounded
'   NOTE: Effective data rate will be halved if Manchester encoding is used
    readRegX (core#BITRATEMSB, 2, @tmp)
    case bps
        1_200..300_000:
            bps := FXOSC / bps
        OTHER:
            result := tmp
            return FXOSC / result

    tmp := bps & core#BITS_BITRATE
    writeRegX (core#BITRATEMSB, 2, @tmp)
    return tmp

PUB CarrierFreq(Hz) | tmp
' Set Carrier frequency, in Hz
'   Valid values:
'       290_000_000..340_000_000, 424_000_000..510_000_000, 862_000_000..1_020_000_000
'   Any other value polls the chip and returns the current setting
'   NOTE: Set value will be rounded
    readRegX (core#FRFMSB, 3, @tmp)
    case Hz
        290_000_000..340_000_000, 424_000_000..510_000_000, 862_000_000..1_020_000_000:
            Hz := Hz / FSTEP
            Hz &= core#BITS_FRF
        OTHER:
            tmp &= core#BITS_FRF
            return tmp * FSTEP

    tmp := Hz & core#BITS_FRF
    writeRegX (core#FRFMSB, 3, @tmp)

PUB CRCCheck(enabled) | tmp
' Enable CRC calculation (TX) and checking (RX)
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
    tmp := $00
    readRegX(core#PACKETCONFIG1, 1, @tmp)
    case ||enabled
        0, 1:
            enabled := (||enabled & %1) << core#FLD_CRCON
        OTHER:
            result := ((tmp >> core#FLD_CRCON) & %1) * TRUE
            return

    tmp &= core#MASK_CRCON
    tmp := (tmp | enabled) & core#PACKETCONFIG1_MASK
    writeRegX(core#PACKETCONFIG1, 1, @tmp)

PUB DataMode(mode) | tmp
' Set data processing mode
'   Valid values:
'       DATAMODE_PACKET (0): Packet mode
'       DATAMODE_CONT_W_SYNC (2): Continuous mode with bit synchronizer
'       DATAMODE_CONT_WO_SYNC (3): Continuous mode without bit synchronizer
'   Any other value polls the chip and returns the current setting
    readRegX (core#DATAMODUL, 1, @tmp)
    case mode
        DATAMODE_PACKET, DATAMODE_CONT_W_SYNC, DATAMODE_CONT_WO_SYNC:
            mode := mode << core#FLD_DATAMODE
        OTHER:
            result := (tmp >> core#FLD_DATAMODE) & core#BITS_DATAMODE
            return result

    tmp &= core#MASK_DATAMODE
    tmp := (tmp | mode) & core#DATAMODUL_MASK
    writeRegX (core#DATAMODUL, 1, @tmp)

PUB DataWhitening(enabled) | tmp
' Enable data whitening
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
'   NOTE: This setting and ManchesterEnc are mutually exclusive; enabling this will disable ManchesterEnc
    tmp := $00
    readRegX(core#PACKETCONFIG1, 1, @tmp)
    case ||enabled
        0:
        1:
            enabled := DCFREE_WHITE << core#FLD_DCFREE
        OTHER:
            result := ((tmp >> core#FLD_DCFREE) & core#BITS_DCFREE)
            return (result == DCFREE_WHITE)

    tmp &= core#MASK_DCFREE
    tmp := (tmp | enabled) & core#PACKETCONFIG1_MASK
    writeRegX(core#PACKETCONFIG1, 1, @tmp)

PUB Deviation(Hz) | tmp
' Set carrier deviation, in Hz
'   Valid values:
'       600..300_000
'       Default is 5_000
'   Any other value polls the chip and returns the current setting
'   NOTE: Set value will be rounded
    tmp := 0
    readRegX (core#FDEVMSB, 2, @tmp)
    case Hz
        600..300_000:
            Hz := (Hz / FSTEP) & core#BITS_FDEV
        OTHER:
            tmp &= core#BITS_FDEV
            return tmp * FSTEP

    writeRegX (core#FDEVMSB, 2, @Hz)

PUB FIFOEmpty
' FIFO Empty status
'   Returns: TRUE if FIFO empty, FALSE if FIFO contains at least one byte
    result := $00
    readRegX (core#IRQFLAGS2, 1, @result)
    result := (((result >> core#FLD_FIFONOTEMPTY) & %1) ^ %1) * TRUE

PUB FIFOFull
' FIFO Full status
'   Returns: TRUE if FIFO full, FALSE if there's at least one byte available
    result := $00
    readRegX (core#IRQFLAGS2, 1, @result)
    result := ((result >> core#FLD_FIFOFULL) & %1) * TRUE

PUB Gain(dB) | tmp
' Set LNA gain, in dB relative to highest gain
'   Valid values:
'      *LNA_AGC (0): Gain is set by the internal AGC loop
'       LNA_HIGH (1): Highest gain
'       -6: Highest gain - 6dB
'       -12: Highest gain - 12dB
'       -24: Highest gain - 24dB
'       -36: Highest gain - 36dB
'       -48: Highest gain - 48dB
'   Any other value polls the chip and returns the current setting
    readRegX (core#LNA, 1, @tmp)
    case dB := lookdown(dB: LNA_AGC, LNA_HIGH, -6, -12, -24, -36, -48)
        1..7:
            dB := dB-1 & core#BITS_LNAGAINSELECT
        OTHER:
            result := tmp & core#BITS_LNAGAINSELECT
            return lookupz(result: LNA_AGC, LNA_HIGH, -6, -12, -24, -36, -48)

    tmp &= core#MASK_LNAGAINSELECT
    tmp := (tmp | dB) & core#LNA_MASK
    writeRegX (core#LNA, 1, @tmp)

PUB GaussianFilter(BT) | tmp
' Set Gaussian filter/data shaping parameters
'   Valid values:
'       BT_NONE (0): No shaping
'       BT_1_0 (1): Gaussian filter, BT = 1.0
'       BT_0_5 (2): Gaussian filter, BT = 0.5
'       BT_0_3 (3): Gaussian filter, BT = 0.3

'   Any other value polls the chip and returns the current setting
    readRegX (core#DATAMODUL, 1, @tmp)
    case BT
        BT_NONE..BT_0_3:
            BT := BT << core#FLD_MODULATIONSHAPING
        OTHER:
            result := (tmp >> core#FLD_MODULATIONSHAPING) & core#BITS_MODULATIONSHAPING
            return result

    tmp &= core#MASK_MODULATIONSHAPING
    tmp := (tmp | BT) & core#DATAMODUL_MASK
    writeRegX (core#DATAMODUL, 1, @tmp)

PUB Listen(enabled) | tmp
' Enable listen mode
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
'   NOTE: Should be enable when in standby mode
    readRegX (core#OPMODE, 1, @tmp)
    case ||enabled
        0, 1:
            enabled := (||enabled) << core#FLD_LISTENON
        OTHER:
            result := ((tmp >> core#FLD_LISTENON) & %1) * TRUE
            return result

    tmp &= core#MASK_LISTENON
    tmp := (tmp | enabled) & core#OPMODE_MASK
    writeRegX (core#OPMODE, 1, @tmp)

PUB LNAZInput(ohms) | tmp
' Set LNA's input impedance, in ohms
'   Valid values:
'       50, *200
'   Any other value polls the chip and returns the current setting
    readRegX (core#LNA, 1, @tmp)
    case ohms := lookdown(ohms: 50, 200)
        1, 2:
            ohms := (ohms-1) << core#FLD_LNAZIN
        OTHER:
            result := (tmp >> core#FLD_LNAZIN) & %1
            return lookupz(result: 50, 200)

    tmp &= core#MASK_LNAZIN
    tmp := (tmp | ohms) & core#LNA_MASK
    writeRegX (core#LNA, 1, @tmp)


PUB LowBattLevel(mV) | tmp
' Set low battery threshold, in millivolts
'   Valid values:
'       1695, 1764, *1835, 1905, 1976, 2045, 2116, 2185
'   Any other value polls the chip and returns the current setting
    readRegX (core#LOWBAT, 1, @tmp)
    case mV := lookdown(mV: 1695, 1764, 1835, 1905, 1976, 2045, 2116, 2185)
        1..8:
            mV := (mV-1) & core#BITS_LOWBATTRIM
        OTHER:
            result := tmp & core#BITS_LOWBATTRIM
            return lookupz(result: 1695, 1764, 1835, 1905, 1976, 2045, 2116, 2185)

    tmp &= core#MASK_LOWBATTRIM
    tmp := (tmp | mV) & core#LOWBAT_MASK
    writeRegX (core#LOWBAT, 1, @tmp)

PUB LowBattMon(enabled) | tmp
' Enable low battery detector signal
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
    readRegX (core#LOWBAT, 1, @tmp)
    case ||enabled
        0, 1:
            enabled := (||enabled) << core#FLD_LOWBATON
        OTHER:
            result := ((tmp >> core#FLD_LOWBATON) & %1) * TRUE
            return result

    tmp &= core#MASK_LOWBATON
    tmp := (tmp | enabled) & core#LOWBAT_MASK
    writeRegX (core#LOWBAT, 1, @tmp)

PUB ManchesterEnc(enabled) | tmp
' Enable Manchester encoding/decoding
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
'   NOTE: This setting and DataWhitening are mutually exclusive; enabling this will disable DataWhitening
    tmp := $00
    readRegX(core#PACKETCONFIG1, 1, @tmp)
    case ||enabled
        0:
        1:
            enabled := DCFREE_MANCH << core#FLD_DCFREE
        OTHER:
            result := ((tmp >> core#FLD_DCFREE) & core#BITS_DCFREE)
            return (result == DCFREE_MANCH)

    tmp &= core#MASK_DCFREE
    tmp := (tmp | enabled) & core#PACKETCONFIG1_MASK
    writeRegX(core#PACKETCONFIG1, 1, @tmp)

PUB Modulation(type) | tmp
' Set modulation type
'   Valid values:
'       MOD_FSK (0): Frequency Shift Keyed
'       MOD_OOK (1): On-Off Keyed
'   Any other value polls the chip and returns the current setting
    readRegX (core#DATAMODUL, 1, @tmp)
    case type
        MOD_FSK, MOD_OOK:
            type := type << core#FLD_MODULATIONTYPE
        OTHER:
            result := (tmp >> core#FLD_MODULATIONTYPE) & core#BITS_MODULATIONTYPE
            return result

    tmp &= core#MASK_MODULATIONTYPE
    tmp := (tmp | type) & core#DATAMODUL_MASK
    writeRegX (core#DATAMODUL, 1, @tmp)

PUB OCPCurrent(mA) | tmp
' Set PA overcurrent protection level, in milliamps
'   Valid values:
'       45..120 (Default: 95)
'   NOTE: Set value will be rounded to the nearest 5mA
'   Any other value polls the chip and returns the current setting
    readRegX (core#OCP, 1, @tmp)
    case mA
        45..120:
            mA := (mA-45)/5 & core#BITS_OCPTRIM
        OTHER:
            result := 45 + 5 * (tmp & core#BITS_OCPTRIM)
            return result

    tmp &= core#MASK_OCPTRIM
    tmp := (tmp | mA) & core#OCP_MASK
    writeRegX (core#OCP, 1, @tmp)

PUB OpMode(mode) | tmp
' Set operating mode
'   Valid values:
'       OPMODE_SLEEP (0): Sleep mode
'       OPMODE_STDBY (1): Standby mode
'       OPMODE_FS (2): Frequency Synthesizer mode
'       OPMODE_TX (3): Transmitter mode
'       OPMODE_RX (4): Receiver mode
'   Any other value polls the chip and returns the current setting
    readRegX (core#OPMODE, 1, @tmp)
    case mode
        %000..%100:
            mode := mode << core#FLD_MODE
        OTHER:
            return (tmp >> core#FLD_MODE) & core#BITS_MODE

    tmp &= core#MASK_MODE
    tmp := (tmp | mode) & core#OPMODE_MASK
    writeRegX (core#OPMODE, 1, @tmp)

PUB OutputPower(dBm) | tmp
' Set transmit output power, in dBm
'   Valid values:
'       -18..17
'   Any other value polls the chip and returns the current setting
    tmp := 0
    readRegX (core#PALEVEL, 1, @tmp)
    case dBm
        -18..17:
            dBm := (dBm + 18) & core#BITS_OUTPUTPOWER
        OTHER:
            result := tmp & core#BITS_OUTPUTPOWER
            result := result - 18'case pa[012] bitfield
            return result

    tmp &= core#MASK_OUTPUTPOWER
    tmp := (tmp | dBm) & core#PALEVEL_MASK
    writeRegX (core#PALEVEL, 1, @tmp)

PUB OvercurrentProtection(enabled) | tmp
' Enable PA overcurrent protection
'   Valid values: *TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
    readRegX (core#OCP, 1, @tmp)
    case ||enabled
        0, 1:
            enabled := (||enabled) << core#FLD_OCPON
        OTHER:
            result := ((tmp >> core#FLD_OCPON) & %1) * TRUE
            return result

    tmp &= core#MASK_OCPON
    tmp := (tmp | enabled) & core#OCP_MASK
    writeRegX (core#OCP, 1, @tmp)

PUB PacketSent
' Packet sent status
'   Returns: TRUE if packet sent, FALSE otherwise
'   NOTE: Once set, this flag clears when exiting TX mode
    result := $00
    readRegX (core#IRQFLAGS2, 1, @result)
    result := ((result >> core#FLD_PACKETSENT) & %1) * TRUE

PUB PreambleBytes(bytes) | tmp
' Set number of bytes in preamble
'   Valid values: 0..65535
'   Any other value polls the chip and returns the current setting
    tmp := $00
    readRegX(core#PREAMBLEMSB, 2, @tmp)
    case bytes
        0..65535:
        OTHER:
            return tmp

    writeRegX(core#PREAMBLEMSB, 2, @bytes)

PUB RampTime(uSec) | tmp
' Set rise/fall time of ramp up/down in FSK, in microseconds
'   Valid values:
'       3400, 2000, 1000, 500, 250, 125, 100, 62, 50, 40, 31, 25, 20, 15, 12, 10
'   Any other value polls the chip and returns the current setting
    readRegX (core#PARAMP, 1, @tmp)
    case uSec := lookdown(uSec: 3400, 2000, 1000, 500, 250, 125, 100, 62, 50, 40, 31, 25, 20, 15, 12, 10)
        1..16:
            uSec := (uSec-1) & core#BITS_PARAMP
        OTHER:
            result := tmp & core#BITS_PARAMP
            return lookupz(result: 3400, 2000, 1000, 500, 250, 125, 100, 62, 50, 40, 31, 25, 20, 15, 12, 10)

    tmp := uSec & core#PARAMP_MASK
    writeRegX (core#PARAMP, 1, @tmp)

PUB RCOscCal(enabled) | tmp
' Trigger calibration of RC oscillator
'   Valid values:
'       TRUE (-1 or 1)
'   Any other value polls the chip and returns the current calibration status
'   Returns:
'       FALSE: RC calibration in progress
'       TRUE: RC calibration complete
    readRegX (core#OSC1, 1, @tmp)
    case ||enabled
        1:
            enabled := (||enabled) << core#FLD_RCCALSTART
        OTHER:
            result := ((tmp >> core#FLD_RCCALDONE) & %1) * TRUE
            return result

    tmp := (tmp | enabled) & core#OSC1_MASK
    writeRegX (core#OSC1, 1, @tmp)

PUB Sequencer(mode) | tmp
' Control automatic sequencer
'   Valid values:
'       *OPMODE_AUTO (0): Automatic sequence, as selected by OperatingMode
'        OPMODE_MANUAL (1): Mode is forced
'   Any other value polls the chip and returns the current setting
    readRegX (core#OPMODE, 1, @tmp)
    case mode
        OPMODE_AUTO, OPMODE_MANUAL:
            mode := mode << core#FLD_SEQUENCEROFF
        OTHER:
            result := (tmp >> core#FLD_SEQUENCEROFF) & %1
            return result

    tmp &= core#MASK_SEQUENCEROFF
    tmp := (tmp | mode) & core#OPMODE_MASK
    writeRegX (core#OPMODE, 1, @tmp)

PUB SyncWord(rw, buff_addr)
' Set sync word to value at buff_addr
'   Valid values:
'       rw: SW_READ (0), SW_WRITE (1)
'       variable at address buff_addr: All bytes can be $00..$FF
'   For rw, any value other than SW_WRITE (1) polls the chip and returns the current setting
'   NOTE: Variable pointed to by buff_addr must be at least 8 bytes in length
    case rw
        SW_WRITE:
            writeRegX(core#SYNCVALUE1, 8, buff_addr)
            return $E111_1111
        OTHER:
            readRegX(core#SYNCVALUE1, 8, buff_addr)  'XXX Future test: set nr_bytes arg to SyncWordBytes(-2)?
            return $E000_0000

PUB SyncWordEnabled(enable) | tmp
' Enable sync word generation (TX) and detection (RX)
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
    tmp := $00
    readRegX(core#SYNCCONFIG, 1, @tmp)
    case ||enable
        0, 1:
            enable := ||enable << core#FLD_SYNCON
        OTHER:
            return ((tmp >> core#FLD_SYNCON) & %1) * TRUE

    tmp &= core#MASK_SYNCON
    tmp := (tmp | enable) & core#SYNCCONFIG_MASK
    writeRegX(core#SYNCCONFIG, 1, @tmp)

PUB SyncWordLength(bytes) | tmp
' Set number of bytes in sync word
'   Valid values: 1..8
'   Any other value polls the chip and returns the current setting
    tmp := $00
    readRegX(core#SYNCCONFIG, 1, @tmp)
    case bytes
        1..8:
            bytes := (bytes-1) << core#FLD_SYNCSIZE
        OTHER:
            return ((tmp >> core#FLD_SYNCSIZE) & core#BITS_SYNCSIZE) + 1

    tmp &= core#MASK_SYNCSIZE
    tmp := (tmp | bytes) & core#SYNCCONFIG_MASK
    writeRegX(core#SYNCCONFIG, 1, @tmp)

PUB SyncWordMaxBitErr(bits) | tmp
' Set maximum number of tolerated bit errors in sync word
'   Valid values: 0..7
'   Any other value polls the chip and returns the current setting
    tmp := $00
    readRegX(core#SYNCCONFIG, 1, @tmp)
    case bits
        0..7:
        OTHER:
            return (tmp & core#BITS_SYNCTOL)

    tmp &= core#MASK_SYNCTOL
    tmp := (tmp | bits) & core#SYNCCONFIG_MASK
    writeRegX(core#SYNCCONFIG, 1, @tmp)


PUB Version
' Read silicon revision
'   Returns:
'       Value   Chip version
'       $21:    V2a
'       $22:    V2b
'       $23:    V2c
'       $24:    ???
    readRegX (core#VERSION, 1, @result)

PUB readRegX(reg, nr_bytes, buf_addr) | i
' Read nr_bytes from register 'reg' to address 'buf_addr'
    case reg
        $00..$13, $18..$4F, $58..59, $5F, $6F, $71:
            outa[_CS] := 0
            spi.SHIFTOUT(_MOSI, _SCK, core#MOSI_BITORDER, 8, reg)
            repeat i from nr_bytes-1 to 0
                byte[buf_addr][i] := spi.SHIFTIN(_MISO, _SCK, core#MISO_BITORDER, 8)
            outa[_CS] := 1

        OTHER:
            return FALSE

PUB writeRegX(reg, nr_bytes, buf_addr) | i
' Write nr_bytes to register 'reg' stored in val
    case reg
        $00..$13, $18..$4F, $58..59, $5F, $6F, $71:
            outa[_CS] := 0
            spi.SHIFTOUT(_MOSI, _SCK, core#MOSI_BITORDER, 8, reg|core#W)
            repeat i from nr_bytes-1 to 0
                spi.SHIFTOUT(_MOSI, _SCK, core#MOSI_BITORDER, 8, byte[buf_addr][i])
            outa[_CS] := 1

        OTHER:
            return FALSE

DAT
{
    --------------------------------------------------------------------------------------------------------
    TERMS OF USE: MIT License

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
    associated documentation files (the "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
    following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial
    portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
    LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    --------------------------------------------------------------------------------------------------------
}
