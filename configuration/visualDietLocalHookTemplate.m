function visualDietLocalHook

%  visualDietLocalHook
%
% Configure things for working on the  visual diet projects.
%
% For use with CHOP network computers, need appropriate access to run
% For use with ToolboxToolbox
% If you 'git clone' visualDiet into your ToolboxToolbox "projectRoot"
% folder, then run in MATLAB
%   tbUseProject('visualDiet')
% ToolboxToolbox will set up visualDiet and its dependencies on
% your machine.
%
% As part of the setup process, ToolboxToolbox will copy this file to your
% ToolboxToolbox localToolboxHooks directory (minus the "Template" suffix).
% The defalt location for this would be
%   ~/localToolboxHooks/visualDietLocalHook.m
%
% Each time you run tbUseProject('visualDiet'), ToolboxToolbox will
% execute your local copy of this file to do setup for continuousHA.
%
% You should edit your local copy with values that are correct for your
% local machine, for example the output directory location.
%


%% Say hello.
projectName = 'visualDiet';

%% Delete any old prefs
if (ispref(projectName))
    rmpref(projectName);
end

%% Specify base paths for materials and data (set up for CPG only)
[~, userID] = system('whoami');
userID = strtrim(userID);

visualDiet_dataBasePath = ['/Users/' userID '/OneDrive - Children''s Hospital of Philadelphia/Research/Visual Diet/Data/'];
visualDiet_analysisBasePath = ['/Users/' userID '/OneDrive - Children''s Hospital of Philadelphia/Research/Visual Diet/Analysis/'];

%% Specify where output goes (for mac)

% Code to run on Mac plaform
setpref(projectName,'visualDietDataPath', visualDiet_dataBasePath);
setpref(projectName,'visualDietAnalysisPath', visualDiet_analysisBasePath);

