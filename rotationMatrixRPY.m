function R = rotationMatrixRPY(roll_deg, pitch_deg, yaw_deg)
%ROTATIONMATRIXRPY Matriz de rotacao 3D usando roll, pitch e yaw.
%
% Convencao:
%   roll  -> rotacao em torno de x
%   pitch -> rotacao em torno de y
%   yaw   -> rotacao em torno de z
%
% Matriz total:
%   R = Rz(yaw) * Ry(pitch) * Rx(roll)

    roll  = deg2rad(roll_deg);
    pitch = deg2rad(pitch_deg);
    yaw   = deg2rad(yaw_deg);

    Rx = [ ...
        1, 0,          0;
        0, cos(roll), -sin(roll);
        0, sin(roll),  cos(roll)
    ];

    Ry = [ ...
         cos(pitch), 0, sin(pitch);
         0,          1, 0;
        -sin(pitch), 0, cos(pitch)
    ];

    Rz = [ ...
        cos(yaw), -sin(yaw), 0;
        sin(yaw),  cos(yaw), 0;
        0,         0,        1
    ];

    R = Rz * Ry * Rx;

end