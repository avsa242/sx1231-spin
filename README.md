# sx1231-spin 
-------------

This is a P8X32A/Propeller driver object for the Semtech SX1231 UHF Transceiver (SPI)

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

* 1 extra core/cog for the PASM SPI driver

## Limitations

* Very early in development; may malfunction or outright fail to build

## TODO

- [x] Verify modulated transmission
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

