clear all;clc;
%%
example='vectorWithGroups';
%example='matrix';
switch example
    case 'matrix'
        qoeValues = csvread('continuousRatings.csv');
        [stat,p]=QoEmetrics(qoeValues,'low',1);
    case 'vectorWithGroups'
        M = csvread('continuousRatingsWithGroups.csv');
        qoeValues=M(:,2); groups=M(:,1);
        [stat,p]=QoEmetrics(qoeValues,groups,'low',1);
    otherwise
        error('Example %s not defined',example);
end

%%
figure(1);clf;
errorbar(stat.mos,stat.mosCIlength);
xlabel('test condition')
ylabel('MOS')
legend(sprintf('MOS with CI, \\alpha=%.2f',p.alpha),'location','southeast')
%%
figure(2);clf;
plot(stat.mos,stat.sos.^2,'*');
hold all
f = @(a,x) (a*(-x.^2 + (p.low+p.high).*x  - (p.low*p.high)));
x=linspace(p.low,p.high,100);
%plot(x,f(stat.a2,x),'s')
plot(x,f(stat.sosParameter_a,x),'.');
%plot(x,polyval(stat.a,x));
legend('measurement','SOS hypothesis');
xlabel('MOS')
ylabel('SOS')
%%
figure(3);clf;
plot(stat.mos,stat.gob,'X');
hold all
plot(stat.mos,stat.pow,'s');
xlabel('MOS')
ylabel('ratio')
legend('GoB','PoW','location','north');
%%
figure(4);clf;
if ~isempty(p.groups)
    boxplot(qoeValues',groups)
else
    boxplot(qoeValues')
end
xlabel('test condition')
ylabel('value')
%%
figure(5);clf;
plot(stat.mos,stat.quantile,'d');
xlabel('MOS')
ylabel('quantile')
legend(num2str(p.quantilesP(:)*100,'%d%%-quantile'),'location','southeast');
