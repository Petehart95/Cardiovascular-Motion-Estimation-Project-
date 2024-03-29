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

% User interface for selecting a DICOM image file as input
FilterSpec = '.dcm';
[FileName,PathName,FilterIndex] = uigetfile(FilterSpec);
selectedFile = strcat(PathName,FileName);

% DICOM image selected, store in a matrix
Im = dicomread(selectedFile);

disp('DICOM Image Loaded!');
disp('------------------------');

% Store structural information about the DICOM image for reference later on
Im_struct = size(Im(:,:,:,:)); 
totalRows = (Im_struct(1));
totalColumns = (Im_struct(2));
totalChannels = (Im_struct(3));
totalFrames = (Im_struct(4));    

% Initialise variables
kernelSize = 8;
kernelCount = 1;
stepSize = kernelSize/2;
searchWindowSize = (kernelSize*6)/2;
threshold = 0.5;
%rawVelocity = zeros(size(1000));
%noisyVelocity = zeros(size(1000));
absDifference = zeros(size(stepSize));

% Regions of interest within the ultrasound images (focus on the
% cardiomyocytes)

region = [%310,200,280,500;  % temp region
          310,130,230,440;  % Region 1 | row start | totalrows - n = row end | col start | totalcol - n = col end
          310,130,360,330;
          310,130,470,180]; % Region 2 | row start | totalrows - n = row end | col start | totalcol - n = col end
      
region1 = [320 200; % [row start | totalrows - n = row end;
           425 250]; %  col start | totalcolumns - n = col end];

region2 = [327 150;
           363 330];

region3 = [];

region4 = [310,200,230,540];

fr_plt1 = 0;
vel_plt1 = 0;
vel_plt2 = 0;
rowtemp = 0;
coltemp = 0;


% Clear command line, inform the user that the image is ready to be analysed
% so they are aware of what stage the program is at

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
%    tic
    frr=fr+1;
    noiseCTR = 1;
    finalVelocity = 0;
    %Reset variables from previous iteration
    pxDistance = 0;
    kernelCount = 1;
    objectCount = 1;
    
    %Get the first frame as a reference point
    Fr1 = Im(:,:,:,fr);
    %Get the subsequent frame for motion estimation
    Fr2 = Im(:,:,:,frr);
    
    Fr1 = rgb2gray(Fr1);
    Fr2 = rgb2gray(Fr2);

    %Threshold value for segmenting the image
    T = 160;
    
    for i=1:size(Fr1,1)
        for j=1:size(Fr1,2)
            if Fr1(i,j) > T
                I_bw1(i,j) = 0;
            else
                I_bw1(i,j) = 255;
            end
        end
    end
    
    for i=1:size(Fr2,1)
        for j=1:size(Fr2,2)
            if Fr2(i,j) > T
                I_bw2(i,j) = 0;
            else
                I_bw2(i,j) = 255;
            end
        end
    end
    
    seD = strel('square',4);
    I_bw1 = imclose(imopen(I_bw1,seD),seD);
    I_bw2 = imclose(imopen(I_bw2,seD),seD);
    
    for regionCTR=1:3
        %For each pixel within the frame
        for row1 = region(regionCTR,1):stepSize/2:totalRows-region(regionCTR,2)                                                                                                                                                                                                                                                                                                                                                                                                                          
            for col1 = region(regionCTR,3):stepSize/2:totalColumns-region(regionCTR,4)
                %Get a kernel from Frame 1, which is the kernel that will be
                %searched for in Frame 2
                kernelRef = Fr1(row1-stepSize:row1+stepSize,col1-stepSize:col1+stepSize);

                %Get an initial kernel as a starting point (middle)
                firstKernel = Fr2(row1-stepSize:row1+stepSize,col1-stepSize:col1+stepSize);

                X = firstKernel-kernelRef;
                best_SAD = sum(abs(X(:)));                        
                rowtemp = row1;
                coltemp = col1;

                %Search for the pixel within this search window of Frame (n + 1)
                for row2 = row1-searchWindowSize:row1+searchWindowSize
                    for col2 = col1-searchWindowSize:col1+searchWindowSize
                        % Acquire the next pixel for comparison within the
                        % search window
                        currentKernel = Fr2(row2-stepSize:row2+stepSize,col2-stepSize:col2+stepSize);
                        %Ensure that the motion vectors will only consider
                        %speckles which represent the speckle displacement of
                        %the muscle tissue
                        currentKernelMask1 = I_bw1(row1,col1);
                        currentKernelMask2 = I_bw2(row2,col2);

                        %Calculate an SAD value to determine how similar this
                        %kernel is with the kernel being searched for
                        X = currentKernel-kernelRef;
                        SSD = sum(X(:).^2); 
                        MAD = max(abs(X(:)));
                        %SAD = sum(abs(X(:)));                        
                        SAD = abs(sum(currentKernel(:))-sum(kernelRef(:)));
                        % If this kernel has a smaller difference with the
                        % reference kernel, replace the best kernel with this
                        % kernel
                        
                        if SAD < best_SAD && currentKernelMask1 == 0
                            best_SAD = SAD;
                            rowtemp = row2;
                            coltemp = col2;
                        end

                    end
                end
                % Store data regarding whether the current coordinate
                % is a part of the cardiomyocytes in the ultrasound
                if currentKernelMask1 == 0
                    segmentedObject(kernelCount) = true;
                else
                    objectCount = objectCount + 1;
                    segmentedObject(kernelCount) = false;
                end
                
                %Best match found for this pixel

                % Store these variables in a 2D array, so the results can be
                % plotted later
                plt_rowcol1(kernelCount,1) = row1;
                plt_rowcol1(kernelCount,2) = col1;
                
                plt_rowcol2(kernelCount,1) = rowtemp;
                plt_rowcol2(kernelCount,2) = coltemp;

                %Calculate the velocity for this motion vector
                rawVelocity(kernelCount) = sqrt((rowtemp-row1)^2+(coltemp-col1)^2)/(50);

                % Keep track on the total amount of kernels for indexing
                kernelCount = kernelCount + 1;
            end
        end
        %Store the total difference between the original position and
        %the new position of each kernel
        plt_diff = plt_rowcol2 - plt_rowcol1;

        %average velocity vector
        avgMV_X = sum(plt_diff(:,1)) / kernelCount;
        avgMV_Y = sum(plt_diff(:,2)) / kernelCount;

        medianMV_X = median(plt_diff(:,1));
        medianMV_Y = median(plt_diff(:,2));

        %Store the average motion velocity vector in a matrix
        avgMV = [avgMV_X,avgMV_Y,0];
        medianMV = [medianMV_X,medianMV_Y,0];

        noisyVectors = 0;
        %For all of the motion vectors observed
        for i = noiseCTR:size(plt_diff,1)
           %Store the currently selected motion vector in a matrix
           mv = [plt_diff(i,1), plt_diff(i,2),0];
           %Calculate the angle (using the tangent) between the average
           %velocity vector and the currently selected motion vector
           angle = atan2d(norm(cross(mv,avgMV)),dot(mv,avgMV));
           %If the angle is greater than the threshold, deem it as noise or
           %unusable data, and reset the motion vector (set it to 0, to signify
           %that the difference in position between two frames of a block is 0)
           if (angle > 10)
               plt_diff(i,1) = 0;
               plt_diff(i,2) = 0;
               rawVelocity(1,i) = 0;

              noisyVelocity(1,i) = true;
              noisyVectors = noisyVectors + 1;

               %Recalculate the average vector so further comparisons can be
               %made
               avgMV_X = sum(plt_diff(:,1)) / (kernelCount - noisyVectors);
               avgMV_Y = sum(plt_diff(:,2)) / (kernelCount - noisyVectors);
    
               %Store the average motion velocity vector in a matrix
              avgMV = [avgMV_X,avgMV_Y,0];
           else
               noisyVelocity(1,i) = false;
           end 
        end
        noiseCTR = size(plt_diff,1);
     end        
        ctr = 1;
        for i=1:size(noisyVelocity,2)-1
            if noisyVelocity(1,i) == false && segmentedObject(1,i) == true
                finalVelocity(1,ctr) = rawVelocity(1,i);
                ctr = ctr + 1;
            else
                continue;
            end
        end

         avgVelocity = sum(finalVelocity) / size(finalVelocity,2);
         medianVelocity = median(finalVelocity);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOT RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    totalVelocity = sum(size(finalVelocity))-1;
    frameVector = zeros(1,totalVelocity);
    frameVector(1,1:totalVelocity) = fr;

    % RGB Output
    subplot(2,2,1);
    imshow(Im(:,:,:,fr));
    title('RGB Ultrasound Image');
    hold on;
    quiver(plt_rowcol1(:,2),plt_rowcol1(:,1),plt_diff(:,2),plt_diff(:,1),'AutoScale','off');
    hold off;
    
    % Mask output
    subplot(2,2,2);
    imshow(I_bw2);
    title('Greyscale Ultrasound Image');
    hold on;
    quiver(plt_rowcol1(:,2),plt_rowcol1(:,1),plt_diff(:,2),plt_diff(:,1),'color',[1,0,0]);
    hold off;    
        
    % Plot the average velocity of muscle contraction during each frame    
    % Velocity output
    subplot(2,2,[3,4]);
    title('Average Velocity per Frame');
    
    
    hold on;
    % Plot all of the velocity vectors as a scatter plot
    for i=1:size(finalVelocity)
        p1 = scatter(frameVector,finalVelocity,'MarkerEdgeColor','black','MarkerEdgeAlpha',0.4,'SizeData',2.5);
    end
    % Overlay a plot depicting the average and median velocity values
    % between each frame of the ultrasound image
    p2 = plot([fr_plt1,fr],[vel_plt1,avgVelocity],'red');
    p3 = plot([fr_plt1,fr],[vel_plt2,medianVelocity],'blue');

    xlabel('Frame #') % x-axis label
    ylabel('Average Velocity');
    legend([p2,p3],'Mean','Median','Location','northwest');
    
    hold off;
    
    % Store these values for the next plot
    fr_plt1 = fr;
    vel_plt1 = avgVelocity;
    vel_plt2 = medianVelocity;
    
    % Pause to allow figures to update
    pause(0.0001);
end
% Time to complete processing all frames of this ultrasound image
%searchTime = toc;
disp('end of script');