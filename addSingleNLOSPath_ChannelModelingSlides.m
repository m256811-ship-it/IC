function h_vector = addSingleNLOSPath_ChannelModelingSlides( ...
    h_vector, params, TP1, RP, WP, dA, m, FOV,G_Con, wallAxis)

%ADDSINGLENLOSPATH_CHANNELMODELINGSLIDES
%
% Calcula a contribuição TX -> parede -> RX para um único patch WP.

%% TX -> WALL

D_tx_wall = sqrt(dot(TP1 - WP, TP1 - WP));

if D_tx_wall == 0
    return;
end

cos_phi_tx_wall = abs(WP(3) - TP1(3)) / D_tx_wall;

if wallAxis == "x"
    cos_alpha_wall = abs(TP1(1) - WP(1)) / D_tx_wall;
elseif wallAxis == "y"
    cos_alpha_wall = abs(TP1(2) - WP(2)) / D_tx_wall;
else
    error('wallAxis deve ser "x" ou "y".');
end


%% WALL -> RX

D_wall_rx = sqrt(dot(WP - RP, WP - RP));

if D_wall_rx == 0
    return;
end

if wallAxis == "x"
    cos_beta_wall = abs(WP(1) - RP(1)) / D_wall_rx;
elseif wallAxis == "y"
    cos_beta_wall = abs(WP(2) - RP(2)) / D_wall_rx;
end

cos_psi_wall_rx = abs(WP(3) - RP(3)) / D_wall_rx;

cos_psi_wall_rx = max(min(cos_psi_wall_rx, 1), -1);


%% FOV

if abs(acos(cos_psi_wall_rx)) <= FOV

    H_patch = (m+1)*params.Tsc * G_Con*params.Adet*params.rho*dA * ...
        (cos_phi_tx_wall^m) * ...
        cos_alpha_wall * ...
        cos_beta_wall * ...
        cos_psi_wall_rx / ...
        (2*pi^2 * D_tx_wall^2 * D_wall_rx^2);

    tau_NLOS = (D_tx_wall + D_wall_rx)/params.C;

    h_vector = addPathLinear_ChannelModelingSlides( ...
        h_vector, H_patch, tau_NLOS, params.delta_t_ns);

end

end