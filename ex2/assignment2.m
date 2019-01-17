load('FaceData.mat');
p = 56; % image width
q = 46; % image height
d = p*q;
subjectCount = 40;
facesPerSubject = 10;
n = (subjectCount/2) * facesPerSubject; %number of samples for training
l = (subjectCount/2) * facesPerSubject; %number of samples for testing
faceTrain = zeros(d, n); % n*d matrix
faceTest = zeros(d, l); % l%d matrix
Id = zeros(1, l); % l%1 matrix
%%
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
image(FaceData(1,1).Image);
%%
phi0 = mean(faceTrain,2); %column vector with the mean value for each pixel
faceTrain0 = zeros(d, n);
for i=1:n
    faceTrain0(:, i) = faceTrain(:, i) - phi0; % subtracting to each image the mean vector
end

order_eigen_value = zeros(p*q,1);
covMatrix = 1/(n-1) * faceTrain0 * faceTrain0';
[eig_vec,eig_value] = eig(covMatrix);
diag_eig_value = diag(eig_value);
sum_eig_value = sum(diag_eig_value);
%% Compute the information present in m principal components
v = zeros(d,1);
sum_currently = 0;
m = (1:d)';
for i = 1:d
    sum_currently = sum_currently + diag_eig_value(i);
    v(i) = sum_currently/sum_eig_value;
end
figure();
plot(m,v)
%% Show eigen faces
% Show mean face
figure, imagesc(reshape(phi0, [56,46]));

m = 90;
phi_m = eig_vec(:,1:m);
% Show first 10 faces
for i=1:10
    faceColumn = phi_m(:,i);
    figure, imagesc(reshape(faceColumn,[56,46]));
end
%% Calculate scores
dissimilarityScores = zeros(l,l);
matrixA = zeros(m,l);
for i=1:l
    matrixA(:, i) = phi_m'*(faceTest(:,i)-phi0);
end

disSimScore = zeros(l,l);
for i=1:l
    for j=1:l
        disSimScore(i,j) = norm(matrixA(:,i) - matrixA(:, j));
    end
end
%%
get_scores_from_file(disSimScore, Id);