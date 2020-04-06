% segmentLeaves: Segments the leaves from a CT scan. Saves result to same
% filename in working folder.
%
% bw = segmentLeaves(fn_nii, plant)
%
% Outputs:
%   bw: segmented volume
%
% Inputs:
%   fn_nii: path to CT scan
%   plant: string representing type of plant
%
% Example:
% bw = segmentLeaves('S1A.nii', 'soy');
%
% (C) 2020 The Johns Hopkins University Applied Physics Laboratory LLC
% All Rights Reserved
% Author: Nathanael Kuo (nathanael.kuo@jhuapl.com)

function bw = segmentLeaves(fn_nii, plant)
%% set thresholds
if nargin > 1 && strcmpi(plant,'wheat')
    t1 = 90;
else
    t1 = 80;
end
t2 = 400;

%% set up
nii = load_untouch_nii(fn_nii);
dim = nii.hdr.dime.dim(2:4);
pixdim = nii.hdr.dime.pixdim(2:4);

%% remove bright objects (e.g. phantom, table, pot, stems)
se = strel('sphere',2);
bw = imdilate(nii.img > t2,se);
bw = nii.img > t1 & ~bw;

%% feature engineering
% area
conn = conndef(3,'minimal');
bw = bwareaopen(bw,5^3,conn);
% area ratio
cc = bwconncomp(bw,conn);
S1 = regionprops(cc,{'Area','BoundingBox','PixelIdxList'});
L = labelmatrix(cc);
for s = 1:length(S1)
    S2 = regionprops(bwconncomp(imdilate(ismember(L,s),se) & nii.img > t1,conn),'Area');
    S1(s).grownArea = max([S2.Area]);
    S1(s).ratio = S1(s).grownArea/S1(s).Area;
end
S1 = S1([S1.ratio] > 1 & [S1.ratio] < 1.1);
% translate to segmentation
bw = false(dim);
bw(cat(1,S1(:).PixelIdxList)) = true;

%% determine leaves by stem
% remove large bright objects
BW = nii.img > t2;
for i = 1:size(BW,3)
    BW(:,:,i) = bwareaopen(BW(:,:,i),100);
end
BW = imdilate(BW,se);
BW = nii.img > t1 & ~BW;
BW = imreconstruct(bw & BW,BW);
S = regionprops(bwconncomp(BW),{'Centroid','PixelIdxList'});
D = pdist2(cat(1,S.Centroid),dim/2);
[~,i] = min(D);
BW = false(dim);
BW(cat(1,S(i).PixelIdxList)) = true;
bw = bw & BW;

%% save segmentation
C = strsplit(fn_nii,filesep);
save_nii(make_nii(uint8(bw),pixdim),C{end});
