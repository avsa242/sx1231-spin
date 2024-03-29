{
    --------------------------------------------
    Filename: SX1231-RXDemo.spin2
    Author: Jesse Burt
    Description: Simple receive demo of the SX1231 driver (P2 version)
    Copyright (c) 2022
    Started Dec 15, 2020
    Updated Nov 13, 2022
    See end of file for terms of use.
    --------------------------------------------
}
CON

    _clkmode        = cfg#_clkmode
    _xinfreq        = cfg#_xinfreq

' -- User-modifiable constants
    LED             = cfg#LED1
    SER_BAUD        = 115_200

    CS_PIN          = 0
    SCK_PIN         = 1
    MOSI_PIN        = 2
    MISO_PIN        = 3
    RESET_PIN       = 4                         ' use is recommended
                                                '   (-1 to disable)
' --

OBJ

    ser         : "com.serial.terminal.ansi"
    cfg         : "boardcfg.flip"
    time        : "time"
    sx1231      : "wireless.transceiver.sx1231"

VAR

    byte _buffer[256]

PUB main{} | sw[2], payld_len

    setup{}
    ser.pos_xy(0, 3)
    ser.strln(string("Receive mode"))
    sx1231.preset_rx4k8{}                       ' 4800bps, use Automodes to
                                                ' handle transition between
                                                ' RX-sleep-RX opmodes

' -- TX/RX settings
    sx1231.carrier_freq(902_300_000)            ' US 902.3MHz
    sx1231.payld_len(8)                         ' test packet size
    payld_len := sx1231.payld_len(-2)           ' read back from radio
    sx1231.fifo_thresh(payld_len-1)             ' trigger int at payld len-1
    sx1231.syncwd_len(8)                        ' syncword bytes 1..8 (set syncword accordingly)
    sx1231.set_syncwd(string($E7, $E7, $E7, $E7, $E7, $E7, $E7, $E7))
' --

' -- RX-specific settings
    sx1231.rx_mode{}

    ' change these if having difficulty with reception
    sx1231.lna_gain(0)                          ' -6, -12, -24, -26, -48 dB
                                                ' or LNA_AGC (0), LNA_HIGH (1)
    sx1231.rssi_int_thresh(-80)                 ' set rcvd signal level threshold
                                                '   considered a valid signal
                                                ' -127..0 (dBm)
' --

    repeat
        bytefill(@_buffer, 0, 256)              ' clear local RX buffer
        ' if the FIFO fill level reaches the set threshold,
        '   read the payload in from the radio
        if (sx1231.interrupt{} & sx1231#INT_FIFO_THR)
            sx1231.rx_payld(payld_len, @_buffer)
        ' display the received payload on the terminal
        ser.pos_xy(0, 5)
        ser.hexdump(@_buffer, 0, 4, payld_len, 16 <# payld_len)
        repeat until (sx1231.opmode(-2) == sx1231#OPMODE_SLEEP)

PUB setup{}

    ser.start(SER_BAUD)
    time.msleep(30)
    ser.clear{}
    ser.strln(string("Serial terminal started"))

    if sx1231.startx(CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN, RESET_PIN)
        ser.strln(string("SX1231 driver started"))
    else
        ser.strln(string("SX1231 driver failed to start - halting"))
        repeat

DAT
{
Copyright 2022 Jesse Burt

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

