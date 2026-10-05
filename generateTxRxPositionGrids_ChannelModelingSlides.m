function [txPositions, rxPositions] = generateTxRxPositionGrids_ChannelModelingSlides(params)
%GENERATETXRXPOSITIONGRIDS_CHANNELMODELINGSLIDES
%
% Gera malhas de posições possíveis para TX no teto e RX no chão.
%
% Saidas:
%
%   txPositions : [Ntx x 3]
%       Cada linha representa uma posição [x y z] possível do TX.
%
%   rxPositions : [Nrx x 3]
%       Cada linha representa uma posição [x y z] possível do RX.
%
% A sala é centrada na origem:
%
%   x = [-lx/2, +lx/2]
%   y = [-ly/2, +ly/2]
%   z = [-lz/2, +lz/2]

lx = params.room(1);
ly = params.room(2);
lz = params.room(3);

%% ============================================================
%  Malha de posições do TX
% =============================================================

NxTx = params.txGridNx;
NyTx = params.txGridNy;

txMargin = params.txGridMargin;

xTx = linspace( ...
    -lx/2 + txMargin, ...
    lx/2 - txMargin, ...
    NxTx);

yTx = linspace( ...
    -ly/2 + txMargin, ...
    ly/2 - txMargin, ...
    NyTx);

[XTx, YTx] = meshgrid(xTx, yTx);

zTx = lz/2;

txPositions = [ ...
    XTx(:), ...
    YTx(:), ...
    zTx * ones(numel(XTx),1)];

%% ============================================================
%  Malha de posições do RX
% =============================================================

NxRx = params.rxGridNx;
NyRx = params.rxGridNy;

rxMargin = params.rxGridMargin;

xRx = linspace( ...
    -lx/2 + rxMargin, ...
    lx/2 - rxMargin, ...
    NxRx);

yRx = linspace( ...
    -ly/2 + rxMargin, ...
    ly/2 - rxMargin, ...
    NyRx);

[XRx, YRx] = meshgrid(xRx, yRx);

zRx = -lz/2;

rxPositions = [ ...
    XRx(:), ...
    YRx(:), ...
    zRx * ones(numel(XRx),1)];

end