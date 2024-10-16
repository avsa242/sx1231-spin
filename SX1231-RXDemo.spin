{
----------------------------------------------------------------------------------------------------
    Filename:       SX1231-RXDemo.spin
    Description:    Simple receive demo of the SX1231 driver
    Author:         Jesse Burt
    Started:        Dec 15, 2020
    Updated:        Oct 14, 2024
    Copyright (c) 2024 - See end of file for terms of use.
----------------------------------------------------------------------------------------------------
}

CON

    _clkmode = xtal1+pll16x
    _xinfreq = 5_000_000


OBJ

    ser:    "com.serial.terminal.ansi" | SER_BAUD=115_200
    time:   "time"
    sx1231: "wireless.transceiver.sx1231" | CS=0, SCK=1, MOSI=2, MISO=3, RST=4


VAR

    byte _buffer[radio.PAYLD_LEN_MAX]


PUB main() | sw[2], payld_len

    setup()
    ser.pos_xy(0, 3)
    ser.strln(@"Receive mode")

    radio.preset_rx4k8()                        ' 4800bps, use Automodes to
                                                ' handle transition between
                                                ' RX-sleep-RX opmodes

' -- TX/RX settings
    radio.carrier_freq(902_300_000)             ' US 902.3MHz
    radio.payld_len(8)                          ' test packet size
    payld_len := radio.payld_len()              ' read back from radio
    radio.fifo_thresh(payld_len-1)              ' trigger int at payld len-1
    radio.syncwd_len(8)                         ' syncword bytes 1..8 (set syncword accordingly)
    radio.set_syncwd( string($E7, $E7, $E7, $E7, $E7, $E7, $E7, $E7) )
' --

' -- RX-specific settings
    radio.rx_mode()

    ' change these if having difficulty with reception
    radio.lna_gain(0)                           ' -6, -12, -24, -26, -48 dB
                                                ' or LNA_AGC (0), LNA_HIGH (1)
    radio.rssi_int_thresh(-80)                  ' set rcvd signal level threshold
                                                '   considered a valid signal
                                                ' -127..0 (dBm)
' --

    repeat
        bytefill(@_buffer, 0, radio.PAYLD_LEN_MAX)
        ' if the FIFO fill level reaches the set threshold,
        '   read the payload in from the radio
        if ( radio.interrupt() & radio.INT_FIFO_THR )
            radio.rx_payld(payld_len, @_buffer)

        ' display the received payload on the terminal
        ser.pos_xy(0, 5)
        ser.hexdump(@_buffer, 0, 4, payld_len, 16 <# payld_len)
        repeat
        until (radio.opmode() == radio.OPMODE_SLEEP)


PUB setup()

    ser.start()
    time.msleep(30)
    ser.clear()
    ser.strln(@"Serial terminal started")

    if ( radio.start() )
        ser.strln(@"SX1231 driver started")
    else
        ser.strln(@"SX1231 driver failed to start - halting")
        repeat

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

