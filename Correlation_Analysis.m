clear all
close all
filename = '488nmJBerger.csv'; % 46.6 mW
%bad spectra: 86, 
%good example spectra: 89, 48, 70

%filename = '488nmMJourdain.csv'; % 25? mW
%filename = '488nmRonja.csv'; % 15 mW
bleedthrough_paper = false;
fitlim = true;
plottrace = true;
randtrace = 48; % tracenumber, 0 for random one
plotdecrossbleed = true;
tomean = false;
singexp = false;
tolog = true;
screenshiftx = 0;


tracedata = importcsv(filename);
tracenum = length(tracedata.yleft(1,:));
if(randtrace ==0)
    randtrace = round(rand()*tracenum)
end
if(bleedthrough_paper)
    [kPe, kEp] = determine_bleedthrough(tracedata);
    decrossbleddata = tracedata;
else
    [decrossbleddata, kPe, kEp] = decrossbleeddata(tracedata,plotdecrossbleed,randtrace,screenshiftx);
end


preparedtracedata = preparedata(decrossbleddata,tomean);
xax = preparedtracedata.xax;
yleft = preparedtracedata.yleft;
yright = preparedtracedata.yright;
totalshift = round(length(yleft)*0.6);

%% setup plot and fit data
markersize = 15;
timeresolution =xax(2);
lgdloc = 'northeast';
markercolor = '#800080';
fitcolor = [0 0.5 0];
fitlw = 2;
lwsingle = 2;
singlecolor = [0, 0, 1, 0.15];
corrxax = ((1:totalshift)*timeresolution)';
fitxax = min(corrxax):0.001:max(corrxax);
fitboxheight = 0.45;
fitboxshift = 0;


xlimmin = timeresolution*0.9;
xlimmax = timeresolution * totalshift *1.0 ;
xlimits = [xlimmin, xlimmax];
ylimmin = -0.5;
ylimmax = 1.1;
ylimits = [ylimmin, ylimmax];

%% plot timetraces
if(plottrace)
    rawtracedata =  preparedata(tracedata,tomean);
    rawyleft = rawtracedata.yleft;
    rawyright = rawtracedata.yright;
    lgdloc = 'northeast';
    
    
    fig = figure('Name','timetraces','NumberTitle','off');
    clf(fig)
    set(fig,'Position',[screenshiftx+1305, 25, 500, 900]);
    tiledlayout(2,1, 'Padding', 'none', 'TileSpacing', 'compact');
    
    eductcolor = [0, 0.75, 0];
    productcolor = [0.75, 0, 0];
    
    eductcolorraw = [0, 0.5, 0];
    productcolorraw = [0.5, 0, 0];
    lw = 1.5;
    smoothfunc = @(x) x;%smooth(x,5);
    nexttile
    hold on
    plot(xax,smoothfunc(yleft(:,randtrace)), 'DisplayName', "educt timetrace decrossbled","Color",eductcolor,"Linewidth",lw)
    plot(xax,smoothfunc(yright(:,randtrace)), 'DisplayName', "product timetrace decrossbled","Color",productcolor,"Linewidth",lw)
    lgd = legend('-DynamicLegend');
    lgd.Location = lgdloc;
    nexttile
    hold on
    
    plot(xax,smoothfunc(rawyright(:,randtrace)), 'DisplayName', "product timetrace raw","Color",productcolorraw,"Linewidth",lw)
    plot(xax,smoothfunc(rawyleft(:,randtrace)), 'DisplayName', "educt timetrace raw","Color",eductcolorraw,"Linewidth",lw)
    lgd = legend('-DynamicLegend');
    lgd.Location = lgdloc;
    %return
end

% %% concat correlation
% concatcorr = false;
% if(concatcorr)   
%     fig = figure('Name','Concatenation Correlation','NumberTitle','off');
%     clf(fig)
%     hold on
%     set(fig,'Position',[screenshiftx + 50, 550, 1600, 400]);
%     tiledlayout(1,3, 'Padding', 'none', 'TileSpacing', 'compact');
%     
%     tilenum = 1;
%     
%     [corrxax,concorrautoleft] = plot_concorrelation(fig,totalshift,xax,yleft,yleft,tilenum,fitlim,singexp,ylimits,xlimits);
%     
%     tilenum = 2;
%     [corrxax,concrosscorr] = plot_concorrelation(fig,totalshift,xax,yright,yleft,tilenum,fitlim,singexp,ylimits,xlimits);
%     
%     tilenum = 3;
%     [corrxax,concorrautoright] = plot_concorrelation(fig,totalshift,xax,yright,yright,tilenum,fitlim,singexp,ylimits,xlimits);
% end
% 
% %% loop correlation
% loopcorr = false;
% if(loopcorr)
%     fig = figure('Name','Loop Correlation','NumberTitle','off');
%     clf(fig)
%     hold on
%     set(fig,'Position',[screenshiftx + 50, 55, 1600, 400]);
%     tiledlayout(1,3, 'Padding', 'none', 'TileSpacing', 'compact');
%     
%     tilenum = 1;
%     
%     [corrxax,loopcorrautoleft] = plot_loopcorrelation(fig,totalshift,xax,yleft,yleft,tilenum,fitlim,singexp,ylimits,xlimits);
%     
%     tilenum = 2;
%     [corrxax,loopcrosscorr] = plot_loopcorrelation(fig,totalshift,xax,yright,yleft,tilenum,fitlim,singexp,ylimits,xlimits);
%     
%     tilenum = 3;
%     [corrxax,loopcorrautoright] = plot_loopcorrelation(fig,totalshift,xax,yright,yright,tilenum,fitlim,singexp,ylimits,xlimits);
% end

%% matlab cross correlation
fig = figure('Name','Correlations','NumberTitle','off');
clf(fig)
hold on
set(fig,'Position',[screenshiftx + 5, 25, 1300, 900]);
tiledlayout(2,2, 'Padding', 'none', 'TileSpacing', 'compact');

tilenum = 1;
titlestr = 'autocorrelation left $(y1 \times y1)$';
[corrxax,corrautoleft] = plot_correlation(fig,totalshift,xax,yleft,yleft,tilenum,fitlim,tolog,singexp,xlimits,titlestr);

tilenum = 2;
titlestr = 'autocorrelation right $(y2 \times y2)$';
[corrxax,corrautoright] = plot_correlation(fig,totalshift,xax,yright,yright,tilenum,fitlim,tolog,singexp,xlimits,titlestr);

tilenum = 3;
titlestr = 'crosscorrelation $(y1 \times y2)$';
[corrxax,crosscorr_] = plot_correlation(fig,totalshift,xax,yleft,yright,tilenum,fitlim,tolog,singexp,xlimits,titlestr);

tilenum = 4;
titlestr = 'crosscorrelation inverse $(y2 \times y1)$';
[corrxax,crosscorrinv] = plot_correlation(fig,totalshift,xax,yright,yleft,tilenum,fitlim,tolog,singexp,xlimits,titlestr);


%% corrected correlation curves:
if(bleedthrough_paper)
    %Autocorrelation product = 
    autoproduct = corrautoright + ((kEp^2)*corrautoleft) + ((2*kPe)*crosscorr_);
    
    fig = figure(123);
    clf(fig)
    set(fig,'Position',[screenshiftx-550, 550, 500, 400]);
    plot(corrxax,autoproduct)
    hold on
    plot(corrxax,corrautoright)
    plot(corrxax,(kEp^2)*corrautoleft)
    plot(corrxax,(2*kPe)*crosscorr_)
    set(gca, 'XScale', 'log')
    leg = legend('autocorrelation product corrected','autocorrelation product','kEp^2 \cdot autocorelation educt','kPe \cdot 2 crosscorrelation');
    leg.Location = 'southwest';
    
    concross = (kPe * corrautoright) + (kEp*corrautoleft) + ((1+(kPe*kEp))*crosscorr_);
    fig = figure(1234);
    clf(fig)
    set(fig,'Position',[screenshiftx-550, 50, 500, 400]);
    plot(corrxax,concross)
    hold on
    plot(corrxax,kPe * corrautoright)
    plot(corrxax,kEp*corrautoleft)
    plot(corrxax,(1+(kPe*kEp))*crosscorr_)
    set(gca, 'XScale', 'log')
    leg = legend('crosscorrelation corrected','kPe \cdot autocorrelation product','kEp \cdot autocorelation educt','(1 + kPe \cdot kEp) \cdot crosscorrelation');
    leg.Location = 'southwest';
end