{
    --------------------------------------------
    Filename: SX1231-Test.spin
    Author: Jesse Burt
    Description: Test object for the SX1231 driver
    Copyright (c) 2020
    Started Apr 19, 2019
    Updated Mar 5, 2020
    See end of file for terms of use.
    --------------------------------------------
}

CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq

    LED         = cfg#LED1
    SER_RX      = 31
    SER_TX      = 30
    SER_BAUD    = 115_200

    MISO_PIN    = 11
    MOSI_PIN    = 10
    SCK_PIN     = 9
    CS_PIN      = 8

    COL_REG     = 0
    COL_SET     = COL_REG+20
    COL_READ    = COL_SET+20
    COL_PF      = COL_READ+18

OBJ

    cfg     : "core.con.boardcfg.flip"
    ser     : "com.serial.terminal.ansi"
    time    : "time"
    io      : "io"
    sx      : "wireless.transceiver.sx1231.spi"

VAR

    long _fails, _expanded
    byte _ser_cog, _row

PUB Main

    Setup

    _row := 2
'    _expanded := TRUE
    AFCAUTOON(1)
    AESON(1)
    AUTORESTARTRX(1)
    FIFOTHRESHOLD(1)
    TXSTARTCONDITION(1)
    EXITCONDITION(1)
    ENTERCONDITION(1)
    INTERMEDIATEMODE(1)
    BROADCASTADRS (1)
    NODEADRS (1)
    PACKETLEN (1)
    ADDRESSFILT (1)
    DCFREE_WHITE (1)
    DCFREE_MANCH (1)
    CRCON (1)
    SYNCTOL (1)
    SYNCON (1)
    SYNCSIZE (1)
    PREAMBLE (1)
    LNAGAINSELECT (1)
    LNAZIN (1)
    OCPTRIM (1)
    OCPON (1)
    PARAMP (1)
    OUTPUTPOWER (1)
    LOWBATTRIM (1)
    LOWBATON (1)
    AFCCTRL (1)
    OSC1 (1)
    FRF (1)
    FDEV (1)
    BITRATE (1)
    MODULATIONSHAPING (1)
    MODULATIONTYPE (1)
    DATAMODE (1)
    MODE (1)
    LISTENON (1)
    SEQUENCEROFF (1)
    FlashLED(LED, 100)

PUB AFCAUTOON(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from FALSE to TRUE
            sx.AFCAuto (tmp)
            read := sx.AFCAuto (-2)
            Message (string("AFCAUTOON"), tmp, read)

PUB AESON(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from FALSE to TRUE
            sx.Encryption (tmp)
            read := sx.Encryption (-2)
            Message (string("AESON"), tmp, read)


PUB AUTORESTARTRX(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from FALSE to TRUE
            sx.AutoRestartRX (tmp)
            read := sx.AutoRestartRX (-2)
            Message (string("AUTORESTARTRX"), tmp, read)

PUB FIFOTHRESHOLD(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 127
            sx.FIFOThreshold (tmp)
            read := sx.FIFOThreshold (-2)
            Message (string("FIFOTHRESHOLD"), tmp, read)

PUB TXSTARTCONDITION(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 1
            sx.TXStartCondition (tmp)
            read := sx.TXStartCondition (-2)
            Message (string("TXSTARTCONDITION"), tmp, read)

PUB EXITCONDITION(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 7
            sx.ExitCondition (tmp)
            read := sx.ExitCondition (-2)
            Message (string("EXITCONDITION"), tmp, read)

PUB ENTERCONDITION(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 7
            sx.EnterCondition (tmp)
            read := sx.EnterCondition (-2)
            Message (string("ENTERCONDITION"), tmp, read)


PUB INTERMEDIATEMODE(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 3
            sx.IntermediateMode (tmp)
            read := sx.IntermediateMode (-2)
            Message (string("INTERMEDIATEMODE"), tmp, read)

PUB BROADCASTADRS(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 255
            sx.BroadcastAddress (tmp)
            read := sx.BroadcastAddress (-2)
            Message (string("BROADCASTADRS"), tmp, read)

PUB NODEADRS(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 255
            sx.NodeAddress (tmp)
            read := sx.NodeAddress (-2)
            Message (string("NODEADRS"), tmp, read)

PUB PACKETLEN(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 255
            sx.PayloadLen (tmp)
            read := sx.PayloadLen (-2)
            Message (string("PACKETLEN"), tmp, read)

PUB ADDRESSFILT(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 2
            sx.AddressCheck (tmp)
            read := sx.AddressCheck (-2)
            Message (string("ADDRESSFILT"), tmp, read)

PUB DCFREE_WHITE(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from FALSE to TRUE
            sx.DataWhitening (tmp)
            read := sx.DataWhitening (-2)
            Message (string("DCFREE_WHITE"), tmp, read)

PUB DCFREE_MANCH(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from FALSE to TRUE
            sx.ManchesterEnc (tmp)
            read := sx.ManchesterEnc (-2)
            Message (string("DCFREE_MANCH"), tmp, read)

PUB CRCON(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from FALSE to TRUE
            sx.CRCCheckEnabled (tmp)
            read := sx.CRCCheckEnabled (-2)
            Message (string("CRCON"), tmp, read)

PUB SYNCTOL(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 7
            sx.SyncWordMaxBitErr (tmp)
            read := sx.SyncWordMaxBitErr (-2)
            Message (string("SYNCTOL"), tmp, read)

PUB SYNCON(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from FALSE to TRUE
            sx.SyncWordEnabled (tmp)
            read := sx.SyncWordEnabled (-2)
            Message (string("SYNCON"), tmp, read)

PUB SYNCSIZE(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 1 to 8
            sx.SyncWordLength (tmp)
            read := sx.SyncWordLength (-2)
            Message (string("SYNCSIZE"), tmp, read)

PUB PREAMBLE(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 65535 step 1024
            sx.PreambleLen (tmp)
            read := sx.PreambleLen (-2)
            Message (string("PREAMBLE"), tmp, read)

PUB LNAGAINSELECT(reps) | tmp, read

   _row++
    repeat reps
        repeat tmp from 1 to 6
            sx.LNAGain (lookup(tmp: sx#LNA_AGC, sx#LNA_HIGH, -6, -12, -24, -36, -48))
            read := sx.LNAGain (-2)
            Message (string("LNAGAINSELECT"), lookup(tmp: sx#LNA_AGC, sx#LNA_HIGH, -6, -12, -24, -36, -48), read)

PUB LNAZIN(reps) | tmp, read

   _row++
    repeat reps
        repeat tmp from 1 to 2
            sx.LNAZInput (lookup(tmp: 50, 200))
            read := sx.LNAZInput (-2)
            Message (string("LNAZIN"), lookup(tmp: 50, 200), read)

PUB OCPTRIM(reps) | tmp, read

   _row++
    repeat reps
        repeat tmp from 1 to 16
            sx.OCPCurrent (lookup(tmp: 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110, 115, 120))
            read := sx.OCPCurrent (-2)
            Message (string("OCPTRIM"), lookup(tmp: 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110, 115, 120), read)

PUB OCPON(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from FALSE to TRUE
            sx.OvercurrentProtection (tmp)
            read := sx.OvercurrentProtection (-2)
            Message (string("OCPON"), tmp, read)

PUB PARAMP(reps) | tmp, read

   _row++
    repeat reps
        repeat tmp from 1 to 16
            sx.RampTime (lookup(tmp: 3400, 2000, 1000, 500, 250, 125, 100, 62, 50, 40, 31, 25, 20, 15, 12, 10))
            read := sx.RampTime (-2)
            Message (string("PARAMP"), lookup(tmp: 3400, 2000, 1000, 500, 250, 125, 100, 62, 50, 40, 31, 25, 20, 15, 12, 10), read)

PUB OUTPUTPOWER(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from -18 to 13
            sx.TXPower (tmp)
            read := sx.TXPower (-100)
            Message (string("OUTPUTPOWER"), tmp, read)

PUB LOWBATTRIM(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 1 to 8
            sx.LowBattLevel (lookup(tmp: 1695, 1764, 1835, 1905, 1976, 2045, 2116, 2185))
            read := sx.LowBattLevel  (-2)
            Message (string("LOWBATTRIM"), lookup(tmp: 1695, 1764, 1835, 1905, 1976, 2045, 2116, 2185), read)

PUB LOWBATON(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from FALSE to TRUE
            sx.LowBattMon (tmp)
            read := sx.LowBattMon (-2)
            Message (string("LOWBATON"), tmp, read)

PUB AFCCTRL(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from sx#AFC_STANDARD to sx#AFC_IMPROVED
            sx.AFCMethod (tmp)
            read := sx.AFCMethod (-2)
            Message (string("AFCCTRL"), tmp, read)

PUB OSC1(reps) | tmp, read
' For now, ignore failures
    _row++
    repeat reps
        repeat tmp from 0 to -1
            sx.RCOscCal (tmp)
            read := sx.RCOscCal (-2)
            Message (string("OSC1"), tmp, read)

PUB FRF(reps) | tmp, read
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

PUB FDEV(reps) | tmp, read
' For now, ignore failures
    _row++
    repeat reps
        repeat tmp from 600 to 300_000 step 10000
            sx.FreqDeviation (tmp)
            read := sx.FreqDeviation (-2)
            Message (string("FDEV"), tmp, read)

PUB BITRATE(reps) | tmp, read
' For now, ignore failures past 9600bps
    _row++
    repeat reps
        repeat tmp from 1 to 9
            sx.DataRate (lookup(tmp: 1200, 2400, 4800, 9600, 19_200, 38_400, 76_800, 115_200, 300_000))
            read := sx.DataRate (-2)
            Message (string("BITRATE"), lookup(tmp: 1200, 2400, 4800, 9600, 19_200, 38_400, 76_800, 115_200, 300_000), read)

PUB MODULATIONSHAPING(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from sx#BT_NONE to sx#BT_0_3
            sx.GaussianFilter (tmp)
            read := sx.GaussianFilter (-2)
            Message (string("MODULATIONSHAPING"), tmp, read)

PUB MODULATIONTYPE(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from sx#MOD_FSK to sx#MOD_OOK
            sx.Modulation (tmp)
            read := sx.Modulation (-2)
            Message (string("MODULATIONTYPE"), tmp, read)

PUB DATAMODE(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from sx#DATAMODE_PACKET to sx#DATAMODE_CONT_WO_SYNC
            if tmp == %01   'Not a valid mode, skip it
                next
            sx.DataMode (tmp)
            read := sx.DataMode (-2)
            Message (string("DATAMODE"), tmp, read)

PUB MODE(reps) | tmp, read

    _row++
    sx.Sequencer (sx#OPMODE_MANUAL) ' Must first set sequencer to manual mode to switch operating modes
    time.MSleep (10)
    repeat reps
        repeat tmp from 0 to 4
            sx.OpMode (tmp)
            read := sx.OpMode (-2)
            Message (string("MODE"), tmp, read)
    sx.Sequencer (sx#OPMODE_AUTO)   ' Restore automatic sequencer mode

PUB LISTENON(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to -1
            sx.Listen (tmp)
            read := sx.Listen (-2)
            Message (string("LISTENON"), tmp, read)

PUB SEQUENCEROFF(reps) | tmp, read

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
            ser.str(string(ser#CR, ser#LF))
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
            ser.Str(string(ser#CR, ser#LF))
        OTHER:
            ser.Str (string("DEADBEEF"))

PUB PassFail(num)

    case num
        0: ser.Str (string("FAIL"))
        -1: ser.Str (string("PASS"))
        OTHER: ser.Str (string("???"))

PUB Setup

    repeat until _ser_cog := ser.StartRXTX (SER_RX, SER_TX, 0, SER_BAUD)
    time.MSleep(30)
    ser.Clear
    ser.Str(string("Serial terminal started", ser#CR, ser#LF))
    if sx.Start (CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN)
        ser.Str (string("SX1231 driver started", ser#CR, ser#LF))
    else
        ser.Str (string("SX1231 driver failed to start - halting", ser#CR, ser#LF))
        sx.Stop
        time.MSleep (5)
        ser.Stop
        FlashLED(LED, 500)

#include "lib.utility.spin"

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
