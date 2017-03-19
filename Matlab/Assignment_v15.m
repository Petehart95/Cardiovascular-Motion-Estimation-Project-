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
Im = dicomread('E:\Year 3\Project\patient_data\IM_0025-Bmode');
disp('DICOM Image Loaded!');
disp('------------------------');
disp('Initialising Variables...');
%Obtain base frame and future frame for comparison
Fr1 = Im(:,:,1,2);
Fr2 = Im(:,:,1,3);

centreKernel = 0; %Flag for verifying if optimal estimate has been found
pxDistance = 0; %distanceTravelled = sqrt(x1 - x2).^2 + (y1 - y2).^2 + ...)
velocity = 0; %Velocity value for estimating the muscle movement per frame

Im_struct = size(Im(:,:,:,:)); %Store structural information about the DICOM image for reference later on
totalRows = (Im_struct(1));
totalColumns = (Im_struct(2));
totalChannels = (Im_struct(3));
totalFrames = (Im_struct(4));

P = 8;

blockSize = P;
blockCount = 1; %initial value for total blocks in each frame
midpoint = blockSize/2; %mid point of each block

disp('Variables Initialised!');
disp('------------------------');


%Clear command line, inform the user that the image is ready to be analysed
%so they are aware of what stage the algorithm is at
clc;
disp('------------------------');
disp('Executing the Algorithms');
disp('------------------------');

disp('Beginning DICOM Image Analysis.');
pause(1);
clc;
disp('------------------------');
disp('Executing the Algorithms');
disp('------------------------');

disp('Beginning DICOM Image Analysis..');
pause(1);
clc;
disp('------------------------');
disp('Executing the Algorithms');
disp('------------------------');
disp('Beginning DICOM Image Analysis...');
pause(1);


%Iterate through all frames of the DICOM image
for fr=1:totalFrames-1
    tic
    %Get the first frame as a reference point
    Fr1 = Im(:,:,1,fr);
    %Get the subsequent frame for motion estimation
    Fr2 = Im(:,:,1,fr+1);
    
    %Empty matrices from the previous frame iteration
    ov = zeros(blockCount,2);
    mv = zeros(blockCount,2);
    
    %Reset the displacement value stored from the previous frame iteration
    totalDistanceCm = 0;
    
    %Reset the block count from the previous frame iteration
    blockNo = 1;
    
    %Three-step search procedure(TSS)
    %Iterate through all of the block of pixels in the image
    for x1=110:P:totalRows-20
        for y1=110:P:totalColumns-20      
            
            %Reset variables from the previous iteration
            x2 = x1;
            y2 = y1;
            
            %Reset the step size value
            S = 4;

            %While the step size is not 1, continue searching for the best
            %block in frame n + 1.
            while(S > 1)
                kOrg = Fr1(x1:x1+S,y1:y1+S);
                
                %Obtain the next 9 blocks from Frame n + 1
                %Centre block does not need to be checked, as it should
                %already be within the index range of the reference image
                k0 = Fr2(x2:x2+S,y2:y2+S);             
                
                %If a block exceeds the image size, initialise it as an
                %empty block
                k1 = Fr2(x2-S:x2,y2-S:y2);
                k2 = Fr2(x2:x2+S,y2-S:y2);
                k3 = Fr2(x2+S:x2+S+S,y2-S:y2);
                k4 = Fr2(x2-S:x2,y2:y2+S);
                k5 = Fr2(x2+S:x2+S+S,y2:y2+S);
                k6 = Fr2(x2-S:x2,y2+S:y2+S+S);
                k7 = Fr2(x2:x2+S,y2+S:y2+S+S);
                k8 = Fr2(x2+S:x2+S+S,y2+S:y2+S+S);
                
                %DEFAULT: Start with the origin being in the centre
                best_SAD = sum(sum(abs(k0-kOrg)));
                xtemp = x2;
                ytemp = y2;
                centreKernel = 1;
                
                %K1 Check
                SAD=sum(sum(abs(k1-kOrg)));
                if (SAD < best_SAD)
                    best_SAD = SAD;
                    xtemp = x2 - S;
                    ytemp = y2 - S;    
                    centreKernel = 0;
                end
                %K2 Check
                SAD=sum(sum(abs(k2-kOrg)));
                if (SAD < best_SAD)
                    best_SAD = SAD;
                    xtemp = x2;
                    ytemp = y2 - S;
                    centreKernel = 0;
                end
                %K3 Check
                SAD=sum(sum(abs(k3-kOrg)));
                if (SAD < best_SAD)
                    best_SAD = SAD;
                    xtemp = x2 + S;
                    ytemp = y2 - S;
                    centreKernel = 0;
                end
                %K4 Check
                SAD=sum(sum(abs(k4-kOrg)));
                if (SAD < best_SAD)
                    best_SAD = SAD;
                    xtemp = x2 - S;
                    ytemp = y2;
                    centreKernel = 0;
                end
                %K5 Check
                SAD=sum(sum(abs(k5-kOrg)));
                if (SAD < best_SAD)
                    best_SAD = SAD;
                    xtemp = x2 + S;
                    ytemp = y2;
                    centreKernel = 0;
                end
                %K6 Check
                SAD=sum(sum(abs(k6-kOrg)));
                if (SAD < best_SAD)
                    best_SAD = SAD;
                    xtemp = x2 - S;
                    ytemp = y2 + S;
                    centreKernel = 0;
                end
                %K7 Check
                SAD=sum(sum(abs(k7-kOrg)));
                if (SAD < best_SAD)
                    best_SAD = SAD;
                    xtemp = x2;
                    ytemp = y2 + S;
                    centreKernel = 0;
                end
                %K8 Check
                SAD=sum(sum(abs(k8-kOrg)));
                if (SAD < best_SAD)
                    best_SAD = SAD;
                    xtemp = x2 + S;
                    ytemp = y2 + S;
                    centreKernel = 0;
                end
                x2 = xtemp;
                y2 = ytemp;
                
                S = S / 2;
            end %while loop terminated here
            % BLOCK LOCATED: STEP 4
            ov(blockNo,1) = x1;
            ov(blockNo,2) = y1;
            
            mv(blockNo,1) = x2 - x1;
            mv(blockNo,2) = y2 - y1;
                        
            
            %Calibration factor = known distance in cm / known distance in
            %pixels
            %calibrationFactor = 10/30;
            
            %Re-gather the distance of the motion vector
            %distanceInPixelsX = mv(blockNo,1);
            %distanceInPixelsY = mv(blockNo,2);
            
            %Convert the from a pixel unit of distance to centimetres
            %distanceInCmX = distanceInPixelsX * calibrationFactor;
            %distanceInCmY = distanceInPixelsY * calibrationFactor;
            
            %totalDistanceCm = totalDistanceCm + (distanceInCmX).^2 + (distanceInCmY).^2;            
            pxDistance = pxDistance + ((y2 - y1).^2 + (x2 - x1).^2);

            blockNo = blockNo + 1;
        end
    end %nested for loop terminated here
    searchTime = toc;
    pxDistance = sqrt(pxDistance);
    velocity = pxDistance / searchTime;
    %cmDistance = pxDistance / 30;
    %velocity = sqrt(totalDistanceCm) / 50;
    %velocityArr(fr) = velocity;

    %average velocity vector
    avgMV_X = sum(mv(:,1)) / sum(size(mv(:,1)));
    avgMV_Y = sum(mv(:,2)) / sum(size(mv(:,2)));
    
    %Calculate the inverse tangent from the motion vector to find
    %the angle
    avgMV_TAN = atan(avgMV_Y/avgMV_X);
    
    %For all of the motion vectors perceived, calculate the tangent to find
    %the angle of the motion vector
    for i=1:size(mv,1)
        mv_x = mv(i,1);
        mv_y = mv(i,2);
        mv_TAN = atan(mv_y/mv_x);
        %If this motion vector has an angle difference greater than 180
        %degrees, flag it and ignore it.  Reset the motion vector value to
        %default.
        if mv_TAN > 180
            mv(i,1) = ov(i,1);
            mv(i,2) = ov(i,2);
        end
    end
    
    subplot(1,2,1);
    hold on;
    scatter(fr,velocity);
    hold off;
    subplot(1,2,2);
    imshow(Im(:,:,:,fr));
    hold on;
    quiver(ov(:,2),ov(:,1),mv(:,2),mv(:,1),'color',[1,0,0]);
    hold off;
    pause(0.0001);
end
disp('end of script');