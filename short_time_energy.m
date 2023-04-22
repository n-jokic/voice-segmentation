function En = short_time_energy(x, win, fs)
% x - voice signal
% win - window of length 1-3 * pitch period
% bartlett, blackman, hamming, hann, taylor
% fs - sampling frequency [Hz]
% Out: 
% En - short time energy
f_pitch = 150;
N = round(2.5*fs/f_pitch);

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

pad = zeros(N, 1);
x_temp = [pad; x];
temp_conv = conv(x_temp.^2, w.^2);
En = temp_conv(1+N : length(x) + N);


end

