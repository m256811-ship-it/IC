function x = ookMod(bits, A)
%Modulação OOK:
%bit 0 -> 0
%bit 1 -> A
x = A*double(bits(:));
end