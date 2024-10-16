{
----------------------------------------------------------------------------------------------------
    Filename:       wireless.transceiver.sx1231.spin
    Description:    Driver for the Semtech SX1231 UHF Transceiver IC
    Author:         Jesse Burt
    Started:        Apr 19, 2019
    Updated:        Oct 14, 2024
    Copyright (c) 2024 - See end of file for terms of use.
----------------------------------------------------------------------------------------------------
}

CON

    { default I/O settings; these can be overridden in the parent object }
    ' SPI
    CS                      = 0
    SCK                     = 1
    MOSI                    = 2
    MISO                    = 3
    SPI_FREQ                = 1_000_000
    RST                     = 4

    ' limits
    PAYLD_LEN_MAX           = 66


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
    INT_OPMODE_RDY          = 1 << 15
    INT_RXRDY               = 1 << 14
    INT_TXRDY               = 1 << 13
    INT_PLL_LOCKED          = 1 << 12
    INT_RSSI_THR            = 1 << 11
    INT_TIMEOUT             = 1 << 10
    INT_INTERM_MODE         = 1 << 9
    INT_SYNC_ADDR_MATCH     = 1 << 8
    INT_FIFO_FULL           = 1 << 7
    INT_FIFO_NOTEMPTY       = 1 << 6
    INT_FIFO_THR            = 1 << 5
    INT_FIFO_OVER           = 1 << 4
    INT_PAYLD_SENT          = 1 << 3
    INT_PAYLD_RDY           = 1 << 2
    INT_PAYLD_CRCOK         = 1 << 1
    INT_BATT_LO             = 1

    ' Clock output modes
    CLKOUT_RC               = 6
    CLKOUT_OFF              = 7

    ' GPIO pin modes                            ' Usable when op_mode() ==
    DIO0_LOWBAT             = 2                 ' SLEEP, STDBY, FS, TX
    DIO0_PLLLOCK            = 3                 ' FS, TX
    DIO0_CRCOK              = 0                 ' RX
    DIO0_PAYLDRDY           = 1                 ' RX
    DIO0_SYNCADDR           = 2                 ' RX
    DIO0_RSSI               = 3                 ' RX
    DIO0_PKTSENT            = 0                 ' TX
    DIO0_TXRDY              = 1                 ' TX

    DIO1_FIFOLVL            = 0                 ' All
    DIO1_FIFOFULL           = 1                 ' All
    DIO1_FIFONOTEMPTY       = 2                 ' All
    DIO1_TIMEOUT            = 3                 ' RX
    DIO1_PLLLOCK            = 3                 ' FS, TX

    DIO2_FIFONOTEMPTY       = 0                 ' All
    DIO2_DATA               = 1                 ' RX, TX
    DIO2_LOWBAT             = 2                 ' All
    DIO2_AUTOMODE           = 3                 ' All

    DIO3_FIFOFULL           = 0                 ' All
    DIO3_RSSI               = 1                 ' RX
    DIO3_TXRDY              = 1                 ' TX
    DIO3_LOWBAT             = 2                 ' SLEEP, STDBY, FS, TX
    DIO3_SYNCADDR           = 2                 ' RX
    DIO3_PLLLOCK            = 3                 ' FS, RX, TX

    DIO4_RSSI               = 1                 ' RX
    DIO4_TXRDY              = 1                 ' TX
    DIO4_LOWBAT             = 2                 ' SLEEP, STDBY, FS, TX
    DIO4_RXRDY              = 2                 ' RX
    DIO4_PLLLOCK            = 3                 ' FS, RX, TX

    DIO5_CLKOUT             = 0                 ' STDBY, FS, RX, TX
    DIO5_DATA               = 1                 ' RX, TX
    DIO5_LOWBAT             = 2                 ' All
    DIO5_MODERDY            = 3                 ' All


VAR

    long _CS, _RST


OBJ

    spi:    "com.spi.1mhz"                      ' SPI engine
    core:   "core.con.sx1231"                   ' HW-specific constants
    time:   "time"                              ' timekeeping methods
    u64:    "math.unsigned64"                   ' unsigned 64-bit int math


PUB null()
' This is not a top-level object


PUB start(): status
' Start the driver using default I/O settings
    return startx(CS, SCK, MOSI, MISO, RST)


PUB startx(CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN, RESET_PIN): status
' Start the driver with custom I/O settings
'   CS_PIN:     Chip Select (0..31)
'   SCK_PIN:    Serial Clock (0..31)
'   MOSI_PIN:   Master-Out Slave-In (0..31)
'   MISO_PIN:   Master-In Slave-Out (0..31)
'   RESET_PIN:  Reset (0..31)
'   Returns:
'       cog ID+1 of SPI engine on success (= calling cog ID+1, if the bytecode SPI engine is used)
'       0 on failure
    if (lookdown(CS_PIN: 0..31) and lookdown(SCK_PIN: 0..31) and lookdown(MOSI_PIN: 0..31) and ...
        lookdown(MISO_PIN: 0..31) )
        if ( status := spi.init(SCK_PIN, MOSI_PIN, MISO_PIN, core.SPI_MODE) )
            _CS := CS_PIN
            _RST := RESET_PIN
            outa[_CS] := 1
            dira[_CS] := 1
            reset()                             ' soft-reset (if pin defined)
            time.usleep(core.T_POR)             ' wait for device startup
            if ( lookdown(dev_id(): $21..$24) )
                return
    ' if this point is reached, something above failed
    ' Double check I/O pin assignments, connections, power
    ' Lastly - make sure you have at least one free core/cog
    return FALSE


PUB stop()
' Stop the driver
    spi.deinit()
    longfill(@_CS, 0, 2)


PUB defaults() | tmp[4]
' Factory defaults
    addr_check(ADDRCHK_NONE)
    afc_auto_ena(FALSE)
    afc_method(AFC_STANDARD)
    auto_restart_rx(TRUE)
    bcast_addr($00)
    carrier_freq(915_000_000)
    crc_check_ena(TRUE)
    data_mode(DATAMODE_PKT)
    data_rate(4800)
    data_whiten_ena(FALSE)
    encrypt_ena(FALSE)
    bytefill(@tmp, $00, 16)
    encrypt_key(KEY_WR, @tmp)
    enter_cond(ENTCOND_NONE)
    exit_cond(EXITCOND_NONE)
    fifo_thresh(15)
    freq_dev(5000)
    gaussian_filt(BT_NONE)
    interm_mode(IMODE_SLEEP)
    listen(FALSE)
    lna_gain(LNA_AGC)
    lna_z_input(200)
    low_batt_lvl(1_835)
    low_batt_mon_ena(FALSE)
    manchest_enc_ena(FALSE)
    modulation(MOD_FSK)
    node_addr($00)
    ocp_current(95)
    opmode(OPMODE_STDBY)
    over_current_prot_ena(TRUE)
    payld_len(64)
    payld_len_cfg(PKTLEN_FIXED)
    preamble_len(3)
    pa_ramp_time(40)
    rx_bw(10_400)
    sequencer(OPMODE_AUTO)
    set_syncwd( string($01, $01, $01, $01, $01, $01, $01, $01) )
    syncwd_ena(TRUE)
    syncwd_len(4)
    syncwd_max_bit_err(0)
    tx_pwr(13)
    tx_start_cond(TXSTART_FIFONOTEMPTY)


PUB preset_tx4k8()
' Transmit, 4800bps (uses Automodes to transition between sleep-TX-sleep)
    reset()                                     ' start with default settings

    tx_start_cond(TXSTART_FIFOLVL)              ' can TX only if FIFO > thresh
    opmode(OPMODE_SLEEP)                        ' start in sleep mode
    enter_cond(ENTCOND_FIFOLVL)                 ' next mode if FIFO > thresh
    interm_mode(IMODE_TX)                       ' next mode is transmit
    exit_cond(EXITCOND_PKTSENT)                 ' back to sleep, once sent


PUB preset_rx4k8()
' Receive, 4800bps (uses Automodes to transition between RX-sleep-RX)
    reset()

    opmode(OPMODE_RX)                           ' start in RX mode
    enter_cond(ENTCOND_CRCOK)                   ' next mode if CRC is good
    interm_mode(IMODE_SLEEP)                    ' next mode is sleep
    exit_cond(EXITCOND_FIFOEMPTY)               ' back to RX, once payld rcvd.


PUB abort_listen() | tmp
' Abort listen mode when used together with Listen(FALSE)
    tmp := 0
    readreg(core.OPMODE, 1, @tmp)
    tmp &= core.LISTENABT_MASK
    tmp := (tmp | (1 << core.LISTENABT))
    writereg(core.OPMODE, 1, @tmp)


PUB addr_check(mode=-2): curr_mode
' Enable address checking/matching/filtering
'   Valid values:
'       ADDRCHK_NONE (%00): No address check
'       ADDRCHK_CHK_NO_BCAST (%01): Check address, but ignore broadcast addresses
'       ADDRCHK_CHK_00_BCAST (%10): Check address, and also respond to broadcast address
'   Any other value polls the chip and returns the current setting
    curr_mode := 0
    readreg(core.PKTCFG1, 1, @curr_mode)
    case mode
        ADDRCHK_NONE, ADDRCHK_CHK_NO_BCAST, ADDRCHK_CHK_BCAST:
            mode <<= core.ADDRFILT
            mode := ((curr_mode & core.ADDRFILT_MASK) | mode)
            writereg(core.PKTCFG1, 1, @mode)
        other:
            return ((curr_mode >> core.ADDRFILT) & core.ADDRFILT_BITS)


PUB afc_auto_ena(state=-2): curr_state
' Enable automatic AFC
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
    curr_state := 0
    readreg(core.AFCFEI, 1, @curr_state)
    case ||(state)
        0, 1:
            state := ||(state) << core.AFCAUTOON
            state := ((curr_state & core.AFCAUTOON_MASK) | state)
            writereg(core.AFCFEI, 1, @state)
        other:
            return (((curr_state >> core.AFCAUTOON) & 1) == 1)


PUB afc_complete(): flag
' Flag indicating AFC (auto or manual) completed
'   Returns: TRUE (-1) if complete, FALSE (0) otherwise
    flag := 0
    readreg(core.AFCFEI, 1, @flag)
    return (((flag >> core.AFCDONE) & 1) == 1)


PUB afc_method(mode=-2): curr_mode
' Set AFC mode/routine
'   Valid values:
'       AFC_STANDARD (0): Standard AFC routine
'       AFC_IMPROVED (1): Improved AFC routine, for signals with modulation index < 2
'   Any other value polls the chip and returns the current setting
    curr_mode := 0
    readreg(core.AFCCTRL, 1, @curr_mode)
    case mode
        AFC_STANDARD, AFC_IMPROVED:
            mode := mode << core.AFCLOWBETAON
            mode := ((curr_mode & core.AFCLOWBETAON_MASK) | mode)
            writereg(core.AFCCTRL, 1, @mode)
        other:
            return ((curr_mode >> core.AFCLOWBETAON) & 1)


PUB afc_offset(): offs
' Read AFC frequency offset
'   Returns: Frequency offset in Hz
    offs := 0
    readreg(core.AFCMSB, 2, @offs)
    return (~~offs) * FSTEP


PUB afc_start() | tmp
' Trigger a manual AFC
    readreg(core.AFCFEI, 1, @tmp)               ' read reg setting
    tmp |= 1                                    ' set the AFCSTART bit
    writereg(core.AFCFEI, 1, @tmp)              ' write it back


PUB after_rx(next_state=-2): curr_state
' Define the state the radio transitions to after a packet is successfully
'   received
    curr_state := interm_mode(next_state)


PUB after_tx(next_state=-2): curr_state
' Define the state the radio transitions to after a packet is successfully
'   transmitted
    curr_state := interm_mode(next_state)


PUB auto_restart_rx(state=-2): curr_state
' Enable automatic RX restart (RSSI phase)
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
'   NOTE: Restart occurs after payload is ready and the packet has been read from the FIFO
    curr_state := 0
    readreg(core.PKTCFG2, 1, @curr_state)
    case ||(state)
        0, 1:
            state := ||(state) << core.AUTORSTARTRXON
            state := ((curr_state & core.AUTORSTARTRXON_MASK) | state)
            writereg(core.PKTCFG2, 1, @state)
        other:
            return (((curr_state >> core.AUTORSTARTRXON) & 1) == 1)


PUB batt_low(): flag
' Flag indicating battery voltage low
'   Returns TRUE if battery low, FALSE otherwise
    readreg(core.LOWBAT, 1, @flag)
    return ( ( (flag >> core.LOWBATMON) & 1) == 1)


PUB bcast_addr(addr=-2): curr_addr
' Set broadcast address
'   Valid values: $00..$FF
'   Any other value polls the chip and returns the current setting
    case addr
        $00..$FF:
            writereg(core.BCASTADRS, 1, @addr)
        other:
            curr_addr := 0
            readreg(core.BCASTADRS, 1, @curr_addr)
            return


PUB carrier_freq(freq=-2): curr_freq
' Set Carrier frequency, in Hz
'   Valid values:
'       290_000_000..340_000_000, 424_000_000..510_000_000, 862_000_000..1_020_000_000
'   Any other value polls the chip and returns the current setting
'   NOTE: Set value will be rounded
    case freq
        290_000_000..340_000_000, 424_000_000..510_000_000, 862_000_000..1_020_000_000:
            freq := u64.multdiv(freq, 1_000, FSTEP)
            writereg(core.FRFMSB, 3, @freq)
        other:
            readreg(core.FRFMSB, 3, @curr_freq)
            return u64.multdiv(curr_freq, FSTEP, 1_000)


PUB clk_out(divisor=-2): curr_div
' Set clkout frequency, as a divisor of FXOSC
'   Valid values:
'       1, 2, 4, 8, 16, 32, CLKOUT_RC (6), CLKOUT_OFF (7)
'   Any other value polls the chip and returns the current setting
'   NOTE: For optimal efficiency, it is recommended to disable the
'       clock output (CLKOUT_OFF) unless needed
    curr_div := 0
    readreg(core.DIOMAP2, 1, @curr_div)
    case divisor
        1, 2, 4, 8, 16, 32, CLKOUT_RC, CLKOUT_OFF:
            divisor := lookdownz(divisor: 1, 2, 4, 8, 16, 32, CLKOUT_RC, CLKOUT_OFF)
            divisor := ((curr_div & core.CLKOUT_MASK) | divisor)
            writereg(core.DIOMAP2, 1, @divisor)
        other:
            curr_div &= core.CLKOUT_BITS
            return lookupz(curr_div: 1, 2, 4, 8, 16, 32, CLKOUT_RC, CLKOUT_OFF)


PUB crc_check_ena(state=-2): curr_state
' Enable CRC calculation (TX) and checking (RX)
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
    curr_state := 0
    readreg(core.PKTCFG1, 1, @curr_state)
    case ||(state)
        0, 1:
            state := ||(state) << core.CRCON
            state := ((curr_state & core.CRCON_MASK) | state)
            writereg(core.PKTCFG1, 1, @state)
        other:
            return (((curr_state >> core.CRCON) & 1) == 1)


PUB data_mode(mode=-2): curr_mode
' Set data processing mode
'   Valid values:
'       DATAMODE_PKT (0): Packet mode
'       DATAMODE_CONT_W_SYNC (2): Continuous mode with bit synchronizer
'       DATAMODE_CONT_WO_SYNC (3): Continuous mode without bit synchronizer
'   Any other value polls the chip and returns the current setting
    readreg(core.DATAMOD, 1, @curr_mode)
    case mode
        DATAMODE_PKT, DATAMODE_CONT_W_SYNC, DATAMODE_CONT_WO_SYNC:
            mode := mode << core.DATAMODE
            mode := ((curr_mode & core.DATAMODE_MASK) | mode)
            writereg(core.DATAMOD, 1, @mode)
        other:
            return ((curr_mode >> core.DATAMODE) & core.DATAMODE_BITS)


PUB data_rate(rate=-2): curr_rate
' Set on-air data rate, in bits per second
'   Valid values:
'       1_200..300_000
'   Any other value polls the chip and returns the current setting
'   NOTE: Result will be rounded
'   NOTE: Effective data rate will be halved if Manchester encoding is used
    case rate
        1_200..300_000:
            rate := (FXOSC / rate) & core.BITRATE_MASK
            writereg(core.BITRATEMSB, 2, @rate)
        other:
            readreg(core.BITRATEMSB, 2, @curr_rate)
            return (FXOSC / curr_rate)


PUB data_whiten_ena(state=-2): curr_state
' Enable data whitening
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
'   NOTE: This setting and manchest_enc_ena() are mutually exclusive;
'       enabling this will disable manchest_enc_ena()
    curr_state := 0
    readreg(core.PKTCFG1, 1, @curr_state)
    case ||(state)
        0:
        1:
            state := DCFREE_WHITE << core.DCFREE
        other:
            curr_state := ((curr_state >> core.DCFREE) & core.DCFREE_BITS)
            return (curr_state == DCFREE_WHITE)

    state := ((curr_state & core.DCFREE_MASK) | state)
    writereg(core.PKTCFG1, 1, @state)


PUB dev_id(): id
' Read device ID
'   Returns:
'       Value   Chip version
'       $21:    V2a
'       $22:    V2b
'       $23:    V2c
'       $24:    ???
    id := 0
    readreg(core.VERSION, 1, @id)


PUB encrypt_ena(state=-2): curr_state
' Enable AES encrypt_ena/decryption
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
'   NOTE: Encryption is limited to payloads of a maximum of 66 bytes
    curr_state := 0
    readreg(core.PKTCFG2, 1, @curr_state)
    case ||(state)
        0, 1:
            state := ||(state) & 1
            state := ((curr_state & core.AESON_MASK) | state)
            writereg(core.PKTCFG2, 1, @state)
        other:
            return ((curr_state & 1) == 1)


PUB encrypt_key(rw, ptr_buff) | tmp
' Set AES 128-bit encrypt_ena key
'   Valid values:
'       rw: KEY_RD (0), KEY_WR (1)
'       ptr_buff: All bytes at address may be $00..$FF
'   NOTE: Buffer at ptr_buff must be at least 16 bytes
'       1st byte of key is MSB
    case rw
        KEY_WR:
            writereg(core.AESKEY1, 16, ptr_buff)
        other:
            readreg(core.AESKEY1, 16, ptr_buff)


PUB enter_cond(cond=-2): curr_cond
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
    readreg(core.AUTOMODES, 1, @curr_cond)
    case cond
        ENTCOND_NONE, ENTCOND_FIFONOTEMPTY, ENTCOND_FIFOLVL, ENTCOND_CRCOK, ENTCOND_PAYLDRDY, ENTCOND_SYNCADD, ENTCOND_PKTSENT, ENTCOND_FIFOEMPTY:
            cond <<= core.ENTCOND
            cond := ((curr_cond & core.ENTCOND_MASK) | cond)
            writereg(core.AUTOMODES, 1, @cond)
        other:
            return ((curr_cond >> core.ENTCOND) & core.ENTCOND_BITS)


PUB exit_cond(cond=-2): curr_cond
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
    readreg(core.AUTOMODES, 1, @curr_cond)
    case cond
        EXITCOND_NONE, EXITCOND_FIFOEMPTY, EXITCOND_FIFOLVL, EXITCOND_CRCOK, EXITCOND_PAYLDRDY, ...
        EXITCOND_SYNCADD, EXITCOND_PKTSENT, EXITCOND_TIMEOUT:
            cond <<= core.EXITCOND
            cond := ((curr_cond & core.EXITCOND_MASK) | cond)
            writereg(core.AUTOMODES, 1, @cond)
        other:
            return ((curr_cond >> core.EXITCOND) & core.EXITCOND_BITS)


PUB fei_complete(): flag
' Flag indicating FEI measurement complete
'   Returns: TRUE if complete, FALSE otherwise
    flag := 0
    readreg(core.AFCFEI, 1, @flag)
    return ( ( (flag >> core.FEIDONE) & 1) == 1)


PUB fei_error(): ferr
' Frequency error
'   Returns: FEI measurement, in Hz (signed)
    ferr := 0
    readreg(core.AFCFEI, 2, @ferr)
    return ((~~ferr) * FSTEP)


PUB fei_start() | tmp
' Trigger a manual FEI measurement
    tmp := 0
    readreg(core.AFCFEI, 1, @tmp)               ' read reg settings
    tmp := tmp | (1 << core.FEISTART)           ' set the FEISTART bit
    writereg(core.AFCFEI, 1, @tmp)              ' write it back


PUB fifo_empty(): flag
' Flag indicating FIFO empty
'   Returns:
'       TRUE (-1): FIFO empty
'       FALSE (0): FIFO contains at least one byte
    flag := 0
    readreg(core.IRQFLAGS2, 1, @flag)
    return ( ( ( (flag >> core.FIFONOTEMPTY) & 1) ^ 1) == 1)


PUB fifo_full(): flag
' Flag indicating FIFO full
'   Returns:
'       TRUE (-1): FIFO full
'       FALSE (0): at least one byte available
    flag := 0
    readreg(core.IRQFLAGS2, 1, @flag)
    return ( ( (flag >> core.FIFOFULL) & 1) == 1)


PUB fifo_thresh(thresh=-2): curr_thr
' Set threshold for triggering FIFO level interrupt
'   Valid values: 0..127
'   Any other value polls the chip and returns the current setting
    curr_thr := 0
    readreg(core.FIFOTHRESH, 1, @curr_thr)
    case thresh
        0..127:
            thresh := ((curr_thr & core.FIFOTHRESHOLD_MASK) | thresh)
            writereg(core.FIFOTHRESH, 1, @thresh)
        other:
            return (curr_thr & core.FIFOTHRESHOLD_BITS)


PUB freq_dev(fdev=-2): curr_fdev
' Set carrier deviation, in Hz
'   Valid values:
'       600..300_000
'       Default is 5_000
'   Any other value polls the chip and returns the current setting
'   NOTE: Set value will be rounded
    case fdev
        600..300_000:
            ' freq deviation reg = (freq deviation / FSTEP)
            fdev := u64.multdiv(fdev, 1_000, FSTEP)
            writereg(core.FDEVMSB, 2, @fdev)
        other:
            curr_fdev := 0
            readreg(core.FDEVMSB, 2, @curr_fdev)
            return u64.multdiv(curr_fdev, FSTEP, 1_000)


PUB gaussian_filt(mode=-2): curr_mode
' Set Gaussian filter/data shaping modeeters
'   Valid values:
'       BT_NONE (0): No shaping
'       BT_1_0 (1): Gaussian filter, BT = 1.0
'       BT_0_5 (2): Gaussian filter, BT = 0.5
'       BT_0_3 (3): Gaussian filter, BT = 0.3
'   Any other value polls the chip and returns the current setting
    readreg(core.DATAMOD, 1, @curr_mode)
    case mode
        BT_NONE..BT_0_3:
            mode := mode << core.MODSHP
            mode := ((curr_mode & core.MODSHP_MASK) | mode)
            writereg(core.DATAMOD, 1, @mode)
        other:
            return ((curr_mode >> core.MODSHP) & core.MODSHP_BITS)


PUB gpio0(mode=-2): curr_mode
' Assert DIO0 pin on set mode
'   Valid values: (available functions are op_mode()-dependent)
'       OPMODE_SLEEP:
'           DIO0_LOWBAT (2)
'       OPMODE_STDBY:
'           DIO0_LOWBAT (2)
'       OPMODE_FS:
'           DIO0_LOWBAT (2)
'           DIO0_PLLLOCK (3)
'       OPMODE_RX:
'           DIO0_CRCOK (0)
'           DIO0_PAYLDRDY (1)
'           DIO0_SYNCADDR (2)
'           DIO0_RSSI (3)
'       OPMODE_TX:
'           DIO0_PKTSENT (0)
'           DIO0_TXRDY (1)
'           DIO0_LOWBAT (2)
'           DIO0_PLLLOCK (3)
    curr_mode := 0
    readreg(core.DIOMAP1, 1, @curr_mode)
    case mode
        0..3:
            mode <<= core.DIO0
            mode := ((curr_mode & core.DIO0_MASK) | mode)
            writereg(core.DIOMAP1, 1, @mode)
        other:
            return ((curr_mode >> core.DIO0) & core.DIO_BITS)


PUB gpio1(mode=-2): curr_mode
' Assert DIO1 pin on set mode
'   Valid values:
'       OPMODE_SLEEP:
'           DIO1_FIFOLVL (0)
'           DIO1_FIFOFULL (1)
'           DIO1_FIFONOTEMPTY (2)
'       OPMODE_STDBY:
'           DIO1_FIOFLVL (0)
'           DIO1_FIFOFULL (1)
'           DIO1_FIFONOTEMPTY (2)
'       OPMODE_FS:
'           DIO1_FIOFLVL (0)
'           DIO1_FIFOFULL (1)
'           DIO1_FIFONOTEMPTY (2)
'           DIO1_PLLLOCK (3)
'       OPMODE_RX:
'           DIO1_FIOFLVL (0)
'           DIO1_FIFOFULL (1)
'           DIO1_FIFONOTEMPTY (2)
'           DIO1_TIMEOUT (3)
'       OPMODE_TX:
'           DIO1_FIOFLVL (0)
'           DIO1_FIFOFULL (1)
'           DIO1_FIFONOTEMPTY (2)
'           DIO1_PLLLOCK (3)
    curr_mode := 0
    readreg(core.DIOMAP1, 1, @curr_mode)
    case mode
        0..3:
            mode <<= core.DIO1
            mode := ((curr_mode & core.DIO1_MASK) | mode)
            writereg(core.DIOMAP1, 1, @mode)
        other:
            return ((curr_mode >> core.DIO1) & core.DIO_BITS)


PUB gpio2(mode=-2): curr_mode
' Assert DIO2 pin on set mode
'   Valid values:
'       OPMODE_SLEEP:
'           DIO2_FIFONOTEMPTY (0)
'           DIO2_LOWBAT (2)
'           DIO2_AUTOMODE (3)
'       OPMODE_STDBY:
'           DIO2_FIFONOTEMPTY (0)
'           DIO2_LOWBAT (2)
'           DIO2_AUTOMODE (3)
'       OPMODE_FS:
'           DIO2_FIFONOTEMPTY (0)
'           DIO2_LOWBAT (2)
'           DIO2_AUTOMODE (3)
'       OPMODE_RX:
'           DIO2_FIFONOTEMPTY (0)
'           DIO2_DATA (1)
'           DIO2_LOWBAT (2)
'           DIO2_AUTOMODE (3)
'       OPMODE_TX:
'           DIO2_FIFONOTEMPTY (0)
'           DIO2_DATA (1)
'           DIO2_LOWBAT (2)
'           DIO2_AUTOMODE (3)
    curr_mode := 0
    readreg(core.DIOMAP1, 1, @curr_mode)
    case mode
        0..3:
            mode <<= core.DIO2
            mode := ((curr_mode & core.DIO2_MASK) | mode)
            writereg(core.DIOMAP1, 1, @mode)
        other:
            return ((curr_mode >> core.DIO2) & core.DIO_BITS)


PUB gpio3(mode=-2): curr_mode
' Assert DIO3 pin on set mode
'   Valid values:
'       OPMODE_SLEEP:
'           DIO3_FIFOFULL (0)
'           DIO3_LOWBAT (2)
'       OPMODE_STDBY:
'           DIO3_FIFOFULL (0)
'           DIO3_LOWBAT (2)
'       OPMODE_FS:
'           DIO3_FIFOFULL (0)
'           DIO3_LOWBAT (2)
'           DIO3_PLLLOCK (3)
'       OPMODE_RX:
'           DIO3_FIFOFULL (0)
'           DIO3_RSSI (1)
'           DIO3_SYNCADDR (2)
'           DIO3_PLLLOCK (3)
'       OPMODE_TX:
'           DIO3_FIFOFULL (0)
'           DIO3_TXRDY (1)
'           DIO3_LOWBAT (2)
'           DIO3_PLLLOCK (3)
    curr_mode := 0
    readreg(core.DIOMAP1, 1, @curr_mode)
    case mode
        0..3:
            mode <<= core.DIO3
            mode := ((curr_mode & core.DIO3_MASK) | mode)
            writereg(core.DIOMAP1, 1, @mode)
        other:
            return (curr_mode & core.DIO_BITS)


PUB gpio4(mode=-2): curr_mode
' Assert DIO4 pin on set mode
'   Valid values:
'       OPMODE_SLEEP:
'           DIO4_LOWBAT (2)
'       OPMODE_STDBY:
'           DIO4_LOWBAT (2)
'       OPMODE_FS:
'           DIO4_LOWBAT (2)
'           DIO4_PLLLOCK (3)
'       OPMODE_RX:
'           DIO4_TIMEOUT (0)
'           DIO4_RSSI (1)
'           DIO4_RXRDY (2)
'           DIO4_PLLLOCK (3)
'       OPMODE_TX:
'           DIO4_MODERDY (0)
'           DIO4_TXRDY (1)
'           DIO4_LOWBAT (2)
'           DIO4_PLLLOCK (3)
    curr_mode := 0
    readreg(core.DIOMAP2, 1, @curr_mode)
    case mode
        0..3:
            mode <<= core.DIO4
            mode := ((curr_mode & core.DIO4_MASK) | mode)
            writereg(core.DIOMAP2, 1, @mode)
        other:
            return ((curr_mode >> core.DIO4) & core.DIO_BITS)


PUB gpio5(mode=-2): curr_mode
' Assert DIO5 pin on set mode
'   Valid values:
'       OPMODE_SLEEP:
'           DIO5_LOWBAT (2)
'           DIO5_MODERDY (3)
'       OPMODE_STDBY:
'           DIO5_CLKOUT (0)
'           DIO5_LOWBAT (2)
'           DIO5_MODERDY (3)
'       OPMODE_FS:
'           DIO5_CLKOUT (0)
'           DIO5_LOWBAT (2)
'           DIO5_MODERDY (3)
'       OPMODE_RX:
'           DIO5_CLKOUT (0)
'           DIO5_DATA (1)
'           DIO5_LOWBAT (2)
'           DIO5_MODERDY (3)
'       OPMODE_TX:
'           DIO5_CLKOUT (0)
'           DIO5_DATA (1)
'           DIO5_LOWBAT (2)
'           DIO5_MODERDY (3)
    curr_mode := 0
    readreg(core.DIOMAP2, 1, @curr_mode)
    case mode
        0..3:
            mode <<= core.DIO5
            mode := ((curr_mode & core.DIO5_MASK) | mode)
            writereg(core.DIOMAP2, 1, @mode)
        other:
            return ((curr_mode >> core.DIO5) & core.DIO_BITS)


PUB idle()
' Change chip state to idle (standby)
    opmode(OPMODE_STDBY)


PUB interm_mode(mode=-2): curr_mode
' Set intermediate operating mode
'   Valid values:
'       IMODE_SLEEP (%00): Sleep
'       IMODE_STBY (%01): Standby
'       IMODE_RX (%10): Receive
'       IMODE_TX (%11): Transmit
'   Any other value polls the chip and returns the current setting
    curr_mode := 0
    readreg(core.AUTOMODES, 1, @curr_mode)
    case mode
        IMODE_SLEEP, IMODE_STBY, IMODE_RX, IMODE_TX:
            mode &= core.INTMDTMODE_BITS
            mode := ((curr_mode & core.INTMDTMODE_MASK) | mode)
            writereg(core.AUTOMODES, 1, @mode)
        other:
            return (curr_mode & core.INTMDTMODE_BITS)


PUB interrupt(): mask
' Read interrupt state
'   Bits:
'   15  - OpMode ready
'   14  - RX mode only: After RSSI, AGC and AFC
'   13  - TX mode only: after PA ramp up
'   12  - FS, RX, TX OpModes: PLL locked
'   11  - RX mode only: RSSI exceeds level set by rssi_int_thresh()
'   10  - Timeout
'   9   - Entered intermediate mode
'   8   - Syncword and address (if enabled) match
'   7   - FIFO is full
'   6   - FIFO isn't empty
'   5   - FIFO level exceeds threshold set by fifo_thresh()
'   4   - FIFO overrun
'   3   - Payload sent
'   2   - Payload ready
'   1   - RX Payload CRC OK
'   0   - Battery voltage below level set by low_batt_lvl()
    mask := 0
    readreg(core.IRQFLAGS1, 2, @mask)


PUB listen(state=-2): curr_state
' Enable listen mode
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
'   NOTE: Should be enable when in standby mode
    curr_state := 0
    readreg(core.OPMODE, 1, @curr_state)
    case ||(state)
        0, 1:
            state := ||(state) << core.LISTENON
            state := ((curr_state & core.LISTENON_MASK) | state)
            writereg(core.OPMODE, 1, @state)
        other:
            return (((curr_state >> core.LISTENON) & 1) == 1)


PUB lna_gain(gain=-255): curr_gain
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
    curr_gain := 0
    readreg(core.LNA, 1, @curr_gain)
    case gain
        -6, -12, -24, -36, -48:
            gain := lookdownz(gain: LNA_AGC, LNA_HIGH, -6, -12, -24, -36, -48)
            gain := ((curr_gain & core.LNAGAINSEL_MASK) | gain)
            writereg(core.LNA, 1, @gain)
        other:'XXX Should this read the LNACURRENTGAIN field instead?
            curr_gain := curr_gain & core.LNAGAINSEL_BITS
            return lookupz(curr_gain: LNA_AGC, LNA_HIGH, -6, -12, -24, -36, -48)


PUB lna_z_input(impedance=-2): curr_imp
' Set LNA's input impedance, in ohms
'   Valid values:
'       50, *200
'   Any other value polls the chip and returns the current setting
    curr_imp := 0
    readreg(core.LNA, 1, @curr_imp)
    case impedance
        50, 200:
            impedance := lookdownz(impedance: 50, 200) << core.LNAZIN
            impedance := ((curr_imp & core.LNAZIN_MASK) | impedance)
            writereg(core.LNA, 1, @impedance)
        other:
            curr_imp := (curr_imp >> core.LNAZIN) & 1
            return lookupz(curr_imp: 50, 200)


PUB low_batt_lvl(lvl=-2): curr_lvl
' Set low battery threshold, in millivolts
'   Valid values:
'       1695, 1764, *1835, 1905, 1976, 2045, 2116, 2185
'   Any other value polls the chip and returns the current setting
    curr_lvl := 0
    readreg(core.LOWBAT, 1, @curr_lvl)
    case lvl
        1695, 1764, 1835, 1905, 1976, 2045, 2116, 2185:
            lvl := lookdownz(lvl: 1695, 1764, 1835, 1905, 1976, 2045, 2116, 2185)
            lvl := ((curr_lvl & core.LOWBATTRIM_MASK) | lvl)
            writereg(core.LOWBAT, 1, @lvl)
        other:
            curr_lvl &= core.LOWBATTRIM_BITS
            return lookupz(curr_lvl: 1695, 1764, 1835, 1905, 1976, 2045, 2116, 2185)


PUB low_batt_mon_ena(state=-2): curr_state
' Enable low battery detector signal
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
    curr_state := 0
    readreg(core.LOWBAT, 1, @curr_state)
    case ||(state)
        0, 1:
            state := ||(state) << core.LOWBATON
            state := ((curr_state & core.LOWBAT_MASK) | state)
            writereg(core.LOWBAT, 1, @state)
        other:
            return (((curr_state >> core.LOWBATON) & 1) == 1)


PUB manchest_enc_ena(state=-2): curr_state
' Enable Manchester encoding/decoding
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
'   NOTE: This setting and data_whiten_ena() are mutually exclusive;
'       enabling this will disable data_whiten_ena()
    curr_state := 0
    readreg(core.PKTCFG1, 1, @curr_state)
    case ||(state)
        0:                                      ' disabled state is just 0, so
        1:                                      '   just leave it as-is
            state := DCFREE_MANCH << core.DCFREE
        other:
            curr_state := ((curr_state >> core.DCFREE) & core.DCFREE_BITS)
            return (curr_state == DCFREE_MANCH)

    state := ((curr_state & core.DCFREE_MASK) | state)
    writereg(core.PKTCFG1, 1, @state)


PUB modulation(mode=-2): curr_mode
' Set modulation mode
'   Valid values:
'       MOD_FSK (0): Frequency Shift Keyed
'       MOD_OOK (1): On-Off Keyed
'   Any other value polls the chip and returns the current setting
    curr_mode := 0
    readreg(core.DATAMOD, 1, @curr_mode)
    case mode
        MOD_FSK, MOD_OOK:
            mode <<= core.MODTYPE
            mode := ((curr_mode & core.MODTYPE_MASK) | mode)
            writereg(core.DATAMOD, 1, @mode)
        other:
            return (curr_mode >> core.MODTYPE) & core.MODTYPE_BITS


PUB node_addr(addr=-2): curr_addr
' Set node address
'   Valid values: $00..$FF
'   Any other value polls the chip and returns the current setting
    case addr
        $00..$FF:
            writereg(core.NODEADRS, 1, @addr)
        other:
            curr_addr := 0
            readreg(core.NODEADRS, 1, @curr_addr)
            return


PUB ocp_current(lvl=-2): curr_lvl
' Set PA overcurrent protection level, in milliamps
'   Valid values:
'       45..120 (Default: 95)
'   NOTE: Set value will be rounded to the nearest 5mA
'   Any other value polls the chip and returns the current setting
    curr_lvl := 0
    readreg(core.OCP, 1, @curr_lvl)
    case lvl
        45..120:
            lvl := (((lvl-45) / 5) & core.OCPTRIM)
            lvl := ((curr_lvl & core.OCPTRIM_MASK) | lvl)
            writereg(core.OCP, 1, @lvl)
        other:
            return ((5 * (curr_lvl & core.OCPTRIM_BITS)) + 45)


PUB opmode(mode=-2): curr_mode
' Set operating mode
'   Valid values:
'       OPMODE_SLEEP (0): Sleep mode
'       OPMODE_STDBY (1): Standby mode
'       OPMODE_FS (2): Frequency Synthesizer mode
'       OPMODE_TX (3): Transmitter mode
'       OPMODE_RX (4): Receiver mode
'   Any other value polls the chip and returns the current setting
    curr_mode := 0
    readreg(core.OPMODE, 1, @curr_mode)
    case mode
        OPMODE_SLEEP..OPMODE_RX:
            mode <<= core.MODE
            mode := ((curr_mode & core.MODE_MASK) | mode)
            writereg(core.OPMODE, 1, @mode)
        other:
            return ((curr_mode >> core.MODE) & core.MODE_BITS)


PUB over_current_prot_ena(state=-2): curr_state
' Enable PA overcurrent protection
'   Valid values: *TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
    curr_state := 0
    readreg(core.OCP, 1, @curr_state)
    case ||(state)
        0, 1:
            state := ||(state) << core.OCPON
            state := ((curr_state & core.OCPON_MASK) | state)
            writereg(core.OCP, 1, @state)
        other:
            return (((curr_state >> core.OCPON) & 1) == 1)


PUB payld_len(length=-2): curr_len
' Set payload/packet length, in bytes
'   Valid values: 0..66
'   Any other value polls the chip and returns the current setting
' NOTE: Behavior differs depending on setting of payld_len_cfg():
'   If PKTLEN_FIXED, this sets payload length
'   If PKTLEN_VAR, this sets max length in RX, and is ignored in TX
    case length
        0..66:
            writereg(core.PAYLOADLENGTH, 1, @length)
        other:
            curr_len := 0
            readreg(core.PAYLOADLENGTH, 1, @curr_len)
            return


PUB payld_len_cfg(mode=-2): curr_mode
' Set payload/packet length mode
'   Valid values:
'       PKTLEN_FIXED: fixed payload length
'       PKTLEN_VAR: variable payload length
'   Any other value polls the chip and returns the current setting
    curr_mode := 0
    readreg(core.PKTCFG1, 1, @curr_mode)
    case mode
        PKTLEN_FIXED, PKTLEN_VAR:
            mode <<= core.PKTFORMAT
            mode := ((curr_mode & core.PKTFORMAT_MASK) | mode)
            writereg(core.PKTCFG1, 1, @mode)
        other:
            return ((curr_mode >> core.PKTFORMAT) & 1)


PUB payld_sent(): flag
' Flag indicating payload sent
'   Returns:
'       TRUE (-1): payload sent
'       FALSE (0): payload not sent
'   NOTE: Once set, this flag clears when exiting TX mode
    flag := 0
    readreg(core.IRQFLAGS2, 1, @flag)
    return (((flag >> core.PKTSENT) & 1) == 1)


PUB pll_locked(): flag
' Flag indicating PLL is locked
'   Returns: TRUE (-1) or FALSE (0)
    flag := 0
    readreg(core.IRQFLAGS1, 1, @flag)
    return (((flag >> core.PLLLOCK) & 1) == 1)


PUB preamble_len(length=-2): curr_len
' Set length of preamble, in bytes
'   Valid values: 0..65535
'   Any other value polls the chip and returns the current setting
    case length
        0..65535:
            writereg(core.PREAMBLEMSB, 2, @length)
        other:
            curr_len := 0
            readreg(core.PREAMBLEMSB, 2, @curr_len)
            return


PUB pa_ramp_time(rtime=-2): curr_rtime
' Set rise/fall time of ramp up/down in FSK, in microseconds
'   Valid values:
'       3400, 2000, 1000, 500, 250, 125, 100, 62, 50, 40, 31, 25, 20, 15, 12, 10
'   Any other value polls the chip and returns the current setting
    case rtime
        3400, 2000, 1000, 500, 250, 125, 100, 62, 50, 40, 31, 25, 20, 15, 12, 10:
            rtime := lookdownz(rtime:   3400, 2000, 1000, 500, 250, 125, 100, 62, 50, 40, 31, ...
                                        25, 20, 15, 12, 10)
            writereg(core.PARAMP, 1, @rtime)
        other:
            readreg(core.PARAMP, 1, @curr_rtime)
            curr_rtime &= core.PA_RAMP_BITS
            return lookupz(curr_rtime:  3400, 2000, 1000, 500, 250, 125, 100, 62, 50, 40, 31, ...
                                        25, 20, 15, 12, 10)


PUB rc_osc_cal(state=-2): curr_state
' Trigger calibration of RC oscillator
'   Valid values:
'       TRUE (-1 or 1)
'   Any other value polls the chip and returns the current calibration status
'   Returns:
'       FALSE: RC calibration in progress
'       TRUE: RC calibration complete
    curr_state := 0
    readreg(core.OSC1, 1, @curr_state)
    case ||(state)
        1:
            state := ||(state) << core.RCCALSTART
            state := (curr_state & core.RCCALSTART_MASK | state) | core.OSC1_RSVD
            writereg(core.OSC1, 1, @state)
        other:
            return (((curr_state >> core.RCCALDONE) & 1) == 1)


PUB reset()
' Perform soft-reset
    if ( lookdown(_RST: 0..31) )                   ' if a valid pin is set,
        outa[_RST] := 1                         ' pull RESET high for 100uS,
        dira[_RST] := 1
        time.usleep(core.T_RESACTIVE)
        outa[_RST] := 0                         '   then let it float
        dira[_RST] := 0
        time.usleep(core.T_RES)                 ' wait for chip to be ready


PUB rssi(): level | tmp
' Received Signal Strength Indicator
'   Returns: Signal strength seen by transceiver, in dBm
    tmp := 1
    writereg(core.RSSICFG, 1, @tmp)             ' trigger an RSSI measurement
    repeat
        readreg(core.RSSICFG, 1, @tmp)
    until (tmp & core.RSSIDONE)                 ' wait until it's updated

    readreg(core.RSSIVALUE, 1, @level)
    return -(level >> 1)                        ' div by 2 and negate


PUB rssi_int_thresh(thresh=-255): curr_thr
' Set threshold for triggering RSSI interrupt, in dBm
'   Valid values: -127..0
'   Any other value polls the chip and returns the current setting
    case thresh
        -127..0:
            thresh := ||(thresh) * 2
            writereg(core.RSSITHRESH, 1, @thresh)
        other:
            curr_thr := 0
            readreg(core.RSSITHRESH, 1, @curr_thr)
            return -(curr_thr / 2)


PUB rx_bandwidth = rx_bw
PUB rx_bw(bw=-2): curr_bw | exp_mod, exp, mant, mant_tmp, rxb_calc
' Set receiver channel filter bandwidth, in Hz
'   Valid values: 2600, 3100, 3900, 5200, 6300, 7800, 10400, 12500, 15600,
'       20800, 25000, 31300, 41700, 50000, 62500, 83300, 100000, 125000,
'       166700, 200000, 250000, 333300, 400000, 500000
'   Any other value polls the chip and returns the current setting
    curr_bw := 0
    readreg(core.RXBW, 1, @curr_bw)
    ' exponent differs depending on FSK or OOK modulation
    exp_mod := lookupz(modulation(): 2, 3)
    case bw
        2_600..500_000:
            ' iterate through combinations of exponent and mantissa settings
            '   until a (close) match to the requested BW is found
            repeat exp from 7 to 0
                repeat mant from 2 to 0
                    mant_tmp := lookupz(mant: 16, 20, 24)
                    rxb_calc := FXOSC / (mant_tmp * (1 << (exp + exp_mod)))
                    if ( rxb_calc => bw )
                        quit
                if ( rxb_calc => bw )
                    quit
            bw := (mant << 3) | exp
            bw := ((curr_bw & core.RX_BW_MASK) | bw)
            writereg(core.RXBW, 1, @bw)
        other:
            exp := (curr_bw & core.RXBWEXP_BITS)
            mant := ((curr_bw >> core.RXBWMANT) & core.RXBWMANT_BITS)
            mant := lookupz(mant: 16, 20, 24)
            return (FXOSC / (mant * (1 << (exp + exp_mod))))


PUB rx_payld(nr_bytes, ptr_buff)
' Read data queued in the RX FIFO
'   nr_bytes Valid values: 1..66
'   Any other value is ignored
'   NOTE: Buffer at ptr_buff must be at least as large as value
'       nr_bytes is set to
    readreg(core.FIFO, nr_bytes, ptr_buff)


PUB rx_mode()
' Change chip state to RX (receive)
    opmode(OPMODE_RX)


PUB sens_mode(mode=-2): curr_mode
' Set receiver sensitivity level/mode
'   Valid values:
'      *SENS_NORM: normal sensitivity
'       SENS_HI: high sensitivity
'   Any other value polls the chip and returns the current setting
    case mode
        SENS_NORM, SENS_HI:
            writereg(core.TESTLNA, 1, @mode)
        other:
            curr_mode := 0
            readreg(core.TESTLNA, 1, @curr_mode)
            return


PUB sequencer(mode=-2): curr_mode
' Control automatic sequencer
'   Valid values:
'       *OPMODE_AUTO (0): Automatic sequence, as selected by op_mode()
'        OPMODE_MANUAL (1): Mode is forced
'   Any other value polls the chip and returns the current setting
    curr_mode := 0
    readreg(core.OPMODE, 1, @curr_mode)
    case mode
        OPMODE_AUTO, OPMODE_MANUAL:
            mode := mode << core.SEQOFF
            mode := ((curr_mode & core.SEQOFF_MASK) | mode)
            writereg(core.OPMODE, 1, @mode)
        other:
            return ((curr_mode >> core.SEQOFF) & 1)


PUB sleep()
' Power down chip
    opmode(OPMODE_SLEEP)


PUB set_syncwd(ptr_syncwd)
' Set sync word to value at ptr_buff
'   ptr_syncwd: pointer to copy syncword data from
'   NOTE: 8 bytes will be copied from buffer
    writereg(core.SYNCVALUE1, 8, ptr_syncwd)


PUB syncwd(ptr_syncwd)
' Get current sync word
'   ptr_syncwd: pointer to copy syncword data to
'   NOTE: Variable pointed to by ptr_syncwd must be at least 8 bytes in length
    readreg(core.SYNCVALUE1, 8, ptr_syncwd)


PUB syncwd_ena(state=-2): curr_state
' Enable sync word generation (TX) and detection (RX)
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
    curr_state := 0
    readreg(core.SYNCCFG, 1, @curr_state)
    case ||(state)
        0, 1:
            state := ||(state) << core.SYNCON
            state := ((curr_state & core.SYNCON_MASK) | state)
            writereg(core.SYNCCFG, 1, @state)
        other:
            return (((curr_state >> core.SYNCON) & 1) == 1)


PUB syncwd_len(length=-2): curr_len
' Set length of sync word, in bytes
'   Valid values: 1..8
'   Any other value polls the chip and returns the current setting
    curr_len := 0
    readreg(core.SYNCCFG, 1, @curr_len)
    case length
        1..8:
            length := (length-1) << core.SYNCSIZE
            length := ((curr_len & core.SYNCSIZE_MASK) | length)
            writereg(core.SYNCCFG, 1, @length)
        other:
            return (((curr_len >> core.SYNCSIZE) & core.SYNCSIZE_BITS) + 1)


PUB syncwd_max_bit_err(bits=-2): curr_bits
' Set maximum number of tolerated bit errors in sync word
'   Valid values: 0..7
'   Any other value polls the chip and returns the current setting
    curr_bits := 0
    readreg(core.SYNCCFG, 1, @curr_bits)
    case bits
        0..7:
            bits := ((curr_bits & core.SYNCTOL_MASK) | bits)
            writereg(core.SYNCCFG, 1, @bits)
        other:
            return (curr_bits & core.SYNCTOL)


PUB temperature(): temp | tmp
' Read temperature
'   Returns: Hundredths of a degree C
'   NOTE: The receiver can't be used while measuring temperature
    tmp := (1 << core.TEMPMEASSTART)            ' start measurement
    writereg(core.TEMP1, 1, @tmp)
    tmp := 0
    repeat
        readreg(core.TEMP1, 1, @tmp)            ' wait until measurement
    while ((tmp >> core.TEMPMEASRUN) & 1)       '   complete

    temp := 0
    readreg(core.TEMP2, 1, @temp)
    return (~temp * 100)


PUB tx_mode()
' Change chip state to transmit
    opmode(OPMODE_TX)


PUB tx_payld(nr_bytes, ptr_buff)
' Queue data to transmit in the TX FIFO
'   nr_bytes Valid values: 1..66
'   Any other value is ignored
    writereg(core.FIFO, nr_bytes, ptr_buff)


PUB tx_pwr(pwr=-255): curr_pwr | pa1, pa2
' Set transmit output power, in dBm
'   Valid values:
'       -18..20
'   Any other value polls the chip and returns the current setting
    curr_pwr := 0
    readreg(core.PALVL, 1, @curr_pwr)
    case pwr
        -18..13:                                ' PA0 on, PA1 and PA2 off
            pwr := (pwr + 18) | (1 << core.PA0ON)
            pa1 := core.PA1_NORMAL              ' Turn off the PA_BOOST circuit
            pa2 := core.PA2_NORMAL
        14..17:                                 ' PA1 on, PA2 on
            pwr := (pwr + 14) | (1 << core.PA1ON) | (1 << core.PA2ON)
            pa1 := core.PA1_NORMAL              ' PA_BOOST off
            pa2 := core.PA2_NORMAL
        18..20:                                 ' PA1 and PA2 on
            pwr := (pwr + 11) | (1 << core.PA1ON) | (1 << core.PA2ON)
            pa1 := core.PA1_BOOST               ' PA_BOOST on
            pa2 := core.PA2_BOOST
        other:
            case (curr_pwr >> core.PA2ON) & core.PA012_BITS
                %100:                           ' PA0
                    curr_pwr &= core.OUTPWR_BITS
                    curr_pwr -= 18
                %011, %010:                     ' PA1, PA2
                    readreg(core.TESTPA1, 1, @pa1)
                    readreg(core.TESTPA2, 1, @pa2)
                    curr_pwr &= core.OUTPWR_BITS
                    if pa1 == core.PA1_BOOST and pa2 == core.PA2_BOOST
                        curr_pwr -= 11          ' pwr offset with PA_BOOST
                    else
                        curr_pwr -= 14          ' pwr offset without PA_BOOST
            return

    writereg(core.PALVL, 1, @pwr)
    writereg(core.TESTPA1, 1, @pa1)
    writereg(core.TESTPA2, 1, @pa2)


PUB tx_start_cond(cond=-2): curr_cond
' Define condition required to begin packet transmission
'   Valid values:
'       TXSTART_FIFOLVL (0): If the number of bytes in the FIFO exceeds fifo_thresh()
'      *TXSTART_FIFONOTEMPTY (1): If there's at least one byte in the FIFO
'   Any other value polls the chip and returns the current setting
    curr_cond := 0
    readreg(core.FIFOTHRESH, 1, @curr_cond)
    case cond
        TXSTART_FIFOLVL, TXSTART_FIFONOTEMPTY:
            cond <<= core.TXSTARTCOND
            cond := ((curr_cond & core.TXSTARTCOND_MASK) | cond)
            writereg(core.FIFOTHRESH, 1, @cond)
        other:
            return ((curr_cond >> core.TXSTARTCOND) & 1)


PUB wait_rx() | tmp
' Force the receiver in wait mode (continuous RX)
    tmp := 0
    readreg(core.PKTCFG2, 1, @tmp)

    tmp &= core.RSTARTRX_MASK
    tmp := (tmp | (1 << core.RSTARTRX)) & core.PKTCFG2_MASK
    writereg(core.PKTCFG2, 1, @tmp)


PRI readreg(reg_nr, nr_bytes, ptr_buff)
' Read nr_bytes from device into ptr_buff
    case reg_nr                                 ' validate register #
        $00..$13, $18..$4F, $58..$59, $5F, $6F, $71:
            outa[_CS] := 0
                spi.wr_byte(reg_nr)
                spi.rdblock_msbf(ptr_buff, nr_bytes)
            outa[_CS] := 1
        other:
            return


PRI writereg(reg_nr, nr_bytes, ptr_buff)
' Write nr_bytes to device from ptr_buff
    case reg_nr                                 ' validate register #
        $00..$13, $18..$4F, $58..$59, $5F, $6F, $71:
            outa[_CS] := 0
                spi.wr_byte(reg_nr | core.SPI_WR)   ' add write bit to reg #
                spi.wrblock_msbf(ptr_buff, nr_bytes)
            outa[_CS] := 1
        other:
            return


DAT
{
Copyright 2024 Jesse Burt

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

