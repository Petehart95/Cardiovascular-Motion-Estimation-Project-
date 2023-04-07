close all; clc; clear;

FilterSpec = '.dcm';
[FileName,PathName,FilterIndex] = uigetfile(FilterSpec);
selectedFile = strcat(PathName,FileName);

% DICOM image selected, store in a matrix
Im = dicomread(selectedFile);

Im_struct = size(Im(:,:,:,:)); 
totalRows = (Im_struct(1));
totalColumns = (Im_struct(2));
totalChannels = (Im_struct(3));
totalFrames = (Im_struct(4));    

for i=1:totalFrames-1
    subplot(2,1,1);
    imshow(Im(:,:,:,i));
    subplot(2,1,2);
    imshow(Im(:,:,:,i+1));
    pause(0.001);
end