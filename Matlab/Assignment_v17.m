%Third Year Project | Artefact 
%Cardiac Image Processing Project

%Reset script: close all windows, data in the command window and clear the
%workspace to make room for new data
close all; clc; clear;
disp('------------------------');
disp('Script Start');
disp('------------------------');

%Receive a DICOM image as input, store it in a 4D matrix.
%Im(Col,Row,R/G/B,Frame)
disp('Loading the DICOM Image...');
Im = dicomread('E:\Year 3\Project\patient_data\IM_0001-Bmode');
disp('DICOM Image Loaded!');
disp('------------------------');

Im_struct = size(Im(:,:,:,:)); %Store structural information about the DICOM image for reference later on
totalRows = (Im_struct(1));
totalColumns = (Im_struct(2));
totalChannels = (Im_struct(3));
totalFrames = (Im_struct(4));    

kernelSize = 20;
kernelCount = 1;
stepSize = kernelSize/2;
searchWindowSize = (20*6)/2;
threshold = 0.5;

searchStart = 80;
searchEnd = 80;

fr_plt1 = 0;
vel_plt1 = 0;
xtemp = 0;
ytemp = 0;

totalKernels = (totalRows - (searchStart + searchEnd) / kernelSize) + (totalColumns - (searchStart + searchEnd) / kernelSize);

f1 = figure;
f2 = figure;
f3 = figure;

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% BLOCK-MATCHING MOTION ESTIMATION ALGORITHM %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Iterate through all frames of the DICOM image (-1 to remain within the bounds of the image)
for fr=1:totalFrames-1
    tic
    
    %Get the first frame as a reference point
    Fr1 = Im(:,:,:,fr);
    %Get the subsequent frame for motion estimation
    Fr2 = Im(:,:,:,fr+1);
    
    Fr1 = rgb2gray(Fr1);
    Fr2 = rgb2gray(Fr2);
    T = 140;
    
    for i=1:size(Fr1,1)
        for j=1:size(Fr1,2)
            if Fr1(i,j) > T
                I_bw(i,j) = 0;
            else
                I_bw(i,j) = 255;
            end
        end
    end

    %Empty matrices from the previous frame iteration
    plt_xy = zeros(totalKernels,2);
    plt_uv = zeros(totalKernels,2);
    
    %Reset variables from previous iteration
    pxDistance = 0;
    kernelCount = 1;
    
    %For each pixel within the frame
    for x1 = searchStart:10:totalRows-searchEnd
        for y1 = searchStart:20:totalColumns-searchEnd
            %Get a kernel from Frame 1, which is the kernel that will be
            %searched for in Frame 2
            kernelRef = Fr1(x1-stepSize:x1+stepSize,y1-stepSize:y1+stepSize);
            
            %Get an initial kernel as a starting point (middle)
            firstKernel = Fr2(x1-stepSize:x1+stepSize,y1-stepSize:y1+stepSize);
            best_SAD = sum(sum(abs(firstKernel-kernelRef)));
            xtemp = x1;
            ytemp = y1;

            %Search for the pixel within this search window of Frame (n + 1)
            for x2 = x1-searchWindowSize:x1+searchWindowSize
                for y2 = y1-searchWindowSize:y1+searchWindowSize
                    
                    % Acquire the next pixel for comparison within the
                    % search window
                    currentKernel = Fr2(x2-stepSize:x2+stepSize,y2-stepSize:y2+stepSize);
                    
                    currentKernelMask1 = I_bw(x1,y1);
                    currentKernelMask2 = I_bw(x2,y2);

                    %Calculate an SAD value to determine how similar this
                    %kernel is with the kernel being searched for
                    SAD = sum(sum(abs(currentKernel-kernelRef)));
                                        
                    % If this kernel has a smaller difference with the
                    % reference kernel, replace the best kernel with this
                    % kernel
                    if SAD < best_SAD && currentKernelMask1 == 0
                        best_SAD = SAD;
                        xtemp = x2;
                        ytemp = y2;
                    end
                end
            end
            % Re-assign x2 and y2 variables once the best match has been
            % determined
            x2 = xtemp;
            y2 = ytemp;
            
            % Store these variables in a 2D array, so the results can be
            % plotted later
            plt_xy(kernelCount,1) = x1;
            plt_xy(kernelCount,2) = y1;
            
            %Store the total difference between the original position and
            %the new position of each kernel
            plt_uv(kernelCount,1) = x2 - x1;
            plt_uv(kernelCount,2) = y2 - y1;            
            
            % Calculate the total distance of displacement so a velocity
            % calculation can be calculated later
            pxDistance = pxDistance + (x2 - x1).^2 + (y2 - y1).^2;
            
            % Keep track on the total amount of kernels for indexing
            kernelCount = kernelCount + 1;
        end
    end
    % Stop timing the function for this frame
    searchTime = toc;
    
    % Square the total displacement to calculate the absolute difference
    pxDistance = sqrt(pxDistance);
    
    % Convert px/s to cm/s
    cmDistance = pxDistance / 44;
    
    %average velocity vector
    avgMV_X = sum(plt_uv(:,1)) / sum(size(plt_uv(:,1)));
    avgMV_Y = sum(plt_uv(:,2)) / sum(size(plt_uv(:,2)));
    
    % Estimate velocity of the muscle contraction
    velocity = cmDistance / searchTime;
    

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOT RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot the average velocity of muscle contraction during each frame
    figure(f1);
    hold on;
    plot([fr_plt1,fr],[vel_plt1,velocity],'red');
    hold off;
    
    %Store these values for subsequent plot
    fr_plt1 = fr;
    vel_plt1 = velocity;
    
    % Plot the original ultrasound image with an overlay demonstrating
    % motion vector distribution
    figure(f2);
    imshow(I_bw);
    hold on;
    quiver(plt_xy(:,2),plt_xy(:,1),plt_uv(:,2),plt_uv(:,1),'color',[1,0,0]);
    hold off;    
    
    figure(f3);
    imshow(Im(:,:,:,fr));
    hold on;
    quiver(plt_xy(:,2),plt_xy(:,1),plt_uv(:,2),plt_uv(:,1),'color',[1,0,0]);
    hold off;
    
    % Pause to allow figures to update
    pause(0.0001);
end
disp('end of script');