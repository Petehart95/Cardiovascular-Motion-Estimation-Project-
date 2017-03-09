close all; 
clc;

Im1 = dicomread('data\IM_0001-Bmode');


Fr1 = rgb2gray(Im1(:,:,:,1));

%temp for comparing original position
org_x = zeros(size(Fr1));
org_y = zeros(size(Fr1));

%Empty matrix for storing the new x and y values for a pixel location
mv_x = zeros(size(Fr1));
mv_y = zeros(size(Fr1));

dif_x = zeros(size(Fr1));
dif_y = zeros(size(Fr1));

c = zeros(size(Fr1));

%C = col
C=20;
%R = row
R=20;
%S = variable for storing centre of block
S=R/2;

%Iterate through all frames of the DICOM image
for fr=1:2%200
    %Get the first frame as a reference point
    Fr1 = Im1(:,:,:,fr);
    %Get the subsequent frame for motion estimation
    Fr2 = Im1(:,:,:,fr+1);
    %Iterate through all of the block of pixels in the image
    for i=40:C:size(Fr1,1)-40
        for j=40:R:size(Fr1,2)-40
            
            row1=i;
            col1=j;
            row2=i+R;
            col2=j+C;

            %FRAME A BLOCK
            a=Fr1(row1:row2,col1:col2);
            c(row1:row2, col1:col2) = 255;
            %FRAME B BLOCKS
            %Block Size = 8px x 16px 
            %Blocks have been divided in the following format:

            %| b1   | b2      | b3 %
            %| b4   | bstart  | b5 %
            %| b6   | b7      | b8 %

            % Calculate the SAD for each block in comparison to the block
            % in Frame A. Use the closest match.

            bstart=sum(sum(abs(Fr2(row1:row2,col1:col2)-a)));

            % Set the centre block as the first block for comparison
            best_SAD = bstart;
            blockSize = row2 - row1;
            row_mid = row1 + (blockSize/2);
            col_mid = col1 + (blockSize/2);
            % Vector for storing FRAME1 x values
            org_x(row_mid,col_mid) = row_mid;
            % Vector for storing FRAME1 y values
            org_y(row_mid,col_mid) = col_mid;
            
            % DEFAULT VALUE SAME AS ORIGINAL FRAME POSITION 
            %(assume no change)
            
            % Vector for storing new x values
            mv_x(row_mid,col_mid) = row_mid;
            % Vector for storing new y values
            mv_y(row_mid,col_mid) = col_mid;
            
            
            % | COMPARE BLOCKS | %
            %Comparing a block of pixels with the adjacent neighbouring pixels
            %X = rows Y = cols
            %B1 Check
            SAD=sum(sum(abs(a-Fr2(row1-R:row2-R,col1-C:col2-C))));
            if (SAD < best_SAD)
                best_SAD = SAD;
                mv_x(row_mid,col_mid) = row_mid-R;
                mv_y(row_mid,col_mid) = col_mid-C;
            end
            %B2 Check
            SAD=sum(sum(abs(a-Fr2(row1-R:row2-R,col1:col2))));
            if (SAD < best_SAD)
                best_SAD = SAD;
                mv_x(row_mid,col_mid) = row_mid-R;
                mv_y(row_mid,col_mid) = col_mid;
            end
            %B3 Check
            SAD=sum(sum(abs(a-Fr2(row1-R:row2-R,col1+C:col2+C))));
            if (SAD < best_SAD)
                best_SAD = SAD;
                mv_x(row_mid,col_mid) = row_mid-R;
                mv_y(row_mid,col_mid) = col_mid+C;
            end
            %B4 Check
            SAD=sum(sum(abs(a-Fr2(row1:row2,col1-C:col2-C))));
            if (SAD < best_SAD)
                best_SAD = SAD;
                mv_x(row_mid,col_mid) = row_mid;
                mv_y(row_mid,col_mid) = col_mid-C;
            end
            %B5 Check
            SAD=sum(sum(abs(a-Fr2(row1:row2,col1+C:col2+C))));
            if (SAD < best_SAD)
                best_SAD = SAD;
                mv_x(row_mid,col_mid) = row_mid;
                mv_y(row_mid,col_mid) = col_mid+R;
            end
            %B6 Check
            SAD=sum(sum(abs(a-Fr2(row1+R:row2+R,col1-C:col2-C))));
            if (SAD < best_SAD)
                best_SAD = SAD;
                mv_x(row_mid,col_mid) = row_mid+R;
                mv_y(row_mid,col_mid) = col_mid-C;
            end
            %B7 Check
            SAD=sum(sum(abs(a-Fr2(row1+R:row2+R,col1:col2))));
            if (SAD < best_SAD)
                best_SAD = SAD;
                mv_x(row_mid,col_mid) = row_mid+R;
                mv_y(row_mid,col_mid) = col_mid;
            end
            %B8 Check
            SAD=sum(sum(abs(a-Fr2(row1+R:row2+R,col1+C:col2+C))));
            if (SAD < best_SAD)
                best_SAD = SAD;
                mv_x(row_mid,col_mid) = row_mid+R;
                mv_y(row_mid,col_mid) = col_mid+C;
            end
            
            dif_x(row_mid,col_mid) = mv_x(row_mid,col_mid) - org_x(row_mid,col_mid);
            dif_y(row_mid,col_mid) = mv_y(row_mid,col_mid) - org_y(row_mid,col_mid);
        end
    end
    
    avg_x = sum(sum(dif_x(:,:)));
    avg_y = sum(sum(dif_y(:,:)));
    %APPLY THE MOTION VECTOR
    imshow(Im1(:,:,:,fr));
    title(num2str(fr));
    hold on;
    Im1(110:20:end-20,:,:) = 254;     
    Im1(:,110:20:end-40,:) = 254; 
   % quiver(org_y,org_x,dif_y,dif_x,0)
    hold off;
    pause(0.01);
    %imshow(c);
end
%figure;
%imshow(Im1(:,:,:,1));
