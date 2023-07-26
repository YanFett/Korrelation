clear all
close all
filename = '488nmJBerger.csv';
%bad spectra: 86, 
%good example spectra: 89, 48, 70
%filename = 'Ronja750s.csv';
%filename = 'Spuren mit Farbwechsel (nur 488).csv';
tonormalize = true;
tomean = false;

tracedata = importcsv(filename);
[kPe, kEp] = determine_bleedthrough(tracedata);
showspectrum = 89;
%showspectrum =  round(rand()*length(tracedata.yleft(1,:)))
decrossbleddata = decrossbleeddata(tracedata,true,showspectrum);
preparedtracedata = preparedata(decrossbleddata,tonormalize,tomean );
xax = preparedtracedata.xax;
yleft = preparedtracedata.yleft;
yright = preparedtracedata.yright;

showspec.left = yleft(:,showspectrum);
showspec.right = yright(:,showspectrum);


%% setup plot and fit data
markersize = 10;
timeresolution =xax(2);
totalshift = 1200;
corrxax = ((1:totalshift)*timeresolution)';
fitxax = min(corrxax):0.001:max(corrxax);
fitboxheight = 0.45;
fitboxshift = 0;
screenshiftx = 0;%-1700;

interval = 3;
%round(rand()*length(yright(1,:)));
tracenumber = length(yleft(1,:));
concrosscorr = zeros(totalshift,1);
for i = 1:totalshift
    [concrosscorr(i),corrfunc(i,:)] = correlate_concat(yright,yleft,i,xax,true,showspectrum,interval);
    if(mod(i,interval)==0)
        fig = figure(32543);
        set(fig,'Position',[100 + 50, 55, 500, 400]);
        clf(fig)
        set(gca, 'XScale', 'log')
        hold on

        for ii=1:tracenumber
            if(ii~=showspectrum)
                plt = plot(1:i,corrfunc(:,ii),'Color',[0, 0, 1, 0.2],'LineWidth',2);
            end
        end

    plot(1:i,corrfunc(:,showspectrum),'r','LineWidth',7);
    plot(1:i,concrosscorr(1:i),'k','LineWidth',10);
    end
    %leg = legend('local crosscorrelation','global crosscorrelation');
    %leg.Location = 'southwest';
end