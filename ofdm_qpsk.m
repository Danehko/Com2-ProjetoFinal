clear all
close all
clc

%% Parametros iniciais 
rs = 2.41e9; % taxa de simbolo da entrada do canal/taxa de transmissao / frequ�ncia de transmissão
ts = 1/rs; % tempo de simbolo
num_sim = 23; % numero de simbolos a ser transmitidos
num_subs = 24; % numero de subsportadora
r = 0.5; % taxa codigo conv
t = [0:ts:num_sim/rs-(ts)]; 
M = 4; %ordem da modulação M = representa geração de bits %taxa de simbolo de entrada do canal
B = 20e6;
t_am = 0.1e-9; %Período de amostragem % O canal adotado será o canal ITU Vehicular-A, com as seguintes especificações:
doppler = 10;%fd   Frequência doppler % O canal adotado será o canal ITU Vehicular-A, com as seguintes especificações:
delay = [0 300 700 1100 1700 2500].*1e-9; %Espalhamento de atraso % O canal adotado será o canal ITU Vehicular-A, com as seguintes especificações:
ganho = [0 -1 -9 -10 -15 -20]; %Ganhos dos múltiplos percursosdb % O canal adotado será o canal ITU Vehicular-A, com as seguintes especificações:
 
%% gerando informação a ser transmitida
info = randi([0 1],1,(num_sim-1) * num_subs);% 22ofdm dados
info = [info zeros(1,num_subs)]; %1 ofdm zeros limpar os registradores para o codigo conv

%% codigo conv
k = 7;
g0 = 133;
g1 = 171;
trelica = poly2trellis(k,[g0 g1]);
info_convenc = convenc(info, trelica);

j = log2(M);
info_reshape = reshape(info_convenc, size(info_convenc,j)/j,j);
info_dec = bi2de(info_reshape,'left-msb');
info_conv = pskmod(info_dec,M);

%% Modulando BPSK
info_mod = pskmod(info_conv,M); %utilizando uma função que faz a modulação PSK (modulação digital em fase)
info_mod_reshape = reshape(info_mod, num_subs*2,[]);
tam_info_mod  = size(info_mod_reshape);
%% Modulando OFDM
piloto = [1,1,1,-1];
OFDM = zeros(64,tam_info_mod(2));
OFDM(1:6,:) = 0;
OFDM(7:11,:) = info_mod_reshape(1:5,:);
OFDM(12,:) = piloto(1);
OFDM(13:25,:) = info_mod_reshape(6:18,:);
OFDM(26,:) = piloto(2);
OFDM(27:32,:) = info_mod_reshape(19:24,:);
OFDM(33,:) = 0;
OFDM(34:39,:) = info_mod_reshape(25:30,:);
OFDM(40,:) = piloto(3);
OFDM(41:53,:) = info_mod_reshape(31:43,:);
OFDM(54,:) = piloto(4);
OFDM(55:59,:) = info_mod_reshape(44:48,:);
OFDM(60:64,:) = 0;

prefixo_ciclico = 16;

%% preambulo LTS
LTS = [0,0,0,0,0,0,1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1,-1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 0, 1, -1, -1, 1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, 1,1, -1, -1, 1,  -1, 1, -1, 1, 1, 1, 1,0,0,0,0,0];
LTS_IFFT = ifft(LTS);
aux2 = LTS_IFFT(64 - prefixo_ciclico + 1: end);
LTS_C_PC = [aux2 LTS_IFFT];
LTS_T = [LTS_C_PC LTS_C_PC];
%% add prefixo
reshape_OFDM = reshape(OFDM,64,[]);
OFDM_ifft = ifft(reshape_OFDM);
aux = OFDM_ifft(64 - prefixo_ciclico + 1: end, :);
x_comPC = [aux; OFDM_ifft];
x = reshape(x_comPC, 1, []);
tx = [LTS_T x];
 
for SNR = 0:40 %este loop representa a variação da SNR
    %% Canal/Transmitindo 
    canal_ray = rayleighchan(ts, doppler,delay,ganho);% gerando o objeto que representa o canal
    canal_ray.StoreHistory = 1; % hablitando a gravação dos ganhos de canal
    sinal_rec_ray = filter(canal_ray, tx); %esta função representa  o ato de transmitir um sinal modulado por um canal sem fio
    
    ganho_ray = canal_ray.PathGains; % salvando os ganhos do canal
    sinal_rec_ray_awgn = awgn(sinal_rec_ray,SNR); % Modelando a inserção do ruido branco no sinal recebido
    %% receptor
    reshape_sinal_rx = reshape(sinal_rec_ray_awgn, (80), []);
    y_semPC = reshape_sinal_rx((prefixo_ciclico + 1): end, :);
    LTS_REC = y_semPC(:,1:2);
    OFDM_REC = y_semPC(:,3:end);
    Y = fft(OFDM_REC, 64);%Y = fft(OFDM_REC);
    T = fft(ganho_ray(1,1:length(delay)), 64); 
    H =  repmat(T.', 1, size(Y, 2));
    auxy = Y ./ H;
    saida = reshape(auxy, 1, []);
    
    info_rec = [ Y(7:11,:); Y(13:25,:); Y(27:32,:); Y(34:39,:); Y(41:53,:); Y(55:59,:)];
    info_rec_demod = pskdemod(info_rec,M);
    info_rec_reshape = reshape(info_rec_demod,1,[]);
    aux3 = isequal(info_rec_reshape, info_conv);
    decod_info_rec = vitdec(info_rec_reshape,trelica,1,'cont','hard');
    aux4 = isequal(decod_info_rec(1,2:end-23), info(1,1:end-24));
   [num_ray(SNR+1), taxa_ray(SNR+1)]  = symerr(info(1,1:end-24),decod_info_rec(1,2:end-23)); % comparando a sequencia de informação gerada com a informação demodulada
end
% 
semilogy([0:40],taxa_ray,'r');