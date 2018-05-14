#include "compute_ii.h"
#include <iostream>

using namespace std;

inline void mask_incr(basetype& x, basetype Amask, basetype endptr)
{
	basetype stopmask = endptr | (Amask & (~x)); // stop bit mask

	basetype nxormask = ~0x0; // ALL ones
	while (1)
	{
		nxormask <<= 1;
		if ((nxormask & stopmask) != stopmask) break; // smallest stop bit covered
	}

	x ^= Amask & (~nxormask);
}

inline basetype findendptr(basetype mask)
{
	// find endptr = (biggest bit of mask)

	basetype endptr = 0x1;
	while (1)
	{
		mask >>= 1;
		if (mask == 0) break;
		endptr <<= 1;
	}

	return endptr;
}

double compute_ii(counttype * FRx, counttype * FRxy, counttype Mx, counttype Mxy, basetype &MIB, int Nx, int Nxy)
{
	double logMx = log((double)Mx);
	double logMxy = log((double)Mxy);

	// compute H(x)
	double Hx = 0;
	{
		basetype x = 0;  // for(basetype x=0; x<=maxval(Nx); x++) // "for" not used to correctly serve case Nx=sizeof(basetype)
		while (1) {
			if (FRx[x] != 0) Hx -= (double)FRx[x] * log((double)FRx[x]); // accumulate sum in entropy
			if (x == maxval(Nx)) break;
			x++;
		}
	}
	Hx = (Hx / Mx + logMx) / log(2.0); // finalize calculation of entropy


	// compute H(xy)
	double Hxy = 0;
	{
		basetype xy = 0;  // for(basetype xy=0; xy<=maxval(Nxy); xy++) // "for" not used to correctly serve case Nxy=sizeof(basetype)
		while (1) {
			if (FRxy[xy] != 0) Hxy -= (double)FRxy[xy] * log((double)FRxy[xy]); // accumulate sum in entropy
			if (xy == maxval(Nxy)) break;
			xy++;
		}
	}
	Hxy = (Hxy / Mxy + logMxy) / log(2.0); // finalize calculation of entropy

	// big cycle over different partitions Amask
	// minimize {Ieff/min(HxA,HxB)} w.r.t. Amask

	double mintarget = DBL_MAX; // target to minimize
	basetype argminAmask = 0; // argmin
	double Iintegr = 0.0; // integrated information = Ieff(argminAmask)

	for (basetype Amask = 1; Amask <= (0x1 << (Nx - 1)); Amask++) // from 00..01 to 10...00 (Nx bits) // !!! enough is 00..01 to 01...11
	{
		//	basetype Amask=0x33;//0x0F;//0x33;//0x49;

		basetype Bmask = Amask ^ maxval(Nx);

		basetype Aendptr = findendptr(Amask);
		basetype Bendptr = findendptr(Bmask);

		basetype XYAmask = (Amask << Nx) | Amask;
		basetype XYBmask = XYAmask ^ maxval(Nxy);

		basetype XYAendptr = findendptr(XYAmask);
		basetype XYBendptr = findendptr(XYBmask);

		// compute H(xA)
		double HxA = 0;
		{
			basetype x0 = 0x0;
			basetype x = x0; // cycle over bits in A
			do {
				counttype FRxA = 0; // summary frequency of xA over all xB

				basetype x1 = x; // cycle over bits in B
				do {
					FRxA += FRx[x];

					mask_incr(x, Bmask, Bendptr);
				} while (x != x1);

				if (FRxA != 0) HxA -= (double)FRxA * log((double)FRxA); // accumulate sum in entropy

				mask_incr(x, Amask, Aendptr);
			} while (x != x0);
		}
		HxA = (HxA / Mx + logMx) / log(2.0); // finalize calculation of entropy


		// compute H(xB)
		double HxB = 0;
		{
			basetype x0 = 0x0;
			basetype x = x0; // cycle over bits in B
			do {
				counttype FRxB = 0; // summary frequency of xB over all xA

				basetype x1 = x; // cycle over bits in A
				do
				{
					FRxB += FRx[x];

					mask_incr(x, Amask, Aendptr);
				} while (x != x1);

				if (FRxB != 0) HxB -= (double)FRxB * log((double)FRxB); // accumulate sum in entropy

				mask_incr(x, Bmask, Bendptr);
			} while (x != x0);
		}
		HxB = (HxB / Mx + logMx) / log(2.0); // finalize calculation of entropy


		// compute H(xyA)
		double HxyA = 0;
		{
			basetype xy0 = 0x0;
			basetype xy = xy0; // cycle over bits in A
			do {
				counttype FRxyA = 0; // summary frequency of xA over all xB

				basetype xy1 = xy; // cycle over bits in B
				do {
					FRxyA += FRxy[xy];

					mask_incr(xy, XYBmask, XYBendptr);
				} while (xy != xy1);

				if (FRxyA != 0) HxyA -= (double)FRxyA * log((double)FRxyA); // accumulate sum in entropy

				mask_incr(xy, XYAmask, XYAendptr);
			} while (xy != xy0);
		}
		HxyA = (HxyA / Mxy + logMxy) / log(2.0); // finalize calculation of entropy


		// compute H(xyB)
		double HxyB = 0;
		{
			basetype xy0 = 0x0;
			basetype xy = xy0; // cycle over bits in B
			do {
				counttype FRxyB = 0; // summary frequency of xB over all xA

				basetype xy1 = xy; // cycle over bits in A
				do
				{
					FRxyB += FRxy[xy];

					mask_incr(xy, XYAmask, XYAendptr);
				} while (xy != xy1);

				if (FRxyB != 0) HxyB -= (double)FRxyB * log((double)FRxyB); // accumulate sum in entropy

				mask_incr(xy, XYBmask, XYBendptr);
			} while (xy != xy0);
		}
		HxyB = (HxyB / Mxy + logMxy) / log(2.0); // finalize calculation of entropy


		// Effective information
		double Ieff = (2 * Hx - Hxy) - (2 * HxA - HxyA) - (2 * HxB - HxyB);

		// minimize {Ieff/min(HxA,HxB)} w.r.t. Amask
		double target = Ieff / ((HxA < HxB) ? HxA : HxB);
		if (target < mintarget)
		{
			mintarget = target;
			argminAmask = Amask;
			Iintegr = Ieff;
		}

	} // end cycle in Amask

	MIB = argminAmask;
	return Iintegr;
}
