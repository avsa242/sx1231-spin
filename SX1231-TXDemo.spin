{
    --------------------------------------------
    Filename: SX1231-TXDemo.spin
    Author: Jesse Burt
    Description: Simple transmit demo of the SX1231 driver
    Copyright (c) 2022
    Started Dec 15, 2020
    Updated Aug 20, 2022
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
    RESET_PIN       = 12                        ' use is recommended
                                                '   (-1 to disable)
' --

OBJ

    ser   : "com.serial.terminal.ansi"
    cfg   : "core.con.boardcfg.flip"
    time  : "time"
    str   : "string"
    sx1231: "wireless.transceiver.sx1231"

VAR

    byte _buffer[256]

PUB Main{} | sw[2], count

    setup{}
    ser.position(0, 3)
    ser.strln(string("Transmit mode"))
    sx1231.preset_tx4k8{}                       ' 4800bps, use Automodes to
                                                ' handle transition between
                                                ' sleep-TX-sleep opmodes

' -- TX/RX settings
    sx1231.carrierfreq(902_300_000)             ' US 902.3MHz
    sx1231.payloadlen(8)                        ' test packet size
    sx1231.fifothreshold(sx1231.payloadlen(-2)-1)' trigger int at payld len-1
    sw[0] := $E7E7E7E7
    sw[1] := $E7E7E7E7
    sx1231.syncwordlength(8)                    ' 1..8
    sx1231.syncword(1, @sw)
' --

' -- TX-specific settings
    ' transmit power
    ' (-18..13 is routed to RFO pin, higher is routed to PABOOST pin)
    sx1231.txpower(13)                          ' -18..20dBm
' --

    count := 0
    repeat
        bytefill(@_buffer, 0, 256)              ' clear local TX buffer

        ' payload is the string 'TEST' with hexadecimal counter after
        str.sprintf1(@_buffer, string("TEST%04.4d"), count)
        sx1231.txpayload(8, @_buffer)           ' queue the data

        count++
        ser.position(0, 5)
        ser.str(string("Sending: "))
        ser.str(@_buffer)
        time.msleep(1000)                       ' wait in between packets
                                                ' (don't abuse the airwaves)

PUB Setup{}

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

