function newtraces = preparetrace(traces,tomean) %normalizes the trace, then substracts the average from the whole trace.
    if ~exist('tomean', 'var')
        tomean = false;
    end
    newtraces = zeros(length(traces(:,1)),length(traces(1,:))); %prepare array so matlab shuts up
    for i = 1:length(traces(1,:))
        trace = traces(:,i); %get one trace
            trace=mat2gray(trace); %normalize trace (from 0 to 1)
        if(tomean)
            trace = trace - mean(trace); %determine mean, substract from normalized values
        end
        newtraces(:,i) = trace; % write new trace to results
    end
end