clear all;
close all;
clc;


%% Parâmetros
fc = 50e3;                  % Freq central em 50kHz
fa = 4*fc;                  % Freq amostragem
Rb = 1e3;                   % Taxa de bits
Tb = 1/Rb;
chips = 20*5;

% Parâmetros codigo convolucional
K = 4;                      % Qtde registradores de deslocamento
k = 7;                      % Tamanho da informação
L = k+K-1;                  % Tamanho palavra codigo (com bits de limpeza)
SNR = [0:40];               % Vetor SNR

%% Codificação
g1 = str2num(dec2base(bin2dec('1010'),8));
g2 = str2num(dec2base(bin2dec('1001'),8));
EncTrellis = poly2trellis(K,[g1 g2]);
ini = 1;
fim = 1;
msg = randi([0 1], 1, k);   % Gerando a informação
m = [msg zeros(1,K-1)];     % Mensagem + zeros de limpeza

info = convenc(m,EncTrellis);

for bit = 1:length(info)
   if(info(bit)==0)
        info(bit) = -1;
   end
end

% Super amostragem na quantidade de chips
info_BPSK =  repmat(info,chips,1);
info_BPSK =  reshape(info_BPSK,1,[]); 

%% Gerando o código pseudo-randômico e a portadora
d=round(rand(1,chips));
pn_code=[]; portadora=[];
t1=[0:2*pi/19:2*pi];        % Criando amostras do cosseno 
for k=1:chips
    if d(1,k)==0
        sig=-ones(1,2*L);
    else
        sig=ones(1,2*L);
    end
    c=cos(t1);   
    portadora=[portadora c];        %portadora
    pn_code=[pn_code sig];
   
end

passo = (2*(length(info))/fc)/(length(info)*chips);
t = [0:passo:((2*length(info))/fc)-passo]; 
c_t = cos(2*pi*fc*t);               % portadora
s_t = c_t .* info_BPSK;             % portadora * informação

info_dsss = info_BPSK .* pn_code;   %informação espalhada
tx_dsss = info_dsss .* portadora;   %informação espalhada e modulada

figure('position', [20, 20, 800, 600])
plot(t,rectpulse(m, 200),'linewidth',2);title('Informação');xlabel('Samples [n]');
ylabel('Amplitude [V]');ylim([-0.1 1.1]);grid minor;

%sinais de informação, código pseudo-randômico, informação DSSS, e informação DSSS modulada 
figure('position', [20, 20, 800, 600])
subplot(421)
plot(t,info_BPSK,'linewidth',1); title('Sinal de informação'); xlabel('Tempo [s]');
ylabel('Amplitude [V]'); ylim([-1.1 1.1]);grid minor;xlim([0 2.8e-4]);
subplot(423)
plot(t,pn_code,'linewidth',1); title('Codigo de espalhamento'); ylabel('Amplitude [V]');
xlabel('Tempo [s]'); ylim([-1.1 1.1]);grid minor; xlim([0 2.8e-4]);
subplot(425)
plot(t,info_dsss,'linewidth',1); title('Sinal espalhado'); xlabel('Tempo [s]');
ylabel('Amplitude [V]'); ylim([-1.1 1.1]);grid minor; xlim([0 2.8e-4]);
subplot(427)
plot(t,tx_dsss,'linewidth',1); title('Sinal espalhado e modulado'); xlabel('Tempo [s]');
ylabel('Amplitude [V]'); ylim([-1.1 1.1]);grid minor; xlim([0 2.8e-4])

f = [-fa/2:100:fa/2-1];
INFO_BPSK = fft(info_BPSK)/length(info_BPSK);
PN_CODE = fft(pn_code)/length(pn_code);
DSSS = fft(info_dsss)/length(info_dsss);
TX_DSSS = fft(tx_dsss)/length(tx_dsss);

subplot(422)
plot(f,fftshift(abs(INFO_BPSK)),'linewidth',1);title('Espectro do sinal de informação');xlabel('Frequencia [Hz]');
xlim([-7e4 7e4]);grid minor;ylim([-0.1 0.5]);
subplot(424)
plot(f, fftshift(abs(PN_CODE)),'linewidth',1);title('Espectro do codigo de espalhamento');xlabel('Frequencia [Hz]');
xlim([-7e4 7e4]);grid minor;ylim([-0.1 0.25]);
subplot(426)
plot(f, fftshift(abs(DSSS)),'linewidth',1);title('Espectro do sinal espalhado');xlabel('Frequencia [Hz]');
xlim([-7e4 7e4]);grid minor;ylim([-0.1 0.25]);
subplot(428)
plot(f, fftshift(abs(TX_DSSS)),'linewidth',1);title('Espectro TX');xlabel('Frequencia [Hz]');
xlim([-7e4 7e4]);grid minor;ylim([-0.1 0.15]);

%% Variando o SNR

for snr = SNR
    for x = 0:100
        rx_dsss_awgn = awgn(tx_dsss, snr);
        info_rx_awgn = rx_dsss_awgn.*portadora;
        rx_demodulado_awgn = [];
        for i=1:2000
            if info_rx_awgn(i)>=0
            rxs = 1;
        else
            rxs = -1;
            end
            rx_demodulado_awgn = [rx_demodulado_awgn rxs];
        end
        rx_desespalhado_awgn = rx_demodulado_awgn.*pn_code;
        rx_desespalhado = downsample(rx_desespalhado_awgn, chips);
        rx_desespalhado(rx_desespalhado<0) = 0;
        DecMsg = vitdec(rx_desespalhado, EncTrellis,1,'cont','hard');
        DecMsg = [DecMsg(2:end), 0];
        num_erro_bit = sum(xor(m,DecMsg));
        erro(x+1) = num_erro_bit/length(m);
    end
    taxa(snr+1) = sum(erro(:))/100;
end

figure('position', [20, 20, 800, 600])
semilogy(SNR,vpa(taxa),'linewidth',2); grid minor;%ylim([10^-4 10^0]);
title('Desempenho BER X SNR'); ylabel('BER');xlabel('SNR [dB]');

%% Demodular o sinal recebido, ignorando o canal
rx_dsss = tx_dsss;
info_rx = tx_dsss.*portadora;
rx_demodulado=[];
for i=1:2000
    if info_rx(i)>=0
    rxs =1;
else
    rxs =-1;
    end
    rx_demodulado = [rx_demodulado rxs]; %demodulando o sinal;
end

rx_desespalhado = rx_demodulado.*pn_code; %desespalhando o sinal
RX = fft(rx_desespalhado)/length(rx_desespalhado);

figure('position', [20, 20, 800, 600])
subplot(411)
plot(t, rx_dsss,'linewidth',1); title('Sinal recebido'); xlabel('Tempo [s]');
ylabel('Amplitude [V]'); ylim([-1.1 1.1]);grid minor;xlim([0 2.8e-4]);
subplot(412)
plot(t, rx_demodulado,'linewidth',1); title('Sinal demodulado'); xlabel('Tempo [s]');
ylabel('Amplitude [V]'); ylim([-1.1 1.1]);grid minor;xlim([0 2.8e-4]);
subplot(413)
plot(t, rx_desespalhado,'linewidth',1); title('Sinal de recuperado'); xlabel('Tempo [s]');
ylabel('Amplitude [V]'); ylim([-1.1 1.1]);grid minor;xlim([0 2.8e-4]);
subplot(414)
plot(f,fftshift(abs(RX)),'linewidth',1);title('Espectro RX');xlabel('Frequencia [Hz]');
xlim([-7e4 7e4]);grid minor;ylim([-0.1 0.5]);

rx_desespalhado = downsample(rx_desespalhado, chips);
rx_desespalhado(rx_desespalhado<0) = 0;
DecMsg = vitdec(rx_desespalhado, EncTrellis,1,'cont','hard');
DecMsg = [DecMsg(2:end), 0];

figure('position', [20, 20, 800, 600])
plot(t,rectpulse(DecMsg, 200),'linewidth',2);title('Informação Recebida');xlabel('Segundos [s]');
ylabel('Amplitude [V]');ylim([-0.1 1.1]);grid minor;


