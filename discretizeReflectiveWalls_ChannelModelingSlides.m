function walls = discretizeReflectiveWalls_ChannelModelingSlides(params)
%DISCRETIZEREFLECTIVEWALLS_CHANNELMODELINGSLIDES
%
% Divide as quatro paredes laterais da sala em patches.
%
% A sala e centrada na origem:
%
%   x = [-lx/2, +lx/2]
%   y = [-ly/2, +ly/2]
%   z = [-lz/2, +lz/2]

lx = params.room(1);
ly = params.room(2);
lz = params.room(3);

%% Numero de patches

ppm = params.patchesPerMeter;

Nx = max(1, round(lx * ppm));
Ny = max(1, round(ly * ppm));
Nz = max(1, round(lz * ppm));

%% Dimensoes dos patches

dx = lx / Nx;
dy = ly / Ny;
dz = lz / Nz;

%% Centros dos patches

xCenters = -lx/2 + ((1:Nx) - 0.5) * dx;
yCenters = -ly/2 + ((1:Ny) - 0.5) * dy;
zCenters = -lz/2 + ((1:Nz) - 0.5) * dz;

%% ============================================================
% Parede 1: x = -lx/2
% =============================================================

[Y,Z] = meshgrid(yCenters, zCenters);

walls(1).name = "xMin";

walls(1).points = [ ...
    -lx/2 * ones(numel(Y),1), ...
    Y(:), ...
    Z(:)];

walls(1).normal = [1 0 0];
walls(1).dA = dy * dz;

%% ============================================================
% Parede 2: x = +lx/2
% =============================================================

walls(2).name = "xMax";

walls(2).points = [ ...
    lx/2 * ones(numel(Y),1), ...
    Y(:), ...
    Z(:)];

walls(2).normal = [-1 0 0];
walls(2).dA = dy * dz;

%% ============================================================
% Parede 3: y = -ly/2
% =============================================================

[X,Z] = meshgrid(xCenters, zCenters);

walls(3).name = "yMin";

walls(3).points = [ ...
    X(:), ...
    -ly/2 * ones(numel(X),1), ...
    Z(:)];

walls(3).normal = [0 1 0];
walls(3).dA = dx * dz;

%% ============================================================
% Parede 4: y = +ly/2
% =============================================================

walls(4).name = "yMax";

walls(4).points = [ ...
    X(:), ...
    ly/2 * ones(numel(X),1), ...
    Z(:)];

walls(4).normal = [0 -1 0];
walls(4).dA = dx * dz;

end