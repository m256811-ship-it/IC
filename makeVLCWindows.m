
function [X, Y] = makeVLCWindows(y, bits, Lwin)
% Cria janelas de amostras recebidas para detectar cada bit.
%
% Para um canal FIR causal, a amostra y(n), y(n+1), ..., y(n+Lwin-1)
% contém informação sobre o bit transmitido em n.
%
% Entrada da rede:
% X(i,:) = [y(i), y(i+1), ..., y(i+Lwin-1)]
%
% Saída desejada:
% Y(i) = bit(i)

y = y(:);
bits = bits(:);

N = length(bits);
Nobs = N - Lwin + 1;

X = zeros(Nobs, Lwin);

for i = 1:Nobs
    X(i,:) = y(i:i+Lwin-1).';
end

Y = categorical(bits(1:Nobs));

end
