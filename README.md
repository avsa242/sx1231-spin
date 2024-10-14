# sx1231-spin 
-------------

This is a P8X32A/Propeller driver object for the Semtech SX1231 UHF Transceiver (SPI)

**IMPORTANT**: This software is meant to be used with the [spin-standard-library](https://github.com/avsa242/spin-standard-library) (P8X32A) or [p2-spin-standard-library](https://github.com/avsa242/p2-spin-standard-library) (P2X8C4M64P). Please install the applicable library first before attempting to use this code, otherwise you will be missing several files required to build the project.


## Salient Features

* SPI connection at up to 1MHz (P1), 10MHz (P2)
* Set on-air bitrate
* Set carrier center freq
* Set carrier deviation freq
* Set modulation type
* Set transmit power
* Set number of preamble bytes
* Set packet length
* Set syncword (and length of)
* Enable and read on-chip low-battery status
* Address matching/filtering (including broadcast)
* CRC generation/checking
* Data whitening or Manchester encoding (untested)
* Encryption (untested)
* Configure GPIO (DIO0..5) functionality


## Requirements

P1/SPIN1:
* spin-standard-library
* 1 extra core/cog for the PASM SPI engine

P2/SPIN2:
* p2-spin-standard-library


## Compiler Compatibility

| Processor | Language | Compiler               | Backend      | Status                |
|-----------|----------|------------------------|--------------|-----------------------|
| P1        | SPIN1    | FlexSpin (6.9.4)       | Bytecode     | OK                    |
| P1        | SPIN1    | FlexSpin (6.9.4)       | Native/PASM  | OK                    |
| P2        | SPIN2    | FlexSpin (6.9.4)       | NuCode       | Untested              |
| P2        | SPIN2    | FlexSpin (6.9.4)       | Native/PASM2 | OK                    |

(other versions or toolchains not listed are __not supported__, and _may or may not_ work)


## Limitations

* TBD

