# CT_leaf_analysis
MATLAB code to analyze CT scans of leaves

### References

Associated CT scan data on Cyverse Data Commons is forthcoming.

Publication in The Plant Phenome Journal is forthcoming.

### Usage

All code was tested in MATLAB R2019a.

The following toolbox is also necessary for running this code:

Jimmy Shen (2020). Tools for NIfTI and ANALYZE image (https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image), MATLAB Central File Exchange.

The pipeline is designed to be run in the following order:

1. Preprocessing: standardVolumeNII.m
2. Segmentation: segmentLeaves.m
3. Calculation: computeMetrics.m

Please see commented code for more details.