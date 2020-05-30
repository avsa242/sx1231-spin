# sx1231-spin 
-------------

This is a P8X32A/Propeller driver object for the Semtech SX1231 UHF Transceiver (SPI)

**IMPORTANT**: This software is meant to be used with the [spin-standard-library](https://github.com/avsa242/spin-standard-library) (P8X32A) or [p2-spin-standard-library](https://github.com/avsa242/p2-spin-standard-library) (P2X8C4M64P). Please install the applicable library first before attempting to use this code, otherwise you will be missing several files required to build the project.

## Salient Features

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
* Data whitening or Manchester encoding
* Encryption

## Requirements

P1/SPIN1:
* spin-standard-library
* 1 extra core/cog for the PASM SPI driver

P2/SPIN2:
* p2-spin-standard-library

## Compiler Compatibility

* P1/SPIN1: OpenSpin (tested with 1.00.81)
* P2/SPIN2: FastSpin (tested with 4.1.10-beta)
* ~~BST~~ (incompatible - no preprocessor)
* ~~Propeller Tool~~ (incompatible - no preprocessor)
* ~~PNut~~ (incompatible - no preprocessor)

## Limitations

* Very early in development; may malfunction or outright fail to build

## TODO

- [x] Verify modulated transmission
- [ ] Add some simple demos
- [ ] Add support for reading RSSI
- [ ] Add support for setting GPIO pin functions
- [ ] Add support for reading the rest of the IRQ flags
- [ ] Add support for setting RSSI threshold (carrier detect)
- [ ] Add support for PLL lock status
- [ ] Add support for setting RX bandwidth
- [ ] Add support for setting freq by channel (emulated - use current channel bandwidth * channel number)
- [ ] Update API to current standard (wireless.transceiver API)
- [ ] Fix carrier frequency error
- [ ] Fix transmit power issues (-2dB is loud, -3dB barely received at the highest receiver gain settings)
- [ ] Verify reception from another SX1231 unit
- [ ] Verify reception of an SX1231 transmission by a different, compatible unit (e.g., CC1101)

