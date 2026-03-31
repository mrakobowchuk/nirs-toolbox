classdef TimeSeriesViewer < handle
    %UNTITLED7 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = protected)
        tree
        root
        
        data
        
        lines
        optodes
        
        heirarchy
        
        ax_probe
        ax_data
        
        dtype
    end
    
    methods 
        function obj = TimeSeriesViewer( data )
            obj.data = data;
           
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
            if ~isempty(iData) && iData >= 1 && iData <= length(obj.data)
                cla(obj.ax_probe);
                obj.data(iData).probe.draw([0.3 0.5 1], {'LineStyle', '-', 'LineWidth', 6}, obj.ax_probe);
            
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
            labels = cell(1, length(obj.data));
            for i = 1:length(obj.data)
                labels{i} = [ num2str(i) ':' obj.data(i).description ];
            end
        end
        
        function resetLines( obj )
            % reset lines
            for i = 1:length(obj.lines)
                set(obj.lines(i), 'LineStyle', '-');
                set(obj.lines(i), 'Color', [0.3 0.5 1])
            end
        end
    end
    
    methods
        function draw(obj)
            probe = obj.data(1).probe;
            %find screen size - JP
            set(0,'units','pixels');
            pix_SS = get(0,'screensize');
            %percent screen size - JP
            scaleFig = .80;
            res = [pix_SS(3).*scaleFig pix_SS(4).*scaleFig];
            
            % make figure window
            f = figure('Position', [res(1)*.092 res(2)*.081 res(1) res(2)]);
            
            % show file selection list
            obj.tree = uicontrol('Style', 'listbox', ...
                'String', obj.root, ...
                'Position', [res(1)*.0293 res(2)*.057 res(1)*.329 res(2)*.325], ...
                'Callback', @(src,~) obj.treeSelectFun(src, []));
                        
            % menu for selecting data type
            types = unique(probe.link.type);
            
            % axis for plotting data
            obj.ax_data = gca;
            setpixelposition( obj.ax_data, [res(1)*.046 res(2)*.635 res(1)*.906  res(2)*.2929] )
            
            % axis for plotting probe
            obj.ax_probe = axes;
            setpixelposition( obj.ax_probe, [res(1)*.412 res(2)*.122 res(1)*.534 res(2)*.439] );
            
            % data type menu
            dtypeMenu = uicontrol('Style', 'popupmenu',...
                'String', types, ...
                'Position', [res(1)*.412 res(2)*.041 res(2)*.48 res(2)*.041],...
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
