# RKSymMagBuoyantFoam

This code is an extension of RKSymFoam to handle magnetohydrodynamic (MHD) flows at low
magnetic Reyolds numbers and buoyancy. It was developed by Daniel Santos (daniel.santos@unibw.de) as
a direct extension of the RKSymFoam by Jannes Hopman (https://github.com/janneshopman/RKSymFoam).
The basic collocated symmetry-preserving operators can be found in F.X Trias et. al. "Symmetry-preserving 
discretization of Navier–Stokes equations on collocated unstructured grids", and the unconditional stability
is guaranteed by using a volume-weighted interpolator on momentum quantities (see D. Santos et. al. "On a symmetry-preserving 
unconditionally stable projection method on collocated unstructured grids for incompressible flows").

## Note on RKSymFoam
This code contains slightly adjusted versions of the solvers used in the
paper "A symmetry-preserving second-order time-accurate PISO-based
method." by E.M.J. Komen, J.A. Hopman, E.M.A. Frederix, F.X. Trias and
R.W.C.P.  Verstappen. One notable adjustment is made in the pressure
gradient interpolation to follow the paper "On a symmetry-preserving 
unconditionally stable projection method on collocated unstructured grids 
for incompressible flows" by D. Santos, J.A. Hopman, C.D. Pérez-Segarra, 
F.X. Trias. The pseudo-symplectic Runge-Kutta integrators included in this
work are extracted from the paper "Explicit Runge-Kutta schemes for 
incompressible flow with improved energy-conservation properties." by 
F. Capuano, G. Coppola, L. Rández, and L. de Luca. For a description of 
the method, please refer to these papers. 

## Authors

(RKSymFoam) The main structure of the solver, including the Runge-Kutta schemes was
developped by Edo Frederix, of the Nuclear Research and Consultancy Group
(NRG), Westerduinweg 3, 1755 LE Petten, The Netherlands. The
symmetry-preserving method was applied to this structure by Jannes Hopman,
of the Heat and Mass Transfer Technological Center, Technical University
of Catalonia, C/Colom 11, 08222 Terrassa, Spain. The pseudo-symplectic
schemes were added by Josep Plana-Riu, of the Heat and Mass Transfer
Technological Center, Technical University of Catalonia. 

(RKSymMagBuoyantFoam) This code is a direct extension of the RKSymFoam by Daniel Santos, from the 
University of the Bundeswehr Munich.

## License

RKSymMagBuoyantFoam is published under the GNU GPL Version 3 license, which can be
found in the LICENSE file.

## Citation

If you use RKSymMagBuoyantFoam in your research, please cite:

- J. Hopman, RKSymFoam (original framework)
- D. Santos, RKSymMagBuoyantFoam (current extension)

## Prerequisites

* OpenFOAM v2412. While it may compile against other versions, this is not
tested and currently not supported.
* Python with numpy and matplotlib

## Usage

* Make sure that OpenFOAM v2412 is loaded into your environment 
* Compile all libraries and apps with

<pre>
./Allwmake
</pre>

## Test cases

* The test case included is a 2D buoyant cavity in the presence of a strong horizontal magnetic field.
A README is included in cases/buoyantMHDcavity to further explain the case and its validation.

* The available Runge-Kutta schemes can be found in
"libraries/RungeKuttaSchemes", the Butcher Tableaus are given in the
"<\*.C>" file and a reference is given in the "<*.H>" file

<p align="center">
  <img src="docs/cavity_figure.svg" width="500" alt="2D enclosed buoyant cavity">
</p>

<p align="center">
  <em>
    2D enclosed buoyant cavity with conductive walls filled with liquid metal
    under a strong horizontal magnetic field. Hartmann boundary layers are indicated.
  </em>
</p>

## Using RKSymMagBuoyantFoam in your own OpenFOAM cases

* The entries in "system/fvSchemes" are not read by RKSymMagBuoyantFoam, except
potentially for the turbulence model, all other schemes can be set to:

<pre>
    default         none;
</pre>

* In "system/fvSolution", the subdictionaries for "p" and "pFinal" are named
"pCorr" and "pCorrFinal" respectively.
* A subdictionary named "RungeKutta" has to be added to "system/fvSolution",
for example:

<pre>
RungeKutta
{
scheme          BackwardEuler;
nOuter          1;
nInner          2;
pnPredCoef      1;
pRefCell        0;
pRefValue       0;
}
</pre>

* All available schemes are based on the Butcher Tableau and can be found
in the "libraries/RungeKuttaSchemes" directory
* Cases are run exactly the same way as by any other OpenFOAM solver
* A transport model has to be chosen in "constant/tansportProperties",
similar to the usage of pimpleFoam.
* A turbulence model has to be chosen in "constant/turbulenceProperties"
file, similar to the usage of pimpleFoam.
* If you want to run a DNS, set the transport model to Newtonian (1) and
the simulation type to laminar (2), as demonstrated below.
* 1\. In "constant/transportProperties" add the line:

<pre>
transportModel  Newtonian;
</pre>

* 2\. Create the file "constant/turbulenceProperties":
<pre>
FoamFile
{
    version     2.0;
    format      ascii;
    class       dictionary;
    location    "constant";
    object      turbulenceProperties;
}

simulationType laminar;
</pre>

## Contact & support

For bug reports or support, feel free to contact Daniel Santos at
daniel.santos@unibw.de. 

