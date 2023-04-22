function [Te, T] = short_time_tieger(x, win, fs, alpha)
% x - voice signal
% win - window of length 1-3 * pitch period
% bartlett, blackman, hamming, hann, taylor
% fs - sampling frequency [Hz]
% Out: 
% Te- short time tieger energy
f_pitch = 150;
N = round(fs/f_pitch);

w = triang(N);
if strcmp(win, 'bartlett')
    w = bartlett(N);
end

if strcmp(win, 'blackman')
    w = blackman(N);
end

if strcmp(win, 'hamming')
    w = hamming(N);
end

if strcmp(win, 'hann')
    w = hann(N);
end

if strcmp(win, 'taylor')
    w = taylorwin(N);
end


figure()
    stem(w);
        xlabel('n')
        ylabel('w[n]')
        title("Prozorska funkcija : " + win)

[~,F,T,P] = spectrogram(x, w, round(0.5*N) , 1024, fs);
Te_temp = zeros(length(T), 1);
F = (F.^alpha)';

for i = 1 : length(Te_temp)
    Te_temp(i) = F*P(:, i)/length(F);
end



pad = zeros(N, 1);
Te_temp = [pad; Te_temp];
temp_conv = conv(Te_temp, ones(N, 1));
Te = temp_conv(1+N : length(T) + N);


end

