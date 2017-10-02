# VASPUP

This is an old collection of scripts from 2014 to help set up VASP calculations.
The functionality has mostly been superceded by other packages such as
[materials-toolbox](https://github.com/utf/materials-toolbox) and
[kgrid](https://github.com/WMD-group/kgrid). These scripts are only kept here for posterity.

## Usage

### POTCAR generation

The `generate-potcar` script can be used to generate a VASP 
[POTCAR](https://cms.mpi.univie.ac.at/vasp/vasp/POTCAR_file.html) file, based on an input
POSCAR. If the current directory contains a POSCAR file, simply run:
```
generate-potcar
```
and the script will prompt you about which potentials you would like to use. Alternatively,
a POSCAR file can be specified as follows:
```
generate-potcar MgO/POSCAR
```
In order to enable this functionality, the `VASP_POTENTIALS` environment variable must be set 
(see [Installation](#Installation) for more details).

### Convergence Testing

The main functionality of this package is for quickly setting up a series of folders for 
convergence testing. To achieve this, create a folder called `input` containing INCAR, KPOINTS
POSCAR, and POTCAR files, in addition to a CONFIG file. An example CONFIG file is provided in
the [config directory](https://github.com/utf/vaspup/blob/master/config/CONVERGE) (NOTE: It must be
renamed from CONVERGE to CONFIG). The directory structure should match the below:

```bash
./<run script from here>
./input
    /INCAR
    /KPOINTS
    /POSCAR
    /POTCAR
    /CONFIG
```

Customise the CONFIG file as you wish, the run the `generate-converge` excutable from the folder **below** the 
`input` directory. A series of folders will be created, with the settings modified to match the folder names.

Once the calculations have finished running, the `data-converge` script can be used to extract the
total energies from the VASP output. The `data-converge` script should be run separately within the folders named
`kpoint_converge` and `cutoff_converge`.

### SOD Scripts

There are several scripts to help with automating the [Site-Occupancy Disorder](https://sites.google.com/site/rgrauc/sod-program)
package but I can't remember what these do exactly. I probably wouldn't go near them if I were you.

## Installation

Installation is simple, just update your path to include the location of the bin folder. E.g. Edit your `~/.bashrc`
file to include:

```bash
export PATH="${HOME}/path/to/vaspup/bin:${PATH}"
```

To enable the POTCAR functionality, you should also set the VASP_POTENTIALS environment variable to
point to your potentials directory. E.g. Edit your `~/.bashrc` file to include:

```bash
export VASP_POTENTIALS="${HOME}/path/to/potentials"
```

## Disclaimer

This program is not affiliated with VASP. This program is made available under the MIT License; you are free to modify and use the code, but do so at your own risk.
