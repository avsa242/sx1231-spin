{
    --------------------------------------------
    Filename: core.con.sx1231.spin
    Author: Jesse Burt
    Description: Low-level constants
    Copyright (c) 2019
    Started Apr 19, 2019
    Updated Apr 19, 2019
    See end of file for terms of use.
    --------------------------------------------
}

CON

' SPI Configuration
    CPOL                        = 0
    CLK_DELAY                   = 10
    MOSI_BITORDER               = 5             'MSBFIRST
    MISO_BITORDER               = 0             'MSBPRE

    W                           = 1 << 7        ' wnr bit (Write access)

' Register definitions
    FIFO                        = $00

    OPMODE                      = $01
    OPMODE_MASK                 = $FC
        FLD_SEQUENCEROFF        = 7
        FLD_LISTENON            = 6
        FLD_LISTENABORT         = 5
        FLD_MODE                = 2
        BITS_MODE               = %111
        MASK_SEQUENCEROFF       = OPMODE_MASK ^ (1 << FLD_SEQUENCEROFF)
        MASK_LISTENON           = OPMODE_MASK ^ (1 << FLD_LISTENON)
        MASK_LISTENABORT        = OPMODE_MASK ^ (1 << FLD_LISTENABORT)
        MASK_MODE               = OPMODE_MASK ^ (BITS_MODE << FLD_MODE)

    DATAMODUL                   = $02
    DATAMODUL_MASK              = $6B
        FLD_DATAMODE            = 5
        FLD_MODULATIONTYPE      = 3
        FLD_MODULATIONSHAPING   = 0
        BITS_DATAMODE           = %11
        BITS_MODULATIONTYPE     = %01
        BITS_MODULATIONSHAPING  = %11
        MASK_DATAMODE           = DATAMODUL_MASK ^ (BITS_DATAMODE << FLD_DATAMODE)
        MASK_MODULATIONTYPE     = DATAMODUL_MASK ^ (BITS_MODULATIONTYPE << FLD_MODULATIONTYPE)
        MASK_MODULATIONSHAPING  = DATAMODUL_MASK ^ (BITS_MODULATIONSHAPING << FLD_MODULATIONSHAPING)

    BITRATEMSB                  = $03
    BITRATELSB                  = $04
        BITS_BITRATE            = $FFFF

    FDEVMSB                     = $05
    FDEVLSB                     = $06
        BITS_FDEV               = $3FFF

    FRFMSB                      = $07
    FRFMID                      = $08
    FRFLSB                      = $09
        BITS_FRF                = $FF_FF_FF

    OSC1                        = $0A
    OSC1_MASK                   = $80
        FLD_RCCALSTART          = 7
        FLD_RCCALDONE           = 6

    AFCCTRL                     = $0B
    AFCCTRL_MASK                = $20
        FLD_AFCLOWBETAON        = 5

    LOWBAT                      = $0C
    LOWBAT_MASK                 = $1F
        FLD_LOWBATMONITOR       = 4
        FLD_LOWBATON            = 3
        FLD_LOWBATTRIM          = 0
        BITS_LOWBATTRIM         = %111
        MASK_LOWBATMONITOR      = LOWBAT_MASK ^ (1 << FLD_LOWBATMONITOR)
        MASK_LOWBATON           = LOWBAT_MASK ^ (1 << FLD_LOWBATON)
        MASK_LOWBATTRIM         = LOWBAT_MASK ^ (BITS_LOWBATTRIM << FLD_LOWBATTRIM)

    LISTEN1                     = $0D
    LISTEN2                     = $0E
    LISTEN3                     = $0F

    VERSION                     = $10

    PALEVEL                     = $11
    PALEVEL_MASK                = $FF
        FLD_PA0ON               = 7
        FLD_PA1ON               = 6
        FLD_PA2ON               = 5
        FLD_OUTPUTPOWER         = 0
        BITS_PA012              = %111
        BITS_OUTPUTPOWER        = %11111
        MASK_PA0ON              = PALEVEL_MASK ^ (1 << FLD_PA0ON)
        MASK_PA1ON              = PALEVEL_MASK ^ (1 << FLD_PA1ON)
        MASK_PA2ON              = PALEVEL_MASK ^ (1 << FLD_PA2ON)
        MASK_OUTPUTPOWER        = PALEVEL_MASK ^ (BITS_OUTPUTPOWER << FLD_OUTPUTPOWER)

    PARAMP                      = $12
    PARAMP_MASK                 = $0F
        FLD_PARAMP              = 0
        BITS_PARAMP             = %1111

    OCP                         = $13
    LNA                         = $18
    RXBW                        = $19
    AFCBW                       = $1A
    OOKPEAK                     = $1B
    OOKAVG                      = $1C
    OOKFIX                      = $1D
    AFCFEI                      = $1E
    AFCMSB                      = $1F
    AFCLSB                      = $20
    FEIMSB                      = $21
    FEILSB                      = $22
    RSSICONFIG                  = $23
    RSSIVALUE                   = $24
    DIOMAPPING1                 = $25
    DIOMAPPING2                 = $26
    IRQFLAGS1                   = $27
    IRQFLAGS2                   = $28
    RSSITHRESH                  = $29
    RXTIMEOUT1                  = $2A
    RXTIMEOUT2                  = $2B
    PREAMBLEMSB                 = $2C
    PREAMBLELSB                 = $2D
    SYNCCONFIG                  = $2E
    #$2F, SYNCVALUE1, SYNCVALUE2, SYNCVALUE3, SYNCVALUE4, SYNCVALUE5, SYNCVALUE6, SYNCVALUE7, SYNCVALUE8
    PACKETCONFIG1               = $37
    PAYLOADLENGTH               = $38
    NODEADRS                    = $39
    BROADCASTADRS               = $3A
    AUTOMODES                   = $3B
    FIFOTHRESH                  = $3C
    PACKETCONFIG2               = $3D
    #$3E, AESKEY1, AESKEY2, AESKEY3, AESKEY4, AESKEY5, AESKEY6, AESKEY7, AESKEY8, {
}         AESKEY9, AESKEY10, AESKEY11, AESKEY12, AESKEY13, AESKEY14, AESKEY15, AESKEY16
    TEMP1                       = $4E
    TEMP2                       = $4F
    TESTLNA                     = $58
    TESTTCXO                    = $59
    TESTLLBW                    = $5F
    TESTDAGC                    = $6F
    TESTAFC                     = $71

PUB Null
' This is not a top-level object
