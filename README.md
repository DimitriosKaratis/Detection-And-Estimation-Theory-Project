# EEG Denoising with Wiener Filter

This repository contains the implementation and analysis of a **Wiener Filter** for denoising EEG (Electroencephalogram) signals.  
The work was developed as part of the *Estimation and Detection Theory* course project at the **Department of Electrical and Computer Engineering, Aristotle University of Thessaloniki**.

--- 

## 📖 Project Overview

EEG signals are often corrupted by artifacts, such as **eye blinks**, which introduce noise in multiple channels.  
The goal of this project is to design and apply a **Wiener filter** that separates the clean EEG activity from the noise, using statistical estimation techniques.

The project is divided into the following main steps:

1. **Data Preparation**  
   - EEG training data (`train.mat`) includes both signals and blink indices.  
   - EEG test data (`test.mat`) contains only signals.  

2. **Covariance Estimation**  
   - Compute covariance matrices of clean EEG activity and blink-induced noise.  
   - Estimate the Wiener filter matrix:  

     $$
     W = R_{vv} (R_{vv} + R_{dd})^{-1}
     $$

3. **Filter Application**  
   - Apply the Wiener filter to both training and test EEG signals.  

4. **Performance Evaluation**  
   - Compute explained variance (signal retained) for training and test sets.  
   - Analyze per-channel estimation error variances.  

5. **Visualization**  
   - Plot original vs. filtered EEG signals for selected channels.  
   - Show bar plots of estimation error variances across channels.  
