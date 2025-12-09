# Enhanced Arbiter PUF with Sparsity, 3-XOR Chaining & BCH Error Correction [![Paper](https://img.shields.io/badge/Paper-IEEE%20Blue-blue)] [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
> **An Arbiter PUF Design with Sparsity, XOR Chaining, and BCH Error Correction for Versatile Hardware Security Applications**  

This is to be implemented on Vivado 2022.2v. Make sure to use PYNQ-Z1 Board as the design target. 

The Split-CMA-ES model that was used to perform the attack on the enhanced APUF can be found at the following URL:
https://github.com/scluconn/DA_PUF_Library/tree/master

### Key Results (100,000 real hardware CRPs)
| Metric                        | Value                     |
|-----------------------------|---------------------------|
| Uniformity                  | **50.76%**                |
| Inter-device Uniqueness     | **≈50%**                  |
| Raw BER                     | 11.8%                     |
| After 7× Majority Voting    | **1.4%**                  |
| After BCH(31,16,3)           | **<1.4% → 98.6% reliability** |
| DNN (MLP) Attack Accuracy   | **≈49.5%** (random guess) |
| Split-CMA-ES Attack (1.8M queries) | **77.6%** max           |
| Resource Usage (PYNQ-Z1)    | **<1% LUTs, <1 mW**       |


## Features
- 50% **challenge sparsity** via fixed public 32×32 random matrix (`numpy.random.seed(42)`)
- **3-XOR chaining** of three 32-stage APUFs with deliberate delay offsets (0, 1, 2 ns)
- **7× temporal majority voting** + **BCH(31,16,3)** error correction (software, `galois` library)
- Code-offset **fuzzy extractor** for reliable key generation
- Full **Verilog + Vivado 2022.2 + PYNQ Jupyter** integration
- Resistant to classical DNNs and reliability-based evolutionary attacks


## Prediction accuracy of the state-of-the-art Split-CMA-ES attack
<img width="900" height="600" alt="520353795-7a2105d5-f413-4a7c-80c8-3d499e22ac52" src="https://github.com/user-attachments/assets/95ded101-83e4-4715-a8a2-f1addc5d4f4a" />




## Impact of Gaussian Noise (Base)
<img width="1713" height="1186" alt="image" src="https://github.com/user-attachments/assets/1e8737b8-dc99-4483-a54a-9f093691d1f9" />

The average BER stabilizes near 13%, with increased variance
at higher noise levels, highlighting the need for error correction mechanisms
such as BCH.

## Impact of Gaussian Noise (Enhanced)
<img width="2017" height="1186" alt="image" src="https://github.com/user-attachments/assets/8867b0f0-17d3-4eaf-90a6-2d1a0818d268" />

The average BER stabilizes near 6% with our enhancement features.


## Block Design as shown in Vivado 2022.2:
<img width="2356" height="889" alt="image" src="https://github.com/user-attachments/assets/ce2f06a6-e7a6-45b4-8d96-9b1bd50779ad" />



## Flowchart of the proposed APUF design:
<img width="1024" height="1536" alt="image" src="https://github.com/user-attachments/assets/26b178fc-ba00-4de3-9820-0f50acf90bb3" />



## RTL schematic of critical PUF modules (32 stages, 3 XOR instances).
<img width="1237" height="679" alt="image" src="https://github.com/user-attachments/assets/a2cc0d52-555f-4269-8869-0cd386bc7222" />


