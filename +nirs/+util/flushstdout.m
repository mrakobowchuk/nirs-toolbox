function flushstdout(nlines)
% flushstdout  Attempt to flush/clear the last N lines from the command window.
%
% In MATLAB versions that support Java-based command window access, this
% function deletes the last NLINES lines using backspace characters.
% In MATLAB R2025a and later (where the Java MLDesktop API is no longer
% available), the function silently does nothing to maintain compatibility.

if(nargin==0)
    nlines=12;
end

try
    desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
    cmdwin = desktop.getClient('Command Window');
    cmdwinview = cmdwin.getComponent(0).getViewport.getComponent(0);
    
    s=getText(cmdwinview);
    str=s.toCharArray';
    lst=find(double(str)==10);
    nlines=min(nlines,length(lst)-2);
    
    for i=1:length(str)-lst(end-nlines)
        fprintf(1,'\b');
    end
catch
    % Java-based command window access is not available (e.g. MATLAB R2025a+).
    % Silently ignore and continue.
end
