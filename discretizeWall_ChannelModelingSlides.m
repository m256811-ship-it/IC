function surfaces = discretizeRoomSurfaces_ChannelModelingSlides(params)
%DISCRETIZEROOMSURFACES_CHANNELMODELINGSLIDES
%
% Divide as seis superficies da sala em patches retangulares.
%
% Cada superficie contem:
%   .name
%   .points   -> centros dos patches [Npatch x 3]
%   .normal   -> normal apontando para dentro da sala
%   .dA       -> area de cada patch
%
% A sala e centrada na origem:
%
%   x = [-lx/2, +lx/2]
%   y = [-ly/2, +ly/2]
%   z = [-lz/2, +lz/2]

    lx = params.room(1);
    ly = params.room(2);
    lz = params.room(3);

    %% Numero de patches por eixo

    ppm = params.patchesPerMeter;

    Nx = max(1, round(lx * ppm));
    Ny = max(1, round(ly * ppm));
    Nz = max(1, round(lz * ppm));

    %% Dimensoes dos patches

    dx = lx / Nx;
    dy = ly / Ny;
    dz = lz / Nz;

    %% Centros das celulas

    xCenters = -lx/2 + dx/2 : dx : lx/2 - dx/2;
    yCenters = -ly/2 + dy/2 : dy : ly/2 - dy/2;
    zCenters = -lz/2 + dz/2 : dz : lz/2 - dz/2;

    %% ============================================================
    %  Superficies x = constante
    % =============================================================

    [Y, Z] = meshgrid(yCenters, zCenters);

    % Parede x = -lx/2
    surfaces(1).name = "xMin";

    surfaces(1).points = [ ...
        -lx/2 * ones(numel(Y),1), ...
        Y(:), ...
        Z(:)];

    surfaces(1).normal = [1 0 0];

    surfaces(1).dA = dy * dz;

    % Parede x = +lx/2
    surfaces(2).name = "xMax";

    surfaces(2).points = [ ...
        lx/2 * ones(numel(Y),1), ...
        Y(:), ...
        Z(:)];

    surfaces(2).normal = [-1 0 0];

    surfaces(2).dA = dy * dz;

    %% ============================================================
    %  Superficies y = constante
    % =============================================================

    [X, Z] = meshgrid(xCenters, zCenters);

    % Parede y = -ly/2
    surfaces(3).name = "yMin";

    surfaces(3).points = [ ...
        X(:), ...
        -ly/2 * ones(numel(X),1), ...
        Z(:)];

    surfaces(3).normal = [0 1 0];

    surfaces(3).dA = dx * dz;

    % Parede y = +ly/2
    surfaces(4).name = "yMax";

    surfaces(4).points = [ ...
        X(:), ...
        ly/2 * ones(numel(X),1), ...
        Z(:)];

    surfaces(4).normal = [0 -1 0];

    surfaces(4).dA = dx * dz;

    %% ============================================================
    %  Superficies z = constante
    % =============================================================

    [X, Y] = meshgrid(xCenters, yCenters);

    % Chao: z = -lz/2
    surfaces(5).name = "floor";

    surfaces(5).points = [ ...
        X(:), ...
        Y(:), ...
        -lz/2 * ones(numel(X),1)];

    surfaces(5).normal = [0 0 1];

    surfaces(5).dA = dx * dy;

    % Teto: z = +lz/2
    surfaces(6).name = "ceiling";

    surfaces(6).points = [ ...
        X(:), ...
        Y(:), ...
        lz/2 * ones(numel(X),1)];

    surfaces(6).normal = [0 0 -1];

    surfaces(6).dA = dx * dy;

end