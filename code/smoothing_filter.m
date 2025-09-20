%% Estimation and Detection Theory
% Wiener Filter for EEG Denoising
% Karatis Dimitrios 10775 

clear; clc; close all;

%% 1. Load Data
% Load training and test datasets.
% train.mat contains EEG signals (train_eeg) and blink time indices
% test.mat contains only EEG signals (test_eeg)
train_data = load('train.mat');
test_data = load('test.mat');

%% 2. Definitions
% Extract signal dimensions for training and testing
[N_train, T_train] = size(train_data.train_eeg);  
[N_test, T_test] = size(test_data.test_eeg);

% Create a binary mask marking time indices where artifacts (blinks) occur
artifact_mask = false(1, T_train);
artifact_mask(train_data.blinks) = true;

% Separate clean EEG signals (without blinks) and artifact segments
clean_data = train_data.train_eeg(:, ~artifact_mask);   % Clean brain activity (v)
artifact_data = train_data.train_eeg(:, artifact_mask); % Noise due to blinks (d)

%% 3. Covariance Matrix Estimation
% Estimate covariance matrix of clean EEG signals
Rvv = cov(clean_data');  

% Estimate covariance matrix of artifacts
Rdd = cov(artifact_data');  

% Compute Wiener smoothing matrix: W = Rvv * inv(Rvv + Rdd)
W = Rvv / (Rvv + Rdd);   % Size: 19x19

%% 4. Apply Filter to Training Data
% Apply Wiener filter to training data
v_denoised_train = W * train_data.train_eeg;  % 19xT

%% 4. Apply Filter to Test Data
% Apply Wiener filter to test data
v_denoised_test = W * test_data.test_eeg;  % 19xT

%% 4b. Estimation Error Calculation
% Compute estimation error matrix: M = (I - W) * Rvv
I = eye(size(W));
M = (I - W) * Rvv;

% Extract diagonal elements (per-channel estimation error variance)
error_variance = diag(M);  % 19x1

% Compute total Mean Squared Error (MSE)
total_MSE = trace(M);

% Compute total variance of original noisy training signal
total_noisy_var_train = trace(cov(train_data.train_eeg'));

% Compute percentage of signal retained (explained variance, train set)
percent_retained_train = 100 * (1 - total_MSE / total_noisy_var_train);
disp(['Explained variance of Wiener Filter (train): ', num2str(percent_retained_train), ' %']);

% Compute total variance of original noisy test signal
total_noisy_var_test = trace(cov(test_data.test_eeg'));

% Compute percentage of signal retained (explained variance, test set)
percent_retained_test = 100 * (1 - total_MSE / total_noisy_var_test);
disp(['Explained variance of Wiener Filter (test): ', num2str(percent_retained_test), ' %']);

%% 5. Define Time and Channel for Visualization
% Sampling frequency
fs = 400;      

% Generate time vectors
t_train = (0:T_train-1) / fs;
t_test = (0:T_test-1) / fs;

% Define time window for visualization (seconds)
t_start = 0;
t_end = 24;  

% Get time indices within selected window
time_indices = (t_test >= t_start) & (t_test <= t_end);

% Select channel for visualization
channel_to_plot = 19;

%% 6. Visualization
figure;

% Training data visualization
subplot(2,1,1);
plot(t_train, train_data.train_eeg(channel_to_plot, :), 'b', 'DisplayName', 'Noisy');
hold on;
plot(t_train, v_denoised_train(channel_to_plot, :), 'r', 'DisplayName', 'Filtered');
legend();
xlabel('Time (s)');
ylabel('Amplitude');
title(['Train - Channel ', num2str(channel_to_plot)]);

% Test data visualization
subplot(2,1,2);
plot(t_test(time_indices), test_data.test_eeg(channel_to_plot, time_indices), 'b', 'DisplayName', 'Noisy'); 
hold on;
plot(t_test(time_indices), v_denoised_test(channel_to_plot, time_indices), 'r', 'DisplayName', 'Filtered');
legend();
xlabel('Time (s)');
ylabel('Amplitude');
title(['Test - Channel ', num2str(channel_to_plot), ' (Time ', num2str(t_start), '–', num2str(t_end), 's)']);

sgtitle(['EEG Denoising with Wiener Filter — Channel ', num2str(channel_to_plot)]);

% Plot estimation error variance across channels
figure;
bar(error_variance, 'FaceColor', [0.2 0.4 0.6]);
xlabel('Channel Index');
ylabel('Estimation Error Variance');
title('Variance of Estimation Error after Wiener Smoothing');
grid on;

