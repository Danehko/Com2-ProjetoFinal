% Seja um sistema de comunicação com espalhamento espectral por sequência direta (FHSS).
% Obtenha a taxa de erro de bit com relação à variação da relação sinal-ruído (SNR). Para isso, faça
% as seguintes considerações:
% Largura de banda de cada canal de informação: B i = (9 ± 0,5) kHz, considerando que
% há uma banda de guarda bilateral de 1 kHz, centrada na frequência do canal de 100 kHz.
% Considere que existem 11 canais de informação.
% Para cada bit de informação do sinal há 20 chip de espalhamento do sinal.
% Use o código de bloco de Hamming (7,4), para codificar a sequência de informação.
% Considere a modulação: BPSK.
% O ruído do canal será o AWGN, com a variação dada por: [0,40] dB.
% O trabalho deverá ser implementado em Matlab. E deverá ser entregue o código
% implementado, juntamente com o relatório explicando a simulação realizada.

clear all; close all; clc;

N = 20; %chips/bit
upsamp = N*75;
Nb = 4*10; %minimo 4

Rb = 1e3; % taxa de bit
Tb = 1/Rb; % tempo de bit
fa = Rb*upsamp; % Frequência de amostragem
T = 1/fa;  % Tempo de amostragem

fc = 100e3; %freq central

%%gerando info
info_orig = randi([0 1], 1,Nb);

%% Gera os canais e as frequencias dos mesmos
nchan = 11; %nro de canais
freqs_chan = [];
band_chan = 10e3; % Bilateral(9+-0.5)k -> 10kHz por canal
fi = 50e3; % freq inicial para canais
for i= 1:nchan %descobre a freq central de cada canal a partir da inicial fi
    freqs_chan(i) = (i-1)*band_chan + fi;
end
%% hamming(7,4)
    n = 7;
    k = 4;
    hamm = encode(info_orig,n,k,'hamming/binary'); % codificação precisa ser binaria ([0,1])
    
    info = hamm.*2 -1; %para transformar 0 em -1 e 1 em +1
    filtro_nrz = ones(1,upsamp);
    up = upsample(info,upsamp)
    info_BPSK_cod = filter(filtro_nrz,1,up);
    bits_cod = length(hamm);
%% modulando e enviando
    duracao = bits_cod*Tb; %gerar vetor de tempo e frequencia
    t = 0:T:duracao-T; % Vetor de tempo

    %vetor frequencia
    f = [-fa/2:fa/length(t):(fa/2)-1];
    port_fcentr = cos(2*pi*fc*t);
    %modulando em bpsk
    sig_mod_bpsk = info_BPSK_cod.*port_fcentr;
   
    %% 11 frequencias
    %sig_por_chan = pseudo_codigo(freqs_chan,N,bits_cod);
    %para 11 frequencias
    sig_por_chan = [];
    pseudo_fa = 5*freqs_chan(11);
    pseudo_T = [5*(1/freqs_chan(1))];
    passo = 1/pseudo_fa;
    pseudo_t = 0:passo:pseudo_T-passo;

    for r = 1:N
        var = randi([0 10],1,1); % seleciona um canal aleatorio
        switch(var)
            case(0)
                sig_por_chan = [sig_por_chan cos(2*pi*freqs_chan(1)*pseudo_t)];
                
            case(1)
                sig_por_chan = [sig_por_chan cos(2*pi*freqs_chan(2)*pseudo_t)];

            case(2)
               sig_por_chan = [sig_por_chan cos(2*pi*freqs_chan(3)*pseudo_t)];

            case(3)
               sig_por_chan = [sig_por_chan cos(2*pi*freqs_chan(4)*pseudo_t)];

            case(4)
               sig_por_chan = [sig_por_chan cos(2*pi*freqs_chan(5)*pseudo_t)];

            case(5)
               sig_por_chan = [sig_por_chan cos(2*pi*freqs_chan(6)*pseudo_t)];

            case(6)
               sig_por_chan = [sig_por_chan cos(2*pi*freqs_chan(7)*pseudo_t)];

            case(7)
               sig_por_chan = [sig_por_chan cos(2*pi*freqs_chan(8)*pseudo_t)];

            case(8)
               sig_por_chan = [sig_por_chan cos(2*pi*freqs_chan(9)*pseudo_t)];

            case(9)
               sig_por_chan = [sig_por_chan cos(2*pi*freqs_chan(10)*pseudo_t)];

            case(10)
               sig_por_chan = [sig_por_chan cos(2*pi*freqs_chan(11)*pseudo_t)];

        end

    end
    
    sig_por_chan = repmat(sig_por_chan,1,bits_cod); 
    sig_transm = sig_mod_bpsk.*sig_por_chan;
    
    %% Recebendo
    Eb = sum(sig_transm.^2)/bits_cod;
    SNR = 100;
    
    ruido_linear= Eb/10^((SNR)/10); %ruido
    ruido_gerado = randn(1,length(sig_transm)).*sqrt(ruido_linear/2);
    %adicionando ruido
    r_x = sig_transm + ruido_gerado;
    r_x = r_x.*sig_por_chan;
    r_x = r_x.*port_fcentr;
    limiar_decisao = (-1+1)/2;
    %correlator
    aux = reshape(r_x,[upsamp,bits_cod]);
    correlator = sum(aux)./upsamp;
    informacao_codificada = correlator > limiar_decisao;
    
    %decode hamming
    informacao_recuperada = decode(informacao_codificada,n,k,'hamming/binary');
    
    verifica_informacao = isequal(informacao_recuperada,info_orig);
    if(verifica_informacao == 1)
      msgbox('Informacao recuperada com sucesso');
    else
      msgbox('Informacao recuperada com erro');
    end
    
