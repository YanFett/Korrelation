function tracedata = preparedata(tracedata,tomean) % this is what i call a pass through function
tracedata.yright = preparetrace(tracedata.yright,tomean); %prepare data for first half of y values
tracedata.yleft = preparetrace(tracedata.yleft,tomean); % prepare data for second half of y values
end