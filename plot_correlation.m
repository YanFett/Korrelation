function [corrxax,concorrautoleft] = plot_correlation(fig,totalshift,xax,y1,y2,tilenum,fitlim,tolog,singexp,xlimits,titlestr)
    skiperrorbar = 5;
    timeresolution =xax(2);
    if ~exist('tolog', 'var')
    tolog = true;
    end
    if ~exist('ylimits', 'var')
        ylimmin = 0.05;
        ylimmax = 0.25;
        ylimits = [ylimmin, ylimmax];
    end
    if ~exist('xlimits', 'var')
        xlimmin = timeresolution*0.9;
        xlimmax = timeresolution * totalshift *1.1 ;
        xlimits = [xlimmin, xlimmax];
    end
    if ~exist('fitlim','var')
        fitlim = true;
    end
    if ~exist('singexp','var')
        singexp = true;
    end

    lgdloc = 'northeast';
    fitcolor = [0 0.5 0];
    fitlw = 2;
    lwsingle = 2;
    singlecolor = [0, 0, 1, 0.15];
    %fitboxheight = 0.82;
    %fitboxshift = 0.62;
    %corrxax = ((-totalshift:totalshift)*timeresolution)';
    corrxax = ((0:totalshift)*timeresolution)';
    
    fitxax = min(corrxax):0.001:max(corrxax);


    fig; 
    nexttile(tilenum)
    if exist('titlestr','var')
        titlesize = 16;
        title(titlestr,'interpreter','latex', 'FontSize',titlesize);
    end
    hold on
    %set(gca, 'XScale', 'log')
   % concorrautoleft = zeros(totalshift,1);
    correls = zeros(totalshift+1,length(y1(1,:)));
    for i = 1 : length(y1(1,:))
        factors = crosscorr(y1(:,i),y2(:,i),NumLags=totalshift);
        cutfact = factors(totalshift:2*totalshift);
        correls(:,i) = cutfact;
        plot(corrxax,correls(:,i),'Color',singlecolor,'LineWidth',lwsingle,'HandleVisibility','off');
    end
    meancorr = mean(correls,2);
    errors = std(correls,0,2);
    for i = 1:length(errors)
        if(mod(i,skiperrorbar)~=0)
            errors(i) = NaN;
        end
    end
    h = errorbar(corrxax,meancorr,errors,'Color','r','CapSize',2,'HandleVisibility','off');
    alpha = 0.5;
    set([h.Bar, h.Line], 'ColorType', 'truecoloralpha', 'ColorData', [h.Line.ColorData(1:3); 255*alpha])
    plot(corrxax,meancorr,'Color','r','LineWidth',5, 'DisplayName', "mean correlation");
    %[factors,lags] = correlate_concat_inbuilt(y1,y1,totalshift);

   % set(gca, 'XScale', 'log')

    concorrautoleft = meancorr;
%     for ii=1:length(corrfunc(1,:))
%         plt = plot(corrxax,corrfunc(:,ii),'Color',singlecolor,'LineWidth',lwsingle,'HandleVisibility','off');
%     end
    %scatter(corrxax,concorrautoleft,markersize,'MarkerEdgeColor',markercolor, 'DisplayName', "correlation")
    if(fitlim)
        if(singexp)
            fitconleft = singexpfit(corrxax,concorrautoleft);
        else
            fitconleft = biexpfitc(corrxax,concorrautoleft);
            if(abs(fitconleft.t1)>abs(fitconleft.t2))
                A = fitconleft.a;
                T1 = fitconleft.t1;
                B = fitconleft.b;
                T2 = fitconleft.t2;
            else
                A = fitconleft.b;
                T1 = fitconleft.t2;
                B = fitconleft.a;
                T2 = fitconleft.t1;
            end
            
        end
        plot(fitxax,fitconleft(fitxax), 'DisplayName', "fit","Color",fitcolor,"Linewidth",fitlw)
        
        lgd = legend('-DynamicLegend');
        lgd.Location = lgdloc;
        
        num2str_ = @(x) num2str(x,5);
        if(singexp)
            eq_str = strcat({'$a \cdot e^{\frac{-\tau}{T}}+c$',['$a = ', num2str_(fitconleft.a),'$'],['$T = ', num2str_(fitconleft.b),'$'], ['$c = ', num2str_(fitconleft.c),'$']});
        else
            eq_str = {'$a \cdot e^{\frac{-t}{T_1}}+b \cdot e^{\frac{-\tau}{T_2}}+c$',['$a = ', num2str_(A),'$'],['$T_1 = ', num2str_(T1),'$'], ['$b = ', num2str_(B),'$'], ['$T_2 = ', num2str_(T2),'$'], ['$c = ', num2str_(fitconleft.c),'$']};
        end
        if(tolog)
            if(tilenum==1)
                tilenumshiftx = 0.05;
                tilenumshifty = 0.74;
            elseif(tilenum==2)
                tilenumshiftx = 0.56;
                tilenumshifty = 0.74;
            elseif(tilenum==3)
                tilenumshiftx = 0.05;
                tilenumshifty = 0.455;
            elseif(tilenum==4)
                tilenumshiftx = 0.56;
                tilenumshifty = 0.455;
            end

        else
            if(tilenum==1)
                tilenumshiftx = 0.35;
                tilenumshifty = 0.91;
            elseif(tilenum==2)
                tilenumshiftx = 0.86;
                tilenumshifty = 0.91;
            elseif(tilenum==3)
                tilenumshiftx = 0.35;
                tilenumshifty = 0.23;
            elseif(tilenum==4)
                tilenumshiftx = 0.86;
                tilenumshifty = 0.23;
            end
        end
        annotation('textbox', [tilenumshiftx tilenumshifty 0 0], 'String', eq_str,'interpreter','latex', 'FitBoxToText', true,'BackgroundColor','w','fontsize',14);
    end

    if(tolog)
        set(gca, 'XScale', 'log')
    end        
    textsize = 15;
    ylabel('$g(\tau ) [a.u.]$','interpreter','latex', 'FontSize',textsize)
    xlabel('$\tau [s]$','interpreter','latex', 'FontSize',textsize)
    xlim(xlimits)
    %ylim(ylimits)
end