function tracedata = importcsv(filename) %imports a csv file of a specific format and converts it to a tracedata object
    csvdatatemp = readmatrix(filename,"DecimalSeparator",","); %read all data, specify the decimal separator to be ,
    csvdata = csvdatatemp(3:end,:); %cut off headers
    xax = csvdata(:,1); %retrieve the x axis
    width = length(csvdata(1,:));
    height = length(csvdata(:,1));
    yleft = zeros(height,(width-1)/2); %prepare arrays so matlab shuts up
    yright = zeros(height,(width-1)/2); %prepare arrays so matlab shuts up
    ii1 = 1;
    ii2 = 1;
    for i=2:width
        if(mod(i,2)) %some boolean magic, divides into odd and even
            yright(:,ii1) = csvdata(:,i); %put all odd rows as "right" yaxis
            ii1 = ii1 + 1;
        else
            yleft(:,ii2) = csvdata(:,i); %put all even rows as "left" yaxis
            ii2 = ii2 + 1;
        end
    end
    %create the tracedata object
    tracedata.xax = xax; 
    tracedata.yleft = yleft;
    tracedata.yright = yright;
end
