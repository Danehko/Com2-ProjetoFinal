num_sim = 23; % numero de simbolos a ser transmitidos
num_subs = 24; % numero de subsportadora
M =  4;
info = randi([0 1],1,(num_sim-1) * num_subs);% 22ofdm dados
info = [info zeros(1,num_subs)]; %1 ofdm zeros limpar os registradores para o codigo conv
