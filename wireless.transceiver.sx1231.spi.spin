{
    --------------------------------------------
    Filename: wireless.transceiver.sx1231.spi.spin
    Author: Jesse Burt
    Description: Driver for the Semtech SX1231 UHF Transceiver IC
    Copyright (c) 2019
    Started Apr 19, 2019
    Updated Apr 19, 2019
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

VAR

    byte _CS, _MOSI, _MISO, _SCK

OBJ

    spi : "SPI_Asm"                                             'PASM SPI Driver
    core: "core.con.sx1231"
    time: "time"                                                'Basic timing functions

PUB Null
''This is not a top-level object

PUB Start(CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN) : okay

    okay := Startx(CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN, core#CLK_DELAY, core#CPOL)

PUB Startx(CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN, SCK_DELAY, SCK_CPOL): okay
    if SCK_DELAY => 1 and lookdown(SCK_CPOL: 0, 1)
        if okay := spi.start (SCK_DELAY, SCK_CPOL)              'SPI Object Started?
            _CS := CS_PIN
            _MOSI := MOSI_PIN
            _MISO := MISO_PIN
            _SCK := SCK_PIN

            outa[_CS] := 1
            dira[_CS] := 1
            outa[_SCK] := 0
            dira[_SCK] := 1
            time.MSleep (10)                                     'Add startup delay appropriate to your device (consult its datasheet)

            case Version
                $21, $22, $23, $24:
                    return okay
                OTHER:
                    return FALSE


    return FALSE                                                'If we got here, something went wrong

PUB AbortListen | tmp
' Abort listen mode when used together with Listen(FALSE)
    readRegX (core#OPMODE, 1, @tmp)
    tmp &= core#MASK_LISTENABORT
    tmp := (tmp | (1 << core#FLD_LISTENABORT)) & core#OPMODE_MASK
    writeRegX (core#OPMODE, 1, @tmp)

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
            bps := SwapByteOrder (bps)
        OTHER:
            tmp := SwapByteOrder (tmp)
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
            Hz.byte[3] := Hz.byte[0]
            Hz.byte[0] := Hz.byte[2]
            Hz.byte[2] := Hz.byte[3]
            Hz &= core#BITS_FRF
        OTHER:
            tmp.byte[3] := tmp.byte[0]
            tmp.byte[0] := tmp.byte[2]
            tmp.byte[2] := tmp.byte[3]
            tmp &= core#BITS_FRF
            return tmp * FSTEP

    tmp := Hz & core#BITS_FRF
    writeRegX (core#FRFMSB, 3, @tmp)

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
            Hz := Hz / FSTEP
        OTHER:
            tmp := SwapByteOrder (tmp) & core#BITS_FDEV
            return tmp * FSTEP

    tmp := SwapByteOrder (Hz)
    writeRegX (core#FDEVMSB, 2, @tmp)

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

PUB Stop

    spi.stop

PUB Version
' Read silicon revision
'   Returns:
'       Value   Chip version
'       $21:    V2a
'       $22:    V2b
'       $23:    V2c
'       $24:    ???
    readRegX (core#VERSION, 1, @result)

PUB SwapByteOrder(in_word)

    result := (in_word >> 8) | ((in_word << 8) & $FFFF)

PUB readRegX(reg, nr_bytes, buf_addr) | i
' Read nr_bytes from register 'reg' to address 'buf_addr'
    outa[_CS] := 0

    spi.SHIFTOUT(_MOSI, _SCK, core#MOSI_BITORDER, 8, reg)
    
    repeat i from 0 to nr_bytes-1
        byte[buf_addr][i] := spi.SHIFTIN(_MISO, _SCK, core#MISO_BITORDER, 8)

    outa[_CS] := 1

PUB writeRegX(reg, nr_bytes, buf_addr) | i
' Write nr_bytes to register 'reg' stored in val

    outa[_CS] := 0

    spi.SHIFTOUT(_MOSI, _SCK, core#MOSI_BITORDER, 8, reg|core#W)

    repeat i from 0 to nr_bytes-1
        spi.SHIFTOUT(_MOSI, _SCK, core#MOSI_BITORDER, 8, byte[buf_addr][i])

    outa[_CS] := 1

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
