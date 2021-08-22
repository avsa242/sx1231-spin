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

* P1/SPIN1: OpenSpin (tested with 1.00.81), FlexSpin (tested with 6.0.0-beta)
* P2/SPIN2: FlexSpin (tested with 6.0.0-beta)
* ~~BST~~ (incompatible - no preprocessor)
* ~~Propeller Tool~~ (incompatible - no preprocessor)
* ~~PNut~~ (incompatible - no preprocessor)

## Limitations

* Very early in development; may malfunction or outright fail to build
* Because of the max length of the syncword supported by the chip (8 bytes/64bits), the API for SyncWord() currently breaks the standard, by providing two parameters

## TODO

- [x] Verify modulated transmission
- [x] Add some simple demos
- [x] Add support for reading RSSI
- [x] Add support for setting GPIO pin functions
- [x] Add support for reading the rest of the IRQ flags
- [x] Add support for setting RSSI threshold (carrier detect)
- [ ] Add support for PLL lock status
- [x] Add support for setting RX bandwidth
- [ ] Add support for setting freq by channel (emulated - use current channel bandwidth * channel number)
- [ ] Update API to current standard (wireless.transceiver API)

