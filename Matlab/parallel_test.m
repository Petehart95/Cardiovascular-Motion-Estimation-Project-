clc;clear;close all;

Fr1 = magic(800);
Fr2 = magic(800);

fr = 100;

tic
for n=1:fr
    parfor y1=1:780
        for x1=1:780
            m=y1+20;
                S = 20;
                y2 = y1;
                x2 = x1;
                
                s = y2 + S;
                ss = y2 + S * 2;
                sss = y2 - S;
                kOrg = Fr1(y1:y1+S,x1:x1+S);
                
                %Obtain the next 9 blocks from Frame n + 1
                %Centre block does not need to be checked, as it should
                %already be within the index range of the reference image
                k0 = Fr2(y2:s,x2:x2+S);
                
                
                %If a block exceeds the image size, initialise it as an
                %empty block
                    k1 = Fr2(y2-S:y2,x2-S:x2);
                    k2 = Fr2(y2:y2+S,x2-S:x2);
                    k3 = Fr2(y2+S:y2+S+S,x2-S:x2);
                    k4 = Fr2(y2-S:y2,x2:x2+S);
                    k5 = Fr2(y2+S:y2+S+S,x2:x2+S);
                    k6 = Fr2(y2-S:y2,x2+S:x2+S+S);
                    k7 = Fr2(y2:y2+S,x2+S:x2+S+S);
                    k8 = Fr2(y2+S:y2+S+S,x2+S:x2+S+S);       
        end
    end
end
toc
disp('end of script');