%Third Year Project | Artefact 
%Ultrasound Image Analysis with a Parallel Implementation

%Reset script: close all windows, data in the command window and clear the
%workspace to make room for new data
close all; clc; clear;
disp('------------------------');
disp('Script Start');
disp('------------------------');

%Receive a DICOM image as input, store it in a 4D matrix.
%Im(Col,Row,R/G/B,Frame)
disp('Loading the DICOM Image...');
Im = dicomread('F:\Year 3\Project\patient_data\IM_0001-Bmode');
disp('DICOM Image Loaded!');
disp('------------------------');

Im_struct = size(Im(:,:,:,:)); %Store structural information about the DICOM image for reference later on
totalRows = (Im_struct(1));
totalColumns = (Im_struct(2));
totalChannels = (Im_struct(3));
totalFrames = (Im_struct(4));    

kernelSize = 20;
kernelCount = 1;
stepSize = (kernelSize / 2);
searchWindowSize = (kernelSize*6)/2;
threshold = 0.5;

searchStart = 110;
searchEnd = 80;

totalKernels = (totalRows - (searchStart + searchEnd) / kernelSize) + (totalColumns - (searchStart + searchEnd) / kernelSize);

f1 = figure;
%f2 = figure;

%Clear command line, inform the user that the image is ready to be analysed
%so they are aware of what stage the algorithm is at

clc;
disp('Beginning DICOM Image Analysis.');
pause(1);
clc;
disp('Beginning DICOM Image Analysis..');
pause(1);
clc;
disp('Beginning DICOM Image Analysis...');
pause(1);
fr_plt1 = 0;
vel_plt1 = 0;
xtemp = 0;
ytemp = 0;

%Iterate through all frames of the DICOM image
for fr=1:totalFrames-1
    tic
    %Get the first frame as a reference point
    Fr1 = Im(:,:,:,fr);
    %Get the subsequent frame for motion estimation
    Fr2 = Im(:,:,:,fr+1);
    
    Fr1 = rgb2gray(Fr1);
    Fr2 = rgb2gray(Fr2);
    
    %Empty matrices from the previous frame iteration
    plt_xy = zeros(totalKernels,2);
    plt_uv = zeros(totalKernels,2);
    
    kernelCount = 1;
    %For each pixel within the frame
    for x1 = searchStart:10:totalRows-searchEnd
        for y1 = searchStart:10:totalColumns-searchEnd
            %Get a kernel from Frame 1, which is the kernel that will be
            %searched for in Frame 2
            kernelRef = Fr1(x1-stepSize:x1+stepSize,y1-stepSize:y1+stepSize);
            best_SAD = 9999999;
            
            %Search for the pixel within this search window of Frame (n + 1)
            for x2 = x1-searchWindowSize:x1+searchWindowSize
                for y2 = y1-searchWindowSize:y1+searchWindowSize
                    
                    currentKernel = Fr2(x2-stepSize:x2+stepSize,y2-stepSize:y2+stepSize);
                    SAD = sum(sum(abs(currentKernel-kernelRef)));
                    
                    if SAD < best_SAD 
                        best_SAD = SAD;
                        xtemp = x2;
                        ytemp = y2;
                    end
                end
            end
            x2 = xtemp;
            y2 = ytemp;
            
            plt_xy(kernelCount,1) = x1;
            plt_xy(kernelCount,2) = y1;
            
            plt_uv(kernelCount,1) = x2 - x1;
            plt_uv(kernelCount,2) = y2 - y1;            
            
            kernelCount = kernelCount + 1;
        end
    end
    searchTime = toc;
    pxDistance = sqrt(pxDistance);
    cmDistance = pxDistance / 44;
    velocity = cmDistance / searchTime;
    
    %velocity = pxDistance / searchTime;
    %velocityArr(fr) = velocity;
    
    figure(f1);
    hold on;
    plot([fr_plt1,fr],[vel_plt1,velocity],'red');
    hold off;
    
    figure(f2);
    imshow(Im(:,:,:,fr));
    hold on;
    quiver(plt_xy(:,2),plt_xy(:,1),plt_uv(:,2),plt_uv(:,1),'color',[1,0,0]);
    hold off;
    
    pause(0.0001);
end
disp('end of script');