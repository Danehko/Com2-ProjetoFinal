clear all;
close all;
clc;

rng(123);
fc = 50e3;      %Freq central em 100kHz
fa = 2.8*fc;    %freq amostragem
Rb = 10e3;      %taxa de bits
Rc = 100e3;     % taxa de chips
Tb = 1/Rb;
Tc = 1/Rc;
%Nsamp_bits = 1000;
%Nsamp_chips = Nsamp_bits/10;
K = 4; % Qtde registradores de deslocamento
k = 7; % pode ser???
chips = 20*10;
%t = [0:1/fa:10*Tb-1/fa];


%info = randi([0 1], 1, k);
info = [0 1 0 1 0 1 0];
info_up = upsample(info, chips);
info_NRZ = filter(ones(1,chips),1,info_up)*2-1; %% BPSK

%pn code BPSK
pn_code = randi([0,1],1,length(info)*chips);
for bit = 1:length(pn_code)
   if(pn_code(bit)==0)
        pn_code(bit) = -1;
   end
end 

t = [0 : 1:(140*10)-1];
c_t = cos(2*pi*fc*t); %portadora

dsss = info_NRZ .* pn_code;
tx_dsss = dsss .* c_t;


% plot
figure
subplot(311)
plot(t, info_NRZ); title('Sinal de informacao'); xlabel('Tempo [s]', 'FontWeight', 'bold');
ylabel('Amplitude [V]', 'FontWeight', 'bold'); ylim([-1.1 1.1]);grid minor;
subplot(312)
plot(t, pn_code); title('Codigo de espalhamento'); ylabel('Amplitude [V]', 'FontWeight', 'bold');
xlabel('Tempo [s]', 'FontWeight', 'bold'); ylim([-1.1 1.1]);grid minor;
subplot(313)
plot(t, dsss); title('Sinal espalhado'); xlabel('Tempo [s]', 'FontWeight', 'bold');
ylabel('Amplitude [V]', 'FontWeight', 'bold'); ylim([-1.1 1.1]);grid minor;

f = [-fa/2:100:fa/2-1];
INFO_NRZ = fft(info_NRZ)/length(info_NRZ);
PN_CODE = fft(pn_code)/length(pn_code);
DSSS = fft(dsss)/length(dsss);
TX_DSSS = fft(tx_dsss)/length(tx_dsss);

figure
subplot(211)
plot(t, tx_dsss);title('Sinal modulado e espalhado');xlabel('Tempo [s]', 'FontWeight', 'bold');
ylabel('Amplitude [V]', 'FontWeight', 'bold');
subplot(212)
plot(f, fftshift(abs(TX_DSSS))); title('Espectro do sinal modulado e espalhado');
xlabel('Frequencia [Hz]', 'FontWeight', 'bold'); ylabel('Amplitude', 'FontWeight', 'bold');
xlim([-3e5 3e5]);

figure
subplot(311)
plot(f, fftshift(abs(INFO_NRZ)));title('Espectro do sinal de informacao');xlabel('Frequencia [Hz]', 'FontWeight', 'bold');
xlim([-1e5 1e5]);
subplot(312)
plot(f, fftshift(abs(PN_CODE)));title('Espectro do codigo de espalhamento');xlabel('Frequencia [Hz]', 'FontWeight', 'bold');
xlim([-1e5 1e5]);
subplot(313)
plot(f, fftshift(abs(DSSS)));title('Espectro do sinal espalhado');xlabel('Frequencia [Hz]', 'FontWeight', 'bold');
xlim([-1e5 1e5]);

%desespalhar
rx_dsss = tx_dsss .* c_t;
rx_dsssf = fir1(50,(0.2));

RX_DSSS = fft(rx_dsssf)/length(rx_dsssf);


figure
subplot(211)
plot(t, rx_dsssf);
subplot(212)
plot(f, fftshift(abs(RX_DSSS)));




