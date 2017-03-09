
disp('Parallel Test...');

tic
parfor i=1:10000
    for j=1:10000
    end
end
toc

disp('Serial Test...');
pause(3);

tic
for i=1:10000
    for j=1:10000
    end
end
toc
