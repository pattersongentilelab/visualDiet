
%% Power analysis calculations for seasonal and group comparisons

% Set up simulation parameters
num_simulations = 1000; % Number of times to run the simulation
n_groups = 2;          % Number of groups
n_participants_per_group = 51;
n_total_participants = n_groups * n_participants_per_group;
n_measurements_per_season = 14; % 2 weeks of actigraphy and light data
n_seasons = 2; % Winter and summer
dropout = 0.2; % proportion dropout

alpha = 0.05;          % Significance level
p_values = zeros(num_simulations, 1); % To store the p-values

% --- Define expected model parameters ---
% Fixed effects (replace with your expected values)
beta_intercept = 1.6;  % Average hrs light in migraine
beta_group_effect = 0.5; % Expected difference between groups (Group B vs A) in hours
beta_season_effect = 0.5; % Expected difference between seasons (Summer vs Winter)
beta_interaction_effect = -0.25; % Group*Season interaction term

% Standard deviations
std_subject = 0.8;   % Standard deviation of random intercepts (between-subject variance)
std_residual = 1.0;  % Standard deviation of residual error (within-subject variance)

% Pre-allocate table for simulated data
sim_data = table();
sim_data.Subject = repelem(1:n_total_participants, n_seasons * n_measurements_per_season)';
sim_data.Group = categorical(repelem([repmat({'Migraine'}, n_participants_per_group, 1); ...
                         repmat({'Control'}, n_participants_per_group, 1)], ...
                         n_seasons * n_measurements_per_season));
sim_data.Season = categorical(repmat([repmat({'Winter'}, n_measurements_per_season, 1); ...
                         repmat({'Summer'}, n_measurements_per_season, 1)], ...
                         n_total_participants, 1));


for i = 1:num_simulations
    % 1. Simulate data for all participants
    random_intercepts = std_subject * randn(n_total_participants, 1);

    % Combine fixed and random effects for each observation
    expected_midpoint = beta_intercept + ...
                        (sim_data.Group == 'Control') .* beta_group_effect + ...
                        (sim_data.Season == 'Summer') .* beta_season_effect + ...
                        (sim_data.Group == 'Control' & sim_data.Season == 'Summer') .* beta_interaction_effect + ...
                        random_intercepts(sim_data.Subject);

    % Add residual error
    sim_data.LightHr = expected_midpoint + std_residual * randn(size(sim_data, 1), 1);
    sim_data.LightHr(sim_data.LightHr<0) = 0;

    % Add drop out
    makeNaN = randi(length(sim_data.LightHr),[round(dropout*length(sim_data.LightHr)),1]);
    sim_data.LightHr(makeNaN) = NaN;

    % 2. Fit the linear mixed-effects model
    lme = fitlme(sim_data, 'LightHr ~ Group*Season + (1|Subject)'); % linear relationship

    % sim_data.LightHr = round(sim_data.LightHr);
    % sim_data.LightHr(sim_data.LightHr>5) = 5;
    % lme = fitglme(sim_data(sim_data.Group=='Migraine',:), 'LightHr ~ Season + (1|Subject)','Distribution','Poisson'); % Poisson relationship

    % 3. Extract the p-value for the interaction term
    fixed_effects_stats = lme.Coefficients;
    fixed_effects_stats.Name = categorical(fixed_effects_stats.Name);
    p_values(i) = fixed_effects_stats.pValue(fixed_effects_stats.Name == 'Group_Migraine:Season_Winter');

    median_SeasonDiff_Mig(i) = median(sim_data.LightHr(sim_data.Group=='Migraine' & sim_data.Season=='Winter')) - median(sim_data.LightHr(sim_data.Group=='Migraine' & sim_data.Season=='Summer'));
    median_SeasonDiff(i) = median(sim_data.LightHr(sim_data.Season=='Winter')) - median(sim_data.LightHr(sim_data.Season=='Summer'));

end

% --- Analyze results ---
power = mean(p_values < alpha); % Proportion of significant results
fprintf('Estimated Power for the tested effect effect: %.2f%%\n', power * 100);

% Optional: Check the parameters of one of the fitted models
disp('Example of a fitted LME model:');
disp(lme);