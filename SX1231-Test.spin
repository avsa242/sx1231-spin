{
    --------------------------------------------
    Filename: SX1231-Test.spin
    Author: Jesse Burt
    Description: Test object for the SX1231 driver
    Copyright (c) 2019
    Started Apr 19, 2019
    Updated Apr 19, 2019
    See end of file for terms of use.
    --------------------------------------------
}

CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq

    MISO_PIN    = 0
    MOSI_PIN    = 1
    SCK_PIN     = 2
    CS_PIN      = 3

    COL_REG     = 0
    COL_SET     = 16
    COL_READ    = 24
    COL_PF      = 40

OBJ

    cfg     : "core.con.boardcfg.flip"
    ser     : "com.serial.terminal"
    time    : "time"
    sx      : "wireless.transceiver.sx1231.spi"

VAR

    byte _ser_cog

PUB Main

    Setup

    Test_MODULATIONTYPE (1)
    Test_DATAMODE (1)
    Test_MODE (1)
    Test_LISTENON (1)
    Test_SEQUENCEROFF (1)
    flash(cfg#LED1)

PUB Test_MODULATIONTYPE(reps) | tmp, read

    repeat reps
        repeat tmp from sx#MOD_FSK to sx#MOD_OOK
            sx.Modulation (tmp)
            read := sx.Modulation (-2)
            Message (string("MODULATIONTYPE"), tmp, read)

PUB Test_DATAMODE(reps) | tmp, read

    repeat reps
        repeat tmp from sx#DATAMODE_PACKET to sx#DATAMODE_CONT_WO_SYNC
            if tmp == %01   'Not a valid mode, skip it
                next
            sx.DataMode (tmp)
            read := sx.DataMode (-2)
            Message (string("DATAMODE"), tmp, read)

PUB Test_MODE(reps) | tmp, read

    sx.Sequencer (sx#OPMODE_MANUAL) ' Must first set sequencer to manual mode to switch operating modes
    time.MSleep (10)
    repeat reps
        repeat tmp from 0 to 4
            sx.OpMode (tmp)
            read := sx.OpMode (-2)
            Message (string("MODE"), tmp, read)
    sx.Sequencer (sx#OPMODE_AUTO)   ' Restore automatic sequencer mode

PUB Test_LISTENON(reps) | tmp, read

    repeat reps
        repeat tmp from 0 to -1
            sx.Listen (tmp)
            read := sx.Listen (-2)
            Message (string("LISTENON"), tmp, read)

PUB Test_SEQUENCEROFF(reps) | tmp, read

    repeat reps
        repeat tmp from 0 to 1
            sx.Sequencer (tmp)
            read := sx.Sequencer (-2)
            Message (string("SEQUENCEROFF"), tmp, read)

PUB Message(field, arg1, arg2)

    ser.PositionX ( COL_REG)
    ser.Str (field)

    ser.PositionX ( COL_SET)
    ser.Str (string("SET: "))
    ser.Dec (arg1)

    ser.PositionX ( COL_READ)
    ser.Str (string("   READ: "))
    ser.Dec (arg2)

    ser.PositionX (COL_PF)
    PassFail (arg1 == arg2)
    ser.NewLine

PUB PassFail(num)

    case num
        0: ser.Str (string("FAIL"))
        -1: ser.Str (string("PASS"))
        OTHER: ser.Str (string("???"))

PUB Setup

    repeat until _ser_cog := ser.Start (115_200)
    ser.Clear
    ser.Str(string("Serial terminal started", ser#NL))
    if sx.Start (CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN)
        ser.Str (string("SX1231 driver started", ser#NL))
    else
        ser.Str (string("SX1231 driver failed to start - halting", ser#NL))
        sx.Stop
        time.MSleep (5)
        ser.Stop
        repeat

PRI flash(led_pin)

    dira[led_pin] := 1
    repeat
        !outa[led_pin]
        time.MSleep (100)

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
