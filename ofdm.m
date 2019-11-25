% Seja um sistema de comunicação OFDM. Considerando a especificação da camada física da
% norma IEEE 802.11, faça uma simulação desse sistema OFDM para obter a taxa de erro de bit de
% erro de símbolo OFDM e de erro de pacote transmitido, com relação à variação da relação sinal-
% ruído (SNR). Para isso, faça as seguintes considerações:
% A frequência de transmissão será 2,410 GHz.
% Largura de banda do canal: B = 20 MHz.
% A quantidade de símbolos OFDM de informação por pacote é de 23 símbolos.
% Será adotado o código convolucional com taxa de codificação r = 1 ⁄ 2 .
% As modulações consideradas serão: BPSK, QPSK e 16-QAM.
% Cada pacote transmitirá dois símbolos OFDM com a sequência de treinamento longa
% (LTS). A sequência de treinamento curta (STS) será desprezada.
% Não será necessário implementar o scrambler nem o interleaving.
% O ruído do canal será o AWGN, com a variação dada por: [0,40] dB.
% O canal adotado será o canal ITU Vehicular-A, com as seguintes especificações:
% o Período de amostragem: 100 ns.
% o Frequência doppler: 10 Hz.
% o Espalhamento de atraso: [0 100 300 700 1100 1700 2500] ns.
% o Ganhos dos múltiplos percursos: [0 -1 -9 -10 -15 -20] dB.
% O trabalho deverá ser implementado em Matlab. E deverá ser entregue o código
% implementado, juntamente com o relatório explicando a simulação realizada.