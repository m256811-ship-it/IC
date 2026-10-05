function pairs = createTxRxPairs_ChannelModelingSlides( ...
    txPositions, rxPositions)
%CREATETXRXPAIRS_CHANNELMODELINGSLIDES
%
% Cria todas as combinacoes possíveis entre posições TX e RX.
%
% Cada linha de pairs contém:
%
% [txIndex rxIndex txX txY txZ rxX rxY rxZ]

Ntx = size(txPositions, 1);
Nrx = size(rxPositions, 1);

Npairs = Ntx * Nrx;

pairs = zeros(Npairs, 8);

counter = 1;

for iTx = 1:Ntx

    for iRx = 1:Nrx

        pairs(counter,:) = [ ...
            iTx, ...
            iRx, ...
            txPositions(iTx,:), ...
            rxPositions(iRx,:) ...
            ];

        counter = counter + 1;

    end

end

end