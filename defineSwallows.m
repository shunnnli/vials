function [pswallow,threshold,allpeaks] = defineSwallows(loc,tp,camdata)
% defineSwallows: Find putative swallows from corrected laryngeal movements
%   *: designed to be conservative (false positive is acceptable)
%   INPUT: ylplocs (local maxima of corrected laryngeal movement)
%          tp, loc
%   OUTPUT: pswallow = [psid, time, ylarypeaks(i)]

% lary corrected trajectory = Laryngeal - jaw
yjaw = loc(:,14);
ylaryvsjaw = loc(:,11) - yjaw;

% Find peaks of laryngeal y trajectory
[ylarypeaks,ylplocs,ylpw,ylpp] = findpeaks(ylaryvsjaw,...
    'MinPeakDistance',15,'MinPeakProminence',5);

% Store data of all peaks
allpeaks.pks = ylarypeaks;
allpeaks.locs = ylplocs;
allpeaks.w = ylpw;  % width
allpeaks.p = ylpp;  % prominance

% If jaw marker is too low --> not swallowing
alljh = yjaw(tp(:,36));  % all jaw height during tongueInFrame
threshold = nanmean(alljh);  % mean
% threshold = prctile(alljh,25); % 25%
% threshold = min(alljh);

% Find whether peaks in ylplocs concurred with tongue protrusion
psid = 0;
pswallow = [];
tpRange = tp(:,35:36);
for i = 1:size(ylplocs)
    frame = ylplocs(i);    % corresponding frame
    inRange = find(frame >= tpRange(:,1) & frame <= tpRange(:,2), 1);
    if isempty(inRange)
        % Filter if lary & jaw are around the same height (tongue must be out)
        if yjaw <= threshold
            continue
        end
        
        % add peak to pswallow if after filtering
        psid = psid + 1;
        new_row = [psid,frame2time(frame,camdata),ylarypeaks(i),ylpp(i)];
        pswallow = [pswallow; new_row];
    end
end

% Determine minimum height diff between two markers
%{
alltif = ylaryvsjaw(tp(:,36));  % all height diff of tongueInframe
% threshold = nanmean(alltif);  % mean
threshold = prctile(alltif,25); % 25%
% threshold = min(alltif);
%}

end

