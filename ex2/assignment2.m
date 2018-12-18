load('FaceData.mat');
faceTrain = struct([]);
faceTest = struct;
for i=1:20
    for j=1:10
        imageDouble = double(FaceData(i,j).Image)/255;
        faceTrain.i.j = imageDouble(:);
    end
end