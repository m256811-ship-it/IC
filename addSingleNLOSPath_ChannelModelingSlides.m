function h_vector = addSingleNLOSPath_ChannelModelingSlides( ...
    h_vector, params, TP1, RP, WP, nPatch, dA, ...
    m, FOV, G_Con, nTx, nRx)
%ADDSINGLENLOSPATH_CHANNELMODELINGSLIDES
%
% Calcula a contribuicao de primeira reflexao:
%
%   TX -> patch -> RX
%
% usando geometria vetorial geral.

    %% Garantir vetores coluna

    TP1 = TP1(:);
    RP = RP(:);
    WP = WP(:);

    nTx = nTx(:);
    nRx = nRx(:);
    nPatch = nPatch(:);

    %% ============================================================
    %  TX -> PATCH
    % =============================================================

    vTxPatch = WP - TP1;

    D_tx_patch = norm(vTxPatch);

    if D_tx_patch == 0
        return;
    end

    uTxPatch = vTxPatch / D_tx_patch;

    %% Angulo de irradiacao do TX

    cos_phi = dot(nTx, uTxPatch);

    %% Angulo de incidencia no patch

    % Vetor visto pelo patch apontando para o TX
    cos_alpha = dot(nPatch, -uTxPatch);

    %% ============================================================
    %  PATCH -> RX
    % =============================================================

    vPatchRx = RP - WP;

    D_patch_rx = norm(vPatchRx);

    if D_patch_rx == 0
        return;
    end

    uPatchRx = vPatchRx / D_patch_rx;

    %% Angulo de saida/reflexao do patch

    cos_beta = dot(nPatch, uPatchRx);

    %% Angulo de incidencia no RX

    % Vetor visto pelo receptor apontando para o patch
    cos_psi = dot(nRx, -uPatchRx);

    %% ============================================================
    %  Protecao numerica
    % =============================================================

    cos_phi   = max(-1, min(1, cos_phi));
    cos_alpha = max(-1, min(1, cos_alpha));
    cos_beta  = max(-1, min(1, cos_beta));
    cos_psi   = max(-1, min(1, cos_psi));

    %% ============================================================
    %  Validacao geometrica
    % =============================================================

    % Todos os caminhos precisam estar no hemisferio fisicamente valido

    if cos_phi <= 0 || ...
       cos_alpha <= 0 || ...
       cos_beta <= 0 || ...
       cos_psi <= 0

        return;
    end

    %% ============================================================
    %  FOV do receptor
    % =============================================================

    psi = acos(cos_psi);

    if psi > FOV
        return;
    end

    %% ============================================================
    %  Ganho NLOS do patch
    % =============================================================

    H_patch = ...
        (m+1) * ...
        params.Tsc * ...
        G_Con * ...
        params.Adet * ...
        params.rho * ...
        dA * ...
        (cos_phi^m) * ...
        cos_alpha * ...
        cos_beta * ...
        cos_psi / ...
        (2*pi^2 * D_tx_patch^2 * D_patch_rx^2);

    %% ============================================================
    %  Atraso do caminho
    % =============================================================

    tau_NLOS = ...
        (D_tx_patch + D_patch_rx) / params.C;

    %% ============================================================
    %  Adicionar caminho a h(t)
    % =============================================================

    h_vector = addPathLinear_ChannelModelingSlides( ...
        h_vector, ...
        H_patch, ...
        tau_NLOS, ...
        params.delta_t_ns);

end