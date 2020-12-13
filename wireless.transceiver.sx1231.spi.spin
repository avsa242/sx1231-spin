{
    --------------------------------------------
    Filename: wireless.transceiver.sx1231.spi.spin
    Author: Jesse Burt
    Description: Driver for the Semtech SX1231 UHF Transceiver IC
    Copyright (c) 2020
    Started Apr 19, 2019
    Updated Dec 13, 2020
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
    DATAMODE_PKT         = 0
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

' Intermediate modes
    IMODE_SLEEP             = %00
    IMODE_STBY              = %01
    IMODE_RX                = %10
    IMODE_TX                = %11

' Conditions for entering and exiting intermediate modes
    ENTCOND_NONE            = %000
    ENTCOND_FIFONOTEMPTY    = %001
    ENTCOND_FIFOLVL         = %010
    ENTCOND_CRCOK           = %011
    ENTCOND_PAYLDRDY        = %100
    ENTCOND_SYNCADD         = %101
    ENTCOND_PKTSENT         = %110
    ENTCOND_FIFOEMPTY       = %111

    EXITCOND_NONE           = %000
    EXITCOND_FIFOEMPTY      = %001
    EXITCOND_FIFOLVL        = %010
    EXITCOND_CRCOK          = %011
    EXITCOND_PAYLDRDY       = %100
    EXITCOND_SYNCADD        = %101
    EXITCOND_PKTSENT        = %110
    EXITCOND_TIMEOUT        = %111

' Conditions for starting packet transmission
    TXSTART_FIFOLVL         = 0
    TXSTART_FIFONOTEMPTY    = 1

' AES Key
    KEY_RD                  = 0
    KEY_WR                  = 1

' Packet length config
    PKTLEN_FIXED            = 0
    PKTLEN_VAR              = 1

' Constants for compatibility with other drivers
    IDLE_RXTX               = 0
    SYNCMODE_3032_CS        = 0
    AGC_OFF                 = 0

VAR

    long _CS, _SCK, _MOSI, _MISO

OBJ

    spi : "com.spi.4w"
    core: "core.con.sx1231"
    time: "time"
    io  : "io"

PUB Null
''This is not a top-level object

PUB Startx(CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN): okay

    if okay := spi.start(core#CLK_DLY, core#CPOL)
        longmove(@_CS, CS_PIN, 4)
        io.High(_CS)
        io.Output(_CS)

        time.MSleep (10)

        if lookdown(DeviceID: $21, $22, $23, $24)'Is it really an SX1231?
            return okay

    return FALSE                                ' something above failed

PUB Stop

    spi.stop

PUB Defaults | tmp[4]
' Factory defaults
    AddressCheck(ADDRCHK_NONE)
    AFCAuto(FALSE)
    AFCMethod(AFC_STANDARD)
    AutoRestartRX(TRUE)
    BroadcastAddress($00)
    CarrierFreq(915_000_000)
    CRCCheckEnabled(TRUE)
    DataMode(DATAMODE_PKT)
    DataRate(4800)
    DataWhitening(FALSE)
    Encryption(FALSE)
    bytefill(@tmp, $00, 16)
    EncryptionKey(KEY_WR, @tmp)
    EnterCondition(ENTCOND_NONE)
    ExitCondition(EXITCOND_NONE)
    FIFOThreshold(15)
    FreqDeviation(5000)
    GaussianFilter(BT_NONE)
    IntermediateMode(IMODE_SLEEP)
    Listen(FALSE)
    LNAGain(LNA_AGC)
    LNAZInput(200)
    LowBattLevel(1_835)
    LowBattMon(FALSE)
    ManchesterEnc(FALSE)
    Modulation(MOD_FSK)
    NodeAddress($00)
    OCPCurrent(95)
    OpMode(OPMODE_STDBY)
    OvercurrentProtection(TRUE)
    PayloadLen(64)
    PayloadLenCfg(PKTLEN_FIXED)
    PreambleLen(3)
    RampTime(40)
    RXBandwidth(10_400)
    Sequencer(OPMODE_AUTO)
    bytefill(@tmp, $01, 8)
    SyncWord(SW_WRITE, @tmp)
    SyncWordEnabled(TRUE)
    SyncWordLength(4)
    SyncWordMaxBitErr(0)
    TXPower(13)
    TXStartCondition(TXSTART_FIFONOTEMPTY)

PUB AbortListen | tmp
' Abort listen mode when used together with Listen(FALSE)
    readReg (core#OPMODE, 1, @tmp)
    tmp &= core#LISTENABT_MASK
    tmp := (tmp | (1 << core#LISTENABT)) & core#OPMODE_MASK
    writeReg (core#OPMODE, 1, @tmp)

PUB AddressCheck(mode) | tmp
' Enable address checking/matching/filtering
'   Valid values:
'       ADDRCHK_NONE (%00): No address check
'       ADDRCHK_CHK_NO_BCAST (%01): Check address, but ignore broadcast addresses
'       ADDRCHK_CHK_00_BCAST (%10): Check address, and also respond to broadcast address
'   Any other value polls the chip and returns the current setting
    tmp := $00
    readReg(core#PKTCFG1, 1, @tmp)
    case mode
        ADDRCHK_NONE, ADDRCHK_CHK_NO_BCAST, ADDRCHK_CHK_BCAST:
            mode <<= core#ADDRFILT
        OTHER:
            result := ((tmp >> core#ADDRFILT) & core#ADDRFILT_BITS)
            return

    tmp &= core#ADDRFILT_MASK
    tmp := (tmp | mode) & core#PKTCFG1_MASK
    writeReg(core#PKTCFG1, 1, @tmp)

PUB AFCAuto(enabled) | tmp
' Enable automatic AFC
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
    tmp := $00
    readReg(core#AFCFEI, 1, @tmp)
    case ||enabled
        0, 1:
            enabled := (||enabled << core#AFCAUTOON)
        OTHER:
            result := ((tmp >> core#AFCAUTOON) & %1) * TRUE
            return

    tmp &= core#AFCAUTOON_MASK
    tmp := (tmp | enabled) & core#AFCFEI_MASK
    writeReg(core#AFCFEI, 1, @tmp)

PUB AFCComplete
' AFC (auto or manual) completed
'   Returns: TRUE if complete, FALSE otherwise
    readReg (core#AFCFEI, 1, @result)
    result := ((result >> core#AFCDONE) & %1) * TRUE

PUB AFCMethod(method) | tmp
' Set AFC method/routine
'   Valid values:
'       AFC_STANDARD (0): Standard AFC routine
'       AFC_IMPROVED (1): Improved AFC routine, for signals with modulation index < 2
'   Any other value polls the chip and returns the current setting
    readReg (core#AFCCTRL, 1, @tmp)
    case method
        AFC_STANDARD, AFC_IMPROVED:
            method := method << core#AFCLOWBETAON
        OTHER:
            return (tmp >> core#AFCLOWBETAON) & %1

    tmp := (tmp | method) & core#AFCCTRL_MASK
    writeReg (core#AFCCTRL, 1, @tmp)

PUB AFCOffset | tmp
' Read AFC frequency offset
'   Returns: Frequency offset in Hz
    tmp := $00
    readReg(core#AFCMSB, 2, @tmp)
    if tmp & $8000  'XXX use spin sign-extend
        result := (65536-tmp) * FSTEP
    else
        result := tmp * FSTEP
    return

PUB AFCStart | tmp
' Trigger a manual AFC
    readReg (core#AFCFEI, 1, @tmp)
    tmp |= %1   '1 << core#AFCSTART
    writeReg (core#AFCFEI, 1, @tmp)

PUB AfterRX(next_state)
' Defines the state the radio transitions to after a packet is successfully received
    result := IntermediateMode(next_state)

PUB AfterTX(next_state)
' Defines the state the radio transitions to after a packet is successfully transmitted
    result := IntermediateMode(next_state)

PUB AGCFilterLength(param)
' dummy method

PUB AGCMode(param)
' dummy method

PUB AppendStatus(param)
' dummy method

PUB AutoCal(param)
' dummy method

PUB AutoRestartRX(enabled) | tmp
' Enable automatic RX restart (RSSI phase)
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
'   NOTE: Restart occurs after payload is ready and the packet has been read from the FIFO
    tmp := $00
    readReg(core#PKTCFG2, 1, @tmp)
    case ||enabled
        0, 1:
            enabled := ||enabled << core#AUTORSTARTRXON
        OTHER:
            result := ((tmp >> core#AUTORSTARTRXON) & %1) * TRUE
            return

    tmp &= core#AUTORSTARTRXON
    tmp := (tmp | enabled) & core#PKTCFG2_MASK
    writeReg(core#PKTCFG2, 1, @tmp)

PUB BattLow
' Battery low detector
'   Returns TRUE if battery low, FALSE otherwise
    readReg (core#LOWBAT, 1, @result)
    result := ((result >> core#LOWBATMON) & %1)* TRUE

PUB BroadcastAddress(addr) | tmp
' Set broadcast address
'   Valid values: $00..$FF
'   Any other value polls the chip and returns the current setting
    tmp := $00
    readReg (core#BCASTADRS, 1, @tmp)
    case addr
        $00..$FF:
        OTHER:
            return tmp

    writeReg (core#BCASTADRS, 1, @addr)

PUB CarrierFreq(Hz) | tmp
' Set Carrier frequency, in Hz
'   Valid values:
'       290_000_000..340_000_000, 424_000_000..510_000_000, 862_000_000..1_020_000_000
'   Any other value polls the chip and returns the current setting
'   NOTE: Set value will be rounded
    readReg (core#FRFMSB, 3, @tmp)'XXX move to get case
    case Hz
        290_000_000..340_000_000, 424_000_000..510_000_000, 862_000_000..1_020_000_000:
            Hz := Hz / FSTEP
            Hz &= core#FRF_MASK
        OTHER:
            tmp &= core#FRF_MASK
            return tmp * FSTEP

    tmp := Hz & core#FRF_MASK   'XXX move to set case
    writeReg (core#FRFMSB, 3, @tmp)

PUB CarrierSense(param)
' dummy method

PUB Channel(param)
' dummy method

PUB CRCCheckEnabled(enabled) | tmp
' Enable CRC calculation (TX) and checking (RX)
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
    tmp := $00
    readReg(core#PKTCFG1, 1, @tmp)
    case ||enabled
        0, 1:
            enabled := (||enabled & %1) << core#CRCON
        OTHER:
            result := ((tmp >> core#CRCON) & %1) * TRUE
            return

    tmp &= core#CRCON_MASK
    tmp := (tmp | enabled) & core#PKTCFG1_MASK
    writeReg(core#PKTCFG1, 1, @tmp)

PUB CRCLength(param)
' dummy method

PUB DataMode(mode) | tmp
' Set data processing mode
'   Valid values:
'       DATAMODE_PKT (0): Packet mode
'       DATAMODE_CONT_W_SYNC (2): Continuous mode with bit synchronizer
'       DATAMODE_CONT_WO_SYNC (3): Continuous mode without bit synchronizer
'   Any other value polls the chip and returns the current setting
    readReg (core#DATAMOD, 1, @tmp)
    case mode
        DATAMODE_PKT, DATAMODE_CONT_W_SYNC, DATAMODE_CONT_WO_SYNC:
            mode := mode << core#DATAMODE
        OTHER:
            result := (tmp >> core#DATAMODE) & core#DATAMODE_BITS
            return result

    tmp &= core#DATAMODE_MASK
    tmp := (tmp | mode) & core#DATAMOD_MASK
    writeReg (core#DATAMOD, 1, @tmp)

PUB DataRate(bps) | tmp
' Set on-air data rate, in bits per second
'   Valid values:
'       1_200..300_000
'   Any other value polls the chip and returns the current setting
'   NOTE: Result will be rounded
'   NOTE: Effective data rate will be halved if Manchester encoding is used
    readReg (core#BITRATEMSB, 2, @tmp)'XXX move to get case
    case bps
        1_200..300_000:
            bps := FXOSC / bps
        OTHER:
            result := tmp
            return FXOSC / result

    tmp := bps & core#BITRATE_MASK 'XXX move to set case
    writeReg (core#BITRATEMSB, 2, @tmp)
    return tmp

PUB DataWhitening(enabled) | tmp
' Enable data whitening
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
'   NOTE: This setting and ManchesterEnc are mutually exclusive; enabling this will disable ManchesterEnc
    tmp := $00
    readReg(core#PKTCFG1, 1, @tmp)
    case ||enabled
        0:
        1:
            enabled := DCFREE_WHITE << core#DCFREE
        OTHER:
            result := ((tmp >> core#DCFREE) & core#DCFREE_BITS)
            return (result == DCFREE_WHITE)

    tmp &= core#DCFREE_MASK
    tmp := (tmp | enabled) & core#PKTCFG1_MASK
    writeReg(core#PKTCFG1, 1, @tmp)

PUB DCBlock(param)
' dummy method

PUB DeviceID
' Read device ID
'   Returns:
'       Value   Chip version
'       $21:    V2a
'       $22:    V2b
'       $23:    V2c
'       $24:    ???
    readReg (core#VERSION, 1, @result)

PUB DVGAGain(param)
' dummy method

PUB Encryption(enabled) | tmp
' Enable AES encryption/decryption
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
'   NOTE: Encryption is limited to payloads of a maximum of 66 bytes
    tmp := $00
    readReg(core#PKTCFG2, 1, @tmp)
    case ||enabled
        0, 1:
            enabled := ||enabled & %1
        OTHER:
            result := (tmp & %1) * TRUE
            return

    tmp &= core#AESON_MASK
    tmp := (tmp | enabled) & core#PKTCFG2_MASK
    writeReg(core#PKTCFG2, 1, @tmp)

PUB EncryptionKey(rw, buff_addr) | tmp
' Set AES 128-bit encryption key
'   Valid values:
'       rw: KEY_RD (0), KEY_WR (1)
'       buff_addr: All bytes at address may be $00..$FF
'   NOTE: Variable at buff_addr must be at least 16 bytes
'           1st byte of key is MSB
    case rw
        KEY_WR:
            writeReg(core#AESKEY1, 16, buff_addr)
        OTHER:
            readReg(core#AESKEY1, 16, buff_addr)

PUB EnterCondition(condition) | tmp
' Set interrupt condition for entering intermediate mode
'   Valid values:
'       ENTCOND_NONE (%000)            Automodes off
'       ENTCOND_FIFONOTEMPTY (%001)    Rising edge of FIFO not empty
'       ENTCOND_FIFOLVL (%010)         Rising edge of FIFO level
'       ENTCOND_CRCOK (%011)           Rising edge of CRC OK
'       ENTCOND_PAYLDRDY (%100)        Rising edge of Payload ready
'       ENTCOND_SYNCADD (%101)         Rising edge of Sync Address
'       ENTCOND_PKTSENT (%110)         Rising edge of Packet sent
'       ENTCOND_FIFOEMPTY (%111)       Falling edge of FIFO not empty (i.e., FIFO empty)
'   Any other value polls the chip and returns the current setting
    tmp := $00
    readReg (core#AUTOMODES, 1, @tmp)
    case condition
        ENTCOND_NONE, ENTCOND_FIFONOTEMPTY, ENTCOND_FIFOLVL, ENTCOND_CRCOK, ENTCOND_PAYLDRDY, ENTCOND_SYNCADD, ENTCOND_PKTSENT, ENTCOND_FIFOEMPTY:
            condition <<= core#ENTCOND
        OTHER:
            result := (tmp >> core#ENTCOND) & core#ENTCOND_BITS 'XXX RETURN

    tmp &= core#ENTCOND_MASK
    tmp := (tmp | condition) & core#AUTOMODES_MASK
    writeReg(core#AUTOMODES, 1, @tmp)

PUB ExitCondition(condition) | tmp
' Set interrupt condition for entering intermediate mode
'   Valid values:
'       EXITCOND_NONE (%000)           Automodes off
'       EXITCOND_FIFOEMPTY (%001)      Falling edge of FIFO not empty
'       EXITCOND_FIFOLVL (%010)        Rising edge of FIFO level or timeout
'       EXITCOND_CRCOK (%011)          Rising edge of CRC OK or timeout
'       EXITCOND_PAYLDRDY (%100)       Rising edge of Payload ready or timeout
'       EXITCOND_SYNCADD (%101)        Rising edge of Sync Addressor timeout
'       EXITCOND_PKTSENT (%110)        Rising edge of Packet sent
'       EXITCOND_TIMEOUT (%111)        Rising edge of timeout
'   Any other value polls the chip and returns the current setting
    tmp := $00
    readReg (core#AUTOMODES, 1, @tmp)
    case condition
        EXITCOND_NONE, EXITCOND_FIFOEMPTY, EXITCOND_FIFOLVL, EXITCOND_CRCOK, EXITCOND_PAYLDRDY, EXITCOND_SYNCADD, EXITCOND_PKTSENT, EXITCOND_TIMEOUT:
            condition <<= core#EXITCOND
        OTHER:
            result := (tmp >> core#EXITCOND) & core#EXITCOND_BITS 'XXX RETURN

    tmp &= core#EXITCOND_MASK
    tmp := (tmp | condition) & core#AUTOMODES_MASK
    writeReg(core#AUTOMODES, 1, @tmp)

PUB FEIComplete
' Indicates if FEI measurement complete
'   Returns: TRUE if complete, FALSE otherwise
    result := $00
    readReg(core#AFCFEI, 1, @result)
    result := ((result >> core#FEIDONE) & %1) * TRUE
    return

PUB FEIError | tmp
' Frequency error
'   Returns: FEI measurement, in Hz
    tmp := $00
    readReg(core#AFCFEI, 2, @tmp)
    if tmp & $8000 'XXX USE SPIN SIGN EXT
        result := (65536-tmp) * FSTEP
    else
        result := tmp * FSTEP
    return

PUB FEIStart | tmp
' Trigger a manual FEI measurement
    tmp := $00
    readReg(core#AFCFEI, 1, @tmp)
    tmp := tmp | (1 << core#FEISTART)
    writeReg(core#AFCFEI, 1, @tmp)

PUB FIFOEmpty
' FIFO Empty status
'   Returns: TRUE if FIFO empty, FALSE if FIFO contains at least one byte
    result := $00
    readReg (core#IRQFLAGS2, 1, @result)
    result := (((result >> core#FIFONOTEMPTY) & %1) ^ %1) * TRUE

PUB FIFOFull
' FIFO Full status
'   Returns: TRUE if FIFO full, FALSE if there's at least one byte available
    result := $00
    readReg (core#IRQFLAGS2, 1, @result)
    result := ((result >> core#FIFOFULL) & %1) * TRUE

PUB FIFOThreshold(bytes) | tmp
' Set threshold for triggering FIFO level interrupt
'   Valid values: 0..127
'   Any other value polls the chip and returns the current setting
    tmp := $00
    readReg(core#FIFOTHRESH, 1, @tmp)
    case bytes
        0..127:
        OTHER:
            return tmp & core#FIFOTHRESHOLD_BITS

    tmp &= core#FIFOTHRESHOLD_MASK
    tmp := (tmp | bytes) & core#FIFOTHRESH_MASK
    writeReg(core#FIFOTHRESH, 1, @tmp)

PUB FlushTX
' dummy method

PUB FreqDeviation(Hz) | tmp
' Set carrier deviation, in Hz
'   Valid values:
'       600..300_000
'       Default is 5_000
'   Any other value polls the chip and returns the current setting
'   NOTE: Set value will be rounded
    tmp := 0
    readReg (core#FDEVMSB, 2, @tmp)' XXX MOVE TO GET CASE
    case Hz
        600..300_000:
            Hz := (Hz / FSTEP) & core#FDEV_MASK
        OTHER:
            tmp &= core#FDEV_MASK
            return tmp * FSTEP

    writeReg (core#FDEVMSB, 2, @Hz)'XXX MOVE TO SET CASE

PUB FSTX
' dummy method

PUB GaussianFilter(BT) | tmp
' Set Gaussian filter/data shaping parameters
'   Valid values:
'       BT_NONE (0): No shaping
'       BT_1_0 (1): Gaussian filter, BT = 1.0
'       BT_0_5 (2): Gaussian filter, BT = 0.5
'       BT_0_3 (3): Gaussian filter, BT = 0.3

'   Any other value polls the chip and returns the current setting
    readReg (core#DATAMOD, 1, @tmp)
    case BT
        BT_NONE..BT_0_3:
            BT := BT << core#MODSHP
        OTHER:
            result := (tmp >> core#MODSHP) & core#MODSHP_BITS
            return result

    tmp &= core#MODSHP_MASK
    tmp := (tmp | BT) & core#DATAMOD_MASK
    writeReg (core#DATAMOD, 1, @tmp)

PUB Idle
' Change chip state to idle (standby)
    OpMode (OPMODE_STDBY)

PUB IntermediateMode(mode) | tmp
' Set intermediate operating mode
'   Valid values:
'       IMODE_SLEEP (%00): Sleep
'       IMODE_STBY (%01): Standby
'       IMODE_RX (%10): Receive
'       IMODE_TX (%11): Transmit
'   Any other value polls the chip and returns the current setting
    tmp := $00
    readReg(core#AUTOMODES, 1, @tmp)
    case mode
        IMODE_SLEEP, IMODE_STBY, IMODE_RX, IMODE_TX:
            mode &= core#INTMDTMODE
        OTHER:
            result := (tmp >> core#INTMDTMODE) & core#INTMDTMODE_BITS'XXX RETURN

    tmp &= core#INTMDTMODE_MASK
    tmp := (tmp | mode) & core#AUTOMODES_MASK
    writeReg(core#AUTOMODES, 1, @tmp)

PUB Interrupt
' Read interrupt state
'   Bits:
'   15  - FIFO is full
'   14  - FIFO isn't empty
'   13  - FIFO level exceeds threshold set by FIFOThreshold()
'   12  - FIFO overrun
'   11  - Payload sent
'   10  - Payload ready
'   9   - RX Payload CRC OK
'   8   - Battery voltage below level set by LowBattLevel()
'   7   - OpMode ready
'   6   - RX mode only: After RSSI, AGC and AFC
'   5   - TX mode only: after PA ramp up
'   4   - FS, RX, TX OpModes: PLL locked
'   3   - RX mode only: RSSI exceeds level set by RSSIThreshold()
'   2   - Timeout
'   1   - Entered intermediate mode
'   0   - Syncword and address (if enabled) match
    readReg(core#IRQFLAGS1, 2, @result)

PUB IntFreq(param)
' dummy method

PUB Listen(enabled) | tmp
' Enable listen mode
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
'   NOTE: Should be enable when in standby mode
    readReg (core#OPMODE, 1, @tmp)
    case ||enabled
        0, 1:
            enabled := (||enabled) << core#LISTENON
        OTHER:
            result := ((tmp >> core#LISTENON) & %1) * TRUE
            return result

    tmp &= core#LISTENON_MASK
    tmp := (tmp | enabled) & core#OPMODE_MASK
    writeReg (core#OPMODE, 1, @tmp)

PUB LNAGain(dB) | tmp
' Set LNA gain, in dB relative to highest gain
'   Valid values:
'      *LNA_AGC (0): Gain is set by the internal AGC loop
'       LNA_HIGH (1): Highest gain
'       -6: (Highest gain - 6dB)
'       -12: (Highest gain - 12dB)
'       -24: (Highest gain - 24dB)
'       -36: (Highest gain - 36dB)
'       -48: (Highest gain - 48dB)
'   Any other value polls the chip and returns the current setting
    readReg (core#LNA, 1, @tmp)
    case dB := lookdown(dB: LNA_AGC, LNA_HIGH, -6, -12, -24, -36, -48)
        1..7:
            dB := dB-1 & core#LNAGAINSEL
        OTHER:'XXX Should this read the LNACURRENTGAIN field instead?
            result := tmp & core#LNAGAINSEL_BITS
            return lookupz(result: LNA_AGC, LNA_HIGH, -6, -12, -24, -36, -48)

    tmp &= core#LNAGAINSEL
    tmp := (tmp | dB) & core#LNA_MASK
    writeReg (core#LNA, 1, @tmp)

PUB LNAZInput(ohms) | tmp
' Set LNA's input impedance, in ohms
'   Valid values:
'       50, *200
'   Any other value polls the chip and returns the current setting
    readReg (core#LNA, 1, @tmp)
    case ohms := lookdown(ohms: 50, 200)
        1, 2:
            ohms := (ohms-1) << core#LNAZIN
        OTHER:
            result := (tmp >> core#LNAZIN) & %1
            return lookupz(result: 50, 200)

    tmp &= core#LNAZIN_MASK
    tmp := (tmp | ohms) & core#LNA_MASK
    writeReg (core#LNA, 1, @tmp)


PUB LowBattLevel(mV) | tmp
' Set low battery threshold, in millivolts
'   Valid values:
'       1695, 1764, *1835, 1905, 1976, 2045, 2116, 2185
'   Any other value polls the chip and returns the current setting
    readReg (core#LOWBAT, 1, @tmp)
    case mV := lookdown(mV: 1695, 1764, 1835, 1905, 1976, 2045, 2116, 2185)
        1..8:
            mV := (mV-1) & core#LOWBATTRIM
        OTHER:
            result := tmp & core#LOWBATTRIM_BITS
            return lookupz(result: 1695, 1764, 1835, 1905, 1976, 2045, 2116, 2185)

    tmp &= core#LOWBATTRIM_MASK
    tmp := (tmp | mV) & core#LOWBAT_MASK
    writeReg (core#LOWBAT, 1, @tmp)

PUB LowBattMon(enabled) | tmp
' Enable low battery detector signal
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
    readReg (core#LOWBAT, 1, @tmp)
    case ||enabled
        0, 1:
            enabled := (||enabled) << core#LOWBATON
        OTHER:
            result := ((tmp >> core#LOWBATON) & %1) * TRUE
            return result

    tmp &= core#LOWBATON_MASK
    tmp := (tmp | enabled) & core#LOWBAT_MASK
    writeReg (core#LOWBAT, 1, @tmp)

PUB ManchesterEnc(enabled) | tmp
' Enable Manchester encoding/decoding
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
'   NOTE: This setting and DataWhitening are mutually exclusive; enabling this will disable DataWhitening
    tmp := $00
    readReg(core#PKTCFG1, 1, @tmp)
    case ||enabled
        0:
        1:
            enabled := DCFREE_MANCH << core#DCFREE
        OTHER:
            result := ((tmp >> core#DCFREE) & core#DCFREE_BITS)
            return (result == DCFREE_MANCH)

    tmp &= core#DCFREE_MASK
    tmp := (tmp | enabled) & core#PKTCFG1_MASK
    writeReg(core#PKTCFG1, 1, @tmp)

PUB Modulation(type) | tmp
' Set modulation type
'   Valid values:
'       MOD_FSK (0): Frequency Shift Keyed
'       MOD_OOK (1): On-Off Keyed
'   Any other value polls the chip and returns the current setting
    readReg (core#DATAMOD, 1, @tmp)
    case type
        MOD_FSK, MOD_OOK:
            type := type << core#MODTYPE
        OTHER:
            result := (tmp >> core#MODTYPE) & core#MODTYPE_BITS
            return result

    tmp &= core#MODTYPE_MASK
    tmp := (tmp | type) & core#DATAMOD_MASK
    writeReg (core#DATAMOD, 1, @tmp)

PUB NodeAddress(addr) | tmp
' Set node address
'   Valid values: $00..$FF
'   Any other value polls the chip and returns the current setting
    tmp := $00
    readReg (core#NODEADRS, 1, @tmp)'XXX MOVE TO GET CASE
    case addr
        $00..$FF:
        OTHER:
            return tmp

    writeReg (core#NODEADRS, 1, @addr)'XXX MOVE TO SET CASE

PUB OCPCurrent(mA) | tmp
' Set PA overcurrent protection level, in milliamps
'   Valid values:
'       45..120 (Default: 95)
'   NOTE: Set value will be rounded to the nearest 5mA
'   Any other value polls the chip and returns the current setting
    readReg (core#OCP, 1, @tmp)
    case mA
        45..120:
            mA := (mA-45)/5 & core#OCPTRIM
        OTHER:
            result := 45 + 5 * (tmp & core#OCPTRIM_BITS)
            return result

    tmp &= core#OCPTRIM_MASK
    tmp := (tmp | mA) & core#OCP_MASK
    writeReg (core#OCP, 1, @tmp)

PUB OpMode(mode) | tmp
' Set operating mode
'   Valid values:
'       OPMODE_SLEEP (0): Sleep mode
'       OPMODE_STDBY (1): Standby mode
'       OPMODE_FS (2): Frequency Synthesizer mode
'       OPMODE_TX (3): Transmitter mode
'       OPMODE_RX (4): Receiver mode
'   Any other value polls the chip and returns the current setting
    readReg (core#OPMODE, 1, @tmp)
    case mode
        %000..%100:
            mode := mode << core#MODE
        OTHER:
            return (tmp >> core#MODE) & core#MODE_BITS

    tmp &= core#MODE_MASK
    tmp := (tmp | mode) & core#OPMODE_MASK
    writeReg (core#OPMODE, 1, @tmp)

PUB OvercurrentProtection(enabled) | tmp
' Enable PA overcurrent protection
'   Valid values: *TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
    readReg (core#OCP, 1, @tmp)
    case ||enabled
        0, 1:
            enabled := (||enabled) << core#OCPON
        OTHER:
            result := ((tmp >> core#OCPON) & %1) * TRUE
            return result

    tmp &= core#OCPON_MASK
    tmp := (tmp | enabled) & core#OCP_MASK
    writeReg (core#OCP, 1, @tmp)

PUB PayloadLen(length) | tmp
' Set payload/packet length, in bytes
'   Behavior differs depending on setting of PacketFormat:
'       If PacketFormat == PKTLEN_FIXED, this sets payload length
'       If PacketFormat == PKTLEN_VAR, this sets max length in RX, and is ignored in TX
'   Valid values: 0..255
'   Any other value polls the chip and returns the current setting
    tmp := $00
    readReg (core#PAYLOADLENGTH, 1, @tmp)'XXX MOVE TO GET CASE
    case length
        0..255:
        OTHER:
            return tmp

    writeReg (core#PAYLOADLENGTH, 1, @length)'XXX MOVE TO SET CASE

PUB PayloadLenCfg(mode) | tmp
' Set payload/packet length, in bytes
'   Behavior differs depending on setting of PacketFormat:
'       If PacketFormat == PKTLEN_FIXED, this sets payload length
'       If PacketFormat == PKTLEN_VAR, this sets max length in RX, and is ignored in TX
'   Valid values: 0..255
'   Any other value polls the chip and returns the current setting
    tmp := $00
    readReg (core#PKTCFG1, 1, @tmp)
    case mode
        PKTLEN_FIXED, PKTLEN_VAR:
            mode <<= core#PKTFORMAT
        OTHER:
            result := (tmp >> core#PKTFORMAT) & %1
            return

    tmp &= core#PKTFORMAT
    tmp := (tmp | mode) & core#PKTCFG1_MASK
    writeReg (core#PKTCFG1, 1, @tmp)

PUB PayloadSent
' Packet sent status
'   Returns: TRUE if packet sent, FALSE otherwise
'   NOTE: Once set, this flag clears when exiting TX mode
    result := $00
    readReg (core#IRQFLAGS2, 1, @result)
    result := ((result >> core#PKTSENT) & %1) * TRUE

PUB PreambleLen(bytes) | tmp
' Set number of bytes in preamble
'   Valid values: 0..65535
'   Any other value polls the chip and returns the current setting
    tmp := $00
    readReg(core#PREAMBLEMSB, 2, @tmp)'XXX MOVE TO GET CASE
    case bytes
        0..65535:
        OTHER:
            return tmp

    writeReg(core#PREAMBLEMSB, 2, @bytes)'XXX MOVE TO SET CASE

PUB RampTime(uSec) | tmp
' Set rise/fall time of ramp up/down in FSK, in microseconds
'   Valid values:
'       3400, 2000, 1000, 500, 250, 125, 100, 62, 50, 40, 31, 25, 20, 15, 12, 10
'   Any other value polls the chip and returns the current setting
    readReg (core#PARAMP, 1, @tmp)'XXX MOVE TO GET CASE
    case uSec := lookdown(uSec: 3400, 2000, 1000, 500, 250, 125, 100, 62, 50, 40, 31, 25, 20, 15, 12, 10)
        1..16:
            uSec := (uSec-1) & core#PARAMP
        OTHER:
            result := tmp & core#PA_RAMP_BITS
            return lookupz(result: 3400, 2000, 1000, 500, 250, 125, 100, 62, 50, 40, 31, 25, 20, 15, 12, 10)

    tmp := uSec & core#PARAMP_MASK'XXX MOVE TO SET CASE
    writeReg (core#PARAMP, 1, @tmp)

PUB RCOscCal(enabled) | tmp
' Trigger calibration of RC oscillator
'   Valid values:
'       TRUE (-1 or 1)
'   Any other value polls the chip and returns the current calibration status
'   Returns:
'       FALSE: RC calibration in progress
'       TRUE: RC calibration complete
    readReg (core#OSC1, 1, @tmp)
    case ||enabled
        1:
            enabled := (||enabled) << core#RCCALSTART
        OTHER:
            result := ((tmp >> core#RCCALDONE) & %1) * TRUE
            return result

    tmp := (tmp | enabled) & core#OSC1_MASK
    writeReg (core#OSC1, 1, @tmp)

PUB RSSI | tmp
' Received Signal Strength Indicator
'   Returns: Signal strength seen by transceiver, in dBm
    tmp := %1
    writeReg(core#RSSICFG, 1, @tmp)
    repeat
        readReg(core#RSSICFG, 1, @tmp)
    until tmp & %10'XXX MAKE THIS LOOK LESS MAGIC

    readReg(core#RSSIVALUE, 1, @result)
    result := ~result
    result >>= 1

PUB RXBandwidth(Hz) | tmp, tmp_m, tmp_e
' Set receiver channel filter bandwidth, in Hz
'   Valid values: 2600, 3100, 3900, 5200, 6300, 7800, 10400, 12500, 15600, 20800, 25000, 31300, 41700, 50000, 62500, 83300, 100000, 125000, 166700, 200000, 250000, 333300, 400000, 500000
'   Any other value polls the chip and returns the current setting
    tmp := $00
    readReg(core#RXBW, 1, @tmp)
    case Hz
        2_600..500_000:
            tmp_e := tmp_m := lookdownz(Hz: 500000, 400000, 333300, 250000, 200000, 166700, 125000, 100000, 83300, 62500, 50000, 41700, 31300, 25000, 20800, 15600, 12500, 10400, 7800, 6300, 5200, 3900, 3100, 2600)
            tmp_m := lookupz(tmp_m: %00, %01, %10, %00, %01, %10, %00, %01, %10, %00, %01, %10, %00, %01, %10, %00, %01, %10, %00, %01, %10, %00, %01, %10) << core#RXBWMANT
            tmp_e := lookupz(tmp_e: 00, 00, 00, 01, 01, 01, 02, 02, 02, 03, 03, 03, 04, 04, 04, 05, 05, 05, 06, 06, 06, 07, 07, 07)
            Hz := tmp_m | tmp_e
        OTHER:
            tmp.byte[3] := tmp.byte[0] & core#RXBWEXP
            tmp.byte[2] := lookupz( (tmp.byte[0] >> core#RXBWMANT) & core#RXBWMANT_BITS: 16, 20, 24)' XXX BREAK APART
            result := FXOSC / ( tmp.byte[2] * (1 << (tmp.byte[3] + 2)) )
            return

    tmp &= core#RXBW_MASK
    tmp := (tmp | Hz) & core#RXBW_MASK
    writeReg(core#RXBW, 1, @tmp)

PUB RXPayload(nr_bytes, buff_addr)
' Read data queued in the RX FIFO
'   nr_bytes Valid values: 1..66
'   Any other value is ignored
'   NOTE: Ensure buffer at address buff_addr is at least as big as the number of bytes you're reading
    readReg(core#FIFO, nr_bytes, buff_addr)

PUB RXMode
' Change chip state to RX (receive)
    OpMode (OPMODE_RX)

PUB SensitivityBoost | tmp

    tmp := $2D'XXX MAKE THIS LOOK LESS MAGIC
    writeReg(core#TESTLNA, 1, @tmp)

PUB Sequencer(mode) | tmp
' Control automatic sequencer
'   Valid values:
'       *OPMODE_AUTO (0): Automatic sequence, as selected by OperatingMode
'        OPMODE_MANUAL (1): Mode is forced
'   Any other value polls the chip and returns the current setting
    readReg (core#OPMODE, 1, @tmp)
    case mode
        OPMODE_AUTO, OPMODE_MANUAL:
            mode := mode << core#SEQOFF
        OTHER:
            result := (tmp >> core#SEQOFF) & %1
            return result

    tmp &= core#SEQOFF_MASK
    tmp := (tmp | mode) & core#OPMODE_MASK
    writeReg (core#OPMODE, 1, @tmp)

PUB Sleep
' Power down chip
    OpMode(OPMODE_SLEEP)

PUB SyncMode(param)
' dummy method

PUB SyncWord(rw, buff_addr)'XXX SEE IF THIS CAN BE MADE API-COMPLIANT (1 PARAM)
' Set sync word to value at buff_addr
'   Valid values:
'       rw: SW_READ (0), SW_WRITE (1)
'       variable at address buff_addr: All bytes can be $01..$FF
'   For rw, any value other than SW_WRITE (1) polls the chip and returns the current setting
'   NOTE: Variable pointed to by buff_addr must be at least 8 bytes in length
    case rw
        SW_WRITE:
            writeReg(core#SYNCVALUE1, 8, buff_addr)
        OTHER:
            readReg(core#SYNCVALUE1, 8, buff_addr)  'XXX Future test: set nr_bytes arg to SyncWordBytes(-2)?

PUB SyncWordEnabled(enable) | tmp
' Enable sync word generation (TX) and detection (RX)
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
    tmp := $00
    readReg(core#SYNCCFG, 1, @tmp)
    case ||enable
        0, 1:
            enable := ||enable << core#SYNCON
        OTHER:
            return ((tmp >> core#SYNCON) & %1) * TRUE

    tmp &= core#SYNCON_MASK
    tmp := (tmp | enable) & core#SYNCCFG_MASK
    writeReg(core#SYNCCFG, 1, @tmp)

PUB SyncWordLength(bytes) | tmp
' Set number of bytes in sync word
'   Valid values: 1..8
'   Any other value polls the chip and returns the current setting
    tmp := $00
    readReg(core#SYNCCFG, 1, @tmp)
    case bytes
        1..8:
            bytes := (bytes-1) << core#SYNCSIZE
        OTHER:
            return ((tmp >> core#SYNCSIZE) & core#SYNCSIZE) + 1

    tmp &= core#SYNCSIZE_MASK
    tmp := (tmp | bytes) & core#SYNCCFG_MASK
    writeReg(core#SYNCCFG, 1, @tmp)

PUB SyncWordMaxBitErr(bits) | tmp
' Set maximum number of tolerated bit errors in sync word
'   Valid values: 0..7
'   Any other value polls the chip and returns the current setting
    tmp := $00
    readReg(core#SYNCCFG, 1, @tmp)
    case bits
        0..7:
        OTHER:
            return (tmp & core#SYNCTOL)

    tmp &= core#SYNCTOL_MASK
    tmp := (tmp | bits) & core#SYNCCFG_MASK
    writeReg(core#SYNCCFG, 1, @tmp)

PUB Temperature | tmp
' Read temperature
'   Returns: Degrees C
    tmp := (1 << core#TEMPMEASSTART)    ' Trigger a temperature measurement
    writeReg(core#TEMP1, 1, @tmp)
    tmp := $00
    repeat                                  ' Wait until the measurement is complete
        readReg(core#TEMP1, 1, @tmp)
    while ((tmp >> core#TEMPMEASRUN) & %1)

    result := $00
    readReg(core#TEMP2, 1, @result)
    if result & $80'XXX USE SPIN SIGN EXT
        return 256-result
    else
        return result

PUB TXMode
' Change chip state to transmit
    OpMode(OPMODE_TX)

PUB TXPayload(nr_bytes, buff_addr)
' Queue data to transmit in the TX FIFO
'   nr_bytes Valid values: 1..66
'   Any other value is ignored
    writeReg(core#FIFO, nr_bytes, buff_addr)

PUB TXPower(dBm) | tmp
' Set transmit output power, in dBm
'   Valid values:
'       -18..17
'   Any other value polls the chip and returns the current setting
    tmp := 0
    readReg (core#PALVL, 1, @tmp.byte[0])
    case dBm
        -18..13:
            dBm := (dBm + 18) & core#OUTPWR
            tmp &= core#OUTPWR_MASK                                ' Zero out the existing power level setting
            tmp &= core#PA0ON_MASK                                      '   and all of the PAx bits
            tmp := tmp & core#PA1ON_MASK & core#PA2ON_MASK              '
            tmp := tmp | (1 << core#PA0ON)                          ' Turn on only the PA0 bit
            tmp.byte[1] := core#PA1_NORMAL                              ' Turn off the PA_BOOST circuit
            tmp.byte[2] := core#PA2_NORMAL
        14..17:
            dBm := (dBm + 14) & core#OUTPWR_MASK
            tmp &= core#OUTPWR_MASK
            tmp &= core#PA0ON_MASK
            tmp := tmp & core#PA1ON_MASK & core#PA2ON_MASK
            tmp := tmp | (1 << core#PA1ON) | (1 << core#PA2ON)
            tmp.byte[1] := core#PA1_NORMAL                              ' Turn off the PA_BOOST circuit
            tmp.byte[2] := core#PA2_NORMAL
        18..20:
            dBm := (dBm + 11) & core#OUTPWR_MASK
            tmp &= core#OUTPWR_MASK
            tmp &= core#PA0ON_MASK
            tmp := tmp & core#PA1ON_MASK & core#PA2ON_MASK
            tmp := tmp | (1 << core#PA1ON) | (1 << core#PA2ON)  ' Turn on the PA1 and 2 bits
            tmp.byte[1] := core#PA1_BOOST                               '   and the PA_BOOST circuit
            tmp.byte[2] := core#PA2_BOOST
        OTHER:
            result := tmp & core#OUTPWR_BITS                       ' Determine offset to calculate current
            case (tmp >> core#PA2ON) & core#PA012_BITS              ' TXPower by checking which PAx bits are set
                %100:                                                   ' Only PA0 is set
                    result -= 18
                %011, %010:                                             ' PA1 and possibly PA2 are set
                    readReg(core#TESTPA1, 1, @tmp.byte[1])
                    readReg(core#TESTPA2, 1, @tmp.byte[2])
                    if tmp.byte[1] == core#PA1_BOOST and tmp.byte[2] == core#PA2_BOOST
                        result -= 11                                    ' PA_BOOST is active
                    else
                        result -= 14                                    ' PA_BOOST is inactive
            return result

    tmp := (tmp | dBm) & core#PALVL_MASK
    writeReg (core#PALVL, 1, @tmp.byte[0])
    writeReg (core#TESTPA1, 1, @tmp.byte[1])
    writeReg (core#TESTPA2, 1, @tmp.byte[2])

PUB TXStartCondition(when) | tmp
' Define when to begin packet transmission
'   Valid values:
'       TXSTART_FIFOLVL (0): If the number of bytes in the FIFO exceeds FIFOThreshold
'       TXSTART_FIFONOTEMPTY (1): If there's at least one byte in the FIFO
'   Any other value polls the chip and returns the current setting
    tmp := $00
    readReg(core#FIFOTHRESH, 1, @tmp)
    case when
        TXSTART_FIFOLVL, TXSTART_FIFONOTEMPTY:
            when <<= core#TXSTARTCOND
        OTHER:
            result := (tmp >> core#TXSTARTCOND) & %1'XXX RETURN

    tmp &= core#TXSTARTCOND_MASK
    tmp := (tmp | when) & core#FIFOTHRESH_MASK
    writeReg(core#FIFOTHRESH, 1, @tmp)

PUB WaitRX | tmp
' Force the receiver in wait mode (continuous RX)
    tmp := $00
    readReg(core#PKTCFG2, 1, @tmp)

    tmp &= core#RSTARTRX_MASK
    tmp := (tmp | (1 << core#RSTARTRX)) & core#PKTCFG2_MASK
    writeReg(core#PKTCFG2, 1, @tmp)

PRI readReg(reg, nr_bytes, buff_addr) | tmp
' Read nr_bytes from register 'reg' to address 'buff_addr'
    case reg
        $00..$13, $18..$4F, $58..59, $5F, $6F, $71:
            io.Low(_CS)
            spi.SHIFTOUT(_MOSI, _SCK, core#MOSI_BITORDER, 8, reg)
            repeat tmp from nr_bytes-1 to 0
                byte[buff_addr][tmp] := spi.SHIFTIN(_MISO, _SCK, core#MISO_BITORDER, 8)
            io.High(_CS)

        OTHER:
            return FALSE

PRI writeReg(reg, nr_bytes, buff_addr) | tmp
' Write nr_bytes to register 'reg' stored in val
    case reg
        $00..$13, $18..$4F, $58..59, $5F, $6F, $71:
            io.Low(_CS)
            spi.SHIFTOUT(_MOSI, _SCK, core#MOSI_BITORDER, 8, reg|core#W)
            repeat tmp from nr_bytes-1 to 0
                spi.SHIFTOUT(_MOSI, _SCK, core#MOSI_BITORDER, 8, byte[buff_addr][tmp])
            io.High(_CS)

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
