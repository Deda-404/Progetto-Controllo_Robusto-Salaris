function rapporti = lyapunov_sample_ratios(rho, direzioni, raggi, P, modello)
%LYAPUNOV_SAMPLE_RATIOS Valuta Vdot/||z||^2 in punti finiti dell'ellissoide.
% Le colonne di direzioni hanno norma uno; R=chol(P) e z=sqrt(rho)*R\d
% danno V(z)=rho. I raggi in (0,1] controllano anche punti interni.
% Questa verifica NON dimostra la negativita su tutto l'insieme.
arguments
    rho (1,1) double {mustBePositive,mustBeFinite,mustBeReal}
    direzioni (:,:) double {mustBeFinite,mustBeReal,mustBeNonempty}
    raggi (:,1) double {mustBePositive,mustBeFinite,mustBeReal,mustBeLessThanOrEqual(raggi,1)}
    P (:,:) double {mustBeFinite,mustBeReal}
    modello (1,1) struct
end
R = chol(P);
assert(all(abs(vecnorm(direzioni)-1)<1e-10),'Lyapunov:Directions', ...
    'Le direzioni devono essere non nulle e normalizzate.');
punti = sqrt(rho)*(R\direzioni);
rapporti = zeros(numel(raggi),size(punti,2));
for k=1:numel(raggi)
    for j=1:size(punti,2)
        z = raggi(k)*punti(:,j);
        dz = sea_closed_loop_rhs(z,modello);
        rapporti(k,j) = 2*z'*P*dz/(z'*z);
    end
end
assert(all(isfinite(rapporti),'all'),'Lyapunov:Nonfinite', ...
    'Un rapporto non finito non puo validare un livello di Lyapunov.');
end
