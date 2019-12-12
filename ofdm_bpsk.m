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
M = 2; %ordem da modulação M = representa geração de bits %taxa de simbolo de entrada do canal
B = 20e6;
t_am = 0.1e-9; %Período de amostragem % O canal adotado será o canal ITU Vehicular-A, com as seguintes especificações:
doppler = 10;%fd   Frequência doppler % O canal adotado será o canal ITU Vehicular-A, com as seguintes especificações:
delay = [0 300 700 1100 1700 2500].*1e-9; %Espalhamento de atraso % O canal adotado será o canal ITU Vehicular-A, com as seguintes especificações:
ganho = [0 -1 -9 -10 -15 -20]; %Ganhos dos múltiplos percursosdb % O canal adotado será o canal ITU Vehicular-A, com as seguintes especificações:
 
%% gerando informação a ser transmitida
info = randi([0 1],num_sim-1,num_subs);% 22ofdm dados
info = [info; zeros(1,num_subs)]; %1 ofdm zeros limpar os registradores para o codigo conv

%% codigo conv
k = 7;
g0 = 133;
g1 = 171;
trelica = poly2trellis(k,[g0 g1]);
info_conv = convenc(info, trelica);

%% Modulando BPSK
info_mod = pskmod(info_conv,M); %utilizando uma função que faz a modulação PSK (modulação digital em fase)
%% preambulo LTS

LTS = [1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1,-1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 0,
    1, -1, -1, 1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, 1,1, -1, -1, 1,  -1, 1, -1, 1, 1, 1, 1];
LTS_IFFT = ifft(LTs);
LTS_T = [LTS_IFFT LTS_IFFT];
%% Modulando OFDM
piloto = [1,1,1,-1];
OFDM(:,(1:5)) = info_mod(1:5,:);
OFDM(:,6) = piloto(1);
OFDM(:,(7:19)) = info_mod(6:18,:);
OFDM(:,20) = piloto(2);
OFDM(:,21:26) = info_mod(19:24,:);
OFDM(:,27) = 0;
OFDM(:,28:33) = info_mod(25:30,:);
OFDM(:,34) = piloto(3);
OFDM(:,35:47) = info_mod(31:43,:);
OFDM(:,48) = piloto(4);
OFDM(:,49:53) = info_mod(44:48,:);
% adicionando prefixo ciclico
% reshape_info_mod = reshape(info_mod, [num_subs,length(info_mod)/num_subs]);   
% x_semPC = ifft(reshape_info_mod);
% auxx = x_semPC(num_subs - prefixo_ciclico + 1: end, :);
% x_comPC = [auxx; x_semPC];
% x = reshape(x_comPC, 1, []);
%  
% %% Transmitindo 
% canal_ray = rayleighchan(ts, doppler);% gerando o objeto que representa o canal
% canal_ray.StoreHistory = 1; % hablitando a gravação dos ganhos de canal
% sinal_rec_ray = filter(canal_ray, x); %esta função representa  o ato de transmitir um sinal modulado por um canal sem fio
% ganho_ray = canal_ray.PathGains; % salvando os ganhos do canal
%  
% for SNR = 0:40 %este loop representa a variação da SNR
%     sinal_rec_ray_awgn = awgn(sinal_rec_ray,SNR); % Modelando a inserção do ruido branco no sinal recebido
%     %% receptor
%     reshape_sinal_rx = reshape(sinal_rec_ray_awgn, (num_subs*2 + prefixo_ciclico), []);
%     y_semPC = reshape_sinal_rx((prefixo_ciclico + 1): end, :);
%     H = fft(ganho_ray.', num_subs*2);
%     Y = fft(y_semPC, num_subs*2);
%     auxy = Y ./ repmat(H, 1, size(Y, 2));
%     saida = reshape(auxy, 1, []);
%     %% rece
%     sinalEqRay = saida./ganho_ray; % (equalizando)eliminando os efeitos de rotação de fase e alteração de amplite no sinal recebido
%     sinalDemRay = pskdemod(sinalEqRay,M);% demodulando o sinal equalizado
%     [num_ray(SNR+1), taxa_ray(SNR+1)]  = symerr(info,sinalDemRay); % comparando a sequencia de informação gerada com a informação demodulada
% end
% % 
% semilogy([0:40],taxa_ray,'r',[0:40],taxa_ric,'b');
