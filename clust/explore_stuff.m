classdef explore_stuff < handle
    
    % simple interface for exploring multi-dim data
    properties
        h
        t
        dims
        last_str
        opt
        EEG
    end
    
    methods
        function obj = explore_stuff(EEG, t_val, effect_names)
            obj.h.f1 = figure; obj.h.ax1 = axes('Parent', obj.h.f1);
            obj.dims = length(size(t_val));
            obj.opt.current_effect = 3;
            obj.opt.t_threshold = 1.8;
            if obj.dims > 3
                obj.opt.current_electrode = 1;
                obj.opt.current_electrode_h = [];
            end

            % plot electrodes
            if obj.dims > 3
                topoplot([], EEG.chanlocs, 'style', 'blank', ...
                    'electrodes', 'labelpoint');
            else
                topoplot([], EEG.chanlocs);
            end
            if obj.dims > 3
                topo = topo_scrapper(gca);
                set(topo.elec_labels, 'ButtonDownFcn', @(o, e) obj.show_elec());
            end
            
            obj.EEG = EEG;
            obj.t = t_val;
            obj.last_str = '300 450';
            obj.h.f2 = figure; obj.h.ax2 = axes('Parent', obj.h.f2,...
                'Position', [0.1, 0.15 0.86, 0.75]);
            obj.h.drpdwn = uicontrol('style', 'popupmenu' , 'string', ...
                effect_names, 'units', ...
                'normalized', 'position', ...
                [0.3, 0.0001, 0.2, 0.1], 'callback', ...
                @(o, e) obj.change_effect(), 'value', 1);
            obj.h.winlims = uicontrol('style', 'edit' , 'string', ...
                obj.last_str, 'units', ...
                'normalized', 'position', ...
                [0.6, 0.0001, 0.3, 0.1], 'callback', ...
                @(o, e) obj.refresh_patch(), 'value', 1);
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
            xlim = str2num(strval);
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
            topoplot(val, obj.EEG.chanlocs); % 'chaninfo', self.EEG.chaninfo
        end

        function show_elec(obj)
            % the marks have this button callback:
            % tmpstr = get(gco, 'userdata');
            % set(gco, 'userdata', get(gco, 'string'));
            % set(gco, 'string', tmpstr);
            % clear tmpstr;
            strelec = get(gco, 'userdata');

            % change color
            set(gco, 'color', 'r');
            if ~isempty(obj.opt.current_electrode_h)
                set(obj.opt.current_electrode_h, ...
                    'color', 'k');
            end
            
            obj.opt.current_electrode = str2num(strelec); %#ok<ST2NM>
            obj.opt.current_electrode_h = gco;
            obj.refresh_effect();
        end

        function change_effect(obj)
            neweff = get(obj.h.drpdwn, 'Value');
            if ~(obj.opt.current_effect == neweff)
                obj.opt.current_effect = neweff;
                obj.refresh_effect();
            end
        end
        
        function refresh_effect(obj)
            cla(obj.h.ax2);
            if obj.dims == 4
                t = squeeze(obj.t(:, :, obj.opt.current_electrode, ...
                    obj.opt.current_effect)); %#ok<*PROP>
            else
                t = obj.t(:, :, obj.opt.current_effect);
            end
            maskitsweet(t, abs(t) > obj.opt.t_threshold, ...
                'FigH', obj.h.f2, 'AxH', obj.h.ax2, ...
                'Time', obj.EEG.times);
            % redraw patch
            obj.last_str = '';
            obj.draw_patch();

        end
    end
end