clear all;
close all;
clc;

%rng(123);
fc = 50e3;      %Freq central em 50kHz
fa = 2.8*fc;    %freq amostragem
Rb = 1e3;      %taxa de bits
Tb = 1/Rb;
K = 4; % Qtde registradores de deslocamento
k = 7; % pode ser???
chips = 20*5;

info = randi([0 1], 1, k);      %gerando a informação
%info = [0 1 0 1 0 0 0];
for bit = 1:length(info)
   if(info(bit)==0)
        info(bit) = -1;
   end
end

info_BPSK =  repmat(info,chips,1);
info_BPSK =  reshape(info_BPSK,1,[]); %super amostragem na quantidade de chips

% Gerando o código pseudo-randômico e a portadora
d=round(rand(1,chips));
pn_code=[];
portadora=[];
t1=[0:2*pi/6:2*pi];                 % Creating 7 amostras for one cosine 
for k=1:chips
    if d(1,k)==0
        sig=-ones(1,7);
    else
        sig=ones(1,7);
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
tx_dsss = info_dsss .* portadora;   %informaçaõ espalhada e modulada

%Informações sobre o sinal e a portadora
% figure
% subplot(311)
% plot(t,info_BPSK,'linewidth',2);title('Informação BPSK');xlabel('Tempo [s]');
% ylabel('Amplitude [V]');ylim([-1.1 1.1]);grid minor;xlim([0 2.8e-4]);
% subplot(312)
% plot(t,c_t,'linewidth',2); title('Portadora');grid minor;ylim([-1.1 1.1]);xlim([0 2.8e-4]);
% xlabel('Tempo [s]'); ylabel('Amplitude');
% subplot(313)
% plot(t,s_t,'linewidth',2); title('Sinal modulado');grid minor;ylim([-1.1 1.1]);xlim([0 2.8e-4]);
% xlabel('Tempo [s]'); ylabel('Amplitude');


%sinais de informação, código pseudo-randômico, informação DSSS, e informação DSSS modulada 
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

f = [-fa/2:200:fa/2-1];
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


%demodular o sinal recebido, ignorando o canal
rx_dsss = tx_dsss;
info_rx = tx_dsss.*portadora;
rx_demodulado=[];
for i=1:700
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





