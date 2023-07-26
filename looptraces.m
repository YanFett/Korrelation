function newtraces = looptraces(traces,n)
    %n = mod(n,length(traces(:,1)));
    newtraces = zeros(length(traces(:,1)),length(traces(1,:))); %prepare array so matlab shuts up
%     newtraces(1:end-n,:) = traces(n+1:end,:);
%     newtraces(end-n+1:end,:) = traces(1:n,:);
    newtraces(1:n,:) = traces(end-n+1:end,:);
    newtraces(n+1:end,:) = traces(1:end-n,:);
end