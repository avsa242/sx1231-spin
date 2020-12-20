{
    --------------------------------------------
    Filename: wireless.transceiver.sx1231.spi.spin
    Author: Jesse Burt
    Description: Driver for the Semtech SX1231 UHF Transceiver IC
    Copyright (c) 2020
    Started Apr 19, 2019
    Updated Dec 19, 2020
    See end of file for terms of use.
    --------------------------------------------
}

CON

' SX1231 Oscillator Frequency, and frequency step size
    FXOSC                   = 32_000_000
    FSTEP                   = 61_035            ' (FXOSC * 1_000) / (1 << 19)

' Sequencer operating modes
    OPMODE_AUTO             = 0
    OPMODE_MANUAL           = 1

    OPMODE_SLEEP            = 0
    OPMODE_STDBY            = 1
    OPMODE_FS               = 2
    OPMODE_TX               = 3
    OPMODE_RX               = 4

' Data processing modes
    DATAMODE_PKT            = 0
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

' Sensitivity modes
    SENS_NORM               = $1b
    SENS_HI                 = $2d

' Interrupts
    OPMODE_RDY              = 1 << 15
    RXREADY                 = 1 << 14
    TXREADY                 = 1 << 13
    PLL_LOCKED              = 1 << 12
    RSSI_THR                = 1 << 11
    TIMEOUT                 = 1 << 10
    INTERM_MODE             = 1 << 9
    SYNC_ADDR_MATCH         = 1 << 8
    FIFO_FULL               = 1 << 7
    FIFO_NOTEMPTY           = 1 << 6
    FIFO_THR                = 1 << 5
    FIFO_OVER               = 1 << 4
    PAYLD_SENT              = 1 << 3
    PAYLD_RDY               = 1 << 2
    PAYLD_CRCOK             = 1 << 1
    BATT_LOW                = 1

' Clock output modes
    CLKOUT_RC               = 6
    CLKOUT_OFF              = 7

VAR

    long _CS, _SCK, _MOSI, _MISO

OBJ

    spi : "com.spi.4w"
    core: "core.con.sx1231"
    time: "time"
    io  : "io"
    u64 : "math.unsigned64"

PUB Null{}
' This is not a top-level object

PUB Startx(CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN): okay

    if lookdown(CS_PIN: 0..31) and lookdown(SCK_PIN: 0..31) and {
}   lookdown(MOSI_PIN: 0..31) and lookdown(MISO_PIN: 0..31)
        if okay := spi.start(core#CLK_DLY, core#CPOL)
            longmove(@_CS, @CS_PIN, 4)
            io.high(_CS)
            io.output(_CS)

            time.msleep (10)

            if lookdown(deviceid{}: $21, $22, $23, $24)
                return okay

    return FALSE                                ' something above failed

PUB Stop{}

    spi.stop{}

PUB Defaults{} | tmp[4]
' Factory defaults
    addresscheck(ADDRCHK_NONE)
    afcauto(FALSE)
    afcmethod(AFC_STANDARD)
    autorestartrx(TRUE)
    broadcastaddress($00)
    carrierfreq(915_000_000)
    crccheckenabled(TRUE)
    datamode(DATAMODE_PKT)
    datarate(4800)
    datawhitening(FALSE)
    encryption(FALSE)
    bytefill(@tmp, $00, 16)
    encryptionkey(KEY_WR, @tmp)
    entercondition(ENTCOND_NONE)
    exitcondition(EXITCOND_NONE)
    fifothreshold(15)
    freqdeviation(5000)
    gaussianfilter(BT_NONE)
    intermediatemode(IMODE_SLEEP)
    listen(FALSE)
    lnagain(LNA_AGC)
    lnazinput(200)
    lowbattlevel(1_835)
    lowbattmon(FALSE)
    manchesterenc(FALSE)
    modulation(MOD_FSK)
    nodeaddress($00)
    ocpcurrent(95)
    opmode(OPMODE_STDBY)
    overcurrentprotection(TRUE)
    payloadlen(64)
    payloadlencfg(PKTLEN_FIXED)
    preamblelen(3)
    ramptime(40)
    rxbandwidth(10_400)
    sequencer(OPMODE_AUTO)
    bytefill(@tmp, $01, 8)
    syncword(SW_WRITE, @tmp)
    syncwordenabled(TRUE)
    syncwordlength(4)
    syncwordmaxbiterr(0)
    txpower(13)
    txstartcondition(TXSTART_FIFONOTEMPTY)

PUB AbortListen{} | tmp
' Abort listen mode when used together with Listen(FALSE)
    readreg(core#OPMODE, 1, @tmp)
    tmp &= core#LISTENABT_MASK
    tmp := (tmp | (1 << core#LISTENABT)) & core#OPMODE_MASK
    writereg(core#OPMODE, 1, @tmp)

PUB AddressCheck(mode): curr_mode
' Enable address checking/matching/filtering
'   Valid values:
'       ADDRCHK_NONE (%00): No address check
'       ADDRCHK_CHK_NO_BCAST (%01): Check address, but ignore broadcast addresses
'       ADDRCHK_CHK_00_BCAST (%10): Check address, and also respond to broadcast address
'   Any other value polls the chip and returns the current setting
    curr_mode := 0
    readreg(core#PKTCFG1, 1, @curr_mode)
    case mode
        ADDRCHK_NONE, ADDRCHK_CHK_NO_BCAST, ADDRCHK_CHK_BCAST:
            mode <<= core#ADDRFILT
        other:
            return ((curr_mode >> core#ADDRFILT) & core#ADDRFILT_BITS)

    mode := ((curr_mode & core#ADDRFILT_MASK) | mode) & core#PKTCFG1_MASK
    writereg(core#PKTCFG1, 1, @mode)

PUB AFCAuto(state): curr_state
' Enable automatic AFC
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
    curr_state := 0
    readreg(core#AFCFEI, 1, @curr_state)
    case ||(state)
        0, 1:
            state := ||(state) << core#AFCAUTOON
        other:
            return ((curr_state >> core#AFCAUTOON) & 1) == 1

    state := ((curr_state & core#AFCAUTOON_MASK) | state) & core#AFCFEI_MASK
    writereg(core#AFCFEI, 1, @state)

PUB AFCComplete{}: flag
' Flag indicating AFC (auto or manual) completed
'   Returns: TRUE (-1) if complete, FALSE (0) otherwise
    readreg(core#AFCFEI, 1, @flag)
    return ((flag >> core#AFCDONE) & 1) == 1

PUB AFCMethod(mode): curr_mode
' Set AFC mode/routine
'   Valid values:
'       AFC_STANDARD (0): Standard AFC routine
'       AFC_IMPROVED (1): Improved AFC routine, for signals with modulation index < 2
'   Any other value polls the chip and returns the current setting
    readreg(core#AFCCTRL, 1, @curr_mode)
    case mode
        AFC_STANDARD, AFC_IMPROVED:
            mode := mode << core#AFCLOWBETAON
        other:
            return (curr_mode >> core#AFCLOWBETAON) & 1

    mode := ((curr_mode & core#AFCLOWBETAON_MASK) | mode) & CORE#AFCCTRL_MASK
    writereg(core#AFCCTRL, 1, @mode)

PUB AFCOffset{}: offs
' Read AFC frequency offset
'   Returns: Frequency offset in Hz
    offs := 0
    readreg(core#AFCMSB, 2, @offs)
    return (~~offs) * FSTEP

PUB AFCStart{} | tmp
' Trigger a manual AFC
    readreg(core#AFCFEI, 1, @tmp)
    tmp |= %1   '1 << core#AFCSTART
    writereg(core#AFCFEI, 1, @tmp)

PUB AfterRX(next_state): curr_state
' Defines the state the radio transitions to after a packet is successfully received
    curr_state := intermediatemode(next_state)

PUB AfterTX(next_state): curr_state
' Defines the state the radio transitions to after a packet is successfully transmitted
    curr_state := intermediatemode(next_state)

PUB AGCFilterLength(param)
' dummy method

PUB AGCMode(param)
' dummy method

PUB AppendStatus(param)
' dummy method

PUB AutoCal(param)
' dummy method

PUB AutoRestartRX(state): curr_state
' Enable automatic RX restart (RSSI phase)
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
'   NOTE: Restart occurs after payload is ready and the packet has been read from the FIFO
    curr_state := 0
    readreg(core#PKTCFG2, 1, @curr_state)
    case ||(state)
        0, 1:
            state := ||(state) << core#AUTORSTARTRXON
        other:
            return ((curr_state >> core#AUTORSTARTRXON) & 1) == 1

    state := ((curr_state & core#AUTORSTARTRXON_MASK) | state) & core#PKTCFG2_MASK
    writereg(core#PKTCFG2, 1, @state)

PUB BattLow{}: flag
' Flag indicating battery voltage low
'   Returns TRUE if battery low, FALSE otherwise
    readreg(core#LOWBAT, 1, @flag)
    return ((flag >> core#LOWBATMON) & 1) == 1

PUB BroadcastAddress(addr): curr_addr
' Set broadcast address
'   Valid values: $00..$FF
'   Any other value polls the chip and returns the current setting
    case addr
        $00..$FF:
            writereg(core#BCASTADRS, 1, @addr)
        other:
            curr_addr := 0
            readreg(core#BCASTADRS, 1, @curr_addr)
            return

PUB CarrierFreq(freq): curr_freq
' Set Carrier frequency, in Hz
'   Valid values:
'       290_000_000..340_000_000, 424_000_000..510_000_000, 862_000_000..1_020_000_000
'   Any other value polls the chip and returns the current setting
'   NOTE: Set value will be rounded
    case freq
        290_000_000..340_000_000, 424_000_000..510_000_000, 862_000_000..1_020_000_000:
            freq := u64.multdiv(freq, 1_000, FSTEP)
            writereg(core#FRFMSB, 3, @freq)
        other:
            readreg(core#FRFMSB, 3, @curr_freq)
            return u64.multdiv(curr_freq, FSTEP, 1_000)

PUB CarrierSense(param)
' dummy method

PUB Channel(param)
' dummy method

PUB ClkOut(divisor): curr_div
' Set clkout frequency, as a divisor of FXOSC
'   Valid values:
'       1, 2, 4, 8, 16, 32, CLKOUT_RC (6), CLKOUT_OFF (7)
'   Any other value polls the chip and returns the current setting
'   NOTE: For optimal efficiency, it is recommended to disable the
        clock output (CLKOUT_OFF) unless needed
    curr_div := 0
    readreg(core#DIOMAPPING2, 1, @curr_div)
    case divisor
        1, 2, 4, 8, 16, 32, CLKOUT_RC, CLKOUT_OFF:
            divisor := lookdownz(divisor: 1, 2, 4, 8, 16, 32, CLKOUT_RC, CLKOUT_OFF)
        other:
            curr_div &= core#CLKOUT_BITS
            return lookupz(curr_div: 1, 2, 4, 8, 16, 32, CLKOUT_RC, CLKOUT_OFF)

    divisor := ((curr_div & core#CLKOUT_MASK) | divisor) & core#DIOMAPPING2_MASK
    writereg(core#DIOMAPPING2, 1, @divisor)

PUB CRCCheckEnabled(state): curr_state
' Enable CRC calculation (TX) and checking (RX)
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
    curr_state := 0
    readreg(core#PKTCFG1, 1, @curr_state)
    case ||(state)
        0, 1:
            state := ||(state) << core#CRCON
        other:
            return ((curr_state >> core#CRCON) & 1) == 1

    state := ((curr_state & core#CRCON_MASK) | state) & core#PKTCFG1_MASK
    writereg(core#PKTCFG1, 1, @state)

PUB CRCLength(param)
' dummy method

PUB DataMode(mode): curr_mode
' Set data processing mode
'   Valid values:
'       DATAMODE_PKT (0): Packet mode
'       DATAMODE_CONT_W_SYNC (2): Continuous mode with bit synchronizer
'       DATAMODE_CONT_WO_SYNC (3): Continuous mode without bit synchronizer
'   Any other value polls the chip and returns the current setting
    readreg(core#DATAMOD, 1, @curr_mode)
    case mode
        DATAMODE_PKT, DATAMODE_CONT_W_SYNC, DATAMODE_CONT_WO_SYNC:
            mode := mode << core#DATAMODE
        other:
            return (curr_mode >> core#DATAMODE) & core#DATAMODE_BITS

    mode := ((curr_mode & core#DATAMODE_MASK) | mode) & core#DATAMOD_MASK
    writereg(core#DATAMOD, 1, @mode)

PUB DataRate(rate): curr_rate
' Set on-air data rate, in bits per second
'   Valid values:
'       1_200..300_000
'   Any other value polls the chip and returns the current setting
'   NOTE: Result will be rounded
'   NOTE: Effective data rate will be halved if Manchester encoding is used
    case rate
        1_200..300_000:
            rate := (FXOSC / rate) & core#BITRATE_MASK
            writereg(core#BITRATEMSB, 2, @rate)
        other:
            readreg(core#BITRATEMSB, 2, @curr_rate)
            return FXOSC / curr_rate

PUB DataWhitening(state): curr_state
' Enable data whitening
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
'   NOTE: This setting and ManchesterEnc() are mutually exclusive;
'       enabling this will disable ManchesterEnc()
    curr_state := 0
    readreg(core#PKTCFG1, 1, @curr_state)
    case ||(state)
        0:
        1:
            state := DCFREE_WHITE << core#DCFREE
        other:
            curr_state := ((curr_state >> core#DCFREE) & core#DCFREE_BITS)
            return (curr_state == DCFREE_WHITE)

    state := ((curr_state & core#DCFREE_MASK) | state) & core#PKTCFG1_MASK
    writereg(core#PKTCFG1, 1, @curr_state)

PUB DCBlock(param)
' dummy method

PUB DeviceID{}: id
' Read device ID
'   Returns:
'       Value   Chip version
'       $21:    V2a
'       $22:    V2b
'       $23:    V2c
'       $24:    ???
    readreg(core#VERSION, 1, @id)

PUB DVGAGain(param)
' dummy method

PUB Encryption(state): curr_state
' Enable AES encryption/decryption
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
'   NOTE: Encryption is limited to payloads of a maximum of 66 bytes
    curr_state := 0
    readreg(core#PKTCFG2, 1, @curr_state)
    case ||(state)
        0, 1:
            state := ||(state) & 1
        other:
            return (curr_state & 1) == 1

    state := ((curr_state & core#AESON_MASK) | state) & core#PKTCFG2_MASK
    writereg(core#PKTCFG2, 1, @state)

PUB EncryptionKey(rw, ptr_buff) | tmp
' Set AES 128-bit encryption key
'   Valid values:
'       rw: KEY_RD (0), KEY_WR (1)
'       ptr_buff: All bytes at address may be $00..$FF
'   NOTE: Variable at ptr_buff must be at least 16 bytes
'           1st byte of key is MSB
    case rw
        KEY_WR:
            writereg(core#AESKEY1, 16, ptr_buff)
        other:
            readreg(core#AESKEY1, 16, ptr_buff)

PUB EnterCondition(cond): curr_cond
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
    curr_cond := 0
    readreg(core#AUTOMODES, 1, @curr_cond)
    case cond
        ENTCOND_NONE, ENTCOND_FIFONOTEMPTY, ENTCOND_FIFOLVL, ENTCOND_CRCOK, ENTCOND_PAYLDRDY, ENTCOND_SYNCADD, ENTCOND_PKTSENT, ENTCOND_FIFOEMPTY:
            cond <<= core#ENTCOND
        other:
            return (curr_cond >> core#ENTCOND) & core#ENTCOND_BITS

    cond := ((curr_cond & core#ENTCOND_MASK) | cond) & core#AUTOMODES_MASK
    writereg(core#AUTOMODES, 1, @cond)

PUB ExitCondition(cond): curr_cond
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
    curr_cond := 0
    readreg(core#AUTOMODES, 1, @curr_cond)
    case cond
        EXITCOND_NONE, EXITCOND_FIFOEMPTY, EXITCOND_FIFOLVL, EXITCOND_CRCOK,{
}       EXITCOND_PAYLDRDY, EXITCOND_SYNCADD, EXITCOND_PKTSENT,{
}       EXITCOND_TIMEOUT:
            cond <<= core#EXITCOND
        other:
            return (curr_cond >> core#EXITCOND) & core#EXITCOND_BITS

    cond := ((curr_cond & core#EXITCOND_MASK) | cond) & core#AUTOMODES_MASK
    writereg(core#AUTOMODES, 1, @cond)

PUB FEIComplete{}: flag
' Flag indicating FEI measurement complete
'   Returns: TRUE if complete, FALSE otherwise
    flag := 0
    readreg(core#AFCFEI, 1, @flag)
    return ((flag >> core#FEIDONE) & 1) == 1

PUB FEIError{}: ferr
' Frequency error
'   Returns: FEI measurement, in Hz
    ferr := 0
    readreg(core#AFCFEI, 2, @ferr)
    return (~~ferr) * FSTEP

PUB FEIStart{} | tmp
' Trigger a manual FEI measurement
    tmp := 0
    readreg(core#AFCFEI, 1, @tmp)
    tmp := tmp | (1 << core#FEISTART)
    writereg(core#AFCFEI, 1, @tmp)

PUB FIFOEmpty{}: flag
' Flag indicating FIFO empty
'   Returns:
'       TRUE (-1) if FIFO empty
'       FALSE (0) if FIFO contains at least one byte
    flag := 0
    readreg(core#IRQFLAGS2, 1, @flag)
    return (((flag >> core#FIFONOTEMPTY) & 1) ^ 1) == 1

PUB FIFOFull{}: flag
' Flag indicating FIFO full
'   Returns:
'       TRUE (-1) if FIFO full
'       FALSE (0) if there's at least one byte available
    flag := 0
    readreg(core#IRQFLAGS2, 1, @flag)
    return ((flag >> core#FIFOFULL) & 1) == 1

PUB FIFOThreshold(thresh): curr_thr
' Set threshold for triggering FIFO level interrupt
'   Valid values: 0..127
'   Any other value polls the chip and returns the current setting
    curr_thr := 0
    readreg(core#FIFOTHRESH, 1, @curr_thr)
    case thresh
        0..127:
        other:
            return curr_thr & core#FIFOTHRESHOLD_BITS

    thresh := ((curr_thr & core#FIFOTHRESHOLD_MASK) | thresh) & core#FIFOTHRESH_MASK
    writereg(core#FIFOTHRESH, 1, @thresh)

PUB FlushTX{}
' dummy method

PUB FreqDeviation(fdev): curr_fdev
' Set carrier deviation, in Hz
'   Valid values:
'       600..300_000
'       Default is 5_000
'   Any other value polls the chip and returns the current setting
'   NOTE: Set value will be rounded
    case fdev
        600..300_000:
            fdev := u64.multdiv(fdev, 1_000, FSTEP)
            writereg(core#FDEVMSB, 2, @fdev)
        other:
            curr_fdev := 0
            readreg(core#FDEVMSB, 2, @curr_fdev)
            return u64.multdiv(curr_fdev, FSTEP, 1_000)

PUB FSTX{}
' dummy method

PUB GaussianFilter(param): curr_param
' Set Gaussian filter/data shaping parameters
'   Valid values:
'       BT_NONE (0): No shaping
'       BT_1_0 (1): Gaussian filter, BT = 1.0
'       BT_0_5 (2): Gaussian filter, BT = 0.5
'       BT_0_3 (3): Gaussian filter, BT = 0.3
'   Any other value polls the chip and returns the current setting
    readreg(core#DATAMOD, 1, @curr_param)
    case param
        BT_NONE..BT_0_3:
            param := param << core#MODSHP
        other:
            return (curr_param >> core#MODSHP) & core#MODSHP_BITS

    param := ((curr_param & core#MODSHP_MASK) | param) & core#DATAMOD_MASK
    writereg(core#DATAMOD, 1, @param)

PUB Idle{}
' Change chip state to idle (standby)
    opmode(OPMODE_STDBY)

PUB IntermediateMode(mode): curr_mode
' Set intermediate operating mode
'   Valid values:
'       IMODE_SLEEP (%00): Sleep
'       IMODE_STBY (%01): Standby
'       IMODE_RX (%10): Receive
'       IMODE_TX (%11): Transmit
'   Any other value polls the chip and returns the current setting
    curr_mode := 0
    readreg(core#AUTOMODES, 1, @curr_mode)
    case mode
        IMODE_SLEEP, IMODE_STBY, IMODE_RX, IMODE_TX:
            mode &= core#INTMDTMODE
        other:
            return (curr_mode >> core#INTMDTMODE) & core#INTMDTMODE_BITS

    mode := ((curr_mode & core#INTMDTMODE_MASK) | mode) & core#AUTOMODES_MASK
    writereg(core#AUTOMODES, 1, @mode)

PUB Interrupt{}: mask
' Read interrupt state
'   Bits:
'   15  - OpMode ready
'   14  - RX mode only: After RSSI, AGC and AFC
'   13  - TX mode only: after PA ramp up
'   12  - FS, RX, TX OpModes: PLL locked
'   11  - RX mode only: RSSI exceeds level set by RSSIThreshold()
'   10  - Timeout
'   9   - Entered intermediate mode
'   8   - Syncword and address (if enabled) match
'   7   - FIFO is full
'   6   - FIFO isn't empty
'   5   - FIFO level exceeds threshold set by FIFOThreshold()
'   4   - FIFO overrun
'   3   - Payload sent
'   2   - Payload ready
'   1   - RX Payload CRC OK
'   0   - Battery voltage below level set by LowBattLevel()
    readreg(core#IRQFLAGS1, 2, @mask)

PUB IntFreq(param)
' dummy method

PUB Listen(state): curr_state
' Enable listen mode
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
'   NOTE: Should be enable when in standby mode
    readreg(core#OPMODE, 1, @curr_state)
    case ||(state)
        0, 1:
            state := ||(state) << core#LISTENON
        other:
            return ((curr_state >> core#LISTENON) & 1) == 1

    state := ((curr_state & core#LISTENON_MASK) | state) & core#OPMODE_MASK
    writereg(core#OPMODE, 1, @state)

PUB LNAGain(gain): curr_gain
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
    readreg(core#LNA, 1, @curr_gain)
    case gain
        -6, -12, -24, -36, -48:
            gain := lookdownz(gain: LNA_AGC, LNA_HIGH, -6, -12, -24, -36, -48)
        other:'XXX Should this read the LNACURRENTGAIN field instead?
            curr_gain := curr_gain & core#LNAGAINSEL_BITS
            return lookupz(curr_gain: LNA_AGC, LNA_HIGH, -6, -12, -24, -36, -48)

    gain := ((curr_gain & core#LNAGAINSEL_MASK) | gain) & core#LNA_MASK
    writereg(core#LNA, 1, @gain)

PUB LNAZInput(impedance): curr_imp
' Set LNA's input impedance, in ohms
'   Valid values:
'       50, *200
'   Any other value polls the chip and returns the current setting
    readreg(core#LNA, 1, @curr_imp)
    case impedance
        50, 200:
            impedance := lookdownz(impedance: 50, 200) << core#LNAZIN
        other:
            curr_imp := (curr_imp >> core#LNAZIN) & 1
            return lookupz(curr_imp: 50, 200)

    impedance := ((curr_imp & core#LNAZIN_MASK) | impedance) & core#LNA_MASK
    writereg(core#LNA, 1, @impedance)

PUB LowBattLevel(lvl): curr_lvl
' Set low battery threshold, in millivolts
'   Valid values:
'       1695, 1764, *1835, 1905, 1976, 2045, 2116, 2185
'   Any other value polls the chip and returns the current setting
    readreg(core#LOWBAT, 1, @curr_lvl)
    case lvl
        1695, 1764, 1835, 1905, 1976, 2045, 2116, 2185:
            lvl := lookdownz(lvl: 1695, 1764, 1835, 1905, 1976, 2045, 2116, 2185)
        other:
            curr_lvl &= core#LOWBATTRIM_BITS
            return lookupz(curr_lvl: 1695, 1764, 1835, 1905, 1976, 2045, 2116, 2185)

    lvl := ((curr_lvl & core#LOWBATTRIM_MASK) | lvl) & core#LOWBAT_MASK
    writereg(core#LOWBAT, 1, @lvl)

PUB LowBattMon(state): curr_state
' Enable low battery detector signal
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
    readreg(core#LOWBAT, 1, @curr_state)
    case ||(state)
        0, 1:
            state := ||(state) << core#LOWBATON
        other:
            return ((curr_state >> core#LOWBATON) & 1) == 1

    state := ((curr_state & core#LOWBAT_MASK) | state) & core#LOWBAT_MASK
    writereg(core#LOWBAT, 1, @state)

PUB ManchesterEnc(state): curr_state
' Enable Manchester encoding/decoding
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
'   NOTE: This setting and DataWhitening() are mutually exclusive;
'       enabling this will disable DataWhitening()
    curr_state := 0
    readreg(core#PKTCFG1, 1, @curr_state)
    case ||(state)
        0:                                      ' disabled state is just 0, so
        1:                                      '   just leave it as-is
            state := DCFREE_MANCH << core#DCFREE
        other:
            curr_state := ((curr_state >> core#DCFREE) & core#DCFREE_BITS)
            return (curr_state == DCFREE_MANCH)

    state := ((curr_state & core#DCFREE_MASK) | state) & core#PKTCFG1_MASK
    writereg(core#PKTCFG1, 1, @state)

PUB Modulation(mode): curr_mode
' Set modulation mode
'   Valid values:
'       MOD_FSK (0): Frequency Shift Keyed
'       MOD_OOK (1): On-Off Keyed
'   Any other value polls the chip and returns the current setting
    readreg(core#DATAMOD, 1, @curr_mode)
    case mode
        MOD_FSK, MOD_OOK:
            mode <<= core#MODTYPE
        other:
            return (curr_mode >> core#MODTYPE) & core#MODTYPE_BITS

    mode := ((curr_mode & core#MODTYPE_MASK) | mode) & core#DATAMOD_MASK
    writereg(core#DATAMOD, 1, @mode)

PUB NodeAddress(addr): curr_addr
' Set node address
'   Valid values: $00..$FF
'   Any other value polls the chip and returns the current setting
    case addr
        $00..$FF:
            writereg(core#NODEADRS, 1, @addr)
        other:
            curr_addr := 0
            readreg(core#NODEADRS, 1, @curr_addr)
            return

PUB OCPCurrent(lvl): curr_lvl
' Set PA overcurrent protection level, in milliamps
'   Valid values:
'       45..120 (Default: 95)
'   NOTE: Set value will be rounded to the nearest 5mA
'   Any other value polls the chip and returns the current setting
    readreg(core#OCP, 1, @curr_lvl)
    case lvl
        45..120:
            lvl := (lvl-45)/5 & core#OCPTRIM
        other:
            return 45 + 5 * (curr_lvl & core#OCPTRIM_BITS)

    lvl := ((curr_lvl & core#OCPTRIM_MASK) | lvl) & core#OCP_MASK
    writereg(core#OCP, 1, @lvl)

PUB OpMode(mode): curr_mode
' Set operating mode
'   Valid values:
'       OPMODE_SLEEP (0): Sleep mode
'       OPMODE_STDBY (1): Standby mode
'       OPMODE_FS (2): Frequency Synthesizer mode
'       OPMODE_TX (3): Transmitter mode
'       OPMODE_RX (4): Receiver mode
'   Any other value polls the chip and returns the current setting
    readreg(core#OPMODE, 1, @curr_mode)
    case mode
        OPMODE_SLEEP..OPMODE_RX:
            mode <<= core#MODE
        other:
            return (curr_mode >> core#MODE) & core#MODE_BITS

    mode := ((curr_mode & core#MODE_MASK) | mode) & core#OPMODE_MASK
    writereg(core#OPMODE, 1, @mode)

PUB OvercurrentProtection(state): curr_state
' Enable PA overcurrent protection
'   Valid values: *TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
    readreg(core#OCP, 1, @curr_state)
    case ||(state)
        0, 1:
            state := ||(state) << core#OCPON
        other:
            return ((curr_state >> core#OCPON) & 1) == 1

    state := ((curr_state & core#OCPON_MASK) | state) & core#OCP_MASK
    writereg(core#OCP, 1, @state)

PUB PayloadLen(length): curr_len
' Set payload/packet length, in bytes
'   Behavior differs depending on setting of PayloadLenCfg():
'       If PKTLEN_FIXED, this sets payload length
'       If PKTLEN_VAR, this sets max length in RX, and is ignored in TX
'   Valid values: 0..255
'   Any other value polls the chip and returns the current setting
    case length
        0..255:
            writereg(core#PAYLOADLENGTH, 1, @length)
        other:
            curr_len := 0
            readreg(core#PAYLOADLENGTH, 1, @curr_len)
            return

PUB PayloadLenCfg(mode): curr_mode
' Set payload/packet length mode
'   Valid values:
'       PKTLEN_FIXED: fixed payload length
'       PKTLEN_VAR: variable payload length
'   Any other value polls the chip and returns the current setting
    curr_mode := 0
    readreg(core#PKTCFG1, 1, @curr_mode)
    case mode
        PKTLEN_FIXED, PKTLEN_VAR:
            mode <<= core#PKTFORMAT
        other:
            return (curr_mode >> core#PKTFORMAT) & 1

    mode := ((curr_mode & core#PKTFORMAT_MASK) | mode) & core#PKTCFG1_MASK
    writereg(core#PKTCFG1, 1, @mode)

PUB PayloadSent{}: flag
' Flag indicating packet sent
'   Returns:
'       TRUE (-1) if packet sent
'       FALSE (0) otherwise
'   NOTE: Once set, this flag clears when exiting TX mode
    flag := 0
    readreg(core#IRQFLAGS2, 1, @flag)
    return ((flag >> core#PKTSENT) & 1) == 1

PUB PreambleLen(length): curr_len
' Set number of length in bytes
'   Valid values: 0..65535
'   Any other value polls the chip and returns the current setting
    case length
        0..65535:
            writereg(core#PREAMBLEMSB, 2, @length)
        other:
            curr_len := 0
            readreg(core#PREAMBLEMSB, 2, @curr_len)
            return

PUB RampTime(rtime): curr_rtime
' Set rise/fall time of ramp up/down in FSK, in microseconds
'   Valid values:
'       3400, 2000, 1000, 500, 250, 125, 100, 62, 50, 40, 31, 25, 20, 15, 12, 10
'   Any other value polls the chip and returns the current setting
    case rtime
        3400, 2000, 1000, 500, 250, 125, 100, 62, 50, 40, 31, 25, 20, 15, 12, 10:
            rtime := lookdownz(rtime: 3400, 2000, 1000, 500, 250, 125, 100,{
}           62, 50, 40, 31, 25, 20, 15, 12, 10)
            rtime := (rtime & core#PA_RAMP_BITS) & core#PARAMP_MASK
            writereg(core#PARAMP, 1, @rtime)
        other:
            readreg(core#PARAMP, 1, @curr_rtime)
            curr_rtime &= core#PA_RAMP_BITS
            return lookupz(curr_rtime: 3400, 2000, 1000, 500, 250, 125, 100,{
}           62, 50, 40, 31, 25, 20, 15, 12, 10)

PUB RCOscCal(state): curr_state
' Trigger calibration of RC oscillator
'   Valid values:
'       TRUE (-1 or 1)
'   Any other value polls the chip and returns the current calibration status
'   Returns:
'       FALSE: RC calibration in progress
'       TRUE: RC calibration complete
    readreg(core#OSC1, 1, @curr_state)
    case ||(state)
        1:
            state := ||(state) << core#RCCALSTART
        other:
            return ((curr_state >> core#RCCALDONE) & 1) == 1

    state := (curr_state | state) & core#OSC1_MASK
    writereg(core#OSC1, 1, @state)

PUB RSSI{}: level | tmp
' Received Signal Strength Indicator
'   Returns: Signal strength seen by transceiver, in dBm
    tmp := %1
    writereg(core#RSSICFG, 1, @tmp)
    repeat
        readreg(core#RSSICFG, 1, @tmp)
    until tmp & core#RSSIDONE

    readreg(core#RSSIVALUE, 1, @level)
    return (level >> 1) * -1

PUB RXBandwidth(bw): curr_bw | bw_m, bw_e   'XXX only calcs for FSK mode
' Set receiver channel filter bandwidth, in Hz
'   Valid values: 2600, 3100, 3900, 5200, 6300, 7800, 10400, 12500, 15600, 20800, 25000, 31300, 41700, 50000, 62500, 83300, 100000, 125000, 166700, 200000, 250000, 333300, 400000, 500000
'   Any other value polls the chip and returns the current setting
    curr_bw := 0
    readreg(core#RXBW, 1, @curr_bw)
    case bw
        2_600..500_000: 'XXX calc this instead of using tables
            bw_e := bw_m := lookdownz(bw: 500000, 400000, 333300, 250000, 200000, 166700, 125000, 100000, 83300, 62500, 50000, 41700, 31300, 25000, 20800, 15600, 12500, 10400, 7800, 6300, 5200, 3900, 3100, 2600)
            bw_m := lookupz(bw_m: %00, %01, %10, %00, %01, %10, %00, %01, %10, %00, %01, %10, %00, %01, %10, %00, %01, %10, %00, %01, %10, %00, %01, %10) << core#RXBWMANT
            bw_e := lookupz(bw_e: 00, 00, 00, 01, 01, 01, 02, 02, 02, 03, 03, 03, 04, 04, 04, 05, 05, 05, 06, 06, 06, 07, 07, 07)
            curr_bw := bw_m | bw_e
        other:
            bw_e := curr_bw & core#RXBWEXP_BITS
            bw_m := (curr_bw >> core#RXBWMANT) & core#RXBWMANT_BITS
            bw_m := lookupz(bw_m: 16, 20, 24)
            return FXOSC / (bw_m * (1 << (bw_e + 2)))

    bw := ((curr_bw & core#RX_BW_MASK) | bw) & core#RXBW_MASK
    writereg(core#RXBW, 1, @bw)

PUB RXPayload(nr_bytes, ptr_buff)
' Read data queued in the RX FIFO
'   nr_bytes Valid values: 1..66
'   Any other value is ignored
'   NOTE: Ensure buffer at address ptr_buff is at least as big as the number of bytes you're reading
    readreg(core#FIFO, nr_bytes, ptr_buff)

PUB RXMode{}
' Change chip state to RX (receive)
    opmode(OPMODE_RX)

PUB SensitivityMode(mode): curr_mode
' Set receiver sensitivity level/mode
'   Valid values:
'      *SENS_NORM: normal sensitivity
'       SENS_HI: high sensitivity
'   Any other value polls the chip and returns the current setting
    case mode
        SENS_NORM, SENS_HI:
            writereg(core#TESTLNA, 1, @mode)
        other:
            curr_mode := 0
            readreg(core#TESTLNA, 1, @curr_mode)
            return

PUB Sequencer(mode): curr_mode
' Control automatic sequencer
'   Valid values:
'       *OPMODE_AUTO (0): Automatic sequence, as selected by OpMode()
'        OPMODE_MANUAL (1): Mode is forced
'   Any other value polls the chip and returns the current setting
    readreg(core#OPMODE, 1, @curr_mode)
    case mode
        OPMODE_AUTO, OPMODE_MANUAL:
            mode := mode << core#SEQOFF
        other:
            return (curr_mode >> core#SEQOFF) & 1

    mode := ((curr_mode & core#SEQOFF_MASK) | mode) & core#OPMODE_MASK
    writereg(core#OPMODE, 1, @mode)

PUB Sleep{}
' Power down chip
    opmode(OPMODE_SLEEP)

PUB SyncMode(param)
' dummy method

PUB SyncWord(rw, ptr_buff)'XXX SEE IF THIS CAN BE MADE API-COMPLIANT (1 PARAM)
' Set sync word to value at ptr_buff
'   Valid values:
'       rw: SW_READ (0), SW_WRITE (1)
'       variable at address ptr_buff: All bytes can be $01..$FF
'   For rw, any value other than SW_WRITE (1) polls the chip and returns the current setting
'   NOTE: Variable pointed to by ptr_buff must be at least 8 bytes in length
    case rw
        SW_WRITE:
            writereg(core#SYNCVALUE1, 8, ptr_buff)
        other:
            readreg(core#SYNCVALUE1, 8, ptr_buff)  'XXX Future test: set nr_bytes arg to SyncWordBytes(-2)?

PUB SyncWordEnabled(state): curr_state
' Enable sync word generation (TX) and detection (RX)
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
    curr_state := 0
    readreg(core#SYNCCFG, 1, @curr_state)
    case ||(state)
        0, 1:
            state := ||(state) << core#SYNCON
        other:
            return ((curr_state >> core#SYNCON) & 1) == 1

    state := ((curr_state & core#SYNCON_MASK) | state) & core#SYNCCFG_MASK
    writereg(core#SYNCCFG, 1, @state)

PUB SyncWordLength(length): curr_len
' Set length of sync word, in bytes
'   Valid values: 1..8
'   Any other value polls the chip and returns the current setting
    curr_len := 0
    readreg(core#SYNCCFG, 1, @curr_len)
    case length
        1..8:
            length := (length-1) << core#SYNCSIZE
        other:
            return ((curr_len >> core#SYNCSIZE) & core#SYNCSIZE) + 1

    length := ((curr_len & core#SYNCSIZE_MASK) | length) & core#SYNCCFG_MASK
    writereg(core#SYNCCFG, 1, @length)

PUB SyncWordMaxBitErr(bits): curr_bits
' Set maximum number of tolerated bit errors in sync word
'   Valid values: 0..7
'   Any other value polls the chip and returns the current setting
    curr_bits := 0
    readreg(core#SYNCCFG, 1, @curr_bits)
    case bits
        0..7:
        other:
            return (curr_bits & core#SYNCTOL)

    bits := ((curr_bits & core#SYNCTOL_MASK) | bits) & core#SYNCCFG_MASK
    writereg(core#SYNCCFG, 1, @bits)

PUB Temperature{}: temp | tmp
' Read temperature
'   Returns: Hundredths of a degree C
'   NOTE: The receiver can't be used while measuring temperature
    tmp := (1 << core#TEMPMEASSTART)            ' start measurement
    writereg(core#TEMP1, 1, @tmp)
    tmp := 0
    repeat
        readreg(core#TEMP1, 1, @tmp)            ' wait until measurement
    while ((tmp >> core#TEMPMEASRUN) & 1)       '   complete

    temp := 0
    readreg(core#TEMP2, 1, @temp)
    return ~temp * 100

PUB TXMode{}
' Change chip state to transmit
    opmode(OPMODE_TX)

PUB TXPayload(nr_bytes, ptr_buff)
' Queue data to transmit in the TX FIFO
'   nr_bytes Valid values: 1..66
'   Any other value is ignored
    writereg(core#FIFO, nr_bytes, ptr_buff)

PUB TXPower(pwr): curr_pwr | pa1, pa2
' Set transmit output power, in dBm
'   Valid values:
'       -18..20
'   Any other value polls the chip and returns the current setting
    curr_pwr := 0
    readreg(core#PALVL, 1, @curr_pwr)
    case pwr
        -18..13:                                ' PA0 on, PA1 and PA2 off
            pwr := (pwr + 18) | (1 << core#PA0ON)
            pa1 := core#PA1_NORMAL              ' Turn off the PA_BOOST circuit
            pa2 := core#PA2_NORMAL
        14..17:                                 ' PA1 on, PA2 on
            pwr := (pwr + 14) | (1 << core#PA1ON) | (1 << core#PA2ON)
            pa1 := core#PA1_NORMAL              ' PA_BOOST off
            pa2 := core#PA2_NORMAL
        18..20:                                 ' PA1 and PA2 on
            pwr := (pwr + 11) | (1 << core#PA1ON) | (1 << core#PA2ON)
            pa1 := core#PA1_BOOST               ' PA_BOOST on
            pa2 := core#PA2_BOOST
        other:
            case (curr_pwr >> core#PA2ON) & core#PA012_BITS
                %100:                           ' PA0
                    curr_pwr &= core#OUTPWR_BITS
                    curr_pwr -= 18
                %011, %010:                     ' PA1, PA2
                    readreg(core#TESTPA1, 1, @pa1)
                    readreg(core#TESTPA2, 1, @pa2)
                    curr_pwr &= core#OUTPWR_BITS
                    if pa1 == core#PA1_BOOST and pa2 == core#PA2_BOOST
                        curr_pwr -= 11          ' pwr offset with PA_BOOST
                    else
                        curr_pwr -= 14          ' pwr offset without PA_BOOST
            return

    writereg(core#PALVL, 1, @pwr)
    writereg(core#TESTPA1, 1, @pa1)
    writereg(core#TESTPA2, 1, @pa2)

PUB TXStartCondition(cond): curr_cond
' Define condition to begin packet transmission
'   Valid values:
'       TXSTART_FIFOLVL (0): If the number of bytes in the FIFO exceeds
'           FIFOThreshold()
'      *TXSTART_FIFONOTEMPTY (1): If there's at least one byte in the FIFO
'   Any other value polls the chip and returns the current setting
    curr_cond := 0
    readreg(core#FIFOTHRESH, 1, @curr_cond)
    case cond
        TXSTART_FIFOLVL, TXSTART_FIFONOTEMPTY:
            cond <<= core#TXSTARTCOND
        other:
            return (curr_cond >> core#TXSTARTCOND) & 1

    cond := ((curr_cond & core#TXSTARTCOND_MASK) | cond) & core#FIFOTHRESH_MASK
    writereg(core#FIFOTHRESH, 1, @cond)

PUB WaitRX{} | tmp
' Force the receiver in wait mode (continuous RX)
    tmp := 0
    readreg(core#PKTCFG2, 1, @tmp)

    tmp &= core#RSTARTRX_MASK
    tmp := (tmp | (1 << core#RSTARTRX)) & core#PKTCFG2_MASK
    writereg(core#PKTCFG2, 1, @tmp)

PRI readReg(reg_nr, nr_bytes, ptr_buff) | tmp
' Read nr_bytes from device into ptr_buff
    case reg_nr
        $00..$13, $18..$4F, $58..$59, $5F, $6F, $71:
            io.low(_CS)
            spi.shiftout(_MOSI, _SCK, core#MOSI_BITORDER, 8, reg_nr)
            repeat tmp from nr_bytes-1 to 0
                byte[ptr_buff][tmp] := spi.shiftin(_MISO, _SCK, core#MISO_BITORDER, 8)
            io.high(_CS)

        other:
            return

PRI writereg(reg_nr, nr_bytes, ptr_buff) | tmp
' Write nr_bytes to device from ptr_buff
    case reg_nr
        $00..$13, $18..$4F, $58..$59, $5F, $6F, $71:
            io.low(_CS)
            spi.shiftout(_MOSI, _SCK, core#MOSI_BITORDER, 8, reg_nr|core#W)
            repeat tmp from nr_bytes-1 to 0
                spi.shiftout(_MOSI, _SCK, core#MOSI_BITORDER, 8, byte[ptr_buff][tmp])
            io.high(_CS)

        other:
            return

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
