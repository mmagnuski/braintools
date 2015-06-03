function [peak_samp, peakness] = peakness(n,signal, range, varargin)

% [peak_samp, peakness] = peakness(n, sig, rng)
% finds peak that maximizes peak slope (peakness)
% within a given range (rng) of a given signal (sig).
% Peak slope is defined as mean slope on both sides
% of the peak within n-samples (n).
% ====
% peakness requires extrema.m function available
% at MATLAB Central
%
% =================
% PEAKNESS examples
% high peakness:
%    /\
% __/  \__
%
% lower peakness:
%    /\__
% __/ 
% 
% no peak, no peakness:
%    __
% __/ 

prefcenter = false;

% ADD - difference from other peaks (normal value if
% no other peaks present)
% input checks:
if nargin>4
    adr = strcmp('prefcenter', varargin);
    if ~isempty(adr)
        prefcenter = true;
    end
end

% check signal size:
signal = signal(:)';

% calculates n-peakness on m-smoothed spectrum
stddif = std(abs(diff(signal(range(1):range(2)))), 1);
smoothsignal = signal;

% find extrema
% IMAX - extrema samples within the range
% sample adresses are relative to the whole signal 
[~,IMAX] = extrema(smoothsignal(range(1):range(2)));
IMAX = sort(IMAX + range(1) - 1);
len = length(IMAX);

% if no positive extrema:
% (what else should we do?)
if len == 0
    peak_samp = [];
    peakness = [];
    return
end

% checking range constraint
kill = false(len,1);

% checking if extrema for sure...
for p = 1:len
kill(p) = smoothsignal(IMAX(p)-1) > smoothsignal(IMAX(p))...
    || smoothsignal(IMAX(p)+1) > smoothsignal(IMAX(p));
end
IMAX(kill) = [];
len = length(IMAX);

% if no positive extrema:
% (what else should we do?)
if len == 0
    peak_samp = [];
    peakness = [];
    return
end


% for each positive extremum calculate peakness
% ADD optional - gaussian kernel
peakn = zeros(len,1);
for p = 1:len
    try
    peakn(p) = mean([diff( signal( IMAX(p) - n : IMAX(p) )),...
        diff( signal( IMAX(p) : IMAX(p) + n ))*-1]);
    catch %#ok<CTCH>
        peakn(p) = NaN;
    end
end

% maximizing peakness:
[peakness, peak_samp] = max(peakn);

% preferring centre - should not be used now (?)
if prefcenter
    % if differences are not more than 0.01
    % then we prefer the peak that is closer
    % to the centre of the range:
    closepeaks = peakness - peakn < stddif;
    closepeaks(peak_samp) = false;
    
    if sum(closepeaks) > 0
        whichpeak = find(closepeaks);
        withinrangeadr = IMAX(whichpeak) - range(1) + 1;
        midr = length(range(1):range(2))/2;
        curr_loc = abs(IMAX(peak_samp) - range(1) + 1 - midr);
        peakloc = abs(withinrangeadr - midr);
        closeloc = peakloc < curr_loc;
        if sum(closeloc) > 0
            [~, peak_samp] = min(peakloc);
            peak_samp = whichpeak(peak_samp);
            peakness = peakn(peak_samp);
        end
    end
end

% peak sample
peak_samp = IMAX(peak_samp);

