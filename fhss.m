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
    up = upsample(info,upsamp);
    info_BPSK_cod = filter(filtro_nrz,1,up);
    bits_cod = length(hamm);
%% modulando e enviando
    duracao = bits_cod*Tb; 
    t = 0:T:duracao-T; 

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
    SNR = 40; % Definir nivel de sinal ruido
    
    sigEner = norm(sig_transm(:))^2; %ruido
    noiseEner = sigEner/(10^(SNR/10));        % energy of noise to be added
    noiseVar = noiseEner/(length(sig_transm(:)-1));     % variance of noise to be added
    noiseStd = sqrt(noiseVar);                   % std. deviation of noise to be added
    noise = noiseStd*randn(size(sig_transm));           % noise
    noisySig = sig_transm+noise;                        % noisy signal
    rec_sig = noisySig.*sig_por_chan.*port_fcentr; % por canal para cada freq e pela freq central

    aux = reshape(rec_sig,[upsamp,bits_cod]);
    correlator = sum(aux)./upsamp;
    info_cod = correlator > 0;
    %decodificando usando hamming(7,4)

    decod_info = decode(info_cod,n,k,'hamming/binary');
    
    verifica_informacao = isequal(decod_info,info_orig);
    
    if(verifica_informacao == 1)
    	display('Informacao recuperada com sucesso');
    else
        display('Informacao recuperada com erro');
    end


    %% Plots
    figure(1)
    
    %informação gerada no randi
    subplot(4,1,1);
    stem(info_orig);
    set(gca,'XTick',1:N,'XLim',[0.66 N+0.33]);    %Setting axis limits and scale for the graph
    title('Informação Original');
    ylabel('Amplitude(V)');
    xlabel('Ticks');

    %info transmitida
    subplot(4,1,2);
    plot(t,sig_transm);
    %set(gca,'XTick',0:t,'XLim',[0.66 N+0.33]);    %Setting axis limits and scale for the graph
    xlim([0 0.005])
    title('Parte da informação transmitida');
    ylabel('Amplitude(V)');
    xlabel('Tempo(s)');

    %codigo de canal
    subplot(4,1,3);
    plot(t,sig_por_chan);
    xlim([0 0.0008]);
    title('Código aleatório de canal ocupado');
    ylabel('Amplitude(V)');
    xlabel('Tempo(s)');

    
    subplot(4,1,4);
    stem(decod_info);
    set(gca,'XTick',1:N,'XLim',[0.66 N+0.33]);    %Setting axis limits and scale for the graph
    title('Informação Recuperada');
    ylabel('Amplitude(V)');
    xlabel('Ticks');
    
    %% Figura 2
    figure(2)
    %espectro do sinal transmitido
    subplot(2,1,1);
    plot(f,fftshift(abs(fft(sig_transm))));
    ylabel('Amplitude(V)');
    xlabel('Frequencia(Hz)');
    xlim([-4.5e5 4.5e5]);
    ylim([0 2e3]);
    title('Espectro do sinal transmitido');
    
    %espectro do sinal transmitido
    subplot(2,1,2);
    plot(f,fftshift(abs(fft(rec_sig))));
    ylabel('Amplitude(V)');
    xlabel('Frequencia(Hz)');
    xlim([-4.5e5 4.5e5]);
    ylim([0 2e3]);
    title('Espectro do sinal recuperado');
    
    %% SNR variante
    SNR_MAX = Nb;
    for SNR = 0:SNR_MAX
        %% https://www.mathworks.com/matlabcentral/fileexchange/62820-add-awgn-noise-to-signal
        sigEner = norm(sig_transm(:))^2;                    % energy of the signal
        noiseEner = sigEner/(10^(SNR/10));        % energy of noise to be added
        noiseVar = noiseEner/(length(sig_transm(:)-1));     % variance of noise to be added
        noiseStd = sqrt(noiseVar);                   % std. deviation of noise to be added
        noise = noiseStd*randn(size(sig_transm));           % noise
        noisySig = sig_transm+noise;                        % noisy signal
        aux = reshape(rec_sig,[upsamp,bits_cod]);
        correlator = sum(aux)./upsamp;
        info_cod = correlator > 0;
        decod_info = decode(info_cod,n,k,'hamming/binary');
        
        [n_err(SNR+1),tx_err(SNR+1)]=biterr(decod_info,info_orig);
        
end
        figure(3);
        semilogy([0:SNR_MAX],tx_err);
        title('BPSK - FHSS')
        ylabel('BER');xlabel('SNR[dB]');
    


    
