function [Frho_p, FrhoVx_p,FrhoVy_p,FrhoVz_p,Feng_p, ...
          Frho_n, FrhoVx_n,FrhoVy_n,FrhoVz_n,Feng_n] = GasKineticFluxSplit(rho,Vx,Vy,Vz,p,bx,by,bz)
%% The heat capacity ratio ( \gamma ) for an ideal gas can be related to the degrees of freedom ( f ):  gamma = 1 + 2/f
%      eng= 0.5.*rho.*(Vx.^2+Vy.^2+Vz.^2)+p./(gamma-1)+0.5.*(bx.^2+by.^2+bz.^2);
global gamma
%     Vx=rhoVx./rho;
%     Vy=rhoVy./rho;
%     Vz=rhoVz./rho;
    rhoVx = rho.*Vx;
    rhoVy = rho.*Vy;
    rhoVz = rho.*Vz;
    eng= 0.5.*rho.*(Vx.^2+Vy.^2+Vz.^2)+p./(gamma-1)+0.5.*(bx.^2+by.^2+bz.^2);

    b = sqrt(bx.^2+by.^2+bz.^2); % only b^2 is needed
%     p = (eng - 0.5.*rho.*(Vx.^2+Vy.^2+Vz.^2) - 0.5.*b.^2).*(gamma-1);   
    ptot = p + 0.5*b.^2;
    lamda = rho./(2*ptot);
%
    Vx0_p = 0.5*erfc(-sqrt(lamda).*Vx);
    Vx0_n = 0.5*erfc(+sqrt(lamda).*Vx);
    Vx1_p = Vx.*Vx0_p + 0.5.*exp(-lamda.*Vx.^2)./sqrt(pi.*lamda);
    Vx1_n = Vx.*Vx0_n - 0.5.*exp(-lamda.*Vx.^2)./sqrt(pi.*lamda);
    
    Vy0_p = 0.5*erfc(-sqrt(lamda).*Vy);
    Vy0_n = 0.5*erfc(+sqrt(lamda).*Vy);
    Vy1_p = Vy.*Vy0_p + 0.5.*exp(-lamda.*Vy.^2)./sqrt(pi.*lamda);
    Vy1_n = Vy.*Vy0_n - 0.5.*exp(-lamda.*Vy.^2)./sqrt(pi.*lamda);
    
    Vz0_p = 0.5*erfc(-sqrt(lamda).*Vz);
    Vz0_n = 0.5*erfc(+sqrt(lamda).*Vz);
    Vz1_p = Vz.*Vz0_p + 0.5.*exp(-lamda.*Vz.^2)./sqrt(pi.*lamda);
    Vz1_n = Vz.*Vz0_n - 0.5.*exp(-lamda.*Vz.^2)./sqrt(pi.*lamda);

    direction = 1;
    
if (direction ==1)
    n1=1;
    n2=0;
    n3=0;
    Vn0_p = Vx0_p;     
    Vn0_n = Vx0_n;
    Vn1_p = Vx1_p;     
    Vn1_n = Vx1_n;
    bn = bx;
    Vn = Vx;
elseif(direction==2)
    n1=0;
    n2=1;
    n3=0;
    Vn0_p = Vy0_p;     
    Vn0_n = Vy0_n;
    Vn1_p = Vy1_p;     
    Vn1_n = Vy1_n;
    bn = by;
    Vn = Vy;
elseif(direction==3)
    n1=0;
    n2=0;
    n3=1;
    Vn0_p = Vz0_p;     
    Vn0_n = Vz0_n;
    Vn1_p = Vz1_p;     
    Vn1_n = Vz1_n;
    bn = bz;
    Vn = Vz;
end
%    
    % Flux in the positive x direction
    Frho_p   = rho  .* Vn1_p;
    FrhoVx_p = rhoVx .* Vn1_p + (ptot*n1 - bx.*bn) .* Vn0_p;
    FrhoVy_p = rhoVy .* Vn1_p + (ptot*n2 - by.*bn) .* Vn0_p;
    FrhoVz_p = rhoVz .* Vn1_p + (ptot*n3 - bz.*bn) .* Vn0_p;
%     Fbx_p    = (bx - bn*n1) .* Vn1_p + (Vn*n1 - Vx) .* bn .* Vn0_p;
%     Fby_p    = (by - bn*n2) .* Vn1_p + (Vn*n2 - Vy) .* bn .* Vn0_p;
%     Fbz_p    = (bz - bn*n3) .* Vn1_p + (Vn*n3 - Vz) .* bn .* Vn0_p;
    Feng_p   = (eng + 0.5*p + 0.5.*b.^2 - bn.^2) .* Vn1_p + (Vn.*bn.^2 - (Vx.*bx + Vy.*by + Vz.*bz).*bn + 0.5*p.*Vn).*Vn0_p;
    
    % Flux in the negative x direction
    Frho_n   = rho  .* Vn1_n;
    FrhoVx_n = rhoVx .* Vn1_n + (ptot*n1 - bx.*bn) .* Vn0_n;
    FrhoVy_n = rhoVy .* Vn1_n + (ptot*n2 - by.*bn) .* Vn0_n;
    FrhoVz_n = rhoVz .* Vn1_n + (ptot*n3 - bz.*bn) .* Vn0_n;
%     Fbx_n    = (bx - bn*n1) .* Vn1_n + (Vn*n1 - Vx) .* bn .* Vn0_n;
%     Fby_n    = (by - bn*n2) .* Vn1_n + (Vn*n2 - Vy) .* bn .* Vn0_n;
%     Fbz_n    = (bz - bn*n3) .* Vn1_n + (Vn*n3 - Vz) .* bn .* Vn0_n;
    Feng_n   = (eng + 0.5*p + 0.5.*b.^2 - bn.^2) .* Vn1_n + (Vn.*bn.^2 - (Vx.*bx + Vy.*by + Vz.*bz).*bn + 0.5*p.*Vn).*Vn0_n;
    
%     Frho_n   = rho  .* Vn1_n;
%     FrhoVx_n = rhoVx .* Vn1_n + (ptot*n1 - bx.*bn) .* Vn0_n;
%     FrhoVy_n = rhoVy .* Vn1_n + (ptot*n2 - by.*bn) .* Vn0_n;
%     FrhoVz_n = rhoVz .* Vn1_n + (ptot*n3 - bz.*bn) .* Vn0_n;
%     Fbx_n    = (bx - bn*n1) .* Vn1_n + (Vn*n1 - Vx) .* bn .* Vn0_n;
%     Fby_n    = (by - bn*n2) .* Vn1_n + (Vn*n2 - Vy) .* bn .* Vn0_n;
%     Fbz_n    = (bz - bn*n3) .* Vn1_n + (Vn*n3 - Vz) .* bn .* Vn0_n;
%     Feng_n   = (eng + 0.5*p + 0.5.*b.^2 - bn.^2) .* Vn1_n - (Vn.*bn.^2 - (Vx.*bx + Vy.*by + Vz.*bz).*bn + 0.5*p.*Vn).*Vn0_n;   
    
end
