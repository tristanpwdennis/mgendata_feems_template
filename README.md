# funestus-feems

FEEMS (Fast Estimation of Effective Migration Surfaces) for *Anopheles funestus* using [MalariaGEN AF1](https://malariagen.github.io/vector-data/af1/af1.html) data.

## Notebooks

| Notebook | What it does |
|----------|-------------|
| `prepare_feems_inputs.ipynb` | Query AF1 for samples by country, create outer boundary polygon, visualise the study region + FEEMS grid, export SNPs to PLINK |
| `run_feems.ipynb` | Load PLINK genotypes, align coordinates, run cross-validation to select λ, fit and visualise the effective migration surface |

Run them in order. Each has a **`USER CONFIG`** block at the top — that is the only section you need to edit.

---

## Requirements

- [pixi](https://pixi.sh) — cross-platform conda/pip package manager  
  Install it with:
  ```bash
  curl -fsSL https://pixi.sh/install.sh | bash
  ```
- MalariaGEN AF1 data access — if you haven't already, you will be prompted to authenticate with Google when you first run `malariagen_data.Af1()` in a notebook

---

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/tristanpwdennis/funestus_feems.git
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

This registers a kernel called **"FEEMS (funestus)"** that appears in the JupyterLab kernel picker.

### 4. Launch JupyterLab

```bash
pixi run lab
```

Or open the notebooks in an existing JupyterLab instance and select the **"FEEMS (funestus)"** kernel.

---

## Running the analysis

### Step 1 — `prepare_feems_inputs.ipynb`

Edit the `USER CONFIG` block at the top:

Some example params - change these according to your study region or sample sets anlaysed.

```python
STUDY_REGION = 'kenya'                                      # used in output filenames
BBOX = dict(xmin=33.5, xmax=42.0, ymin=-5.0, ymax=5.0)    # study bounding box
SAMPLE_QUERY = 'taxon == "funestus" & country == "Kenya"'   # AF1 pandas query
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

All files are written to `feems_outputs/`:

```
feems_outputs/
├── feems_inputs_kenya.png          ← study region visualisation (check this first)
├── feems_kenya_surface.pdf         ← effective migration surface
├── feems_kenya_node_positions.csv  ← node lon/lat + sample counts (for R plotting)
├── feems_kenya_edge_weights.csv    ← edge weights (for R plotting)
├── sample_coords_kenya.csv         ← sample coordinates
├── shapefiles/
│   └── outer_kenya.csv             ← outer boundary polygon
└── plink/
    └── 3RL-*.bed/.bim/.fam         ← PLINK genotype files
```

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

> **HPC / module systems**: if you are on an HPC that loads Python via `module load`, the loaded Python's `site-packages` can bleed into the pixi env via `PYTHONPATH`, causing import errors from mismatched package versions. Before running `pixi run`, unload conflicting modules (e.g. `module unload IPython`) or prefix commands with `env -u PYTHONPATH pixi run ...`.
