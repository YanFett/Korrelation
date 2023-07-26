function [decrossbleddata, kPe, kEp] = decrossbleeddata(preparedtracedata,toplot,randspect,screenshiftx) % this is what i call a pass through function
    if ~exist('randspect', 'var')
        randspect = 54;
    end

    if ~exist('toplot', 'var')
        toplot = false;
    end
    if ~exist('directcorr', 'var')
        directcorr = false;
    end
    if ~exist('screenshiftx', 'var')
        screenshiftx = 0;
    end
    xax = preparedtracedata.xax;
    yleft = preparedtracedata.yleft;
    yright = preparedtracedata.yright;
    size = length(yright(1,:));

    tonormalize = true;
    smoothing = 8;
    threshold = 0.6;
    filtering = 8;
    if(tonormalize)
        normalize = @(x) mat2gray(x);
    else
        normalize = @(x) x;
    end

    startcutoff = 60; %3 seconds
    % determine HEe Brightness of the educt (left) dye in the educt (left) channel
    %HEe = mean(eductstart,'all');
    % determine HEp Brightness of the educt (left) dye in the product (right) channel
    %HEp = mean(productstart,'all');
    %kEp = HEe/HEp;
    
    correctedleft = zeros(length(yleft(:,1)),length(yleft(1,:)));
    correctedright = zeros(length(yleft(:,1)),length(yleft(1,:)));

    fEp = zeros(size,1);
    fPe = zeros(size,1);
    for i = 1:size
        lefttrace = yleft(:,i);
        righttrace = yright(:,i);
        lefttrace = normalize(lefttrace);
        righttrace = normalize(righttrace);
        leftsmooth = smooth(lefttrace,smoothing);
        rightsmooth = smooth(righttrace,smoothing);
        indexEnters = find(normalize(rightsmooth(startcutoff:end)) > threshold, 1, 'first'); % Index when particle enters and sigma becomes big enough.
        indexLeaves = find(normalize(rightsmooth(startcutoff:end)) > threshold, 1, 'last'); % Index when particle leaves and sigma becomes small again.
        indexEnters = indexEnters + startcutoff-1;
        indexLeaves = indexLeaves + startcutoff-1;
        meanright = mean(righttrace(indexEnters:indexLeaves));
        meanleft = mean(lefttrace(indexEnters:indexLeaves));

        rightinleft = meanleft/meanright;
        
        corrleft1 = lefttrace - rightinleft*righttrace;
        %corrleft1(corrleft1<0)=0;
        corrleft1 = normalize(corrleft1);
        corrleftsmooth = smooth(corrleft1,smoothing);

        startright = mean(rightsmooth(1:startcutoff,:));
        startleft = mean(leftsmooth(1:startcutoff,:));

        leftinright = startright/startleft;

        corrright1 = righttrace - leftinright*lefttrace;
        %corrright1(corrright1<0)=0;
        corrright1 = normalize(corrright1);
        corrrightsmooth = smooth(corrright1,smoothing);

        if(directcorr)
            correctedleft(:,i) = corrleft1;
%            correctedleftsmooth = corrleftsmooth1;

            correctedright(:,i) = corrright1;
%            correctedrightsmooth = corrrightsmooth1;
        else
            startright = mean(rightsmooth(1:startcutoff,:));
            startleft = mean(corrleftsmooth(1:startcutoff,:));
%             startleft
%             startright
            
            meanright = mean(righttrace(indexEnters:indexLeaves));
            meanleft = mean(lefttrace(indexEnters:indexLeaves));
            rightinleft = meanleft/meanright;
            
%             rightinleft
            cleft = lefttrace - rightinleft*corrright1;
            %cleft(cleft<0)=0;
            cleft = normalize(cleft);
            correctedleft(:,i) = cleft;


%             leftinright
            cright= righttrace - leftinright*corrleft1;
            %cright(cright<0)=0;
            cright = normalize(cright);
            correctedright(:,i) = cright;

% %             rightinleft
%             correctedleft(:,i) = medfilt1(normalize(lefttrace - rightinleft*corrrightsmooth),filtering);
% 
% 
% %             leftinright
%             correctedright(:,i) = medfilt1(normalize(righttrace - leftinright*corrleftsmooth),filtering);
% 
% %             rightinleft
%             correctedleft(:,i) = filloutliers(normalize(lefttrace - rightinleft*corrrightsmooth),'clip',"movmedian",filtering,"SamplePoints",xax);
% 
% 
% %             leftinright
%             correctedright(:,i) = filloutliers(normalize(righttrace - leftinright*corrleftsmooth),'clip',"movmedian",filtering,"SamplePoints",xax);

        end
        
        fEp(i) = leftinright;
        fPe(i) = rightinleft;

        if(i == randspect && toplot)
            xshift = screenshiftx + 1805;
            yshift = 25;
            fig = figure('Name','crossbleed Analysis','NumberTitle','off');
            clf(fig)
            set(fig,'Position',[xshift,yshift, 500, 900]);
            tiledlayout(2,1, 'Padding', 'none', 'TileSpacing', 'compact');
            nexttile
            hold on
            lwblack = 0.6;
            lwcolor = 1;
            plot(xax, righttrace, 'Color', 'r','LineWidth',lwcolor)
            plot(xax, correctedright(:,i), 'Color', [0 0.5 0],'LineWidth',lwcolor)
            if(directcorr)
                plot(xax ,leftinright*corrleft1,'Color','k','LineWidth',lwblack)
            else
                plot(xax ,leftinright*corrleft1,'Color','k','LineWidth',lwblack)
            end
            lgd = legend('right','corrected right','difference');
            lgd.Location = 'northeast';
            

            nexttile
%             hold on
%             lwcolor = 1.5;
%             plot(xax, correctedleft(:,i), 'Color', 'b','LineWidth',lwcolor)
%             plot(xax, correctedright(:,i), 'Color', [0 0.5 0],'LineWidth',lwcolor)
% 
%             lgd = legend('correctedleft','correctedright');
%             lgd.Location = 'northeast';
%     
%     
%     
%             fig = figure(3);
%             set(fig,'Position',[xshift, 5+yshift, 500, 400]);
%             clf(fig)
            hold on
            lwblack = 0.6;
            lwcolor = 1;
            plot(xax, lefttrace, 'Color', '#B8860B','LineWidth',lwcolor)
            plot(xax, correctedleft(:,i), 'Color', 'b','LineWidth',lwcolor)
            if(directcorr)
                plot(xax ,rightinleft*corrright1,'Color','k','LineWidth',lwblack)
            else
                plot(xax ,rightinleft*corrright1,'Color','k','LineWidth',lwblack)
            end
            lgd = legend('left','corrected left','difference');
            lgd.Location = 'northeast';

%             fig = figure(4);
%             set(fig,'Position',[xshift+505, 5+yshift, 500, 400]);
%             clf(fig)
%             hold on
%             plot(xax, leftsmooth, 'Color', '#B8860B','LineWidth', 0.75)
%             plot(xax, rightsmooth, 'Color', 'r','LineWidth',0.75)
%             lgd = legend('left','right');
%             lgd.Location = 'northeast';

        end
    end
    kPe = mean(fPe);
    kEp = mean(fEp);
    decrossbleddata.yright = correctedright;
    decrossbleddata.yleft = correctedleft;
    decrossbleddata.xax = xax;
end