close all; 
clc;

Im = dicomread('C:\Users\Peter\Documents\MATLAB\Project\data\IM_0001-Bmode');

Fr1 = rgb2gray(Im(:,:,:,1));
Fr2 = rgb2gray(Im(:,:,:,2));

u = rgb2gray(Im(:,:,:,1));
v = rgb2gray(Im(:,:,:,1));

% X1 = [0,0,0;
%      0,0,0;
%      0,0,0;];
%  
% X2 = [0,0,0;
%      0,0,0;
%      0,0,0;];
%  
% X3 = [0,0,0;
%      0,0,0;
%      0,0,0;];
 




% searchArea(row1:row2,col1:col2);
S=4;
B=16;


%Search Window
for i=16:size(Fr1,1)
    for j=16:size(Fr1,2)
        
        row1=B;
        col1=B;
        row2=B+B-1;
        col2=B+B-1;
        
        %FRAME A BLOCK
        a=Fr1(row1:row2,col1:col2);
        
        %FRAME B BLOCKS
        %Blocks have been divided in the following format:
        
        %| b1   | b2      | b3 %
        %| b4   | bstart  | b5 %
        %| b6   | b7      | b8 %
        
        % Calculate the SAD for each block in comparison to the block
        % in Frame A. Use the closest match.

        bstart=sum(sum(abs(a-Fr2(row1:row2,col1:col2))));
        
        % Set the centre block as the first block for comparison
        flag = bstart;
        centre = 1;
        
        % | COMPARE BLOCKS | %
        
        b1=sum(sum(abs(a-Fr2(row1-B:row2-B,col1-B:col2-B))));
        if (b1 < flag)
            flag = b1;
            centre = 0;
        end
        b2=sum(sum(abs(a-Fr2(row1-B:row2-B,col1:col2))));
        if (b2 < flag)
            flag = b2;
            centre = 0;
        end
        b3=sum(sum(abs(a-Fr2(row1-B:row2-B,col1+B:col2+B))));
        if (b3 < flag)
            flag = b3;
            centre = 0;
        end
        b4=sum(sum(abs(a-Fr2(row1:row2,col1-B:col2-B))));
        if (b4 < flag)
            flag = b4;
            centre = 0;
        end
        b5=sum(sum(abs(a-Fr2(row1:row2,col1+B:col2+B))));
        if (b5 < flag)
            flag = b5;
            centre = 0;
        end
        b6=sum(sum(abs(a-Fr2(row1+B:row2+B,col1-B:col2-B))));
        if (b6 < flag)
            flag = b6;
            centre = 0;
        end
        b7=sum(sum(abs(a-Fr2(row1+B:row2+B,col1:col2))));
        if (b7 < flag)
            flag = b7;
            centre = 0;
        end
        b8=sum(sum(abs(a-Fr2(row1+B:row2+B,col1+B:col2+B))));
        if (b8 < flag)
            flag = b8;
            centre = 0;
        end
        
    
        % STAGE 1: FINISH %
        
        % STAGE 2 %
        % (Applicable if closest match was not the centre block)
        
    end
end
% S = 1; %step-size
% flag = 5;



% for i=2:size(Fr1,1)-S %Go through all pixels in frame 1
%     for j=2:size(Fr1,2)-S
%          X1(1,1) = Fr1(i-S,j-S);
%          X1(2,1) = Fr1(i,j-S);
%          X1(3,1) = Fr1(i+S,j-S);
%          X1(1,2) = Fr1(i-S,j);
%          X1(2,2) = Fr1(i,j);
%          X1(3,2) = Fr1(i+S,j);
%          X1(1,3) = Fr1(i-S,j+S);
%          X1(2,3) = Fr1(i,j+S);
%          X1(3,3) = Fr1(i+S,j+S);
%          
%          for ii=2:size(Fr2,1)-S
%              for jj=2:size(Fr2,2)-S
%                  X2(1,1) = Fr2(ii-S,jj-S);
%                  X2(2,1) = Fr2(ii,jj-S);
%                  X2(3,1) = Fr2(ii+S,jj-S);
%                  X2(1,2) = Fr2(ii-S,jj);
%                  X2(2,2) = Fr2(ii,jj);
%                  X2(3,2) = Fr2(ii+S,jj);
%                  X2(1,3) = Fr2(ii-S,jj+S);
%                  X2(2,3) = Fr2(ii,jj+S);
%                  X2(3,3) = Fr2(ii+S,jj+S);
% 
%                  SAD = sum(sum(abs(X1-X2)));
% 
%                  if SAD < flag %Calculate the sum of absolute differences
%                      flag = SAD; %set a new flag, in case a closer match can be found
%                      
%                      iii = ii; %If closer match, store the plot point
%                      jjj = jj;
% 
%                  end
%              end
%          end
%          
%          u(i,j) = iii;
%          v(i,j) = jjj;
% 
%          
%         flag = 5; %reset SAD flag & changed flag
%     end
% end
% 
figure;
imshow(Fr1,[]);
hold on;

quiver(Fr1(1),Fr1(2),u(1),u(2));