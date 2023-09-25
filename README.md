# Magnetic_Null_Detector
The IDL routine can give a first hand idea about the location and number of three dimensional magnetic nulls for a magnetic field configuration. It is assumed that the magnetic field components are given in Cartesian coordinates.

The code given here is written to read magnetic field data from a .nc file. Note that a .sav file can also be used. In this program, the magnetic field components have the dimension as Bx = Bx[448,256,192], By = By[448,256,192], and Bz = Bz[448,256,192]. The nc file corresponds to a MHD simulation in time having 100 time steps. In the code given here, the 10th time step is taken for analysis.
