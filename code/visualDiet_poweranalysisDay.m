

%% Power analysis for linear mixed effects models

data_path = getpref('visualDiet','visualDietDataPath');
load([data_path '/pilotVD'],'M','T','subject_data')

participants = unique(M.record_id);

sample_size2 = 20:1:150;

for i = 1:length(sample_size2)
    for j = 1:1000
        sim_subject = datasample(unique(T.record_id),sample_size2(i),'Replace',true);

        for k = 1:length(sim_subject)
            temp = T(T.record_id==sim_subject(k),:);
            if k==1
                sim_data = temp;
            else
                sim_data = [sim_data;temp];
            end
        end

        mdl_Light = fitlme(sim_data,'Light~ha+migraine+vsHigh+disability+(repeat|record_id)');
        est_Light(i,j,:) = double(mdl_Light.Coefficients(2:5,2));
        lower_Light(i,j,:) = double(mdl_Light.Coefficients(2:5,7));
        upper_Light(i,j,:) = double(mdl_Light.Coefficients(2:5,8));
        p_Light(i,j,:) = double(mdl_Light.Coefficients(2:5,6));

        mdl_Outdoor = fitlme(sim_data,'light_min1000~ha+migraine+vsHigh+disability+(repeat|record_id)');
        est_Outdoor(i,j,:) = double(mdl_Outdoor.Coefficients(2:5,2));
        lower_Outdoor(i,j,:) = double(mdl_Outdoor.Coefficients(2:5,7));
        upper_Outdoor(i,j,:) = double(mdl_Outdoor.Coefficients(2:5,8));
        p_Outdoor(i,j,:) = double(mdl_Outdoor.Coefficients(2:5,6));

        mdl_mEDIpDay = fitlme(sim_data,'mEDI_min250~ha+migraine+vsHigh+disability+(repeat|record_id)');
        est_mEDIpDay(i,j,:) = double(mdl_mEDIpDay.Coefficients(2:5,2));
        lower_mEDIpDay(i,j,:) = double(mdl_mEDIpDay.Coefficients(2:5,7));
        upper_mEDIpDay(i,j,:) = double(mdl_mEDIpDay.Coefficients(2:5,8));
        p_mEDIpDay(i,j,:) = double(mdl_mEDIpDay.Coefficients(2:5,6));

        mdl_mEDIpEve = fitlme(sim_data,'mEDI_max10~ha+migraine+vsHigh+disability+(repeat|record_id)');
        est_mEDIpEve(i,j,:) = double(mdl_mEDIpEve.Coefficients(2:5,2));
        lower_mEDIpEve(i,j,:) = double(mdl_mEDIpEve.Coefficients(2:5,7));
        upper_mEDIpEve(i,j,:) = double(mdl_mEDIpEve.Coefficients(2:5,8));
        p_mEDIpEve(i,j,:) = double(mdl_mEDIpEve.Coefficients(2:5,6));

        mdl_mEDIpNight = fitlme(sim_data,'mEDI_max1~ha+migraine+vsHigh+disability+(repeat|record_id)');
        est_mEDIpNight(i,j,:) = double(mdl_mEDIpNight.Coefficients(2:5,2));
        lower_mEDIpNight(i,j,:) = double(mdl_mEDIpNight.Coefficients(2:5,7));
        upper_mEDIpNight(i,j,:) = double(mdl_mEDIpNight.Coefficients(2:5,8));
        p_mEDIpNight(i,j,:) = double(mdl_mEDIpNight.Coefficients(2:5,6));

        mdl_mEDI_M = fitlme(sim_data,'mEDI_M~ha+migraine+vsHigh+disability+(repeat|record_id)');
        est_mEDI_M(i,j,:) = double(mdl_mEDI_M.Coefficients(2:5,2));
        lower_mEDI_M(i,j,:) = double(mdl_mEDI_M.Coefficients(2:5,7));
        upper_mEDI_M(i,j,:) = double(mdl_mEDI_M.Coefficients(2:5,8));
        p_mEDI_M(i,j,:) = double(mdl_mEDI_M.Coefficients(2:5,6));

        mdl_mEDI_A = fitlme(sim_data,'mEDI_A~ha+migraine+vsHigh+disability+(repeat|record_id)');
        est_mEDI_A(i,j,:) = double(mdl_mEDI_A.Coefficients(2:5,2));
        lower_mEDI_A(i,j,:) = double(mdl_mEDI_A.Coefficients(2:5,7));
        upper_mEDI_A(i,j,:) = double(mdl_mEDI_A.Coefficients(2:5,8));
        p_mEDI_A(i,j,:) = double(mdl_mEDI_A.Coefficients(2:5,6));

        mdl_mEDI_B = fitlme(sim_data,'mEDI_B~ha+migraine+vsHigh+disability+(repeat|record_id)');
        est_mEDI_B(i,j,:) = double(mdl_mEDI_B.Coefficients(2:5,2));
        lower_mEDI_B(i,j,:) = double(mdl_mEDI_B.Coefficients(2:5,7));
        upper_mEDI_B(i,j,:) = double(mdl_mEDI_B.Coefficients(2:5,8));
        p_mEDI_B(i,j,:) = double(mdl_mEDI_B.Coefficients(2:5,6));

        clear mdl_* sim_data sim_subject
    end
end
clear sim_data

analysis_path = getpref('visualDiet','visualDietAnalysisPath');
save([analysis_path '/powerVDbyday'])
