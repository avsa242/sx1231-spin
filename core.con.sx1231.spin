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
    DATAMODUL                   = $02
    BITRATEMSB                  = $03
    BITRATELSB                  = $04
    FDEVMSB                     = $05
    FDEVLSB                     = $06
    FRFMSB                      = $07
    FRFMID                      = $08
    FRFLSB                      = $09
    OSC1                        = $0A
    AFCCTRL                     = $0B
    LOWBAT                      = $0C
    LISTEN1                     = $0D
    LISTEN2                     = $0E
    LISTEN3                     = $0F
    VERSION                     = $10
    PALEVEL                     = $11
    PARAMP                      = $12
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
