load('FaceData.mat');
p = 56; % image width
q = 46; % image height
d = p*q;
subjectCount = 40;
facesPerSubject = 10;
n = (subjectCount/2) * facesPerSubject;
l = (subjectCount/2) * facesPerSubject;
faceTrain = zeros(d, n); % n*d matrix
faceTest = zeros(d, l); % l%d matrix
Id = zeros(1, l); % l%1 matrix
for i=1:subjectCount/2
    for j=1:facesPerSubject
        imageDouble = double(FaceData(i,j).Image)/255;
        faceTrain(:, i*j) = imageDouble(:);
    end
end

for i=(subjectCount/2 + 1):subjectCount
    for j=1:facesPerSubject
        imageDouble = double(FaceData(i,j).Image)/255;
        faceTest(:, (i-20)*j) = imageDouble(:);
        
        % Calculates row number in Id-matrix (1 - 200) from for-loops
        Id(:, (i-21)*10 + j) = i;
    end
end
%%
phi0 = mean(faceTrain,2);
faceTrain0 = zeros(d, n);
for i=1:n
    faceTrain0(:, i) = faceTrain(:, i) - phi0;
end


covMatrix = 1/(n-1) * faceTrain0 * faceTrain0';