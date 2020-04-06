% computeMetrics: Computes various leaf metrics.
%
% m = computeMetrics(fn_nii)
%
% Outputs:
%   m: struct of measurements
%   m.volume: leaf volume
%   m.surface_area: leaf surface area
%   m.projected_area: top-down projected area
%
% Inputs:
%   fn_nii: path to segmentation
%
% Example:
% m = computeMetrics('S1A.nii');
%
% (C) 2020 The Johns Hopkins University Applied Physics Laboratory LLC
% All Rights Reserved
% Author: Nathanael Kuo (nathanael.kuo@jhuapl.com)

function m = computeMetrics(fn_nii)

%% set up
nii = load_nii(fn_nii);
pixdim = nii.hdr.dime.pixdim(2:4);

%% metrics
stats = regionprops3(nii.img > 0, {'Volume','SurfaceArea'});
m.volume = sum([stats.Volume])*prod(pixdim);
m.surface_area = sum([stats.SurfaceArea])*mean(pixdim)^2;
m.projected_area = numel(find(sum(nii.img,3) > 0))*prod(pixdim(1:2));
