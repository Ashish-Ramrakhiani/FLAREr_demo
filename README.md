# FLARE Simulation Project

This repository contains code for running FLARE simulations with FaaSr integration. Follow these setup instructions to run the simulations on your local machine.

## Prerequisites

- R programming environment
- Git
- AWS credentials (for S3 storage access)

## Installation

1. Clone this repository:
```bash
git clone https://github.com/Ashish-Ramrakhiani/FLAREr_demo.git
cd FLAREr_demo
```

2. Install the required dependencies in R:
```R
# Install devtools if you haven't already
install.packages("devtools")

# Install GLM3r from GitHub
remotes::install_github("rqthomas/GLM3r")
```

## Configuration

1. Set up environment variables for GLM and AWS access:
```R
Sys.setenv('GLM_PATH'='GLM3r')
Sys.setenv("AWS_ACCESS_KEY_ID"="YOUR_AWS_ACCESS_KEY")
Sys.setenv("AWS_SECRET_ACCESS_KEY"="YOUR_AWS_SECRET_KEY")
```

**Note:** Replace `YOUR_AWS_ACCESS_KEY` and `YOUR_AWS_SECRET_KEY` with your actual AWS credentials.

## Required Bucket Structure

The FLARE simulation expects a specific bucket structure for data organization. Here's the required structure:

```
"mc_cliet_alias"/bucket5
└─ flare
   ├─ drivers
   │  ├─ iflow                    # Inflow drivers
   │  │  ├─ f
   │  │  │  └─ model_id=h
   │  │  │     └─ reference_datetime=2022-10-02
   │  │  │        └─ site_id=fcre
   │  │  │           └─ p.parquet
   │  │  └─ h
   │  │     └─ model_id=h
   │  │        └─ site_id=fcre
   │  │           └─ part-0.parquet
   │  ├─ met                      # Meteorological drivers
   │  │  ├─ ensemble_forecast
   │  │  │  └─ model_id=gfs_seamless
   │  │  │     └─ reference_date=2022-10-02
   │  │  │        └─ site_id=fcre
   │  │  │           └─ part-0.parquet
   │  │  └─ gefs
   │  │     ├─ st2
   │  │     │  └─ reference_datetime=2022-10-02
   │  │     │     └─ site_id=fcre
   │  │     │        └─ part-0.parquet
   │  │     └─ stage3
   │  │        └─ site_id=fcre
   │  │           └─ part-0.parquet
   │  └─ oflow                    # Outflow drivers
   │     ├─ f
   │     │  └─ model_id=h
   │     │     └─ reference_datetime=2022-10-02
   │     │        └─ site_id=fcre
   │     │           └─ p.parquet
   │     └─ h
   │        └─ model_id=h
   │           └─ site_id=fcre
   │              └─ p.parquet
   ├─ forecasts                   # Generated forecasts
   │  └─ parquet
   │     └─ site_id=fcre
   │        └─ model_id=test
   │           └─ reference_date=2022-10-02
   │              └─ part-0.parquet
   └─ restart                     # Restart files
      └─ fcre
         └─ test
            ├─ configure_run.yml
            └─ fcre-2022-10-02-test.nc
```

### Key Components:
- `drivers/`: Contains all input drivers for the simulation
  - `iflow/`: Inflow data
  - `met/`: Meteorological data and forecasts
  - `oflow/`: Outflow data
- `forecasts/`: Stores generated forecast outputs
- `restart/`: Contains configuration and state files for simulation restarts

Make sure to maintain this structure when setting up your environment. The simulation expects data files to be in their respective locations.

## Running the Simulation

1. Load the FLAREr package:
```R
library(devtools)
devtools::load_all()
```

2. Initialize the forecast environment:
```R
paths <- initialize_forecast_environment(local_fork_directory="~/FLAREr_demo")
```

3. Run the FLARE simulation:
```R
next_restart <- FLAREr::run_flare(
    lake_directory = paths$lake_directory,
    configure_run_file = "configure_run.yml",
    config_set_name = "default"
)
```

## Expected Output

The simulation will run through multiple time steps, showing progress for each step. You should see output similar to:
- Data assimilation statistics for each zone temperature
- Mean and standard deviation calculations
- Progress updates for each time step

The simulation generates:
- Forecast data
- Restart files
- Visualization plots
- Data uploaded to S3 storage

## Troubleshooting

Common issues and solutions:

1. If you see `Error: object 'FLAREr' not found`, make sure you've run `devtools::load_all()` first.
2. If you encounter S3 upload errors, verify your AWS credentials are correct and you have the necessary permissions.
3. For "function not found" errors, ensure all dependencies are properly installed.
4. If files are not found, verify your bucket structure matches the required format.
