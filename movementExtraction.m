%% Load files
% load session deeplabcut data
sessions = ["11-062419-1"; "11-062819-1"; "12-070519-2"; "13-090919-1";...
    "14-091519-1"; "18-102119-1"; "18-102519-1"; "18-102519-2";...
    "19-111119-1"];
session = sessions(3);
disp(session);

% 0 = no swallow
% 1 = 'DLC_resnet50_swallowing-trackingSep8shuffle1_1030000.csv';
% 2 = 'DeepCut_resnet50_swallow-trackingSep18shuffle1_1030000.csv';
% 3 = 'DLC_resnet50_swallow-no-markerNov22shuffle1_1030000.csv';
swallowdlc = 0;
[camdata,sideloc,bottomloc,swallowloc] = loadDLC(session,swallowdlc);

%% Set camera calibration parameters
% load calibration video
scalvid = VideoReader(strcat('Videos/',session,'/side-',session,'.mp4'));
bcalvid = VideoReader(strcat('Videos/',session,'/bottom-',session,'.mp4'));

% set and extract sample frame
bcalvid.CurrentTime = 75;
scalvid.CurrentTime = 75;
bottomsnap = readFrame(bcalvid);
sidesnap = readFrame(scalvid);
imtool(bottomsnap);
% imtool(sidesnap);

%% Calibrate camera and reconstruct markers
loc_path = strcat('Videos/',session,'/','loc.csv');

% Enter pixel distance between spout tip and tape (5 mm)
sidexlen = 152;
sideylen = 25.83;
bottomxlen = 25.7;
bottomylen = 164;

% Calculate respective ratio
sxratio = 5/sidexlen;
syratio = 0.9/sideylen;
bxratio = 5/bottomxlen;
byratio = 0.9/bottomylen;
ratio = [sxratio;syratio;bxratio;byratio];
noratio = [1;1;1;1];

% Enter pixel height of two markers
laryheight = 0; % 19-111119-1: 48.75
jawheight = 0; % 19-111119-1:23.12

% Calibrate camera
[side,bottom,swallow] = calibrateCamera(sideloc,bottomloc,swallowloc,...
                            noratio,laryheight,jawheight);

% construct marker position in 3D
loc = construct3D(side,bottom,swallow);
writematrix(loc,loc_path);
disp('loc.csv saved');