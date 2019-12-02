% Seja um sistema de comunicação com espalhamento espectral por sequência direta (DSSS).
% Obtenha a taxa de erro de bit com relação a  variação da relaçãoo sinal-ruído (SNR). Mostre as
% formas de onda dos sinais transmitidos e recuperados. Para isso, faça as seguintes considerações:
% 1 - A frequência de transmissãoo será 50 kHz.
% 2 - Considere a modulação: BPSK.
% 3 - Número de chips por bit de informação: N = 20.
% 4 - O ganho de processamento: G = 20.
% 5 - Use o código convolucional com taxa 1/2 , definido pelas matrizes geradoras: g 1 =
% [1 0 1 0] e g 2 = [1 0 0 1], para codificar a sequência de informação.
% 6 - O ruído do canal será o AWGN, com a variação dada por: [0,40] dB.
% 7 - Considere que haverá um sinal interferente somado ao sinal transmitido, que tem as
% mesmas características do sinal de informação.
% O trabalho deverá ser implementado em Matlab. E deverá ser entregue o código
% implementado, juntamente com o relatório explicando a simulação realizada.

close all;
clear all;
clc;

% Especificacoes
Bs = 50e3;
N_chips = 20;
G = 20;
B = Bs/G;
taxa = 1/2;
K = 4; % Qtde registradores de deslocamento
k = 7; % pode ser???
g1 = str2num(dec2base(bin2dec('1010'),8));
g2 = str2num(dec2base(bin2dec('1001'),8));
EncTrellis = poly2trellis(K,[g1 g2]);

% fator superamostragem
N_sup_chips = 100;
N_sup_bits = N_sup_chips * N_chips;

% Gera a mensagem a ser transmitida (baseado no codigo do professor)
L = k+K-1; % tamanho palavra codigo (com bits de limpeza)
ini = 1;
fim = 1;
TamMsg = 10;
msg = randi([0 1],1,TamMsg*k);
Mensagem = [msg zeros(1,K-1)]; % Mensagem + zeros de limpeza
info = [];
for nmsg = 1:TamMsg
    if nmsg == 1
        ini = 1;
        fim = L;
        m = Mensagem(1,ini:fim);
    else
        ini = fim-K+2;
        fim = ini+L-1;
        m = Mensagem(1,ini:fim);
    end
    
    % Code (pelo que eu entendi) contem cada palavra codigo gerada
    Code = convenc(m,EncTrellis); % vai gerar 20 bits por palavra (taxa 1/2)
    
    % Nesta variavel info acredito que teremos a sequencia de bits que
    % devemos transmitir
    info = horzcat(info, Code);  
end
% Aqui agora vamos transmitir a info gerada ...

% superamostragem da info
info_up = upsample(info, N_sup_bits);
info_NRZ = filter(ones(1,N_sup_bits),1,info_up)*2-1;


figure(1)
subplot(311)
plot(rectpulse(m,40000));ylim([-0.2 1.2]);grid minor;title('Info');
subplot(312)
%plot(info_NRZ);ylim([-1.2 1.2]);xlim([0 5e4]);grid minor;title('Info NRZ');


% gerando codigo de esplhamento... e assim ?
cod_esp = randi([0 1], 1, N_chips*length(info));
cod_esp_up = upsample(cod_esp, N_sup_chips);
cod_esp_NRZ = filter(ones(1,N_sup_chips),1,cod_esp_up)*2-1;

%subplot(313)
plot(cod_esp_NRZ);ylim([-1.2 1.2]);xlim([0 2e4]);grid minor;


% Espalhando o sinal no espectro... e isso mesmo?
sinal_esp = info_NRZ .* cod_esp_NRZ;

subplot(313)
plot(sinal_esp);ylim([-1.2 1.2]);xlim([0 2e4]);grid minor;

% Aqui acho que ja da pra transmitir (confirmar com o professor se o que foi
% feito acima esta correto). Alem disso, precisamos saber: 50 KHz e a frequencia da
% portadora ou a frequencia de banda do sinal (Bs) ? Se nao for a
% portadora, podemos utilizar qualquer uma? Outra duvida: utilizamos
% frequencia de amostragem? Precisa realmente fazer esse upsample, etc.. pq
% se tiver, vamos precisar amostar (frequencia de amostragem)


