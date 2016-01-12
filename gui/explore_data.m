classdef explore_data < handle
    
    % simple interface for exploring multi-dim EEG data
    properties
        h
        t
        dims
        last_str
        opt
        stat
        fun
        topo
        EEG
    end
    
    % obj.opt.xaxis
    
    methods
        function obj = explore_data(EEG, t_val, varargin)
            
            % add support for stat
            if isstruct(t_val)
                obj.opt.hasstat = true;
                obj.stat = t_val;
                t_val = t_val.stat;
            else
                obj.opt.hasstat = false;
            end
            
            if nargin > 3
                obj.fun.chan = varargin{1};
            else
                obj.fun.chan = [];
            end

            % init - topofigure
            obj.h.f1 = figure('units', 'normalized'); 
            obj.h.ax1 = axes('Parent', obj.h.f1);
            obj.dims = length(size(t_val));
            obj.opt.t_threshold = 1.8;
            obj.opt.current_electrode = 1;
            obj.opt.current_electrode_h = [];
            
            obj.opt.patch_on = false;
            obj.opt.patch_start = [];
            obj.opt.patch_stop = [];

            % plot electrodes
            if obj.dims > 3 % this could work for 2D too, based on stat
                topoplot([], EEG.chanlocs, 'style', 'blank', ...
                    'electrodes', 'labelpoint');
            else
                topoplot([], EEG.chanlocs);
            end
            obj.topo = topo_scrapper(gca);
            set(obj.topo.elec_marks, 'ButtonDownFcn', ...
                @(o, e) obj.show_elec(o));
            
            obj.EEG = EEG;
            obj.t = t_val;
            obj.last_str = '300 450';
            obj.h.f2 = figure; obj.h.ax2 = axes('Parent', obj.h.f2,...
                'Position', [0.1, 0.15 0.86, 0.75]);

%             dropdown for effects
%             obj.h.drpdwn = uicontrol('style', 'popupmenu' , 'string', ...
%                 effect_names, 'units', ...
%                 'normalized', 'position', ...
%                 [0.3, 0.001, 0.2, 0.05], 'callback', ...
%                 @(o, e) obj.change_effect(), 'value', 1);

            obj.refresh_effect();
% 
%             'callback', ...
%                 @(o, e) obj.refresh_patch(), 'value', 1);
            
            obj.h.f3 = []; obj.h.ax3 = [];
            obj.draw_patch();
        end
        
        
        function draw_patch(obj)
            obj.h.patch = patch('Parent', obj.h.ax2, 'vertices', [1,1,0,0; 1,0,1,0]',...
                'Faces', 1:4, 'Visible', 'off', 'FaceAlpha', 0.3);
        end

        function refresh_patch(obj)
            strval = get(obj.h.winlims, 'String');
            if isequal(obj.last_str, strval)
                return
            end
            obj.last_str = strval;
            xlim = str2num(strval); %#ok<ST2NM>
            xlim = xlim(1:2);
            ylim = get(obj.h.ax2, 'ylim');
            set(obj.h.patch, 'Visible', 'on', 'Vertices', ...
                [xlim, fliplr(xlim); ylim([1,1,2,2])]', 'Faces', 1:4);
            % draw topoplot
            sample_range = find_range(obj.EEG.times, xlim);
            val = mean(obj.t(:, sample_range(1):sample_range(2), ...
                obj.opt.current_effect), 2);
            obj.refresh_topo(val);
        end

        function refresh_topo(obj, val)
            if ishandle(obj.h.ax1)
                axes(obj.h.ax1);
                cla(obj.h.ax1);
            else
                obj.h.f1 = figure; obj.h.ax1 = axes('Parent', obj.h.f1);
            end
            topoplot(val, obj.EEG.chanlocs, 'electrodes', 'on'); % 'chaninfo', self.EEG.chaninfo
            obj.topo = topo_scrapper(gca);
            set(obj.topo.elec_marks, 'ButtonDownFcn', @(o, e) obj.show_elec());
        end

        function show_elec(obj)
            % the marks have this button callback:
            % tmpstr = get(gco, 'userdata');
            % set(gco, 'userdata', get(gco, 'string'));
            % set(gco, 'string', tmpstr);
            % clear tmpstr;
            cursor_pos = get(gca, 'currentpoint');
            difs = bsxfun(@minus, obj.topo.elec_pos(:, 1:2), ...
                cursor_pos(1,1:2));
            difs = sum(abs(difs), 2);
            [~, chan_ind] = min(difs);

            % change color
            if ~isempty(obj.opt.current_electrode_h)
                try
                delete(obj.opt.current_electrode_h);
                end
            end

            hold on;
            sc = scatter(obj.topo.elec_pos(chan_ind,1), ...
                obj.topo.elec_pos(chan_ind,2), ...
                'FaceColor', 'r');
            obj.opt.current_electrode_h = sc;

            obj.opt.current_electrode = chan_ind;
            if obj.dims > 3
                obj.refresh_effect();
            else
                obj.refresh_chanplot();
            end
        end
        
        function out = pos2vert(obj)
            % find closest x and y for start and fin
            
            out = [pstart; ...
                pend(1), pstart(2); ...
                pend; ...
                pstart(1), pend(2)];
        end
        
        function modif_range(obj)
            
            cursor_pos = get(gca, 'currentpoint');
            cursor_pos = cursor_pos(1,1:2);
            if ~obj.opt.patch_on
                obj.opt.patch_on = true;
                obj.opt.patch_start = cursor_pos;
                obj.opt.patch_end = cursor_pos;
                vert = obj.pos2vert();
                obj.opt.patch = patch('vertices', vert, ...
                    'faces', 1:4, 'linewidth', 2, ...
                    'facecolor', [0,1,0], ...
                    'facealpha', 0.3);
            else
                obj.opt.patch_end = cursor_pos;
                vert = obj.pos2vert();
                 %## !!! ##
                set(obj.opt.patch, 'XData', 666);
                  
            end
        end
%         function change_effect(obj)
%             neweff = get(obj.h.drpdwn, 'Value');
%             if ~(obj.opt.current_effect == neweff)
%                 obj.opt.current_effect = neweff;
%                 obj.refresh_effect();
%             end
%         end
        
        function refresh_effect(obj)
            cla(obj.h.ax2);
            if obj.dims == 4
                t = squeeze(obj.t(:, :, obj.opt.current_electrode, ...
                    obj.opt.current_effect)); %#ok<*PROP>
            else
                t = obj.t(:, :, obj.opt.current_electrode);
            end
            if obj.opt.hasstat
                mask = get_cluster_mask(obj.stat, 0.05);
            else
                % mask = abs(t) > obj.opt.t_threshold;
                mask = [];
            end
            maskitsweet(t, mask, ...
                'FigH', obj.h.f2, 'AxH', obj.h.ax2, ...
                'Time', obj.opt.xaxis, 'nosig', 0.75, ...
                'CMin', 0, 'CMax', 0.001, 'CMap', hot(256), ...
                'MapEdge', 'lin', 'MapCent', []);
            % redraw patch
            obj.last_str = '';
            obj.draw_patch();
        end
        
        function refresh_chanplot(obj)
            % create chan figure if absent
            if isempty(obj.h.f3) || ~ishandle(obj.h.f3)
                obj.h.f3 = figure;
                obj.h.ax3 = axes;
            else
                axes(obj.h.ax3);
                cla;
            end
            
            % plot with default if no chanfun
            if ~isempty(obj.fun.chan)
                obj.fun.chan(obj.h.f3, obj.opt.current_electrode);
            else
                plot(obj.EEG.times, obj.t(obj.opt.current_electrode, :, ...
                    obj.opt.current_effect), 'linewidth', 2, ...
                    'linesmoothing', 'on');
            end
            
        end
    end
end