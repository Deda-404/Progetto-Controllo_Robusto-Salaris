function [W1,W2] = hinf_revision_weights(p,c)
% Parametri [omegaW1 As Ms ku omegaU], coordinate fisiche inalterate.
s = tf('s');
W1 = (s/p(3)+p(1))/(s+p(1)*p(2))*eye(2);
W2 = p(4)*(s+p(5))/(s/c.alpha+p(5))*eye(2);
end
