function h_vector = addPathLinear_ChannelModelingSlides(h_vector, H_path, tau, delta_t)
%ADDPATHLINEAR_CHANNELMODELINGSLIDES
%
% Adiciona uma contribuição de caminho óptico ao vetor h_vector usando
% interpolação linear entre bins temporais.

pos = tau/delta_t + 1;

idxLow = floor(pos);
idxHigh = idxLow + 1;

alpha = pos - idxLow;

if idxLow >= 1 && idxLow <= length(h_vector)
    h_vector(idxLow) = h_vector(idxLow) + (1-alpha)*H_path;
end

if idxHigh >= 1 && idxHigh <= length(h_vector)
    h_vector(idxHigh) = h_vector(idxHigh) + alpha*H_path;
end

end