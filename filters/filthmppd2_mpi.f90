SUBROUTINE FILTHMPPD2_MPI(kmax, ijmax, nx,  z1, zf1, wrk)

! #########################################################
! # FILTER LIBRARY
! #
! # Top-hat filter for nx = 2
! # Midpoint(trapezoidal) rule 
! # Periodic boundary conditions
! # PEs explicit version to avoid transpose by MPI
! #
! #########################################################

  IMPLICIT NONE

#include "types.h"

  TINTEGER kmax, ijmax
  TINTEGER nx
  TREAL z1(ijmax,*)
  TREAL zf1(ijmax,*)
  TREAL wrk(ijmax,*)
  
  TINTEGER k,ij
  
! filling array
  DO k = 1,kmax
     DO ij = 1,ijmax
        wrk(ij,k+nx/2) = z1(ij,k)
     ENDDO
  ENDDO
  
  DO k = 1,kmax
     DO ij = 1,ijmax
        zf1(ij,k) = C_025_R*(wrk(ij,k) + wrk(ij,k+2)) + C_05_R*wrk(ij,k+1)
     ENDDO
  ENDDO
  
  RETURN
END SUBROUTINE FILTHMPPD2_MPI
