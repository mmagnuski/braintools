function path = get_eeglab_plugin_path(plugin_name)

% get eeglab path
eegpth = fileparts(which('eeglab.m'));

% plugins are in plugins folder
lst = dir(fullfile(eegpth, 'plugins'));
% only directories
lst = lst([lst.isdir]);

% looking for plugin
isplug = ~cellfun(@(x) isempty(strfind(x, plugin_name)), {lst.name});

if any(isplug)
    isplug  = find(isplug);
    isplug = isplug(1); % only first one taken - CHANGE maybe
    path = fullfile(eegpth, 'plugins', lst(isplug).name);
else
    error('Could not find plugin %s\n', plugin_name);
end