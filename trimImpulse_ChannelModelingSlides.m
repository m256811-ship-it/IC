function [h_trim, t_trim, firstDelay] = trimImpulse_ChannelModelingSlides(h_vector, t_vector)
%TRIMIMPULSE_CHANNELMODELINGSLIDES
%
% Remove zeros iniciais e finais da resposta ao impulso física.

if all(h_vector == 0)

    h_trim = h_vector;
    t_trim = t_vector;
    firstDelay = 0;
    return;

end

threshold = max(abs(h_vector))*1e-12;

idx = find(abs(h_vector) > threshold);

idxStart = idx(1);
idxEnd = idx(end);

h_trim = h_vector(idxStart:idxEnd);
t_trim = t_vector(idxStart:idxEnd);

firstDelay = t_trim(1);

end