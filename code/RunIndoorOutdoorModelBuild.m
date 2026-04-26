% Build Actlumus Model
data_path = getpref('visualDiet','visualDietDataPath');
addpath '/Users/pattersonc/Documents/MATLAB/commonFx'

load([data_path '/Actlumus/Actlumus validation/actlumusValidationAllbin1updated.mat'],'actlumusAll')

% Add summer/winter variable
Month = month(actlumusAll.DATETIME);
actlumusAll.Season = zeros(height(actlumusAll),1);
actlumusAll.Season(Month>4) = 1;

T = actlumusAll(~isnan(actlumusAll.indoorReal) & actlumusAll.Season==0,:);




%% outdoor model
trueLabelIndoor = T.indoorReal;
predLabelIndoor  = T.indoor;

CMindoor = confusionmat(trueLabelIndoor,predLabelIndoor);
confusionchart(CMindoor)

ss = NaN*ones(size(CMindoor,1),1);
for i = 1:size(CMindoor,1)
    TP = CMindoor(i,i);
    FP = sum(CMindoor(:,i))-TP;
    FN = sum(CMindoor(i,:))-TP;
    TN = sum(sum(CMindoor(:,:)))-(TP+FP+FN);
    ss(i,1) = TP/(TP+FN);
    ss(i,2) = TN/(TN+FP);
end



testers = unique(T.tester);
fullMdl_accuracy = zeros(length(testers), 1);
for i = 1:length(testers)
    fullMdl_accuracy(i) = mean(predLabelIndoor(T.tester==testers(i))==trueLabelIndoor(T.tester==testers(i)));
end
meanFullAccuracy = mean(fullMdl_accuracy);



%% Save model

save([data_path '/Actlumus/Actlumus validation/mdlIndoorOutdoor.mat'],'T','actlumusAll','ss','fullMdl_accuracy')