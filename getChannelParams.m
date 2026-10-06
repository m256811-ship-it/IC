function params = getChannelParams()
% GETCHANNELPARAMS
%
% Retorna os parametros relacionados ao modelo fisico do canal VLC,
% geometria da sala, orientacao dos dispositivos e definicao das grades
% de posicoes de TX e RX.

    %% ============================================================
    %  Parametros fisicos do canal VLC
    % =============================================================

    params.theta_deg = 70;

    params.P_total_mW = 20;

    params.FOV_deg = 90;

    params.Adet = 1e-4;

    params.indexLens = 1.5;

    params.Tsc = 1;

    params.room = [2 2 3];       % [lx ly lz] em metros

    params.rho = 0.8;

    params.C = 3e8 * 1e-9;       % velocidade da luz em m/ns


    %% ============================================================
    %  Discretizacao temporal do canal
    % =============================================================

    params.delta_t_ns = 0.5;

    params.tMax_ns = 40;

    params.Tsym_ns = params.delta_t_ns;


    %% ============================================================
    %  Discretizacao espacial das paredes refletoras
    % =============================================================

    params.patchesPerMeter = 5;


    %% ============================================================
    %  Orientacoes de referencia
    % =============================================================

    params.n0Tx = [0 0 -1];

    params.n0Rx = [0 0 1];


    %% ============================================================
    %  Orientacao do transmissor
    % =============================================================

    params.txRoll_deg = 0;

    params.txPitch_deg = 0;

    params.txYaw_deg = 0;


    %% ============================================================
    %  Orientacao do receptor
    % =============================================================

    params.rxRoll_deg = 0;

    params.rxPitch_deg = 0;

    params.rxYaw_deg = 0;


    %% ============================================================
    %  Composicao da resposta impulsiva
    % =============================================================

    params.includeLOS = true;

    params.includeNLOS = true;

    params.normalize = "sum";     % "sum", "energy" ou "none"


    %% ============================================================
    %  Grade de posicoes TX/RX
    % =============================================================

    % Numero de posicoes em cada direcao no teto
    params.txGridNx = 5;

    params.txGridNy = 5;

    % Numero de posicoes em cada direcao no plano do RX
    params.rxGridNx = 5;

    params.rxGridNy = 5;

    % Distancia minima das bordas da sala
    params.txGridMargin = 0.2;    % metros

    params.rxGridMargin = 0.2;    % metros


    %% ============================================================
    %  Posicoes de referencia
    % =============================================================

    lx = params.room(1);
    ly = params.room(2);
    lz = params.room(3);

    % Mantidos para facilitar acesso posterior
    params.lx = lx;
    params.ly = ly;
    params.lz = lz;

    % Posicao inicial/de referencia do TX
    params.TP = [0 0 lz/2];

    % Posicao inicial/de referencia do RX
    params.RP = [0 0 -lz/2];

end