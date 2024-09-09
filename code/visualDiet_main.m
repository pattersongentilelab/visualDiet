% Actlumus data analysis

T = readtable('/Users/carlynpattersongentile/Documents/data/actlumus/CPG_20240520.txt');

figure
subplot(4,1,1)
plot(T.DATE_TIME,T.LIGHT)

subplot(4,1,2)
plot(T.DATE_TIME,T.MELANOPICEDI)