% Wear/nonwear function
function [data,prctDay,prctNight,prctAll] = wearMdl(vd,hd,mdl,varargin)

q = inputParser;
q.addParameter('cleanlight','false',@islogical); % to turn light and mEDI values into NaN for non-wear peariods >10 min
q.parse(varargin{:});

    data = vd;

    vd = vd(ismember(vd.day,[hd.day;hd.day(end)+1]),:);
    vd.daytime = minute(vd.TIME);
    
    vd.hang = zeros(height(vd),1);
    vd.hang(vd.ORIENTATION==2) = 1;
    vd.down = zeros(height(vd),1);
    vd.down(vd.ORIENTATION==32) = 1;
    vd.move = zeros(height(vd),1);
    vd.move(vd.PIM>0) = 1;
    vd.dark = zeros(height(vd),1);
    vd.dark(vd.LIGHT<=1) = 1;
    vd.lightlog = log(vd.LIGHT+0.1);
    vd.pimlog = log(vd.PIM+1);

    [predLabel,~] = predict(mdl,vd);
    vd.predLabel = categorical(predLabel);
    
    data.wear = vd.predLabel;

    %% turn light measurement stretches of 'non-wear' >10 minutes to NaN
   
    isNonAdherent = (data.wear == 'non-wear');
    
    % Find start and end indices of consecutive non-adherent sequences
    starts = find([isNonAdherent(1); diff(isNonAdherent) == 1]);
    ends = find([diff(isNonAdherent) == -1; isNonAdherent(end)]);
    
    % Adjust start if the first element is 'non-wear'
    if isNonAdherent(1) && length(starts) < length(ends)
        starts = [1; starts];
    end
    
    % Calculate lengths of streaks
    streakLengths = ends - starts + 1;
    
    % Identify sequences > 10
    longStreaks = starts(streakLengths > 10);
    longEnds = ends(streakLengths > 10);

    % determine percent of the day and night that was non-wear
    Day = unique(vd.day);
    prctNight = NaN*ones(1,length(Day));
    prctDay = NaN*ones(1,length(Day));
    prctAll = NaN*ones(1,length(Day));
    vd.NonWear = zeros(height(data),1);
    for i = 1:length(longStreaks)
        vd.NonWear(longStreaks(i):longEnds(i)) = 1;
    end
    
    for X = 1:length(Day)     
        D = length(vd.TIME(vd.day==Day(X) & vd.hour>10 & vd.hour<20));
        NwD = length(vd.TIME(vd.day==Day(X) & vd.hour>10 & vd.hour<20 & vd.NonWear==1));
        A = length(vd.TIME(vd.day==Day(X)));
        NwA = length(vd.TIME(vd.day==Day(X) & vd.NonWear==1));
        
        if X<7
            N = length(vd.TIME(vd.day==Day(X+1) & vd.hour<6));
            NwN = length(vd.TIME(vd.day==Day(X+1) & vd.hour<6 & vd.NonWear==1));
        end
        
        prctNight(1,X) = (N-NwN)/N;
        prctDay(1,X) = (D-NwD)/D;
        prctAll(1,X) = (A-NwA)/A;
    end

        
     if q.Results.cleanlight==1
        % Set LIGHT amd MELANOPICEDI columns to NaN for these rows  
        for i = 1:length(longStreaks)
            data.LIGHT(longStreaks(i):longEnds(i)) = NaN;
            data.MELANOPICEDI(longStreaks(i):longEnds(i)) = NaN;
        end
    end

end

