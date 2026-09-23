function G=simulink_integration_linear_map(c)
%SIMULINK_INTEGRATION_LINEAR_MAP Independent full-order artifact interconnection.
ny=size(c.Bk,2)-2; Cy=c.C(1:ny,:);
Br=c.Bk(:,1:2); By=c.Bk(:,3:end); Dr=c.Dk(:,1:2); Dy=c.Dk(:,3:end);
nk=size(c.Ak,1);
Ac=[c.A+c.B*Dy*Cy c.B*c.Ck; By*Cy c.Ak];
Bc=[c.B*Dr c.Bd;Br zeros(nk,2)];
Cc=[c.Cq zeros(2,nk);Dy*Cy c.Ck];
G=ss(Ac,Bc,Cc,[zeros(2,4);Dr zeros(2)]);
end
