classdef ChannelStatsViewer < handle
    %UNTITLED7 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties %(Access = protected)
        tree
        root
        
        stats
        heirarchy
        
        dtype
        
        ax_stats
        
        dtypeMenu
        
        hypTestMenu
        
        contrastWindow
        
        critValBox
        
    end
    
    methods 
        function obj = ChannelStatsViewer( stats )
            error('Not Implemented Yet.')
            % set inputs
            if nargin < 2
                obj.heirarchy = {'group', 'subject'};
            else
                error('not implemented yet')
                obj.heirarchy = heirarchy;
            end
            
            obj.stats = stats;
           
            % put together the tree structure
            obj.root = obj.assembleRoot();
            
            % draw gui
            obj.draw();
        end 
    end
        
    methods (Access = protected)
        
        function drawData( obj, iData, iChan )
            % clear data axis
            cla( obj.ax_data );
            legend(obj.ax_data, 'hide');
            
            axes(obj.ax_data);
            if isempty(iChan)
                obj.data(iData).draw( );
            else
                obj.data(iData).draw( iChan );
            end
        end
        
        %% gui selection functions
        function treeSelectFun( obj, src , ~ )  
            % get selected data index
            iData = get(src, 'Value');
            
            % make sure it is a valid index
            if ~isempty(iData) && iData >= 1 && iData <= length(obj.stats)
                cla( obj.ax_probe )
                axes( obj.ax_probe )
                obj.data(iData).probe.draw();
            
                % line and optode handles
                obj.lines   = findobj(obj.ax_probe, 'Type', 'line');
                obj.optodes = findobj(obj.ax_probe, 'Type', 'text');
                
                % set line func
                for i = 1:length(obj.lines)
                    set(obj.lines(i), 'ButtonDownFcn', @(l,v) obj.lineSelectFun(l,v));
                end

                % set optode func
                for i = 1:length(obj.optodes)
                   set(obj.optodes(i), 'ButtonDownFcn', @(l,v) obj.optSelectFun(l,v));
                end
            
                % find channels matching type
                link = obj.data(iData).probe.link;
                if all( isnumeric(link.type) )
                    types = cellfun(@(x) {num2str(x)}, num2cell(link.type));
                else
                    types = link.type;
                end
                
                lst = strcmpi(obj.dtype, types);
                
                % draw
                axes( obj.ax_data )
                obj.drawData( iData, find(lst) );
            end
        end

        function lineSelectFun( obj, l, ~ )
            obj.resetLines();
            
            % set selected line to --
            set( l, 'LineStyle', '--' )
            
            % get channel index
            i = get(l, 'UserData');
            iSrc = i(1);
            iDet = i(2);
            
            iData = get(obj.tree, 'Value');
            
            % find the channel idx
            link = obj.data(iData).probe.link;
            
            if all( isnumeric(link.type) )
                types = cellfun(@(x) {num2str(x)}, num2cell(link.type));
            else
                types = link.type;
            end

            iChan = find( link.source == iSrc & link.detector == iDet & strcmpi(types, obj.dtype) );
            
            % draw data
            obj.drawData(iData, iChan);
           
        end
        
        function optSelectFun( obj, s, ~ )
            obj.resetLines();
            
            udata = get(s,'UserData');
            
            type = udata(1); %S or D
            oidx = str2num( udata(2:end) );
            
            link = obj.data(1).probe.link;
            
            if type == 'S'
                lst = link.source == oidx;
            else
                lst = link.detector == oidx;
            end
            
            if all( isnumeric(link.type) )
                types = cellfun(@(x) {num2str(x)}, num2cell(link.type));
            else
                types = link.type;
            end
            
            lst = find( lst & strcmpi(obj.dtype, types) );
            
            %%% TODO: Color & Style lines to match data plot %%%
            
            iData = get(obj.tree, 'Value');
            iChan = lst;
            
            obj.drawData(iData, iChan);
           
        end
        
        function dtypeMenuSelectFun(obj, s, ~)
            obj.resetLines();
            
            lst = get(s,'UserData');
            idx = get(s,'Value');
            
            obj.dtype = lst{idx};
            
            % which data file
            iData = get(obj.tree, 'Value');
            
            % find channels matching type
            link = obj.data(iData).probe.link;
            if all( isnumeric(link.type) )
                types = cellfun(@(x) {num2str(x)}, num2cell(link.type));
            else
                types = link.type;
            end
            
            lst = strcmpi(obj.dtype, types);
            
            % draw
            axes( obj.ax_data )
            obj.drawData( iData, find(lst) );
        end
        
        %%
        function labels = assembleRoot( obj )
            % Build list of entry labels for the listbox
            labels = cell(1, length(obj.stats));
            for i = 1:length(obj.stats)
                labels{i} = obj.stats(i).description;
            end
        end
       
    end
    
    methods
        function draw(obj)
            probe = obj.data(1).probe;
            
            % make figure window
            figure('Position', [100 100 850 750])
            
            % show stats selection list
            obj.tree = uicontrol('Style', 'listbox', ...
                'String', obj.root, ...
                'Position', [50 50 350 300], ...
                'Callback', @(src,~) obj.treeSelectFun(src, []));
            
            % menu for selecting data type
            types = unique(probe.link.type);
            
            % axis for plotting data
            obj.ax_data = gca;
            setpixelposition( obj.ax_data, [75 420 700 300] )
            
            % axis for plotting probe
            obj.ax_probe = axes;
            setpixelposition( obj.ax_probe, [450 75 350 275] );
            
            % data type menu
            dtypeMenu = uicontrol('Style', 'popupmenu',...
                'String', types, ...
                'Position', [450 50 350 25],...
                'Callback', @(s,v) obj.dtypeMenuSelectFun(s,v) );
            
            if isnumeric( types(1) )
                set(dtypeMenu, 'UserData', cellfun(@(x) {num2str(x)}, num2cell(types)));
                obj.dtype = num2str( types(1) );
            else
                set(dtypeMenu, 'UserData', types);
                obj.dtype = types(1);
            end

        end
    end
    
end

