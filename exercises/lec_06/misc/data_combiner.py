import argparse
import re
from pathlib import Path
from time import perf_counter

import xarray as xr


YEAR_FILE_PATTERN = re.compile(r"^data_(\d{4})\.nc$")


def _project_root() -> Path:
    return Path(__file__).resolve().parents[3]


def _build_parser() -> argparse.ArgumentParser:
    default_input_dir = _project_root() / "data" / "combine"
    default_output_file = default_input_dir / "combined_1997_to_2025.nc"

    parser = argparse.ArgumentParser(
        description="Combine yearly ERA5 NetCDF files (data_YYYY.nc) into one file."
    )
    parser.add_argument(
        "--input-dir",
        type=Path,
        default=default_input_dir,
        help=f"Directory with yearly files. Default: {default_input_dir}",
    )
    parser.add_argument(
        "--output-file",
        type=Path,
        default=default_output_file,
        help=f"Output NetCDF path. Default: {default_output_file}",
    )
    parser.add_argument(
        "--time-dim",
        default="valid_time",
        help="Time dimension/coordinate name used for concatenation.",
    )
    parser.add_argument(
        "--time-chunk",
        type=int,
        default=744,
        help=(
            "Output chunk size for the time dimension. "
            "Use 0 to keep native source chunks instead."
        ),
    )
    parser.add_argument(
        "--compression-level",
        type=int,
        default=1,
        help="NetCDF zlib compression level (0-9). Use 1 for faster writes.",
    )
    parser.add_argument(
        "--engine",
        default="netcdf4",
        help="xarray NetCDF engine (e.g. netcdf4, h5netcdf).",
    )
    parser.add_argument(
        "--parallel-open",
        action="store_true",
        help=(
            "Enable parallel file opening in xarray.open_mfdataset. "
            "Default is off for better stability on Windows."
        ),
    )
    return parser


def _find_yearly_files(input_dir: Path) -> list[Path]:
    if not input_dir.exists():
        raise FileNotFoundError(f"Input directory does not exist: {input_dir}")

    files_with_years: list[tuple[int, Path]] = []
    for path in input_dir.iterdir():
        if not path.is_file():
            continue
        match = YEAR_FILE_PATTERN.match(path.name)
        if match is None:
            continue
        files_with_years.append((int(match.group(1)), path))

    if not files_with_years:
        raise FileNotFoundError(
            f"No files matching data_YYYY.nc found in: {input_dir}"
        )

    files_with_years.sort(key=lambda item: item[0])
    return [path for _, path in files_with_years]


def _preprocess_dataset(dataset: xr.Dataset) -> xr.Dataset:
    drop_candidates = [name for name in ("number", "expver") if name in dataset.coords]
    if drop_candidates:
        dataset = dataset.reset_coords(drop_candidates, drop=True)
    return dataset


def _build_encoding(
    dataset: xr.Dataset,
    time_dim: str,
    time_chunk: int,
    compression_level: int,
) -> dict[str, dict[str, int | bool | tuple[int, ...]]]:
    encoding: dict[str, dict[str, int | bool | tuple[int, ...]]] = {}
    safe_time_chunk = (
        max(1, min(time_chunk, dataset.sizes[time_dim])) if time_chunk > 0 else None
    )

    for variable_name, data_array in dataset.data_vars.items():
        variable_encoding: dict[str, int | bool | tuple[int, ...]] = {
            "zlib": True,
            "complevel": compression_level,
            "shuffle": True,
        }

        if safe_time_chunk is not None and time_dim in data_array.dims:
            variable_encoding["chunksizes"] = tuple(
                safe_time_chunk if dim == time_dim else dataset.sizes[dim]
                for dim in data_array.dims
            )

        encoding[variable_name] = variable_encoding

    return encoding


def combine_era5_files(
    input_dir: Path,
    output_file: Path,
    time_dim: str,
    time_chunk: int,
    compression_level: int,
    engine: str,
    parallel_open: bool,
) -> None:
    start = perf_counter()
    yearly_files = _find_yearly_files(input_dir)
    print(f"Found {len(yearly_files)} yearly files")
    print(f"First file: {yearly_files[0].name}")
    print(f"Last file:  {yearly_files[-1].name}")

    output_file.parent.mkdir(parents=True, exist_ok=True)

    with xr.open_mfdataset(
        [str(file_path) for file_path in yearly_files],
        combine="nested",
        concat_dim=time_dim,
        preprocess=_preprocess_dataset,
        parallel=parallel_open,
        data_vars="minimal",
        coords="minimal",
        compat="override",
        join="override",
        engine=engine,
    ) as dataset:
        if time_dim not in dataset.dims:
            raise ValueError(
                f"Time dimension '{time_dim}' not found. Available dims: {list(dataset.dims)}"
            )

        dataset = dataset.sortby(time_dim)
        time_index = dataset.get_index(time_dim)
        duplicate_mask = time_index.duplicated()
        duplicate_count = int(duplicate_mask.sum())
        if duplicate_count:
            dataset = dataset.sel({time_dim: ~duplicate_mask})
            print(f"Removed {duplicate_count} duplicate {time_dim} values")

        if time_chunk > 0:
            dataset = dataset.chunk({time_dim: time_chunk})

        encoding = _build_encoding(
            dataset=dataset,
            time_dim=time_dim,
            time_chunk=time_chunk,
            compression_level=max(0, min(compression_level, 9)),
        )

        print("Writing combined NetCDF file...")
        dataset.to_netcdf(
            output_file,
            mode="w",
            engine=engine,
            format="NETCDF4",
            encoding=encoding,
        )

    elapsed = perf_counter() - start
    print(f"Done: {output_file}")
    print(f"Elapsed time: {elapsed:.1f} seconds")


def main() -> None:
    args = _build_parser().parse_args()
    combine_era5_files(
        input_dir=args.input_dir,
        output_file=args.output_file,
        time_dim=args.time_dim,
        time_chunk=args.time_chunk,
        compression_level=args.compression_level,
        engine=args.engine,
        parallel_open=args.parallel_open,
    )


if __name__ == "__main__":
    main()