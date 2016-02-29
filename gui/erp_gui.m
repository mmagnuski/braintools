classdef erp_gui
    
    % in - EEG with epochs
    % a list of conditions
    
    properties
        EEG
        figure
        erp_axis
        lines
        chan
        run_button
        opt
    end
    
    methods
        function obj = erp_gui(EEG)
            % init
            obj.figure = figure; %#ok<CPROP>
            obj.erp_axis = axes('Position', [0.1, 0.3, 0.9, 0.65]);
            obj.EEG = EEG;
            
            eps = epoch_centering_events(EEG, {'car_0', 'face_0'});
            obj.opt.car_epochs = find(eps(1,:));
            obj.opt.face_epochs = find(eps(2,:));
            
            obj.opt.current_face = randi(length(obj.opt.car_epochs));
            obj.opt.current_car = randi(length(obj.opt.face_epochs));
            
            obj.chan = find_elec(EEG, 'E47');
            car_erp = give_erp(EEG, obj.chan, ...
                obj.opt.car_epochs(obj.opt.current_car));
            face_erp = give_erp(EEG, obj.chan, ...
                obj.opt.face_epochs(obj.opt.current_face));
            
            obj.lines(1) = plot(EEG.times, face_erp);
            hold on
            obj.lines(2) = plot(EEG.times, car_erp);
            title('1');
            
            % button
            legend({'twarz', 'samochod'}, 'Location', 'northwest');
                        obj.run_button = uicontrol('parent', obj.figure, ...
                'Style', 'pushbutton', 'Units', 'normalized', ...
                'Position', [0.3, 0.03, 0.4, 0.15], ...
                'callback', @(o,e) obj.run_erp, ...
                'String', 'jedziemy!');
            
            % manual xlim, ylim
            set(obj.erp_axis, 'YLim', [-30, 20]);
            set(obj.erp_axis, 'XLimMode', 'manual');
            set(obj.erp_axis, 'YLimMode', 'manual');
        end
        
        function run_erp(obj)
            max_ep = min([length(obj.opt.car_epochs), ...
                length(obj.opt.face_epochs)]);
            cr = obj.opt.car_epochs;
            fc = obj.opt.face_epochs;
            cc = obj.opt.current_car;
            ff = obj.opt.current_face;
            cr(cc) = [];
            fc(ff) = [];
            pause_val = 0.5/max_ep;
            for num_ep = 2:max_ep
                cari = randperm(length(cr), 1);
                faci = randperm(length(fc), 1);
                ff = [ff, fc(faci)]; %#ok<AGROW>
                cc = [cc, cr(cari)]; %#ok<AGROW>
                cr(cari) = [];
                fc(faci) = [];
                car_erp = give_erp(obj.EEG, obj.chan, cc);
                face_erp = give_erp(obj.EEG, obj.chan, ff);
                
                set(obj.lines(1), 'YData', face_erp);
                set(obj.lines(2), 'YData', car_erp);
                title(num2str(num_ep));
                drawnow; pause(1 / num_ep);
            end
        end
    end
end