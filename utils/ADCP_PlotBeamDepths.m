function ADCP_PlotBeamDepths

%This function plots the beam depths given a csv file output from VMT.

%P.R. Jackson, 4-16-09

[file,path] = uigetfile({'*.txt;*.csv','All Text Files'; '*.*','All Files'},'Select Bathy Text File');
infile = [path file];
disp('Loading Bathy File...' );
disp(infile);
data = dlmread(infile);

ens   = data(:,1);
x     = data(:,2);
y     = data(:,3);
z     = data(:,4);

%Break out by beam (accepting only ensembles with all beams valid)

xb1 = [];
xb2 = [];
xb3 = [];
xb4 = [];
yb1 = [];
yb2 = [];
yb3 = [];
yb4 = [];
zb1 = [];
zb2 = [];
zb3 = [];
zb4 = [];

for i = min(ens):1:max(ens)
    indx = find(ens == i);
    if length(indx) == 4;
        xb1 = [xb1; x(indx(1))];
        xb2 = [xb2; x(indx(2))];
        xb3 = [xb3; x(indx(3))];
        xb4 = [xb4; x(indx(4))];
        yb1 = [yb1; y(indx(1))];
        yb2 = [yb2; y(indx(2))];
        yb3 = [yb3; y(indx(3))];
        yb4 = [yb4; y(indx(4))];
        zb1 = [zb1; z(indx(1))];
        zb2 = [zb2; z(indx(2))];
        zb3 = [zb3; z(indx(3))];
        zb4 = [zb4; z(indx(4))];
    end
end

%Now compute distances from start for each beam

db1 = sqrt((xb1(1) - xb1).^2 + (yb1(1) - yb1).^2);
db2 = sqrt((xb2(1) - xb2).^2 + (yb2(1) - yb2).^2);
db3 = sqrt((xb3(1) - xb3).^2 + (yb3(1) - yb3).^2);
db4 = sqrt((xb4(1) - xb4).^2 + (yb4(1) - yb4).^2);

%Plot 

figure(1); clf
plot(db1,zb1,'k-','LineWidth',2); hold on
plot(db2,zb2,'r-','LineWidth',2); hold on
plot(db3,zb3,'b-','LineWidth',2); hold on
plot(db4,zb4,'g-','LineWidth',2); hold on
xlabel('Distance (m)')
ylabel('Depth (m)')

legend('beam 1','beam 2','beam 3','beam 4','Location','SouthEast')


%Output the data
if 1
    outmat = [db1 db2 db3 db4 zb1 zb2 zb3 zb4];
    dlmwrite([infile(1:end-4) '_BeamXS.csv'],outmat)
end
        
    