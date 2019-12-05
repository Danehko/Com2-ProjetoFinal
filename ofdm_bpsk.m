% Seja um sistema de comunicação OFDM. Considerando a especificação da camada física da
% norma IEEE 802.11, faça uma simulação desse sistema OFDM para obter a taxa de erro de bit de
% erro de símbolo OFDM e de erro de pacote transmitido, com relação à variação da relação sinal
% Cada pacote transmitirá dois símbolos OFDM com a sequência de treinamento longa
% (LTS). A sequência de treinamento curta (STS) será desprezada.
% Não será necessário implementar o scrambler nem o interleaving.
% O trabalho deverá ser implementado em Matlab. E deverá ser entregue o código
% implementado, juntamente com o relatório explicando a simulação realizada.
clear all
close all
clc

%% Parametros iniciais 
rs = 2.41e9; % taxa de simbolo da entrada do canal/taxa de transmissao / frequência de transmissão
ts = 1/rs; % tempo de simbolo
num_sim = 23; % numero de simbolos a ser transmitidos
num_subs = 24;
r = 0.5; % taxa codigo conv
t = [0:ts:num_sim/rs-(ts)]; 
M = 2; %ordem da modulação M = representa geração de bits %taxa de simbolo de entrada do canal
B = 20e6;
t_am = 0.1e-9; %Período de amostragem % O canal adotado será o canal ITU Vehicular-A, com as seguintes especificações:
doppler = 10;%fd   Frequência doppler % O canal adotado será o canal ITU Vehicular-A, com as seguintes especificações:
delay = [0 300 700 1100 1700 2500].*1e-9; %Espalhamento de atraso % O canal adotado será o canal ITU Vehicular-A, com as seguintes especificações:
ganho = [0 -1 -9 -10 -15 -20]; %Ganhos dos múltiplos percursosdb % O canal adotado será o canal ITU Vehicular-A, com as seguintes especificações:
 
%% gerando informação a ser transmitida
info = randi([0 1],num_sim,num_subs);

%% codigo conv
info_conv = info;

%% Modulando BPSK
info_mod = pskmod(info_conv,M); %utilizando uma função que faz a modulação PSK (modulação digital em fase)

%% Modulando OFDM
prefixo_ciclico = 16;
reshape_info_mod = reshape(info_tx, [48, length(info_tx)/48]);   
x_semPC = ifft(reshape_info_mod);
aux = x_semPC(48 - prefixo_ciclico + 1: end, :);
x_comPC = [aux; x_semPC];
x = reshape(x_comPC, 1, []);

%% Transmitindo 
canal_ray = rayleighchan(ts, doppler);% gerando o objeto que representa o canal
canal_ray.StoreHistory = 1; % hablitando a gravação dos ganhos de canal
sinal_rec_ray = filter(canal_ray, x); %esta função representa  o ato de transmitir um sinal modulado por um canal sem fio
ganho_ray = canal_ray.PathGains; % salvando os ganhos do canal

for SNR = 0:40 %este loop representa a variação da SNR
    sinal_rec_ray_awgn = awgn(sinal_rec_ray,SNR); % Modelando a inserção do ruido branco no sinal recebido
    sinalEqRay = sinal_rec_ray_awgn./ganho_ray; % (equalizando)eliminando os efeitos de rotação de fase e alteração de amplite no sinal recebido
    sinalDemRay = pskdemod(sinalEqRay,M);% demodulando o sinal equalizado
    %[num_ray(SNR+1), taxa_ray(SNR+1)]  = symerr(info,sinalDemRay); % comparando a sequencia de informação gerada com a informação demodulada
end

%semilogy([0:30],taxa_ray,'r',[0:30],taxa_ric,'b');
