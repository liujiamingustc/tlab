#include "types.h"
#include "dns_const.h"

SUBROUTINE OPR_PARTIAL1(imode_fdm, nlines, g, u,result, bcs_min,bcs_max, wrk2d)

  USE DNS_TYPES, ONLY : grid_structure
  
  IMPLICIT NONE

  TINTEGER,                        INTENT(IN)    :: imode_fdm
  TINTEGER,                        INTENT(IN)    :: nlines  ! # of lines to be solved
  TINTEGER,                        INTENT(IN)    :: bcs_min ! BC derivative: 0 biased, non-zero
  TINTEGER,                        INTENT(IN)    :: bcs_max !                1 forced to zero
  TYPE(grid_structure),            INTENT(IN)    :: g
  TREAL, DIMENSION(nlines*g%size), INTENT(IN)    :: u
  TREAL, DIMENSION(nlines*g%size), INTENT(OUT)   :: result
  TREAL, DIMENSION(nlines),        INTENT(INOUT) :: wrk2d

! -------------------------------------------------------------------
  TINTEGER ip

! ###################################################################
  IF ( g%periodic ) THEN
     SELECT CASE( imode_fdm )
        
     CASE( FDM_COM4_JACOBIAN )
        CALL FDM_C1N4P_RHS(g%size,nlines, u, result)
        
     CASE( FDM_COM6_JACOBIAN, FDM_COM6_DIRECT ) ! Direct = Jacobian because uniform grid
        CALL FDM_C1N6P_RHS(g%size,nlines, u, result)
        
     CASE( FDM_COM8_JACOBIAN )
        CALL FDM_C1N8P_RHS(g%size,nlines, u, result)
        
     END SELECT
     
     ! ip  = inb_grid_1 - 1
     ! CALL TRIDPSS(g%size,nlines, dx(1,ip+1),dx(1,ip+2),dx(1,ip+3),dx(1,ip+4),dx(1,ip+5), result,wrk2d)
     CALL TRIDPSS(g%size,nlines, g%lu1(1,1),g%lu1(1,2),g%lu1(1,3),g%lu1(1,4),g%lu1(1,5), result,wrk2d)

! -------------------------------------------------------------------
  ELSE
     SELECT CASE( imode_fdm )
        
     CASE( FDM_COM4_JACOBIAN )
        CALL FDM_C1N4_RHS(g%size,nlines, bcs_min,bcs_max, u, result)

     CASE( FDM_COM6_JACOBIAN )
        CALL FDM_C1N6_RHS(g%size,nlines, bcs_min,bcs_max, u, result)

     CASE( FDM_COM8_JACOBIAN )
        CALL FDM_C1N8_RHS(g%size,nlines, bcs_min,bcs_max, u, result)

     CASE( FDM_COM6_DIRECT   ) ! Not yet implemented
        CALL FDM_C1N6_RHS(g%size,nlines, bcs_min,bcs_max, u, result)

     END SELECT
     
     ! ip = inb_grid_1 + (bcs_min + bcs_max*2)*3 - 1
     ! CALL TRIDSS(g%size,nlines, dx(1,ip+1),dx(1,ip+2),dx(1,ip+3), result)
     ip = (bcs_min + bcs_max*2)*3 
     CALL TRIDSS(g%size,nlines, g%lu1(1,ip+1),g%lu1(1,ip+2),g%lu1(1,ip+3), result)

  ENDIF
  
  RETURN
END SUBROUTINE OPR_PARTIAL1

! ###################################################################
! ###################################################################
SUBROUTINE OPR_PARTIAL2(imode_fdm, nlines, g, u,result, bcs_min,bcs_max, wrk2d,wrk3d)

  USE DNS_TYPES, ONLY : grid_structure
  
  IMPLICIT NONE

  TINTEGER,                        INTENT(IN)    :: imode_fdm
  TINTEGER,                        INTENT(IN)    :: nlines     ! # of lines to be solved
  TINTEGER,                        INTENT(IN)    :: bcs_min(2) ! BC derivative: 0 biased, non-zero
  TINTEGER,                        INTENT(IN)    :: bcs_max(2) !                1 forced to zero
  TYPE(grid_structure),            INTENT(IN)    :: g
  TREAL, DIMENSION(nlines*g%size), INTENT(IN)    :: u
  TREAL, DIMENSION(nlines*g%size), INTENT(OUT)   :: result
  TREAL, DIMENSION(nlines),        INTENT(INOUT) :: wrk2d
  TREAL, DIMENSION(nlines*g%size), INTENT(INOUT) :: wrk3d ! First derivative, in case needed

! -------------------------------------------------------------------
  TINTEGER ip

! ###################################################################
! Check whether to calculate 1. order derivative
  IF ( .NOT. g%uniform ) THEN
     IF ( imode_fdm .eq. FDM_COM4_JACOBIAN .OR. &
          imode_fdm .eq. FDM_COM6_JACOBIAN .OR. &
          imode_fdm .eq. FDM_COM8_JACOBIAN      ) THEN
        CALL OPR_PARTIAL1(imode_fdm, nlines, g, u,wrk3d, bcs_min(1),bcs_max(1), wrk2d)
     ENDIF
  ENDIF
  
! ###################################################################
  IF ( g%periodic ) THEN
     SELECT CASE( imode_fdm )
        
     CASE( FDM_COM4_JACOBIAN )
        CALL FDM_C2N4P_RHS(g%size,nlines, u, result)
        
     CASE( FDM_COM6_JACOBIAN, FDM_COM6_DIRECT ) ! Direct = Jacobian because uniform grid
        CALL FDM_C2N6P_RHS(g%size,nlines, u, result)
        
     CASE( FDM_COM8_JACOBIAN )                  ! Not yet implemented
        CALL FDM_C2N6P_RHS(g%size,nlines, u, result)
        
     END SELECT
     
     CALL TRIDPSS(g%size,nlines, g%lu2(1,1),g%lu2(1,2),g%lu2(1,3),g%lu2(1,4),g%lu2(1,5), result,wrk2d)

! -------------------------------------------------------------------
  ELSE
     SELECT CASE( imode_fdm )
        
     CASE( FDM_COM4_JACOBIAN )
        CALL FDM_C2N4_RHS(g%uniform, g%size,nlines, bcs_min(2),bcs_max(2), g%jac, u, wrk3d, result)

     CASE( FDM_COM6_JACOBIAN )
        CALL FDM_C2N6_RHS(g%uniform, g%size,nlines, bcs_min(2),bcs_max(2), g%jac, u, wrk3d, result)

     CASE( FDM_COM8_JACOBIAN ) ! Not yet implemented; defaulting to 6. order
        CALL FDM_C2N6_RHS(g%uniform, g%size,nlines, bcs_min(2),bcs_max(2), g%jac, u, wrk3d, result)

     CASE( FDM_COM6_DIRECT   )
        CALL FDM_C2N6N_RHS(g%size,nlines, g%lu2(1,4), u, result)

     END SELECT
     
     ip = (bcs_min(2) + bcs_max(2)*2)*3 
     CALL TRIDSS(g%size,nlines, g%lu2(1,ip+1),g%lu2(1,ip+2),g%lu2(1,ip+3), result)

  ENDIF
  
  RETURN
END SUBROUTINE OPR_PARTIAL2

! ###################################################################
! ###################################################################
! Add here OPR_DDX(order,...), OPR_DDY(order,...), and OPR_DDZ(order,...)