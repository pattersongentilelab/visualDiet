% Wear/nonwear function
function [data,prctDay,prctNight] = wearMdl(vd,hd,mdl)

    data = vd;

    vd = vd(ismember(vd.day,[hd.day;hd.day(end)+1]),:);
    vd.daytime = minute(vd.TIME);
    
    vd.hang = zeros(height(vd),1);
    vd.hang(vd.ORIENTATION==2) = 1;
    vd.down = zeros(height(vd),1);
    vd.down(vd.ORIENTATION==32) = 1;
    vd.move = zeros(height(vd),1);
    vd.move(vd.TAT>0) = 1;
    vd.dark = zeros(height(vd),1);
    vd.dark(vd.LIGHT<=1) = 1;

    [predLabel,~] = predict(mdl,vd);
    vd.predLabel = predLabel;

    Day = unique(vd.day);
    prctNight = NaN*ones(1,length(Day));
    prctDay = NaN*ones(1,length(Day));

    for X = 1:length(Day)
        D = length(vd.TIME(vd.day==Day(X) & vd.hour>10 & vd.hour<20 & vd.predLabel=='wear'));
        NwD = length(vd.TIME(vd.day==Day(X) & vd.hour>10 & vd.hour<20 & vd.predLabel=='non-wear'));
    
        if X<7
            N = length(vd.TIME(vd.day==Day(X+1) & vd.hour<6 & vd.predLabel=='night'));
            NwN = length(vd.TIME(vd.day==Day(X+1) & vd.hour<6 & vd.predLabel=='non-wear'));
        end
    
        prctNight(1,X) = N/(NwN+N);
        prctDay(1,X) = D/(NwD+D);
    end
    
    data.wear = predLabel;

end

