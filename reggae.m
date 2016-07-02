function c = reggae(m,dir)
%REGGAE Linear reggae-tone color map
%   REGGAE(M,DIR) returns an M-by-3 matrix containing a "reggae" colormap.
%   REGGAE, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB creates one.
%
%   DIR = 1 specifies the colormap from red to green (default).
%   DIR = -1 specifies the colormap in reverse order, from green to red.
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(reggae)
%
%   See also HSV, GRAY, HOT, COOL, BONE, PINK, FLAG,
%   COLORMAP, RGBPLOT.

if nargin < 1, m = size(get(gcf,'colormap'),1); end
if nargin < 2, dir=1;end

if abs(dir)~=1, error(help('reggae'));end

%hos=[1 0 0; 1 0.5 0; 1 1 0; 0.5 1 0; 0 1 0]
c = zeros(m,3);
one = floor(m/2); two = ceil(m/2)+(1-mod(m,2));
c(1:one,1)=1;
c(1:two,2)=linspace(0,1,two);

c(one+1:m,1)=linspace(1,0,m-one);
c(two+1:m,2)=1;
if dir==-1, c=c(end:-1:1,:);end

