function h_sym = physicalToSymbol_ChannelModelingSlides(h_phys, samplesPerSymbol)
%PHYSICALTOSYMBOL_CHANNELMODELINGSLIDES
%
% Converte a resposta física h_phys em um canal discreto compatível
% com a sequência de símbolos do código atual.

    h_phys = h_phys(:).';
    
    Lphys = length(h_phys);
    Lsym = ceil(Lphys/samplesPerSymbol);
    
    h_sym = zeros(1, Lsym);
    
    for ii = 1:Lsym
    
        idxStart = (ii-1)*samplesPerSymbol + 1;
        idxEnd = min(ii*samplesPerSymbol, Lphys);
    
        h_sym(ii) = sum(h_phys(idxStart:idxEnd));
    
    end

end