{
    --------------------------------------------
    Filename: wireless.transceiver.sx1231.spi.spin
    Author: Jesse Burt
    Description: Driver for the Semtech SX1231 UHF Transceiver IC
    Copyright (c) 2019
    Started Apr 19, 2019
    Updated Apr 19, 2019
    See end of file for terms of use.
    --------------------------------------------
}

CON

' Sequencer operating modes
    OPMODE_AUTO     = 0
    OPMODE_MANUAL   = 1

VAR

    byte _CS, _MOSI, _MISO, _SCK

OBJ

    spi : "SPI_Asm"                                             'PASM SPI Driver
    core: "core.con.sx1231"
    time: "time"                                                'Basic timing functions

PUB Null
''This is not a top-level object

PUB Start(CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN) : okay

    okay := Startx(CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN, core#CLK_DELAY, core#CPOL)

PUB Startx(CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN, SCK_DELAY, SCK_CPOL): okay
    if SCK_DELAY => 1 and lookdown(SCK_CPOL: 0, 1)
        if okay := spi.start (SCK_DELAY, SCK_CPOL)              'SPI Object Started?
            _CS := CS_PIN
            _MOSI := MOSI_PIN
            _MISO := MISO_PIN
            _SCK := SCK_PIN

            outa[_CS] := 1
            dira[_CS] := 1
            outa[_SCK] := 0
            dira[_SCK] := 1
            time.MSleep (10)                                     'Add startup delay appropriate to your device (consult its datasheet)

            case Version
                $21, $22, $23, $24:
                    return okay
                OTHER:
                    return FALSE


    return FALSE                                                'If we got here, something went wrong

PUB Listen(enabled) | tmp
' Enable listen mode
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value polls the chip and returns the current setting
'   NOTE: Should be enable when in standby mode
    readRegX (core#OPMODE, 1, @tmp)
    case ||enabled
        0, 1:
            enabled := (||enabled) << core#FLD_LISTENON
        OTHER:
            result := ((tmp >> core#FLD_LISTENON) & %1) * TRUE
            return result

    tmp &= core#MASK_LISTENON
    tmp := (tmp | enabled) & core#OPMODE_MASK
    writeRegX (core#OPMODE, 1, @tmp)

PUB Sequencer(mode) | tmp
' Control automatic sequencer
'   Valid values:
'       *OPMODE_AUTO (0): Automatic sequence, as selected by OperatingMode
'        OPMODE_MANUAL (1): Mode is forced
'   Any other value polls the chip and returns the current setting
    readRegX (core#OPMODE, 1, @tmp)
    case mode
        OPMODE_AUTO, OPMODE_MANUAL:
            mode := mode << core#FLD_SEQUENCEROFF
        OTHER:
            result := (tmp >> core#FLD_SEQUENCEROFF) & %1
            return result

    tmp &= core#MASK_SEQUENCEROFF
    tmp := (tmp | mode) & core#OPMODE_MASK
    writeRegX (core#OPMODE, 1, @tmp)

PUB Stop

    spi.stop

PUB Version
' Read silicon revision
'   Returns:
'       Value   Chip version
'       $21:    V2a
'       $22:    V2b
'       $23:    V2c
'       $24:    ???
    readRegX (core#VERSION, 1, @result)

PUB readRegX(reg, nr_bytes, buf_addr) | i
' Read nr_bytes from register 'reg' to address 'buf_addr'
    outa[_CS] := 0

    spi.SHIFTOUT(_MOSI, _SCK, core#MOSI_BITORDER, 8, reg)
    
    repeat i from 0 to nr_bytes-1
        byte[buf_addr][i] := spi.SHIFTIN(_MISO, _SCK, core#MISO_BITORDER, 8)

    outa[_CS] := 1

PUB writeRegX(reg, nr_bytes, buf_addr) | i
' Write nr_bytes to register 'reg' stored in val

    outa[_CS] := 0

    spi.SHIFTOUT(_MOSI, _SCK, core#MOSI_BITORDER, 8, reg|core#W)

    repeat i from 0 to nr_bytes-1
        spi.SHIFTOUT(_MOSI, _SCK, core#MOSI_BITORDER, 8, byte[buf_addr][i])

    outa[_CS] := 1

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
