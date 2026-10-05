function y = addAwgnFromEbNo(yClean, xTx, EbNo_dB)
% Adiciona ruído AWGN real com base em Eb/N0.
%
% Para OOK, usa-se a energia média transmitida por bit:
% Eb = E[x^2].
%
% Como o ruído é real, usa-se sigma^2 = N0/2.

EbNo = 10^(EbNo_dB/10);

Eb = mean(xTx.^2);

N0 = Eb/EbNo;
sigma2 = N0/2;

noise = sqrt(sigma2)*randn(size(yClean));

y = yClean + noise;

end