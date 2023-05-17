# DPA: Delay Phased Array
Delay Phased Array - New programmable array with delays and phase shift to generate flexible frequency-dependent beams

```
We propose a new mmWave radio architecture called delay-phased
array (DPA) that improves efficient utilization of large bandwidth
and large antenna array at high mmWave frequencies by creating
flexible frequency-dependent multi-beams. DPA allows for flexible
division of system bandwidth into small bands and independent
radiation of each band in different chosen beam directions.
```

## Requirements
- MATLAB software (tested with v9.14 or R2023a, but should work with other versions)
- Doesn't require any MATLAB toolbox.

## Main code
- Run [main_dpa.m](main_dpa.m) to implement and plot a given flexible multi-beam pattern
- Play with parameters: Num antennas, system bandwidth, angles-per-beam, bandwidth-per-beam, number of beams etc
- Chnage other system parameters in [lib_fsda/get_fsda_param.m](lib_fsda/get_fsda_param.m)
- Change `algo_type` to `MATH` to plot beam patterns computed through maths formula for delays and phase values


## CIte our paper
mmFlexible: Flexible Directional Frequency Multiplexing for Multi-user mmWave Networks [[pdf]](https://wcsng.ucsd.edu/files/mmflexible.pdf)

Authors: Ish Kumar Jain, Rohith Reddy Vennam, Raghav Subbaraman, Dinesh Bharadia

Infocom 2023

