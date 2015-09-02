      subroutine fptrnp(m,mm,idim,n,nr,sp,p,b,z,a,q,right)
!  subroutine fptrnp reduces the (m+n-7) x (n-4) matrix a to upper
!  triangular form and applies the same givens transformations to
!  the (m) x (mm) x (idim) matrix z to obtain the (n-4) x (mm) x
!  (idim) matrix q
!  ..
!  ..scalar arguments..
      real p
      integer m,mm,idim,n
!  ..array arguments..
      real sp(m,4),b(n,5),z(m*mm*idim),a(n,5),q((n-4)*mm*idim),&
       right(mm*idim)
      integer nr(m)
!  ..local scalars..
      real cos,pinv,piv,sin,one
      integer i,iband,irot,it,ii,i2,i3,j,jj,l,mid,nmd,m2,m3,&
       nrold,n4,number,n1
!  ..local arrays..
      real h(7)
!  ..subroutine references..
!fpgivs,fprota
!  ..
      one = 1
      if(p.gt.0.) pinv = one/p
      n4 = n-4
      mid = mm*idim
      m2 = m*mm
      m3 = n4*mm
!  reduce the matrix (a) to upper triangular form (r) using givens
!  rotations. apply the same transformations to the rows of matrix z
!  to obtain the mm x (n-4) matrix g.
!  store matrix (r) into (a) and g into q.
!  initialization.
      nmd = n4*mid
      do 50 i=1,nmd
        q(i) = 0.
  50  continue
      do 100 i=1,n4
        do 100 j=1,5
          a(i,j) = 0.
 100  continue
      nrold = 0
!  iband denotes the bandwidth of the matrices (a) and (r).
      iband = 4
      do 750 it=1,m
        number = nr(it)
 150    if(nrold.eq.number) go to 300
        if(p.le.0.) go to 700
        iband = 5
!  fetch a new row of matrix (b).
        n1 = nrold+1
        do 200 j=1,5
          h(j) = b(n1,j)*pinv
 200    continue
!  find the appropriate column of q.
        do 250 j=1,mid
          right(j) = 0.
 250    continue
        irot = nrold
        go to 450
!  fetch a new row of matrix (sp).
 300    h(iband) = 0.
        do 350 j=1,4
          h(j) = sp(it,j)
 350    continue
!  find the appropriate column of q.
        j = 0
        do 400 ii=1,idim
          l = (ii-1)*m2+(it-1)*mm
          do 400 jj=1,mm
            j = j+1
            l = l+1
            right(j) = z(l)
 400    continue
        irot = number
!  rotate the new row of matrix (a) into triangle.
 450    do 600 i=1,iband
          irot = irot+1
          piv = h(i)
          if(piv.eq.0.) go to 600
!  calculate the parameters of the givens transformation.
          call fpgivs(piv,a(irot,1),cos,sin)
!  apply that transformation to the rows of matrix q.
          j = 0
          do 500 ii=1,idim
            l = (ii-1)*m3+irot
            do 500 jj=1,mm
              j = j+1
              call fprota(cos,sin,right(j),q(l))
              l = l+n4
 500      continue
!  apply that transformation to the columns of (a).
          if(i.eq.iband) go to 650
          i2 = 1
          i3 = i+1
          do 550 j=i3,iband
            i2 = i2+1
            call fprota(cos,sin,h(j),a(irot,i2))
 550      continue
 600    continue
 650    if(nrold.eq.number) go to 750
 700    nrold = nrold+1
        go to 150
 750  continue
      return
      end
