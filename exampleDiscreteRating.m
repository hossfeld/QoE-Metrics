clear all;clc;
%%
qoeValues = csvread('discreteRatings.csv');
[stat,p]=QoEmetrics(qoeValues,'low',1);
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
n=hist(qoeValues',p.low:p.high);
bar(n'/stat.numberUsers,'stacked');
colormap(reggae)
xlabel('test condition')
ylabel('ratio')
ylim([0 1]);xlim([0 stat.numberTCs+1])
legend(num2str((p.low:p.high)','OS=%d'),'orientation','horizontal','location','northoutside')
%%
figure(5);clf;
plot(stat.mos,stat.quantile,'d');
xlabel('MOS')
ylabel('quantile')
legend(num2str(p.quantilesP(:)*100,'%d%%-quantile'),'location','southeast');
