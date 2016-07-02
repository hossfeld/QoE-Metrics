% Computes QoE metrics for subjective user rating in y. The subjective data
% y can be passed as matrix or as vector.
% Parameters can be passed as key value pairs.
%
% Input: y - If y is a matrix, each row i represents the ratings all users  
%            for test condition i. Each column j represents the ratings
%            user j for all test conditions. y(i,j) provides the rating of
%            user j for test condition i.
%
% Optional parameters: 
%   low         - Lower bound of the rating scale. Default is 1.
%   high        - Upper bound of the rating scale. Default is 5. 
%   continuous  - Logical value. 1 if rating scale is continous. 0 if
%                 rating scale is discrete.
%   good        - Value used for computing ratio of ratings which are good
%                 or better (GoB), i.e. P(y>=good). Default is good=4.
%   poor        - Value used for computing ratio of ratings which are poor
%                 or worse (PoW), i.e. P(y<=poor). Default is poor=2.
%   alpha       - Significance level for computing confidence interval for
%                 MOS. Default is alpha=0.05;
%   quantilesP  - Quantiles are computed for those probabilities given as vector.
%                 Default values are [0.10, 0.90].
% Usage example: QoEmetrics(y,'low',0) % with QoE values in y
function [stat,p]=QoEmetrics(varargin)

% reading additional input parameters
inp = inputParser;
inp.CaseSensitive = false;
inp.FunctionName = 'QoEmetrics';

addRequired(inp,'y',@(x)validateattributes(x,{'numeric'},{'nonempty'}));
addOptional(inp,'groups',[],@(x)validateattributes(x,{'numeric'},{'vector','nonempty','positive','integer'}));
addParameter(inp,'silent',false,@(x)validateattributes(x,{'logical'},{'scalar','nonempty'}));
addParameter(inp,'low',1,@(x)validateattributes(x,{'numeric'},{'scalar','>=',0}));
addParameter(inp,'high',5,@(x)validateattributes(x,{'numeric'},{'scalar','nonempty','>',inp.Results.low}));
addParameter(inp,'continuous',true,@(x)validateattributes(x,{'logical'},{'scalar','nonempty'}));
addParameter(inp,'good',4,@(x)validateattributes(x,{'numeric'},{'scalar','nonempty','>=',inp.Results.low,'<=',inp.Results.high}));
addParameter(inp,'poor',2,@(x)validateattributes(x,{'numeric'},{'scalar','nonempty','>=',inp.Results.low,'<=',inp.Results.high}));
addParameter(inp,'alpha',0.05,@(x)validateattributes(x,{'numeric'},{'scalar','nonempty','>',0,'<=',0.2}));
addParameter(inp,'quantilesP',[0.1 0.9],@(x)validateattributes(x,{'numeric'},{'vector','nonempty','>',0,'<=',0.2}));


parse(inp,varargin{:});
y=inp.Results.y;
validateattributes(y,{'numeric'},{'>=',inp.Results.low,'<=',inp.Results.high});
p = inp.Results;

% computing the QoE metrics
if ismatrix(y) && ~isvector(y)
    if ~p.silent,clc;fprintf('Reading data from matrix %s\n',inputname(1));end
    stat.numberUsers = size(y,2);
    stat.numberTCs = size(y,1);
    if ~p.silent,fprintf('#users : %d\n#conditions: %d\n',stat.numberUsers,stat.numberTCs);end    
    stat.mos = mean(y,2);  
    stat.sos = std(y,0,2);
    ci = tinv(1-p.alpha/2,size(y,2)-1).*stat.sos/sqrt(stat.numberUsers);
    stat.mosCI=[stat.mos-ci stat.mos+ci];
    stat.mosCIlength=ci;
    stat.median = median(y,2);
    
    % SOS parameter a
    z = (y-p.low)/(p.high-p.low); % scale invariance of SOS parameter; use normalized scores
    zmos = mean(z,2);    
    zvar = var(z,0,2);
    stat.sosParameter_a = -sum( (zmos.^2-zmos).*zvar) ./ (sum( (zmos.^2-zmos).^2 ));
    % f = @(a,x)a*(-x.^2 + (p.low + p.high).*x - p.low*p.high); % toolbox
    % stat.sosParameter_a2 = lsqcurvefit(f,1,stat.mos,stat.sos.^2);
    stat.gob = sum(y>=p.good,2)/size(y,2); % ratio GoB
    stat.pow = sum(y<=p.poor,2)/size(y,2); % ratio PoW
    
    stat.quantile = quantile(y,p.quantilesP,2);
elseif isvector(y)
    if ~p.silent,clc;fprintf('Reading data from matrix %s\n',inputname(1));end
    
    [groups,~,gid]= unique(p.groups);
    stat.numberTCs = length(groups);
    
    n = accumarray(gid,1);  
    if ~p.silent,
        fprintf('#conditions: %d\n',stat.numberTCs);
        fprintf('#users / condition: min=%d; mean=%.2f; median=%.2f; max=%d\n',min(n),mean(n),median(n),max(n));
    end    
    stat.numberUsers = n;
    stat.mos = accumarray(gid,y,[],@mean);  
    stat.sos = accumarray(gid,y,[],@std);
    
    ci = tinv(1-p.alpha/2,n-1).*stat.sos./sqrt(n);
    stat.mosCIlength=ci;
    stat.mosCI=[stat.mos-ci stat.mos+ci];
    
    stat.median = accumarray(gid,y,[],@median);  
    
    % SOS parameter a
    z = (y-p.low)/(p.high-p.low); % scale invariance of SOS parameter; use normalized scores
    zmos = accumarray(gid,z,[],@mean);  
    zvar = accumarray(gid,z,[],@var);
    stat.sosParameter_a = -sum( (zmos.^2-zmos).*zvar) ./ (sum( (zmos.^2-zmos).^2 ));
    % f = @(a,x)a*(-x.^2 + (p.low + p.high).*x - p.low*p.high); % toolbox
    % stat.sosParameter_a2 = lsqcurvefit(f,1,stat.mos,stat.sos.^2);
    stat.gob = accumarray(gid,y,[],@(y)sum(y>=p.good)/length(y)); % ratio GoB 
    stat.pow = accumarray(gid,y,[],@(y)sum(y<=p.poor)/length(y)); % ratio GoB 
    
    stat.quantile=zeros(stat.numberTCs,length(p.quantilesP));
    for i=1:length(p.quantilesP)
        stat.quantile(:,i) = accumarray(gid,y,[],@(y)quantile(y,p.quantilesP(i))); % quantile
    end
end

 if ~p.silent, disp(stat);end

