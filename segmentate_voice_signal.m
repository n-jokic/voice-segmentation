function segmentated = segmentate_voice_signal(y, win, fs, type, ITU, ITL, ITZCR)
% x - voice signal
% win - window of length 1-3 * pitch period
% bartlett, blackman, hamming, hann, taylor
% fs - sampling frequency [Hz]
% type - stEN, stTE
% Out: 
% segmentated - segmentated voice signal

f_pitch = 150; %[Hz]
N = round(2.5*fs/f_pitch);
alpha = 1;

t = (0 : 1 : (length(y)-1))/fs;
stZ = short_time_zcr(y, fs);

if strcmp(type, 'stEN')
    stE = short_time_energy(y, win, fs);
    y_lab = 'E(t)';
    t_e = t;
end

if strcmp(type, 'stTE')
    [stE, t_e] = short_time_tieger(y, win, fs, alpha);
    y_lab = 'TE(t)';
    N = round(length(t_e)/length(y)*N);
end

N1 = [];
N2 = [];
idx = 1;
for i = 2:length(stE)
    if stE(i-1) < ITU && stE(i) >= ITU
        N1(idx) = i;
    end

    if stE(i-1) > ITU && stE(i) <= ITU
        N2(idx) = i;
        idx = idx + 1;
    end
end

for i = 1 : length(N1)
    for j = 0 : N1(i) - 2
        if stE(N1(i) - j) > ITL && stE(N1(i) - j - 1) <= ITL
            N1(i) = N1(i) - j - 1;
            break;
        end
    end
end

for i = 1 : length(N2)
    for j = 0 : length(t_e) - N2(i) - 1
        if stE(N2(i) + j) > ITL && stE(N2(i) + j + 1) <= ITL
            N2(i) = N2(i) + j + 1;
            break;
        end
    end
end


figure(N);
    plot(t_e, stE);
        xlabel('t[s]');
        ylabel(y_lab);
        title('Segmentacija govornog signala');
    hold('on');
    p = plot(t_e, ones(length(stE), 1)*ITU, 'r--');
    q = plot(t_e, ones(length(stE), 1)*ITL, 'b--');   
    %hold('off');
    legend([p, q], {'ITU', 'ITL'}, 'Location', 'best');


    m = plot(t_e(N1), stE(N1), 'r*');
    n = plot(t_e(N2), stE(N2), 'b*');
    legend([p, q, m, n], {'ITU', 'ITL', '$N_1$', '$N_2$'}, 'Location', 'best');


    hold('off');

N1_final = [];
N2_final = [];
idx = 1;
for i = 1 : length(N1) - 1
    N1_final(idx) = N1(i);
    if N1(i + 1) ~= N1_final(idx)
        idx = idx + 1;
    end
end

if length(N1) > 1
    if N1(end) ~= N1_final(end)
        N1_final(end + 1) = N1(end);
    end
else 
    N1_final = N1;
end

idx = 1;
for i = 1 : length(N2) - 1
    N2_final(idx) = N2(i);
    if N2(i + 1) ~= N2_final(idx)
        idx = idx + 1;
    end
end

if length(N2) > 1
    if N2(end) ~= N2_final(end)
        N2_final(end + 1) = N2(end);
    end
else
    N2_final = N2;
end

N1_merged = [];
N2_merged = [];

i = 1;
lowest = 0;
highest = 0;
k = 0;
j = 0;

while i <= length(N1_final)
    N1_merged(i-k) = N1_final(i);
    N2_merged(i-k) = N2_final(i);
    
    if i < length(N1_final)
        if - t_e(N2_merged(i)) + t_e(N1_final(i+1)) < 0.1
            lowest = N1_final(i);
            highest = N2_final(i+1);

            j = 0;

            while true
                if i+1+j > length(N1_final)
                    break
                end
                if - t_e(N2_merged(i+j)) + t_e(N1_final(i+1+j))< 0.1*fs
                    highest = N2_final(i+1+j);
                else
                    break;
                end

                j = j + 1;
            end

            N1_merged(i) = lowest;
            N2_merged(i) = highest;
            k = k + j;


        end
    end

    i = i + 1 + j;
    j = 0;
end


lowest = 0;
for i = 1 : length(N1_merged)
    count = 0;
    for j = 0 : 25*N - 1

        idx = N1_merged(i) - j - 1;

        if idx < 1
            break;
        end

        if stZ(round(t_e(idx + 1)*fs)) > ITZCR && stZ(round(t_e(idx)*fs)) <= ITZCR
            lowest = idx;
            count = count + 1;
        end

    end

    if count >= 3
        N1_merged(i) = lowest;
    end
end

highest = 0;
for i = 1 : length(N2_merged)
    count = 0;
    for j = 0 : 25*N - 1

        idx = N2_merged(i) + j + 1;

        if idx > length(t_e)
            break;
        end

        if stZ(round(t_e(idx - 1)*fs)) > ITZCR && stZ(round(t_e(idx)*fs)) <= ITZCR
            highest= idx;
            count = count + 1;
        end
        

    end

    if count >= 3
        N2_merged(i) = highest;
    end
end






segmentated = {};
for i = 1 : length(N1_merged)
    segmentated{i} = y(round(t_e(N1_merged(i) + 1)*fs) : round(t_e(N2_merged(i) + 1)*fs));
end


figure(N);
    hold('on');
    r = plot(t_e(N1_merged), stE(N1_merged), 'ro');
    s = plot(t_e(N2_merged), stE(N2_merged), 'bo');
    legend([p, q, m, n, r, s], {'ITU', 'ITL', '$N_1$', '$N_2$', '$\hat{N}_1$', '$\hat{N}_2$'}, 'Location', 'best');
    hold ('off');

  



end

