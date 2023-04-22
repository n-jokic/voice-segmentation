function Zn = short_time_zcr(x, fs)
% x - voice signal
% fs - sampling frequency [Hz]
% Out: 
% Zn - short time zero crossing rate

f_pitch = 150; %[Hz]
N = round(10/1000*fs);



pad = zeros(N + 1, 1);
x_temp = [pad; x];
w = ones(N, 1);
temp_conv = conv(abs(sign([x_temp; 0]) - sign([0; x_temp])), w);
Zn = temp_conv(1 + N : length(x) + N);


end

