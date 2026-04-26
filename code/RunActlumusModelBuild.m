% Build Actlumus Model
data_path = getpref('visualDiet','visualDietDataPath');
addpath '/Users/pattersonc/Documents/MATLAB/commonFx'

load([data_path '/Actlumus/Actlumus validation/actlumusValidationAllbin1updated.mat'],'actlumusAll')

%% select test data
trainData = actlumusAll(actlumusAll.trainData==1,:);

%% Logistic regression
% mdl_param = "wearLabel ~ down + hang + lightlog + daytime";
% % mdl_param = "wearLabel ~ pca1 + pca2 + pca3";
% Y = trainData.wearLabel;
% Mdl = fitmnr(trainData,mdl_param);
% trueLabel = Y;
% [predLabel,scoresMdl] = predict(Mdl,trainData);
% rocObj = rocmetrics(trueLabel,scoresMdl,Mdl.ClassNames);
% figure
% plot(rocObj)


%% SVM
mdl_param = "wearLabel ~ down + hang + pimlog + lightlog + daytime";
Mdl = fitcecoc(trainData,mdl_param,'OptimizeHyperparameters','auto');
[~,scoresMdl] = resubPredict(Mdl);
scoreMdl = scoresMdl(:,Mdl.ClassNames);
predLabel = resubPredict(Mdl);
Y = trainData.wearLabel;
trueLabel = Y(~isundefined(trainData.wearLabel));


%% Random Forest Plot
% X = trainData(:, {'down','hang','pimlog','lightlog','daytime'});
% Y = trainData.wearLabel;
% Mdl = TreeBagger(100,X,Y,'Method', 'classification','OOBPrediction', 'on', ...
%     'PredictorNames', X.Properties.VariableNames);
% [Ypred,scoresMdl] = predict(Mdl,X);
% predLabel = categorical(Ypred);
% trueLabel = Y;


%% Leave-one-out Cross-validation by tester
crossValid = struct;
testers = unique(trainData.tester);
cv_accuracy = zeros(length(testers), 1);
for i = 1:length(testers)
    % Partition
    testIdx = (trainData.tester == testers(i));
    trainIdx = ~testIdx;

    % Train

    % LR
    % mdl = fitmnr(trainData(trainIdx,:),mdl_param);
    % [ypred,scoresmdl] = predict(mdl,trainData(testIdx,:));
    
    % SVM
    mdl = fitcecoc(trainData(trainIdx,:),mdl_param,'OptimizeHyperparameters','auto');
    [ypred,scoresmdl] = predict(mdl,trainData(testIdx,:));

    % Forest
    % mdl = TreeBagger(100,X(trainIdx,:),Y(trainIdx),'Method', 'classification','OOBPrediction', 'on', ...
    % 'PredictorNames', X.Properties.VariableNames);
    % [ypred,scoresmdl] = predict(mdl,X(testIdx,:));

    
    predlabel = categorical(ypred);
    truelabel = Y(testIdx);

    % Evaluate
    cv_accuracy(i) = mean(predlabel == truelabel);
    crossValid.mdl{i} = mdl;
    crossValid.accuracy{i} = cv_accuracy(i);
    crossValid.testpred{i} = predlabel;
    crossValid.testtrue{i} = truelabel;
end
meanAccuracy = mean(cv_accuracy);

%% Plot AUCs
rocObj = rocmetrics(trueLabel,scoresMdl,Mdl.ClassNames);

figure
plot(rocObj)

testers = unique(trainData.tester);
fullMdl_accuracy = zeros(length(testers), 1);
for i = 1:length(testers)
    fullMdl_accuracy(i) = mean(predLabel(trainData.tester==testers(i)) ==trueLabel(trainData.tester==testers(i)));
end
meanFullAccuracy = mean(fullMdl_accuracy);

CM = confusionmat(trueLabel,predLabel);
figure
confusionchart(CM)

ss = NaN*ones(size(CM,1),1);
for i = 1:size(CM,1)
    TP = CM(i,i);
    FP = sum(CM(:,i))-TP;
    FN = sum(CM(i,:))-TP;
    TN = sum(sum(CM(:,:)))-(TP+FP+FN);
    ss(i,1) = TP/(TP+FN);
    ss(i,2) = TN/(TN+FP);
end



%% Save model

save([data_path '/Actlumus/Actlumus validation/mdlSVMupdated2.mat'],'Mdl','rocObj','trainData','actlumusAll','ss','fullMdl_accuracy')