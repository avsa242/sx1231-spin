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
- [ ] Fix carrier frequency error
- [ ] Fix transmit power issues (-2dB is loud, -3dB barely received at the highest receiver gain settings)
- [ ] Verify reception from another unit
- [ ] Verify reception of an SX1231 transmission by a different, compatible unit

