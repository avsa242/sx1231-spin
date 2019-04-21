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
    COL_SET     = 20
    COL_READ    = 40
    COL_PF      = 58

OBJ

    cfg     : "core.con.boardcfg.flip"
    ser     : "com.serial.terminal"
    time    : "time"
    sx      : "wireless.transceiver.sx1231.spi"

VAR

    long _fails, _expanded
    byte _ser_cog, _row

PUB Main

    Setup

    _row := 2
    Test_PARAMP (1)
    Test_OUTPUTPOWER (1)
    Test_LOWBATTRIM (1)
    Test_LOWBATON (1)
    Test_AFCCTRL (1)
    Test_OSC1 (1)
    Test_FRF (1)
    Test_FDEV (1)
    Test_BITRATE (1)
    Test_MODULATIONSHAPING (1)
    Test_MODULATIONTYPE (1)
    Test_DATAMODE (1)
    Test_MODE (1)
    Test_LISTENON (1)
    Test_SEQUENCEROFF (1)
    flash(cfg#LED1)

PUB Test_PARAMP(reps) | tmp, read

   _row++
    repeat reps
        repeat tmp from 1 to 16
            sx.RampTime (lookup(tmp: 3400, 2000, 1000, 500, 250, 125, 100, 62, 50, 40, 31, 25, 20, 15, 12, 10))
            read := sx.RampTime (-2)
            Message (string("PARAMP"), lookup(tmp: 3400, 2000, 1000, 500, 250, 125, 100, 62, 50, 40, 31, 25, 20, 15, 12, 10), read)

PUB Test_OUTPUTPOWER(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from -18 to 17
            sx.OutputPower (tmp)
            read := sx.OutputPower (-100)
            Message (string("OUTPUTPOWER"), tmp, read)

PUB Test_LOWBATTRIM(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 1 to 8
            sx.LowBattLevel (lookup(tmp: 1695, 1764, 1835, 1905, 1976, 2045, 2116, 2185))
            read := sx.LowBattLevel  (-2)
            Message (string("LOWBATTRIM"), lookup(tmp: 1695, 1764, 1835, 1905, 1976, 2045, 2116, 2185), read)

PUB Test_LOWBATON(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from FALSE to TRUE
            sx.LowBattMon (tmp)
            read := sx.LowBattMon (-2)
            Message (string("LOWBATON"), tmp, read)

PUB Test_AFCCTRL(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from sx#AFC_STANDARD to sx#AFC_IMPROVED
            sx.AFCMethod (tmp)
            read := sx.AFCMethod (-2)
            Message (string("AFCCTRL"), tmp, read)

PUB Test_OSC1(reps) | tmp, read
' For now, ignore failures
    _row++
    repeat reps
        repeat tmp from 0 to -1
            sx.RCOscCal (tmp)
            read := sx.RCOscCal (-2)
            Message (string("OSC1"), tmp, read)

PUB Test_FRF(reps) | tmp, read
' For now, ignore failures
' 290_000_000..340_000_000, 424_000_000..510_000_000, 862_000_000..1_020_000_000:
    _row++
    repeat reps
        repeat tmp from 290_000_000 to 340_000_000 step 10_000_000
            sx.CarrierFreq (tmp)
            read := sx.CarrierFreq (-2)
            Message (string("FRF"), tmp, read)

        repeat tmp from 424_000_000 to 510_000_000 step 10_000_000
            sx.CarrierFreq (tmp)
            read := sx.CarrierFreq (-2)
            Message (string("FRF"), tmp, read)

        repeat tmp from 862_000_000 to 1_020_000_000 step 10_000_000
            sx.CarrierFreq (tmp)
            read := sx.CarrierFreq (-2)
            Message (string("FRF"), tmp, read)

PUB Test_FDEV(reps) | tmp, read
' For now, ignore failures
    _row++
    repeat reps
        repeat tmp from 600 to 300_000 step 10000
            sx.Deviation (tmp)
            read := sx.Deviation (-2)
            Message (string("FDEV"), tmp, read)

PUB Test_BITRATE(reps) | tmp, read
' For now, ignore failures past 9600bps
    _row++
    repeat reps
        repeat tmp from 1 to 9
            sx.BitRate (lookup(tmp: 1200, 2400, 4800, 9600, 19_200, 38_400, 76_800, 115_200, 300_000))
            read := sx.BitRate (-2)
            Message (string("BITRATE"), lookup(tmp: 1200, 2400, 4800, 9600, 19_200, 38_400, 76_800, 115_200, 300_000), read)

PUB Test_MODULATIONSHAPING(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from sx#BT_NONE to sx#BT_0_3
            sx.GaussianFilter (tmp)
            read := sx.GaussianFilter (-2)
            Message (string("MODULATIONSHAPING"), tmp, read)

PUB Test_MODULATIONTYPE(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from sx#MOD_FSK to sx#MOD_OOK
            sx.Modulation (tmp)
            read := sx.Modulation (-2)
            Message (string("MODULATIONTYPE"), tmp, read)

PUB Test_DATAMODE(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from sx#DATAMODE_PACKET to sx#DATAMODE_CONT_WO_SYNC
            if tmp == %01   'Not a valid mode, skip it
                next
            sx.DataMode (tmp)
            read := sx.DataMode (-2)
            Message (string("DATAMODE"), tmp, read)

PUB Test_MODE(reps) | tmp, read

    _row++
    sx.Sequencer (sx#OPMODE_MANUAL) ' Must first set sequencer to manual mode to switch operating modes
    time.MSleep (10)
    repeat reps
        repeat tmp from 0 to 4
            sx.OpMode (tmp)
            read := sx.OpMode (-2)
            Message (string("MODE"), tmp, read)
    sx.Sequencer (sx#OPMODE_AUTO)   ' Restore automatic sequencer mode

PUB Test_LISTENON(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to -1
            sx.Listen (tmp)
            read := sx.Listen (-2)
            Message (string("LISTENON"), tmp, read)

PUB Test_SEQUENCEROFF(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 1
            sx.Sequencer (tmp)
            read := sx.Sequencer (-2)
            Message (string("SEQUENCEROFF"), tmp, read)

PUB Message(field, arg1, arg2)

    case _expanded
        TRUE:
            ser.PositionX (COL_REG)
            ser.Str (field)

            ser.PositionX (COL_SET)
            ser.Str (string("SET: "))
            ser.Dec (arg1)
            ser.Chars (32, 3)

            ser.PositionX (COL_READ)
            ser.Str (string("READ: "))
            ser.Dec (arg2)
            ser.Chars (32, 3)
            ser.PositionX (COL_PF)
            PassFail (arg1 == arg2)
            ser.NewLine

        FALSE:
            ser.Position (COL_REG, _row)
            ser.Str (field)

            ser.Position (COL_SET, _row)
            ser.Str (string("SET: "))
            ser.Dec (arg1)
            ser.Chars (32, 3)

            ser.Position (COL_READ, _row)
            ser.Str (string("READ: "))
            ser.Dec (arg2)
            ser.Chars (32, 3)

            ser.Position (COL_PF, _row)
            PassFail (arg1 == arg2)
            ser.NewLine
        OTHER:
            ser.Str (string("DEADBEEF"))

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
