% standardizeVolumeNII: Processes a NIfTI volume to a standard intensity
% scale, volume size, and resolution. Saves result to same filename in
% working folder.
%
% standardizeVolumeNII(filename,volumeSize,resolution)
%
% Outputs: None
%
% Inputs:
%   filename: path to NIfTI volume
%   volumeSize: 3-element vector defining desired standard volume size
%   resolution: 3-element vector defining desired standard pixel resolution
%
% Example:
% standardizeVolumeNII('S1A.nii',[512 512 512],[1 1 1]);
%
% (C) 2020 The Johns Hopkins University Applied Physics Laboratory LLC
% All Rights Reserved
% Author: Nathanael Kuo (nathanael.kuo@jhuapl.com)

function standardizeVolumeNII(filename,volumeSize,resolution)

%% read volume
nii = load_nii(filename);
pixdim = nii.hdr.dime.pixdim(2:4);
dim = nii.hdr.dime.dim(2:4);

%% adjust intensity scale volume size
if min(nii.img(:)) < 0
    nii.img = nii.img+1024;
end
intensityScale = 'uint16';
minVal = zeros(1,1,intensityScale);
minVal(1) = min(nii.img(:));
if minVal ~= 0
    disp(filename);
end
vol_new = ones(volumeSize,intensityScale)*minVal;

%% adjust resolution
FOV = pixdim.*(dim-1);
X = 0:pixdim(2):FOV(2);
Y = 0:pixdim(1):FOV(1);
Z = 0:pixdim(3):FOV(3);
FOVq = resolution.*(volumeSize-1);
[Xq,Yq,Zq] = meshgrid(FOV(2)/2+(-FOVq(2)/2:resolution(2):FOVq(2)/2),...
    FOV(1)/2+(-FOVq(1)/2:resolution(1):FOVq(1)/2),...
    FOV(3)/2+(-FOVq(3)/2:resolution(3):FOVq(3)/2));
nii.img = interp3(X,Y,Z,double(nii.img),Xq,Yq,Zq,'linear',minVal);

%% zero pad & rotate
vol_new(1:volumeSize(1),1:volumeSize(2),1:volumeSize(3)) = nii.img;
p = [3 1 2];

%% save volume
[~,name,ext] = fileparts(filename);
save_nii(make_nii(permute(vol_new, p),resolution(p)),[name,ext]);
