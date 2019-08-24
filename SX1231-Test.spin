{
    --------------------------------------------
    Filename: SX1231-Test.spin
    Author: Jesse Burt
    Description: Test object for the SX1231 driver
    Copyright (c) 2019
    Started Apr 19, 2019
    Updated Aug 23, 2019
    See end of file for terms of use.
    --------------------------------------------
}

CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq

    MISO_PIN    = 11
    MOSI_PIN    = 10
    SCK_PIN     = 9
    CS_PIN      = 8

    COL_REG     = 0
    COL_SET     = COL_REG+20
    COL_READ    = COL_SET+20
    COL_PF      = COL_READ+18

    LED         = cfg#LED1

OBJ

    cfg     : "core.con.boardcfg.flip"
    ser     : "com.serial.terminal.ansi"
    time    : "time"
    sx      : "wireless.transceiver.sx1231.spi"

VAR

    long _fails, _expanded
    byte _ser_cog, _row

PUB Main

    Setup

    _row := 2
'    _expanded := TRUE
    Test_AUTORESTARTRX(1)
    Test_FIFOTHRESHOLD(1)
    Test_TXSTARTCONDITION(1)
    Test_EXITCONDITION(1)
    Test_ENTERCONDITION(1)
    Test_INTERMEDIATEMODE(1)
    Test_BROADCASTADRS (1)
    Test_NODEADRS (1)
    Test_PACKETLEN (1)
    Test_ADDRESSFILT (1)
    Test_DCFREE_WHITE (1)
    Test_DCFREE_MANCH (1)
    Test_CRCON (1)
    Test_SYNCTOL (1)
    Test_SYNCON (1)
    Test_SYNCSIZE (1)
    Test_PREAMBLE (1)
    Test_LNAGAINSELECT (1)
    Test_LNAZIN (1)
    Test_OCPTRIM (1)
    Test_OCPON (1)
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
    flash(cfg#LED1, 100)

PUB Test_AUTORESTARTRX(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from FALSE to TRUE
            sx.AutoRestartRX (tmp)
            read := sx.AutoRestartRX (-2)
            Message (string("AUTORESTARTRX"), tmp, read)

PUB Test_FIFOTHRESHOLD(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 127
            sx.FIFOThreshold (tmp)
            read := sx.FIFOThreshold (-2)
            Message (string("FIFOTHRESHOLD"), tmp, read)

PUB Test_TXSTARTCONDITION(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 1
            sx.TXStartCondition (tmp)
            read := sx.TXStartCondition (-2)
            Message (string("TXSTARTCONDITION"), tmp, read)

PUB Test_EXITCONDITION(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 7
            sx.ExitCondition (tmp)
            read := sx.ExitCondition (-2)
            Message (string("EXITCONDITION"), tmp, read)

PUB Test_ENTERCONDITION(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 7
            sx.EnterCondition (tmp)
            read := sx.EnterCondition (-2)
            Message (string("ENTERCONDITION"), tmp, read)


PUB Test_INTERMEDIATEMODE(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 3
            sx.IntermediateMode (tmp)
            read := sx.IntermediateMode (-2)
            Message (string("INTERMEDIATEMODE"), tmp, read)

PUB Test_BROADCASTADRS(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 255
            sx.BroadcastAddress (tmp)
            read := sx.BroadcastAddress (-2)
            Message (string("BROADCASTADRS"), tmp, read)

PUB Test_NODEADRS(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 255
            sx.Address (tmp)
            read := sx.Address (-2)
            Message (string("NODEADRS"), tmp, read)

PUB Test_PACKETLEN(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 255
            sx.PacketLen (tmp)
            read := sx.PacketLen (-2)
            Message (string("PACKETLEN"), tmp, read)

PUB Test_ADDRESSFILT(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 2
            sx.AddressCheck (tmp)
            read := sx.AddressCheck (-2)
            Message (string("ADDRESSFILT"), tmp, read)

PUB Test_DCFREE_WHITE(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from FALSE to TRUE
            sx.DataWhitening (tmp)
            read := sx.DataWhitening (-2)
            Message (string("DCFREE_WHITE"), tmp, read)

PUB Test_DCFREE_MANCH(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from FALSE to TRUE
            sx.ManchesterEnc (tmp)
            read := sx.ManchesterEnc (-2)
            Message (string("DCFREE_MANCH"), tmp, read)

PUB Test_CRCON(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from FALSE to TRUE
            sx.CRCCheck (tmp)
            read := sx.CRCCheck (-2)
            Message (string("CRCON"), tmp, read)

PUB Test_SYNCTOL(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 7
            sx.SyncWordMaxBitErr (tmp)
            read := sx.SyncWordMaxBitErr (-2)
            Message (string("SYNCTOL"), tmp, read)

PUB Test_SYNCON(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from FALSE to TRUE
            sx.SyncWordEnabled (tmp)
            read := sx.SyncWordEnabled (-2)
            Message (string("SYNCON"), tmp, read)

PUB Test_SYNCSIZE(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 1 to 8
            sx.SyncWordLength (tmp)
            read := sx.SyncWordLength (-2)
            Message (string("SYNCSIZE"), tmp, read)

PUB Test_PREAMBLE(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 65535 step 1024
            sx.PreambleBytes (tmp)
            read := sx.PreambleBytes (-2)
            Message (string("PREAMBLE"), tmp, read)

PUB Test_LNAGAINSELECT(reps) | tmp, read

   _row++
    repeat reps
        repeat tmp from 1 to 6
            sx.Gain (lookup(tmp: sx#LNA_AGC, sx#LNA_HIGH, -6, -12, -24, -36, -48))
            read := sx.Gain (-2)
            Message (string("LNAGAINSELECT"), lookup(tmp: sx#LNA_AGC, sx#LNA_HIGH, -6, -12, -24, -36, -48), read)

PUB Test_LNAZIN(reps) | tmp, read

   _row++
    repeat reps
        repeat tmp from 1 to 2
            sx.LNAZInput (lookup(tmp: 50, 200))
            read := sx.LNAZInput (-2)
            Message (string("LNAZIN"), lookup(tmp: 50, 200), read)

PUB Test_OCPTRIM(reps) | tmp, read

   _row++
    repeat reps
        repeat tmp from 1 to 16
            sx.OCPCurrent (lookup(tmp: 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110, 115, 120))
            read := sx.OCPCurrent (-2)
            Message (string("OCPTRIM"), lookup(tmp: 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110, 115, 120), read)

PUB Test_OCPON(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from FALSE to TRUE
            sx.OvercurrentProtection (tmp)
            read := sx.OvercurrentProtection (-2)
            Message (string("OCPON"), tmp, read)

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
        repeat tmp from -18 to 13
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
'            ser.NewLine
            ser.str(string(10, 13))
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
'            ser.NewLine
            ser.Str(string(10, 13))
        OTHER:
            ser.Str (string("DEADBEEF"))

PUB PassFail(num)

    case num
        0: ser.Str (string("FAIL"))
        -1: ser.Str (string("PASS"))
        OTHER: ser.Str (string("???"))

PUB Setup

    repeat until _ser_cog := ser.Start (115_200)
    time.MSleep(500)
    ser.Clear
    ser.Str(string("Serial terminal started", 10, 13))'ser#NL))
    if sx.Start (CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN)
        ser.Str (string("SX1231 driver started", 10, 13))'ser#NL))
    else
        ser.Str (string("SX1231 driver failed to start - halting", 10, 13))'ser#NL))
        sx.Stop
        time.MSleep (5)
        ser.Stop
        Flash(LED, 500)

PRI Flash(led_pin, delay_ms)

    dira[led_pin] := 1
    repeat
        !outa[led_pin]
        time.MSleep (delay_ms)

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
