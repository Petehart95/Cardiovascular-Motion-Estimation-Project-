%Third Year Project | Artefact 
%DICOM Image Converter which was intended for the C++ version of this
%project

%Reset script: close all windows, data in the command window and clear the
%workspace to make room for new data
close all; clc; clear;
disp('------------------------');
disp('Script Start');
disp('------------------------');

%Receive a DICOM image as input, store it in a 4D matrix.
%Im(Col,Row,R/G/B,Frame)
disp('Loading the DICOM Image...');
Im = dicomread('E:\Year 3\Project\patient_data\IM_0025-Bmode');
disp('DICOM Image Loaded!');

%Obtain base frame and future frame for comparison

Im_struct = size(Im(:,:,:,:));

totalRows = (Im_struct(1));
totalColumns = (Im_struct(2));
totalChannels = (Im_struct(3));
totalFrames = (Im_struct(4));
currentFolder = pwd;

for i=1:totalFrames
    Fr = rgb2gray(Im(:,:,:,i));
    dir = '';
    dir = sprintf('Frame %d.txt',i);
    fid = '';
    fid = fopen(dir,'wt');
    fprintf(fid,'%d ', Fr);
    
    progress = i / totalFrames * 100;
    progressDebug = sprintf('Progress: %.0f%% Complete',progress);
    clc;
    disp(progressDebug);
end

disp('End of Script');