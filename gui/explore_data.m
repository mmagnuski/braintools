classdef explore_data < handle

    % simple interface for exploring multi-dim EEG data
    %
    % usage:
    % obj = explore_data(EEG, stat);
    %
    % Compulsory arguments
    % --------------------
    % EEG : eeglab data structure
    %    eeg data is used mostly to get channel locations for
    %    topoplot
    % stat : n-dimentional matrix
    %    has to conform to following dimensions order:
    %    * 3D - (n, m, channels) or (n, channels, effects) if effects
    %                            is set to true
    %    * 4D - (n, m, channels, effects)
    %
    % Optional key-value arguments
    % ----------------------------
    % captype : string
    %    String describing cap type.
    % effects
    % xaxis
    % yaxis
    % minchan
    % proportional_scale
    % max_map
    % chanconn
    % clusters
    % clustermask
    % xaxis_labels
    % yaxis_labels
    % effect_names

    % TODO:
    % - [ ] add back channel names
    % - [ ] support for 2D?
    % - [ ] ...

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

            obj.opt.xaxis = [];
            obj.opt.yaxis = [];
            obj.opt.maskx = [];
            obj.opt.masky = [];
            obj.opt.xaxis_labels = [];
            obj.opt.yaxis_labels = [];

            obj.opt.captype = 'EGI64';
            obj.opt.thresh = '10%';
            obj.opt.chanconn = [];
            obj.opt.clusters = [];
            obj.opt.clustermask = [];
            obj.opt.minchan = 0;
            obj.opt.effect = false;
            obj.opt.effect_names = [];

            obj.opt.max_map = 0.001;
            obj.opt.proportional_scale = true;

            if nargin > 2
                obj.opt = parse_arse(varargin, obj.opt);
            end

            % init - topofigure
            obj.h.f1 = figure('units', 'normalized'); 
            obj.h.ax1 = axes('Parent', obj.h.f1);
            obj.dims = ndims(t_val);
            % obj.opt.t_threshold = 1.8;
            obj.opt.current_electrode = 1;
            obj.opt.current_electrode_h = [];

            obj.opt.patch_on = false;
            obj.opt.patch_start = [];
            obj.opt.patch_stop = [];

            obj.opt.filter_thresh = 0;
            obj.opt.filter_kernel = ones(3, 3);
            obj.opt.filter_kernel(2, 2) = 0;

            % plot electrodes
            if obj.dims > 2 % this could work for 2D too, based on stat
                topoplot([], EEG.chanlocs, 'style', 'blank', ...
                    'electrodes', 'on');
            else
                topoplot([], EEG.chanlocs, 'electrodes', 'on');
            end
            if obj.dims > 3 || obj.opt.effect
                obj.opt.effect = true;
                obj.opt.current_effect = 1;
                if obj.dims == 4
                    obj.opt.num_effects = size(t_val, 4);
                elseif obj.dims == 3
                    obj.opt.num_effects = size(t_val, 3);
                end
                if isempty(obj.opt.effect_names)
                    obj.opt.effect_names = arrayfun(@(x) ...
                        sprintf('effect_%d', x), 1:obj.opt.num_effects, ...
                        'UniformOutput', false);
                end
            end

            obj.topo = topo_scrapper(gca);
            set(obj.topo.elec_marks, 'ButtonDownFcn', ...
                @(o, e) obj.show_elec());
            set(obj.h.f1, 'ButtonDownFcn', @(o, e) obj.show_elec());

            obj.EEG = EEG;
            obj.t = t_val;
            if any(obj.t(:) < 0)
                obj.opt.negative_values = true;
                obj.opt.cmap = jet(256);
            else
                obj.opt.negative_values = false;
                obj.opt.cmap = hot(256);
            end

            obj.h.f2 = figure; obj.h.ax2 = axes('Parent', obj.h.f2,...
                'Position', [0.1, 0.15 0.8, 0.75]);

            % all_points = numel(t_val);
            obj.opt.max_val = max(t_val(:));
            % obj.opt.max_val = obj.opt.max_val(round(all_points * 0.99));
            obj.h.scale_axis = axes('Parent', obj.h.f2, 'Position', ...
                [0.92, 0.15, 0.06, 0.75], 'XTick', [], ...
                'YTick', [], 'YLim', [0, obj.opt.max_val]);

            obj.refresh_effect();

            % find handle to the image
            chldr = get(gca, 'Children');
            chldr_type = get(chldr, 'type');
            im_chldr = find(strcmp('image', chldr_type));
            obj.h.image = chldr(im_chldr(end));
            obj.h.mask = chldr(im_chldr(1));

            if isempty(obj.opt.xaxis)
                obj.opt.xaxis = get(obj.h.image, 'XData');
                obj.opt.maskx = get(obj.h.mask, 'XData');
            end
            if isempty(obj.opt.yaxis)
                obj.opt.yaxis = get(obj.h.image, 'YData');
                obj.opt.masky = get(obj.h.mask, 'YData');
            end
            obj.opt.xdiff = mean(diff(obj.opt.xaxis));
            obj.opt.ydiff = mean(diff(obj.opt.yaxis));
            obj.opt.patch = [];

            % use linear axis info - XData and YData
            % assume linear progression
            obj.opt.linxaxis = linspace(obj.opt.xaxis(1), ...
                obj.opt.xaxis(end), length(obj.opt.xaxis));
            obj.opt.linyaxis = linspace(obj.opt.yaxis(1), ...
                obj.opt.yaxis(end), length(obj.opt.yaxis));

            set(obj.h.f2, 'WindowButtonDownFcn', ...
                @(o,e) obj.turn_selection_on());

            obj.h.f3 = []; obj.h.ax3 = [];

            % add cluster button
            obj.h.cluster_button = uicontrol('parent', obj.h.f2, ...
                'style', 'pushbutton', 'units', 'normalized', ...
                'position', [0.8, 0.01, 0.15, 0.065], 'string', ...
                'cluster', 'callback', @(o,e) obj.cluster());
            obj.h.tresh_box = uicontrol('parent', obj.h.f2, ...
                'style', 'edit', 'units', 'normalized', ...
                'position', [0.65, 0.01, 0.12, 0.065], 'string', ...
                '10%', 'callback', @(o,e) obj.set_tresh());
            obj.h.minchan_box = uicontrol('parent', obj.h.f2, ...
                'style', 'edit', 'units', 'normalized', ...
                'position', [0.55, 0.01, 0.07, 0.065], 'string', ...
                '0', 'callback', @(o,e) obj.set_minchan());
            obj.h.filter_box = uicontrol('parent', obj.h.f2, ...
                'style', 'edit', 'units', 'normalized', ...
                'position', [0.45, 0.01, 0.07, 0.065], 'string', ...
                '', 'callback', @(o,e) obj.set_filter());
            % add arrows if more than 3 dimensions
            if obj.dims > 3 || obj.opt.effect
                obj.h.left_button = uicontrol('parent', obj.h.f2, ...
                    'style', 'pushbutton', 'units', 'normalized', ...
                    'position', [0.05, 0.01, 0.05, 0.065], 'string', ...
                    '<', 'callback', @(o,e) obj.change_effect(-1));
                obj.h.right_button = uicontrol('parent', obj.h.f2, ...
                    'style', 'pushbutton', 'units', 'normalized', ...
                    'position', [0.35, 0.01, 0.05, 0.065], 'string', ...
                    '>', 'callback', @(o,e) obj.change_effect(1));
                obj.h.mid_text = uicontrol('parent', obj.h.f2, ...
                    'style', 'text', 'units', 'normalized', ...
                    'position', [0.15, 0.01, 0.15, 0.065], 'string', ...
                    obj.opt.effect_names{1});
            end
        end


        function draw_patch(obj)
            obj.h.patch = patch('Parent', obj.h.ax2, 'vertices', [1,1,0,0; 1,0,1,0]',...
                'Faces', 1:4, 'Visible', 'off', 'FaceAlpha', 0.3);
        end

        function turn_selection_on(obj)
            % drag rectangle after cursor and update topo after release
            cursor_pos = get(obj.h.ax2, 'currentpoint');
            cursor_pos = cursor_pos(1,1:2);
            xlm = get(obj.h.ax2, 'XLim');
            ylm = get(obj.h.ax2, 'YLim');

            if cursor_pos(1) > xlm(1) && ...
                    cursor_pos(1) < xlm(2) && ...
                    cursor_pos(2) > ylm(1) && ...
                    cursor_pos(2) < ylm(2)
                set(obj.h.f2, 'WindowButtonMotionFcn', ...
                    @(o,e) obj.modif_range());
                set(obj.h.f2, 'WindowButtonUpFcn', ...
                    @(o,e) obj.on_release_activate_range());
                set(obj.h.f2, 'WindowButtonDownFcn', '');
            end
        end

        % TODO: add option to set stable scale for topo too
        function refresh_topo(obj, val)
            % updates topo
            if ishandle(obj.h.ax1)
                axes(obj.h.ax1);
                cla(obj.h.ax1);
            else
                obj.h.f1 = figure; obj.h.ax1 = axes('Parent', obj.h.f1);
            end
            topoplot(val, obj.EEG.chanlocs, 'electrodes', 'on'); % 'chaninfo', self.EEG.chaninfo
            obj.topo = topo_scrapper(gca);
            set(obj.topo.elec_marks, 'ButtonDownFcn', @(o, e) obj.show_elec());
            set(obj.h.f1, 'ButtonDownFcn', @(o, e) obj.show_elec());
            set(obj.topo.hggroup, 'ButtonDownFcn', @(o, e) obj.show_elec());
            chldr = get(obj.h.ax1, 'Children');
            chldr_types = get(chldr, 'type');
            surface_obj = find(strcmp('surface', chldr_types));
            if ~isempty(surface_obj)
                surface_obj = chldr(surface_obj);
                set(surface_obj, 'ButtonDownFcn', @(o, e) obj.show_elec());
            end
        end

        function show_elec(obj)
            % update main window after clicking on topo
            %
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
                try %#ok<TRYNC>
                    delete(obj.opt.current_electrode_h);
                end
            end

            hold on;
            sc = scatter(obj.topo.elec_pos(chan_ind,1), ...
                obj.topo.elec_pos(chan_ind,2), 48, ...
                'FaceColor', 'w');
            obj.opt.current_electrode_h = sc;

            obj.opt.current_electrode = chan_ind;
            if ~(obj.dims == 2 ||(obj.dims == 3 && obj.opt.effect))
                obj.refresh_effect();
            end
        end

        function out = pos2vert(obj)
            % find closest x and y for start and fin
            x = sort([obj.opt.patch_start(1), obj.opt.patch_end(1)]);
            y = sort([obj.opt.patch_start(2), obj.opt.patch_end(2)]);
            x = find_range(obj.opt.linxaxis, x);
            y = find_range(obj.opt.linyaxis, y);

            obj.opt.xsel = x;
            obj.opt.ysel = y;

            x = obj.opt.linxaxis(x);
            y = obj.opt.linyaxis(y);

            % snap values to grid (assumes grid is linear)
            x = x + (obj.opt.xdiff * [-1, 1]) / 2; 
            y = y + (obj.opt.ydiff * [-1, 1]) / 2;
            
            out = [x([1, 2, 2, 1])', y([1, 1, 2, 2])'];
        end

        function modif_range(obj)

            cursor_pos = get(obj.h.ax2, 'currentpoint');
            cursor_pos = cursor_pos(1,1:2);
            if ~obj.opt.patch_on
                obj.opt.patch_on = true;
                if ~isempty(obj.opt.patch)&& ishandle(obj.opt.patch)
                    delete(obj.opt.patch);
                end
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
                set(obj.opt.patch, 'XData', vert(:,1));
                set(obj.opt.patch, 'YData', vert(:,2));
                set(obj.opt.patch, 'Vertices', vert);

            end
        end

        function on_release_activate_range(obj)
            if obj.opt.patch_on
                % turn off mouse tracking
                set(obj.h.f2, 'WindowButtonMotionFcn', '');
                set(obj.h.f2, 'WindowButtonUpFcn', '');

                obj.opt.patch_on = false;
                x = obj.opt.xsel;
                y = obj.opt.ysel;

                if obj.dims == 3
                    if obj.opt.effect
                        temp_t = obj.t(:, :, obj.opt.current_effect)';
                        mean_val = squeeze(nanmean(...
                            temp_t(:, x(1):x(2)), 2))';
                    else
                        data = obj.t(y(1):y(2), x(1):x(2), :);
                        mean_val = squeeze(nanmean(nanmean(data, 1), 2))';
                    end
                elseif obj.dims == 4
                    data = obj.t(y(1):y(2), x(1):x(2), :, ...
                        obj.opt.current_effect);
                    mean_val = squeeze(nanmean(nanmean(data, 1), 2))';
                end
                
                obj.refresh_topo(mean_val);
                set(obj.h.f2, 'WindowButtonDownFcn', ...
                    @(o,e) obj.turn_selection_on());
            end
        end

%         function change_effect(obj)
%             neweff = get(obj.h.drpdwn, 'Value');
%             if ~(obj.opt.current_effect == neweff)
%                 obj.opt.current_effect = neweff;
%                 obj.refresh_effect();
%             end
%         end
        function change_effect(obj, v)
            neweff = min([obj.opt.num_effects, ...
                max([1, obj.opt.current_effect + v])]);
            if ~(obj.opt.current_effect == neweff)
                obj.opt.current_effect = neweff;
                set(obj.h.mid_text, 'string', ...
                    obj.opt.effect_names{obj.opt.current_effect});
                obj.refresh_effect();
            end
        end

        function set_filter(obj)
            obj.opt.filter_thresh = str2num(get(obj.h.filter_box, 'string')); %#ok<ST2NM>
        end

        function refresh_effect(obj)
            cla(obj.h.ax2);
            axes(obj.h.ax2);
            if obj.dims == 4
                t = squeeze(obj.t(:, :, obj.opt.current_electrode, ...
                    obj.opt.current_effect)); %#ok<*PROP>
            elseif obj.dims == 3
                if obj.opt.effect
                    t = obj.t(:, :, obj.opt.current_effect)';
                else
                    t = obj.t(:, :, obj.opt.current_electrode);
                end
            end

            % this should change
%             if obj.opt.hasstat
%                 mask = get_cluster_mask(obj.stat, 0.05);
%             else
%                 % mask = abs(t) > obj.opt.t_threshold;
%                 mask = [];
%             end

            if isempty(obj.opt.clustermask)
                msk = [];
            else
                if obj.dims == 3 && obj.opt.effect
                    msk = squeeze(obj.opt.clustermask(:,:));
                else
                    msk = squeeze(obj.opt.clustermask(...
                        obj.opt.current_electrode,:,:));
                end
            end
            if isempty(obj.opt.xaxis)
                obj.opt.xaxis = 1:size(obj.t, 2);
            end
            if isempty(obj.opt.yaxis)
                obj.opt.yaxis = 1:size(obj.t, 1);
            end
            if obj.dims == 3 && obj.opt.effect
                temp = obj.opt.xaxis;
                obj.opt.xaxis = obj.opt.yaxis;
                obj.opt.yaxis = temp;
            end
            mx = obj.opt.max_map;
            sorted = sort(t(:));
            sorted = sorted(~isnan(sorted));
            t_len = length(sorted);

            if obj.opt.proportional_scale
                mx = sorted(round(t_len*0.99));
            end
            if obj.opt.negative_values && any(sorted < 0)
                minv = sorted(max([1, round(t_len*0.01)]));
                max_abs = max(abs([minv, mx]));
                mx = max_abs; minv = -max_abs;
            else
                minv = 0;
            end

            obj.opt.local_max_val = mx;
            obj.opt.local_min_val = minv;
            if obj.opt.negative_values
                maskitsweet(t, msk, ...
                'FigH', obj.h.f2, 'AxH', obj.h.ax2, ...
                'Time', obj.opt.xaxis, 'Freq', obj.opt.yaxis, ...
                'nosig', 0.75, ...
                'CMin', minv, 'CMax', mx, 'CMap', obj.opt.cmap);
            else
                maskitsweet(t, msk, ...
                    'FigH', obj.h.f2, 'AxH', obj.h.ax2, ...
                    'Time', obj.opt.xaxis, 'Freq', obj.opt.yaxis, ...
                    'nosig', 0.75, ...
                    'CMin', minv, 'CMax', mx, 'CMap', obj.opt.cmap, ...
                    'MapEdge', 'lin', 'MapCent', []);
            end
            obj.opt.patch_on = false;
            obj.opt.patch = [];
            if ~isempty(obj.opt.xaxis_labels)
                set(obj.h.ax2, 'xtick', obj.opt.xaxis_labels{1});
                set(obj.h.ax2, 'xticklabel', obj.opt.xaxis_labels{2});
            end
            if ~isempty(obj.opt.yaxis_labels)
                set(obj.h.ax2, 'ytick', obj.opt.yaxis_labels{1});
                set(obj.h.ax2, 'yticklabel', obj.opt.yaxis_labels{2});
            end

            obj.refresh_scale();
        end

        function data = filter_bool(obj, data)
            % currently works only for 3D (n, m, channels) data
            if obj.opt.filter_thresh == 0
                return
            end
            if obj.opt.filter_thresh < 1.
                real_thresh = obj.opt.filter_thresh * sum(...
                    sum(obj.opt.filter_kernel));
            else
                real_thresh = obj.opt.filter_thresh;
            end
            for ch = 1:size(data, 1)
                slice = squeeze(data(ch, :, :));
                data(ch, :, :) = slice .* conv2(...
                    double(slice), obj.opt.filter_kernel, ...
                    'same') >= real_thresh;
            end
        end

        function refresh_scale(obj)
            % CHANGE update to reflect pos-neg too
            % and the scale should work within effect, not across
            cla(obj.h.scale_axis);
            image(reshape(hot(256), [256, 1, 3]), ...
                'Parent', obj.h.scale_axis, ...
                'XData', [0, 0.1], 'YData', ...
                [0, obj.opt.local_max_val]);

            set(obj.h.scale_axis, 'YDir', 'normal');
            set(obj.h.scale_axis, 'YTick', []);
            set(obj.h.scale_axis, 'XTick', []);
            set(obj.h.scale_axis, 'YLim', [0, obj.opt.max_val]);
        end

        function cluster(obj)
            if isempty(obj.opt.chanconn)
                obj.opt.chanconn = get_chanconn(obj.opt.captype, obj.EEG);
            end

            % check if %
            if obj.dims == 3
                if obj.opt.effect
                    data = permute(obj.t(:, :, obj.opt.current_effect), ...
                        [2, 1]);
                else
                    data = permute(obj.t, [3, 1, 2]);
                end
            elseif obj.dims == 4
                data = permute(obj.t(:, :, :, obj.opt.current_effect), ...
                    [3, 1, 2]);
            end
            ifperc = strfind(obj.opt.thresh, '%');
            if ifperc % TODO - if pos and neg!
                val = obj.opt.thresh;
                val(ifperc) = [];
                val = str2num(val)/100; %#ok<ST2NM>

                t_unrl = sort(obj.t(:), 'descend');
                t_unrl = t_unrl(~isnan(t_unrl));

                len = numel(t_unrl);

                if ~obj.opt.negative_values
                    smp = round(val * len);
                    smp = max(1, smp);
                    thresh = t_unrl(smp);

                else
                    smp = round(val/2 * len);
                    smp = max(1, smp);
                    thresh = [t_unrl(smp), t_unrl(end-smp+1)];
                end
            else
                val = str2num(obj.opt.thresh); %#ok<ST2NM>
                thresh = val;
                if obj.opt.negative_values
                    thresh = [thresh, -val];
                end
            end
            booldata = obj.filter_bool(data >= thresh(1));

            obj.opt.clusters = findcluster(booldata, ...
                obj.opt.chanconn, obj.opt.minchan);
            if obj.opt.negative_values
                booldata2 = obj.filter_bool(data <= thresh(2));
                negclusters = findcluster(booldata2, ...
                    obj.opt.chanconn, obj.opt.minchan);
                lastClstNum = max(obj.opt.clusters(:));
                negclusters = (negclusters + lastClstNum) .* uint32(negclusters > 0);
                obj.opt.clusters = obj.opt.clusters + negclusters;
            end

            obj.opt.clustermask = obj.opt.clusters > 0;
            obj.refresh_effect();
        end

        function set_tresh(obj)
            obj.opt.thresh = get(obj.h.tresh_box, 'String');
        end

        function set_minchan(obj)
            obj.opt.minchan = str2num(get(obj.h.minchan_box, 'string')); %#ok<ST2NM>
        end
    end
end