% Actlumus data analysis

data_path = getpref('visualDiet','visualDietDataPath');

T = readtable([data_path '/CPG_20240520.txt']);

figure
subplot(2,1,1)
plot(T.DATE_TIME,T.LIGHT)

subplot(2,1,2)
plot(T.DATE_TIME,T.MELANOPICEDI)