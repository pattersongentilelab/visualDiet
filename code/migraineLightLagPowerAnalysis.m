% load pilot data to create simulated dataset
data_path = getpref('visualDiet','visualDietDataPath');
load([data_path '/pilotVDgrant'])

addpath '/Users/pattersonc/Documents/MATLAB/commonFx'

LightHr = T.mEDI_min250*10;
T.LightHr = LightHr;
LightScale = T.light_scale;
T.LightHr_nextDay = circshift(T.LightHr,-1);
T.LightHr_nextDay(7:7:end) = NaN;

%% Power analysis calculations for lagged light and sleep data


% --- Study Parameters ---
num_migraine = 24;         % Number of participants with migraine
num_control = 24;          % Number of control participants
num_days = 14;             % Days of recording
num_simulations = 1000;    % Number of Monte Carlo simulations for power estimate
alpha = 0.05;              % Significance level
dropout = 0.2;             % proportion dropout

% --- Mixed-Effects Model Parameters ---
% These are critical to define for the simulation.
% Use estimates from pilot data or literature.
% Fixed effects:
beta_intercept = 4.1;      % Baseline sleep midpoint (hours from midnight)
beta_group_migraine = 0.5; % Assumed difference in baseline sleep midpoint (migraine vs control)
beta_season_winter = 0.5;  % Assumed effect of winter vs summer
beta_light_lagged = -0.17; % ASSUMED EFFECT: lagged light exposure effect on sleep midpoint
beta_interaction = 0.0;   % ASSUMED INTERACTION: Migraine * lagged light effect

% Random effects variance components (standard deviations):
% These capture subject-to-subject variability.
std_subject_intercept = 1.3;    % Variability in baseline sleep midpoint
std_subject_slope_light = 0.37;  % Variability in the effect of light exposure
std_residual = 1.0;             % Within-subject observation error


% Pre-allocate storage for results
p_values_interaction = zeros(num_simulations, 1);

for i = 1:num_simulations
    % --- Simulate Data ---
    num_participants = num_migraine + num_control;
    num_observations = num_days * 2 * num_participants; % Summer and Winter

    % Subject IDs
    subject_id = repelem(1:num_participants, num_days * 2)';

    % Group variable: 0 for control, 1 for migraine
    group = [zeros(num_control * num_days * 2, 1); ones(num_migraine * num_days * 2, 1)];

    % Season variable: 0 for summer, 1 for winter
    season = repmat([zeros(num_days, 1); ones(num_days, 1)], num_participants, 1);

    % Lagged light exposure (simulated continuous variable) based on pilot data
    rep = num_days*num_migraine*2;
    light_lagged = datasample(LightScale,rep*2,'Replace',true);
   
    % Generate random effects for each subject
    random_intercepts = std_subject_intercept * randn(num_participants, 1);
    random_slopes_light = std_subject_slope_light * randn(num_participants, 1);
    
    % Generate observation-level error
    error = std_residual * randn(num_observations, 1);
    
    % Build the design matrices for random effects
    Z_intercept = dummyvar(categorical(subject_id));
    Z_slope_light = Z_intercept .* light_lagged;
    
    % Calculate the linear predictor for sleep midpoint
    fixed_effects_term = beta_intercept ...
        + beta_group_migraine * group ...
        + beta_season_winter * season ...
        + beta_light_lagged * light_lagged ...
        + beta_interaction * group .* light_lagged;
    
    random_effects_term = Z_intercept * random_intercepts + Z_slope_light * random_slopes_light;
    
    % Calculate the simulated sleep midpoint
    sleep_midpoint = fixed_effects_term + random_effects_term + error;
    sleep_midpoint(sleep_midpoint<0) = 0;

    % Add drop out
    makeNaN = randi(length(sleep_midpoint),[round(dropout*length(sleep_midpoint)),1]);
    sleep_midpoint(makeNaN) = NaN;


    % --- Fit Linear Mixed-Effects Model ---
    % Create a table for the model
    tbl = table(sleep_midpoint, group, season, light_lagged, subject_id, ...
        'VariableNames', {'SleepMidpoint', 'Group', 'Season', 'LaggedLight', 'SubjectID'});
    tbl.Group = categorical(tbl.Group);
    tbl.Season = categorical(tbl.Season);
    tbl.SubjectID = categorical(tbl.SubjectID);

    % Specify the LME formula: 
    % SleepMidpoint ~ 1 + Group*LaggedLight + Season + (1 + LaggedLight|SubjectID)
    % The term (1 + LaggedLight|SubjectID) specifies a random intercept and random
    % slope for LaggedLight, nested within each subject.
    try
        % lme = fitlme(tbl, 'SleepMidpoint ~ Group*LaggedLight + Season + (1 + LaggedLight|SubjectID)');
        lme = fitlme(tbl, 'SleepMidpoint ~ LaggedLight + (1 + LaggedLight|SubjectID)');
        % p_val = coefTest(lme, [0 0 0 1 0]);
        p_val = coefTest(lme, [0 1]);
        p_values_test(i) = p_val;
    catch
        p_values_test(i) = NaN;
    end
end

% --- Calculate Power ---
num_significant = sum(p_values_test < alpha, 'omitnan');
power = num_significant / sum(~isnan(p_values_test));


% Display the result
fprintf('Estimated power: %.2f\n', power);

% Check the parameters of one of the fitted models
disp('Example of a fitted LME model:');
disp(lme);

% determine variability of light effect on sleep midpoint

% figure
% Data = T(~isnan(T.LightHr_nextDay),:);
% participants = unique(Data.record_id);
% for x = 1:length(participants)
%     [r(x),p] = corr(Data.light_scale(Data.record_id==participants(x)),Data.LightHr_nextDay(Data.record_id==participants(x)));
% 
%     clf
%     plot(Data.light_scale(Data.record_id==participants(x)),Data.LightHr_nextDay(Data.record_id==participants(x)),'ok')
%     lsline
%     pause
%     hold off
% end