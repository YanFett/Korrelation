function [kPe, kEp] = determine_bleedthrough(tracedata) % this is what i call a pass through function
smoothing = 5;
yright = preparetrace(tracedata.yright,true,false); %normalize traces
yleft = preparetrace(tracedata.yleft,true,false); %normalize traces
size = length(yright(1,:));
startcutoff = 61;
endcutoff = 30;
% approximation: highest point in product trace happens after the reaction,
% after 3 seconds and 1.5 seconds before the recording ends
HPpvec = zeros(size,1);
HPevec = zeros(size,1);
for i=1:size 
    producttrace = smooth(yright(:,i),smoothing);
    educttrace = smooth(yleft(:,i),smoothing); 
    producttracecut = yright(startcutoff:end-endcutoff,i);
    % find maximum in product (right) channel
    [~,loc] = max(producttracecut);
    peakstart = (loc+startcutoff)-round(startcutoff/2);
    peakend = (loc+startcutoff)+round(startcutoff/2);
    % determine HPp Brightness of the product (right) dye in the product (right) channel
    HPpvec(i) = mean(producttrace(peakstart:peakend));
    % determine HPe Brightness of the product (right) dye in the educt (left) channel
    HPevec(i) = mean(educttrace(peakstart:peakend));
end

HPe = mean(HPevec);
HPp = mean(HPpvec);


% approxmation: In the first three seconds the Educt molecule has neither bleached nor reacted yet.
eductstart = yleft(1:startcutoff,:);
productstart = yright(1:startcutoff,:);

% determine HEe Brightness of the educt (left) dye in the educt (left) channel
HEe = mean(eductstart,'all');
% determine HEp Brightness of the educt (left) dye in the product (right) channel
HEp = mean(productstart,'all');

kPe = HPe/HPp;

kEp = HEp/HEe;


end