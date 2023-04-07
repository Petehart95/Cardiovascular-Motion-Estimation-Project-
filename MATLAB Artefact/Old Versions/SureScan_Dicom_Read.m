function [info, Im] = SureScan_Dicom_Read(path, filename)

%close all; clc;

if nargin < 2
    %[filename, path] = uigetfile('*.dcm');
%     [filename, path] = uigetfile('*.dcm');
%     [pathstr, name, ext] = fileparts(filename);
%     if ( ~strcmp( ext , '.dcm' ) )
%         display('Format not supported ... data file must be *.dcm format');
%         return;
%     end
    [filename, path] = uigetfile('*.*');
end

if ( ~strcmp(path(end),'\') )
    path = [path '\'];
end
info = dicominfo([path filename]);
info.FrameRate = 1000/info.FrameTime;

%Im = dicomread([path filename]);
Im = dicomread(info);
% if ( length(size(Im)) > 3 )
%     display(['There are ' num2str(size(Im,4)) ' frames stored in the file']);
%     for fr = 1:info.NumberOfFrames imshow(Im(:,:,:,fr)); title(num2str(fr)); pause(0.01); end
% else
%     imshow(Im);
% end




