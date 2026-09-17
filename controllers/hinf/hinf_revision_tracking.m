function [metrics,responses] = hinf_revision_tracking(reference,m5,c)
% Medesime metriche per 1-DoF e 2-DoF; settling intorno al valore finale.
metrics=inf(2,6); responses=cell(2,1); dc=dcgain(reference(1:2,:));
for j=1:2
    r=zeros(numel(c.time),2); r(:,j)=m5.referenceAmplitude;
    y=lsim(reference,r,c.time); responses{j}=y;
    final=dc(j,j)*m5.referenceAmplitude;
    outside=find(abs(y(:,j)-final)>.02*m5.referenceAmplitude,1,'last');
    ts=0;
    if ~isempty(outside)
        ts=inf;
        if outside<numel(c.time), ts=c.time(outside+1); end
    end
    metrics(j,:)=[ts,100*max(0,max(y(:,j))/m5.referenceAmplitude-1), ...
        abs(dc(j,j)-1),max(abs(y(:,3-j)))/max(max(abs(y(:,j))),eps), ...
        max(abs(y(:,3:4)),[],'all'),sqrt(mean(y(:,3:4).^2,'all'))];
end
end
