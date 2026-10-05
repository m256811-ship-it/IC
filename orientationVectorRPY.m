function n = orientationVectorRPY(roll_deg, pitch_deg, yaw_deg, n0)
%ORIENTATIONVECTORRPY Calcula o vetor normal apos rotacoes roll-pitch-yaw.
%
% direction:
%   "up"   -> vetor inicial [0; 0; 1]
%   "down" -> vetor inicial [0; 0; -1]

    R = rotationMatrixRPY(roll_deg, pitch_deg, yaw_deg);
    
    n0 = n0(:);
    n0 = n0 /  norm(n0);
    n = R * n0;

    % Protecao numerica
    n = n / norm(n);

end