function [correlation_intensity,meancorrfunc] = correlate_concat(traces1,traces2,shift,xax,toplot,plotting,interval)
    if ~exist('plotting', 'var')
        plotting = 1;
    end

    if ~exist('toplot', 'var')
        toplot = false;
    end

    if ~exist('interval', 'var')
        interval = 10;
    end

    if ~exist('xax', 'var')
        xax = [];
    end
    tracelength = length(traces1(:,1));
    tracenumber = length(traces1(1,:));
    plotting = plotting;
    plotfrom = tracelength*(plotting-1);
    plottill = plotfrom + tracelength;
    concattrace1 = concattraces(traces1);
    concattrace2 = concattraces(traces2);
    shiftedconcattrace = looptraces(concattrace2,shift);
    correlation_function=(concattrace1.*shiftedconcattrace);%./concattrace1.^2;
    correlation_factors = mean(correlation_function,1);
    correlation_intensity = mean(correlation_factors);
%    corrfunc = reshape(correlation_function,length(traces1(1,:)),length(traces1(:,1)));
%    meancorrfunc = mean(corrfunc,2);
%    localcorr = mean(correlation_function(plotfrom:plottill));
    meancorrfunc = zeros(tracenumber,1);
    for(i = 1:tracenumber)
        meanstart=1+(i-1)*tracelength;
        meanend = meanstart + tracelength-1;
        meancorrfunc(i) = mean(correlation_function(meanstart:meanend));
    end
    if(toplot && mod(shift,interval)==0)
        fig = figure(122223);
        clf(fig)
        set(fig,'Position',[100 + 50, 555, 500, 400]);
        plot(xax,concattrace1(plotfrom:plottill-1))
        hold on
        plot(xax,shiftedconcattrace(plotfrom:plottill-1))
        plot(xax,correlation_function(plotfrom:plottill-1))
        legend('trace','shifted trace','correlation')
        eq_str = {['correlation value ',num2str(mean(correlation_function(plotfrom:plottill)))], ['shiftamount ',num2str(shift)], ['tracenumber ', num2str(plotting)]} ;
        annotation('textbox', [0.45 0.3 0 0], 'String', eq_str, 'FitBoxToText', true);
        
    end
end