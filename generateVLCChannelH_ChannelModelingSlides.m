function [hFIR, tFIR_ns] = generateVLCChannelH_ChannelModelingSlides(params, TP1, RP)
%GENERATEVLCCHANNELH_CHANNELMODELINGSLIDES
%
% Gera apenas o canal VLC discreto hFIR, baseado no código ChannelModelingSlides.mlx.
%
% Uso:
%
%   [hFIR, tFIR_ns] = generateVLCChannelH_ChannelModelingSlides(params, TP1, RP);
%
% Saídas:
%
%   hFIR
%       Canal discreto final usado no receptor neural:
%
%           y = filter(hFIR, 1, x);
%
%   tFIR_ns
%       Vetor de atrasos relativos associados aos taps de hFIR.
% Obs: aqui não consideramos uma grade de recepção, mas um ponto específico
%  definido por RP

    %% ============================================================
    %   Parâmetros derivados de parâmetros anteriores
    % =============================================================

    % Ordem Lambertiana do LED
    m = -log10(2)/log10(cosd(params.theta_deg));

    % Field of View em radianos
    FOV = deg2rad(params.FOV_deg);
    
    G_Con = (params.indexLens^2)/(sin(FOV)^2);

    % Tempo de símbolo usado para formar o canal discreto final.
    % Se não for definido, assume que cada tap corresponde à resolução física.
    if isfield(params, 'Tsym_ns')
        Tsym_ns = params.Tsym_ns;
    else
        Tsym_ns = params.delta_t_ns;
    end

    %% ============================================================
    %  Orientacao do transmissor e receptor
    % =============================================================

    nTx = orientationVectorRPY( ...
        params.txRoll_deg, ...
        params.txPitch_deg, ...
        params.txYaw_deg, ...
        params.n0Tx);

    nRx = orientationVectorRPY( ...
        params.rxRoll_deg, ...
        params.rxPitch_deg, ...
        params.rxYaw_deg, ...
        params.n0Rx);

    %% ============================================================
    %   Inicialização temporal do canal
    % =============================================================

    % Vetor de tempo físico, em ns.
    t_vector = 0:params.delta_t_ns:params.tMax_ns;

    % Resposta ao impulso 
    h_vector = zeros(1, length(t_vector));


    %% ============================================================
    %   Componente LOS
    % =============================================================

    if params.includeLOS

        % Vetor TX -> RX
        vTxRx = (RP - TP1).';
        
        % Distancia TX -> RX
        D1 = norm(vTxRx);

        if D1 == 0
            error('As posições de TX e RX não podem ser iguais.');
        end
        
        % Vetor unitario TX -> RX
        uTxRx = vTxRx / D1;

        %Calular \phi 
        cosphi = dot(nTx, uTxRx);
        phi = acos(cosphi);
        
        %Calcular \psi
        cospsi = dot(nRx, -uTxRx);
        psi = acos(cospsi);

        %Visualização de phi e psi em grau 
        phi_deg = acosd(cosphi);
        psi_deg = acosd(cospsi);

        fprintf('phi = %.2f deg | psi = %.2f deg\n', phi_deg, psi_deg);

        % Atraso LOS, em ns
        tau0 = D1/params.C;

        % Condição de FOV
        % O caminho so existe se:
        % 1. RX estiver na frente do LED
        % 2. TX estiver na frente do receptor
        % 3. sinal estiver dentro do FOV
        if cosphi > 0 && cospsi > 0 && psi <= FOV

            % Ganho do canal LOS
            H_LOS = (m+1) * params.Tsc * G_Con * params.Adet ...
      * cosphi.^m ...
      * cospsi ...
      / (2*pi*D1.^2);

            % Adiciona a contribuição LOS ao vetor h_vector
            h_vector = addPathLinear_ChannelModelingSlides( ...
            h_vector, H_LOS, tau0, params.delta_t_ns);

        end

    end


    %% ============================================================
    %  5. Componente NLOS - primeira reflexao
    % =============================================================

            if params.includeNLOS
                %Discretização das paredes 
                walls = discretizeReflectiveWalls_ChannelModelingSlides(params);

                for iWall = 1:length(walls)

                    wall = walls(iWall);

                    for iPatch = 1:size(wall.points, 1)

                        WP = wall.points(iPatch,:);

                        h_vector = addSingleNLOSPath_ChannelModelingSlides( ...
                            h_vector, ...
                            params, ...
                            TP1, ...
                            RP, ...
                            WP, ...
                            wall.normal, ...
                            wall.dA, ...
                            m, ...
                            FOV, ...
                            G_Con, ...
                            nTx, ...
                            nRx);

                    end

                end

            end

    %% ============================================================
    %   Corte dos zeros iniciais e finais
    % =============================================================

    [h_vector_trim, ~, ~] = trimImpulse_ChannelModelingSlides(h_vector, t_vector);


    %% ============================================================
    %   Conversão para canal discreto final
    % =============================================================

    samplesPerSymbol = round(Tsym_ns/params.delta_t_ns);

    if samplesPerSymbol < 1
        error('params.Tsym_ns deve ser maior ou igual a params.delta_t_ns.');
    end

    if abs(samplesPerSymbol*params.delta_t_ns - Tsym_ns) > 1e-9
        warning(['params.Tsym_ns não é múltiplo exato de params.delta_t_ns. ', ...
                 'A função usará samplesPerSymbol = %d.'], samplesPerSymbol);
    end

    h_before_norm = physicalToSymbol_ChannelModelingSlides( ...
        h_vector_trim, samplesPerSymbol);

    % Atraso relativo dos taps finais
    tFIR_ns = (0:length(h_before_norm)-1) * Tsym_ns;


    %% ============================================================
    %  Normalização
    % =============================================================

    switch string(params.normalize)

        case "none"

            hFIR = h_before_norm;

        case "sum"

            if sum(h_before_norm) > 0
                hFIR = h_before_norm/sum(h_before_norm);
            else
                hFIR = h_before_norm;
            end

        case "energy"

            if sum(h_before_norm.^2) > 0
                hFIR = h_before_norm/sqrt(sum(h_before_norm.^2));
            else
                hFIR = h_before_norm;
            end

        otherwise

            error('params.normalize deve ser "none", "sum" ou "energy".');

    end

end