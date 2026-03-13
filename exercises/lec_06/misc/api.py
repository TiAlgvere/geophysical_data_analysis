import os
import importlib
import time
from pathlib import Path
from datetime import datetime, UTC


DATASET = "reanalysis-era5-single-levels"
YEARS = [str(year) for year in range(2022, 1996, -1)]  # 2022 ... 1997
SUBMISSION_DELAY_SECONDS = 1
SUBMITTED_REQUESTS_LOG = "submitted_requests.csv"
RUN_LOCK_FILE = ".download_in_progress.lock"

BASE_REQUEST = {
	"product_type": ["reanalysis"],
	"variable": [
		"10m_u_component_of_wind",
		"10m_v_component_of_wind",
		"sea_surface_temperature",
		"land_sea_mask",
	],
	"month": [f"{month:02d}" for month in range(1, 13)],
	"day": [f"{day:02d}" for day in range(1, 32)],
	"time": [f"{hour:02d}:00" for hour in range(9, 22)],  # 09:00 ... 21:00
	"data_format": "netcdf",
	"download_format": "unarchived",
	"area": [60, 20, 57, 30],
}


def load_submitted_years(log_file: Path) -> set[str]:
	if not log_file.exists():
		return set()

	with log_file.open("r", encoding="utf-8") as file:
		lines = [line.strip() for line in file if line.strip()]

	if not lines:
		return set()

	data_lines = lines[1:] if lines[0].startswith("year,") else lines
	years = set()
	for line in data_lines:
		year = line.split(",", 1)[0].strip()
		if year:
			years.add(year)

	return years


def append_submission_log(log_file: Path, year: str, request_id: str, state: str) -> None:
	write_header = not log_file.exists() or log_file.stat().st_size == 0
	with log_file.open("a", encoding="utf-8") as file:
		if write_header:
			file.write("year,request_id,state,submitted_utc\n")
		timestamp = datetime.now(UTC).isoformat()
		file.write(f"{year},{request_id},{state},{timestamp}\n")


def acquire_run_lock(lock_file: Path) -> None:
	if lock_file.exists():
		raise RuntimeError(
			f"Another download run is already active (lock file exists): {lock_file}. "
			"If no run is active, delete this lock file and rerun."
		)

	lock_file.write_text(str(os.getpid()), encoding="utf-8")


def release_run_lock(lock_file: Path) -> None:
	if lock_file.exists():
		lock_file.unlink()


def build_client():
	try:
		cdsapi = importlib.import_module("cdsapi")
	except ModuleNotFoundError as exc:
		raise RuntimeError(
			"Package 'cdsapi' is not installed. Install it with: pip install cdsapi"
		) from exc

	url = os.getenv("CDSAPI_URL", "https://cds.climate.copernicus.eu/api")
	key = os.getenv("CDSAPI_KEY", "b2e11ecb-d637-485d-9c19-9a011b541bd7")

	return cdsapi.Client(url=url, key=key, wait_until_complete=False, delete=False)


def submit_year_request(client, year: str) -> tuple[str, str]:
	request = {**BASE_REQUEST, "year": [year]}
	print(f"Submitting request for year {year}")
	result = client.retrieve(DATASET, request)
	reply = getattr(result, "reply", {})
	request_id = str(reply.get("request_id", ""))
	state = str(reply.get("state", "submitted"))
	print(f"Submitted year {year}: request_id={request_id}, state={state}")
	return request_id, state


def main() -> None:
	out_dir = Path(__file__).resolve().parent / "downloads_era5"
	out_dir.mkdir(parents=True, exist_ok=True)
	submitted_log = out_dir / SUBMITTED_REQUESTS_LOG
	run_lock = out_dir / RUN_LOCK_FILE
	submitted_years = load_submitted_years(submitted_log)
	acquire_run_lock(run_lock)

	try:
		client = build_client()
		failed_years = []

		for year in YEARS:
			if year in submitted_years:
				print(f"Skipping year {year}: request already submitted")
				continue

			try:
				request_id, state = submit_year_request(client, year)
			except Exception as error:
				print(f"Year {year} failed: {error}")
				failed_years.append(year)
				continue

			append_submission_log(submitted_log, year, request_id, state)
			submitted_years.add(year)
			time.sleep(SUBMISSION_DELAY_SECONDS)

		if failed_years:
			raise RuntimeError(
				"Submission finished with failures for years: " + ", ".join(failed_years)
			)

		print("All requests submitted.")
	finally:
		release_run_lock(run_lock)


if __name__ == "__main__":
	main()
