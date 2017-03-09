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
Im = dicomread('data\IM_0001-Bmode');
disp('DICOM Image Loaded!');
disp('------------------------');
disp('Initialising Variables...');
%Obtain base frame and future frame for comparison
Fr1 = Im(:,:,1,2);
Fr2 = Im(:,:,1,3);



w = zeros(100,100);  %SEARCH WINDOW

S = 20; %S = Step Size
centreKernel = 1; %Flag for verifying if optimal estimate has been found
totalDisplacement = 1; %distanceTravelled = sqrt(x1 - x2).^2 + (y1 - y2).^2 + ...)
velocity = 1; %Velocity value for estimating the muscle movement per frame
Frame_Rate = 50; %Extracted from the DICOM file info

blockSize = S/2;
blockCount = (((size(Fr1,1)-40) - 110)/blockSize * (size(Fr1,2) - 20) - 110)/blockSize;
midpoint = blockSize/2;


x1 = 1;
y1 = 1;
x2 = 1;
y2 = 1;

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
clc;
disp('------------------------');
disp('Executing the Algorithms');
disp('------------------------');
    
%Iterate through all frames of the DICOM image
for fr=1:2
   
    %Get the first frame as a reference point
    Fr1 = Im(:,:,1,fr);
    %Get the subsequent frame for motion estimation
    Fr2 = Im(:,:,1,fr+1);
    
    %Empty matrices from the previous frame iteration
    ov = zeros(blockCount,2);
    mv = zeros(blockCount,2);
    
    %mv_x = zeros(size(Im(:,:,1,1)));
    %mv_y = zeros(size(Im(:,:,1,1)));
    
    %ov_x = zeros(size(Im(:,:,1,1)));
    %ov_y = zeros(size(Im(:,:,1,1)));
    
    %Reset the displacement value stored from the previous frame iteration
    totalDisplacement = 0;
    blockNo = 1;
    
    %Iterate through all of the block of pixels in the image
    for x1=110:blockSize:size(Fr1,1)-40
        for y1=110:blockSize:size(Fr1,2)-20       
            
            kOrg = Fr1(x1:x1+S,y1:y1+S);
            
            %Reset variables from the previous iteration
            x2 = x1;
            y2 = y1;
            iterations = 1;
            centreKernel = false;
            
            while centreKernel ~= true && iterations < 4
                
                k0 = Fr2(x2:x2+S,y2:y2+S);
                k1 = Fr2(x2-S:x2,y2-S:y2);
                k2 = Fr2(x2:x2+S,y2-S:y2);
                k3 = Fr2(x2+S:x2+S+S,y2-S:y2);
                k4 = Fr2(x2+S:x2+S+S,y2:y2+S);
                k5 = Fr2(x2+S:x2+S+S,y2:y2+S);
                k6 = Fr2(x2-S:x2,y2:y2+S);
                k7 = Fr2(x2:x2+S,y2+S:y2+S+S);
                k8 = Fr2(x2+S:x2+S+S,y2+S:y2+S+S);
       
                %DEFAULT: Centre block is initially the best SAD
                best_SAD = sum(sum(abs(k0-kOrg)));
                centreKernel = true;

                %K1 Check
                SAD=sum(sum(abs(k1-kOrg)));
                if (SAD < best_SAD)
                    best_SAD = SAD;
                    x2 = x2 - S;
                    y2 = y2 - S;    
                    centreKernel = false;
                end
                %K2 Check
                SAD=sum(sum(abs(k2-kOrg)));
                if (SAD < best_SAD)
                    best_SAD = SAD;
                   %ii = ii;
                    y2 = y2 - S;
                    centreKernel = false;
                end
                %K3 Check
                SAD=sum(sum(abs(k3-kOrg)));
                if (SAD < best_SAD)
                    best_SAD = SAD;
                    x2 = x2 + S;
                    y2 = y2 - S;
                    centreKernel = false;
                end
                %K4 Check
                SAD=sum(sum(abs(k4-kOrg)));
                if (SAD < best_SAD)
                    best_SAD = SAD;
                    x2 = x2 - S;
                   %jj = jj;
                    centreKernel = false;
                end
                %K5 Check
                SAD=sum(sum(abs(k5-kOrg)));
                if (SAD < best_SAD)
                    best_SAD = SAD;
                    x2 = x2 + S;
                   %jj = jj;
                    centreKernel = false;
                end
                %K6 Check
                SAD=sum(sum(abs(k6-kOrg)));
                if (SAD < best_SAD)
                    best_SAD = SAD;
                    x2 = x2 - S;
                    y2 = y2 + S;
                    centreKernel = false;
                end
                %K7 Check
                SAD=sum(sum(abs(k7-kOrg)));
                if (SAD < best_SAD)
                    best_SAD = SAD;
                   %ii = ii;
                    y2 = y2 + S;
                    centreKernel = false;
                end
                %K8 Check
                SAD=sum(sum(abs(k8-kOrg)));
                if (SAD < best_SAD)
                    best_SAD = SAD;
                    x2 = x2 + S;
                    y2 = y2 + S;
                    centreKernel = false;
                end
                
                iterations = iterations + 1;
                
            end
            % BLOCK LOCATED: STEP 4
            
            
            %ov_x(x1+midpoint,y1+midpoint) = x1;
            %ov_y(x1+midpoint,y1+midpoint) = y1;
            
            %mv_x(x1+midpoint,y1+midpoint) = x2;
            %mv_y(x1+midpoint,y1+midpoint) = y2;
            
            ov(blockNo,1) = x1;
            ov(blockNo,2) = y1;
            
            mv(blockNo,1) = x2;
            mv(blockNo,2) = y2;
            
            blockNo = blockNo + 1;
            
            totalDisplacement = totalDisplacement + ((x2 - x1).^2 + (y2 - y1).^2);
            
            %output to debug to monitor progress
            
            progress = blockNo / 3129 * 100;
            
            clc;
            disp('------------------------');
            str = sprintf('FRAME = %d', fr);
            disp(str);
            disp('------------------------');
            str = sprintf('Progress = %.1f%%',progress);
            disp(str);

            
        end
    end
    totalDisplacement = sqrt(totalDisplacement);
    velocity = totalDisplacement / Frame_Rate;
    
    disp('Outputting Results...');
    
    figure;
    imshow(Im(:,:,:,fr));
    
    hold on;
    quiver(ov(:,2),ov(:,1),mv(:,2)-ov(:,2),mv(:,1)-ov(:,1),0);
    hold off;
    pause(0.5);
    disp('Motion Estimation Analysis Complete!');
    pause(1);
    disp('Analysing next frame...');
    pause(1);
    
end


disp('end of script');