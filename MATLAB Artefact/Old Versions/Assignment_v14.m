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

P = 4;

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
    for y1=110:P:totalRows-20
        for x1=110:P:totalColumns-20      
            
            %Reset variables from the previous iteration
            y2 = y1;
            x2 = x1;
            
            %Reset the step size value
            S = 4;

            %While the step size is not 1, continue searching for the best
            %block in frame n + 1.
            
            while(S > 1)
                kOrg = Fr1(y1:y1+S,x1:x1+S);
                
                %Obtain the next 9 blocks from Frame n + 1
                %Centre block does not need to be checked, as it should
                %already be within the index range of the reference image
                k0 = Fr2(y2:y2+S,x2:x2+S);
                                
                %Create a flag variable for checking the validity of a
                %block i.e. if a block is within the bounds of the image
                k1_valid = 1;
                k2_valid = 1;
                k3_valid = 1;
                k4_valid = 1;
                k5_valid = 1;
                k6_valid = 1;
                k7_valid = 1;
                k8_valid = 1;
                
               
                %If a block exceeds the image size, initialise it as an
                %empty block
                if(y2 - S > 0 && x2 - S > 0)
                    k1 = Fr2(y2-S:y2,x2-S:x2);
                else
                    k1_valid = 0;
                end
                
                if (y2 + S < size(Fr2,1) && x2 - S > 0)
                    k2 = Fr2(y2:y2+S,x2-S:x2);
                else
                    k2_valid = 0;
                end
                
                if (y2 + S + S < size(Fr2,1) && x2 - S > 0)
                    k3 = Fr2(y2+S:y2+S+S,x2-S:x2);
                else
                    k3_valid = 0;
                end
                
                if (y2 - S > 0 && x2 + S < size(Fr2,2))
                    k4 = Fr2(y2-S:y2,x2:x2+S);
                else
                    k4_valid = 0;
                end
                
                if (y2 + S + S < size(Fr2,1) && x2 + S < size(Fr2,2))
                    k5 = Fr2(y2+S:y2+S+S,x2:x2+S);
                else
                    k5_valid = 0;
                end
                
                if (y2 - S > 0 && x2 + S + S < size(Fr2,2))
                    k6 = Fr2(y2-S:y2,x2+S:x2+S+S);
                else
                    k6_valid = 0;
                end
                
                if (y2 + S < size(Fr2,1) && x2 + S + S < size(Fr2,2))
                    k7 = Fr2(y2:y2+S,x2+S:x2+S+S);
                else
                    k7_valid = 0;
                end
                
                if (y2 + S + S < size(Fr2,1) && x2 + S + S < size(Fr2,2))
                    k8 = Fr2(y2+S:y2+S+S,x2+S:x2+S+S);
                else
                    k8_valid = 0;
                end
                

                %DEFAULT: Start with the origin being in the centre
                best_SAD = sum(sum(abs(k0-kOrg)));
                ytemp = y2;
                xtemp = x2;
                centreKernel = 1;
                
                %K1 Check
                SAD=sum(sum(abs(k1-kOrg)));
                if (SAD < best_SAD)
                    best_SAD = SAD;
                    ytemp = y2 - S;
                    xtemp = x2 - S;    
                    centreKernel = 0;
                end
                %K2 Check
                SAD=sum(sum(abs(k2-kOrg)));
                if (SAD < best_SAD)
                    best_SAD = SAD;
                    ytemp = y2;
                    xtemp = x2 - S;
                    centreKernel = 0;
                end
                %K3 Check
                SAD=sum(sum(abs(k3-kOrg)));
                if (SAD < best_SAD)
                    best_SAD = SAD;
                    ytemp = y2 + S;
                    xtemp = x2 - S;
                    centreKernel = 0;
                end
                %K4 Check
                SAD=sum(sum(abs(k4-kOrg)));
                if (SAD < best_SAD)
                    best_SAD = SAD;
                    ytemp = y2 - S;
                    xtemp = x2;
                    centreKernel = 0;
                end
                %K5 Check
                SAD=sum(sum(abs(k5-kOrg)));
                if (SAD < best_SAD)
                    best_SAD = SAD;
                    ytemp = y2 + S;
                    xtemp = x2;
                    centreKernel = 0;
                end
                %K6 Check
                SAD=sum(sum(abs(k6-kOrg)));
                if (SAD < best_SAD)
                    best_SAD = SAD;
                    ytemp = y2 - S;
                    xtemp = x2 + S;
                    centreKernel = 0;
                end
                %K7 Check
                SAD=sum(sum(abs(k7-kOrg)));
                if (SAD < best_SAD)
                    best_SAD = SAD;
                    ytemp = y2;
                    xtemp = x2 + S;
                    centreKernel = 0;
                end
                %K8 Check
                SAD=sum(sum(abs(k8-kOrg)));
                if (SAD < best_SAD)
                    best_SAD = SAD;
                    ytemp = y2 + S;
                    xtemp = x2 + S;
                    centreKernel = 0;
                end
                y2 = ytemp;
                x2 = xtemp;
                
                S = S / 2;
            end %while loop terminated here
            % BLOCK LOCATED: STEP 4
            ov(blockNo,1) = y1;
            ov(blockNo,2) = x1;
            
            mv(blockNo,1) = y2 - y1;
            mv(blockNo,2) = x2 - x1;
                        
            %pxDistance = pxDistance + ((y2 - y1).^2 + (x2 - x1).^2);
            
            %Calibration factor = known distance in cm / known distance in
            %pixels
            calibrationFactor = 10/30;
            
            %Re-gather the distance of the motion vector
            distanceInPixelsY = mv(blockNo,1);
            distanceInPixelsX = mv(blockNo,2);
            
            %Convert the from a pixel unit of distance to centimetres
            distanceInCmY = distanceInPixelsY * calibrationFactor;
            distanceInCmX = distanceInPixelsX * calibrationFactor;
            
            totalDistanceCm = totalDistanceCm + (distanceInCmY).^2 + (distanceInCmX).^2;            
            
            blockNo = blockNo + 1;

        end
    end %nested for loop terminated here
    searchTime = toc;
    %pxDistance = sqrt(pxDistance);
    %cmDistance = pxDistance / 30;
    velocity = sqrt(totalDistanceCm) / 50;
    %velocityArr(fr) = velocity;

    %average velocity vector
    avgMV_X = sum(mv(:,1)) / sum(size(mv(:,1)));
    avgMV_Y = sum(mv(:,2)) / sum(size(mv(:,1)));
    
    scatter(fr,velocity);
    hold on;
    line(fr,velocity);
    pause(0.0001);
end
disp('end of script');