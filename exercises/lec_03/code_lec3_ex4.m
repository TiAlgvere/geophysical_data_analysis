clearvars
close all
clc

nc_file = 'data/series_bot_lumi_057_a0.nc';

% File info
fprintf('=== File info ===\n');
ncdisp(nc_file);
info = ncinfo(nc_file);
fprintf('Format : %s\n', info.Format);
fprintf('Variables (%d):\n', length(info.Variables));
for i = 1:length(info.Variables)
    v = info.Variables(i);
    fprintf('  %s  size: %s\n', v.Name, mat2str(v.Size));
end

% Read coordinate variables
time_raw = ncread(nc_file, 'time');
rvk      = ncread(nc_file, 'rvk');

% Convert time to MATLAB datetime
t0        = datetime(2009, 12, 28);
time_dt   = t0 + days(time_raw);

fprintf('\nTime range: %s  to  %s  (%d steps)\n', ...
        datestr(time_dt(1)), datestr(time_dt(end)), length(time_dt));
fprintf('RVK range : %.0f  to  %.0f  (%d stations)\n', ...
        rvk(1), rvk(end), length(rvk));

% Read data variables
t_sed = ncread(nc_file, 'iow_ergom_t_sed');
t_ips = ncread(nc_file, 'iow_ergom_t_ips');  

fprintf('t_sed size: %s\n', mat2str(size(t_sed)));
fprintf('t_ips size: %s\n', mat2str(size(t_ips)));

% Figure 1: Time series at one RVK station
rvk_idx = 100;

figure(1);
plot(time_dt, t_sed(:, rvk_idx), 'b-',  'LineWidth', 1.2, 'DisplayName', 'Sediment temp');
hold on;
plot(time_dt, t_ips(:, rvk_idx), 'r--', 'LineWidth', 1.2, 'DisplayName', 'Bottom water temp');
hold off;
xlabel('Time');
ylabel('Temperature (°C)');
title(sprintf('Bottom temperatures at RVK station #%d (index %d)', ...
              rvk(rvk_idx), rvk_idx));
legend('Location', 'best');
grid on;
datetick('x', 'yyyy', 'keepticks');
xtickangle(45);

% Figure 2: Spatial distribution at one time step
t_idx = 1000;

figure(2);
plot(rvk, t_sed(t_idx, :), 'b-',  'LineWidth', 1.2, 'DisplayName', 'Sediment temp');
hold on;
plot(rvk, t_ips(t_idx, :), 'r--', 'LineWidth', 1.2, 'DisplayName', 'Bottom water temp');
hold off;
xlabel('RVK station');
ylabel('Temperature (°C)');
title(sprintf('Spatial distribution of bottom temperatures on %s', ...
              datestr(time_dt(t_idx), 'yyyy-mm-dd')));
legend('Location', 'best');
grid on;
