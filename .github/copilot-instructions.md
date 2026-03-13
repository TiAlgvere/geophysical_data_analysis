# Geophysical Data Analysis Project Guidelines

## Code Style

**MATLAB Structure:**
- Always start scripts with: `clearvars; close all; clc`
- Use section comments with dashes: `% --- Description ---`
- Variable names include units: `pressure_dbar`, `SA_gkg`, `CT_degC`, `juda_UTC`
- Relative paths from project root: `'../../data/'` or `'exercises/lec_XX/results'`
- Save results as `.mat` files in `exercises/lec_XX/results/` directories

**Code Organization:**
```matlab
% Standard pattern: Load → Process → Visualize → Save
data_file = 'path/to/file.mat';
S = load(data_file);
% --- Processing step description ---
result = process_data(S.variable);
% --- Visualization ---
figure; plot(result);
save('output.mat', 'result');
```

## Data Handling Conventions

**File Formats:**
- NetCDF (.nc): Use `ncread(filename, 'variable_name')` for variables, `ncinfo()` for metadata
- MATLAB tables (.mat): Load via `S = load(file); T = S.variable_name`
- Always check data dimensions with `size()` or `ndims()` before processing

**Critical Patterns:**
- Filter NaNs before statistics: `valid = ~isnan(x) & ~isnan(y); x = x(valid);`
- Land-sea masking: `data(lsm_2d == 1) = NaN;` where `lsm` is land-sea mask
- Grid plotting requires transpose: `imagesc(lon, lat, data')`
- Time conversion from NetCDF: `datetime(time, 'ConvertFrom', 'datenum')`

**Common Coordinate Variables:**
- `lat`, `lon` for spatial coordinates
- `[LON, LAT] = meshgrid(lon, lat)` for 2D grids (uppercase for mesh arrays)
- `u10`, `v10` for wind components; wind speed: `WS = sqrt(u10.^2 + v10.^2)`

## Architecture

**Project Structure:**
- `exercises/lec_XX/`: MATLAB exercise code and results
- `data/`: Reference datasets (.mat, .nc files)
- `lectures/`: Course materials (PDFs)
- Python scripts for NetCDF inspection only (not core analysis)

**Data Flow:**
1. Load data from `data/` directory
2. Process and clean (handle outliers, missing values)
3. Visualize with proper axis labels and colorbars
4. Save results to `exercises/lec_XX/results/`

## Conventions

**Visualization Standards:**
- Use `figure('Color', 'w')` for white backgrounds
- Reverse Y-axis for depth data: `set(gca, 'YDir', 'reverse')`
- Label colorbars: `cb = colorbar; cb.Label.String = 'Units';`
- Include units in axis labels: `'Salinity (g kg^{-1})'`

**File Paths:**
- Always use relative paths from project root
- Create output directories defensively:
  ```matlab
  if ~exist(out_dir, 'dir')
      mkdir(out_dir)
  end
  ```
- Check file existence before loading: `if exist(filename, 'file')`

**Common Pitfalls to Avoid:**
- Don't assume working directory - use relative paths consistently
- Always verify NetCDF variable dimensions before `mean(data, dim)`
- Handle 2D vs 3D land-sea masks: check `ndims(lsm)` first
- Apply data quality filters before statistical analysis
- Use appropriate NaN-handling functions (`nanmean`, `nanstd`) or filter first

## Domain-Specific Notes

**Geophysical Variables:**
- Salinity: typically 4-12 g/kg range
- Temperature: Conservative Temperature (CT) in °C
- Pressure: in decibars (dbar), often used as depth proxy
- Wind: u10/v10 components, calculate direction with `mod(atan2d(u10, v10), 360)`
- Time: Often as Julian days or datenum format

**Quality Control:**
- Apply physical constraints (e.g., `sal_bot >= 7` for realistic salinity)
- Remove outliers before analysis
- Use separate "clean" data files when available
- Check for missing data patterns before computing statistics