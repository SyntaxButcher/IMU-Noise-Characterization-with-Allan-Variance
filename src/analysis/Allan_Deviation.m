file = 'Allan_data.csv';

T = readmatrix(file);
sizeGyro = length(T(:,18));
GyroX = T(2:sizeGyro,18);
GyroY = T(2:sizeGyro,19);
GyroZ = T(2:sizeGyro,20);
AccX = T(2:sizeGyro,22);
AccY = T(2:sizeGyro,23);
AccZ = T(2:sizeGyro,24);

%time period
Fs = 40; %frequency
t0 = 1/Fs;

theta = cumsum(AccX, 1) * t0;

maxNumM = 100;
L = size(theta, 1);
maxM = 2.^floor(log2(L/2));
m = logspace(log10(1), log10(maxM), maxNumM).';
m = ceil(m); % m must be an integer.
m = unique(m); % Remove duplicates.

[avar, tau] = allanvar(AccX, m, 40);
adev = sqrt(avar);

% Find the index where the slope of the log-scaled Allan deviation is equal
% to the slope specified.
slope = -0.5;
logtau = log10(tau);
logadev = log10(adev);
dlogadev = diff(logadev) ./ diff(logtau);
[~, i] = min(abs(dlogadev - slope));

% Find the y-intercept of the line.
b = logadev(i) - slope*logtau(i);

% Determine the angle random walk coefficient from the line.
logN = slope*log(1) + b;
N = 10^logN

% Find the index where the slope of the log-scaled Allan deviation is equal
% to the slope specified.
slope = 0.5;
logtau = log10(tau);
logadev = log10(adev);
dlogadev = diff(logadev) ./ diff(logtau);
[~, i] = min(abs(dlogadev - slope));

% Find the y-intercept of the line.
b = logadev(i) - slope*logtau(i);

% Determine the rate random walk coefficient from the line.
logK = slope*log10(3) + b;
K = 10^logK

% Find the index where the slope of the log-scaled Allan deviation is equal
% to the slope specified.
slope = 0;
logtau = log10(tau);
logadev = log10(adev);
dlogadev = diff(logadev) ./ diff(logtau);
[~, i] = min(abs(dlogadev - slope));

% Find the y-intercept of the line.
b = logadev(i) - slope*logtau(i);

% Determine the bias instability coefficient from the line.
scfB = sqrt(2*log(2)/pi);
logB = b - log10(scfB);
B = 10^logB

tauN = 1;
lineN = N ./ sqrt(tau);
tauK = 3;
lineK = K .* sqrt(tau/3);
tauB = tau(i);
lineB = B * scfB * ones(size(tau));

tauParams = [tauN, tauK, tauB];
params = [N, K, scfB*B];
figure
loglog(tau, adev, tau, [lineN, lineK, lineB], '--', ...
    tauParams, params, 'o')
title('Allan Deviation of Linear Acceleration along X with Noise Parameters')
xlabel('\tau')
ylabel('\sigma(\tau)')
legend('$\sigma (m/s^2)$ Allan Deviation', '$\sigma_N ((m/s^2)/\sqrt{Hz})$ Velocity Random Walk', ...
    '$\sigma_K ((m/s^2)\sqrt{Hz})$ Rate Random Walk', '$\sigma_B (m/s^2)$ Constant Bias', 'Interpreter', 'latex')
text(tauParams, params, {'N', 'K', '0.664B'})
grid on
axis equal

%Storing and commenting the error values for tabulating

%GyroXN = N;
%GyroXK = K;
%GyroXB = B;

%GyroYN = N;
%GyroYK = K;
%GyroYB = B;

%GyroZN = N;
%GyroZK = K;
%GyroZB = B;

%AccXN = N;
%AccXK = K;
%AccXB = B;

%AccYN = N;
%AccYK = K;
%AccYB = B;

%AccZN = N;
%AccZK = K;
%AccZB = B;

%Tabulating

%{
Gyro_Axis = ["X";"Y";"Z"];
Angle_Random_Walk = [GyroXN;GyroYN;GyroZN];
in_DegreesPerHr = [GyroXN*((180)/(pi*sqrt(1/3600)));GyroYN*((180)/(pi*sqrt(1/3600)));GyroZN*((180)/(pi*sqrt(1/3600)))];
Rate_Random_Walk = [GyroXK;GyroYK;GyroZK];
Bias_Instability = [GyroXB;GyroYB;GyroZB];
in_DegreesPerHour = [GyroXB*((180*60*60)/(pi));GyroYB*((180*60*60)/(pi));GyroZB*((180*60*60)/(pi))];
GyroAllanTable = table(Gyro_Axis, Angle_Random_Walk,in_DegreesPerHr, Rate_Random_Walk, Bias_Instability, in_DegreesPerHour)
%}

%{
Accelerometer_Axis = ["X";"Y";"Z"];
Velocity_Random_Walk = [AccXN;AccYN;AccZN];
in_meterPerSecondPerRootHr = [AccXN/sqrt(1/3600);AccYN/sqrt(1/3600);AccZN/sqrt(1/3600)];
Rate_Random_Walk = [AccXK;AccYK;AccZK];
Constant_Bias = [AccXB;AccYB;AccZB];
in_mg = [AccXB*100;AccYB*100;AccZB*100];
GyroAllanTable = table(Accelerometer_Axis, Velocity_Random_Walk,in_meterPerSecondPerRootHr, Rate_Random_Walk, Constant_Bias, in_mg)
%}
