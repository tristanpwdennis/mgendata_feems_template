# fEEMS with malariagen_data

FEEMS (Fast Estimation of Effective Migration Surfaces) for *Anopheles funestus* using [MalariaGEN](https://malariagen.github.io/vector-data) data.

## Notebooks

| Notebook | What it does |
|----------|-------------|
| `prepare_feems_inputs.ipynb` | Query a given release (e.g. Af1) for samples by country, create outer boundary polygon, visualise the study region + FEEMS grid, export SNPs to PLINK |
| `run_feems.ipynb` | Load PLINK genotypes, align coordinates, run cross-validation to select λ, fit and visualise the effective migration surface |

Run them in order. Each has a **`USER CONFIG`** block at the top — that is the only section you need to edit.

---

## Requirements

- [pixi](https://pixi.sh) — cross-platform conda/pip package manager  
  Install it with:
  ```bash
  curl -fsSL https://pixi.sh/install.sh | bash
  ```
- MalariaGEN data access — if you haven't already, you will be prompted to authenticate with Google when you first run `malariagen_data.Af1()` in a notebook

---

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/tristanpwdennis/mgendata_feems_template.git
cd funestus_feems
```

### 2. Install the environment

```bash
pixi install
```

This creates an isolated environment under `.pixi/` containing all dependencies (feems, malariagen-data, cartopy, suitesparse, etc.). The first run downloads packages and may take a few minutes.

### 3. Register the Jupyter kernel

```bash
pixi run kernel
```

This registers a kernel called **"FEEMS (mgendata)"** that appears in the JupyterLab kernel picker.

### 4. Launch JupyterLab

```bash
pixi run lab
```

Or open the notebooks in an existing JupyterLab instance and select the **"FEEMS (mgendata)"** kernel.

---

## Running the analysis

### Step 1 — `prepare_feems_inputs.ipynb`

Edit the `USER CONFIG` block at the top:

Some example params - change these according to your study region or sample sets anlaysed.

```python
STUDY_REGION = 'kenya'                                      # used in output filenames
BBOX = dict(xmin=33.5, xmax=42.0, ymin=-5.0, ymax=5.0)    # study bounding box
SAMPLE_QUERY = 'taxon == "funestus" & country == "Kenya"'   # AF1 pandas query - if using Af1
SAMPLE_SETS  = None   # None = all public sets; or e.g. ['1232-VO-KE-OCHOMO-VMF00044']
SNP_REGION   = '3RL:6000000-9000000'
N_SNPS       = 100_000
```

Run all cells. The notebook will:
1. Query AF1 and show you what samples are available
2. Build an outer boundary polygon from Natural Earth land data
3. Clip the FEEMS global grid to your study region and plot a two-panel figure showing the bounding box, outer boundary, grid nodes/edges, and sample locations
4. Export SNPs to PLINK (slow — several minutes)

The **PLINK prefix** is printed at the end of the last cell.

### Step 2 — `run_feems.ipynb`

Paste the PLINK prefix into the `USER CONFIG` block:

```python
PLINK_PREFIX = 'feems_outputs/plink/3RL-6000000-9000000.100000.2.1.0'
```

Run all cells. The notebook will:
1. Load genotypes and align sample coordinates to FAM order
2. Build the `SpatialGraph`
3. Run 10-fold cross-validation over a log-spaced λ grid
4. Fit the model at the best λ and plot the effective migration surface

---

## Outputs

All files are written to `feems_outputs/`. This directory isn't tracked by git (it is in the gitignore) so you won't get bulky data in your github repo.

---

## Environment details

The environment is defined in `pixi.toml` and managed by pixi. Key packages:

| Package | Version | Source | Purpose |
|---------|---------|--------|---------|
| `feems` | 2.0 (git) | [NovembreLab/feems](https://github.com/NovembreLab/feems) | FEEMS model fitting |
| `malariagen-data` | 15.2.2 | PyPI | AF1 data access |
| `suitesparse` | ≥7 | conda-forge | Sparse linear algebra (C library) |
| `scikit-sparse` | ≥0.5 | PyPI | Python bindings to SuiteSparse |
| `pandas-plink` | ≥2.3 | PyPI | Read PLINK BED files |
| `cartopy` | ≥0.25 | conda-forge | Mapping + Natural Earth data |
| `shapely` / `fiona` / `pyproj` | — | conda-forge | Geometry + projection |

> **Note**: `malariagen-data` is pinned to 15.2.2 because each release is coupled to specific AF1 data versions. If you need a different version, update `pixi.toml` and test for API changes.

> **Platform**: tested on `linux-64`. The `pixi.toml` also declares `osx-arm64` — if you hit build errors for `scikit-sparse` on macOS, open an issue.

> **HPC / module systems**: if you are on an HPC that loads Python via `module load`, the loaded Python's `site-packages` can bleed into the pixi env via `PYTHONPATH`, causing import errors from mismatched package versions. Before running `pixi run`, unload conflicting modules (e.g. `module unload IPython`) or prefix commands with `env -u PYTHONPATH pixi run ...`. I don't think this will be an issue on Hyperion but on UQ's Bunya HPC it has caused me a lot of pain.
