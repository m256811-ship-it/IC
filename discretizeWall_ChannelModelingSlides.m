function [x, y, z, Nx, Ny, Nz, dA] = discretizeWall_ChannelModelingSlides(params)
%DISCRETIZEWALL_CHANNELMODELINGSLIDES
%
% Cria a discretização espacial da sala e da parede usada no cálculo NLOS.

Nx = params.room(1)*5;
Ny = params.room(2)*5;
Nz = params.room(3)*5;

x = linspace(-params.room(1)/2, params.room(1)/2, Nx);
y = linspace(-params.room(2)/2, params.room(2)/2, Ny);
z = linspace(-params.room(3)/2, params.room(3)/2, Nz);

% Área de cada elemento da parede x = -lx/2.
dA = params.room(3)*params.room(2)/(Ny*Nz);

end