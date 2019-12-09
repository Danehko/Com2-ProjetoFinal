clear all;
close all;
clc;

%rng(123);
fc = 50e3;      %Freq central em 50kHz
fa = 4*fc;    %freq amostragem
Rb = 1e3;      %taxa de bits
Tb = 1/Rb;
chips = 20*5;

% parametros codigo convolucional
K = 4; % Qtde registradores de deslocamento
k = 7; % pode ser???
L = k+K-1; % tamanho palavra codigo (com bits de limpeza)
g1 = str2num(dec2base(bin2dec('1010'),8));
g2 = str2num(dec2base(bin2dec('1001'),8));
EncTrellis = poly2trellis(K,[g1 g2]);
ini = 1;
fim = 1;

TamMsg = 7;
msg = randi([0 1], 1, TamMsg);      %gerando a informa��o
m = [msg zeros(1,K-1)]; % Mensagem + zeros de limpeza

%Informa��es sobre o sinal e a portadora
figure
plot(rectpulse(m, 1000),'linewidth',2);title('Informação Crua');xlabel('Samples [n]');
ylabel('Amplitude [V]');ylim([-0.1 1.1]);grid minor;

info = convenc(m,EncTrellis);

% info = [];
% for nmsg = 1:TamMsg
%     if nmsg == 1
%         ini = 1;
%         fim = L;
%         m = Mensagem(1,ini:fim);
%     else
%         ini = fim-K+2;
%         fim = ini+L-1;
%         m = Mensagem(1,ini:fim);
%     end
%     
%     % Code (pelo que eu entendi) contem cada palavra codigo gerada
%     Code = convenc(m,EncTrellis); % vai gerar a taxa 1/2
%     info = horzcat(info, Code);
%     
% end

%info = [0 1 0 1 0 0 0];
for bit = 1:length(info)
   if(info(bit)==0)
        info(bit) = -1;
   end
end

info_BPSK =  repmat(info,chips,1);
info_BPSK =  reshape(info_BPSK,1,[]); %super amostragem na quantidade de chips

% Gerando o c�digo pseudo-rand�mico e a portadora
d=round(rand(1,chips));
pn_code=[];
portadora=[];
t1=[0:2*pi/19:2*pi];                 % Creating 7 amostras for one cosine 
% t1=[0:2*pi/139:2*pi];                 % Creating 7 amostras for one cosine 
for k=1:chips
    if d(1,k)==0
        sig=-ones(1,2*L);
%         sig=-ones(1,TamMsg*2*L);
    else
        sig=ones(1,2*L);
%         sig=ones(1,TamMsg*2*L);
    end
    c=cos(t1);   
    portadora=[portadora c];        %portadora
    pn_code=[pn_code sig];
   
end

passo = (2*(length(info))/fc)/(length(info)*chips);
t = [0:passo:((2*length(info))/fc)-passo]; 
c_t = cos(2*pi*fc*t);               % portadora
s_t = c_t .* info_BPSK;             % portadora * informa��o

info_dsss = info_BPSK .* pn_code;   %informa��o espalhada
tx_dsss = info_dsss .* portadora;   %informa�a� espalhada e modulada


%sinais de informa��o, c�digo pseudo-rand�mico, informa��o DSSS, e informa��o DSSS modulada 
figure
subplot(421)
plot(t,info_BPSK,'linewidth',1); title('Sinal de informacao'); xlabel('Tempo [s]');
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
% f = [-fa/2:10:fa/2-1];
INFO_BPSK = fft(info_BPSK)/length(info_BPSK);
PN_CODE = fft(pn_code)/length(pn_code);
DSSS = fft(info_dsss)/length(info_dsss);
TX_DSSS = fft(tx_dsss)/length(tx_dsss);

subplot(422)
plot(f,fftshift(abs(INFO_BPSK)),'linewidth',1);title('Espectro do sinal de informacao');xlabel('Frequencia [Hz]');
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


for SNR = 0:40
    rx_dsss_awgn = awgn(tx_dsss, SNR);
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
    RX = fft(rx_desespalhado_awgn)/length(rx_desespalhado_awgn);

%     rx_awgn_down = downsample(rx_desespalhado_awgn, chips);
    rx_awgn_down = rx_desespalhado_awgn;
    rx_awgn_down(rx_awgn_down<0) = 0;
%     i = info;
    i = info_BPSK;
    i(i<0) = 0;
    [num(SNR+1), taxa(SNR+1)] = biterr(i, rx_awgn_down);
end

figure
semilogy([0:40],taxa,'b') 
title('Desempenho BER X SNR'); ylabel('BER');xlabel('SNR [dB]');


%demodular o sinal recebido, ignorando o canal
rx_dsss = tx_dsss;
info_rx = tx_dsss.*portadora;
rx_demodulado=[];
% for i=1:700
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

figure
subplot(411)
plot(t, rx_dsss,'linewidth',1); title('Sinal recebido'); xlabel('Tempo [s]');
ylabel('Amplitude [V]'); ylim([-1.1 1.1]);grid minor;xlim([0 2.8e-4]);
subplot(412)
plot(t, rx_demodulado,'linewidth',1); title('Sinal de demodulado'); xlabel('Tempo [s]');
ylabel('Amplitude [V]'); ylim([-1.1 1.1]);grid minor;xlim([0 2.8e-4]);
subplot(413)
plot(t, rx_desespalhado,'linewidth',1); title('Sinal de recuperado'); xlabel('Tempo [s]');
ylabel('Amplitude [V]'); ylim([-1.1 1.1]);grid minor;xlim([0 2.8e-4]);
subplot(414)
plot(f,fftshift(abs(RX)),'linewidth',1);title('Espectro RX');xlabel('Frequencia [Hz]');
xlim([-7e4 7e4]);grid minor;ylim([-0.1 0.5]);



rx_desespalhado(rx_desespalhado<0) = 0;
DecMsg = vitdec(rx_desespalhado, EncTrellis,1,'cont','hard');
figure
plot(rectpulse(DecMsg, 1000),'linewidth',2);title('Informação Crua');xlabel('Samples [n]');
ylabel('Amplitude [V]');ylim([-0.1 1.1]);grid minor;

% % decodificação do codigo convolucional
% nIteracao = 10^4;
% for nmsg = 1:TamMsg
%    for np =1:length(L+1)
%        for ni = 1:nIteracao
%            DecMsg = vitdec(rx,EncTrellis,1,'cont','hard');
%        end
%    end
% end

