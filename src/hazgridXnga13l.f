c--- hazgridXnga13l.f for USGS PSHA runs, Last changed  05/13/ 2013. Long header version.
c 5/13/2013: Add anelastic attenuation in CB13, for R>80 km. Bozorgnia email May 2013.
c 5/10/2013: Further update hypocenter in CB13. USE W&C M(A) to estimate flt width
c
c 5/09/2013: Increase the R index to 310 to allow di=1 and Rmax of 300 km. Steering committee
c	recommendation is to step up Rmax to 300 km to capture afault influence in Arizona.
c	Put the hypocenter 1/2 way downdip in CB13 virtual faults. Was 3/4 down previously.
c
c 5/08/2013: Deep seismicity can be treated with a staircase distribution of depths
c            These depths and the longitudes where they change are input in the dtor line.
c 		There can be up to three deep seismicity levels.
c 4/16/2013: BSSA13 running for all 107 periods incl PGV (index 1). 
c 4/12/2013: CY2013 updated. Corrected a line about HW_taper3 in AS-2013 routine (their only update). 
c 4/11/2013: Update Idriss NGA-W GMPE coeffs to latest available (emailed 4/10)
c 4/10/2013: correct logic for fixed-strike source and agrid with header (iflt=20)
c	Increase number of maximum-magnitude zones to 15 (controlled by nzonex parameter)
c 4/09/2013: modify CB13 and GK13. Modify Basin and Range Q for GK13 to 205
c 4/04/2013: asum first dim up dimension to 40 to accomodate big range of magnitudes.
c 4/02/2013: added a definition for di2 = di/2 that was needed (PC Liu Discovery). also small
c		repair of a line controlling logic for variable Vs30 input model.
c 4/01/2013: Add GK13. Calif Q is 156.6 here (new). Same index as GK12.
c 3/20/2013: clean up declarations. dont use dimension without specifying type. This
c step is a disambiguation where subroutines specify "implicit none". Some array items
c were replaced with scalar items in calls to some subroutines. Work with Morgan 3/20
c 3/19/2013: Revise BSSA to the March version. Has large GMPE Std. dev. Add sdi option to BSSA13.
c 3/152013: Include AS08 index 24.
c 3/06/2013: incl Mar 2013 version of CY NGA(2) GMPE- this one removed and the april one replaced.
c 3/05/2013: include Feb 2013 version of AS NGA(2) GMPE. 
c 2/25/2013: include Feb 2013 version of CB NGA(2) GMPE. work in progress.
c 2/22/2013: add option to compute inelastic spectral displacement (Units: cm). Fcn of dy.
c To invoke option, specify dy as arg2 and the value of dy as arg3 (for example 10.0 cm). 
c 1/18/2013: corrections to sigma in Idriss GMPE. Loop corr in BSSA preparation.
c
c 1/09/2013: allow user to specify aleatory sigma with arg2=fixsigma and arg3= value
c Example using fixed sigma option: hazgridXnga13l CAmapC_21.in fixsigma 0.5
c 1/09/2013: improve the asum() accumulation based on P. Powers observation
c about "banding" of event-rates at certain latitudes. New vers. has no banding.
c  The effect of this change is visible when comparing with OpenSHA but otherwise too subtle.
c 12/28/2012: add BSSA12 index 29
c 12/27/2012: add Idriss2013 index 38. This one has linear siteamp function.
c 12/26/2012: add CY2012 index 33 (removed Mar 2013) Use CY2013.
c 12/24/2012: add AS2012 model index 34. As in CB12, you can vary dip of virtual flts
c by using icode values in the range 0 to 9, or 0 to -9 to put all sites on footwall side
c DEC 20 2012: iconv becomes icode to add options associated with WUS gmpes as well as CEUS gmpes
c add Campbell-Bozorgnia 2012 GMPE for wus. Icode for CB12 set up to vary dip of random sources:
c      icode=0 90 =>d; 1=>80 d, 2=>70 d, and so on. Index 32.
c Add GK12 model with basin effect. index 39. Q_s is 435 everywhere in the initial model setup.
c this version has the long header records (896 instead of 308 byte)
c 11/16/2012: add NAAsub corresponding to the BCHYDRO GMPE of 2010. Index=31. For intraplate sources.
c       we don't intend to use NAAsub for subduction sources in this code (see hazSUBXnga.test)
c GetGeom  : use BA nonlinear siteamp, from AF hazgridXGT.f. 
c GetABsub: do not modify. Use the original 2003 formulation of siteamp. Some corrections to getABsub
c were discovered by Pengsheng and fixed in this code Jan 9, 2013. SHarmsen.
c
c more comments in previous versions.
c Some history of code mods:
c 7/22/2010: hazgridXnga13l with double precision for the summation step prob(,,,)=prob()+blah blah
c Idea is that the small distant source rate may be omitted during summation due to word-size.
c Testing shows d.p. accumulation is a very minor improvement. But does not impact run time so we
c implement it here.
c 10/31/2012: Add AB06', A08', Pez11 CEUS GMPEs initially set up for A-rock or BC-rock only. The
c   A->BC conversion uses Gail Atkinson's factors very different from Frankel's factors.
c
c 7/19/2010: Add Geomatrix subduction (previously just inslab). iatten=14 for subd.
c 7/13/2010: Add Zhao interface and intraplate GMPEs. These have slightly different
c      	sigma_t and considerably different medians.
c 7/14/2010: add ABsub subduction (previously only inslab). gmpe 16 for Cascadia, 
c      				17 for global
c 2/03/2010: Add option for fixed strike with strike direction a fcn of site location.
c      	To invoke this new option, make iflt -2
c   The field of strikes is in a binary file that replaces the strike direction & is written
c      	on that line of the input file. Use iosubs to read and write this file.
c      	The trial WUS strike directions were written by azimuth_to_pole.f. An Euler pole
c      	was put at 45N, 116W for trial runs. Some places (PACNW, So CAL) were modified
c 10/13/2009: correct TP05 c1(0.3 s) for BC rock.
c Oct 9 2009: put M(m) into an array xmw() where M is the moment mag for index m.
c Conversion should be done just once, and then subsequently should access xmw(m) rather
c than recomputing the CEUS mb->M .
c Jan 7 2009: add PGV coeffs to CY-NGA relation. PGV available in Mar 2008 Eq spectra.
c Jan 9 2009: zero out the avghwcy array when entering routine. necessary on PC runs
c May 8 2009: correct some D-soil coeffs, c6, in getABsub (10hz, 3.33, 2 hz)
c May 13 2009: add E-soil coeffs, c7, to getABsub. Include B rock, prev. BC only
c June 17 2009: correct tau_nl in getCY2007H
c       Previous version had tau a decreasing fcn of distance. This version is more accurate.
c June 18 2009: use current xmag to define the magnitude index, m_ind, in rjbmean array
c   This mod assumes that xmag, or M, at the time it is looked at is Moment Magnitude, and
c   that the calculation of rjbmean was for a M(SRL) or M(A) relation.
c   
c Dec 18 2008: vulnerability in output file names for the .m and .p files is finally repaired.
c Nov 20 2008: add Zhao et al. atten. for inslab and interface source. Need variety of models at LP Sa, but
c      	AB03 is only good to 3 s. Zhao's inslab goes to 5 s Sa.
c Nov 19 2008: increase set of periods available with Geomatrix inslab attn.
c mod Oct 22 2008. M (saturation) limit at 8.0 (AB03, BSSA v93 #4, p 1709)
c August 2008: Mmax may be treated as a distribution for the cases iflt=3 and iflt=4.
c these are CEUS or CENA flags indicating mblg is the native magnitude and
c if iflt=3 mblg will be convertd to moment mag. using an Arch Johnston conversion;
c if iflt=4 mblg will be convertd to moment mag. using Atknson-Boore 95 conversion formula.
c  wtmj_cra, wtmj_ext 
c  wtmab_cra, wtmab_ext complementary distribution vectors.
c Vector sizes increased to allow up to mb 8.05 Feb 1 2012. Largest mb corresponds
c to a moment mag approaching 9.
c These vector values are defined in data statements below (or f95 equiv. of data statements).
c These vectors can be modified to change the epistemic range of Mmax in the CEUS (CENA).
c The values are relative to the local magnitude (mb) and its conversion to moment
c magnitude. NSHMP and this code use two conversions, Johnston and AB95. 
c These are designated "j" and "ab" in above vectors. The first distribution value corresponds
c to mb 5.05. The second corresponds to mb 5.15, and nth corresponds to 5.05+ (n-1)* 0.1. 0.1 is the
c expected dm in the below code. If mmin or dm changes, you would have to change the distributions above.
c The upper tail endpoint that has been tested corresponds to Mmax 7.7 (moment magnitude). 
c  "cra" defines mmax distribution in USGS Craton. "ext" defines mmax distribution in USGS Extended Margin.
c   logical arrays craton and margin are read in. The arrays are defined over the CEUS standard map grid.
c   If i is the geographic location index, craton(i)=.true. if i is in the craton. margin(i)=.true. if i
c   is in the extended margin. Both are false if i is in an undefined location (offshore). 
c Undefined results
c in a default offshore Mmax which is the magmax read in in the input file. This is a scalar Mmax (no distribution).
c This option also requires that you read in an mmax array which defines the absolute upper limit of Mmax at
c each grid point (maxmat = 1 must be selected). If you set maxmat to 0, the input magmax will be applied at
c all geographic locations (no craton / margin distinction).
c maxmat has additional option in 2013: maxmat>1 means read in a model of Mmax regions. In each Mmax
c region, a distribution of Mmax values is read in. The hazard is calculated based on the CCD of Mmax
c in each of these regions (up to 10 such zones are allowed)
c
c sept 30 2008: define dy inside getBooreNGA (prior omitted)
c October 26 2007: add Oct version of CY NGA relation. Subroutine CY2007H.
c modified sept 12, 2007: does not call erf() within intraplate subroutines.
c  This seems to be required for Windows PC gfortran. Other subroutines will
c also have to be modified similarly (such as CEUS models).
c Nov 26, 2007:  fix a bug in getAB06 for the non-default stress factor case such as 200 bar
c June 4 2008: deaggregate at a site
c May 21 2008: further consolidate CEUS background runs, from 16 to 2. The
c remaining 2 are for Johnston mb to M and AB mb to M, respectively.
c The mmax branches are included as weights. Two binary logical files craton and margin are
c read in iff abs(iflt)= 3 or 4.
c --- iflt <= 0. Uses only point src.
c --- iflt=-3 uses point src but also uses Johnston mb to Mw New sept 2008
c --- iflt=-4 uses point src but also uses AB mb to Mw
c April 30 2008: Read in precomputed array of mean distances to randomly oriented
c faults. This array is called rjbmean and is indexed by mag and distance. Reading
c in this array from file 'meanrjb.bin' can save a few seconds of CPU time
c per CEUS background-hazard run (16 of them). Indexes ilat and ilon no longer needed.
c Feb 1 2013: the mean distance from src S needed to be increased to allow
c Mmax of 8.1 for the CEUS SSC logic tree branches. The new mean distance
c array is called rjbmean.bin.Aeast and has 26 mag bins instead of 16.
c
c aug 19, 2008: clamp is consistent for short period defined from 0.5 > T > 0.02 s.
c Apr 10 2008: clamp in getFEA is now used. Was commented out prior to today. (T. Cao noticed this)
c feb 5 2008: add 3s coeffs. to absub and Geomatrix atten models.
c March 15 2008: Hardrock for AB06 always called if Vs30>=2000 m/s and can be called if Vs30>1500 m/s.
c March 15 2008: Hardrock coeffs used for Frankel, Toro, TP05, Silva if Vs30>=1500 regardless of whether negative
c    iatten() index is used. This is meant to assist users. However, there is a debate about what constitutes 
c      A-class rock in the CEUS versus A in the WUS. May need an AB class in nhbd of 1500 m/s.
c March 20 2008: BooreNGA308 subroutine replaces BooreNGA407: Only effect is to
c nonlinear calculations and pga_nl. Does not affect 760 m/s or BC rock calcs.
c This update should be used for the SoilD and SoilC PSHA calcs.
c April 8 2008: Toro 2-hz and 3.33-hz c1 coeffs checked and changed.
c july 6 2008: add 2.5 and 25 hz to getSilva and getTP05. For the latter,
c use cubic spline interp from Numerical Recipes. This seems to do a good job
c putting the median between the nearest available period medians over Rcd range<1000 km
c
c Dec 3, 2007: Toro CEUS finite fault corr. uses Mw to make the correction.
c  Sept 20, 2007: new mmax rule: if the mmax matrix indicator is -1, use the
c   minimum of the scalar Mmax and the matrix Mmax for that source. The purpose
c of this mod is to perform a rate calculation for M<6.5 earthquakes which could
c have M<6.0 in a few places, such as the Creeping Section of the SAF. SH 9/20/2007
c 
c Greater Ztor allowed  aug 15 2007 to accomodate very deep Benioff zones
c revised Apr 10, 2007, ABsub. for C and D site classes. SHarmsen.
c rev feb 13 Art Frankel, corrects AB06 for the BC boundary
c       revised june 11 2007 based on erratum in bssa for june 2007
c --- Revised Mar 27, 2007 SHarmsen, USGS. harmsen@usgs.gov 303 273 8567; 
c This code implements nga relations; Kanno, new 2006 CEUS models, and previously used
c attenuation models.
c --- Oct 2007 rev: update B&A NGA relation, which now has 23 spectral periods (see Eq Spectra Mar 2008)
c === Jan 25 2007 rev: 3-branch gnd, to increase epistemic uncert where needed.
c ---  Important, this 3-branch has been included in 4 NGA relations only as of jan 25 07
c ---      These are A&B (21), C&B (22), C&Y (23), and Idriss (26). Dont use A&S2005
c
c 3-branch gnd is an all-or-none proposition as of jan 31. If last period doesnt
c ask for it, none will get it. THis is a coding error. But not fixed.
c === Oct revision: uses array constructors which replace previous "data " statements that were
c         used to initialize arrays but cannot be used with some F95 compilers
c --- Dec revision: add effects of buried blind thrust and normal if present. Extra 
c --- branching is implied if wtnormal or wtrev > 0. If everything is StrikeSlip, these
c --- additional  steps are not done.
c --- Dec revision: use mean (rjb) instead of sample (rjb) i.e., replace spinning fault  with mean
c --- distance from random-orientation fault, uses Numerical Recipes el2 routine 
c ----  For details, see getmeanrjb subroutine. These mean distances are read
c ---- in from a precomputed file in hazgridXnga13l. Saves a few sec
c --- Future directions: finite reverse and normal slip faults need to be coded up.
c ---  Simplest model might be a circular surface with center at each source point.
c
c --- Compile with  f95 or gfortran. On Solaris, use -e for extended line length. link to iosubs.o
c Try this on sun  using Solaris 10 fortran 95:
c f95 hazgridXnga13l.f -o hazgridXnga13l -O iosubs_128.o -e -ftrap=%none
c	the -fast flag has been known to fail on hazgridXnga13l runs...
c Try this on PCs with gfortran:
c      gfortran hazgridXnga13l.f iosubs.o -ffixed-line-length-none -static -o hazgridXnga13l.exe -finit-local-zerro -ffpe-trap=
c
c the flag -finit-local-zerro initializes uninitialized variables (arrays) to 0 and 
c logicals to .false.  This flag was brought in to veersions of gfortran after 2007, and is not a standard.
c
c --- f95 man pages say to compile with -ftrap=%none if -fast flag is used. 
c ---- For listing use flag -Xlist
c --- Further notes:
c
c      	Feb 9 2007: can have up to 8 atten models per spectral period.
c      		this limit used to be 7. However, we need 8 for
c      		NM & Charleston Seismic Zones in the 2007 update. Steve H.
c
c --- Computation approach is that of Frankel in this version: compute
c the cumu. prob. exceedance over R and M for each atten and add the
c weight*pr to a multi-dimension matrix, which is here called pr (actually mean
c freq. of exceedance).
c These multi-dimensions correspond to distance, magnitude, ground-motions sampled,
c depth-to-top-of-rupture,
c and spectral period. Depth-to-top is a new prediction variable. Dtor requires a
c separate dimension because median motion can vary with uncertainty in Dtor.
c To some extent, atten models of 2002 had some sensitivity to dtor (not all however).
c This depth was previously fixed at 5 km for WUS gridded. 5 or 10 for CEUS gridded.
c Now, however, dtor can vary. 
c This version of the gridded hazard program
c also precomputes the complementary normal prob and stores in p(), a 1-dim array
c
c -- iatten=21 boore-atkinson nga updated to the Apr 2007 version. SH. Note:
c B&A have  7.5 and 10-s SA predictions but 10s had to be modified for normal faulting.
c -- iatten=22 campbell-bozorgnia nga updated to the 3-2008 vers,
c      	the CB update includes peak displacement, a novelty. Sigma for
c      	random horizontal component is the default now.
c === iatten=32 CB 2012 for vertical dipping faults. (testing dec 20 2012)
c -- iatten=23 chiou-youngs nga vers 3-2008. (earlier 2006 version is also available)
c -- iatten=24 abrahamson-silva partially set up mar 06 (this relation will probably change).
c -- iatten=25 idriss pga oct 2005.
c -- iatten=26 Kanno et al. BSSA 2006. This model has large aleatory sigma for
c ---   all spectral periods, about 50% larger than NGA relations above.
c Next,
c Older atten. relations. Some are for fixed site conditions and some for
c Vs-30 dependent site conditions. CEUS fixed site is HR or FR; WUS FR or soil.
c ---  added iatten= 1 Spudich ea, 2000. From BJF93. Has siteamp from BJF97.
c ---  added iatten= 2 toro ceus BC rock
c ---  added iatten= -2 toro ceus hard  rock
c ---  added iatten= 3 Sadigh et al ( rock-site coeffs.& eqn) nov 22 2005.rock
c ---  added iatten= -3 Sadigh et al (soils-site coeffs.&eqn) in prep aug06
c  iatten = 4 AB06 BC  Atkinson and B00re 2006 (added Nov 14 2006)
c  iatten = -4 AB06 hardrock. There is a siteamp that  is added to hardrock median;
c      		however, it is 0 (in logspace) for vs30=760.
c ---   iatten == 20 :: AB06 with 200bar stress, siteamp. HR coeffs used if vs30>1000
c ---  add iatten=  5 AB94 ceus (New, previously had same 6 index as fea. )
c ---  add iatten=  -5 AB94 HRceus (New, previously had same 6 index as fea.)
c ---  added iatten= 6  Frankel ea BC rock, ceus
c ---  add iatten=  -6 FEA HRceus (New, previously had same 6 index as fea.)
c
c ---  added iatten= 7 Somerville ceus. BCrock. Note: Somerville is used
c      	for the finite-fault portion of gridded hazard. Used with Charleston
c ---  added iatten= -7 Somerville ceus. hardrock.
c---   added iatten= 8 Abrahamson-Silva 1997. rock. july 25 2006
c ---  added iatten= 9 Campbell and Bozorgnia 2003. rock. july 25 2006
c ---  added iatten= -9 Campbell and Bozorgnia 2003. D soil. future 2006
c ---  added iatten= 10 Campbell CEUS BC or firmrock 2003. july 25 2006
c ---  added iatten= -10 Campbell CEUS A or hardrock 2003. aug 2006
c---   added iatten= 11 BJF 1997. All Vs30 allowed, like NGA relations. Mech dependent. july 26 2006.
c ---  added iatten= 12 AB intraslab seismicity Puget Sound region B or BC-rock condition. 
c ---      		repaired rpga calc feb 12 2007. Modify c3 dtor to min(100,dtor)
c ---  added iatten= -12 AB intraslab seismicity Puget Sound region C D E-soil condition
c ---  added iatten= 18 AB intraslab seismicity world data BC-rock condition
c ---  added iatten= -18 AB intraslab seismicity world data region C D E-soil condition
c ---  added iatten= 13 Geomatrix slab seismicity rock, 1997 srl. july 25 2006
c ---  added iatten= -13 Geomatrix slab seismicity soil, 1997 srl. july 25 2006
c --- added  iatten= 14 Geomatrix subduction. Added July 19 2010 SH. Uses BA siteamp
c      for soil Vs30 and rock Vs30 .ne. Vref (760 m/s)
c --- added  iatten= 15 Silva 2002 added jan 31 2007. hr or bc only
c === iatten = 19 Tavakoli and Pezeshk 2005 added nov 14 2006.
c ----      	TP05 has hardrock coef c1 used if vs30>900 m/s (no negative index though).
c - - -  iatten = 27 Zhao et al for deep inslab. Can use for LP. Nov 20 2008.
c - - -  iatten = 28 Zhao et al for deep interface. Can use for LP to 5 sc Tmax. 
c GMPE index 28 became active July 12 2010. Zhao interface (may be used for
c America Samoa Oceanic Sources NSHMP PSHA work. To be determined later).
c --- index 29 BSSA 2013 April.
c - - -  iatten = 41 Motazettian and Atkinson (changed from index 14 Jul 2010)
c - -  -      	Motazettian and Atkinson has siteamp from BJF97
c - - - iatten = 31 BCHydro for inslab. added Nov 2012. This one has nonln siteamp.
c ---- iatten = 32 CB13 march
c ---- iatten = 33 CY13 march
c ----- iatten= 34  AS13 march
c --- iatten=35 A08'
c --- iatten=36 AB06'
c --- iatten=37 Pez11
c --- iatten=38 Idriss Apr 2013 (this one has  been updated- STD. Deviation, however, has not).
c --- iatten=39      GK12 with continuous basin response.
c ---
c --- SOme New Features (compared to 2002 update versions):
c --- code works for a large grid of sites or a small set (<=30) of sites.
c --- Features of hazgridXv31.f have been included here so that only
c --- one code is necessary. 
c ---   Input file has a new first line : number of sites, or nrec.
c --- Make nrec 0 to get the grid features of hazgridXv3.
c --- Make nrec 1 to 30 to specify set of sites <lat(i),long(i),i=1,...,nrec>
c --- Output file names are specified in input file, one per period.
c
c --- New Feature:
c --- Source box is now independent of site box and is specified same way. 
c
c --- More new features...:
c---- now includes siteamp w/ some older attenuation relations i.e., variable VS30.
c --- How siteamp is handled is an open question as of July 2006. But using the
c --- simple BJF model for initial try. Many relations have nonlinear siteamp fcn
c
c -- Geotechnical input : Vs30 (which can be a geographic array), H=depth to Vs2500 m/s.
c --- To do: array of Vs30 will require a separ. Vs30 dim. on pr(...). Code is triggered
c --- to read Vs30 array if the initial input value of Vs30 is set to 0.0.
c --- Relatively low Vs30 produces nonlinear siteamp in all NGA relations (except idriss).
c --- Geotechnical information is communicated in common /geotec/
c
c ---  Depth_to_top: now is a distribution with 1 to 3 depths
c --- Enter wt as two distributions, for M<6.5 and for M>=6.5: 
c ntor, (dtor(k),wtor(k),wtor65(k),k=1,ntor) with 1 <= ntor <=3. wtor65 for M>=6.5
c    wtor is weight distribution form M<6.5, wtor65 is weight distribution for M>=6.5
c ---We might want to model a shallower average top-of-rupture for larger events. Example
c --- 3 2. .3 .6 6. .4 .3 9. .3 .1 
c ---  says "3 dtors, 2 km, 6 km, and 9 km, resp. For smaller source, roughly uniform
c --- distribution of depths. For M>=6.5, shift center of distribution to shallower depths."
c ---  Testing this distribution concept Mar 2006.  For most sites, 
c ---plausible variation of dtor seems to have little significance for Pex> o(10^-6)
c --- The distance metric  is  r_jb.
c --- Variable dtor is also of potential interest for intraslab seismic hazard.
c --- Dtor variability could be linked to geographic position, but not programmed.
c  Assumes that r_cd = sqrt(r_jb**2+dtor**2) in all instances. SH Mar 2006.
c
c -- Additional source sense-of-slip input: wtss, wtrev, and wtnormal. Please
c   dont mix reverse and normal but it is fine to mix ss+rev or ss+normal in any combination
c In 2002 style-of-slip variability was controlled in individual attenuation
c model inputs. Here it is a global variable, in common /mech/
c
c ---  Older atten. model subroutines have been brought up to NGA style for
c --- standard 7 periods and BC rock site conditions. A few have variable vs30
c --- modeling capability (BJF, Spudich2000, Motazetian). CEUS models have A-rock.
c Older notes (also see Frankel codes for more notes)
c--- with clipping for Toro and new Boore tables
c--- calculates mean annual rates of exceedances for gridded a-values
c--- can use b-value and Mmax matrix
c--- this version can use finite faults centered on grid cells for M>=6.5
c--- randomizes strike of faults
c--- this version can use multiple attenuation functions at different periods
c--- choice of attenuation relation: Joyner-Boore, Toro, Sadigh, Campbell, etc.
c--- From hazgridXnga written by Art Frankel
c
c--- to run: hazgridXnga13l inputfile > log.file
c--- try: hazgridXnga13l WUSmapC.in > WUSmapC.log
c --- SDI option: hazgridXnga13l input file dy 1.0 > log file
c ---- this SDI option has been built in to more recent WUS GMPEs and to Intraplate GMPEs
c ---- SDI has not been built into CEUS GMPEs or to older WUS GMPEs as of Mar 21 2013 SH.
c
c--- output files have hazard curve for each site concatenated
c--- one output file per period (unless extra epistemic uncert, which adds .p and .m files)
c --- Messages are written to have more useful diagnostic information. Look at log file if
c      	you are having problems.
c--- Ground motion levels should be in units of g, except for PGV. Code checks for >12 g
c --- and stops if this is found. For PGV there is a related check, for PGV max < 20 cm/s.
c--- period=0 indicates PGA. period = -1 indicates PGV
      parameter ( d2r=0.0174533,pi=3.14159265,fourpisq=39.4784175)
        parameter (nlmx=20,npmx=8,nsrcmx=200000,nzonex=15)   
      real*8 emax/3.0/,sqrt2/1.4142135623/
      real, dimension(2) :: mcut,dcut,tarray
      real, dimension(nzonex) :: mwmaxx	!mwmaxx=the absolutely largest mag in a zone. new 4/04/2013.
c You can raise p dim & make some minor code changes to improve accuracy (currently
c p() has about 4 decimal place accuracy which is likely to be good enough)
      common/prob/p(25005),plim,dp2     !table of complementary normal probab.
      common/mech/wtss,wtrev,wtnormal
c there are several expressions that are sensitive to fault dip. What to do about this for
c gridded sources?
      common/dipinf_90/dipang,cosDELTA,cdipsq,cyhwfac,cbhwfac
      common/dipinf_50/dipang2,cosDELTA2,cdip2sq,cyhwfac2,cbhwfac2
      common/geotec/vs30,dbasin
      common/depth_rup/ntor,dtor,wtor,wtor65
      common/gail3/freq
c rjbmean = mean rjb distance (km) from random oriented src
c Sizeof of rjbmean will work for Rmax of 1000 km. Mmin 6.05 Mmax 8.55 (feb 1 2013)
        real rjbmean(26,1001)
      common/ipindx/iperba(10),ipgeom(10)
      common / atten / pr, xlev, nlev, icode, wt, wtdist
      common/ia08/ia08
c add SDI-related common block sdi feb 22 2013
      common/sdi/sdi,dy_sdi,fac_sde
      real, dimension(8) :: fac_sde
      real pr(310,38,20,8,3,3),xlev(20,8),wt(8,10,2),wtdist(8,10)
      real ylev(20,8)
      integer nlev(8),icode(8,10)
      real, dimension(3):: dtor,wtor,wtor65,w_edge
        real, dimension(0:9):: dipbck
      real, dimension (3,3,8) :: gnd_ep
      real, dimension(16,40,8,3,3) :: hbin,ebar,rbar,mbar
      real, dimension(40,nzonex):: mmax_ccd	!new 4/02/2013 complementary cum. distribution of mmax
c (first dimension) in zones 1 to 10 (2nd dimension)
      common/epistemic/nfi,e_wind,gnd_ep,mcut,dcut
      common/deagg/deagg
c epsilon_0 pre-calcs. will occur if and only if deagg = .true.
c separate arrays are kept for each atten. model. epsilon band contribs may be computed
c later, during the summing-up stage.
      common/e0_wus/e0_wus(310,31,8,3,3)
      common/fix_sigma/fix_sigma,SIGMA_FX
      LOGICAL fix_sigma,sdi/.false./,pnw_deep/.false./
c 
c If multiple depths (3 or less) are run, the below arrays will work. However, typical
c case for WUS intrslab is just one depth at 50 km. May need to remove this dim.
c to reduce memory demand.
      common/e0_sub/e0_sub(310,31,8,3)
c 
c 3 intraplate models e0s will be combined in this array as a fcn of distance, M, period,
c ad depth of source-zone top.
c
c e0_ceus not saving a depth of rupture dim, not sens. to this. last dim is ip (period index)
       common/e0_ceus/e0_ceus(310,31,8)
        common/ceus_sig/lceus_sigma,ceus_sigma
      real, dimension (107):: perbssa13
      real, dimension(40,nzonex):: mwmax,wtmw,wt_zone
       common/cb13p/Percb13
      integer m_ind
      real, dimension(13):: a11fr,freq
c wtmj_cra = wt applied to rate when using Johnston mb to M for src in stable craton
c wtmj_ext = wt applied to M when using Johnston mb to M for src in extended margin
c wtmab_cra, wtmab_ext = ditto for Atkinson-Boore mb to M
      real, dimension(40) :: wtmj_cra,wtmj_ext,wtmab_cra,wtmab_ext,wt_cra,wt_marg
      real, dimension(40) :: wt_mask,xmw
c CEUS, 2008:wt_mask is assigned to one of the above depending on current site location and
c current mb --> Mw in input
c CEUS, 2013: wt_mask is assigned to one of the wtmw() vectors, the one corresponding to zone(k)
      real v30(100000)      !possible array of site-specific vs30 new mar 2006.
      type header_type
        character*128 name(6)
        real period
        integer nlev
        real xlev(20)
        real extra(10)
      end type header_type
       type(header_type) :: headr,hd
      type h_type
        character*128 name(6)
        real bval       !bvalue >=0 usually
        integer icum    !icum=1 if cumulative rate of exceed; 0 if incremental
        real maga       !the magnitude at which a is computed, typically 0
        real dmag       !the delta-M interval used (usually 0.1)
        real lowmag     !minimum M for which this rate should be used
        real cmag       !the magnitude for which a recurrence interval is available
        real himag      !maximum M for which this should be used
        real ri         !the recurrence interval years
        real excess(14) !items without a current use.
        real s,minlon,maxlon,dlon,minlat,maxlat,dlat,en
        real extra(2)
      end type h_type
      type(h_type) :: hd_a
      real magmin,magmax,magref,sigmanf,distnf
      real ymax/-100./,ymin/100./,dy/0.1/      !latitude of sites?
      real, dimension(13) :: pcut 
      integer, dimension(13) :: icut
      integer readn,iq_ka,iq_as,jabs,vs30_class
      logical finite,grid,isok,m_zones/.false./      ! grid=.true. if stations form a regular grid
c m_zones is an indicator that magnitude zones are (are not) active
      logical lceus_sigma/.false./,wus/.false./,ceus/.false./,slab/.false./,readcb13/.true./
      logical byeca,byesoc,byeext,byepug,v30a,override_vs,l_mmax,hardrock,useRy0
c override_vs becomes true if for deaggregation work user inputs a vs30 on command line.
      logical deagg,ss,rev,normal,obl,okabs,okgeo,okzhao,oktogo,e_wind(8),readbssa/.true./
c craton and margin determine whether a source is in craton, margin, or neither
      logical, dimension(128000):: craton,margin
c oktogo is a check that period is in set of 7 available for 2003 PSHA work.
c similar logical variable for AB03 is okabs. Similar for geomatrix is okgeo.
c The pre-NGA atten. models are only called if oktogo = .true.      
      real slat(32),slong(32)      !station coordinates if using list option
      character*12 sname(32)      !station names? might be useful
      character*72 progname,pname*36
      character*8 date,time*10,zone*5
      character*80 namein,nameout,name,name3,name4,namea
      character cmnts2skip(200)*80
      character*12 pithy(3),adum
      dimension xlen2(50),perabs(9),perabu(10)
      integer, dimension(8):: ia08
c 7/22/2010: promote hazard curve to double precision for better accumulation of small contributors
      real*8, dimension (1000,20,8,3) :: prob
c the sum will be put back into single precision array called "out" prior to writing.
      real, dimension(40000) :: out
      integer, dimension(8,10):: iatten
      integer, dimension(8,10):: irab
       real, dimension(1000):: xlim,xwide
      real*8 dp,pr0,prl,prlr,prr
      real prd(106),camper(24),perb(23),perka(0:37),tpper(16)
      real, dimension(13):: pergeo
      real, dimension(22) :: NAAper, perId12
      real, dimension(23) :: Percb13
      real, dimension(23) ::peras13
      real arat, aratemx/0.0/,Mtaper
      real, dimension(26):: abper, abfrq
c above spectral period vectors are associated with various NGA and other
c atten models. perka corresponds to Kanno et al. added Nov 8 2006.      
      dimension aperiod(108),ival(8)
      integer, dimension (npmx) :: nattn,iper,iperb,iperab,ipertp,isilva,ipcb13,ipbssa
      integer, dimension(npmx,3):: ifp
c      real, dimension (16,20,10,npmx,5) :: prob5
      real, dimension(0:35) :: pdgk
      real, dimension (22) :: percy13	!DOWNSIZED 4/2013
      real, dimension(npmx) :: perx,period,safix
      real, dimension(npmx+1) :: perx_pl
      real, dimension(11):: pdSilva,per_camp,perzhao
c some arrays for BSSA NGAW model 
      real, dimension(5) :: dumb
c safix is for fixed-SA or fixed PGA runs, usually with deaggregation.
      dimension asum(40,1000,3),arate(nsrcmx,40)
c nov 14 2007: add wtgrid matrix for use if Mtaper > 5 (agrid tapering magnitude)
      real, dimension(nsrcmx) :: a,b,mmax,wtgrid,fltstrk
      integer, dimension(nsrcmx) :: mzone	!zone indicator
c Spectral period -1 is reserved for pgv
c      pcut=(/0.0062,0.0228,0.0668,0.1587,0.3085,0.5,0.6915,.8413,.9332,
c     + 0.9772,0.9938,1.,1./)
c above cuts at e=-2.5,-2,-1.5,-1,-0.5,0,.5,1,1.5,2,2.5, respectively
c for possible deagg work.
c percy13 changed in the apr 2013 update: they omit pgd and pgv this time.
       percy13=     (/0.0100, 0.0200, 0.0300,
     1                0.0400, 0.0500, 0.0750, 0.1000, 0.1500,
     1                0.2000, 0.2500, 0.3000, 0.4000, 0.5000,
     1                0.7500, 1.0000, 1.5000, 2.0000, 3.0000,
     1                4.0000, 5.0000, 7.5000,10.0000/)
c peras13 22 periods plus a -1 at the tail.
      peras13= (/ 0.00, 0.02, 0.03, 0.05, 0.075, 0.1, 0.15, 0.2, 0.25, 
     1              0.3, 0.4, 0.5, 0.75, 1., 1.5, 2., 3., 4., 5., 6., 7.5, 10.,-1. /)
        perId12  = (/0.01,0.02,0.03,0.04,0.05,0.075,0.1,0.15,0.2,0.25,0.3,0.4,0.5,
     + 0.75,1.,1.5,2.,3.,4.,5.,7.5,10./)
c Idriss 2012 GMPE periods in perId12
       perabs = (/0.,0.2,1.0,0.1,0.3,0.5,0.75,2.0,3./)
       perabu = (/0.,0.2,1.0,0.1,0.3,0.4,0.5,0.75,2.0,3./)
      perx_pl= (/0.0,0.2,1.0,0.1,0.3,0.5,2.0,0.04,0.4/)
c pergeo Geomatrix inslab periods available Nov 19 2008.
         pergeo= (/0.,0.2,1.0,0.1,0.3,0.5,2.0,.4,0.75,1.5,3.,4.,5./)    
       perx= (/0.,0.2,1.0,0.1,0.3,0.5,2.0,-1./)      
c pdgk = period set for GK12 model.
      pdgk= (/0.,0.01,0.02,0.03,0.04,0.06,0.08,0.1,0.12,0.14,
     &         0.16,0.18,0.20,0.22,0.24,0.27,0.30,0.33,
     &         0.36,0.4,0.46,0.5,0.6,0.75,0.85,1.0,1.5,
     &         2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0/)
c perb = Boore-Atkinson NGA 4/2007 period set, -1 = pgv. Now 23. 10 s is longest in April.
      perb= (/-1.000, 0.000, 0.010, 0.020, 0.030, 0.050, 0.075, 0.100,
     + 0.150, 0.200, 0.250, 0.300, 0.400, 0.500, 0.750, 1.000,
     + 1.500, 2.000, 3.000, 4.000, 5.0, 7.5, 10.0/)
       aperiod= (/ 0.0, -1.0, -2.0, 0.01, 0.02, 0.022, 0.025, 0.029,
     1              0.03, 0.032, 0.035, 0.036, 0.04, 0.042, 0.044, 
     2              0.045, 0.046, 0.048, 0.05, 0.055, 0.06, 0.065, 
     3              0.067, 0.07, 0.075, 0.08, 0.085, 0.09, 0.095, 0.1, 
     4              0.11, 0.12, 0.13, 0.133, 0.14, 0.15, 0.16, 0.17, 
     5              0.18, 0.19, 0.2, 0.22, 0.24, 0.25, 0.26, 0.28, 0.29, 
     6              0.3, 0.32, 0.34, 0.35, 0.36, 0.38, 0.4, 0.42, 0.44,
     7              0.45, 0.46, 0.48, 0.5, 0.55, 0.6, 0.65, 0.667, 0.7,
     8              0.75, 0.8, 0.85, 0.9, 0.95, 1.0, 1.1, 1.2, 1.3, 1.4, 
     9              1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.2, 2.4, 2.5, 2.6, 2.8, 
     1              3.0, 3.2, 3.4, 3.5, 3.6, 3.8, 4.0, 4.2, 4.4, 4.6, 4.8, 
     1              5.0, 5.5, 6.0, 6.5, 7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 10.0 /)
c modified the .3155 to .3, modified the .0996 to 0.1 sh mar 16. mod .3968 to 0.4
c june 30 2007. 
      perbssa13=(/-1.000000, 0.000000, 0.010000, 0.020000, 0.022000, 0.025000, 0.029000,
     + 0.030000, 0.032000, 0.035000, 0.036000, 0.040000, 0.042000, 0.044000, 0.045000, 0.046000, 0.048000,
     + 0.050000, 0.055000, 0.060000, 0.065000, 0.067000, 0.070000, 0.075000, 0.080000, 0.085000, 0.090000,
     + 0.095000, 0.100000, 0.110000, 0.120000, 0.130000, 0.133000, 0.140000, 0.150000, 0.160000, 0.170000,
     + 0.180000, 0.190000, 0.200000, 0.220000, 0.240000, 0.250000, 0.260000, 0.280000, 0.290000, 0.300000,
     + 0.320000, 0.340000, 0.350000, 0.360000, 0.380000, 0.400000, 0.420000, 0.440000, 0.450000, 0.460000,
     + 0.480000, 0.500000, 0.550000, 0.600000, 0.650000, 0.667000, 0.700000, 0.750000, 0.800000, 0.850000,
     + 0.900000, 0.950000, 1.000000, 1.100000, 1.200000, 1.300000, 1.400000, 1.500000, 1.600000, 1.700000,
     + 1.800000, 1.900000, 2.000000, 2.200000, 2.400000, 2.500000, 2.600000, 2.800000, 3.000000, 3.200000,
     + 3.400000, 3.500000, 3.600000, 3.800000, 4.000000, 4.200000, 4.400000, 4.600000, 4.800000, 5.000000,
     + 5.500000, 6.000000, 6.500000, 7.000000, 7.500000, 8.000000, 8.500000, 9.000000, 9.50,10.0/)

c per_camp available spectral periods for CampCEUS (2003). PGA is 0.0 s here.
      per_camp = (/0.00,0.2,1.0,0.1,0.3,0.4,
     + 0.5,2.0,.03,.04,.05/)
      abper = (/5.0000, 4.0000, 3.1250, 2.5000, 2.0000, 1.5873, 1.2500, 1.0000,
     1 0.7937, 0.6289, 0.5000, 0.4, 0.3, 0.2506, 0.2000, 0.1580,
     1 0.1255, 0.1, 0.0791, 0.0629, 0.0499, 0.0396, 0.0315, 0.0250,
     1 0.0000, -1.000/)
c BCHydro periods add nov 2012
        NAAper =(/0.00, 0.050, 0.075,0.100, 0.150,0.200,0.250,0.300,0.400,
     + 0.500, 0.600, 0.750, 1.000, 1.500, 2.000, 2.500, 3.000, 4.000, 5.000, 6.0, 7.500, 10.0/)
c
c Silva Gregor and Darragh 2002 CEUS periods available as of july 1 2008.
      pdSilva=(/0.,0.04,0.05,0.1,0.2,0.3,0.4,0.5,1.,2.,5./)
c Tavakoli periods 0 = pga. added 0.4 s june 30 2008 (interpolated)
      tpper = (/0.00e+00,.04,5.00e-02,8.00e-02,1.00e-01,1.50e-01,2.00e-01,
     1 0.3,0.40,0.5,
     1       7.50e-01,1.00e+00,1.50e+00,2.00e+00,3.00e+00,4.00e+00/)
c a11fr frequencies for CEUS 2011 GMPES:
       a11fr =(/0.20,    0.33, 0.50, 1.00, 2.00, 3.33, 5.00,10.00,20.,33.00,50.00,99.00,89.00/)
c available periods for CY as of jan 2009. pga=0.0, pgv is -1.0 here
       prd=(/0.0,0.020,0.022,0.025,0.029,0.030,0.032,0.035,0.036,0.040,0.042,0.044,0.045,0.046,
     10.048,0.050,0.055,0.060,0.065,0.067,0.070,0.075,0.080,0.085,0.090,0.095,0.100,0.110,0.120,
     10.130,0.133,0.140,0.150,0.160,0.170,0.180,0.190,0.200,0.220,0.240,0.250,0.260,0.280,0.290,
     10.300,0.320,0.340,0.350,0.360,0.380,0.400,0.420,0.440,0.450,0.460,0.480,0.500,0.550,0.600,
     10.650,0.667,0.700,0.750,0.800,0.850,0.900,0.950,1.000,1.100,1.200,1.300,1.400,1.500,1.600,
     11.700,1.800,1.900,2.000,2.200,2.400,2.500,2.600,2.800,3.000,3.200,3.400,3.500,3.600,3.800,
     14.000,4.200,4.400,4.600,4.800,5.000,5.500,6.000,6.500,7.000,7.500,8.000,8.500,9.000,9.500,
     110.0,-1./)
c available periods for CB as of Mar 2008. pga=0.0 here. Displacement per is -2
      camper=(/0.010,0.020,0.030,0.050,0.075,0.100,0.150,0.200,0.250,0.300,0.400,0.500,0.750,
     + 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 7.5,10.0, 0.0,-1.0,-2.0/)
      perka =(/0.,0.05,0.06,0.07,0.08,0.09,0.10,0.11,0.12,0.13,0.15,0.17,0.20,0.22,
     +0.25,0.30,0.35,0.40,0.45,0.50,0.60,0.70,0.80,0.90,1.00,1.10,1.20,
     +1.30,1.50,1.70,2.00,2.20,2.50,3.00,3.50,4.00,4.50,5.00/)
c perabs: period set for ab slab-zone (deep) eqs.
c ab06 frequencies, these don't seem to be extremely close to 1/T
      abfrq = (/2.00e-01,2.50e-01,3.20e-01,4.00e-01,5.00e-01,6.30e-01,8.00e-01,1.00e+00,
     1       1.26e+00,1.59e+00,2.00e+00,2.52e+00,3.17e+00,3.99e+00,5.03e+00,6.33e+00,
     1       7.97e+00,1.00e+01,1.26e+01,1.59e+01,2.00e+01,2.52e+01,3.18e+01,4.00e+01,
     1       0.00e+00,-1.00e+00/)
      perzhao = (/0.0,0.1,0.2,0.3,0.5,1.0,1.5,2.,3.,4.,5./)
c use 2008 USGS logic tree for Mmax for the wts for mbLg from 5.05 to 7.45. We may
c read in this distribution but this is safe for envisioned purpose: web site server for
c site-specific deagg.
      dipbck =(/90.0,80.,70.,60.,50.,45.,40.,35.,30.,25.0/)
c the size of below arrays was increased to 40 because of potentially greater Mmax under consideration.
      wtmj_cra=(/1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,
     +0.9,0.7,0.2,0.2,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0./)
      wtmj_ext=(/1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,
     +1.,1.,1.,0.9,0.7,0.7,0.2,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0./)
      wtmab_cra=(/1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,
     +1.,1.,0.9,0.9,0.7,0.2,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0./)
      wtmab_ext=(/1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,
     +1.,1.,1.,1.,1.,1.,0.9,0.7,0.2,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0./)
      pithy = (/'Using Median','Median+EpUnc','Median-EpUnc'/)

c      write(6,*) "enter name of input file"
 900  format(a)
      if(iargc().lt.1)stop'Usage hazgridXnga13l inputfile > logfile'
      if(iargc().eq.3)then
      call getarg(2,adum)
      if(adum.eq.'fixsigma'.or.adum.eq.'FIXSIGMA')then
      call getarg(3,adum)
      read(adum,'(f6.3)')sigma_fx
      fix_sigma=.true.
      print *,'This run will fix sigma at ',sigma_fx,' for all WUS GMPEs all sp. periods'
            elseif(adum.eq.'dy'.or.adum.eq.'dY'.or.adum.eq.'DY')then
            sdi=.true.
            call getarg(3,adum)
            read(adum,'(f6.3)')dy_sdi
            print *,'The code will compute inelastic displ spectra with dy(cm) ',dy_sdi
      else
      print *,'dont know what to do with ',adum
      endif
      elseif(iargc().gt.4)then
      deagg=.true.
      call getarg(2,adum)
      read(adum,'(f7.4)')rlatd
      ind=index(adum,'.')
      jnd=index(adum,' ')-1
      if(ind.eq.0)adum=adum(1:jnd)//'.'
      read(adum,'(f8.4)')rlatd
      call getarg(3,adum)
      ind=index(adum,'.')
      jnd=index(adum,' ')-1
      if(ind.eq.0)adum=adum(1:jnd)//'.'
      read(adum,'(f9.4)')rlond
c rlatd rlond are the coordinates of the deagg-analysis site. This location overrides the stuff
c in the input file.
      write(6,*)'#HazgridXnga13l: deagg site location: ',rlatd,rlond
            call getarg(4,adum)
      read(adum,'(i1)')npd
      do i=5,npd +4
      call getarg(i,adum)
c adum could be sa(g) or pgv (cm/s). need flexi format
      ind=index(adum,'.')
      jnd=index(adum,' ')-1
      override_vs= .false.
      if(ind.eq.0)adum=adum(1:jnd)//'.'
      read(adum,'(f8.4)')safix(i-4)
      write(6,*)'#command line sa ',safix(i-4)
      enddo
      if(iargc().gt.npd+4)then
      call getarg(npd+5,adum)
      ind=index(adum,'.')
      jnd=index(adum,' ')-1
      if(ind.eq.0)adum=adum(1:jnd)//'.'
      read(adum,'(f6.1)')vs30d
      override_vs=.true.
      write(6,*)'#vs30 will be ',vs30d,' m/s for this run. From command line'
      else
      override_vs=.false.
      endif
      rbar=0.
      mbar=0.
      ebar=0.
      hbin=0.0
      prob5=0.
      endif
      call getarg(1,namein)
      inquire(file=namein,exist=isok)
      if(isok)then
      open(unit=1,file=namein,status='old')
      else
      write(6,*)'File not found: ',namein
      stop 'Put in working dir and retry'
      endif
      call date_and_time(date,time,zone,ival)
      write (6,61)date,time,zone,namein
61      format('hazgridXnga13l (5/13/2013) log file. Pgm run on ',a,' at ',a,1x,a,/,
     + '# Control file:',a)
        call getarg(0,progname)
        ind=index(progname,' ')
        if(ind.gt.30)then
        pname=progname(ind-36:ind-1)
        else
        pname=progname(1:ind)
        endif
c Initialize truncated normal array Pex, store in p().
c The indep. variable is a real*8 to reduce discretization error.
        prl=0.5*(derf(emax/sqrt2) + 1.0)
        prlr=1.0/prl
        prr=1.0-prl
        plim=-emax/sqrt2
        pr0=plim
      ii=1
        dp=0.00004*(3.3-plim)
        dp2=1.0/dp
        p(1)=1.e-9
        do i=2,25001
        pr0=pr0+dp
        p(i)=((derf(pr0)+1.)*0.5-prr)*prlr
c        if(p(i).ge.pcut(ii))then
c        icut(ii)=i
c        ii=ii+1
c        endif
        enddo
        p(25002)=1.0
c        write(6,*)'epsilon indexes: '
c        do ii=1,13
c      write(6,*)ii,icut(ii)
c        enddo
      mcut(1)=6.0
      mcut(2)=7.0
      dcut(1)=10.
      dcut(2)=30.
      pr=0.
c      call initialize()
c End initializing the truncated normal PEx() array=p()
c Made the indep. variable a real*8 to reduce discretization error. However,
c you have to be careful that your erf can take a real*8. If not, spr0=pr0 assignment
c where spr0 is single precision should be tried.
      v30a = .false.
       distnf = 0.0; sigmanf = 0.0
      wt_mask=1.0
      craton=.false.
      margin=.false.
      write(6,580)'Enter a zero for grid of sites 1 to 30 for list: '
      read(1,*,err=2106)nrec
      write(6,*)nrec
      if(nrec.eq.0)then
      grid=.true.
c      write(6,*) "for sites: enter min lat, max lat, dlat"
      read(1,*) ymin, ymax, dy
      if(.not.deagg)then
      latmin=nint(ymin)
      ylatmin=float(latmin)
       write(6,*)'Receiver latitude range ',ymin,ymax,dy
      endif
c      write(6,*) "for sites: enter min lon, max lon, dlon"
      read(1,*) xmin, xmax, dx
      
      if(.not.deagg)then
      write(6,*)'  & Longitude range ',xmin,xmax,dx
      nx= nint((xmax-xmin)/dx) +1
      ny= nint((ymax-ymin)/dy) +1
      nxbog=(xmax-xmin)/dx+1      !the old way, can yield bogus estimate of nx.
      nybog=(ymax-ymin)/dy+1
      write(6,*) nx,ny,' old calc: ',nxbog,nybog
      write(6,*)'Grid_of_sites hazcurves underway'
      nrec= nx*ny
      endif      !if not deagg
      elseif(nrec.lt.33)then
      grid=.false.
      write(6,*)'Program will compute gridded haz at ',nrec,' sites'
      dx =0.1
      dy =0.1      !need defaults
      do i=1,nrec
c      write(6,*)'Enter station lat,long (dec deg) and name(1 word): '
580      format(a,$)	
      read(1,*)slat(i),slong(i),sname(i)
      write(6,*)slat(i),slong(i),' ',sname(i)
      ymin=min(ymin,slat(i))
      ymax=max(ymax,slat(i))
      if(slat(i).lt.-88.)stop 'invalid station location. Antarctica?'
      enddo
      latmin=nint(ymin)
      ylatmin=ymin
      latmax=nint(ymax)
      else
      write(6,*)'Code expected first line of input to be nrec'
      write(6,*)'Valid nrec are 0, 1, ..., 29,30. Just read in ',nrec
      stop 'Please correct input file.'
      endif
      if(deagg)then
c replace whatever was in the file with the command line location
      nrec=1
      grid=.false.
      slat(1)=rlatd
      ymax=rlatd; ymin=rlatd
      slong(1)=rlond
      sname(1)='DEAG1'
      ylatmin=rlatd
      latmin=nint(rlatd); latmax=nint(rlatd)
      nx=1
      ny=1
      dmbin = 0.1      !try fine dM for initial deagg
      endif      !deagg is true?
      byeext=index(namein,'EXTmap').gt.0
      byeca=index(namein,'CAmap').gt.0.or.index(namein,'creepmap').gt.0
      byesoc=index(namein,'brawmap').gt.0
      byepug=index(namein,'pugetmap').gt.0
      normal=byeext
      ss=.not.normal	!temporary testing: no reverse or oblique.
c *** NEW 11/05 **** Enter soil Vs30 condition  ******NEW*******
      write(6,*)'Softrock has Vs<2500 m/s in below question'
      write(6,*)"For sites, enter Vs30(m/s) and softrock max depth(km)"
      read(1,*)vs30,dbasin
      if(override_vs)vs30=vs30d
c use Chiou-Youngs 10-2007 default depth to 1 km/s rock. Z1 Units: m.
        Z1cal = exp(-7.15/4 * log(((VS30/1000.)**4 + .57094**4)/(1.360**4 + .57094**4)))
c     Norm Abrahamson's CA z1 reference (eq 18)
       z1_ref = exp ( -7.67/4. * alog( (Vs30**4 + 610.**4)/(1360.**4+610.**4) ) ) / 1000.
c      deltaZ1=0.0	!dont know use 0. from guidance in CY doc.
      z1=z1cal	!CY2013 function used until we know better for wus...
      z1km=Z1*0.001	!for AS need units km
c from B Chiou email of Apr 15 2013.
        deltaZ1 = Z1cal -
     1  exp(-7.15/4 *
     1      log(((VS30/1000.)**4 + .57094**4)/(1.360**4 + .57094**4)))
      write(6,*)' Vs30 (m/s), Z1 (m) and depth of basin (km): ',vs30,Z1,dbasin,deltaZ1
        if(vs30.lt.90..and.vs30.gt.0.)then
      write(6,*)'Vs30 = ',vs30,'. This looks unreasonable.'
      stop'hazgridXnga13l: Please check input file just before distance incr,dmax'
      elseif(vs30.eq.0.)then
      write(6,580)'Enter the name of the binary vs30 array: '
      read (1,900)name
      inquire(file=name,exist=isok)
      if(.not.isok)stop'Vs30 array not in working directory'
      call openr(name)
      write(6,580)'Enter ymin, ymax, dy (lat, d) of Vs30 array: '
      read (1,*)vymin,vymax,vdy
      write(6,580)'Enter xmin, xmax, dx (long, d) of Vs30 array: '
      read (1,*)vxmin,vxmax,vdx
      write(6,580)'Enter a default vs30 in case site not inbounds: '
      read (1,*)vs30dflt
      if(vymin.gt.vymax)then
      y0=vymin
      vymin=vymax
      vymax=y0
c fix it if nec.
      endif
      nvx= nint((vxmax-vxmin)/vdx) +1
      nvy= nint((vymax-vymin)/vdy) +1      
c nint insures portability among different computers
      v30a=.true.
      nv30=nvx*nvy
c 30 characters
c      nhd=308
c 128 characters
      nhd=896
      call gethead(hd,nhd,nread)
      if(hd%extra(2).ne.vxmin)stop'mismatch vs30'
      call getbuf2(v30,nv30,nvread)
      write(6,*)'For vs30 expect ',nv30,' got ',nvread
      write(6,*)'**** Warning on site variability: ******************'
      write(6,*)'If using ChiouYoungs NGA, Z1 does not vary with Vs30'
      endif
c up to three depth to top of rupture values may be enterred to define uncertainty
c in this important variable. Units km.
      write(6,*)'Separate weights for dtor | M<6.5 or M>=6.5 in below question'
      write(6,*)"Enter ndtor, (dtor(k),wt_65-(k),wt_65+),k=1,..ndtor<=3"
      read (1,*)ntor,(dtor(k),wtor(k),wtor65(k),k=1,ntor)
      write(6,*)ntor, dtor(1),dtor(2),dtor(3),' km was input'
c check reasonableness of distribution
      wtor6=0.0
      wtor7=0.0
      tormin=10000.
      do k=1,ntor
      wtor6=wtor6+wtor(k)
      wtor7=wtor7+wtor65(k)
      tormin=min(tormin,dtor(k))
      enddo
      if (abs(wtor6-1.0).gt.0.001.and.tormin.lt.32.)then
      write(6,*)'sum of dtor weights not equal to 1. Please check input'
      stop 'and retry with improved weights'
      elseif(abs(wtor6-float(ntor)).le.0.001.and.tormin.ge.32.)then
      write(6,*)'For deep seismicity all focal-depth weights are 1'
      pnw_deep = .true.		!special study if tormin>32 and 3 depths
      w_edge=wtor65	!the locations of steps are input in wtor65 in this special case
      elseif(tormin.ge.32.)then
      write(6,*)'For deep seismicity all focal-depth weights should be 1'      
      stop'Reset these to 1.0 and retry'
      endif
      if (abs(wtor7-1.0).gt.0.001.and.tormin.lt.32.)then
      write(6,*)'sum of M6.5+ dtor Wt not equal to 1. Please check input'
      stop 'and retry with improved weights'
      endif
c large tormin could be associated with deep Benioff zone. For crustal
c earthquakes, this check isn't very interesting.
      if(tormin.lt.0..or.tormin.gt.202.)stop'Top of rupture distribution
     +  not reasonble. Please reenter'
      dipang1=pi/2.
      dipang2=pi*50./180.      !dip angle for normal &reverse
      cosDELTA=0.
      cosDELTA2=cos(dipang2)
      cdip2sq=cosDELTA2**2
      cbhwfac=0.0	!cb factor will be zero for vertical faults.
      cbhwfac2=1.0	!cb factor will be one for 50 degree dipping faults
      cyhwfac=0.0	!cy factor also zero for vertical faults.
      cyhwfac2=atan(13.05*0.5*cosDELTA2/6.0)/(pi*0.5)	! 50 degree dipping faults
c      cyhwfac=atan(width(ift)*0.5*cosDELTA/(dtor+1.0))/(pi*0.5)
c 13.05 = width if 50 d dip and 10 km from top of fault to 15 km trans. zone.
c      
      ss=.true.
      rev=.false.
      obl=.false.
      write(6,*)"Enter three weights ",
     + "corresponding to fraction ss, reverse, normal: "
      read (1,*)wtss,wtrev,wtnormal
c check for reasonable weights
      if(abs(1.-wtss-wtrev-wtnormal).gt.0.001)then
      	write(6,*)'Sense of slip weights dont add to 1.'
      	stop 'Please check these weights'
      elseif(min(wtss,wtrev,wtnormal).lt.-0.001)then
      	write(6,*)'At least one sense-of-slip weight < 0.'
      	      stop 'Please check these weights'
      endif
      write(6,*)'Weights to ss, rev, normal are ',wtss,wtrev,wtnormal
      read(1,*) di,dmax
      write(6,*)'dist incr ',di,' max dist ',dmax
c New: source grid independent of station grid.
	di2=di/2.0
c      write(6,*) "for sources: enter min lat, max lat, dlat"
      read(1,*) ysmin, ysmax, dsy
c      write(6,*) "for sources: enter min lon, max lon, dlon"
      read(1,*) xsmin, xsmax, dsx
      write(6,*)'Source box xmin,ymin ',xsmin,ysmin
      nsx= (xsmax-xsmin)/dsx +1
      nsy= (ysmax-ysmin)/dsy +1
      nsxx= nint((xsmax-xsmin)/dsx)+1
      nsyy=nint((ysmax-ysmin)/dsy)+1
      if(nsx.ne.nsxx.or.nsy.ne.nsyy)then
      write(6,*)'WARNING: NUMBER OF SOURCES is ambiguous '
      write(6,*)'Standard estimate is ',nsx*nsy
      write(6,*)'Improved value is ',nsxx*nsyy,' Using improved'
      nsx=nsxx
      nsy=nsyy
      endif
      nsrc= nsx*nsy
      if(nsrc.gt.nsrcmx)stop'number of sources exceeds rate array dim'
      arate=0.
c      write(6,*) "enter bval,magmin,magmax,dmag,magref"
      read(1,*) bval,magmin,magmax,dmag,magref
      rmagmin=magmin
c--- iflt=1 or 10 uses finite faults for M>6.0 with random strike
c--- iflt=2 or 20 uses finite faults and fixes strike
c--- iflt=3 uses finite faults with Johnston mblg to Mw conv.
c---- iflt=4 uses finite faults with Boore-Atkinson mblg to Mw conv.
c === iflt = -3 use point src with Johnston mblg to Mw conv.
c --- iflt = -4 use point src with Boore-Atkinson nblg to Mw conv. new sept 2008
c
c--- ibmat=1 uses b-value matrix
c--- maxmat = 1 uses Mmax matrix. mmax>1 uses zones of Mmax. New April 2013.
c --  maxmat = -1, use min of Mmax matrix and magmax scalar value input below
c-- set each to zero if you don't want these
c New nov 14 07L add field Mtaper (real variable). If M>Mtaper, multiply rate by wtgrid(k)
c to include CA
c      write(6,*) "enter iflt,ibmat,maxmat, Mtaper"
      l_mmax=.false.
c New nov 14 07L add field Mtaper (real variable). If M>Mtaper, multiply rate by wtgrid(k)
c to include CA
      read (1,*) iflt,ibmat,maxmat,Mtaper
      if(maxmat.gt.nzonex)stop'maximum number of Mmax zones is exceeded'
c New sept 2008: Use logical variable finite to control whether it's handled as a point src.
      if(iflt.le.0.and.iflt.ne.-2)then
      finite=.false.
      iflt=abs(iflt)
      else
      finite=.true.
      endif
      if(iflt.gt.2.and.iflt.lt.10)then
       write(6,*)' craton and margin logical indicator files are being 
     * read from GR/'
       rmagmin= 1.14 + 0.24*magmin +0.0933*magmin*magmin
       rmagmin=  min (rmagmin,2.715 - 0.277*magmin +0.127*magmin*magmin)
      open(90,file='GR/margin',form='unformatted')
      read(90)margin
      close(90)
      open(90,file='GR/craton',form='unformatted')
      read(90)craton
      close(90)
      if(iflt.eq.3)then
      wt_cra=wtmj_cra
      wt_marg=wtmj_ext
      else
      wt_cra=wtmab_cra
      wt_marg=wtmab_ext
      endif
      else
      margin=.false.
      craton=.false.
      endif
      write(6,*)'Magmin,magmax ',magmin,magmax
      dmag2= dmag/2.
      if(magmin.lt.4.5)stop' magmin appears unreasonably low.'
      if(ibmat.eq.1) then
c        write(6,*) "enter name of b-value file"
        read(1,900) name3
      inquire(file=name3,exist=isok)
      if(isok)then
        call openr(name3)
        call getbuf2(b,nsrc,readn)
c      write(6,*) "ymin=",ymin
        write(6,*) name3,' b-grid ',nsrc,readn
        if(nsrc.gt.readn)stop 'these must be equal.'
        else
        write(6,*)'File not found ',name3
        stop 'Put in expected loc and retry'
        endif      	!bvalue matrix found or not
        else
        write(6,*)'Constant b-value used ',bval,' scalar mmax ',magmax
        endif
      if(maxmat.ge.1.or.maxmat.eq.-1) then
c        write(6,*) "enter name of Mmax file"
        read(1,900) name4
      inquire(file=name4,exist=isok)
      if(isok)then
        call openr(name4)
        call getbuf2(mmax,nsrc,readn)
        write(6,*) nsrc,readn,' mmax grid'
        if(nsrc.gt.readn)stop 'these must be equal.'
        if(maxmat.eq.1)then
      write(6,*)'Geographic mmax file replaces const. mmax ',name4
      elseif(maxmat.lt.0)then
      l_mmax=.true.
c      s_magmax=magmax
      write(6,*)'Code takes minimum of mmax file and ',magmax
      else
      m_zones=.true.	!logical to indicate that magnitude "zones" are active
      write(6,*)'Indicator file of mmax zones is: ',name4
      write(6,*)'New feature Apr 2 2013: zones define regions with different MMax distributions'
c the zone mmax distribution with weights
c example line: 5 6.5 0.1 6.7 0.2 6.9 0.4 7.1 0.2 7.3 0.1
      do k=1,maxmat
      read(1,*)izone,nm,(mwmax(j,izone),wtmw(j,izone),j=1,nm)
      mwmaxx(izone)=mwmax(nm,izone)
      wnow=1.
      i1=1
      sum=0.0
      do j=1,nm
      i2= nint((mwmax(j,izone)-magmin)/dmag)+1
      print *,i2,mwmax(j,izone), magmin,dmag,izone
      wt_zone(i1:i2,izone)=wnow
      i1=i2+1
      wnow=wnow-wtmw(j,izone)
      sum=sum+wtmw(j,izone)
      enddo	!j loop
      if(abs(sum-1.).gt.1e-6)then
      print *,'Sum of weights in zone ',k,' is not 1. Renormalizing. Sum ',sum
      wt_zone(1:i1,izone)=wt_zone(1:i1,izone)/sum
      endif
      wt_zone(i1:40,izone)=0.0	!Pr[ M>max(Mmax)] is zero
      print 3434,'For magnitude zone ',k,' CCD of Mmax beginning at ',magmin
3434	format(a,i2,a,f5.2)
      print *,wt_zone(1:i1,k)
      enddo	!k loop
      mzone=int(mmax)	!mzone is integer field over the region {1,2,..,mmax}
      endif
        else
        write(6,*)'This mmax file was not found: ',name4
        stop
        endif
        endif
      fac= alog10(10.**(bval*dmag2)-10.**(-bval*dmag2))
c new Nov 14 2007: enter wtgrid file name if Mtaper is between 5 and 8. Mtaper is a magnitude
c above which the rate of events will be decreased by a factor to be found in a file
c that fills wtgrid.
      if(Mtaper.gt.5..and.Mtaper.lt.8.)then
      read(1,900) name
      inquire(file=name,exist=isok)
      if(isok)then
      call openr(name)
      call getbuf2(wtgrid,nsrc,readn)
      write(6,*)'wtgrid file ',name
      write(6,*) nsrc,readn,' wtgrid counts'
        if(nsrc.gt.readn)stop 'These must be equal.'
        else
        write(6,*)'This wtgrid file was not found: ',name
        stop
        endif
        else
        Mtaper=10.
        endif
      
      nmagmax=0
c      write(6,*) "enter name of a-value file"
      read(1,900) name
      inquire(file=name,exist=isok)
      if(isok)then
      call openr(name)
c dpes the agrid file have a header record? If so read it.
      if(iflt.ge.10)then
      nhd = 896
      call gethead(hd_a,nhd,n)
      ysmin=hd_a%minlat; ysmax=hd_a%maxlat; dsy=hd_a%dlat
      print *,'From header, ymin,ymax,dy for sources: ',ysmin,ysmax,dsy
      nsx= nint((hd_a%maxlon-hd_a%minlon)/hd_a%dlon)+1
      xsmin=hd_a%minlon; xsmax=hd_a%maxlon; dsx=hd_a%dlon
      print *,'From header, xmin,xmax,dx for sources: ',xsmin,xsmax,xsy
      nsy=nint((hd_a%maxlat-hd_a%minlat)/hd_a%dlat)+1
      bval = hd_a%bval
      nsrc = nint(hd_a%en)
      print *,'Agrid header info replaces input file. Nsx,nsy,bval ',nsx,nsy,bval
      print *,'Mean return time (yrs) for this zone: ',hd_a%ri
      endif
      call getbuf2(a,nsrc,readn)
      write(6,*)'agrid file ',name
      write(6,*) nsrc,readn,' agrid counts'
        if(nsrc.gt.readn)stop 'These must be equal.'
        else
        write(6,*)'This agrid file was not found: ',name
        stop
        endif
c      write(6,*) "enter number of years for agrid file, conv to incr"
      read(1,*) cyr,incr
      if(iflt.ge.10)incr=hd_a%icum
c--- convert from cumulative a-value to incremental a-value if necessary
      if (incr.eq.1) then
      do 112 j=1,nsrc
      if(a(j).ne.0.) then
         a(j)= alog10(a(j))+fac
         a(j)= 10.**a(j)
         endif
 112  continue
      endif
c----------- new line for fixing fault strike if iflt=2
      if(iflt.eq.2.or. iflt.eq.20)then
       read(1,*) fltstr
       write(6,*)'Fixed-strike angle is ',fltstr
       sinf=sin(coef*fltstr); cosf=cos(coef*fltstr)
       elseif(iflt.eq.-2)then
c new Feb 3 2010: file of fault strikes defined on source grid.
             read(1,900)namea
             call openr(namea)
c the fixed strike angle is in radians not degrees.
             call getbuf2(fltstrk,nsrc,nrd)
       write(6,597)namein,namea
597      format('#hazgridXnga13l infi: ',a20,' fixed strike angle from',a)
        else
c New: enter name of the M,D indexed rjbmean array
      read(1,900)name
      write(6,*)'** File of rjbmean distances ',name(1:40)
c      print *,'**File of rjbmean distances ',name(1:40)
      inquire(file=name,exist=isok)
      if(isok)then
c the array size of rjbmean was increased on Feb 1 2013 to allow the possibility
c of a very large background source w/Mmax 8.1 or greater.
        open(4,file=name,form='unformatted')
        read(4,end=2015)rjbmean
        close(4)
        rjbmax=1000.
        if(dmax.gt.rjbmax) stop'please increase Rmax in meanrjb.bin'
        xmmin_rjb=6.05
        xmmax_rjb=8.55
          dm_rjb=0.1
        dr_rjb=1.0
      else
        print *,'This file was not found. Please put it in WD'
        stop'hazgridXnga13l cannot proceed without it'
      endif
        dum=dtime(tarray)
       endif
c--- center magnitude bins
      if(magmax.ne.magmin) magmin= magmin+dmag2
c-------------------------
c---- set up rate matrix (arate) for each source cell and mag increment
      do 90 j=1,nsrc
      if(a(j).eq.0.) go to 90
      if((ibmat.eq.1).and.(b(j).eq.0.)) b(j)=bval
      if(ibmat.eq.0) b(j)=bval
c---- some changes 5/29 for negative Mmax
c. 
c 
      if((abs(maxmat) .eq.1).and.(mmax(j).lt.0.)) a(j)=1.e-10
      if((abs(maxmat) .eq.1).and.(mmax(j).le.0.)) mmax(j)=magmax
c the new rule, sept 20 2007: use the lower of magmax and mmax(j) if l_mmax, but
c only after mmax(j) has been given its annual checkup above.
      if(l_mmax)mmax(j) = min(mmax(j),magmax)
      if(ibmat.eq.1)
     &  fac2= alog10(10.**(b(j)*dmag2)-10.**(-b(j)*dmag2))
      if(maxmat.eq.0) nmag= (magmax-dmag2-magmin)/dmag +1.4
      if((maxmat.eq.0).and.(magmax.eq.magmin)) nmag=1
      if(abs(maxmat).eq.1) nmag= (mmax(j)-dmag2-magmin)/dmag +1.4
c new 4/04/2013: for the multiple zones of mmax, find nmag for each source location
      if (maxmat.gt.1)nmag=(mwmaxx(mzone(j))-dmag2-magmin)/dmag +1.4
      if(nmag.gt.nmagmax) nmagmax=nmag
      do 91 m=1,nmag
      xmag= magmin+(m-1)*dmag
      if(ibmat.eq.0) rate= alog10(a(j)/cyr)-bval*xmag
      if(ibmat.eq.1) then
           rate= alog10(a(j)/cyr)-b(j)*xmag
           endif
      arat= 10.**rate
      if(xmag.ge.Mtaper)arat = arat * wtgrid(j)
      arate(j,m)=arat
      if(arat.gt.aratemx)then
      aratemx=arat
      jp=j
      endif
  91  continue
  90  continue
      write(6,*)'Minimum mag for this run: ',magmin
      print *,'maximum eq rate is ',aratemx,' at j=',jp
      if(aratemx.le.0.)stop'No hazard. Nothing to calculate'
      coef= 3.14159/180.
      ndist= dmax/di +0.5
      nmag= nmagmax
      if(nmag.gt.36)stop'nmag > 36 an array limit in pr()'
cc do this blasted mag conversion once. Be done with it. 10/2009.
      do m=1,nmag
         xmag= magmin+(m-1)*dmag
         if(abs(iflt).eq.3)then
          xmag=  1.14 + 0.24*xmag+0.0933*xmag*xmag
c----Boore Atkinson 87 conversion
         elseif(abs(iflt).eq.4) then
         xmag=  2.715 - 0.277*xmag+0.127*xmag*xmag
        endif
        xmw(m)=xmag
      enddo
c new 12/18/2006:
c Use precalculated mean distance of random oriented source to sites up to 1000 km away
c      write(6,*) "enter number of periods"
      read(1,*) nper
      write(6,*)'Number of spectral periods ',nper
      if(nper.gt.npmx)stop'number exceeds npmx'
c      matrix math, initialize pr array to 0. (rate of exceedance)
       pr=0.
c---loop through periods
      do 700 ip=1,nper
      read(1,*) period(ip),wind      
c wind is indicator variable to determine if addnl epistemic uncert to be
c added to gnd. If yes make wind 1 (or any nonzero number)
      per= period(ip)
      if(sdi)fac_sde(ip) = alog(980.*max(0.01,per)**2/fourpisq)
c Define a mapping of per to iper for later use with atten models.
      k=1
      dowhile(per.ne.perx(k))
      k=k+1
      if(k.gt.8)then
      write(6,*) 'Input period not available for all models ',per
      k=8
      go to 902
      endif
      enddo
902      iper(ip)=k
      if(wind.ne.0.)then
      e_wind(ip)=.true.
      do im=1,3
      if(im.eq.1)then
      write(6,505)mcut(1)
      elseif(im.eq.2)then
      write(6,506)mcut(1),mcut(2)
      else
      write(6,507)mcut(2)
      endif
      write(6,509)dcut(1),dcut(1),dcut(2),dcut(2)
509      format('3 DeltaGnd, for d < ',f4.1,', ',f4.1,' <=d < ',f4.1,
     + '& d >=',f4.1,' km: ',$) 
      read(1,*)gnd_ep(1,im,ip),gnd_ep(2,im,ip),gnd_ep(3,im,ip)
c increase or decrease ln(gm) by equal amounts in NGA subroutines. This effect
c has been added to other WUS atten models to a limited degree. Max 49%.
      write(6,*)gnd_ep(1,im,ip),gnd_ep(2,im,ip),gnd_ep(3,im,ip)
505      format('Additional epistemic gnd, for M < ',f4.1)
506      format('Next, for ',f4.1,'<=M < ',f4.1)
507      format('Finally, for M >= ',f4.1)
      enddo	!im loop
      nfi=3
      else
      nfi=1
      endif	!if additional epistemic sigma is read in
      if(k.eq.8)write(6,*)'PGV is not available for preNGA models'
c      write(6,*) "enter name of output file for this period"
      read(1,900) nameout
      write(6,*)'Output file name for spectral period ',per,nameout
       if(grid)then
      call openwx(ifp(ip,1),nameout)
      write(6,*) ifp(ip,1),trim(nameout)
      if(nfi.eq.3)then
      write(6,*)'Additional files for epistemic gm branches:'
      name4=trim(nameout)//'.p'
      call openwx(ifp(ip,2),name4)
      write(6,*) ifp(ip,2),trim(name4)
        nameout=trim(nameout)//'.m'
      call openwx(ifp(ip,3),nameout)
      write(6,*) ifp(ip,3),trim(nameout)
      endif      !nfi = 3. Open up 2 extra files for epistemic branches
      else
c if ascii put each curve in same output file
      open(9+ip,file=nameout,status='unknown')      !ascii
      write(9+ip,402)date,trim(namein)
402      format('#hazgridXnga13l(7/07/2009) run on ',a9,' input fi ',a)
      if(deagg)then
c  Determinie if Safe to use 20+ip unit number.
c First try: deagg. epistemic gm uncert & depth of top for WUS uncert will get combined into
c same rbar, mbar, ebar, haz array. These could be separated if nec. CEUS. one depth but several
c more atten models(max 8). Inslab. Can have depths but no epistem. gm uncert. 
      if(nper.ne.npd)stop'Deaggregation command-line np does not equal 
     * input-file nper'
       isz=index(nameout,' ')-1
      open(ip+20,file=nameout(1:isz)//'.DEAG',status='unknown')
      write(20+ip,907)safix(ip),period(ip),date,time,namein,rlatd,rlond,vs30
 907      format('#hazgridXnga13l deagg @SA=',f5.3,' g. T='f5.2,
     +' s, run on ',a,' at ',a,' fi ',a,
     +/,'#sta lat long = ',f7.4,1x,f9.4,' Vs30 (m/s) is ',f6.1)      
      endif      !if deagg. new june 6 2008.
      endif
c      write(6,*) "enter number of ground motion levels"
      read(1,*) nlev(ip)
      if(period(ip).gt.0.)then
      write(6,*)'Number of pSA levels ',nlev(ip)
      elseif(period(ip).eq.0.)then
      write(6,*)'Number of PGA levels ',nlev(ip)
      else
      write(6,*)'Number of PGV levels ',nlev(ip),' units cm/s'
      endif
      if(nlev(ip).gt.nlmx)stop'hazgridXnga13l, number of gm levs>nlmx'
      if(nlev(ip).lt.1)stop 'hazgridXnga13l: nlev(ip)<1'
c      write(6,*) "enter ground motion levels"
      read(1,*) (xlev(k,ip),k=1,nlev(ip))
      xlev(1,ip)=max(xlev(1,ip),1.e-8)
      write(6,*)'Min/max gm levels ',xlev(1,ip),xlev(nlev(ip),ip)
      if(xlev(nlev(ip),ip).gt.12. .and.per.ge.0.)stop 'unreasonable upper GM limit'
      if(xlev(nlev(ip),ip).lt.20. .and.per.lt.0.)stop 'unreasonably low PGV GM limit'
c command-line dominates input file if this is a deagg run.
         if(deagg)then
         nlev(ip)=1
         xlev(1,ip)=safix(ip)
         elseif(sdi)then
c New Feb 22 2013: convert sa to sd
        do k=1,nlev(ip)
        xlev(k,ip)=exp(fac_sde(ip))*xlev(k,ip)
        enddo
         endif
      do 403 k=1,nlev(ip)
      ylev(k,ip)=xlev(k,ip)      !save for writing output.
 403  xlev(k,ip)= alog(xlev(k,ip))
      ndist= dmax/di + 0.5
c---------
c      write(6,*) "enter number of atten. relations for this period"
      read(1,*) nattn(ip)
      if(nattn(ip).gt.10)then
      write(6,*)period(ip),' nattn(ip) just input as ',nattn(ip)
      write(6,*)'Limit 10 attenuation models per spectral period'
      stop'hazgridXnga13l: please check input file'
            endif
      write(6,*)'Number of attenuation relations is ',nattn(ip)      	
c--- loop through atten relations for that period
      do 701 ia=1,nattn(ip)
      iq=iper(ip)
      oktogo=iq.le.7
c      write(6,*) "enter type of atten. relation, weight1, wtdist,
c     & weight2, mb to M conv."
c add three terms corresponding to ss-weight, reverse-weight, and normal-slip weight
c new dec 2005.
      read(1,*) iatten(ip,ia),wt(ip,ia,1),wtdist(ip,ia),wt(ip,ia,2),
     &  icode(ip,ia)
      write(6,*)'Attenuation index and wt ',iatten(ip,ia),wt(ip,ia,1)
c new AB06 from Oliver, also T&P, from Oliver Boyd
      ipia=iatten(ip,ia)
      ipiaa=abs(ipia)
      print *,ipia
c special period set for intraslab, includes 3s SA
c Toro & Frankel: if Vs30>=1500 call hardrock. Added this bit of override Mar 17 2008. SH.
c new Oct 31 2012: deal with new CEUS relations
      if(ipia.eq.29)then
      indx_pga=2;indx_pgv=1
c      ipbssa(1)=indx_pga
      k=1
      if(per.eq.-1.)then
      k=1
      print *,'BSSA 2013 relation called for PGV '
      elseif(per.eq.0.0)then
      k=2
      print *,'BSSA 2013 relation called for PGA '
      print *,' BSSA index for pga ',indx_pga
      else
      k=3
      dowhile(Perbssa13(k).ne.per.and.k.lt.107)
      k=k+1
      enddo
      if(k.eq.107.and.per.ne.10.)stop' Period not found for BSSA2013 relation.'
c      if(fix_sigma)sigt_gmpe=sigma_fx      !override table with fixed sigma jan 7 2012.
       nper_gmpe = 107
c      print *,nper_gmpe,' number of periods having coeffs BSSA'
      print *,per,Perbssa13(k),' BSSA period match? Index is ',k
      endif
      ipbssa(ip)=k
      endif	!ipia.eq.29
c
      if(ipia.eq.32)then
      if(readcb13)then
      if(per.gt.0.01)stop'CB13 must be called with PGA as first g.m.'
c      call cb12_nga_spec_in
      call cb13_nga_spec_in
      readcb13=.false.
      k=22
      else
      k=2
      dowhile (Percb13(k).ne.per.and.k.lt.23)
      k=k+1
      enddo
      if(k.eq.23.and.Percb13(k).ne.per)stop' Period not found for CB13 relation.'
      endif	!pga or other spectral accel?
      ipcb13(ip)=k
      print *,'CB13 relation period index ',k,' for period ',per
      endif	!ipia =34?
      if(ipiaa.ge.35.and.ipiaa.le.37)then
        kf=1
        if(per.gt.0.01)then
        fr=1.0/per
        elseif(per.ge.0.0)then
        fr=99.
        elseif(per.eq.-1)then
        fr=89.
        else
        print *,'period requested ',per
        stop' CEUS11 models close encounter with an unknown period'
        endif
        dowhile(fr.gt.a11fr(kf)+.01)
        kf=kf+1
        if(kf.gt.13)stop' period not in A06,A08,P11 set'
        enddo
        freq(ip)=a11fr(kf)
        ia08(ip)=kf
        print *,freq(ip),kf,' gail frequency'
      goto 1492
      endif	!new CEUS models.
      if(ipiaa.eq.12.or.ipiaa.eq.18)then
      ka=1
      okabs=.false.
      dowhile(abs(per-perabs(ka)).gt.0.002)
      ka=ka+1
        if(ka.gt.9)stop'ABsub slab called with unavailble period '
        enddo
        okabs=.true.
        slab=.true.
        jabs=ka
        elseif(ipiaa.eq.16.or.ipiaa.eq.17)then
c new July 14 2010, subduction or interface eqs & coeffs ABsub
      ka=1
      okabs=.false.
c perabu has one more period 0.4 s than perabs. 
      dowhile(abs(per-perabu(ka)).gt.0.002)
      ka=ka+1
        if(ka.gt.10)stop'ABsub subd. called with unavailble period '
        enddo
        okabs=.true.
        jabs=ka
        slab=.false.
c subduction events with ABsub. point source

       elseif(ipiaa.eq.13.or. ipiaa.eq.14)then
       ka=1
       okgeo=.false.
      dowhile(abs(per-pergeo(ka)).gt.0.002)
      ka=ka+1
        if(ka.gt.13)stop'Geomatrix-inslab called with unavailble period '
        enddo
        okgeo=.true.
        ipgeom(ip)=ka
c may also need the companion BA period index as of july 2009
         j=1
         dowhile(period(ip).ne.perb(j))
         j=j+1
         if(j.eq.24)stop 'period doesnt match BA siteamp period set for geom'
         enddo
         iperba(ip)=j
c add spectral periods for Geomatrix end of local mods. Nov 19 2008.
      elseif(ipiaa.eq.27.or.ipiaa.eq.28)then       
c add 13 spectral periods for Zhao et al. Begin local mods. Nov 20 2008.
       ka=1
       okzhao=.false.
      dowhile(abs(per-perzhao(ka)).gt.0.002)
      ka=ka+1
        if(ka.gt.13)stop'Zhao-inslab called with unavailble period '
        enddo
        okzhao=.true.
        jzhao=ka
c add 13 spectral periods for Zhao et al. end of local mods. Nov 20 2008.
      elseif(ipiaa.eq.2.and.vs30.ge.1500.)then
      ipia=-2
      iatten(ip,ia)=-2
      ceus=.true.
      ka=1
      dowhile(abs(per-perx_pl(ka)).gt.0.002)
      ka=ka+1
      if(ka.gt.9)then
      write(6,*)'7/2008: Input spectral period not available for Toro-mblg model'
      stop 'please remove Toro from the input file for this period'
      endif
      enddo
      iq=ka
      oktogo=.true.
      write(6,*)' Toro relation is called with hardrock coeffs., per index ',iq
      elseif(ipiaa.eq.6.and.vs30.ge.1500.)then
      ceus=.true.
      ipia=-6
      iatten(ip,ia)=-6
      ka=1
      dowhile(abs(per-perx_pl(ka)).gt.0.002)
      ka=ka+1
      if(ka.gt.9)then
      write(6,*)'Input spectral period not available for FEA model'
      stop 'please remove FEA from the input file for this period'
      endif
      enddo
      iq=ka
      oktogo=.true.
      write(6,*)'Frankel relation called with hardrock coeffs, A-like Vs30'
      write(6,*)' period index is ',iq,' in perx_pl'
      elseif(ipiaa.eq.10)then	!campbell ceus
      ka=1
      dowhile(abs(per-per_camp(ka)).gt.0.002)
c add several periods july 17 2008
      ka=ka+1
      if(ka.gt.11)then
      write(6,*)'Input spectral period not available for CampCEUS model'
      stop 'please remove CampCEUS from the input file for this period'
      endif
      enddo
      write(6,*)'period index in CampCEUS is ',ka
      iq=ka
      oktogo=.true.
      endif
c new AB06 from Oliver, also T&P, from Oliver Boyd
        if(ipiaa.eq.4.or.ipiaa.eq.20)then
          ka=1
          print *,per,abper(ka)
          dowhile(abs(per-abper(ka)).gt.0.002)
            ka=ka+1
            if(ka.gt.26)then
              write(6,*) ' Input spectral period doesnt correspond to A&B06 set'
              stop 'Please remove this relation from input file'
            endif
          enddo
          iperab(ip)=ka     
          write(6,*)ip,ka,' A&B 12/06 ip map, frequency= ',abfrq(ka)
          if(vs30.lt.1500..and.ipia.lt.0)write(6,808)vs30
          if(ipia.eq.20.and.vs30.ge.2000.)then
          irab(ip,ia)=4
          write(6,*)'AB06: use hardrock table.  Vs30>=2000 m/s.'
          elseif(ipia.eq.20)then
          irab(ip,ia)=3
          elseif(ipia.eq.-20.and.vs30.ge.1500.)then
          irab(ip,ia)=4
          ipia=20
          write(6,*)'AB06: use hardrock table because input says to do so and Vs30>=1500'
          elseif(ipia.eq.4.and.vs30.ge.2000.)then
          irab(ip,ia)=2
          write(6,*)'AB06 relation: use hardrock table when Vs30>=2000 m/s'
          iatten(ip,ia)=-4
      ceus=.true.
          ipia = -4
          elseif(ipia.eq.-4.and.vs30.lt.1500.)then
c below 1500 m/s not a gray area: must use the site term in AB06. However, compared to other
c CEUS atten models, Vs30 of 1400 m/s for example is far from BC boundary and has a neg S term.
          irab(ip,ia)=1
          ipia=4
          write(6,*)'AB06 relation: Code uses rock table with site (S) term when Vs30<1500m/s'        
      ceus=.true.
          endif
808      format('You have called hardrock version of AB06 even though vs30 is ',f6.1)   
        endif
        if(ipia.eq.19)then
      ceus=.true.
          ka=1
          dowhile(abs(per-tpper(ka)).gt.0.001)
            ka=ka+1
            if(ka.gt.16)then
              write(6,*) 'As of 7/08 input period doesnt correspond to T&P05 set'
              stop 'Please remove this relation from input file'
            endif
          enddo
      if(vs30.gt.1500.)then
      irtb=-1
      else
      irtb=1
      endif
          ipertp(ip)=ka
          write(6,*)ip,ka,' T&P 9/06 ip map'
        elseif(ipia.eq.15)then
       ceus=.true.
         ka=1
          dowhile(per.ne.pdSilva(ka))
            ka=ka+1
            if(ka.gt.11)then
              write(6,*) 'As of 7/2008 input period doesnt correspond to Silva2002 set'
              stop 'Sugg: remove this relation from input file for this period'
            endif
          enddo
          isilva(ip)=ka
          write(6,*)ip,ka,' Silva 7/2008 ip map'
          if(vs30.ge.1500.)then
          irsilva=-1
          else
          irsilva=1
          endif
            endif
 1492      continue
       if(ceus.and.icode(ip,ia).eq.1.and.iflt.ne.3)then
       write(6,*)'Inconsistent icode and iflt for Johnston',ipia
        elseif(ceus.and.icode(ip,ia).eq.2.and.iflt.ne.4)then
        write(6,*)'Inconsistent icode and iflt for AB conversion',ipia
        endif
       if(ipia.ge.35.and.ipia.le.37)then
c 2011 CEUS relations
      if(ipia.eq.35)then
      print *,magmin,dmag,ip,iq,ia,freq(ip)
      call getA08p(ip,iq,freq(ip),ia,ndist,di,nmag,magmin,dmag)
      ceus=.true.
      elseif(ipia.eq.36)then
      call getAB06p(ip,iq,freq(ip),ia,ndist,di,nmag,magmin,dmag)
      ceus=.true.
      else
      call getPez11(ip,iq,freq(ip),ia,ndist,di,nmag,magmin,dmag)
      ceus=.true.
      endif
       elseif(ipia.eq.1.and.oktogo)then 
       call getSpu2000(ip,iq,ia,ndist,di,nmag,magmin,dmag,sigmanf,distnf)
       write(6,*)'spudich atten. for extensional region  has been set up'
      elseif(ipia.eq.2.and.oktogo)then 
      ceus=.true.
      if(ntor.gt.1 .and. deagg)stop'hazgridXnga13l: ceus deagg set up for 1 depth'
       call getToro(ip,iq,1,ia,ndist,di,nmag,magmin,dmag,sigmanf,distnf)
      write(6,*)'Toro CEUS, firm rock (BC) set up'
      elseif(ipia.eq.-2.and.oktogo)then 
      if(ntor.gt.1 .and. deagg)stop'hazgridXnga13l: ceus deagg set up for 1 depth'
       call getToro(ip,iq,2,ia,ndist,di,nmag,magmin,dmag,sigmanf,distnf)
      write(6,*)'Toro CEUS, hard rock set up'
      elseif(ipia.eq.3.and.oktogo)then 
c Sadigh rock, WUS relation of 1997
      call getSadighR(ip,iq,ia,ndist,di,nmag,magmin,dmag,
     &  sigmanf,distnf)
       write(6,*)'Sadigh rock subroutine setup OK'
      elseif(ipia.eq.-3.and.oktogo)then 
c Put soil formulation in separate subroutine.
      call getSadighS(ip,iq,ia,ndist,di,nmag,magmin,dmag,
     &  sigmanf,distnf)
       write(6,*)'Sadigh soil subroutine setup OK'
       endif
      if(ipia.eq.6.and.oktogo) then
      call getFEA(ip,iq,1,ia,ndist,di,nmag,magmin,dmag,sigmanf,distnf)
      ceus=.true.
      write(6,*)'getfea w/F-BC table was called  setup OK.'
      elseif(ipia.eq.5.and.oktogo) then
      call getFEA(ip,iq,2,ia,ndist,di,nmag,magmin,dmag,sigmanf,distnf)
      ceus=.true.
      write(6,*)'getfea w/AB95 BC table was called  setup OK.'
      elseif(ipia.eq.-6.and.oktogo) then
       ceus=.true.
      call getFEA(ip,iq,3,ia,ndist,di,nmag,magmin,dmag,sigmanf,distnf)
      write(6,*)'getfea w/FEA HR table was called  setup OK.'
      elseif(ipia.eq.-5.and.oktogo) then
      call getFEA(ip,iq,4,ia,ndist,di,nmag,magmin,dmag,sigmanf,distnf)
      ceus=.true.
      write(6,*)'getfea w/AB95 HR table was called  setup OK.'
      elseif(ipia.eq.4)then
      if(ntor.gt.1 .and. deagg)stop'hazgridXnga13l: ceus deagg set up for 1 depth'
      ceus=.true.
      call getAB06(ip,iperab(ip),1,ia,ndist,di,nmag,magmin,dmag)
      write(6,*)'getAB06 w/BC coeffs & 140bs setup Ok'
      elseif(ipia.eq.20)then
      ceus=.true.
      call getAB06(ip,iperab(ip),irab(ip,ia),ia,ndist,di,nmag,magmin,dmag)
      write(6,*)'getAB06  with 200 bar stress setup Ok'
      elseif(ipia.eq.-4)then
      ceus=.true.
      call getAB06(ip,iperab(ip),2,ia,ndist,di,nmag,magmin,dmag)
      write(6,*)'getAB06 w/HR coeffs was called'
      elseif(ipia.eq.19)then
      ceus=.true.
      call getTP05(ip,ipertp(ip),ia,ndist,di,nmag,magmin,dmag)
       write(6,*)'Tavakoli 2005 CEUS subroutine setup OK'
      elseif(ipia.eq.15)then
      if(ntor.gt.1 .and. deagg)stop'hazgridXnga13l: ceus deagg set up for 1 depth'
      ceus=.true.
      call getSilva(ip,isilva(ip),irsilva,ia,ndist,di,nmag,magmin,dmag)
       write(6,*)'Silva 2002 CEUS subroutine setup OK'
      elseif(ipia.eq.7.and.oktogo) then
      ceus=.true.
      call getSomer(ip,iq,1,ia,ndist,di,nmag,magmin,dmag,sigmanf,distnf)
      write(6,*)'Somerville BC model called finite CEUS fault hazard'
      elseif(ipia.eq.-7.and.oktogo) then
       ceus=.true.
      call getSomer(ip,iq,2,ia,ndist,di,nmag,magmin,dmag,sigmanf,distnf)
      write(6,*)'Somerville HR model called finite CEUS fault hazard'
      elseif (ipia.eq.8.and.oktogo) then
       call getAS97(ip,iq,ia,ndist,di,nmag,magmin,dmag,sigmanf,distnf)    
      elseif(ipia.eq.9.and.oktogo) then
      wus=.true.
      call getCamp2003(ip,iq,ia,ndist,di,nmag,magmin,dmag,sigmanf,distnf) 
      write(6,*)'Camp&Bozorgnia 2003 WUS attenuation set up OK'   
      elseif(ipia.eq.10.and.oktogo)then
      call getCampCEUS(ip,iq,1,ia,ndist,di,nmag,magmin,dmag, sigmanf,distnf)
      ceus=.true.
      write(6,*)'Campbell CEUS hybrid attenuation firmrock setup complete'
      elseif(ipia.eq.-10.and.oktogo)then
      call getCampCEUS(ip,iq,2,ia,ndist,di,nmag,magmin,dmag, sigmanf,distnf)
      write(6,*)'Campbell CEUS hybrid attenuation HR site setup complete'
      ceus=.true.
      elseif(ipia.eq.11.and.oktogo) then
      call getBJF97(ip,iq,ia,ndist,di,nmag,magmin,dmag,sigmanf,distnf)
       elseif((ipiaa.eq.12..or.ipiaa.eq.16).and.okabs)then
       if(vs30.lt.190.)then
       ir = 4
       write(6,*)'AB PNW DE or E-soil called, seism. at ',dtor(1:ntor),' km'
       elseif (vs30.lt.360.)then
       ir = 3
       write(6,*)'AB PNW  D-soil called, seism. at ',dtor(1:ntor),' km'
       elseif(vs30.lt.660.)then 
       ir = 2
       write(6,*)'AB PNW  C-soil called, seism. at ',dtor(1:ntor),' km'
      elseif(vs30.le.780.)then
      ir=1
       write(6,*)'AB PNW BC-rock called, seism. at ',dtor(1:ntor),' km'
      else
      ir=0
       write(6,*)'AB PNW benioff B rock called, seism. at ',dtor(1:ntor),' km'
      endif
       call getABsub(ip,jabs,ir,slab,ia,ndist,di,nmag,magmin,dmag,vs30)
c  getABsub for world data set, gets new index, 17 (subd) or 18 (slab). 
       elseif(ipiaa.eq.17.or.ipiaa.eq.18.and.okabs)then
      if(vs30.gt.780.)then
      ir = 5
       write(6,*)'AB World  B-rock called, seism. at ',dtor(1:ntor),' km'
      elseif(vs30.gt.660.)then
       write(6,*)'AB World  BC rock called, seism. at ',dtor(1:ntor),' km'
      ir  = 6
      elseif(vs30.gt.360.)then
        ir = 7
       write(6,*)'AB World  C-soil called, seism. at ',dtor(1:ntor),' km'
       elseif(vs30.gt.190.)then
       ir=8
       write(6,*)'AB World  D-soil called, seism. at ',dtor(1:ntor),' km'
       else
       ir=9
       write(6,*)'AB World  DE or E-soil called, seism. at ',dtor(1:ntor),' km'
       endif
       call getABsub(ip,jabs,ir,slab,ia,ndist,di,nmag,magmin,dmag,vs30)
      elseif(ipia.eq.13.and.okgeo)then
      slab=.true.
      if(vs30.ge.520.)then
      ir=1
      else
c use transition coeffs between 400 and 550. New july 2009. Trashed. what are
c those transition coeffs? not linear interpolations that is for certain.
      ir=2
      endif
c use soil coeffs as starting case if vs30<520 m/s. Modify siteamp from there.
      call getGeom(ip,ir,ia,slab,ndist,di,nmag,magmin,dmag,vs30)
       write(6,*)'Geomatrix intraslab relation for rock, seism. at ',dtor(1:ntor),' km'
      elseif(ipia.eq.14.and.okgeo)then
      slab=.false.
      if(vs30.ge.520.)then
      ir=1
      else
c use transition coeffs between 400 and 550. New july 2009. Trashed. what are
c those transition coeffs? not linear interpolations that is for certain.
      ir=2
      endif
c use soil coeffs as starting case if vs30<520 m/s. Modify siteamp from there.
      call getGeom(ip,ir,ia,slab,ndist,di,nmag,magmin,dmag,vs30)
       write(6,*)'Geomatrix interplate relation for rock, seism. at ',dtor(1:ntor),' km'
      elseif(ipia.eq.-13.and.okgeo)then
       slab=.true.
      if(vs30.ge.520.)then
      ir=1
      else
      ir=2
      endif
      call getGeom(ip,ir,ia,slab,ndist,di,nmag,magmin,dmag,vs30)
       write(6,*)'Geomatrix intraslab relation for soil, seism. at ',dtor(1:ntor),' km'
      elseif(ipia.eq.27.and.okzhao)then
      slab=.true.
c the 1 below is a slab flag: inslab source if this is 1.
      call zhao(ip,jzhao,1,ia,ndist,di,nmag,magmin,dmag)
       write(6,*)'Zhao intraslab relation for rock, seism. at ',dtor(1:ntor),' km'
      elseif(ipia.eq.28.and.okzhao)then
      slab=.false.
c the 0 below is a subduction flag: 
      call zhao(ip,jzhao,0,ia,ndist,di,nmag,magmin,dmag)
       write(6,*)'Zhao interface relation for rock, seism. at ',dtor(1:ntor),' km'
      elseif(ipia.eq.41.and.oktogo)then
       call getMota(ip,iq,ia,ndist,di,nmag,magmin,dmag,sigmanf,distnf)
       write(6,*)'Mota&Atkinson PRVI atten-relation table set up.'
       endif
c Next set, with index>20: NGA relations 2008. OR NGAW 2012. Or ...
c compute median etc. otherwise use computed value      

        if(ipia.eq.21) then
      wus=.true.
      k=1
c boore-atkinson: 23 periods april 2007.
      dowhile(period(ip).ne.perb(k).and.k.lt.24)
      k=k+1
      if(k.eq.24)then
      write(6,*) period(ip),' This period not part of BA-NGA available set'
      stop 'Please remove BA (atten. model 21) from analysis at this period'
      endif
      enddo
      ib=k
c  Found spectral period  for B&A NGA model. Build the Pex table.
      call getBooreNGA308(ip,ib,ia,ndist,di,nmag,magmin,dmag,sigmanf,distnf)
       elseif(ipia.eq.29)then
c index 29 redefined to correspond to the new Boore et al GMPE for WUS (NGA-W2)(2012). Dec 2012.
      indx1=ipbssa(ip)
c      v30ref = 760.      !
      print *,'calling bssa13 with indx, v30 = ',indx1,vs30,' spectral 
     * period ',period(ip)
      call bssa2013drv( ip,indx1, ia,ndist,di,nmag,magmin,dmag,vs30,z1_ref)
             elseif(ipia.eq.22) then
      icb=1
c Determine index of period in the campbell set, camper.
      wus=.true.
      dowhile(camper(icb).ne.period(ip))
      icb=icb+1
      if(icb.gt.24)stop'period not in CB 11-07 set'
      enddo
      if(icb.eq.24)write(6,*)'CB-NGA: Peak displacement called, 11-07 
     * model'
        call getCampNGA1107 
     + (ip,icb,ia,ndist,di,nmag,magmin,dmag,sigmanf,distnf)
c below added mar 6 2008 from email comment by Ken Campbell
       if(vs30.gt.1500.)stop 'Vs30 >1500 m/s and CB NGA relation does not permit this.'   
         elseif(ipia.eq.32) then
         if(icode(ip,ia).lt.0)then
         icode(ip,ia)=-icode(ip,ia)
         rxfac=-1.
         else
         rxfac=1.0
         endif
         DIP=dipbck(icode(ip,ia))
          SJ=0.      !SJ 0 if not in Japan.
          if(iflt.eq.1.or.iflt.eq.10)then
          print *,'Random-strike fault dip (d): ',DIP
          elseif(iflt.eq.2.or.iflt.eq.20)then
          print *,'Fixed-strike fault dip (d): ',DIP
          endif
      call CB13_NGA_SPEC  (ip,ipcb13(ip),ia,ndist,di,nmag,magmin,dmag,DIP,SJ,rxfac)
c below added from email comment by Ken Campbell mar 6 2008 Does this remain true in 2013 update?
       if(vs30.gt.1500.)stop 'Vs30 >1500 m/s and CB NGA relation does not permit this.'   
         elseif(ipia.eq.23) then
      icy=1
      wus=.true.
c which of the 106 is it anyway?
      dowhile(prd(icy).ne.period(ip))
      icy=icy+1
      if(icy.gt.106)stop'Spectral period not in CY 3-2008+ set'
      enddo
      call CY2007I(ip,icy,vs30,Z1)
      call CY2007H(ip,icy,ia,ndist,di,nmag,magmin,dmag)
c      do k=1,15
c      write(6,*)pr(1,2,k,ip),period(ip)
c      enddo
      elseif(ipia.eq.24)then
c AS  2008 with updates coded Mar 15 2013. SH.
      iq_as=1
      dowhile (aperiod(iq_as).ne.period(ip).and.iq_as.lt.108)
      iq_as=iq_as+1
      enddo
      if(aperiod(iq_as).ne.period(ip))stop'period not in AS-2008 set'
      wus=.true.
      write(6,*)'A&S period ',aperiod(iq_as),' index ',iq_as
         if(icode(ip,ia).lt.0)then
         icode(ip,ia)=-icode(ip,ia)
         rxfac=-1.
         else
         rxfac=1.0
         endif
         DIP=dipbck(icode(ip,ia))
         vs30_class =1      !use measured.
      call ASNGA08
     + (ip,iq_as,ia,ndist,di,nmag,magmin,dmag,vs30_class,z1km,rxfac,DIP)
      elseif(ipia.eq.33)then
c CY2013 index is 33.
         if(icode(ip,ia).lt.0)then
         icode(ip,ia)=-icode(ip,ia)
         rxfac=-1.
         else
         rxfac=1.0
         endif
         DIP=dipbck(icode(ip,ia))
c      if(per.eq.-1.)then
c       iper(ip)=1
c       k=1
c      write(6,*)'Calling CY2013 NGA-W with period index 1: PGV'
c      elseif(per.eq.-2.)then
c       iper(ip)=2
c       k=2
c      write(6,*)'Calling CY2013 NGA-W with period index 2: PGD'
      if (per.ge.0..and. per.le.0.01)then
      iper(ip)=1	!PGA index is 3 in Mar 2013 update
      k=1	!PGA index is 3 in Mar 2013 update
      write(6,*)'Calling CY2013 NGA-W with period index 1: PGA'
      else
      k=2
      dowhile(percy13(k).ne.per.and.k.lt.22)
      k=k+1
      enddo
      if(abs(percy13(k)-per).gt.0.002)stop'period not available for CY2013 GMPE'
      write(6,*)'Calling CY2013 NGA-W revision with deltaz1=',deltaz1
      write(6,*)'Calling CY2013 NGA-W with period index ',k
      iper(ip) = k
c CHECK HERE
      endif	!pga or other?
      write(6,*)'Calling CY2013 model for period ',period(ip),' icode ',icode(ip,ia)
c        call CY2013_NGA(ip,iper(ip),ia,ndist,di,nmag,magmin,dmag,DIP,deltaz1,vs30,rxfac )
        call CY2013_NGA(ip,k,ia,ndist,di,nmag,magmin,dmag,DIP,deltaz1,vs30,rxfac )
      elseif(ipia.eq.39)then
      if (period(ip).lt.0.01)then
      ipgk=0
      else
      k=1
      dowhile(pdgk(k).ne.period(ip))
      k=k+1
      if(k.gt.35)stop' Graizer Kalkan model does not have this pd'
      enddo
      endif	!periods for gk
      ipgk=k
      wus=.true.
      if(rx.lt.-120. .and. ry.gt.39.)then
      Q=156.6	!california Q
      elseif(ry.le.39.0 - 0.8*(rx+120.))then
      Q=156.6 	!more      california Q
       else
      Q=205.	!GK 13 update for basin and range outside CA
      endif
c keep Bdepth very shallow for rock sites. new 4/4/2013.
	if(vs30.ge.600.)then
	 Bdepth=1.1*z1km
	else
         Bdepth=0.75 * z1km + 0.25*dbasin      !Vladimir says his basin is 1.5 km/s isosurface. Campbell is
	endif
      print *,'Calling gksa13v2 with basin depth ',Bdepth,' Q ',Q
      call gksa13v2(ip,ipgk,ia,ndist,di,nmag,magmin,dmag,vs30,Bdepth,Q)	
      elseif(ipia.eq.34)then
         if(icode(ip,ia).lt.0)then
         icode(ip,ia)=-icode(ip,ia)
         rxfac=-1.
         else
         rxfac=1.0
         endif
         DIP=dipbck(icode(ip,ia))
        vs30_rock = 1100.
        z10_rock = 0.006
        useRy0=.false.
        hardrock=.true.
        if(period(ip).le.0.01)then
        iper(ip)=1
        k=1
        else
        k=2
        dowhile(peras13(k).ne.period(ip))
        k=k+1
        if(k.gt.22)stop'period not found in AS2013'
        enddo
      iper(ip)=k
      endif
      wus=.true.
      write(6,*)'Calling AS2013 model for period ',period(ip),' dip ',DIP,' rxfac ',rxfac
c      call AS2012_v2_model (ip,iper,ia,ndist,di,nmag,magmin,dmag,DIP,z10_rock,useRy0,vs30_rock,hardrock,rxfac)
c      call AS2013_v10_model (ip,iper,ia,ndist,di,nmag,magmin,dmag,DIP,z10_rock,useRy0,vs30_rock,hardrock,rxfac)
      call AS2013_v10_model (ip,k,ia,ndist,di,nmag,magmin,dmag,DIP,z10_rock,useRy0,vs30_rock,hardrock,rxfac)
      hardrock=.false.
c      call AS2012_v2_model (ip,iper,ia,ndist,di,nmag,magmin,dmag,DIP,z1,useRy0,vs30,hardrock,rxfac)
c      call AS2013_v10_model (ip,iper,ia,ndist,di,nmag,magmin,dmag,DIP,z1,useRy0,vs30,hardrock,rxfac)
      call AS2013_v10_model (ip,k,ia,ndist,di,nmag,magmin,dmag,DIP,z1,useRy0,vs30,hardrock,rxfac)
      elseif(ipia.eq.38)then
        if(period(ip).le.0.01)then
        iper(ip)=1
        k=1
        else
        k=2
        dowhile(perId12(k).ne.period(ip))
        k=k+1
        if(k.gt.22)stop'period not found in Idr2013'
        enddo
        print *,'Calling Idriss-2013 GMPE for period ',period(ip)
      iper(ip)=k
      endif
      wus=.true.
c      call Idriss2013(iper,ip,ia,ndist,di,nmag,magmin,dmag,vs30)	
      call Idriss2013(k,ip,ia,ndist,di,nmag,magmin,dmag,vs30)	
      elseif(ipia.eq.25)then
      wus=.true.
      call getIdriss 
     + (ip,iq,ia,ndist,di,nmag,magmin,dmag,sigmanf,distnf)
      elseif(ipia.eq.26)then
      iq_ka=0
      dowhile (perka(iq_ka).ne.period(ip))
      iq_ka=iq_ka+1
      if(iq_ka.gt.37)stop'period not in Kanno set'
      enddo
      write(6,*)'Kanno period ',perka(iq_ka),' index ',iq_ka
      call kanno(ip,iq_ka,ia,ndist,di,nmag,magmin,dmag,sigmanf,distnf)
      wus=.true.
      print *,'Warning: kanno relation has comparatively high ale. sigma, 1/09'	
      elseif(ipia.eq.31)then
c new BCHydro for intraplate
      if(period(ip).le.0.022)then
      iq_naa=1
      else
      iq_naa=2
      dowhile (period(ip).ne.NAAper(iq_naa))
      iq_naa=iq_naa+1
      if(iq_naa.gt.22)stop 'period not in BCHydro set'
      enddo
      endif	!assign period index
      slab=.true.
c the 1,0 below are Fevnt=1 for inslab. 0 for backarc. the final 2 is delCi central 
c branch for the median
      print *,'BCHydro inslab model for period ',NAAper(iq_naa)
      call getNAAsub(ip,iq_naa,ia,1,0,ndist,di,nmag,magmin,dmag,2)
      elseif(ipia.ge.38)then
c GMPE index 28 became active July 12 2010. Zhao interface (may be used for
c America Samoa Oceanic Sources NSHMP PSHA work. To be determined later).
c GMPE index 29 is now Motazetti and Atkinson for PRVI work.
c GMPE index 
      write(6,*)'not ready for this atten model index',iatten(ip,ia)
      stop' hazgridXnga13l: Please confine atten index to -10 min to 37 max'
      endif
 701  continue
 700  continue
c---- write header --------------
c Header record should have more data. Current constraint for historical compatibility.
      do 291 ip=1,nper
      headr%name(1)= namein
      headr%name(2)= date//' at '//time	
c      if(ip.eq.1)headr%name(3)= pname      !program
c save some input information in available header.name() spots.
      write(pname,708)(nint(dtor(j)),wtor(j),j=1,ntor)
      headr%name(4) =pname
708      format('Dtor:',3(i2,',',f4.2,';'))
      iam=min(nattn(ip),5)
      write(pname,709)(iatten(ip,ia),ia=1,iam)
      headr%name(5) =pname
709      format('AttnIndx:',5(i3,';'))
      l=min(5,nattn(ip))
      write(pname,719)(wt(ip,ia,1),ia=1,l)
      headr%name(6) =pname
719      format('Attn_Wt:',5(f4.2,';'))
c 
      headr%period= period(ip)
      headr%nlev= nlev(ip)
      do 702 k=1,nlev(ip)
 702  headr%xlev(k)= exp(xlev(k,ip))
c 30 character name
c      ndata= 308
c 128 character name
      ndata= 896
c      headr%extra(1)= cyr
c cant store cyr in extra(1) any longer. Is this needed? SH Feb 22 2013. Positive extra(1) is
c an indicator to downstream programs that SDI rather than SA is what to expect.
c
      if(sdi)then
      headr%extra(1)=dy_sdi
      else
      headr%extra(1)=-1.
      endif
      headr%extra(2)=xmin
      headr%extra(3)=xmax
      headr%extra(4)=dx
      headr%extra(5)=ymin
      headr%extra(6)=ymax
      headr%extra(7)=dy
      headr%extra(8)=float(nrec)
      headr%extra(9)=vs30
      headr%extra(10)=dbasin      !bookkeeping
      if(grid)then
      do ifn = 1,nfi
      headr%name(3)='hazgridXnga13l '//pithy(ifn)
      call puthead(ifp(ip,ifn),headr,ndata,readn)
      enddo	!ifn
      endif
 291  continue
c
c---loop through receiver sites
      m=min(1000,nrec)
      prob=1.e-21	!matrix math allowed. Initialize with small.
c----- uses Wells and Coppersmith relation to get length from moment mag.
c         arg= (xmag-5.08)/1.16
       do 37 i=1,nmagmax
         xmag= xmw(i)      !use the array of moment mag. new oct 2009.
         arg= -3.22+0.69*xmag
         xlen= 10**arg*0.5
         xlen2(i)= xlen
c compute a width of dipping fault, with dip dipf, half length or base of brittle.
      dipf = 50.*d2r
         xwide(i)=min(xlen,(15.-dtor(1))/sin(dipf))
c xlim is maximum distance from point above top of fault for which Rrup is computed
c by dropping a perp. not currently used.
c         xlim(i)=xwide(i)/cos(dipf) + dtor(1)*tan(dipf)
c xwide(i) is max distance at which Rjb is zero (hw on)        
         xwide(i)=xwide(i)*cos(dipf)
  37     continue
c The flush subroutine dumps buffered print material. Gfortran OK with subr. not with function.
        call flush(6)
c If flush works for your computer, you can look at log file before the big grid gets underway.
c---Here's the guts
      icnt=1
      do 100 i=1,nrec
       asum= 0.0	!matrix math
      if(grid)then
      iy= (i-1)/nx 
      ix= i-1-iy*nx
c      write(6,*) i,ix,iy
c      read(5,*) idum
      rx= xmin+float(ix)*dx
      ry= ymax-float(iy)*dy
c      write(6,*)rx,ry,i
            else
            rx=slong(i)
            ry=slat(i)
            write(6,*)'Computing seismic hazard for ',sname(i)
            endif
      if(v30a)then
c find nearest gridpoint in vs30 array to the site with coords rx,ry
      if(rx.gt.vxmax.or.rx.lt.vxmin.or.ry.gt.vymax.or.ry.lt.vymin)then
      vs30=vs30dflt
      else
      ivx=1+nint((rx-vxmin)/vdx)	
      ivy=nint((vymax-ry)/vdy)	!same organization as we are used to.
      vs30=v30(nvx*ivy+ivx)
      endif	!inbounds
      endif	!array rather than scalar vs30	This doesn't do anything for gridded,
c which precomputed median motions and probabilities based on a fixed Vs30. In the future
c site-specific Vs30 may be useful.
      if(byeca.and.ry.gt.43.9)goto 860
      if(byesoc.and.ry.gt.38.9)goto 860
      if(byeext.and.ry.lt.37.5.and.rx.lt.-122.)goto 860
      if(byepug.and.(ry.lt.42..or.rx.gt.-116.))goto 860
c-- loop through source cells
c-- bin rate by distance and magnitude (asum)
      do 101 j=1,nsrc
      if(a(j).eq.0.) go to 101
      isy= (j-1)/nsx
      isx= j-1-isy*nsx
      sx= xsmin+float(isx)*dsx
      if(pnw_deep)then
      kksrc=1
      dowhile(sx.gt.w_edge(kksrc).and.kksrc.lt.ntor)
      kksrc=kksrc+1
      enddo
      endif	!special index for pacnw deep 5/02/2013. Needs to be generalized.
      sy= ysmax-float(isy)*dsy
      dlen= 1.
      xdiff= abs(sx-rx)
      ydiff= abs(sy-ry)
      xdmax= dmax/(111.11*cos(ymax*coef))
      ydmax= dmax/111.11
c      print *,xdiff,ydiff
      if((xdiff.gt.xdmax).or.(ydiff.gt.ydmax)) go to 101
      call delaz(sy,sx,ry,rx,dist,az,baz)
c Point-source dmax is used to decide finite-fault inclusion as well, even
c though finite faults (i.e., those with M>=6) will tend to be closer to the site <rx,ry>.
      if(dist.gt.dmax) go to 101
c use Rjb for distance index. We also have an index for dtor.
c
      idist= dist/di +1
      dcen= di*idist - di2
      frac=(dist-dcen)/di       !fractional error, always < 0.5 in abs. val.
      if(frac.lt.0.)then
      ifrac=max(1,idist-1)
      wt2=-frac
      wt1=1.-wt2
      else
      ifrac=idist+1
      wt2= frac
      wt1=1.-wt2
      endif
      if(m_zones)then
      wt_mask(1:40)=wt_zone(1:40,mzone(j))
      elseif(craton(j))then
         wt_mask(1:40)=wt_cra
        elseif(margin(j))then
        wt_mask(1:40)=wt_marg
        endif
             do m=1,nmagmax
      xmag= xmw(m)      !use the array of moment mag.
c point source calc based on moment mag being < 6.
      if((xmag.lt.6.0).or..not.finite) then
c point-source summation
	if(pnw_deep)then
         asum(m,idist,kksrc)= asum(m,idist,kksrc) + arate(j,m)*wt1
         asum(m,ifrac,kksrc)= asum(m,ifrac,kksrc) + arate(j,m)*wt2
	else
      do kk=1,ntor
      if(xmag.lt.6.5)then
         asum(m,idist,kk)= asum(m,idist,kk) + arate(j,m)*wtor(kk)*wt_mask(m)*wt1
         asum(m,ifrac,kk)= asum(m,ifrac,kk) + arate(j,m)*wtor(kk)*wt_mask(m)*wt2
          else
         asum(m,idist,kk)= asum(m,idist,kk) + arate(j,m)*wtor65(kk)*wt_mask(m)*wt1
         asum(m,ifrac,kk)= asum(m,ifrac,kk) + arate(j,m)*wtor65(kk)*wt_mask(m)*wt2
         endif
         enddo      !top of rupture kk index
         endif	!pnw_deep?
      else      !finite fault follows
      if(iflt.eq.1.or.iflt.gt.2.and.iflt.lt.15)then
c new apr 30 2008: use 2D rjbmean array to speed up runs. 8.55 is moment-mag
c limit and 26 is Mmax index.
      irjb=dist/dr_rjb+1
        m_ind= 1 + max(0,nint((xmag-xmmin_rjb)/dm_rjb))
      m_ind= min(26,m_ind)
      dmin2 = rjbmean(m_ind,irjb)
c      write(6,*)xmag,dmin2,sx,sy,m_ind
      else
c fixed-strike: use Frankel code for vertical plane. Index 20 is also fixed strike.
      if(iflt.eq.-2)then
c fltstrk is already in radian units.
      daz= coef*az - fltstrk(j)
      else
         daz= coef*(az-fltstr)
         endif
         sdist= abs(dist*sin(daz))
         cdist= abs(dist*cos(daz))
         if(cdist.le.xlen2(m)) then
          dmin2= sdist
         else
         dmin2= sqrt(sdist*sdist +(cdist-xlen2(m))**2)
         endif
         endif
c dmin2 was calculated for a vertical-dip fault. if fault dips away from site,
c dmin2 is still correct. However, if fault dips towards site, dmin2 can be
c less or more depending on aspect ratio, dip, other fault geom details.         
         if(dmin2.le.dmax) then
      idist=dmin2/di + 1
      dcen= di*idist - di2
      frac=(dmin2-dcen)/di      !fractional error, always < 0.5 in abs. val.
      if(frac.lt.0.)then
      ifrac=max(1,idist-1)
      wt2=-frac
      wt1=1.-wt2
      else
      ifrac=idist+1
      wt2= frac
      wt1=1.-wt2
      endif
c Rjb is distance. Different weights to different depths & M applied here
	if(pnw_deep)then
c only one depth per source location if deep.
         asum(m,idist,kksrc)= asum(m,idist,kksrc) + arate(j,m)*wt1
         asum(m,ifrac,kksrc)= asum(m,ifrac,kksrc) + arate(j,m)*wt2
         else
         do kk=1,ntor
         if(xmag.lt.6.5)then
         asum(m,idist,kk)= asum(m,idist,kk) + arate(j,m)*wtor(kk)*wt_mask(m)*wt1
         asum(m,ifrac,kk)= asum(m,ifrac,kk) + arate(j,m)*wtor(kk)*wt_mask(m)*wt2
         else
         asum(m,idist,kk)= asum(m,idist,kk) + arate(j,m)*wtor65(kk)*wt_mask(m)*wt1
         asum(m,ifrac,kk)= asum(m,ifrac,kk) + arate(j,m)*wtor65(kk)*wt_mask(m)*wt2
         endif
         enddo		!kk sum
         endif		!pnw_deep?
         endif      !close enough to add rate
         endif      !finite fault
c 111  continue
      enddo
 101  continue
c
      do 203 kk=1,ntor
      depth=dtor(kk)
      do 203 ii=1,ndist
      if(deagg)then
      r=(ii-0.5)*di
        if(r.le.100.)then
        ir=0.1*r + 1
        elseif(r.le.300.)then
        ir=11+(r-100.)*0.02
        elseif(r.le.500.)then
c for CEUS more annuli may be required. Use one annulus R>500.
        ir=15
        else
        ir=16
        endif
        hdist=sqrt(r**2+depth**2)
c may want to compute avg hypocentral distance, rbar
c
      endif	!deagg? 
      do 203 m=1,nmagmax
      asumm=asum(m,ii,kk)
      if(asumm.le.0.)goto 203
      if(deagg)then
      xmag0=xmw(m)
c 
c USGS prefers moment magnitude
c In WUS, rates are wrt Mw, and no conversion is needed.      
c because of the mbLg to Mw conversion, xmag < 5.0 may occur.      
           im=min(40,int((xmag-rmagmin)/dmbin) +1)
c           if(im.gt.15)print *,ir,im,xmag,asumm
      endif      !deagg 
      do 202 ifn=1,nfi
      do 202 ip=1,nper
      if(deagg)then
c one ground-motion level for deagg work, i.e., k=1.
       fac=pr(ii,m,1,ip,kk,ifn)*asumm
        hbin(ir,im,ip,kk,ifn)=fac+hbin(ir,im,ip,kk,ifn)
      mbar(ir,im,ip,kk,ifn)=mbar(ir,im,ip,kk,ifn)+xmag*fac
      rbar(ir,im,ip,kk,ifn)=rbar(ir,im,ip,kk,ifn)+hdist*fac
      if(wus)then
      ebar(ir,im,ip,kk,ifn)=ebar(ir,im,ip,kk,ifn)+e0_wus(ii,m,ip,kk,ifn)*asumm
      elseif(ceus)then
c kk = 1 and ifn = 1 for ceus.
      ebar(ir,im,ip,kk,ifn)=ebar(ir,im,ip,kk,ifn)+e0_ceus(ii,m,ip)*asumm
      elseif(slab)then
c kk is probably 1 and ifn = 1 for intraslab. kk or depth could vary but it doesn't USGS.
c For some countries we have run separate depths with different infiles (50 100 150 km etc) 
      ebar(ir,im,ip,kk,ifn)=ebar(ir,im,ip,kk,ifn)+e0_sub(ii,m,ip,kk)*asumm
      endif
      endif
      do k=1,nlev(ip)
       prob(icnt,k,ip,ifn)=prob(icnt,k,ip,ifn)+pr(ii,m,k,ip,kk,ifn)*asumm
       enddo
 202      continue
 203      continue
 860      continue
cc-- output hazard curves every 1000 sites
      if(grid.and.(icnt.eq.1000.or.i.eq.nrec)) then
c        write(6,*) i,prob(icnt,1,1,1)
        iend= 1000
        if(i.eq.nrec) iend=icnt
      do 115 ifn=1,nfi	!new jan 2007
c it is necessary to keep the above loop dominant here.
        do 115 ip=1,nper
        ndata= iend*nlev(ip)
        do 50 ii=1,ndata
        i2= ii-1
        irec= i2/nlev(ip)
        ilev= i2-irec*nlev(ip)
        irec= irec+1
        ilev= ilev+1
        out(ii)= prob(irec,ilev,ip,ifn)
   50   continue
        call putbufx(ifp(ip,ifn),out,ndata,readn)
        if(ifn.eq.1)write(6,*) i,out(ndata-10),period(ip)
 115    continue
        icnt= 0
         prob= 1.e-21      !matrix reset
       elseif(.not.grid)then	!list, output station data every time
67      format('#Station lat/long ',f8.4,1x,f10.4,1x,a,' vs30 ',f6.1)  
2468    format('#Spectral period ',f6.3,' nlev ',i2,' epistemic: ',a12)
      do 215 ip=1,nper
       write(9+ip,67)slat(i),slong(i),sname(i),vs30
       if(deagg)write(20+ip,67)slat(i),slong(i),sname(i),vs30
      do ifn=1,nfi
      write(9+ip,2468) period(ip), nlev(ip),pithy(ifn)
2469    format('#Spectral period ',f6.3,' nlev ',i2,' epistemic: ',a12,/,
     1'# Rbar(km) Mbar Rate_of_Excd Eps0bar Depth_Index')
      if(deagg)write(20+ip,2469) period(ip), nlev(ip),pithy(ifn)
      do 214 k=1,nlev(ip)

      write(9+ip,212) ylev(k,ip), prob(i,k,ip,ifn)
      if(deagg)then
      do kk=1,ntor
c      write(20+ip,2568)kk
c2568      format(/,' next depth to top index, kk ',i1)
      do ir=1,16
      do im=1,40
      rate=hbin(ir,im,ip,kk,ifn)
      if(rate.gt.1.e-16)then
      rb=rbar(ir,im,ip,kk,ifn)/rate
      xmb=mbar(ir,im,ip,kk,ifn)/rate
      eb=ebar(ir,im,ip,kk,ifn)/rate
      write(20+ip,2599)rb,xmb,rate,eb,kk
      endif      !non neglig. rate
      enddo      !im
      enddo      !ir
      enddo      !kk
      endif      !deagg?
 212      format(f10.6,1x,e11.5,1x,f9.4) 
2599      format(f10.6,1x,f6.3,1x,e11.5,1x,f9.4,2x,i2) 
 214  continue
       enddo	!ifn=1,nfi
 215  continue
       write(10,68)sname(i)
 68      format('#End station data for ',a,/)	
       endif	!if grid or not
 100  icnt= icnt+1
      dum=dtime(tarray)
      write(6,*)tarray(1),' sec= time to complete hazgridXnga13l'
       if(.not.grid)then
       do ip=1,nper
       close(9+ip)
       if(deagg)close(20+ip)
       enddo
       write(6,*)'An ascii file was written for each period in input'
       if(deagg)write(6,*)'A deagg (R,M,e) file was written for each period in input'
       endif
      stop
2106      write(6,*)'hazgridXnga13l: first record must be an integer, nrec. 0 for grid'
      stop 'correct input file line 1'
2014      write(6,*)'BSSA coeff file GR/BSSAcoef.dat not found'
      stop 'Put it in the GR folder'
2015      write(6,*)'hazgridXnga13l is looking for a meanrjb array 26 by 1001 '
      write(6,*)'Do you have a recent version with these M&R limits?'
      stop 'Use program getmeanrjf.v2.f to write this binary array'
      end
c
      subroutine delaz(sorlat,sorlon,stnlat,stnlon,delta,az,baz)
      if((sorlat.eq.stnlat).and.(sorlon.eq.stnlon)) then
          delta=0.
          az=0.
          return
          endif
      coef= 3.141592654/180.
      xlat= sorlat*coef
      xlon= sorlon*coef
      st0= cos(xlat)
      ct0= sin(xlat) 
      phi0= xlon
      xlat= stnlat*coef
      xlon= stnlon*coef
      ct1= sin(xlat)
      st1= cos(xlat)
      sdlon= sin(xlon-phi0)
      cdlon= cos(xlon-phi0)
      cdelt= st0*st1*cdlon+ct0*ct1
      x= st0*ct1-st1*ct0*cdlon
      y= st1*sdlon
      sdelt= sqrt(x*x+y*y)
      delta= atan2(sdelt,cdelt)
      delta= delta/coef
      az= atan2(y,x)
      az= az/coef
      x= st1*ct0-st0*ct1*cdlon
      y= -sdlon*st0
      baz= atan2(y,x)
      baz= baz/coef
      delta= delta*111.2
      return
      end         

      subroutine back(delta0,az,sorlat,sorlon,stnlat,stnlon)
      coef= 3.14159/180.
      delta= delta0/111.11
      delta= delta*coef
      sdelt= sin(delta)
      cdelt= cos(delta)
      xlat= sorlat*coef
      xlon= sorlon*coef
      az2= az*coef
      st0= cos(xlat)
      ct0= sin(xlat)
      phi0= xlon
      cz0= cos(az2)
      ct1= st0*sdelt*cz0+ct0*cdelt
      x= st0*cdelt-ct0*sdelt*cz0
      y= sdelt*sin(az2)
      st1= sqrt(x*x+y*y)
      dlon= atan2(y,x)
      stnlat= atan2(ct1,st1)
      stnlat= stnlat/coef
      stnlon= phi0+dlon
      stnlon= stnlon/coef
      return
      end

      subroutine gettab(gma,f,xmag,rlog)
c      gets corresponding log PSA values (cm/s**2) from interpolation
c      of data file ab94.tab.
c      Written by G.M. Atkinson, Jan. 1994
C----  modified by A. Frankel 10/95
      dimension xmag(20),gma(20,30,20), rlog(30), f(20)
      character*60 header

c
c     Read AB94 simulated grd. motion table.
c
      open(19,file='ab94.tab',status='old',err=234)
 900  format(i2)
      do 20 j = 1, 5
        read(19,10)header
        read(19,900) idum
10      format(a)
20    continue
      nf = 11
      nmag = 14
      nd = 18
      jdl = 0
      do 30 jf = 1, nf-2
        f(jf) = 10.**(-0.3 + float(jf-1)*0.2)
30    continue
      f(nf) = 89.
      f(nf-1) = 99.
      do 50 jm = 1, nmag
        read(19,900) idum
        read(19,900) idum
        read(19,35)xmag(jm)
35      format(13x,f5.2)
        read(19,900) idum
        read(19,45)
        read(19,900) idum
        read(19,45)
        read(19,900) idum
        do 40 jd = 1, nd
          read(19,45)rlog(jd),(gma(jf,jd,jm), jf = 1,nf)
          read(19,900) idum
45        format(f6.2,2x,11f6.2)
40      continue
50    continue
      close(19)
      return
234      write(6,*)'ab94.tab would not open in gettab. put in wd'
      stop'hazgridXnga13l: or rewrite pgm'
      end

c***************************************************************
c*****************************************************************

      subroutine table(gma,amag,R,freq,amean,f,xmag,rlog)

      dimension xmag(20),gma(20,30,20), rlog(30), f(20)
      dimension avg(20)
c     
c     Use interpolation to get amean for given freq(jfreq), amag, R.
c
      nf= 11
      nmag= 14
      nd= 18
      rl = alog10(R)
      jfl = 0
c     Find bounding jf values.
      do 10 j = 1,nf-3
        if (freq .ge. f(j) .and. freq .lt. f(j+1))jfl = j
10    continue
      if (abs(freq-f(1)) .lt. 0.01) jfl = 1
      if (abs(freq-f(nf)) .lt. 0.01) jfl = nf
      if (abs(freq-f(nf-1)) .lt. 0.01) jfl = nf-1
      if (abs(freq-20.) .lt. 0.01)  jfl = nf-2
      if (jfl .eq. 0) write(*,*) ' ERROR. FREQ. OUTSIDE RANGE.'
      if (freq .gt. 20. .and. freq .lt. 89.)
     *   write(*,*)' ERROR. FREQ. OUTSIDE RANGE'
      jfu = jfl + 1
      fracf = 0.
      if (freq .ge. 20.) go to 15
      fracf = (alog10 (freq) - alog10 (f(jfl)) ) /
     *        (alog10 (f(jfu)) - alog10 (f(jfl)) )
15    continue
c     Find bounding jm values.
      jml = 0
      do 20 j = 1, nmag-1
         if (amag .ge. xmag(j) .and. amag .lt. xmag(j+1)) jml = j
20    continue

      if (amag .eq. xmag(nmag)) jml = nmag
      if (jml .eq. 0) write(*,*)' ERROR. MAGNITUDE OUTSIDE RANGE.'
      jmu = jml + 1
      fracm = (amag - xmag(jml)) / (xmag(jmu)-xmag(jml))
c     find bounding distance values.
      do 30 j = 1, nd-1
        if (rl .ge. rlog(j) .and. rl .lt. rlog(j+1)) jdl= j
30    continue

      if (rl .eq. rlog(nd)) jdl = nd
      if (jdl .eq. 0) write(*,*)' ERROR. DISTANCE OUTSIDE RANGE.'
      jdu = jdl + 1
      fracd = (rl - rlog(jdl)) / (rlog(jdu)-rlog(jdl))
      do 40 j = jfl, jfu
        arl = gma(j,jdl,jml) + fracm * (gma(j,jdl,jmu)-gma(j,jdl,jml))
        aru = gma(j,jdu,jml) + fracm * (gma(j,jdu,jmu)-gma(j,jdu,jml))
c       arl is the amplitude for lower dist. bound, so arl>aru
        avg(j) = arl - fracd*(arl-aru)
40    continue
      amean = avg(jfl) + fracf * (avg(jfu) - avg(jfl))
      return
      end

cccccccccccccccccccc
      subroutine getSpu2000(ip,iq,ia,ndist,di,nmag,
     & magmin,dmag,sigmanf,distnf)
c subr. previously known as getBJF93 comandeered by Spudich ea. 
c To more clearly distinguish from BJF97. 
c Subroutine adapted to nga style july 26 2006.
      parameter (sqrt2=1.414213562, pi=3.141592654,np=7,aln10=2.30258509)
      parameter (vref=760.)
c spudich coeffs...
c site amp: for now use that of BJF97. THis should be reviewed July26 2006.
      common/epistemic/nfi,e_wind,gnd_ep,mcut,dcut
      real gnd_ep(3,3,8),mcut(2),dcut(2),gndout(3),gndx
      logical e_wind(8)
      logical deagg
      real magmin,perx(8)
      common/deagg/deagg
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
      common/geotec/vs30,d	!assume vs30 is fixed for all sites. "Soil map" "rock map" etc
      common / atten / pr, xlev, nlev, icode, wt, wtdist
      real pr(310,38,20,8,3,3),xlev(20,8),wt(8,10,2),wtdist(8,10) 
      integer nlev(8),icode(8,10)
        real, dimension(np) :: b1,b2,b3,b4,b5,h,sigma,bv,va
c array constructors OCT 2006. No coeffs corresponding to PGV, perx(8)
        perx=(/0.,0.2,1.0,0.1,0.3,0.5,2.0,-1./)
        bv = (/-.371,-.292,-.698,-.212,-.401,-.553,-.655 /)
        va = (/1396.,2118.,1406.,1112.,2133.,1816.,1795. /)
        b1 = (/0.299,2.224,2.276,2.144,2.263, 2.292, 2.168/)           
        b2 = (/ 0.229, 0.309, 0.450,0.327, 0.334,0.384,0.471/)
        b3 = (/0., -0.090,-.014,-0.098,-0.070,-0.039, -0.037/)
        b4 = (/ 0., 0.,0.,0.0,0.,0.,0.0/)
        b5 =(/-1.052,-1.047,-1.083,-1.250,-1.020,-1.038,-1.049/)
        h = (/7.27,8.63, 6.01,9.99,7.72,6.70, 6.71/)
         sigma= (/0.225,0.262,0.301,0.295,0.263 ,0.275,0.341/)
c set up erf matrix p as ftn of dist,mag,period,level,flt type,atten type
          sig= sigma(iq)*aln10
c site amp first, convert to base 10 for compatibility
c      gnd0= bv(iq)*(alog(vs30/va(iq))-alog(vref/va(iq))
      gnd0 = bv(iq)*alog(vs30/vref)/aln10
      gndx=0.0
      period=perx(iq)
c-- loop through magnitudes
      do 104 m=1,nmag
      xmag0= magmin + (m-1)*dmag
c--- loop through atten. relations for each period
c-- gnd for SS; gnd2 for thrust; gnd3 for normal
        xmag= xmag0
          gndm= gnd0 + b1(iq)+b2(iq)*(xmag-6.)+b3(iq)*(xmag-6.)**2
c-- following for Joyner Boore WUS
c-- loop through distances
      do 103 ii=1,ndist
      dist0= (ii-0.5)*di 
      weight= wt(ip,ia,1)
      if(dist0.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
      dist= sqrt(dist0*dist0+h(iq)**2)
          if(dist0.lt.distnf) sig= sig+ sigmanf
          sigmasq= sig*sqrt2
          gnd= gndm+ b4(iq)*dist + b5(iq)*alog10(dist)
c--- convert from psv in cm/sec to psa in g
c       if(period.eq.1.) write(12,*) ia, period, xmag,  dist0, 10.**gnd
          if(period.ne.0.) gnd=gnd+alog10(2.*pi/(980.*period))
c bse 10 to base e
          gnd= gnd *aln10
      do 102 k=1,nlev(ip)
      temp= (gnd- xlev(k,ip))/sigmasq
      temp1= (erf(temp)+1.)*0.5
      temp1= (temp1- 1.3499e-3)/0.99865
      if(temp1.lt.0.) goto 103
      do kk=1,ntor
      pr(ii,m,k,ip,kk,1)= pr(ii,m,k,ip,kk,1) + weight*temp1
      enddo      ! Spudich median: no variation wrt depth of rupture
  102 continue
  103 continue
  104 continue
      return
      end subroutine getSpu2000

cccccccccccccccc
      subroutine getToro(ip,iq,ir,ia,ndist,di,nmag,
     &   magmin,dmag,sigmanf,distnf)
c adapted to NGA code SH July 2006. 7 periods used in2002. With finite-flt corr,
c added Nov 17 2006.
c Period indexes ip = counter index
c iq = location of the period in the perx() array.
c tc coefficients correspond to Mw. 
c tb coeffs. correspond to MbLg (CEUS agrid often written wrt MbLg).
c ir=1 use BC rock; ir=2 use hardrock model (6000 ft/s according to SRL).
c Hard-rock in tb1h & tc1h, otherwise same regression model & coeffs.
c Added 0.4 and 0.04 s July 16 2008 for NRC work
c Coeffs for several other periods are available in the SRL report, 1997.
c clamp on upper-bound ground accel is applied here. As in original hazgridX code.
        parameter (sqrt2=1.414213562, pi=3.141592654,np=9)
        logical mlg,et,deagg,sp  !sp = short period but not pga?
      common/deagg/deagg
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
      real magmin,dmag,sigmanf,distnf,gndm,gnd,cor,corsq
             real, dimension(np):: perx(np),tc1,tc2,tc3,tc4,tc5,tc6
      real, dimension(np):: tc1h,th,tsigma,clamp
             real, dimension(np):: tb1,tb2,tb3,tb4,tb5,tb6
      real, dimension(np):: tb1h,tbh
           real   ptail(6) 
      common / atten / pr, xlev, nlev, icode, wt,wtdist
c e0_ceus not saving a depth of rupture dim, not sens. to this
      common/e0_ceus/e0_ceus(310,31,8)
      real pr(310,38,20,8,3,3),xlev(20,8),wt(8,10,2),wtdist(8,10) 
      integer nlev(8),icode(8,10)
      
c array constructors. add 0.04 and 0.4 s coeffs july 16 2008. From NRC files
       perx = (/0.,0.2,1.0,0.1,0.3,0.5,2.0,0.04,0.4/)
c tb MbLg coeffs. BC/A 2-hz Siteamp = 1.58, with BC-A coef. diff. of 0.4574.
        tb1 = (/2.489,2.165,0.173,2.91,1.7323,1.109,-.788,4.,1.2/)
      tb1h= (/2.07,1.6,-0.12,2.36,1.19,0.652,-0.97,3.54,0.90/)
c tc Mw coeffs for BC rock. 3hz BC-A is 0.5423 (BC/A siteamp is then 1.72)
      tc1 = (/2.619,2.295,0.383,2.92,1.8823,1.2887,-0.558,4.,1.4/)
c tc Mw coeffs. 3.33 hz is log-log from the 2.5 and 5 hz values. 
        tc1h = (/2.20,1.73,0.09,2.37,1.34,0.8313,-0.740,3.68,1.07/)
c example tc1h(10hz) = 2.37, as in Toro et al., Table 2 midcontinent Moment Magnitude coeffs.
      tb2 = (/1.20,1.24,2.05,1.23,1.51,1.785,2.52,1.19,1.70/)
      tc2 = (/0.81,0.84,1.42,0.81,0.964,1.14,1.86,0.80,1.05/)
      tb3 = (/0.,0.,-0.34,0.,-0.11,-0.2795,-0.47 ,0.,-.26/)
      tc3 = (/0.,0.0,-0.2,0.,-0.059,-0.1244,-0.31,0.0,-0.10/)
      tb4 =(/1.28,0.98,0.90,1.12,0.96,0.930,0.93,1.46,0.94/)
      tc4 = (/1.27,0.98,0.90,1.1,0.951,0.9227,0.92,1.46,0.93/)
      tb5 =  (/1.23,0.74,0.59,1.05,0.6881,0.6354,0.6,1.84,0.65/)
      tc5 = (/1.16,0.66,0.49,1.02,0.601,0.5429,0.46,1.77,0.56/)
      tb6= (/0.0018,0.0039,0.0019,0.0043,0.0034,0.002732,0.0012,0.0010,.0030/)
      
      tc6 = (/0.0021,0.0042,0.0023,0.004,0.00367,0.00306,0.0017,0.0013,0.0033/)
      tbh =(/9.3,7.5,6.8,8.5,7.35,7.05,7.0,10.5,7.2/)
           th = (/9.3,7.5,6.8,8.3,7.26,7.027,6.9,10.5,7.1/)
           clamp = (/3.,6.,0.,6.,6.,6.,0.,6.,6./)
c write sigma in nat log units. Saves a divide
c Toro : slightly larger sigma for 1 and 2 s. Toro Lg based mag has
c larger sigma for larger M (table 3, p 50 ,srl 1997. This isnt in our rendering
c
           tsigma = (/0.7506,0.7506,0.799,.7506,.7506,.7506,0.799,.7506,.7506/)	
c        write(6,*) "enter b1,b2,b3,b4,b5,b6,h,sigma"
c        read(1,*) tc1,tc2,tc3,tc4,tc5,tc6,
c     &    th,tsigma,clamp
          sigmat = tsigma(iq)      	!already performed this: /0.4342945
c set up erf matrix p as ftn of dist,mag,period,level,flt type,atten type
c assume using mblg if icode()=0. 
      period = perx(iq)
      if(icode(ip,ia).eq.0)then
      t1=tb1(iq); t2=tb2(iq); t3=tb3(iq); t4=tb4(iq); t5=tb5(iq); t6=tb6(iq)
      thsq=tbh(iq)**2; t1h=tb1h(iq)
      write(6,*)'Toro relation using MbLg coefficients'
      mlg = .true.
      else
      t1=tc1(iq); t2=tc2(iq); t3=tc3(iq); t4=tc4(iq); t5=tc5(iq); t6=tc6(iq)
      thsq=th(iq)**2; t1h = tc1h(iq)
      write(6,*)'Toro relation using Mw coefficients'
      mlg = .false.
      endif
      sp=perx(iq) .gt. 0.02 .and. perx(iq) .lt. 0.5
      if(ir.eq.1)then
      gnd0=t1
      else
c hard rock. Could have other possibilities as well. 
      gnd0=t1h
      endif
c-- loop through magnitudes
      do 104 m=1,nmag
      xmag0= magmin + (m-1)*dmag
        xmag= xmag0
c With toro model, you change the coefficients appropriate to the magnitude.
c New, Nov 2006: the finite-fault correction, affects the fictitious depth or bending point
c from Toro Paducah paper. Mod. Dec 2007, mblg to Mw for the correction.
         if(mlg) then
         xmag1= 1.14 +0.24*xmag0+0.0933*xmag0*xmag0
         cor1 = exp(-1.25 + 0.227*xmag1)
         xmag2= 2.715 -0.277*xmag0+0.127*xmag0*xmag0
         cor2 = exp(-1.25 + 0.227*xmag2)
         cor=sqrt(cor1*cor2)      !geo mean
         else
        cor = exp(-1.25 + 0.227*xmag)
         endif
          gndm= gnd0+t2*(xmag-6.)+ t3*((xmag-6.)**2)
c New, Nov 2006: the finite-fault correction, affects the fictitious depth or bending point
c from Toro Paducah paper.
        corsq=cor*cor
c Formality, loop through depth of top of rupture. TORO: No sens. to this param.
      do 103 kk=1,ntor
      hsq = dtor(kk)**2
      et=deagg.and.kk.eq.1
c-- loop through distances
      do 103 ii=1,ndist
      dist0= (ii-0.5)*di 
      weight= wt(ip,ia,1)
      if(dist0.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
c note, corsq for finite fault corr in toro relation
      dist= sqrt(dist0*dist0+thsq*corsq)
c-- gnd for SS,etc; mech dependence not specified in Toro ea.
          if(dist0.lt.distnf) then
          sigma= sigmat+ sigmanf
          else
          sigma=sigmat
          endif
          sigmasq= sigma*sqrt2
          gnd= gndm-t4*alog(dist)-t6*dist
          factor= alog(dist/100.)
          if(factor.gt.0.) gnd= gnd-(t5-t4)*factor
c---following is for clipping gnd motions: 1.5g PGA, 3.0g 0.3 and 0.2 s
          if(period.eq.0.)then
           gnd=min(0.405,gnd)
           elseif(sp)then
           gnd=min(gnd,1.099)
           endif
           test0=gnd + 3.*sigmasq/sqrt2
      test= exp(test0)
      if(clamp(iq).lt.test .and. clamp(iq).gt.0.) then
      clamp2= alog(clamp(iq))
      else
       clamp2= test0
       endif
      tempgt3= (gnd- clamp2)/sigmasq
      probgt3= (erf(tempgt3)+1.)*.5
      do 102 k=1,nlev(ip)
      temp= (gnd- xlev(k,ip))/sigmasq
      temp1= (erf(temp)+1.)*.5
      temp1= (temp1-probgt3)/(1.-probgt3)
      if(temp1.lt.0.) goto 103
      fac=weight*temp1
      pr(ii,m,k,ip,kk,1)= pr(ii,m,k,ip,kk,1) + fac
      if(et)e0_ceus(ii,m,ip)= e0_ceus(ii,m,ip)-sqrt2*temp*fac
  102 continue
  103 continue
  104 continue
      return
      end subroutine getToro

cccccccccccccccccc
      subroutine getSadighR(ip,iq,ia,ndist,di,nmag,
     &  magmin,dmag,sigmanf,distnf)
      parameter (sqrt2=1.414213562)
c Sadigh et al (SRL 1997), rock site. Separate subroutine for deeep soil 
c Modified to look like the new nga subroutines. The median is sensitive
c to depth of rupture which is in common/dtor/. This differs from 2002, which
c put a "5 km" assumed depth as a coefficient.
c ip is input file period index. 
c Coeffs have been written for pga, 0.2, .1,.3, 0.5, 1.0, and 2.0 s. SH)
c iq is index of atten model period corresponding to ip
      real magmin
      common/prob/p(25005),plim,dp2	!table of complementary normal probab.
      common/mech/wtss,wtrev,wtnormal
      common/dipinf_50/dipang2,cosDELTA2,cdip2sq,cyhwfac2,cbhwfac2
      common/dipinf_90/dipang,cosDELTA,cdipsq,cyhwfac,cbhwfac
      common/deagg/deagg
      common/geotec/vs30,dbasin
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
            common / atten / pr, xlev, nlev, icode, wt,wtdist
      real pr(310,38,20,8,3,3),xlev(20,8),wt(8,10,2),wtdist(8,10) 
      integer nlev(8),icode(8,10)
      real sc1(7),sc2/1./,sc3(7),sc4(7),sc5(7),sc6(7),perx(7)
      real sd1(7),sd2/1.1/,sd3(7),sd4(7),sd5(7),sd6(7),sd7(7)	
      real ssigma1(7),ssigma2(7),ssigmacoef(7),smagsig(7)
c data prepared for 1st 3 periods nov 22 2005. Needs to be modified
c for sense-of-slip coef. variation, which is available from common/mech/ 
      real sh(7)/7*5./,sthrust(7)/7*.1823/	!factor of 1.2
      real, dimension(6):: ptail 
      logical deagg
c sc1 and sd1 are from the Sadigh etal. SRL table and might correspond to response
c of 600 m/s? rock at the "average" rock site
      sc1 = (/-0.624,.153,-1.705,0.2750,-0.057,-0.5880,-2.945/)
      sc3 = (/0.0,-0.004,-0.055,0.006,-0.017,-0.04,-0.07/)
      sc4 = (/-2.1,-2.08,-1.8,-2.148,-2.028,-1.945,-1.67/)
      sc5 = (/1.29649,1.29649,1.29649,1.29649,1.29649,1.29649,1.29649/)
      sc6 = (/0.25,.25,.25,.25,.25,.25,.25/)
      perx = (/0.0,0.2,1.0,0.1,0.3,0.5,2.0/)
      sd1 = (/-1.274,-.497,-2.355,-0.375,-0.707,-1.238,-3.595/)
      sd3 = (/0.,-.004,-0.055,0.006,-0.071,-0.040,-0.07/)
      sd4 = (/-2.1,-2.08,-1.8,-2.148,-2.028,-1.945,-1.67/)
      sd5 = (/-.48451,-.48451, -.48451,-.48451,-.48451, -.48451,-.48451/)
      sd6 = (/.524,.524,.524,.524,0.524,.524,.524/)
      sd7 = (/0.,0.,0.,-0.041,0.,0.,0./)
      ssigma1 = (/1.39,1.43,1.53,1.41,1.45,1.5,1.53/)
      ssigmacoef = (/0.14,0.14,0.14,0.14,0.14,0.14,0.14/)
      ssigma2 = (/0.38,0.42,0.52,0.4,0.44,0.49,0.52/)
      smagsig = (/7.21,7.21,7.21,7.21,7.21,7.21,7.21/)
c Sadigh SRL 97 atten type
      if(vs30.lt.500.)then
      write(6,*)'getSadighR has been called with probable soil conditions'
      write(6,*)'Consider calling getSadighS instead; vs30=',vs30
      endif
c-- loop through magnitudes
c for thrust, a 1.2 amp factor. This for all mags. 
      gnd0 =wtrev*sthrust(iq)
      do 104 m=1,nmag
      xmag0= magmin + (m-1)*dmag
        xmag= xmag0
c icode generally is 0 in wus. Moment mag is the preferred mag.
          if(xmag.lt.smagsig(iq))then
           sigp= ssigma1(iq)- ssigmacoef(iq)*xmag
          else
           sigp= ssigma2(iq)
           endif
         if(xmag.lt.6.5) then
          facm=exp(sc5(iq)+sc6(iq)*xmag)
       gndm = gnd0+sc1(iq)+sc2*xmag+sc3(iq)*((8.5-xmag)**2.5)
          sco=sc4(iq)
         else
          facm=exp(sd5(iq)+sd6(iq)*xmag)
       gndm = gnd0 +sd1(iq)+sd2*xmag+sd3(iq)*((8.5-xmag)**2.5)
          sco=sd4(iq)
          endif
       do 103 kk=1,ntor
       hsq=dtor(kk)**2     
c-- loop through distances
      do 103 ii=1,ndist
      dist0= (ii-0.5)*di 
      dist= sqrt(dist0*dist0+ hsq)
          if(dist0.lt.distnf)then
           sig= sigp+ sigmanf
           else
           sig=sigp
           endif
          sigmaf= 1./(sig*sqrt2)
      weight= wt(ip,ia,1)
      if(dist0.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
      gnd= gndm+ sco*alog(dist+ facm)
c for 0.1s SA, a reduction factor. Use R_cd as in Sadigh et al 1997.
          gnd= gnd+sd7(iq)*alog(dist+2.)
c          if(ii.eq.1)write(6,*)xmag,sig,gnd,sco,facm
      do 199 k= 1,nlev(ip)
        tmp=(gnd - xlev(k,ip))*sigmaf
       if(tmp.gt.3.3)then
       ipr=25002
       elseif(tmp.gt.plim)then
       ipr= 1+nint(dp2*(tmp-plim))	!3sigma cutoff n'(mu,sig)
       else
       goto 103	!transfer out if ground motion above mu+3sigma
       endif
c        if(k.gt.12.and.ii.eq.1.and.m.gt.12)write(6,*)ii,m,k,p(ipr)
        pr(ii,m,k,ip,kk,1)= pr(ii,m,k,ip,kk,1)+weight*p(ipr)	
 199      continue
  103 continue
  104 continue
      return
      end subroutine getSadighR

cccccccccccccccccc
      subroutine getSadighS(ip,iq,ia,ndist,di,nmag,
     &  magmin,dmag,sigmanf,distnf)
      parameter (sqrt2=1.414213562,np=7)
c Sadigh et al (SRL 1997), soil site. Separate subroutine for rock, above.
c Modified to look like the new nga subroutines
c ip is input file period index. 
c The distance index corresponds to Rjb. Dtor gives the model depth, which
c can vary.
c Coeffs have been written for pga, 0.2, .1,.3, 0.5, 1.0, and 2.0 s. SH)
c iq is index of atten model period corresponding to ip
      real magmin
      common/prob/p(25005),plim,dp2	!table of complementary normal probab.
      common/mech/wtss,wtrev,wtnormal
      common/dipinf_90/dipang,cosDELTA,cdipsq,cyhwfac,cbhwfac

      common/geotec/vs30,dbasin
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
            common / atten / pr, xlev, nlev, icode, wt,wtdist
      real pr(310,38,20,8,3,3),xlev(20,8),wt(8,10,2),wtdist(8,10) 
      integer nlev(8),icode(8,10)
      real ssigma1(7),ssigma2(7),ssigmacoef(7),smagsig(7)
c this routine is for soil. according to Cao hazFXv3-s.f. With minor changes
c for gridded.
c for sense-of-slip coef. variation, which is available from common/mech/ 
       real C1SS/-2.170/,C1RV/-1.920/,C2/1./,C3/1.70/,C4M1/2.1863/,C4M2/0.3825/
       real C6SS(np),C6RV(np),C7(np),perx(8)
       real C5M1/0.32/,C5M2/0.5882/

c      real sthrust(7)/7*.1823/	!factor of 1.2
      perx = (/0.0,0.2,1.0,0.1,0.3,0.5,2.0,-1./)
      C6SS = (/0.,0.9187,0.5665,.6395,.9547,.8494,0.1001/)
      C6RV= (/0.,0.9187,0.5075,.6395,.9547,.8285,-.0526/)
      C7= (/0.,-.004,-0.055,0.005,-.014,-0.033,-0.108/)
      ssigma1= (/1.52,1.565,1.66,1.54,1.58,1.61,1.71/)
      ssigmacoef= (/0.16,0.16,0.16,0.16,0.16,0.16,0.16/)
c set up excd matrix pr as ftn of dist,mag,period,level, but sum thru
c atten type
      if(vs30.gt.510.)then
      write(6,*)'getSadighS has been called with probable rock conditions'
      write(6,*)'Consider calling getSadighR instead; vs30=',vs30
      endif
c term indep of M and R. Lump normal with SS for this calculation.
      c1=(wtss+wtnormal)*(C1SS+C6SS(iq))+wtrev*(C1RV+C6RV(iq))
c-- loop through magnitudes & depth to seismicity
      do 104 m=1,nmag
      xmag0= magmin + (m-1)*dmag
        xmag= xmag0
           sigp= ssigma1(iq)- ssigmacoef(iq)*min(xmag,7.0)
          GNDm= c1 +C2*xmag +C7(iq)*(8.5-xmag)**2.5
      IF(xmag.LE.6.5)then
          facm = C4M1*EXP(C5M1*xmag)
      ELSE
          facm = C4M2*EXP(C5M2*xmag)
        ENDIF
c loop through top of rupture location
       do 103 kk=1,ntor
       hsq=dtor(kk)**2     
c-- loop through rjb distances
      do 103 ii=1,ndist
      dist0= (ii-0.5)*di 
          if(dist0.lt.distnf) then
          sig= sigp+ sigmanf
          else
          sig=sigp
          endif
          sigmaf= 1./(sig*sqrt2)
      weight= wt(ip,ia,1)
      dist= sqrt(dist0**2+hsq)
      if(dist0.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
      gnd= gndm -C3*alog(dist +facm)
      do 199 k= 1,nlev(ip)
        tmp=(gnd - xlev(k,ip))*sigmaf
       if(tmp.gt.3.3)then
       ipr=25002
       elseif(tmp.gt.plim)then
       ipr= 1+nint(dp2*(tmp-plim))	!3sigma cutoff n'(mu,sig)
       else
       goto 102	!transfer out if ground motion above mu+3sigma
       endif
        pr(ii,m,k,ip,kk,1)= pr(ii,m,k,ip,kk,1)+weight*p(ipr)	
 199      continue
 102      continue
  103 continue
  104 continue
      return
      end subroutine getSadighS

cccccccccccccccccccccccc
      subroutine getCamp(ip,period,ia,ndist,di,nmag,
     c  magmin,dmag,sigmanf,distnf)
c not ready for nga code. out of date relation in 2008. Use getCamp2003
      write(6,*)'hazgridXnga13l: getCamp is not a current option.'
      return
      end

cccccccccccccccccccccc
      subroutine getAB95(ip,iq,ia,ndist,di,nmag,
     &   magmin,dmag,sigmanf,distnf)
c adapt to nga style. new problem: gettab. This routine doesn't seem to be used.
c I dont ever see iatten 5 in CEUS input files for 2002. always getFEA. Check? SH
c not ready. july 28 2006. Using iatten 5 for AB95 with table lookup.
      Write(6,*)'hazgridXnga13l: getAB95 should not be called. No array 
     * setup'
      return
      end

ccccccccccccccccccccccc
      subroutine getFEA(ip,iq,ir,ia,ndist,di,nmag,magmin,dmag,sigmanf,distnf)
c example call:
c      call getFEA(ip,iq,1,ia,ndist,di,nmag,magmin,dmag,sigmanf,distnf)
c adapted to nga style. This routine is used for background & charleston.
c 
c  getFEA used for several HR and firm rock models with look-up tables.
c input variables:
c ip,iq period indexes. ip is the current index in iatten() array
c iq = is the index in perx() the standard set of SA periods in 2003 PSHA.
c ir = flag to control which interpolation table:
c The table data are input here. File has to reside in subdir called GR.
c Table data are not saved (new aug 06) use 'em and overwrite 'em.
c ir =1=>Fea BC,
c 2=> AB Bc, 
c 3=> Fea A(HR)
c 4=>  AB A (HR) tables. Tables currently in a subdirectory.
c Note: depth to rupture is controlled by dtor rather than set to "bdepth"
c
      parameter (np=7,npp=9,sqrt2=1.414213562)
      logical deagg,et,sp/.false./      !short-period?
      real magmin,perx(9)
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
      common / atten / pr, xlev, nlev, icode, wt, wtdist
      common/deagg/deagg
c e0_ceus not saving a depth of rupture dim, although could be sens. to this.
c FOR CEUS runs 2008, only one depth of rupture is considered.
      common/e0_ceus/e0_ceus(310,31,8)
      real pr(310,38,20,8,3,3),xlev(20,8),wt(8,10,2),wtdist(8,10) 
      integer nlev(8),icode(8,10)
      real bdepth/5./,bsigma(9),clamp(9),xlogfac(7)/7*0./
c bdepth is no longer used. use dtor instead.
c Same sigma for AB94 and FEA. 1s and 2s larger than the rest. As in Toro ea.
      dimension tabdist(21),gma(22,30)
      character*30 nametab(np),nameab(np),namehr(np+2),subd*3/'GR/'/
      character*30 hardab(np+2)
c Subroutine assumes these files are in working directory:
      perx= (/0.0,0.2,1.0,0.1,0.3,0.5,2.0,0.04,0.4/)
c added 0.04 and 0.4 s for NRC work july 15 2008. hard rock tables k006
           bsigma=(/0.326,0.326,0.347,0.326,0.326,0.326,0.347,0.326,0.326/)
           clamp =(/3.,6.,0.,6.,6.,6.,0.,6.,6./)
      nametab= (/'pgak01l.tbl ','t0p2k01l.tbl','t1p0k01l.tbl','t0p1k01l.tbl',
     1 't0p3k01l.tbl','t0p5k01l.tbl','t2p0k01l.tbl'/)
      namehr= (/'pgak006.tbl ','t0p2k006.tbl','t1p0k006.tbl','t0p1k006.tbl',
     1 't0p3k006.tbl','t0p5k006.tbl','t2p0k006.tbl','tp04k006.tbl',
     2't0p4k006.tbl'/)
c tp04k006 was renamed from t0p04k006.tbl to have fixed length
      nameab= (/'Abbc_pga.tbl','Abbc0p20.tbl','Abbc1p00.tbl',
     1 'Abbc0p10.tbl','Abbc0p30.tbl','Abbc0p50.tbl','Abbc2p00.tbl'/)
c added 0.04 and 0.4s to hardab, July 15 2008. SH.
      hardab= (/'ABHR_PGA.TBL','ABHR0P20.TBL','ABHR1P00.TBL',
     1'ABHR0P10.TBL','ABHR0P30.TBL','ABHR0P50.TBL','ABHR2P00.TBL',
     2'Abhr0p04.tbl','Abhr0p40.tbl'/)
      period=perx(iq)
c         write(6,*)ip,nlev(ip),' ip nlev() in getFEA before table fill'
          if(period.gt.0.)then
           freq=1./perx(iq)
           sp=freq.gt.2.0
          elseif(period.eq.0.) then
          freq= 99.
          sp=.false.
          else
c In nga, negative period implies PGV. However, PGV not available in tables
          freq=1.      ! Flow should not have arrived at this spot.
          endif
c         write(6,*) "enter file name of table"
c         read(1,900) nametab
 900   format(a)
c         write(6,*) "enter depth, sigma, log factor"
c         read(1,*) bdepth,bsigma,xlogfac, clamp
      if(ir.eq.1)then
         open(unit=15,file=subd//nametab(iq),status='old',err=234)
         elseif(ir.eq.2)then
         open(unit=15,file=subd//nameab(iq),status='old',err=236)
      elseif(ir.eq.3)then
         open(unit=15,file=subd//namehr(iq),status='old',err=237)
         elseif(ir.eq.4)then
         open(unit=15,file=subd//hardab(iq),status='old',err=238)
         else
         stop'invalid ir in getFEA'
         endif
         read(15,900) adum
         do 80 idist=1,21
   80    read(15,*) tabdist(idist),(gma(imag,idist),imag=1,20)
         close(15)
c---- following for new Boore look-up table
c set up erf matrix p as ftn of dist,mag,period,level,flt type,atten type
c convert to natural log units
          sigma= bsigma(iq)*2.302585093
c-- loop through magnitudes
      do 104 m=1,nmag
      xmag0= magmin + (m-1)*dmag
c--- loop through atten. relations for each period
c-- gnd for SS; gnd2 for thrust; gnd3 for normal
        xmag= xmag0
        if(icode(ip,ia).eq.1) THEN
        xmag= 1.14 +0.24*xmag0+0.0933*xmag0*xmag0
        ELSEif(icode(ip,ia).eq.2) then
        xmag= 2.715 -0.277*xmag0+0.127*xmag0*xmag0
        endif
          imag= (xmag-4.4)/0.2 +1
          xm1= (imag-1)*0.2 + 4.4
          fracm= (xmag-xm1)/0.2
c loop over depth of rupture. dtor replaces bdepth in this subroutine.
      do 103 kk=1,ntor
      hsq=dtor(kk)**2
      et = kk.eq.1 .and. deagg
c-- loop through distances. ii index corresponds to rjb.
      do 103 ii=1,ndist
      dist0= (ii-.5)*di 
      weight= wt(ip,ia,1)
      if(dist0.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
      dist= sqrt(dist0*dist0+hsq)
          if(dist0.lt.distnf) then
          sigmap= sigma+ sigmanf
          else
          sigmap = sigma
          endif
          sigmasq= sigmap*sqrt2
          if(dist.lt.10.) dist=10.
          rdist= alog10(dist)
          idist= (rdist-tabdist(1))/0.1 + 1
          xd1= (idist-1)*0.1 +tabdist(1)
          fracd= (rdist-xd1)/0.1
          idist1= idist+1
c          write(19,*) ip,xmag,imag,dist,idist
          if(idist.gt.21) idist=21
          if(idist1.gt.21) idist1=21
          gm1= gma(imag,idist)
          gm2= gma(imag+1,idist)
          gm3= gma(imag,idist1)
          gm4= gma(imag+1,idist1)
          arl= gm1 + fracm*(gm2-gm1)
          aru= gm3 + fracm*(gm4-gm3)
          gnd= arl +fracd*(aru-arl)
          gnd= gnd+ xlogfac(iq)
          gnd= gnd/0.4342945
c          if(dist0.gt.950.) then
c            taper= (1001.-dist)/50.
c            if(taper.le.0.01) taper=.01
c            taper= log(taper)
c            gnd=gnd+taper
c            endif
c--- following is for clipping 1.5 g pga, 3 g 5hz 3 hz
          if(period.eq.0.)then
           gnd=min(0.405,gnd)
           elseif(sp)then
           gnd=min(gnd,1.099)
           endif
c clamping issues mean that erf() must be called inside subr. THis may be
c a problem for PCs with windows OS and using off-the-shelf gfortran to compile.
      test= exp(gnd + 3.*sigmasq/sqrt2)
      if (clamp(iq).lt.test.and.clamp(iq).gt.0.)then
       clamp2= alog(clamp(iq))
       else
       clamp2= gnd+ 3.*sigmasq/sqrt2
      endif
      tempgt3= (gnd- clamp2)/sigmasq
      probgt3= (erf(tempgt3)+1.)*0.5
      do 102 k=1,nlev(ip)
      temp= (gnd- xlev(k,ip))/sigmasq
      temp1= (erf(temp)+1.)*0.5
      temp1= (temp1-probgt3)/(1.-probgt3)
c      if (ii.eq.1.and.m.eq.1.and.k.eq.1)write(6,*)ip,temp,temp1,gnd,probgt3,'getFEA'
      if(temp1.lt.0.) goto 103
      fac=weight*temp1
      pr(ii,m,k,ip,kk,1)= pr(ii,m,k,ip,kk,1) + fac
      if(et)e0_ceus(ii,m,ip)= e0_ceus(ii,m,ip)-sqrt2*temp*fac
  102  continue
  103 continue      !dist loop
  104 continue      !mag loop
      return
234      write(6,*)'getFEA table ',subd//nametab(iq),' not found'
      stop 'program hazgridXnga13l cannot continue without it.'
236      write(6,*)'getFEA table ',subd//nameab(iq),' not found'
      stop 'program hazgridXnga13l cannot continue without it.'
237      write(6,*)'getFEA table ',subd//namehr(iq),' not found'
      write(6,*)'Period index iq is ',iq
      stop 'program hazgridXnga13l cannot continue without it.'
238      write(6,*)'getFEA table ',subd//hardab(iq),' not found'
      stop 'program hazgridXnga13l cannot continue without it.'
      end subroutine getFEA

ccccccccccccccccccccccccc
      subroutine getSomer(ip,iq,ir,ia,ndist,di,nmag,
     & magmin,dmag,sigmanf,distnf)
c---- Somerville et al (2001) for CEUS. Coeffs for pga, 0.2 and 1.0s +4 other T sa
c --- adapted to nga style, include coeff values rather than read 'em in
c ir controls rock conditions:
c ir=1 BC or firm rock
c ir=2 hard rock
      parameter (np=7,sqrt2=1.414213562)
      real magmin,period
      logical deagg,sp
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
c wtor = weights to locations of top of rupture. 
c these are applied in main, to rate matrices.
c Do not apply wtor here. We do apply att model epist. weight wt() here, however.
      common / atten / pr, xlev, nlev, icode, wt, wtdist
      common/deagg/deagg
      real pr(310,38,20,8,3,3),xlev(20,8),wt(8,10,2),wtdist(8,10) 
      integer nlev(8),icode(8,10)
           real perx(8)	!possible period set. 
c perx(8) corresponds to PGV which is not set up for Somerville. Could check
c if that relation has a PGV model. SH July 31 2006.
      real a1(np),a1h(np),a2(np),a3(np),a4(np),a5(np),a6(np)
      real a7(np),sig0(np),clamp(np)
      perx = (/0.,0.2,1.0,0.1,0.3,0.5,2.0,-1./)
      a1 = (/0.658,1.358,-0.0143,1.442,1.2353,0.8532,-0.9497/)
      a1h = (/0.239,0.793,-0.307,0.888,0.6930,0.3958,-1.132/)
      a2 = (/0.805,0.805,0.805,0.805,0.805,0.805,0.805/)
      a3 = (/-0.679,-.679,-.696,-.679,-.67023,-.671792,-0.728/)
      a4 = (/0.0861,0.0861,.0861,.0861,0.0861,.0861,.0861/)
      a5 = (/-0.00498,-.00498,-0.00362,-.00498,-.0048045,-.00442189,-0.00221/)
      a6 = (/-0.477,-.477,-0.755,-.477,-.523792,-.605213,-.946/)
      a7 = (/0.,0.,-0.102,0.,-.030298,-.0640237,-.140/)
      sig0 = (/0.587,0.611,0.693,0.595,.6057,.6242,0.824/)
      clamp = (/3.,6.,0.,6.,6.,6.,0./)
c compute SOmerville median and dispersion estimates.
      dist1= sqrt(50.*50.+ 6.*6.)
c set up erf matrix p as ftn of dist,mag,period,level,flt type,atten type
      period=perx(iq)
      sp=perx(iq).gt.0.02 .and. perx(iq).lt. 0.5
      sig= sig0(iq)
      if(ir.eq.1)then
      gnd0=a1(iq)
      else
      gnd0=a1h(iq)
c hard rock varioation in Somerville only affects a1 coef.
      endif	
c-- loop through magnitudes
      do 104 m=1,nmag
      xmag0= magmin + (m-1)*dmag
c--- loop through atten. relations for each period
c-- gnd for SS; gnd2 for thrust; gnd3 for normal
      xmag= xmag0
        if(icode(ip,ia).eq.1)then
         xmag= 1.14 +0.24*xmag0+0.0933*xmag0*xmag0
        elseif(icode(ip,ia).eq.2)then
         xmag= 2.715 -0.277*xmag0+0.127*xmag0*xmag0
         endif
         gndm= gnd0 + a2(iq)*(xmag-6.4)+ a7(iq)*(8.5-xmag)*(8.5-xmag)
      weight= wt(ip,ia,1)
c-- loop through distances
      do 103 ii=1,ndist
      dist0= (float(ii)-0.5)*di
      if(dist0.lt.distnf) then
      sigp= sig + sigmanf
      else
      sigp=sig
      endif
      sigmasq= sigp *sqrt2
      if(dist0.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
c what about using variable h below?
      dist= sqrt(dist0*dist0+ 6.*6.)
      if(dist0.lt.50.) then
      gnd= gndm + a3(iq)*alog(dist)+a4(iq)*(xmag-6.4)*alog(dist)
     &  + a5(iq)*dist0 
        else
      gnd= gndm + a3(iq)*alog(dist1)+a4(iq)*(xmag-6.4)*alog(dist)
     & +a5(iq)*dist0 + a6(iq)*(alog(dist)-alog(dist1))
      endif
c---following is for clipping gnd motions: 1.5g PGA, 3.0g  for 0.3s, 3.0g 0.2s sa median 
          if(period.eq.0.)then
           gnd=min(0.405,gnd)
           elseif(sp)then
           gnd=min(gnd,1.099)
           endif
           test0=gnd + 3.*sigmasq/sqrt2
      test= exp(test0)
      if(clamp(iq).lt.test .and. clamp(iq).gt.0.) then
      clamp2= alog(clamp(iq))
      else
       clamp2= test0
       endif
      tempgt3= (gnd- clamp2)/sigmasq
      probgt3= (erf(tempgt3)+1.)*0.5
      do 102 k=1,nlev(ip)
      temp= (gnd- xlev(k,ip))/sigmasq
      temp1= (erf(temp)+1.)*0.5
      temp1= (temp1-probgt3)/(1.-probgt3)
      if(temp1.lt.0.) goto 103      !no more calcs once p<0
      do kk=1,ntor
c Somerville: no variation in median wrt depth to seismicity. Just fill out kk index
c with same scalar
      pr(ii,m,k,ip,kk,1)= pr(ii,m,k,ip,kk,1) + weight*temp1
      enddo
  102 continue
  103 continue
  104 continue
      return
      end subroutine getSomer

ccccccccccccccccccccccccc
      subroutine getAS97(ip,iq,ia,ndist,di,nmag,
     &  magmin,dmag,sigmanf,distnf)
c ip = period index in array to be filled
c iq = period index in the perx array
c adapted to nga style. july 2006. SHarmsen
        parameter (sqrt2=1.414213562)
      real magmin
      logical deagg
      common/mech/wtss,wtrev,wtnormal
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
c wtor = weights to top of rupture. these are applied in main, to rate matrices.
c do not apply wtor here! added 3-s coeffs aug 2006. removed 3-s, oct2006.
      real, dimension(7):: as1,as2,as3,as4,as5,as6
      real, dimension(7)::  as9,as12,as13,asc1,asc4,b5,b6
      real perx(8),sig,sigp,sigmasq
      common / atten / pr, xlev, nlev, icode, wt, wtdist
      common/deagg/deagg
      real pr(310,38,20,8,3,3),xlev(20,8),wt(8,10,2),wtdist(8,10) 
      integer nlev(8),icode(8,10)
        perx= (/0.,0.2,1.0,0.1,0.3,0.5,2.0,-1./)
      as1= (/1.64,2.406,0.828,2.16,2.114,1.615,-0.15/)
      as2= (/0.512,0.512,0.512,0.512,0.512,0.512,0.512/)
      as3= (/-1.145,-1.115,-0.8383,-1.145,-1.035,-0.9515,-0.725/)
      as4= (/-0.144,-0.144,-0.144,-0.144,-0.144,-0.144,-0.144/)
      as5= (/0.61,0.610,0.49,0.610,0.610,0.5810,0.40/)
      as6= (/0.26,0.26,0.013,0.26,0.198,0.119,-0.094/)
      as9= (/0.37,0.37,0.281,0.37,0.37,0.37,0.16/)
      as12= (/0.,-0.0138,-0.102,0.0280,-0.036,-0.0635,-0.14/)
      as13= (/0.17,0.17,0.17,0.17,0.17,0.17,0.17/)
      asc1= (/6.4,6.4,6.4,6.4,6.4,6.4,6.4/)
      asc4= (/5.6,5.1,3.7,5.5,4.8,4.3,3.5/)
      b5= (/0.70,0.77,0.83,0.74,0.78,0.8,0.85/)
      b6= (/0.135,0.135,0.118,0.135,0.135,0.13,0.105/)
      if(deagg)stop'hazgridXnga2: AS97 not set up for deagg work'
c         write(6,*) "enter a1,a2,a3,a4,a5,a6,h,ithrust"
c         read(1,*) as1,as2,as3,as4,as5,as6,h,ithrust
c         write(6,*) "enter a9,a12,a13,c1,c4,b5,b6"
c         read(1,*) as9,as12,as13,asc1,asc4,b5,b6
c         write(6,*)'getAS',period,as9,as12,b5,b6
c set up erf matrix p as ftn of dist,mag,period,level,flt type,atten type
c-- loop through magnitudes. Collect magnitude-dependent calculations 
      do 104 m=1,nmag
      xmag0= magmin + (m-1)*dmag
c-- gnd is ln(median Sa estimate)
        xmag= xmag0
c icode not used for mag conversions with AS97
        if(xmag.lt.7.0) then
        sig= b5(iq)- b6(iq)*(xmag-5.0)
        else
        sig= b5(iq)- 2.*b6(iq)
        endif 
        if(xmag.le.asc1(iq)) then
          gndm = as1(iq)+as2(iq)*(xmag-asc1(iq))+as12(iq)*((8.5-xmag)**2)
        else 
          gndm = as1(iq)+as4(iq)*(xmag-asc1(iq))+as12(iq)*((8.5-xmag)**2)
      endif
c loop over depth of top of seismicity
c  depth to top may be a distrribution.
c distances are based on d_tor distribution New July 2006.
      do 103 kk=1,ntor
      Hsq = dtor(kk)**2	!2003version of code wasnt ready for variable dtor.
c-- loop through distances
      do 103 ii=1,ndist
      dist0= (ii-0.5)*di 
      weight= wt(ip,ia,1)
      if(dist0.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
      dist1= sqrt(dist0*dist0 + Hsq)
        if(dist0.lt.distnf)then
         sigp = sig+ sigmanf
         else
         sigp=sig
         endif
        sigmasq= sigp *sqrt2
          r= sqrt(dist1*dist1+ asc4(iq)*asc4(iq))
           gnd = gndm+ (as3(iq)+ as13(iq)*(xmag-asc1(iq)))*alog(r)

c following calculations for reverse-slip sources
c use wtrev to control amount of reverse-faulting effect. wtrev replaces
c ithrust, which was 1 for total effect and 2 for half effect.        
      if(wtrev.gt. 0.0)then
        if(xmag.le.5.8) then
          fltfac= as5(iq)
        elseif(xmag.lt.asc1(iq))then
           fltfac= as5(iq)
     &        +(as6(iq)-as5(iq))*(xmag-5.8)/(asc1(iq)-5.8)
        else
           fltfac= as6(iq)
        endif
          gnd= gnd + wtrev*fltfac
          endif      	! wtrev>0
c no hanging wall for gridded seismicity in 2002. Or here.
c          if(ii.eq.1)write(6,*)r,xmag,gnd,fltfac
      do 102 k=1,nlev(ip)
      temp= (gnd- xlev(k,ip))/sigmasq
      temp1= (erf(temp)+1.)*0.5
      temp1= (temp1- 1.3499e-3)/0.99865
      if(temp1.lt.0.) goto 103      !safe to leave when pr<0
      pr(ii,m,k,ip,kk,1)= pr(ii,m,k,ip,kk,1) + weight*temp1
  102 continue
  103 continue
  104 continue
      return
      end subroutine getAS97

ccccccccccccccccccccccccccccc
      subroutine getCamp2003(ip,iq,ia,ndist,di,nmag,
     &     magmin,dmag,sigmanf,distnf)
c  Campbell and Bozorgnia (2003). Adapted to nga style. Coeffs for BC rock
c are below. 7 spectral periods, see perx(j),j=1,...,7.
c could add an ir index for soil conditions. These other than BC models not ready
        parameter (sqrt2=1.414213562)
      real magmin
      common/mech/wtss,wtrev,wtnormal
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
       common/prob/p(25005),plim,dp2   !table of complementary normal probab
c wtor = weights to top of rupture. these are applied in main, to rate matrices.
c Do not apply wtor here.
      common / atten / pr, xlev, nlev, icode, wt, wtdist
      common/deagg/deagg
      real pr(310,38,20,8,3,3),xlev(20,8),wt(8,10,2),wtdist(8,10) 
      integer nlev(8),icode(8,10)
      real c1(7),c2(7),c3(7),c4(7),c5(7),c6(7),c7(7),c8(7),c9(7)
      real c10(7), c11(7), csite(7), c15(7),c1s(7)
      real csigma1(7),csigmacoef(7),csigma2(7),cmagsig(7),mfac
       logical deagg
      real perx(8),period
      c1= (/-4.033,-2.771,-3.867,-2.661,-2.999,-3.556,-4.311/)
      c2= (/0.812,0.812,0.812, 0.812,0.812,0.812,0.812/)
      c3= (/0.036,0.030,-.101,0.060,.007,-0.035,-0.180/)
      c4= (/ -1.061,-1.153,-.964,-1.308,-1.080,-0.964,-0.964/)
      c5= (/0.041,0.098,0.019,0.166,0.059,0.023,0.019/)
      c6= (/-0.005,-0.014,0.,-0.009,-0.007,-0.002,0./)
      c7= (/-.018,-0.038,0.,-0.068,-0.022,-0.004,0./)
      c8= (/0.766,0.704,0.842,0.621,0.752,0.842,0.842/)
      c9= (/0.034,0.026,-.105,0.046,0.007,-0.036,-0.187/)
      c10= (/0.343,0.296,0.329,0.224,0.359,0.406,0.060/)
      c11= (/0.351,0.342,0.338,0.313,0.385,0.479,0.064/)
      c15= (/.370,.370,0.281,0.370,0.370,0.370,0.160/)	!HW effect.
      csite= (/-0.289,-0.331,-0.607,-0.299,-0.453,-0.528,-0.649/)	!is this a vs30-dependent term?
      csigma1= (/0.920,0.981,1.021,0.958,0.984,0.990,1.021/)
      csigmacoef= (/0.07, 0.07,0.07,0.07, 0.07,0.07,0.07/)
      csigma2= (/.402,0.463,0.503,0.44,0.466,0.472,0.503/)
      cmagsig= (/ 7.4,7.4,7.4,7.4,7.4,7.4,7.4/)
        perx = (/0.,0.2,1.0,0.1,0.3,0.5,2.0,-1./)      !-1 shall be reserved for pgv
c set up erf matrix p as ftn of dist,mag,period,level,flt type,atten type
      period=perx(iq)	!not used, might need for debug.
c      if(period.lt.0.)stop'cb2003 : pgv estimation not available'
c hanging-wall term could be added if we had a pdf for hanging wall below
c the site. When we assume half the background sources are reverse-slip,
c it stands to reason
c that P[hanging wall site] > 0.25 whenever dist0< 1 km. 
c However, the extra kick from potentially sitting on HW is not included.
      if(deagg)stop'hazgridXnga13l: no deagg poss for CB03'
      gnd0 = c1(iq) + 0.5*wtrev*(c10(iq) + c11(iq))
      write(6,*)'Camp2003 const term (no csite) ',gnd0
      gnd0 = gnd0 + csite(iq)
c---- above for reverse-slip or  thrust component, now communicated as wtrev
c-- loop through magnitudes
      do 104 m=1,nmag
      xmag0= magmin +(m-1)*dmag
        xmag= xmag0
        if(icode(ip,ia).eq.1)then
         xmag= 1.14 +0.24*xmag0+0.0933*xmag0*xmag0
        elseif(icode(ip,ia).eq.2)then
         xmag= 2.715 -0.277*xmag0+0.127*xmag0*xmag0
         endif
      mfac=(8.5-xmag)*(8.5-xmag)
      gndm = gnd0 + c2(iq)*xmag + c3(iq)*mfac
      arg0= exp (c8(iq)*xmag + c9(iq)*mfac)
c Below: magnitude-dependent dispersion, common through 2003. Dropped in NGA
          if(xmag.lt.cmagsig(iq))then
           csigma= csigma1(iq)- csigmacoef(iq)*xmag
          else
          csigma= csigma2(iq)
          endif
c loop through depth to top
      do 104 kk=1,ntor
      Hsq = max(dtor(kk),5.)	!old code wasnt ready for variable dtor.
      Hsq=Hsq*Hsq
c-- loop through distances
      do 103 ii=1,ndist
      dist0= (ii-0.5)*di       !epicentral or rjb km
      weight= wt(ip,ia,1)
      if(dist0.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
      dist= sqrt(dist0*dist0 + Hsq)      !dist here is r_seis. H is 5 km min.
      arg= dist*dist + ((c5(iq) + 0.5*c6(iq) +0.5*c7(iq))*arg0)**2
      arg= sqrt(arg)
      gnd = gndm + c4(iq)*alog(arg) 
      if(ii.lt.5.and.m.lt.3)write(*,*) arg, xmag, dist0, exp(gnd)
          if(dist0.lt.distnf) then
          csigmap= csigma+ sigmanf
          else
          csigmap=csigma
          endif
      sigmasq= csigmap*sqrt2
      do 102 k=1,nlev(ip)
      tmp= (gnd- xlev(k,ip))/sigmasq
        if(tmp.gt.3.3)then
       ipr=25002
       elseif(tmp.gt.plim)then
       ipr= 1+nint(dp2*(tmp-plim))	!3sigma cutoff n'(mu,sig)
       else
       goto 102	!transfer out if ln(SA) above mu+3sigma
       endif
 199  pr(ii,m,k,ip,kk,1)= pr(ii,m,k,ip,kk,1)+weight*p(ipr)  !sum thru ia index
  102 continue
  103 continue
  104 continue
      return
      end subroutine getCamp2003

cccccccccccccccc
      subroutine getGeom(ip,ir,ia,slab,ndist,di,nmag,
     &     magmin,dmag,vs30)
c  Geomatrix (Youngs et al. intraslab). modified to NGA style.
c Nov 19 2008: add several periods out to 5s from Youngs' email and spreadsheet
c Oct 2008: limit M to 8 following AB03 suggestion (BSSA p 1709). However,
c Geomatrix specified no upper limit. There are no data for inslab prediction
c for these very large M
c July 25 2006. Steve Harmsen. FOR rock or deep soil.
c ip = period index in outer loop.
c ir=1 rock site 
c ir=2 soil site. Further mod occurs for nonlin soil.
c ir=3 transition between rock and soil
c Vs30 is now input. Use ir=1 to get rock-site coeffs, then modify with nonlin siteamp
c Now distinguishing C-class from D-class from E-class...July 2009.
c TS-3 subcomittee recommends using 1/2 wt rock and 1/2 wt soil to approximate
c the C site class (Crouse memo of april 3 2007). Modified to use the BA NGA
c siteamp model July 2009
c This subr. has been modified to use BA_NGA siteamp w/nonlinear response. THis
c is the main change from hazgridXnga4.f to hazgridXnga13l.f.
c  Add SDI option Mar 20 2013
c
      parameter (np=13,sqrt2=1.4142136, vref=760.)
      common/sdi/sdi,dy_sdi,fac_sde
      real, dimension(8):: fac_sde
      real magmin, dy_sdi, rhat, sdisd
      logical deagg,lvs,slab, sdi
      integer islab/0/	!0 for interface 1 for inslab new july2010
      common/ipindx/iperba(10),ipgeom(10)
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
c wtor = weights to top of Benioff zone (km). these are applied in main, to rate matrices.
c do not apply wtor here! dtor replaces "gch" of 2002 code. Dtor allows a distribution if 
c you are uncertain about what that depth is.
c Also, dtor should not have a period dependence. It can have a magnitude dependence.
       common/prob/p(25005),plim,dp2   !table of complementary normal probab
      common / atten / pr, xlev, nlev, icode, wt, wtdist
      common/e0_sub/e0_sub(310,31,8,3)
      common/deagg/deagg
      dimension pr(310,38,20,8,3,3),xlev(20,8),nlev(8),icode(8,10),
     + wt(8,10,2),wtdist(8,10) 
      real gc0/0.2418/,gcs0/-0.6687/,ci/0.3846/,cis/0.3643/
      real gch/0.00607/,gchs/0.00648/,gmr/1.414/,gms/1.438/
      real period,gnd0,gndz,gz,g3,g4,gndm,vgeo(3)
       real, dimension(np):: gc1,gc2,gc3,gc4,gc5,gc1s,gc2s,gc3s,pergeo
c array constructors oct 2006. add 3s feb 2008
C vgeo is a reference vs30 for Geomatrix, 760 m/s rock, 300 m/s soil.
c Additional siteamp will be wrt these values from Frankel discussion july 7
      vgeo=(/760.,300.,475./)
         pergeo= (/0.,0.2,1.0,0.1,0.3,0.5,2.0,.4,0.75,1.5,3.,4.,5./)
       gc1= (/0.,0.722,-1.736,1.1880,0.246,-0.4,-3.3280,
     + -0.115,-1.149,-2.634,-4.511,-5.350,-6.025/)
       gc2= (/0.,-0.0027,-0.0064,-0.0011,-0.0036,-0.0048,-0.0080,
     + -0.0042,-.0057,-.0073,-.0089,-.0096,-.0101/)
       gc1s= (/0.,1.549,-2.87,2.516,0.793,-.438,-6.4330,0.144,-1.704,
     + -5.101,-6.672,-7.618,-8.352/)
       gc2s= (/0.,-0.0019,-0.0066,-0.0019,-0.002,-0.0035,-0.0164,
     + -.002,-.0048,-0.0114,-0.0221,-0.0235,-0.0246/)
       gc3= (/-2.556,-2.528,-2.234,-2.6550,-2.454,-2.36,-2.107,
     + -2.401,-2.286,-2.16,-2.033,-1.98,-1.939/)
       gc3s= (/-2.329,-2.464,-1.785,-2.697,-2.327,-2.140,-1.29,
     + -2.23,-1.95,-1.47,-1.347,-1.272,-1.214/)
       gc4= (/1.45,1.45,1.45,1.45,1.45,1.45,1.55,
     + 1.45,1.45,1.50,1.65,1.65,1.65/)
       gc5= (/-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,
     + -0.1,-0.1,-0.1,-0.1,-0.1,-0.1/)
c set up erf matrix p as ftn of dist,mag,period,level,depth-to-top-of-Benioff-zone
c----  for PGA    ADF. add some more for PGA. SH
      lvs = abs(vs30-vgeo(ir)).gt.0.01*vgeo(ir)
        iq=ipgeom(ip)
        if(slab)then
        islab=1
        else
        islab=0
        endif
      if(lvs)then
          g1p= gc1(1)
          g2p= gc2(1)
          g3p= gc3(1)
          g4p=1.7818
          gep=0.554
          gmp=gmr
          gnd0p=gc0+ci*islab
          endif
      if(ir.eq.1)then
c rock coeffs when vs30>520.
        gnd0=gc0 +ci*islab
        gz=gch
        g1=gc1(iq)
        g2=gc2(iq)
          g3=gc3(iq)
          g4=1.7818
          ge=0.554
          gm=gmr
      elseif(ir.eq.2)then
c soil coeffs when vs30 < 400.0
        gnd0=gcs0 +cis*islab
        gz=gchs
        g1=gc1s(iq)
        g2=gc2s(iq)
           g3=gc3s(iq)
           g4=1.097
           ge=0.617
           gm=gms
         else
c           rockf=(vs30-400.)/150.
c           soilf=1.0-rockf
c           gnd0=rockf*(gc0 +ci)+soilf*(gcs0 +cis*islab)
c           gz=rockf* gch     + soilf*gchs
c        g1= rockf* gc1(i1) + soilf*gc1s(iq) 
c        g2= rockf* gc2(i1) + soilf*gc2s(iq)          
c        g3= rockf* gc3(i1) + soilf*gc3s(iq)
c        g4= rockf* 1.7818  + soilf*1.097 
c        ge= rockf* 0.554   + soilf*0.617
c        gm= rockf* gmr     + soilf*gms
c linear combinations of coeffs doesn't cut it. highly nonlinear response fcn.
      stop' No plan for your ir into getGeom'
      endif
      period = pergeo(iq)
5      format(/,a,f6.2,1x,f6.2)
c loop through dtor (depth of benioff zone. could be one number like 50 km.)
      do 104 kk=1,ntor
      zsq=dtor(kk)**2
      gndz=gnd0 +dtor(kk)*gz +g1
c frankel addn, gndzp for nonlin site response. Gch below is a rock coef.
        if(lvs)gndzp= gnd0p+dtor(kk)*gch +g1p

c-- loop through magnitudes
      do 104 m=1,nmag
      xmag0= magmin +(m-1)*dmag
        xmag= xmag0
      if(iq.eq.3)
     +write(39,5)'# dist(km) exp(gnd),  amp(g),  pganl in  getGeom 
     *Xnga13l M=',xmag,period
c added Oct 22 2008. Limit magnitude to 8.0 (see AB03 bSSA p 1703). "saturation effect" 
      xmag=min(8.0,xmag)       
          sig= gc4(iq)+gc5(iq)*xmag
          sigmasq= sig*sqrt2
c same sigma for soil and rock.
          gndm= gndz +gm*xmag +g2*((10.-xmag)**3) 
c frankel addn, gndmp
          if(lvs)then
          gndmp= gndzp+gmp*xmag+ g2p*((10.-xmag)**3)
          argp= exp(gep*xmag)
        endif
          arg= exp(ge*xmag)
c Distance could be hypocentral or distance to top-of-Benioff zone.
c-- loop through distances
      do 103 ii=1,ndist
      dist0= (ii-0.5)*di       !dist0 is epicentral or r_jb
      weight= wt(ip,ia,1)
      if(dist0.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
c dist is rcd or rrup in getGeom.
      dist= sqrt(dist0*dist0+ zsq)      
          gnd=gndm +g3*alog(dist+g4*arg)
      if(lvs )then
c frankel mods for nonlin siteamp July 2009. Use g4p (rock g4) SH.
            gndp=gndmp+g3p*alog(dist+g4p*argp)
            pganl= exp(gndp)
c      write(6,*) "before basiteamp",pganl,exp(gnd)
c The below call
c to basiteamp produces an amplitude ratio in the variable amp. chnge to 
c function.
c            call basiteamp(pganl,vs30,vgeo(ir),period,amp)
c      if(iq.eq.3.and.ii.lt.20)write(39,*) dist,exp(gnd),exp(amp),pganl
            gnd= gnd + basiteamp(pganl,vs30,vgeo(ir),ip)
      endif      !vs30 .ne. vgeo(ir), the reference Vs for soil or rock, geom.
c add SDI otpion Mar 20 2013
       if(sdi)then
       sde=gnd+fac_sde(ip)	!fac_sde is log(T**2/(4pisq))
       rhat = min(10.,exp(sde)/dy_sdi)	!10 is an upper bound for rhat.
       gnd = sdi_ratio(period,xmag,rhat,sigm,sdisd) + sde
       sigmasq=sdisd*sqrt2	!use sdi for all gnd_ep branches
       endif	!sdi requested?

      do 199 k=1,nlev(ip)
      tmp= (gnd- xlev(k,ip))/sigmasq
        if(tmp.gt.3.3)then
       ipr=25002
       elseif(tmp.gt.plim)then
       ipr= 1+nint(dp2*(tmp-plim))	!3sigma cutoff n'(mu,sig)
       else
       goto 102	!transfer out if ln(SA) above mu+3sigma
       endif
       fac=weight*p(ipr)
      if(deagg)e0_sub(ii,m,ip,kk) = e0_sub(ii,m,ip,kk) -sqrt2 * tmp*fac
 199  pr(ii,m,k,ip,kk,1)= pr(ii,m,k,ip,kk,1)+ fac !sum thru ia index
  102 continue
  103 continue
  104 continue
      return
      end subroutine getGeom

ccccccccccccccc
      subroutine getABsub(ip,iq,ir,slab,ia,ndist,di,nmag,
     &     magmin,dmag,vs30)
c +++ Atkinson and Boore subduction zone intraslab.
c        modified for gfortran, f95 Oct 2006.
c +++ Add interface source modeling July 14 2010.
c mod Oct 22 2008. M upper limit at 8.0 (AB03, BSSA v93 #4, p 1709)
c this subr. was slightly modified apr 10 2007, for NEHRP C- and D- site classes
c See A&B BSSA v93 # 4 pp1703+.
c Input vars:
c ip = global period index, ip may be 1 to npmax (10?)
c iq = index of period in peri or perx array below.
c ir controls rock or soil, pacnw or world
c ir=0 PNW b rock (this was not in code)
c ir=1 PNW bc rock
c ir=2 PNW, NEHRP c soil (about 500-550 m/s)
c ir=3 PNW, NEHRP D soil
c ir=4 PNW, NEHRP E soil
c ir=5 Worldwide b rock
c ir=6 Worldwide bc rock
c ir = 7 Worldwide,  NEHRP c soil (about 500-550 m/s)
c ir=8 Worldwide NEHRP D soil
c ir=9 Worldwide NEHRP E soil
c slab = logical var: .false. for interface .true. for intraplate or slab eq.
c  magmin = smallest M for filling pr() array
c  vs30  = avg vs in top 30 m. added july 2009. SH. Site response defined in
c  broad NEHRP site classes, is not continuous with Vs30. 
c Outputs:
c  pr(dist, mag, gmindex,...) = probability of exceedance array.
c	can be exceedance of spectral displacement if sdi = .true. Mar 20 2013.
c
c +++ Coeffs for 9 spectral pds.
      parameter (np=9,sqrt2=1.4142136,gfac=2.9912261,aln10=2.30258509)
c
c gfac = log10(980). rc1 is region dependent; ww c1w coeff mod mar 22 2007
       parameter(rc2= 0.6909,rc3= 0.01130,rc4= -0.00202, vref=760.)
       parameter(rs2=0.03525,rs3=0.00759,rs4=-0.00206)
      logical deagg
        real magmin
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
      common/sdi/sdi,dy_sdi,fac_sde
      real, dimension(8):: fac_sde
c wtor = weights applied to top of Benioff zone locations (km). 
c These are applied in main, as factors to rate matrices.
c do not apply wtor here. dtor replaces "depth" of 2002 code. Dtor allows a distribution if 
c you are uncertain about what that depth is.
       common/prob/p(25005),plim,dp2   !table of complementary normal probab.
      common/e0_sub/e0_sub(310,31,8,3)
c last dim of e0_sub is ia model, 
      common / atten / pr, xlev, nlev, icode, wt, wtdist
      common/deagg/deagg
      logical slab, sdi
      dimension pr(310,38,20,8,3,3),xlev(20,8),nlev(8),icode(8,10),
     + wt(8,10,2),wtdist(8,10)
      real, dimension(np) :: c1,c1w,c2,c3,c4,c5,c6,c7,sig,perx
      real, dimension(np+1) :: s1,s2,s3,s4,s5,s6,s7,pcor,ssig,peri
      real, dimension(np+1) :: s1g,s2g,s3g,s4g,s5g,s6g,s7g
      real period
c array constructors oct 2006.  Add 3s SA Feb 2008. Add 0.75s dec 08
c add c7 may 13 2009. C7 corresponds to E soil.
      if(slab)then
      r2=rc2; r3=rc3; r4=rc4
      perx= (/0.,0.2,1.0,0.1,0.3,0.5,0.75,2.0,3./)      !-1 shall be reserved for pgv
      c1= (/ -0.25,0.40,-0.98,0.160,0.195,-0.172,-0.67648,-2.250,-3.64/)
      c1w=(/-0.04713,0.51589,-1.02133,0.43928,0.26067,-0.16568,-0.69924,-2.39234,
     + -3.70012/)      ! global c1 coeffs.
      c2= (/0.6909,0.69186,0.8789,0.66675,0.73228,0.7904,0.84559,0.99640,1.1169/)
       c3= (/0.01130,0.00572,0.00130,0.0108,0.00372,0.00166,0.0014349,0.00364,.00615/)
       c4= (/-0.00202,-0.00192,-0.00173,-0.00219,-0.00185,-0.00177,-.0017457,-0.00118,
     + -0.00045/)
      c5= (/0.19,0.15,0.10,.15,0.1383,0.125,.10941,0.100 ,0.1/)
       c6= (/0.24,0.27,0.30,0.23,0.3285,0.353,0.322,0.25,0.25/)
       c7= (/0.29,0.25,0.55,0.20,0.3261,0.4214,0.4966,0.40,0.36/)	
      sig= (/0.27,0.28,0.29,.28,0.280,0.282,0.2869,0.300,0.30/)      !BASE 10 SIGMA
      period = perx(iq)
          sigmasq= sig(iq)*sqrt2*aln10
      else      !subduction
c For subduction events, recommendation is M7.5 up and R<300 km.
c coefficients for subduction, Table 1 p 1715 & T3, p 1726. 
c Definitions: s1g global, s1 Cascadia.
c 10/17/2008: Cubic Splines were used for several 3.33 and 2 hz Global-estimation coefs. 
c Interested in the details? See intAB03.table.f for src code. uses Numerical recipes. 
c s1g has been recomputed for 2.0, 2.5, 3.33 and 5hz. Ditto s2g ,...
c Cannot Add 4 and 5 s. Not available. Nov 19 2008.
      peri= (/0.,0.2,1.0,0.1,0.3,0.4,0.5,0.75,2.0,3.0/)      
       r2=rs2; r3=rs3; r4=rs4
      s1g=(/2.991,2.5711536,2.1442,2.7789,2.6168785,2.6175463,2.536019,2.288355,2.1907,2.301
     + /)
      s1=(/2.79,2.54,2.18,2.5,2.516,2.50,2.418,2.241635,2.33,2.36/)
      s2=(/.03525,.12386,.1345,.09841,.1373,0.1477,.1444,0.14504924,.07148,.02237/)
      s2g=(/.03525,0.13976128,.1345,.09841,0.13694176,0.13179871,0.1324168,0.13728201,.07148,.02237/)
      s3=(/.00759,.00884,.00521,.00974,.00789,0.00728,.00671,5.9208343E-3,.00224,.00012/)
      s3g=(/.00759,7.79948E-3,.00521,.00974,8.12251E-3,8.32052E-3,7.951397E-3,6.429092E-3,.00224,.00012/)
      s4=(/-0.00206,-.0028,-0.0011,-.00287,-.00252,-0.00235,-.00195,-1.5903986E-3,0.,0./)
      s4g=(/-0.00206,-2.49985E-3,-0.0011,-.00287,-2.6353553E-3,-2.6501498E-3,-2.4560375E-3 ,-1.7370114E-3,0.,0./)
      s5=(/0.19,0.15,0.10,0.15,0.14,0.13,0.12,0.106354214,0.10,0.10/)
      s5g=(/0.19,0.13666,0.10,0.15,0.1429013,0.14334,0.13579784,0.11287035,0.10,0.10/)
      s6= (/0.24,0.23,0.30,0.23,0.253,0.37,0.277,0.34101113,.25,0.25/)
      s6g= (/0.24,0.32338,0.30,0.23,0.30005046,0.27662,0.32512766,0.2953982,.25,0.25/)
c s7 corresponds to site class E 
      s7=(/0.29,0.25,0.55,0.2,0.319,0.38,0.416,0.53479433,0.4,0.36/)
      s7g=(/0.29,0.33671,0.55,0.2,0.29974141,0.29329,0.34473022,0.49243947,0.4,0.36/)
      ssig=(/0.23,0.28,0.34,0.27,0.286,0.29,0.31,0.34,0.34,0.36/)
        pcor= (/-0.00298,-0.00290,-0.00536,0.,-0.00225,0.,0.,0.,0.,-0.0052/)
        period = peri(iq)
      sigma=ssig(iq)
      sigmasq=sigma*sqrt2*aln10
        endif
c set up erf matrix p as ftn of dist,mag,period,level,flt type,atten type
          sigmaf= 1.0/sigmasq
      if(period.ne.0.)then
       freq= 1./period
      else
      freq= 100.
      endif
            amp_nl = 0.0	!nonlinear siteamp addition AF
c      if(ip.eq.1)open(15,file='ab.tmp',status='unknown')
c       write(6,*)'Ab data going to log file nmag, ntor=',nmag,ntor
      if(ir.lt.5.and.slab)then
      gnd0=c1(iq)
      r1=c1(1)
      c02=c2(iq)
      c03=c3(iq)
      c04=c4(iq)
      c05=c5(iq)
      c06=c6(iq)
      c07=c7(iq)
      elseif(slab)then
c constant term for world wide data set regr. & slab events
      gnd0=c1w(iq)
      r1=c1w(1)
      c02=c2(iq)
      c03=c3(iq)
      c04=c4(iq)
      c05=c5(iq)
      c06=c6(iq)
      c07=c7(iq)
      elseif(ir.lt.5)then
      gnd0=s1(iq)
      r1=s1(1)
          c02=s2(iq);c03=s3(iq);c04=s4(iq)
          c05=s5(iq);c06=s6(iq);c07=s7(iq)
      else
c constant term for world wide data set regr. & interface events
      gnd0=s1g(iq)
      r1=s1g(1)
          c02=s2g(iq);c03=s3g(iq);c04=s4g(iq)
          c05=s5g(iq);c06=s6g(iq);c07=s7g(iq)
      endif
c-- loop through magnitudes
      do 104 m=1,nmag
      xmag0= magmin +(m-1)*dmag
c--- loop through atten. relations for each period
c-- gnd for SS; gnd2 for thrust; gnd3 for normal
c remove the possible mag conversion. Assume Mw coming in.
c added Oct 22 2008. Limit magnitude to 8.0 (see AB03 bSSA p 1703). "saturation effect" 
      xmag=min(8.0,xmag0)       
          delta= 0.00724*(10.**(0.507*xmag))
          if(slab)then
          g= 10.**(0.301-0.01*xmag)
          else
c g = 2 for M=5 event. 
           g= 10.**(1.2-0.18*xmag)
           endif
           gndm=gnd0+c02*xmag

c loop through depth of slab or interface seismicity
      do 104 kk=1,ntor	!new 7/06. 
      depth=dtor(kk)
      depthp=min(depth,100.)	!additional constraint 3/07
      dsq=depth*depth
c-- loop through distances., ii is rjb distance index.
      do 103 ii=1,ndist
      dist0= (float(ii)-0.5)*di 
      weight= wt(ip,ia,1)
      if(dist0.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
      dist= sqrt(dist0*dist0+ dsq)
          dist2= sqrt(dist*dist + delta*delta)
          gnd= gndm+c03*depthp+c04*dist2
     &         -g*alog10(dist2)
c--- calculate rock PGA for BC site amp. R1 varies with source type and region
c--- interface or inslab. rpga units are cm/s/s.
       rpga= r1+ r2*xmag + r3*depthp+ r4*dist2- g*alog10(dist2)
       rpga= 10.**rpga
       if((rpga.le.100.).or.(freq.le.1.))then
        sl=1.
       elseif((rpga.gt.100.).and.(rpga.lt.500.).and.(freq.gt.1.).and.
     &   (freq.lt.2.)) then
       sl= 1.-(freq-1.)*(rpga-100)/400.
       elseif((rpga.ge.500.).and.(freq.gt.1.).and.(freq.lt.2.)) then
        sl= 1.-(freq-1.)
       elseif((rpga.gt.100.).and.(rpga.lt.500.).and.(freq.ge.2.)) then
        sl= 1.-(rpga-100.)/400.
c       if((rpga.ge.500.).and.(freq.ge.2.)) sl= 0.
      else
      sl=0.
      endif
c-----
c---   Site Amp for NEHRP classes, AB style. No siteamp if ir.eq.0 .or. ir.eq.5 (B rock)
      if(ir.eq.0 .or. ir.eq.5 )then
      gnd = gnd - gfac
      elseif (ir.eq.1.or.ir.eq.6)then
c---   take log ave of B (rock) and C site
          gnd= gnd + (sl*c05)*0.5 - gfac
c use original formulation of siteamp in getABsub
          elseif (ir.eq.2.or.ir.eq.7)then
c --- C-soil site condition, added Apr 10, 2007.
      gnd = gnd + sl*c05 - gfac
          elseif (ir.eq.3.or.ir.eq.8)then
c === D site class coeff in c6. There was a 0.5 factor below for awhile. this
c factor does not appear in the paper of Aug 2003, page 1706. I removed it apr 10
c 2007.
          gnd= gnd + sl*c06 - gfac
          elseif (ir.eq.4.or.ir.eq.9)then
c === E site class coeff in c7. added may 2009.
          gnd= gnd + sl*c07 - gfac
      endif          
c log base 10 to base e. 
          gnd= gnd * aln10 
c      if(kk.eq.1.and.ii.eq.1..and.m.eq.4)
       if(sdi)then
       sde=gnd+fac_sde(ip)	!fac_sde is log(T**2/(4pisq))
       rhat = min(10.,exp(sde)/dy_sdi)	!10 is an upper bound for rhat.
       gnd = sdi_ratio(period,xmag,rhat,sigma,sdisd) + sde
       sigmaf=1./sdisd/sqrt2	!use sdi for all gnd_ep branches
       endif	!sdi requested?

c     + write(6,*) period, xmag, dist, exp(gnd), rpga, sl,weight,xlev(1,ip)
       do 199 k=1,nlev(ip)
      tmp= (gnd- xlev(k,ip))*sigmaf
        if(tmp.gt.3.3)then
       ipr=25002
       elseif(tmp.gt.plim)then
       ipr= 1+nint(dp2*(tmp-plim))	!3sigma cutoff n'(mu,sig)
       else
       goto 102	!transfer out if ln(SA) above mu+3sigma
       endif
       fac=weight*p(ipr)
c       print *,ii,m,ip,fac,' absub'
       if(deagg)e0_sub(ii,m,ip,kk)= e0_sub(ii,m,ip,kk)-sqrt2*tmp*fac
199   pr(ii,m,k,ip,kk,1)= pr(ii,m,k,ip,kk,1)+  fac   !sum thru ia index
  102 continue
  103 continue
  104 continue      !mag and depth counters
      return
      end subroutine getABsub

cccccccc
      subroutine getCampCEUS(ip,iq,ir,ia,ndist,di,nmag,
     &     magmin,dmag,sigmanf,distnf)
c----- Campbell 2001 CEUS modified for nga style, with all coeffs internal defined.
c-----
      parameter (np=11,sqrt2=1.4142136,alg70=4.2484952,alg130=4.8675345)
c precompute log(70) and log(130) used below.
c seismicity depth comes in via depth_rup now. Not h() as in 2002.
c inputs ip,iq period
c ir=1 BC or firm rock
c ir=2 A or hard rock. Only difference is in constant term (check this)
        real magmin,probgt3,tempgt3,gnd,cmagsig
      logical et,deagg,sp	!short period; if true a CEUS gm bound applies.
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
c wtor = weights applied to top of CEUS seismicity (km). 
      common / atten / pr, xlev, nlev, icode, wt, wtdist
       common/e0_ceus/e0_ceus(310,31,8)
      common/deagg/deagg
      dimension pr(310,38,20,8,3,3),xlev(20,8),nlev(8),icode(8,10),
     + wt(8,10,2),wtdist(8,10) 
      real,dimension(np):: c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,
     1 clamp,c1h,c11,c12,c13,perx
c
       perx = (/0.01,0.2,1.0,0.1,0.3,0.4,
     + 0.5,2.0,.03,.04,.05/)
      c1= (/0.4492,.1325,-.3177,.4064,-0.1483,-0.17039,
     + -0.1333,-1.2483,1.68,1.28,0.87/)
      c1h= (/0.0305,-0.4328,-.6104,-0.1475,-.6906,-0.67076736,
     + -.5907,-1.4306,1.186,0.72857,0.3736/)
      c2= (/.633,.617,.451,.613,0.609,0.5722637,
     + 0.534,0.459,.622,.618622,.616/)
      c3= (/-.0427,-.0586,-.2090,-.0353,-0.0786,-0.10939892,
     + -0.1379,-0.2552,-.0362,-.035693,-.0353/)
      c4= (/-1.591,-1.32,-1.158,-1.369,-1.28,-1.244142,
     + -1.216,-1.124,-1.691,-1.5660,-1.469/)
      c5= (/.683,.399,.299,0.484,0.349,0.32603806,
     + 0.318,.310,0.922,0.75759,0.630/)  !paper's c7
      c6= (/.416,.493,.503,0.467,0.502,0.5040741,
     + 0.503,.499,.376,0.40246,0.423/) !paper's c8
      c7= (/1.140,1.25,1.067,1.096,1.241,1.1833254,
     + 1.116,1.015,0.759,0.76576,0.771/) !paper's c9
      c8= (/-.873,-.928,-.482,-1.284,-.753,-0.6529481,
     + -0.606,-.4170,-.922,-1.1005,-1.239/) !paper's c10
      c9= (/-.00428,-.0046,-.00255,-.00454,-.00414,-3.7463151E-3,
     + -.00341,-.00187,-.00367,-.0037319,-.00378/) !paper's c5
      c10= (/.000483,.000337,.000141,.00046,.000263,2.1878805E-4,
     + .000194,.000103,.000501,.00050044,.0005/) !paper's c6
      c11= (/1.030,1.077,1.110,1.059,1.081,1.0901983,
     + 1.098,1.093,1.03,1.037,1.042 /)  !paper's c11
      c12= (/-.0860,-.0838,-.0793,-.0838,-0.0838,-0.083180725,
     + -0.0824,-.0758,-.086,-0.0848,-.0838/) !paper's c12
      c13= (/0.414,.478,.543,0.460,0.482,0.49511834,
     + 0.508,0.551,.414,0.43,.443/)  !paper's c13
c clamp for 2s set to 0 as per Ken Campbell's email of Aug 18 2008.
      clamp= (/3.0,6.0,0.,6.,6.,6.,3.0,0.,6.,6.,6./)
      period = perx(iq)
       cmagsig= 7.16
c set up erf matrix p as ftn of dist,mag,period,level,depth to seismicity,/
c--- Mmin=6.0 nmag=45 dmag=0.05
      sp = period.gt.0.02.and.period.lt.0.5
      if(ir.eq.1)then
      gnd0=c1(iq)
      else
      gnd0=c1h(iq)
      endif
c-- loop through magnitudes
      do 104 m=1,nmag
      xmag0= magmin+(m-1)*dmag
c--- loop through atten. relations for each period
c-- gnd for SS; gnd2 for thrust; gnd3 for normal
        xmag= xmag0
c Two mblg to Mw conversion rules
        if(icode(ip,ia).eq.1)then
         xmag= 1.14 +0.24*xmag0+0.0933*xmag0*xmag0
        elseif(icode(ip,ia).eq.2) then
        xmag= 2.715 -0.277*xmag0+0.127*xmag0*xmag0
        endif
      gndm = gnd0 + c2(iq)*xmag + c3(iq)*(8.5-xmag)*(8.5-xmag)
           if(xmag.lt.cmagsig) then
           csigmam= c11(iq)+ c12(iq)*xmag
           else
            csigmam= c13(iq)
            endif
            cfac = (c5(iq)*exp(c6(iq)*xmag))**2
c loop through dtor. There is a fictitious h term as well. how to use dtor?
      do 103 kk=1,ntor	!new 7/06
      h=max(dtor(kk),5.)	
c generally h was 5 km in the 2002 maps. For Charleston charactristic, h was 10 km.
      hsq=h*h 
      et= deagg .and. kk.eq.1
c-- loop through distances
      do 103 ii=1,ndist
      dist0= (float(ii) - 0.5)*di 
      weight= wt(ip,ia,1)
      if(dist0.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
      dist= sqrt(dist0*dist0 + hsq)
      arg= sqrt(dist*dist + cfac)
      if (dist.lt.distnf)then
      sigmasq=(csigmam+sigmanf)*sqrt2
      else
      sigmasq=csigmam*sqrt2
      endif
      fac=0.
      if(dist.gt.70.) fac= c7(iq)*(alog(dist)- alg70)
      if(dist.gt.130.) fac= fac+ c8(iq)*(alog(dist)-alg130)
      gnd = gndm + c4(iq)*alog(arg) + fac +(c9(iq)+c10(iq)*xmag)*dist
c      write(12,*) period,dist0,xmag,exp(gnd)
c--- following is for clipping 
c---following is for clipping gnd motions: 1.5g PGA, 3.00g 0.3, 3.0g 0.2 
          if(period.lt.0.018)then
           gnd=min(0.405,gnd)
           elseif(sp)then
           gnd=min(gnd,1.099)
           endif
           test0=gnd + 3.*sigmasq/sqrt2
       test= exp(test0)
      if(clamp(iq).lt.test .and. clamp(iq).gt.0.) then
      clamp2= alog(clamp(iq))
      else
       clamp2= test0
      endif
      tempgt3= (gnd- clamp2)/sigmasq
      probgt3= (erf(tempgt3)+1.)*0.5
      do 102 k=1,nlev(ip)
      temp= (gnd- xlev(k,ip))/sigmasq
      temp1= (erf(temp)+1.)*0.5
      temp1= (temp1-probgt3)/(1.-probgt3)
      if(temp1.lt.0.) goto 103      !safe to transfer out once prob < 0
      fac=weight*temp1
      pr(ii,m,k,ip,kk,1)= pr(ii,m,k,ip,kk,1) + fac
      if(et)e0_ceus(ii,m,ip)= e0_ceus(ii,m,ip)-sqrt2*temp*fac
  102 continue
  103 continue
  104 continue
      return
      end subroutine getCampCEUS

cccccc
      subroutine getBJF97(ip,iq,ia,ndist,di,nmag,
     & magmin,dmag,sigmanf,distnf)
c prepared for the general vs30 case july 26 2006 (no nonlinear site resp here) SH
c also prepared for 7 periods. based on Frankel's getBJF97     
      parameter (np=7,sqrt2=1.4142136,pi=3.141592654)
      real magmin,perx(8),sigma_fx,sigmaf
      common/fix_sigma/fix_sigma,sigma_fx	!add option to fix sigma_aleatory.
      common/prob/p(25005),plim,dp2	!table of complementary normal probab.
      common/geotec/vs30,d	!assume vs30 is fixed for all sites. "Soil map" "rock map" etc
      common / atten / pr, xlev, nlev, icode, wt, wtdist
      common/mech/wtss,wtrev,wtnormal
      logical fix_sigma
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
      dimension pr(310,38,20,8,3,3),xlev(20,8),nlev(8),icode(8,10),
     + wt(8,10,2),wtdist(8,10) 
        real, dimension(np):: b1ss,b2,b3,b4,b5,hsq,sigma,
     + b1rv,b1all,bv,va
c array constructors oct 2006
      b1all= (/-0.242,1.089,-1.08,1.059,0.70,-.25,-1.743/)
        bv= (/-.371,-.292,-.698,-.212,-.401,-.553,-.655/)
        va= (/1396.,2118.,1406.,1112.,2133.,1816.,1795./)
      b1ss= (/-.313,0.999,-1.133,1.006,0.598,-.268,-1.699/)
      b1rv= (/-.117,1.17,-1.009,1.087,.803,.087,-1.801/)
      b1all= (/-.242,1.089,-1.08,1.059,0.70,-0.025,-1.743/)
      b2= (/0.527,0.711,1.036,0.753,0.769,0.884,1.085/)
      b3= (/0.,-0.207,-0.032,-.226,-.161,-.09,-.085/)
      b4= (/0.,0.,0.,0.,0.,0.,0./)
      b5= (/-0.778,-0.924,-0.798 ,-.934,-.893,-.846,-.812/)   
c      h= (/5.57,7.02,2.90,6.27,5.94,4.13,5.85/)
      hsq= (/31.0249,49.2804,8.41,39.3129,35.2836,17.0569,34.2225/)
      sigma= (/0.520,0.502,0.613,0.479,0.522,0.556,0.672/)
       perx= (/0.,0.2,1.0,0.1,0.3,0.5,2.0,-1./)
c      data norm/0.053,0.090,0.053,4*.05/
c set up erf matrix p as ftn of dist,mag,period,level,flt type,atten type
      if(fix_sigma)then
      sig=sigma_fx
      else
          sig= sigma(iq)
          endif
c mech-dependent and site Vs30 dependency
      gnd0=b1ss(iq)*wtss+b1rv(iq)*wtrev+b1all(iq)*(1.-wtss-wtrev)
      gnd0=gnd0+bv(iq)*alog(vs30/va(iq))
      write(6,*)'Entering getBJF97 nlev,gnd0=',nlev(ip),gnd0
c-- loop through magnitudes
      do 104 m=1,nmag
      xmag0= magmin + (m-1)*dmag
c--- loop through atten. relations for each period
c-- gnd for SS; gnd2 for thrust; gnd3 for normal
        xmag= xmag0
          gndm= gnd0 +b2(iq)*(xmag-6.)+b3(iq)*(xmag-6.)**2
c-- following for Joyner Boore WUS
c-- loop through distances
      do 103 ii=1,ndist
      dist0= (ii-0.5)*di
      weight= wt(ip,ia,1)
      if(dist0.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
      dist= sqrt(dist0*dist0+hsq(iq))
          gnd= gndm + b4(iq)*dist + b5(iq)*alog(dist)
          if(dist0.lt.distnf) then
          sigp= sig+ sigmanf
          else
          sigp=sig
          endif
          sigmaf= 1/sigp/sqrt2
      do 102 k=1,nlev(ip)
      tmp= (gnd- xlev(k,ip))*sigmaf
        if(tmp.gt.3.3)then
       ipr=25002
       elseif(tmp.gt.plim)then
       ipr= 1+nint(dp2*(tmp-plim))	!3sigma cutoff n'(mu,sig)
       else
       goto 102	!transfer out if ln(SA) above mu+3sigma
       endif
        tmp = weight*p(ipr)  !sum thru ia index. Epistemic gm model weight
      do  kk=1,ntor
c no variation of bjf formulation median or sd with depth of seismicity
      pr(ii,m,k,ip,kk,1)= pr(ii,m,k,ip,kk,1) + tmp
      enddo      !no sensitivity to depth of seismicity.
  102 continue
  103 continue
  104 continue
      return
      end subroutine getBJF97

cccccc
      subroutine getMota(ip,iq,ia,ndist,di,nmag,
     & magmin,dmag,sigmanf,distnf)
c--  for Motazedian and Atkinson 2003 Puerto Rico relations
c adaptations: predefine some frequently used scalars. Add variable dtor capability.
c dtor is depth to top of rupture (e.g., 5km). Can be a distribution, a cloud of uncertainty.
      parameter (np=7,alg75=1.8750613,sqrt2=1.41421356)
      parameter (vref=760.0,aln10=2.30258509,alg=2.99122608)
c alg = log10(980)      
      real magmin,deltasq,sig,sigi,sigmasq,sigmanf,perx(8)
c perx is a standard set of periods in the order shown. Data statements correspond to
c these spectral periods. For example pga coefficients are the 1st element of c1, c2,... vectors.
c modified to nga style, July 26 2006. SHarmsen includes 2s, 1s, 0.2s, and PGA. others are void
c    
      common/geotec/vs30,d	! vs30 defined in calling program
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
c wtor = weights applied to top of PRVI seismicity (km). 
      common / atten / pr, xlev, nlev, icode, wt, wtdist
      common/deagg/deagg
      dimension pr(310,38,20,8,3,3),xlev(20,8),nlev(8),icode(8,10),
     + wt(8,10,2),wtdist(8,10) 
      logical deagg
      real, dimension(np):: c1,c2,c3,c4,sigma,bv,va
c array constructors 10/2006. SH
          perx= (/0.,0.2,1.0,0.1,0.3,0.5,2.0,-1./)      !-1 shall be reserved for pgv
        bv= (/-.371,-.292,-.698,-.212,-.401,-.553,-.655/)
        va= (/1396.,2118.,1406.,1112.,2133.,1816.,1795./)
      c1= (/3.87,4.33,3.40,3.,3.,3.,2.86/)
      c2= (/0.39062,0.38815,0.64818,1.,1.,1.,0.77055/)
      c3= (/-0.11289,-0.13977,-0.15222,0.,0.,0.,-0.11963/)
      c4= (/-0.00213,-0.00189,-0.00091,0.,0.,0.,-0.00082/)
      sigma= (/0.28,0.28,0.28,0.28,0.28,0.28,0.28/)
c site amp first, convert to base 10 for compatibility
c first try at siteamp is the BJF 97 version. no site nonlinearity. Needs work for better compatibility w/nga
      period = perx(iq)
      gnd0 = bv(iq)*alog(vs30/vref)/aln10
        sigi= sigma(iq)
      period=perx(iq)	!probably will not need period (s)	
c-- loop through magnitudes
      do 104 m=1,nmag
      xmag0= magmin + (m-1)*dmag
        xmag= xmag0
        if(icode(ip,ia).eq.1) then
           xmag1= 1.14 +0.24*xmag0+0.0933*xmag0*xmag0
           xmag2= 2.715 -0.277*xmag0+0.127*xmag0*xmag0
           xmag= 0.5*(xmag1+xmag2)
           endif
        deltasq = (-7.333 + 2.333*xmag)**2
c gnd0 the site term is added to the magnitude-dependent terms
        gndm=gnd0 +c1(iq)+c2(iq)*(xmag-6.)+c3(iq)*((xmag-6.)**2)
c-- loop through depth to seismicity (new july 2006)
      do 104 kk=1,ntor
      h=dtor(kk)
      hsq=h*h
c-- loop through distances
      do 103 ii=1,ndist
      dist0= (ii-.5)*di 
      dist0= sqrt(dist0*dist0 + hsq)
        if(dist0.lt.distnf) then
        sig= sigi+ sigmanf
        else
        sig=sigi
        endif
        sigmasq= sig*sqrt2*aln10
      weight= wt(ip,ia,1)
      if(dist0.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
        dist= sqrt(dist0*dist0 + deltasq)
        gnd=  gndm + c4(iq)*dist
        if(dist.le.75.) then
        fac= (-1.88+0.14*xmag)*alog10(dist)
        elseif(dist.le.100.)then
        fac= (-1.88+0.14*xmag)*alg75
        else 
        fac= (-1.88+0.14*xmag)*alg75 -0.5*alog10(dist/100.)
        endif
        gnd= gnd + fac - alg
c alg serves to convert cm/s/s to g
c base10 to base e
        gnd= gnd*aln10
c      write(15,*) period,dist0,xmag,exp(gnd)
      do 102 k=1,nlev(ip)
      temp= (gnd- xlev(k,ip))/sigmasq
      temp1= (erf(temp)+1.)*0.5
      temp1= (temp1- 1.3499e-3)/0.99865
      if(temp1.lt.0.) goto 103      !safe to leave once pr<0
      pr(ii,m,k,ip,kk,1)= pr(ii,m,k,ip,kk,1) + weight*temp1
  102 continue
  103 continue
  104 continue
      return
      end subroutine getMota


ccccccccccc
      subroutine ASNGA08
     + (ip,iper,ia,ndist,di,nmag,magmin,dmag,vs30_class,depthvs10,rxsign,DIP)
c Should work for mix of stike-slip, rev, normal. But not sure about hanging wall
c  How often is it "on?"  SH.
      real fType, vs30, pgaRock,
     1       srcSiteA, lnSa, sigma, tau, period1, sigma1, depthtop, width,
     2       depthvs10, lnSaTD, lnSa1, lnSa2, lnSaRock,dy_sdi
      real sqrt2
      parameter (sqrt2=1.414213562)   
      real gnd_ep(3,3,8),mcut(2),dcut(2),gndx
      logical e_wind(8)
      dimension pr(310,38,20,8,3,3),xlev(20,8),nlev(8),icode(8,10),
     + wt(8,10,2),wtdist(8,10) 
      real dp2
      real, dimension(3) :: gnd
c rxsign = instruction to put all sites on footwall if <0, on hangingwall side if >0.
      real mag, magmin,dip, aspectRatio, rRUp, rjb,rxsign
      real tau1, hw, F
      integer iper, iper1, iper2,ia
c set up erf matrix p as ftn of dist,mag,period,level,atten type       
c We may need to do something more about fault type (or mix of 'em)
       real, dimension (108):: period
       real, dimension(8):: fac_sde
        real, dimension(0:9) :: rxfac
      logical sdi
      integer hwflag,  vs30_class,ip

c 
       common/sdi/sdi,dy_sdi,fac_sde
      common/prob/p(25005),plim,dp2	!table of complementary normal probab.
      common / atten / pr, xlev, nlev, icode, wt, wtdist
      common/mech/wtss,Frv,Fn
      common/dipinf_90/dipang,cosDELTA,cdipsq,cyhwfac,cbhwfac
      common/geotec/vs30,dbasin
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3) 
      common/epistemic/nfi,e_wind,gnd_ep,mcut,dcut
      data period / 0.0, -1.0, -2.0, 0.01, 0.02, 0.022, 0.025, 0.029,
     1              0.03, 0.032, 0.035, 0.036, 0.04, 0.042, 0.044, 
     2              0.045, 0.046, 0.048, 0.05, 0.055, 0.06, 0.065, 
     3              0.067, 0.07, 0.075, 0.08, 0.085, 0.09, 0.095, 0.1, 
     4              0.11, 0.12, 0.13, 0.133, 0.14, 0.15, 0.16, 0.17, 
     5              0.18, 0.19, 0.2, 0.22, 0.24, 0.25, 0.26, 0.28, 0.29, 
     6              0.3, 0.32, 0.34, 0.35, 0.36, 0.38, 0.4, 0.42, 0.44,
     7              0.45, 0.46, 0.48, 0.5, 0.55, 0.6, 0.65, 0.667, 0.7,
     8              0.75, 0.8, 0.85, 0.9, 0.95, 1.0, 1.1, 1.2, 1.3, 1.4, 
     9              1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.2, 2.4, 2.5, 2.6, 2.8, 
     1              3.0, 3.2, 3.4, 3.5, 3.6, 3.8, 4.0, 4.2, 4.4, 4.6, 4.8, 
     1              5.0, 5.5, 6.0, 6.5, 7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 10.0 /
       rxfac=(/0.,0.5,1.,2.,3.,4.,4.5,5.,5.5,6./)

c     VS30 class is to distinguish between the sigma if the VS30 is measured
c     vs the VS30 being estimated from surface geology.
c         Vs30_class = 1 for measured 
c         Vs30_class = 0 for estimated
      specT = period(iper)
        srcsitea= 90.      !this could be input
c        print *,ip,iper,specT,ia,ndist,di,nmag,magmin,dmag,vs30_class,depthvs10,rxsign,DIP
c--- 
c-- loop through magnitudes
      do 104 kk=1,ntor
      DepthTop=dtor(kk)
      iimin=max(1,nint(DepthTop))
      do 104 m=1,nmag
      mag= magmin+(m-1)*dmag
      Width=  mag +2*rxfac(icode(ip,ia))	! fltwidth 
c--- loop through atten. relations for each period
c-- gnd can have extra epistemic uncert.
       if(e_wind(ip))then
          if(mag.lt.mcut(1))then
          ime=1
          elseif(mag.lt.mcut(2))then
          ime=2
          else
          ime=3
          endif
        endif !extra epistemic
c-- loop through distances
      do 103 ii=1,ndist
      rjb=(ii-0.5)*di      !rjb near zero when site over source. Not identically zero.
       if(RJB.lt.wtdist(ip,ia))then
        weight= wt(ip,ia,1)
        else
       weight= wt(ip,ia,2)
      endif        
      if(e_wind(ip))then
          if(RJB.lt.dcut(1))then
          ide=1
          elseif(RJB.lt.dcut(2))then
          ide=2
          else
          ide=3
          endif
          gndx=gnd_ep(ide,ime,ip)
          endif
      rrup = sqrt ( rjb**2 +DepthTop**2)      !this is a basic assumption of the code. 
      rrup2=rrup*rrup
c     compute pga on rock
        R_x = rxsign*(RJB+rxfac(icode(ip,ia)))      !same test model as in CB12. Needs work.
      period0 = 0.0
      pgaRock = 0.0
      vs30_rock = 1100.
      depthvs10rock = 0.006
      if (R_x.lt.0.5)then
      hwflag=1
      else
      hwflag=0
      endif
c removed rake because it is not used in AS_072007_model
      call AS_072007_model (iper, mag, dip, width, rRup, rjb,R_x,
     1                     vs30_rock, pgaRock,  lnSa, sigma, tau,
     2                     period0, depthTop, Frv, Fn,  vs30_class,
     3                     depthvs10rock, hwflag )

      pgaRock = exp(lnSa)

c     Compute the spectral period for the constant displacement model
c     (Eq. 22)
      TD = 10**(-1.25+0.3*mag)
      if (specT .ge. TD) then
c         Compute Sa at TD spectral period for Vs30=1,100m/sec
          call AS_072007_model (iper, mag, dip, width, rRup, rjb,R_x,
     1                     vs30_rock, pgaRock, lnSaTD, sigmaX, tauX, 
     2                     TD, depthtop, Frv, Fn,  vs30_class, 
     3                     depthvs10rock, hwflag )

          lnSaRock = lnSaTD + alog((TD*TD)/(specT*specT))

c         Compute Sa at spectral period for Vs30
          call AS_072007_model (iper, mag, dip, width, rRup, rjb,R_x,
     1                     vs30, pgaRock,  lnSa1, sigma, tau, 
     2                     specT, depthtop, Frv, Fn,  vs30_class, 
     3                     depthvs10, hwflag )
c         Compute Sa at spectral period for Vs30=1,100m/sec
          call AS_072007_model (iper, mag, dip, width, rRup, rjb,R_x,
     1                     vs30_rock, pgaRock,  lnSa2, sigmaX, tauX, 
     2                     specT, depthtop, Frv, Fn,  vs30_class, 
     3                     depthvs10rock, hwflag )
C         Compute soil amplification (i.e., 'lnSa1-lnSa2') and add to Constant displcaement rock spectrum
          lnSa = lnSaRock + (lnSa1-lnSa2)
 
      else
C         For cases where specT < TD compute regular ground motions. 
          call AS_072007_model (iper, mag, dip, width, rRup, rjb,R_x,
     1                     vs30, pgaRock, lnSa, sigma, tau, 
     2                     specT, depthtop, Frv, Fn,  vs30_class, 
     3                     depthvs10, hwflag )
      endif

c     compute Sa (given the PGA rock value)
      sigma1 = sqrt( sigma**2 + tau**2 )
      sigmaf= 1.0/(sigma1*sqrt2)
           gnd(1)=lnSA
           if(ii.eq.1.and.ip.eq.1)print *,mag,lnSA,lnSaRock,pgaRock,sigma1
       if(sdi)then
       sde=gnd(1)+fac_sde(ip)      !fac_sde is log(T**2/(4pisq))
       rhat = min(10.,exp(sde)/dy_sdi)      !10 is an upper bound for rhat.
       gnd(1) = sdi_ratio(specT,mag,rhat,sigma1,sdisd) + sde
       lnSA=gnd(1)      !actually log (inelastic displ. median)
       sigmaf=1./sdisd/sqrt2      !use sdi for all gnd_ep branches
       endif      !sdi requested?
         if(e_wind(ip))then
         gnd(2)= lnSA+gndx
         gnd(3)= lnSA-gndx
         endif
      do ie=1,nfi
      do 199 k= 1,nlev(ip)
        tmp=(gnd(ie) - xlev(k,ip))*sigmaf
       if(tmp.gt.3.3)then
       ipr=25002
       elseif(tmp.gt.plim)then
       ipr= 1+nint(dp2*(tmp-plim))	!3sigma cutoff n'(mu,sig)
       else
       goto 102	!transfer out if ground motion above mu+3sigma
       endif
199        pr(ii,m,k,ip,kk,ie)= pr(ii,m,k,ip,kk,ie)+weight*p(ipr)      !sum thru ia index and mech types...
102      continue
        enddo      !ie loop
103       continue

  104 continue
      return
      end subroutine ASNGA08
c ----------------------------------------------------------------------


      subroutine getIdriss
     + (ip,iq,ia,ndist,di,nmag,magmin,dmag,sigmanf,distnf)
c Oct 2005: for pga only.
c ip is period index in calling program. 
c iq is period index in this subroutine. But there is no need for period
c subscripting because only pga is available.
      parameter (pi=3.14159265,sqrt2=1.414213562,vref=760.)
      common/epistemic/nfi,e_wind,gnd_ep,mcut,dcut
      real gnd_ep(3,3,8),mcut(2),dcut(2),gndout(3),gndx
      logical e_wind(8),deagg
      common/prob/p(25005),plim,dp2	!table of complementary normal probab.
      common/mech/wtss,wtrev,wtnormal
      common/dipinf_90/dipang,cosDELTA,cdipsq,cyhwfac,cbhwfac

      common/geotec/vs30,dbasin
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
      common / atten / pr, xlev, nlev, icode, wt, wtdist
      common/deagg/deagg
      real pr(310,38,20,8,3,3),xlev(20,8),wt(8,10,2),wtdist(8,10) 
      integer nlev(8),icode(8,10)

      real ylev(20,8) 
c----  assumes v30= 760 m/sec
c----  uses ln coefficients
      real magmin,dmag,sigmanf,distnf
      real a1/2.14/,a2/0.134/,b1/2.8/,b2/-0.197/
      real phi/0.08/,sigma/0.68/
      real a16/6.052/,a26/-.473/,b16/3.256/,b26/-0.273/
      if(ip.ne.1)stop'getIdriss: pga only.'
      if(deagg)stop'getIdriss not available for deaggs'
c coeffs. from oct 5 2005 powerpoint progress report
c set up erf matrix p as ftn of dist,mag,period,level. For gridded hazard,
c atten types are averaged with weight from common/atten/
          sig= sigma
          gndx=0.0
          sigmaf= 1./sig/sqrt2
c-- loop through magnitudes
c-- 
       do 104 m=1,nmag
       xmag0= magmin+(m-1)*dmag
c--- loop through atten. relations for each period
c-- gnd for SS; gnd2 for thrust; gnd3 for normal
        xmag= xmag0
       if(e_wind(ip))then
          if(xmag.lt.mcut(1))then
          ime=1
          elseif(xmag.lt.mcut(2))then
          ime=2
          else
          ime=3
          endif
        endif !extra epistemic
      weight= wt(ip,ia,1)
c-- loop through distances. What about nearest distance for gridded?
      do 103 ii=1,ndist
      rjb=(ii-0.5)*di      !minimum src-site Joyner-Boore distance 0.5 km WUS gridded
      if(e_wind(ip))then
          if(rjb.lt.dcut(1))then
          ide=1
          elseif(rjb.lt.dcut(2))then
          ide=2
          else
          ide=3
          endif
          gndx=gnd_ep(ide,ime,ip)      !gndx = additional epistemic uncert
         endif      !extra epistemic
          dist= rjb      !Idriss distance
      dist0=dist
      if(dist0.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
          if(xmag.lt.6.0) then
          gnd= a1+a2*xmag-(b1+b2*xmag)*alog(dist+10.)
        else
          gnd= a16+a26*xmag- (b16+b26*xmag)*alog(dist+10.)
          endif
          gnd= gnd+ wtrev*phi
c          gnd3= gnd
c no variation for normal slip compared to ss.
      gndout(1)=gnd
      gndout(2)=gnd + gndx
      gndout(3)=gnd - gndx

      do ifn=1,nfi
        do  k= 1,nlev(ip)
        tmp=(gndout(ifn) - xlev(k,ip))*sigmaf
       if(tmp.gt.3.3)then
       ipr=25002
       elseif(tmp.gt.plim)then
       ipr= 1+nint(dp2*(tmp-plim))	!3sigma cutoff n'(mu,sig)
       else
       goto 102	!transfer out if ground motion above mu+3sigma
       endif
      do  kk=1,ntor
c for Idriss, dtor is not a carrier variable.
 199  pr(ii,m,k,ip,kk,ifn)= pr(ii,m,k,ip,kk,ifn)+weight*p(ipr)      !This step sums thru ia index
       enddo	!kk
       enddo	!k
102      continue
      enddo	!ifn
103      continue	!distance
104      continue	!mag
      return
      end subroutine getIdriss


      subroutine getBooreNGA308
     + (ip,iq,ia,ndist,di,nmag,magmin,dmag,sigmanf,distnf)
c Coeffs from Apr 02 2007 documentation & out file (oct 1 2007) file. Replaces  getBooreNGA207
c .  Includes 23 periods
c up to 10-s T.
c Modified according to a March 2008 BA document that says to use the
c PGA regression coeffs to estimate PGA_NL (March 20 2008 update)
c----  site vs30 comes in in /geotec/ common (Vs30 need not = 760 m/sec)
c mech type, imec: 1=ss, 2=rev, 3=normal. Not used here. Instead, weights to ss, rev, normal
c----  Has non-linear soil response unlike the earlier BJF models
c --- returns  pr() (probability of exceeding various M,R pairs at each sp. period).
c --- Tested smoothed siteamp for soils. Visually convincing 
c --- ip = period index, counting from 1 to nper, in input file
c --- iq = period index in per() associated with below coefficients 
      parameter (np=23)	!23 periods apr 2007. include 0.01 to 10 s 
      parameter (pi=3.14159265,sqrt2=1.414213562,vref=760.)
      parameter (dx=1.098612289,dxsq=1.206948961,dxcube=1.325968960,plfac=-0.510825624)
c dx = ln(a2/a1), made a param. used in a smoothed nonlin calculation sept 2006.
c plfac = ln(pga_low/0.1)      This never changes so shouldnt be calculated.
       common/sdi/sdi,dy_sdi,fac_sde
       real, dimension(8) :: fac_sde
      common/prob/p(25005),plim,dp2	!table of complementary normal probab.
      common/mech/wtss,wtrev,wtnormal
      common/fix_sigma/fix_sigma,sigma_fx	!add option to fix sigma_aleatory.
      common/geotec/vs30,dbasin
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
      common / atten / pr, xlev, nlev, icode, wt, wtdist
      common/deagg/deagg
      common/e0_wus/e0_wus(310,31,8,3,3)
      common/epistemic/nfi,e_wind,gnd_ep,mcut,dcut
      real gnd_ep(3,3,8),mcut(2),dcut(2),gndout(3)
      logical e_wind(8),fix_sigma
      real pr(310,38,20,8,3,3),xlev(20,8),wt(8,10,2),wtdist(8,10) 
      integer nlev(8),icode(8,10)
      real ptail(6),prlr
           real magmin,dmag,sigmanf,distnf,gndx,dy
      logical deagg,geocalc,sdi
c      !geocalc=.true. when vs30 is not equal to ref. rock veloc, vref ; sdi =.true. if computing 
c      inelastic Spectral Displacement.
c New Coef file: ba_02apr07_usnr.txt  T=10 s coeffs.longest period available.
c in the new coef file there is a series of coeffs for pga4nl. This needs to be worked on. SH Oct 3.
c period = -1 is PGV.
c nonlinear coefs updated 
c BA now suggest using the final PGA coefficients for PGAnl in a followup article to the Mar 08 Eq
c Spectra paper. 
c below coefficients are the pga coeffs which correspond to element 2 of the below arrays. 
c Update of Mar 20 2008.
      real e1nl/-0.53804/,e2nl/-0.50350/,e3nl/-0.75472/,e4nl/-0.50970/
      real e5nl/0.28805/,e6nl/-0.10164/,e7nl/0.0/
      real c1nl/-0.66050/,c2nl/0.11970/,c3nl/-0.011510/,hnl/1.35/,b1nl/0./
      real b2nl/0./,pga_low/0.06/,mhnl/6.75/,mrefnl/4.5/,rrefnl/1.0/
      real  pganl, pganlm,pganlmec
      real  a1/ 0.030/,a2/ 0.090/,a2fac/0.405465108/
      real per(np),e1(np),e2(np),e3(np),e4(np),e5(np),e6(np),e7(np),e8(np)
     + ,mh(np),c1(np),c2(np),c3(np),c4(np),mref(np),rref(np),h(np),
     + blin(np),b1(np),b2(np),v1(np),v2(np),
     +  sig1(np),sig2u(np),sigtu(np),sig2m(np),sigtm(np)
c e2,e3,e4 are the mech-dependent set. e1 is a mech-unspecified value.
c Notation change from subroutine version of 12/05 and earlier.
c array constructors for f95 Linux
c from ba_02apr07_usnr.xls coef file
      per= (/-1.000, 0.000, 0.010, 0.020, 0.030, 0.050, 0.075, 0.100,
     + 0.150, 0.200, 0.250, 0.300, 0.400, 0.500, 0.750, 1.000,
     + 1.500, 2.000, 3.000, 4.000, 5.000, 7.500,10.0/)
       e1= (/ 5.00121,-0.53804,-0.52883,-0.52192,-0.45285,-0.28476,
     1  0.00767, 0.20109, 0.46128, 0.57180, 0.51884, 0.43825, 0.39220, 0.18957,-0.21338,
     1 -0.46896,-0.86271,-1.22652,-1.82979,-2.24656,-1.28408,-1.43145,-2.15446/)
       e2= (/ 5.04727,-0.50350,-0.49429,-0.48508,-0.41831,-0.25022,
     1  0.04912, 0.23102, 0.48661, 0.59253, 0.53496, 0.44516, 0.40602, 0.19878,-0.19496,
     1 -0.43443,-0.79593,-1.15514,-1.74690,-2.15906,-1.21270,-1.31632,-2.16137/)
c Editorial comment I used the e3(10s)=e3(7.5)+e2(10s)-e2(7.5s) for 10s normal, because BA
c report e3(10s) as 0.0 and this gives a large motion compared to others in nhbd.
c also reported this to Dave Boore in email for his advice. SHarmsen Oct 3 2007. Gail suggests
c that ratio for normal might equal ratio for unspecified or ratio for SS. No consensus. Using
c Gail's sugg. This choice of e3(10s), -2.66, is very low. Normal median is probably too low.
       e3= (/ 4.63188,-0.75472,-0.74551,-0.73906,-0.66722,-0.48462,
     1 -0.20578, 0.03058, 0.30185, 0.40860, 0.33880, 0.25356, 0.21398, 0.00967,-0.49176,
     1 -0.78465,-1.20902,-1.57697,-2.22584,-2.58228,-1.50904,-1.81022, -2.66/)
       e4= (/ 5.08210,-0.50970,-0.49966,-0.48895,-0.42229,-0.26092,
     1  0.02706, 0.22193, 0.49328, 0.61472, 0.57747, 0.51990, 0.46080, 0.26337,-0.10813,
     1 -0.39330,-0.88085,-1.27669,-1.91814,-2.38168,-1.41093,-1.59217,-2.14635/)
       e5= (/ 0.18322, 0.28805, 0.28897, 0.25144, 0.17976, 0.06369,
     1  0.01170, 0.04697, 0.17990, 0.52729, 0.60880, 0.64472, 0.78610, 0.76837, 0.75179,
     1  0.67880, 0.70689, 0.77989, 0.77966, 1.24961, 0.14271, 0.52407, 0.40387/)
       e6= (/-0.12736,-0.10164,-0.10019,-0.11006,-0.12858,-0.15752,
     1 -0.17051,-0.15948,-0.14539,-0.12964,-0.13843,-0.15694,-0.07843,-0.09054,-0.14053,
     1 -0.18257,-0.25950,-0.29657,-0.45384,-0.35874,-0.39006,-0.37578,-0.48492/)
       e7= (/ 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     1  0.00000, 0.00000, 0.00000, 0.00102, 0.08607, 0.10601, 0.02262, 0.00000, 0.10302,
     1  0.05393, 0.19082, 0.29888, 0.67466, 0.79508, 0.00000, 0.00000, 0.00000/)
       e8= (/ 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     1  0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     1  0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000/)
       mh= (/ 8.50000, 6.75000, 6.75000, 6.75000, 6.75000, 6.75000,
     1  6.75000, 6.75000, 6.75000, 6.75000, 6.75000, 6.75000, 6.75000, 6.75000, 6.75000,
     1  6.75000, 6.75000, 6.75000, 6.75000, 6.75000, 8.50000, 8.50000, 8.50000/)
       c1= (/-0.873700,-0.660500,-0.662200,-0.666000,-0.690100,-0.717000,
     1 -0.720500,-0.708100,-0.696100,-0.583000,-0.572600,-0.554300,-0.644300,-0.691400,-0.740800,
     1 -0.818300,-0.830300,-0.828500,-0.784400,-0.685400,-0.509600,-0.372400,-0.098240/)
       c2= (/ 0.100600, 0.119700, 0.120000, 0.122800, 0.128300, 0.131700,
     1  0.123700, 0.111700, 0.098840, 0.042730, 0.029770, 0.019550, 0.043940, 0.060800, 0.075180,
     1  0.102700, 0.097930, 0.094320, 0.072820, 0.037580,-0.023910,-0.065680,-0.138000/)
       c3= (/-0.003340,-0.011510,-0.011510,-0.011510,-0.011510,-0.011510,
     1 -0.011510,-0.011510,-0.011130,-0.009520,-0.008370,-0.007500,-0.006260,-0.005400,-0.004090,
     1 -0.003340,-0.002550,-0.002170,-0.001910,-0.001910,-0.001910,-0.001910,-0.001910/)
       c4= (/ 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     1  0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     1  0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000/)
       mref= (/4.500,4.500,4.500,4.500,4.500,4.500,
     1 4.500,4.500,4.500,4.500,4.500,4.500,4.500,4.500,4.500,
     1 4.500,4.500,4.500,4.500,4.500,4.500,4.500,4.500/)
       rref= (/1.000,1.000,1.000,1.000,1.000,1.000,
     1 1.000,1.000,1.000,1.000,1.000,1.000,1.000,1.000,1.000,
     1 1.000,1.000,1.000,1.000,1.000,1.000,1.000,1.000/)
          h= (/2.540,1.350,1.350,1.350,1.350,1.350,
     1 1.550,1.680,1.860,1.980,2.070,2.140,2.240,2.320,2.460,
     1 2.540,2.660,2.730,2.830,2.890,2.930,3.000,3.040/)
      blin = (/-0.600,-0.360,-0.360,-0.340,-0.330,-0.290,
     1 -0.230,-0.250,-0.280,-0.310,-0.390,-0.440,-0.500,-0.600,-0.690,
     1 -0.700,-0.720,-0.730,-0.740,-0.750,-0.750,-0.692,-0.650/)
       b1= (/-0.500,-0.640,-0.640,-0.630,-0.620,-0.640,
     1 -0.640,-0.600,-0.530,-0.520,-0.520,-0.520,-0.510,-0.500,-0.470,
     1 -0.440,-0.400,-0.380,-0.340,-0.310,-0.291,-0.247,-0.215/)
       b2= (/-0.060,-0.140,-0.140,-0.120,-0.110,-0.110,
     1 -0.110,-0.130,-0.180,-0.190,-0.160,-0.140,-0.100,-0.060, 0.000,
     1  0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000/)
         v1= (/ 180., 180., 180., 180., 180., 180.,
     1  180., 180., 180., 180., 180., 180., 180., 180., 180.,
     1  180., 180., 180., 180., 180., 180., 180., 180./)
         v2= (/ 300., 300., 300., 300., 300., 300.,
     1  300., 300., 300., 300., 300., 300., 300., 300., 300.,
     1  300., 300., 300., 300., 300., 300., 300., 300./)
       sig1= (/0.500,0.502,0.502,0.502,0.507,0.516,
     1 0.513,0.520,0.518,0.523,0.527,0.546,0.541,0.555,0.571,
     1 0.573,0.566,0.580,0.566,0.583,0.601,0.626,0.645/)
      sig2u= (/0.286,0.265,0.267,0.267,0.276,0.286,
     1 0.322,0.313,0.288,0.283,0.267,0.272,0.267,0.265,0.311,
     1 0.318,0.382,0.398,0.410,0.394,0.414,0.465,0.355/)
      sigtu= (/0.576,0.566,0.569,0.569,0.578,0.589,
     1 0.606,0.608,0.592,0.596,0.592,0.608,0.603,0.615,0.649,
     1 0.654,0.684,0.702,0.700,0.702,0.730,0.781,0.735/)
      sig2m= (/0.256,0.260,0.262,0.262,0.274,0.286,
     1 0.320,0.318,0.290,0.288,0.267,0.269,0.267,0.265,0.299,
     1 0.302,0.373,0.389,0.401,0.385,0.437,0.477,0.477/)
      sigtm= (/0.560,0.564,0.566,0.566,0.576,0.589,
     1 0.606,0.608,0.594,0.596,0.592,0.608,0.603,0.615,0.645,
     1 0.647,0.679,0.700,0.695,0.698,0.744,0.787,0.801/)
c end of April 07 coeff. updates.
c----  Input vs30.  
c  ip index corresponds to period. (check per correspondence with main perx)
c--- 
      site=0.0	!site term, nonzero for nonrefernce vs30
      gndx=0.0	!additional epistemic may be reset below
5      format(a,$)	
c some calcs that are safely done outside dist and mag loops:
      if(fix_sigma) then
      sigmaf = 1./sigma_fx/sqrt2
      else
          sigmaf= 1./sigtu(iq)/sqrt2      ! used with erf( ) in rate/prob calcs. Unspecified mech
          endif
c      write(6,*)'period ',per(iq),' sigmaf ',sigmaf,' dy_sdi ',dy_sdi,' sdi?', sdi
c      geocalc=vref.ne.vs30
      if ( vref.ne.vs30 ) then
        geocalc=.true.
      else
        geocalc=.false.
      endif
      if(geocalc)then
c The slip-type dependency was not present in BA_NGA, oct 2007; but is present Mar 2008.
c The mec-dependent part of pganl is needed when vs30 is not equal to vref.  
          pganlmec =  e4nl*wtrev + e3nl*wtnormal + e2nl*wtss
        if(v1(iq).lt.vs30.and.vs30.le.v2(iq))then
c some site term precalcs that are not M or d dependent
        bnl=(b1(iq)-b2(iq))*
     + alog(vs30/v2(iq))/alog(v1(iq)/v2(iq)) + b2(iq)
        elseif(v2(iq).lt.vs30.and.vs30.le.vref)then
        bnl=b2(iq)*alog(vs30/vref)/alog(v2(iq)/vref)
        elseif(vs30.le.v1(iq))then
        bnl=b1(iq)
        else
        bnl=0.0
        endif
        endif
c We could have a d_tor loop. Because B&A model does not exhibit variation wrt d_tor,
c this loop is basically omitted (it is present as filler only).       
c--- loop through magnitudes
      do 104 m=1,nmag
      xmag0= magmin+(m-1)*dmag
c-- gnd for SS; will be modified if normal or thrust component is present
        xmag= xmag0
        if(e_wind(ip))then
          if(xmag.lt.mcut(1))then
          ime=1
          elseif(xmag.lt.mcut(2))then
          ime=2
          else
          ime=3
          endif
          endif !extra epistemic
      weight= wt(ip,ia,1)
          if(xmag.le.mh(iq)) then
          gndm = e5(iq)*(xmag-mh(iq))
     +  +e6(iq)*((xmag-mh(iq))**2)
          else
           gndm = e7(iq)*(xmag-mh(iq))
c     + +e8(iq)*((xmag-mh(iq))**2)      !commented out because e8 is zero
           endif
c compute magnitude-dependent part of pganl when it is needed 
          if(xmag.le.mhnl.and.geocalc)then
      pganlm= e1nl+e5nl*(xmag-mhnl)+e6nl*((xmag-mhnl)**2)
          elseif(geocalc)then
c no increase in Near-Field PGA above M=7.0, because e7nl is 0.
      pganlm= e1nl + e7nl*(xmag-mhnl)
           endif
c-- loop through distances. What about nearest distance for gridded?
      do 103 ii=1,ndist
      rjb=(ii-0.5)*di      !minimum src-site Joyner-Boore distance 0.5 km WUS gridded
      if(e_wind(ip))then
          if(rjb.lt.dcut(1))then
          ide=1
          elseif(rjb.lt.dcut(2))then
          ide=2
          else
          ide=3
          endif
          gndx=gnd_ep(ide,ime,ip)
          endif
          dist = sqrt(rjb*rjb+h(iq)**2)
          gnd = gndm + (c1(iq)+ c2(iq)*(xmag-mref(iq)))*alog(dist/rref(iq))
     +  +c3(iq)*(dist-rref(iq))      
c     +  +c4(iq)*(dist-rref(iq))*(xmag-mref(iq))       	
c 2nd continuation line commented out:nuisance
c computation because c4 is zero. Could change in the future.  Still 0 june 06.     
c below assumes that wtss+wtrev=1 or that wtss+wtnormal=1. tripartite case needs another look.
c For most spectral periods e4(ip)<e2(ip). The reverse-slip event effect will lower the median.
c The larger region where Rjb is zero for reverse slip would tend to counteract this. But, in
c this code we dont have dipping faults. All are vertical dipping. No rjb=0 effect to boost the tepid medians.
c We may need to build a model with some part of region with rjb 0 when wtrev>0.      
          gnd = gnd + e4(iq)*wtrev + e3(iq)*wtnormal + e2(iq)*wtss
c          if(ip.eq.1.and.m.lt.3)write(6,*)gnd,rjb,gndm,geocalc      
          if(.not.geocalc)goto 101
c Otherwise correct for non-reference site conditions.
c nonlinear effects, current to mar 20 2008. However no sigma variation is included
c Campbell however reduces sigma for large pga_rock.
          distnl = sqrt(rjb**2 + hnl*hnl)
c include magnitude-dependent part of pganl  

      pganl = pganlmec+pganlm
c
c This pganl is needed when vs30 is not equal to vref. Now compute the
c distance dependency of pganl and add it to current value (log domain). 
          pganl= pganl+ c1nl*alog(distnl/rrefnl)+c3nl*(distnl-rrefnl)
     1 + c2nl*(xmag-mrefnl)*alog(distnl/rrefnl)   
c Note Mar 20 2008 ***: c2nl is no longer zero. ***
          pganl=exp(pganl)      !units g
c bnl stuff computed outside loop : does not vary with mag or dist.          
c Below: include site term. C.f., site with 760 m/s vref.
c First part, linear siteamp as simple fcn of Vs30
        site = blin(iq)*alog(vs30/vref)
c Second part, nonlinear siteamp reductions below. Define dy sept 30 2008.
        dy=bnl*a2fac
        if(pganl.le.a1)then
        site=site+bnl*plfac
        pgafac=0.
        elseif(pganl.le.a2)then
c extra lines smooth a kink in siteamp, pp 9-11 of boore sept report.
c c and d from p 10 of boore sept report. Smoothing introduces extra calcs
c in the range a1 < pganl < a2. Otherwise nonlin term same as in june-july.
c many of these terms are fixed and are defined in data or parameter statements
c Of course, if a1 and a2 change from their sept 06 values the parameters will
c also have to be redefined. (a1,a2) represents a siteamp smoothing range (units g)
        c=(3.*dy-bnl*dx)/dxsq
        d=(bnl*dx-2.*dy)/dxcube
        pgafac=alog(pganl/a1)
        site=site+bnl*plfac + c*pgafac**2 + d*pgafac**3
        else
        site=site+bnl*alog(pganl/0.1)
        pgafac=0.
        endif
        gnd=gnd+site
101        gndout(1)=gnd
       if(sdi)then
       sde=gndout(1)+fac_sde(ip)      !fac_sde is log(T**2/(4pisq))
       rhat = min(10.,exp(sde)/dy_sdi)      !10 is an upper bound for rhat.
       gndout(1) = sdi_ratio(per(iq),xmag,rhat,sigtu(iq),sdisd) + sde
       sigmaf=1./sdisd/sqrt2      !use sdi for all gnd_ep branches
       endif      !sdi requested?
      gndout(2)=gndout(1)+gndx
      gndout(3)=gndout(1)-gndx
        do ifn=1,nfi
        do  k= 1,nlev(ip)
        tmp=(gndout(ifn) - xlev(k,ip))*sigmaf
c for deagg. only one gm level so k index is not needed. Nor is kk (below)
c weight is not applied. e0 is a BA-specific array
c        if(ip.eq.1.and.m.eq.3)write(6,*)tmp,gnd,xlev(k,ip),k,rjb,xmag
       if(tmp.gt.3.3)then
       ipr=25002
       elseif(tmp.gt.plim)then
       ipr= 1+nint(dp2*(tmp-plim))	!3sigma cutoff n'(mu,sig)
       else
       goto 102	!transfer out if ground motion above mu+3sigma
       endif
c       if(m.eq.1.and.ip.eq.1.and.k.eq.10)write(6,*)p(ipr),xmag,rjb,ipr
c loop through depth to top of rup. Doesnt affect anything for B&A relation.
c Note, if boore/atkinson rewrite their model, this kk index will probably have to be
c outside the M&R loops as in getCYNGA and getCBNGA
      fac = weight*p(ipr)
      do  kk=1,ntor
         pr(ii,m,k,ip,kk,ifn)= pr(ii,m,k,ip,kk,ifn)+fac	
      if(deagg)e0_wus(ii,m,ip,kk,ifn)= e0_wus(ii,m,ip,kk,ifn)-tmp*sqrt2*fac
       enddo	!kk
       enddo	!k
102      continue
      enddo	!ifn	
103      continue
104      continue
c Current BA model has nonlinear soil sigma same as linear-response sigma
      return
      end subroutine getBooreNGA308

      subroutine getCampNGA1107(ip,iq,ia,ndist,di,nmag,magmin,
     + dmag,sigmanf,distnf)
c....................................................................
c  Campbell and Bozorgnia NGA regression relation, Nov 2007. Mods of 11/07
c to get ground-motion dependent sigma from eqn(15) & (17) EQ Spectra Mar 2008
c  Based on 1-06 version written by Yuehua Zeng, USGS
c      and July & Sept NGA updates.  Steve Harmsen.7/24/2006,9/7/2006, 1/2007.
c modified sigma to sigma for the geometric mean of 2 h-components
c SHarmsen, Oct 17 2007. From Campbell telephone conversation w/Petersen
c C&B May 2007 report was checked and coeffs did not change at that time. SH 9/2007
c Note: this version only works if pga is called first, because it needs pga
c hard-rock value for subsequent period calcs.
c Steve Harmsen. Two or three terms change from Jan to June 2006
c In July there are 22 periods, see Pd() array for details. In sept, nonlinear
c soil effects are seen in the aleatory unceert estimates, more prominent
c at short periods but significant for soft soils (Vs30<200 m/s) for int&lp.
c In Nov 2006 update, there are 24 periods, including peak displacement; the
c aleatory uncert wrt ground motion has been removed. Now use uncert of
c random horiz. component, according to recommedation of C&B.
c Several input quantities come in via common// statements.
c Modified Feb 22 2013 to allow calc of SDI or inelastic spectral displacement
c
c  input: ip       :index for period in iatten(ip,ia). First period in input file has ip=1.
c         iq  : index of period in Pd() array below.
c         minmag : minimum Mw magnitude for table building.
c         rrup : closest fault distance
c         rjb  : distance to the fault projection on the surface
c        di	: distance increment for table building
c         wtrev  : weight associated with reverse slip, SH.
c        wtnor	: weight associated with normal slip. if wtnor>0, wtrev should be 0.
c         vs   : site S-velocity in m/s (Geotec quantity, equals top-30m or Vs30 )
c         H    : depth to top of the fault
c         d    : sediment depth now defined as Z2.5, depth to 2.5 km/s Vs.
c
c  output: probability of exceedance   pr array,
c which is a function of mag,distance, gm level, and sp. period.
c          
c          sigmaf= 1/sigma/sqrt2 = sigma-factor in natural log
c....................................................................
        parameter (np=24)
      parameter (sqrt2=1.414213562,rockcoef=0.240336,expm75=0.47236655)
c rockcoef = alog(1100/k1(1)), expm75=exp(-0.75)         
      common/epistemic/nfi,e_wind,gnd_ep,mcut,dcut
      real gnd_ep(3,3,8),mcut(2),dcut(2),gndout(3)
      real, dimension (0:310,31) :: avghwcb      !new dec 12
      logical fix_sigma,deagg,e_wind(8),sdi
       common/sdi/sdi,dy_sdi,fac_sde
       real, dimension(8) :: fac_sde
      common/fix_sigma/fix_sigma,sigma_fx	!add option to fix sigma_aleatory.
      common/e0_wus/e0_wus(310,31,8,3,3)
      common/prob/p(25005),plim,dp2	!table of complementary normal probab.
      common/mech/wtss,wtrev,wtnormal
      common/dipinf_90/dipang,cosDELTA,cdipsq,cyhwfac,cbhwfac
      common/dipinf_50/dipang2,cosDELTA2,cdip2sq,cyhwfac2,cbhwfac2
      common/geotec/vs30,dbasin
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
       common / atten / pr, xlev, nlev, icode, wt, wtdist
      common/deagg/deagg
      real sigsqu,spgasq/0.228484/,sln_Ab, sln_yb,sigma_fx
      real pgar(310,31),magmin,dmag,f1,f2,f3,f4,f5,f6,sigt,alpha,pga_rk
      save pgar
      real,dimension(np):: Pd,c0,c1,c2,c3,c4,c5,c6,c7,c8,
     1 c9,c10,c11,c12,k1,k2,k3,
     2 rhos,slny,tlny,slnAF,sC,sig_t
      real pr(310,38,20,8,3,3),xlev(20,8),wt(8,10,2),wtdist(8,10) 
      integer nlev(8),icode(8,10)
c coefficients from CB06_NGA_MODEL.txt. 24 periods available, -1 is PGV. 0.00 is PGA.
c SHarmsen Nov 15 2006. Pd=spectral period vector. The c* coeffs do not change in Sept 1 rev.
      Pd=(/0.010,0.020,0.030,0.050,0.075,0.100,0.150,0.200,0.250,0.300,0.400,0.500,0.750,
     + 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 7.5,10.0, 0.0,-1.0,-2.0/)
       c0=(/-1.715,-1.680,-1.552,-1.209,-0.657,-0.314,-0.133,-0.486,-0.890,-1.171,-1.466,-2.569,-4.844,
     + -6.406, -8.692, -9.701,-10.556,-11.212,-11.684,-12.505,-13.087, -1.715,  0.954, -5.270/)
       c1=(/ 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.500, 0.656, 0.972,
     + 1.196, 1.513, 1.600, 1.600, 1.600, 1.600, 1.600, 1.600, 0.500, 0.696, 1.600/)
       c2=(/-0.530,-0.530,-0.530,-0.530,-0.530,-0.530,-0.530,-0.446,-0.362,-0.294,-0.186,-0.304,-0.578,
     +-0.772,-1.046,-0.978,-0.638,-0.316,-0.070,-0.070,-0.070,-0.530,-0.309,-0.070/)
       c3=(/-0.262,-0.262,-0.262,-0.267,-0.302,-0.324,-0.339,-0.398,-0.458,-0.511,-0.592,-0.536,-0.406,
     +-0.314,-0.185,-0.236,-0.491,-0.770,-0.986,-0.656,-0.422,-0.262,-0.019, 0.000/)
       c4=(/-2.118,-2.123,-2.145,-2.199,-2.277,-2.318,-2.309,-2.220,-2.146,-2.095,-2.066,-2.041,-2.000,
     +-2.000,-2.000,-2.000,-2.000,-2.000,-2.000,-2.000,-2.000,-2.118,-2.016,-2.000/)
       c5=(/ 0.170, 0.170, 0.170, 0.170, 0.170, 0.170, 0.170, 0.170, 0.170, 0.170, 0.170, 0.170, 0.170,
     + 0.170, 0.170, 0.170, 0.170, 0.170, 0.170, 0.170, 0.170, 0.170, 0.170, 0.170/)
       c6=(/ 5.600, 5.600, 5.600, 5.740, 7.090, 8.050, 8.790, 7.600, 6.580, 6.040, 5.300, 4.730, 4.000,
     + 4.000, 4.000, 4.000, 4.000, 4.000, 4.000, 4.000, 4.000, 5.600, 4.000, 4.000/)
       c7=(/ 0.280, 0.280, 0.280, 0.280, 0.280, 0.280, 0.280, 0.280, 0.280, 0.280, 0.280, 0.280, 0.280,
     + 0.255, 0.161, 0.094, 0.000, 0.000, 0.000, 0.000, 0.000, 0.280, 0.245, 0.000/)
       c8=(/-0.120,-0.120,-0.120,-0.120,-0.120,-0.099,-0.048,-0.012, 0.000, 0.000, 0.000, 0.000, 0.000,
     + 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000,-0.120, 0.000, 0.000/)
       c9=(/ 0.490, 0.490, 0.490, 0.490, 0.490, 0.490, 0.490, 0.490, 0.490, 0.490, 0.490, 0.490, 0.490,
     + 0.490, 0.490, 0.371, 0.154, 0.000, 0.000, 0.000, 0.000, 0.490, 0.358, 0.000/)
      c10=(/ 1.058, 1.102, 1.174, 1.272, 1.438, 1.604, 1.928, 2.194, 2.351, 2.460, 2.587, 2.544, 2.133,
     + 1.571, 0.406,-0.456,-0.820,-0.820,-0.820,-0.820,-0.820, 1.058, 1.694,-0.820/)
      c11=(/ 0.040, 0.040, 0.040, 0.040, 0.040, 0.040, 0.040, 0.040, 0.040, 0.040, 0.040, 0.040, 0.077,
     + 0.150, 0.253, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.040, 0.092, 0.300/)
      c12=(/ 0.610, 0.610, 0.610, 0.610, 0.610, 0.610, 0.610, 0.610, 0.610, 0.610, 0.610, 0.883, 1.000,
     + 1.000, 1.000, 1.000, 1.000, 1.000, 1.000, 1.000, 1.000, 0.610, 1.000, 1.000/)
         k1=(/ 865., 865., 908.,1054.,1086.,1032., 878., 748., 654., 587., 503., 457., 410.,
     + 400., 400., 400., 400., 400., 400., 400., 400., 865., 400., 400./)
       k2=(/-1.186,-1.219,-1.273,-1.346,-1.471,-1.624,-1.931,-2.188,-2.381,-2.518,-2.657,-2.669,-2.401,
     +-1.955,-1.025,-0.299, 0.000, 0.000, 0.000, 0.000, 0.000,-1.186,-1.955, 0.000/)
       k3=(/ 1.839, 1.840, 1.841, 1.843, 1.845, 1.847, 1.852, 1.856, 1.861, 1.865, 1.874, 1.883, 1.906,
     + 1.929, 1.974, 2.019, 2.110, 2.200, 2.291, 2.517, 2.744, 1.839, 1.929, 2.744/)
c some revised coeffs. Mar 2008 Eq Spectra 
      slny=(/ 0.478, 0.480, 0.489, 0.510, 0.520, 0.531,
     + 0.532, 0.534, 0.534, 0.544, 0.541, 0.550, 0.568, 0.568, 0.564,
     + 0.571, 0.558, 0.576, 0.601, 0.628, 0.667, 0.478, 0.484, 0.667/)
        tlny=(/ 0.219, 0.219, 0.235, 0.258, 0.292, 0.286,
     + 0.280, 0.249, 0.240, 0.215, 0.217, 0.214, 0.227, 0.255, 0.296,
     + 0.296, 0.326, 0.297, 0.359, 0.428, 0.485, 0.219, 0.203, 0.485/)
      slnAF=(/ 0.300, 0.300, 0.300, 0.300, 0.300, 0.300,
     + 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300,
     + 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300/)
      sC   =(/ 0.166, 0.166, 0.165, 0.162, 0.158, 0.170,
     + 0.180, 0.186, 0.191, 0.198, 0.206, 0.208, 0.221, 0.225, 0.222,
     + 0.226, 0.229, 0.237, 0.237, 0.271, 0.290, 0.166, 0.190, 0.290/)
          rhos=(/ 1.000, 0.999, 0.989, 0.963, 0.922, 0.898,
     + 0.890, 0.871, 0.852, 0.831, 0.785, 0.735, 0.628, 0.534, 0.411,
     + 0.331, 0.289, 0.261, 0.200, 0.174, 0.174, 1.000, 0.691, 0.174/)
c Velocities k1 determine transition from linear to non-linear siteamp. These
c affect both median and sigma calcs (as of sep 1 2006). Not sigma any more (nov 2006)
c
        cs= 1.88
        cn= 1.18      !these 2 c-values did not change from the 1-06 report.
        i=iq
        if(ip.eq.1.and.iq.ne.1.and.iq.ne.22)stop 'pga has to be called first in getCampNGA1107'
        gndx=0.0
c return to ground-motion independent sigma, C&B 11/06.
      	tausq=tlny(i)**2
      	sigsq=slny(i)**2
      	sigsqu = sigsq
      write(6,666) Pd(iq),sqrt(sigsq)
666      format('#Getcampnga1107 spectral period and sigma(lin) ',f5.2,1x,f6.4)
c random horizontal component, include the chisq boost compared to geom. mean.
c      	sigt=sqrt(tausq+sigsq+chisq)	!campbell has a kchi=1 factor.
               sigt=sqrt(tausq+sigsq )      	!sigma for geo. mean of 2 h-components
c sigmaf is a factor in the normal prob. 
      	sigmaf=1.0/sigt/sqrt2
c First, perform calculations that are independent of m or r
c
       vs=min(vs30, 1100.)
      d=dbasin
           vsrk=vs/k1(i)
      if(vsrk.ge.1.0)then
      f5i=(c10(i)+k2(i)*cn)*alog(vsrk)
      f5=f5i	!patch 9/2006
      else
      csfac=cs*vsrk**cn
      f5i=c10(i)*alog(vsrk)	!initial part of f5 calculation
      endif
c      write(6,*)i,wtrev,c7(i),c2(i),c3(i),c9(i)
           f6=0.0
           if(d.lt.1.0)then
             f6=c11(i)*(d-1.0)
           elseif(d.gt.3.0)then
             f6=c12(i)*k3(i)*expm75*(1.0-exp(-0.25*(d-3.)))
          endif
c          sensitivity to site sometimes being on hanging wall added Dec 12 07
c
      wtdip=wtrev+wtnormal
      if(wtdip.gt.0.01)then
      call avghw_cb(iq,avghwcb,nmag,magmin,dmag)
      avghwcb=avghwcb*wtdip
c      write(6,*)'avghwcb im=15, ii=0 & 1 ',avghwcb(0,15),avghwcb(1,15)
      else
      avghwcb =0.0
      endif
c sensitivity to depth to top of rupture. This is a loop variable.
      do 104 kk=1,ntor
      H = dtor(kk)	!Zeng variable names.
           f3=0.0
c weight to rev-slip or normal-slip corresponding to common/mech/ instructions.
c cant have both > 0 as coded here.
          if(H.gt.1.0.and.wtrev.gt.0.)then
               f3=c7(i)*wtrev
          elseif(wtrev.gt.0.)then
               f3=c7(i)*H*wtrev
          
      elseif(wtnormal.gt.0.)then
      	f3=c8(i)*wtnormal
      endif
c Next, perform magnitude- and distance-dependent calculations
c--- loop through magnitudes
      do 104 m=1,nmag
      xmag0= magmin+(m-1)*dmag
c-- gnd for SS; will be modified if normal or thrust component is present
        amag= xmag0
      weight= wt(ip,ia,1)
c f1=median dependence on magnitude. f2= joint M,R dependence
           f1=c0(i)+c1(i)*amag
           if(amag.gt.5.5)f1=f1+c2(i)*(amag-5.5)
           if(amag.gt.6.5)f1=f1+c3(i)*(amag-6.5)
      if(e_wind(ip))then
          if(amag.lt.mcut(1))then
          ime=1
          elseif(amag.lt.mcut(2))then
          ime=2
          else
          ime=3
          endif
          endif      !extra epistemic
c-- loop through distances. What about nearest distance for gridded?
      do 103 ii=1,ndist
      rjb=(ii-0.5)*di      
      if(e_wind(ip))then
          if(rjb.lt.dcut(1))then
          ide=1
          elseif(rjb.lt.dcut(2))then
          ide=2
          else
          ide=3
          endif
          gndx=gnd_ep(ide,ime,ip)
          endif
      rrup = sqrt ( rjb**2 +H**2)      !this is a basic assumption of the code. 
c This simple formula works for vertical-dip faults.
           f2=(c4(i)+c5(i)*amag)*0.5*alog(rrup*rrup+c6(i)*c6(i))
c f3 term is computed outside loop to save time
               f4= avghwcb(ii-1,m)      !this matrix is recomputed for each period
c      	if(amag.gt.6)write(6,*)rrup,f4
c f6 = Shallow sediment thickness dependence, computed outside loop.
c f5 is independent of pgar when vsrk.ge.1. It is computed outside of loop in that case.
           if(vsrk.lt.1.0)then
c C&B: Save pgar for subsequent ip loop indexes. PGA does have to be first. 
c Nonlinear soil term, f5. This term was precomputed outside loops for the case
c vsrk.ge.1.0
         if(ip.eq.1)pgar(ii,m)=exp(f1+f2+f3+f4+f6+(c10(1)
     +                      +k2(1)*cn)*rockcoef)
           pga_rk=pgar(ii,m)
       f5 = f5i +k2(i)*alog((pga_rk+csfac)/(pga_rk+cs))
c additional alpha term CB eqn (17) Sept 1 2006, in sigma computation
c  
c 
c as of 11/2007, site-GM dependent standard deviation is implemented.
c
      	alpha=k2(i)*pga_rk*(1./(pga_rk+csfac)-1./(pga_rk+cs))
      	alfsq=alpha*alpha 
c sln_Ab sigma of pga at base of site profile. see "doc" Eq Spectra paper, p 13 midway thru.
      	sln_Ab= sqrt(spgasq - slnAF(1)**2)
c sln_yb is sigma for spectral period j at base of soil column. Campbell corr.
                sln_yb= sqrt(slny(i)**2 - slnAF(i)**2)
         sigsq=sigsqu +alfsq*sln_Ab**2+2.*alpha*rhos(i)*sln_Ab*sln_yb
c nonlinear motion-dependent sigma, but no motion-dependent tau.
         sigt = sqrt(tausq + sigsq)	
          endif

           gnd=f1+f2+f3+f4+f5+f6
c      if(ip.eq.1.and.rjb.lt.10.)print *,rrup,rjb,exp(gnd),sigt
        gndout(1)=gnd
      gndout(2)=gnd+gndx
      gndout(3)=gnd-gndx
      if(fix_sigma)then
      sigmaf=1./sigma_fx/sqrt2
       elseif(sdi)then
       sde=gndout(1)+fac_sde(ip)      !fac_sde is log(T**2/(4pisq))
       rhat = min(10.,exp(sde)/dy_sdi)
       gndout(1) = sdi_ratio(Pd(iq),amag,rhat,sigt,sdisd) + sde
       sigmaf=1.0/sdisd/sqrt2      !use sdi for all gnd_ep branches
         if(e_wind(ip))then
         gndout(2)= gndout(1)+gndx
         gndout(3)= gndout(1)-gndx
         endif
      else
            sigmaf=1.0/sigt/sqrt2
            endif
        do ifn=1,nfi
        do  k= 1,nlev(ip)
        tmp=(gndout(ifn) - xlev(k,ip))*sigmaf
        if(tmp.gt.3.3)then
       ipr=25002
       elseif(tmp.gt.plim)then
       ipr= 1+nint(dp2*(tmp-plim))	!3sigma cutoff n'(mu,sig)
       else
       goto 102	!transfer out if ln(SA) above mu+3sigma
       endif
       fac=weight*p(ipr)
c for deagg. only one gm level so k index is not needed.  kk is needed for CB
c weight is applied. e0 is averaged thru atten models.
      if(deagg)e0_wus(ii,m,ip,kk,ifn)= e0_wus(ii,m,ip,kk,ifn)-tmp*sqrt2*fac
 199  pr(ii,m,k,ip,kk,ifn)= pr(ii,m,k,ip,kk,ifn)+fac      !sum thru ia index
      enddo	!k levels
102      continue
      enddo	!ifn file index
103      continue	!distance
104      continue	!magnitude and depth_to_top
       return
      end subroutine getCampNGA1107

        subroutine CY2007H(ip,iprd,ia,ndist,di,nmag,magmin,dmag)
        parameter (mxnprd=106)
        parameter (pi=3.14159265,d2r=0.0174533,sqrt2=1.414213562)
c      Add PGV coeffs jan 2009
c Output table of Pr[psa>lev(j)], ann rate of exceedance. For a range of M and R.
c Original code computes ln(median) and sigma for a specific M,Rjb,Rrup,Rx comb.
c Jan 24 2007: psa replaced by gndout, a 3-component vector
c gndout(1)=psa, gndout(2)=psa+gnd_ep, gndout(3)=psa-gnd_ep. Mod was inspired
c by need to increase variability not present in the 3 or 4 NGA relations
c From sept 2007 Chiou & Youngs NGA subroutine "cy2007".
c  Steve Harmsen 10/26/2007. Fortran efficiencies added. 11/01/2007: M-dependent sigma
c  will be run for this relation. Some question about the coef. values
c Predictor variables
c DELTA = fault dip (degrees) assumed 50 d for normal and reverse parts
c cosDELTA2 is available in common/dipinf_50/. Used to set a degree of hw-effect.
c z1 = depth (m) where vs is 1.0 km/s. THis is now used Oct 2007 code. For 760 m/s rock
c reasonable z1 are in the 20 to 60 m range. CY have a default fcn, Z1(VS30):
c        Z1 = exp(28.5-3.82/8*log(V_S30**8+378.8**8))
c
c V_S30 top 30 m avg vs30. 
c Plausibly, Z1 should be a function of Z25 (basin depth) as well.
c R_x new signed distance, < 0 on footwall for big extension of fault strike.
c This code  requires some assumption about distribution of dipping faults, rather
c than the 100% vertical-dip faults of earlier versions of hazgridX . First try
c bases  hw on 50 degree dip assumption. Not used if weight assigned to SS>0.999.
c R_rup and R_JB the usual distance metrics.
c iprd the period index in the 106-element arrays below
c M the source moment mag
c Z_TOR depth to top of rupture available in common /depth_rup/.
c 
c   New documentation for CY : use Eq Spectra Feb Mar 2008.
      common/epistemic/nfi,e_wind,gnd_ep,mcut,dcut
      common/cyinit/a,b,c,rkdepth
       common/sdi/sdi,dy_sdi,fac_sde
       real, dimension(8) :: fac_sde
      real magmin,dmag,di, NL
c added dec 12 2007, average haning-wall effect according to CY model. this
c is obtained by calling avghw_cy subroutine. Currently, virtual faults
c have dip of 50 d and centers at depth 7.5 km. strike is random with uniform distribution
c effect is multiplied by the fraction of dip slip sources (wtrev+wtnormal)
c
      real, dimension(0:310,31):: avghwcy
      real gnd_ep(3,3,8),mcut(2),dcut(2),gndout(3)
      logical fix_sigma,deagg,e_wind(8),sdi
      common/e0_wus/e0_wus(310,31,8,3,3)
      common/prob/p(25005),plim,dp2
      common/mech/wtss,wtrev,wtnormal
      common/dipinf_90/dipang,cosDELTA,cdipsq,cyhwfac,cbhwfac
c dipinf_50 is the dip information for subset of gridded with dip 50 d. This subset
c is vaguely defined. But it may occur with same probability as (wtrev+wtnormal)
      common/fix_sigma/fix_sigma,sigma_fx	!add option to fix sigma_aleatory.
      common/dipinf_50/dipang2,cosDELTA2,cdip2sq,cyhwfac2,cbhwfac2
      common/geotec/V_S30,dbasin
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
      common/atten/ pr, xlev, nlev, icode, wt, wtdist
      common/deagg/deagg
      real pr(310,38,20,8,3,3),xlev(20,8),wt(8,10,2),wtdist(8,10) 
      integer nlev(8),icode(8,10)
c Predictor variables
        real PERIOD, M, Width, R_rup, R_JB, R_x, V_S30, Z1, 
     1       Z_TOR, F_RV, F_NM,sigma_fx

c Model coefficients. Phi moved to cy2007i, oct 25 2007. SHarmsen.
        real, dimension(mxnprd):: prd,
     1       c1, c1a, c1b, c2,
     1       c3, cn,  cM,  c4,
     1       c4a,cRB, c5,  c6,
     1       cHM,c7,  c9, c9a,
     1       cgamma1, cgamma2, cgamma3,
     1       sigma_t,tau1,tau2,sigma1,sigma2,dlt1
      real cc,gamma, cosDELTA, cyhwfac, cbhwfac, psa,psa_ref
      real dipang,cdipsq,sigmaf,dy_sdi
      real r1,r2, r3, r4, fw, hw, sde, sdisd
      real, dimension(8) :: a,b,c,rkdepth
      integer iprd, i,mindex
c Below coeffs from a file called cy2007.coe emailed by Brian Chiou, Oct 2007
c prd array not used below. Assume SA 0.01 s is PGA.
      prd= (/0.010,0.020,0.022,0.025,0.029,0.030,0.032,0.035,0.036,0.040,0.042,0.044,0.045,0.046,
     10.048,0.050,0.055,0.060,0.065,0.067,0.070,0.075,0.080,0.085,0.090,0.095,0.100,0.110,0.120,
     10.130,0.133,0.140,0.150,0.160,0.170,0.180,0.190,0.200,0.220,0.240,0.250,0.260,0.280,0.290,
     10.300,0.320,0.340,0.350,0.360,0.380,0.400,0.420,0.440,0.450,0.460,0.480,0.500,0.550,0.600,
     10.650,0.667,0.700,0.750,0.800,0.850,0.900,0.950,1.000,1.100,1.200,1.300,1.400,1.500,1.600,
     11.700,1.800,1.900,2.000,2.200,2.400,2.500,2.600,2.800,3.000,3.200,3.400,3.500,3.600,3.800,
     14.000,4.200,4.400,4.600,4.800,5.000,5.500,6.000,6.500,7.000,7.500,8.000,8.500,9.000,9.500,
     110.0,-1./)
       c1= (/-1.26869,-1.25148,-1.23809,-1.21643,-1.18418,-1.17437,
     1 -1.15447,-1.12331,-1.11187,-1.06711,-1.04307,-1.01882,-1.00656,-0.99433,-0.97022,
     1 -0.94639,-0.88949,-0.83610,-0.78729,-0.76939,-0.74395,-0.70507,-0.67083,-0.64093,
     1 -0.61510,-0.59310,-0.57470,-0.54528,-0.52757,-0.51999,-0.52032,-0.52270,-0.53087,
     1 -0.54469,-0.56296,-0.58466,-0.60898,-0.63524,-0.68925,-0.74654,-0.77656,-0.80683,
     1 -0.86661,-0.89720,-0.92776,-0.98769,-1.04691,-1.07638,-1.10551,-1.16228,-1.21760,
     1 -1.27136,-1.32348,-1.34896,-1.37399,-1.42262,-1.46945,-1.57899,-1.67858,-1.76913,
     1 -1.79793,-1.85160,-1.92784,-1.99884,-2.06549,-2.12847,-2.18828,-2.24533,-2.35211,
     1 -2.45195,-2.54744,-2.64012,-2.73065,-2.81887,-2.90440,-2.98685,-3.06587,-3.14125,
     1 -3.28154,-3.40957,-3.46975,-3.52774,-3.63778,-3.74126,-3.83896,-3.93140,-3.97588,
     1 -4.01921,-4.10246,-4.18136,-4.25603,-4.32676,-4.39387,-4.45775,-4.51873,-4.66058,
     1 -4.78938,-4.90790,-5.01833,-5.12243,-5.22154,-5.31657,-5.40817,-5.49675,-5.58722,
     + 2.2884/)      !final value for pgv see table 2 p 198
      c1a= (/ 0.100, 0.100, 0.100, 0.100, 0.100, 0.100,
     1  0.100, 0.100, 0.100, 0.100, 0.100, 0.100, 0.100, 0.100, 0.100,
     1  0.100, 0.100, 0.100, 0.100, 0.100, 0.100, 0.100, 0.100, 0.100,
     1  0.100, 0.100, 0.100, 0.100, 0.100, 0.100, 0.100, 0.100, 0.100,
     1  0.100, 0.100, 0.100, 0.100, 0.100, 0.100, 0.100, 0.100, 0.100,
     1  0.09990, 0.09990, 0.09990, 0.09990, 0.09990, 0.09980, 0.09980, 0.09980, 0.09970,
     1  0.09960, 0.09950, 0.09950, 0.09940, 0.09930, 0.09910, 0.09860, 0.09780, 0.09680,
     1  0.09630, 0.09540, 0.09360, 0.09140, 0.08870, 0.08530, 0.08130, 0.07660, 0.06510,
     1  0.05120, 0.03550, 0.01880, 0.00220,-0.01350,-0.02750,-0.03990,-0.05040,-0.05910,
     1 -0.07220,-0.08080,-0.08400,-0.08660,-0.09050,-0.09310,-0.09490,-0.09620,-0.09670,
     1 -0.09710,-0.09780,-0.09820,-0.09860,-0.09890,-0.09910,-0.09930,-0.09940,-0.09960,
     1 -0.09980,-0.09980,-0.09990,-0.09990,-0.09990,-0.100,-0.100,-0.100,-0.10000,
     + 0.1094/)
      c1b= (/-0.25500,-0.25500,-0.25500,-0.25500,-0.25500,-0.25500,
     1 -0.25500,-0.25500,-0.25500,-0.25500,-0.25500,-0.25500,-0.25500,-0.25500,-0.25500,
     1 -0.25500,-0.25500,-0.25500,-0.25470,-0.25400,-0.25400,-0.25400,-0.25400,-0.25400,
     1 -0.25400,-0.25300,-0.25300,-0.25290,-0.25200,-0.25100,-0.25100,-0.25040,-0.25000,
     1 -0.24900,-0.24800,-0.24700,-0.24600,-0.24490,-0.24280,-0.24000,-0.23820,-0.23700,
     1 -0.23430,-0.23280,-0.23130,-0.22750,-0.22470,-0.22260,-0.22140,-0.21800,-0.21460,
     1 -0.21070,-0.20730,-0.20540,-0.20370,-0.20080,-0.19720,-0.18890,-0.18140,-0.17440,
     1 -0.17220,-0.16800,-0.16200,-0.15640,-0.15110,-0.14720,-0.14320,-0.14000,-0.13370,
     1 -0.12820,-0.12460,-0.12140,-0.11840,-0.11660,-0.11400,-0.11250,-0.11110,-0.11000,
     1 -0.10800,-0.10700,-0.10600,-0.10600,-0.10500,-0.10400,-0.10400,-0.10300,-0.10300,
     1 -0.10300,-0.10200,-0.10200,-0.10200,-0.10200,-0.10200,-0.10100,-0.10100,-0.10100,
     1 -0.10100,-0.10100,-0.10100,-0.10100,-0.100,-0.100,-0.100,-0.100,-0.10000,
     + -0.0626/)
        c2= (/1.060,1.060,1.060,1.060,1.060,1.060,
     1 1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.060,
     1 1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.060,
     1 1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.060,
     1 1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.060,
     1 1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.060,
     1 1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.060,
     1 1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.060,
     1 1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.060,
     1 1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.060,
     1 1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.060,
     1 1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.06/)
        c3= (/3.450,3.450,3.450,3.450,3.450,3.450,
     1 3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.450,
     1 3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.450,
     1 3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.450,
     1 3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.450,
     1 3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.450,
     1 3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.450,
     1 3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.450,
     1 3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.450,
     1 3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.450,
     1 3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.450,
     1 3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.45/)
       cn= (/ 2.99600, 3.29240, 3.35160, 3.42930, 3.50120, 3.51370,
     1  3.53310, 3.55120, 3.55490, 3.56300, 3.56270, 3.56070, 3.55940, 3.55740, 3.55260,
     1  3.54730, 3.53080, 3.51290, 3.49300, 3.48440, 3.47140, 3.44800, 3.42320, 3.39660,
     1  3.36890, 3.34070, 3.31200, 3.25490, 3.19920, 3.14470, 3.12880, 3.09320, 3.04360,
     1  2.99700, 2.95220, 2.91000, 2.87010, 2.83120, 2.75960, 2.69160, 2.65790, 2.62560,
     1  2.56370, 2.53340, 2.50480, 2.44870, 2.39700, 2.37190, 2.34800, 2.30340, 2.26110,
     1  2.22180, 2.18480, 2.16720, 2.15000, 2.11780, 2.08680, 2.01740, 1.95700, 1.90360,
     1  1.88680, 1.85540, 1.81190, 1.77270, 1.73680, 1.70390, 1.67470, 1.64800, 1.60460,
     1  1.57170, 1.54620, 1.52630, 1.51100, 1.49840, 1.48890, 1.48140, 1.47440, 1.46980,
     1  1.46250, 1.45800, 1.45620, 1.45600, 1.45500, 1.45570, 1.45650, 1.45810, 1.45940,
     1  1.46060, 1.46300, 1.46520, 1.46760, 1.47030, 1.47330, 1.47520, 1.47790, 1.48310,
     1  1.48780, 1.49230, 1.49550, 1.49750, 1.49900, 1.500, 1.50100, 1.50100, 1.50200,
     + 1.648/)
       cM= (/ 4.18400, 4.18790, 4.18280, 4.17340, 4.15930, 4.15560,
     1  4.14850, 4.13820, 4.13510, 4.12260, 4.11740, 4.11230, 4.11040, 4.10840, 4.10380,
     1  4.10110, 4.09400, 4.08920, 4.08670, 4.08600, 4.08600, 4.08600, 4.08730, 4.08990,
     1  4.09380, 4.09850, 4.10300, 4.11440, 4.12770, 4.14160, 4.14590, 4.15650, 4.17170,
     1  4.18710, 4.20230, 4.21720, 4.23230, 4.24760, 4.27590, 4.30420, 4.31840, 4.33200,
     1  4.35840, 4.37120, 4.38440, 4.40860, 4.43230, 4.44410, 4.45570, 4.47680, 4.49790,
     1  4.51720, 4.53610, 4.54520, 4.55450, 4.57120, 4.58810, 4.62730, 4.66320, 4.69590,
     1  4.70710, 4.72760, 4.75710, 4.78510, 4.81140, 4.83620, 4.85970, 4.88200, 4.92450,
     1  4.96410, 5.00130, 5.03670, 5.06970, 5.10190, 5.13250, 5.16230, 5.19050, 5.21730,
     1  5.26910, 5.31730, 5.33930, 5.36100, 5.40130, 5.43850, 5.47370, 5.50690, 5.52290,
     1  5.53820, 5.56870, 5.59770, 5.62520, 5.65180, 5.67760, 5.70270, 5.72760, 5.78550,
     1  5.84040, 5.89240, 5.94220, 5.98910, 6.03390, 6.07700, 6.11720, 6.15610, 6.19300,
     + 4.2979/)
       c4= (/-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,
     1 -2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,
     1 -2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,
     1 -2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,
     1 -2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,
     1 -2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,
     1 -2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,
     1 -2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,
     1 -2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,
     1 -2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,
     1 -2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,
     1 -2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1/)
      c4a= (/-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,
     1 -0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,
     1 -0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,
     1 -0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,
     1 -0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,
     1 -0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,
     1 -0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,
     1 -0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,
     1 -0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,
     1 -0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,
     1 -0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,
     1 -0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-.5/)
      cRB= (/50.0,50.0,50.0,50.0,50.0,50.0,
     1 50.0,50.0,50.0,50.0,50.0,50.0,50.0,50.0,50.0,
     1 50.0,50.0,50.0,50.0,50.0,50.0,50.0,50.0,50.0,
     1 50.0,50.0,50.0,50.0,50.0,50.0,50.0,50.0,50.0,
     1 50.0,50.0,50.0,50.0,50.0,50.0,50.0,50.0,50.0,
     1 50.0,50.0,50.0,50.0,50.0,50.0,50.0,50.0,50.0,
     1 50.0,50.0,50.0,50.0,50.0,50.0,50.0,50.0,50.0,
     1 50.0,50.0,50.0,50.0,50.0,50.0,50.0,50.0,50.0,
     1 50.0,50.0,50.0,50.0,50.0,50.0,50.0,50.0,50.0,
     1 50.0,50.0,50.0,50.0,50.0,50.0,50.0,50.0,50.0,
     1 50.0,50.0,50.0,50.0,50.0,50.0,50.0,50.0,50.0,
     1 50.0,50.0,50.0,50.0,50.0,50.0,50.0,50.0,50.0,50./)
       c5= (/ 6.16000, 6.15800, 6.15800, 6.15700, 6.15580, 6.15500,
     1  6.15450, 6.15300, 6.15300, 6.15080, 6.14970, 6.14870, 6.14770, 6.14700, 6.14590,
     1  6.14410, 6.14090, 6.13620, 6.13140, 6.12940, 6.12600, 6.12000, 6.11440, 6.10720,
     1  6.10070, 6.09290, 6.08500, 6.06830, 6.04940, 6.02960, 6.02370, 6.00870, 5.98710,
     1  5.96470, 5.94160, 5.91770, 5.89420, 5.86990, 5.82310, 5.77670, 5.75470, 5.73350,
     1  5.69170, 5.67190, 5.65270, 5.61630, 5.58320, 5.56810, 5.55280, 5.52520, 5.49970,
     1  5.47640, 5.45550, 5.44580, 5.43620, 5.41890, 5.40290, 5.36970, 5.34310, 5.32130,
     1  5.31490, 5.30450, 5.29000, 5.27880, 5.26920, 5.26070, 5.25370, 5.24800, 5.23870,
     1  5.23210, 5.22660, 5.22240, 5.21940, 5.21660, 5.21400, 5.21250, 5.21110, 5.20990,
     1  5.20800, 5.20600, 5.20600, 5.20500, 5.20430, 5.20400, 5.20300, 5.20300, 5.20300,
     1  5.20240, 5.20200, 5.20200, 5.20200, 5.20170, 5.20100, 5.20100, 5.20100, 5.20100,
     1  5.20100, 5.20100, 5.20100, 5.200, 5.200, 5.200, 5.200, 5.200, 5.20000,
     + 5.17/)
       c6= (/ 0.48930, 0.48920, 0.48920, 0.48910, 0.48910, 0.48900,
     1  0.48900, 0.48890, 0.48890, 0.48880, 0.48870, 0.48870, 0.48860, 0.48860, 0.48850,
     1  0.48840, 0.48830, 0.48800, 0.48780, 0.48760, 0.48750, 0.48720, 0.48690, 0.48650,
     1  0.48620, 0.48580, 0.48540, 0.48460, 0.48370, 0.48280, 0.48250, 0.48180, 0.48080,
     1  0.47970, 0.47870, 0.47760, 0.47650, 0.47550, 0.47350, 0.47150, 0.47060, 0.46980,
     1  0.46800, 0.46730, 0.46650, 0.46510, 0.46380, 0.46320, 0.46260, 0.46160, 0.46070,
     1  0.45980, 0.45910, 0.45870, 0.45830, 0.45780, 0.45710, 0.45600, 0.45500, 0.45420,
     1  0.45400, 0.45360, 0.45310, 0.45280, 0.45240, 0.45220, 0.45190, 0.45170, 0.45140,
     1  0.45110, 0.45100, 0.45080, 0.45070, 0.45060, 0.45050, 0.45040, 0.45040, 0.45040,
     1  0.45030, 0.45020, 0.45020, 0.45020, 0.45020, 0.45010, 0.45010, 0.45010, 0.45010,
     1  0.45010, 0.45010, 0.45010, 0.45010, 0.45010, 0.45010, 0.45000, 0.45000, 0.45000,
     1  0.45000, 0.45000, 0.45000, 0.45000, 0.45000, 0.45000, 0.45000, 0.45000, 0.45000,
     + 0.4407/)
      cHM= (/ 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
     1  3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
     1  3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
     1  3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
     1  3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
     1  3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
     1  3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
     1  3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
     1  3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
     1  3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
     1  3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
     1  3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,3./)
       c7= (/ 0.05120, 0.05120, 0.05120, 0.05120, 0.05110, 0.05110,
     1  0.05110, 0.05100, 0.05090, 0.05080, 0.05070, 0.05060, 0.05060, 0.05050, 0.05050,
     1  0.05040, 0.05020, 0.05000, 0.04990, 0.04980, 0.04970, 0.04950, 0.04940, 0.04920,
     1  0.04910, 0.04900, 0.04890, 0.04860, 0.04840, 0.04820, 0.04820, 0.04810, 0.04790,
     1  0.04770, 0.04760, 0.04740, 0.04730, 0.04710, 0.04680, 0.04660, 0.04640, 0.04630,
     1  0.04600, 0.04590, 0.04580, 0.04550, 0.04530, 0.04520, 0.04500, 0.04480, 0.04450,
     1  0.04420, 0.04390, 0.04370, 0.04360, 0.04320, 0.04290, 0.04210, 0.04120, 0.04040,
     1  0.04010, 0.03950, 0.03870, 0.03790, 0.03720, 0.03640, 0.03570, 0.03500, 0.03360,
     1  0.03220, 0.03080, 0.02940, 0.02800, 0.02660, 0.02530, 0.02400, 0.02270, 0.02130,
     1  0.01880, 0.01650, 0.01540, 0.01440, 0.01240, 0.01060, 0.00900, 0.00760, 0.00690,
     1  0.00630, 0.00520, 0.00410, 0.00330, 0.00250, 0.00190, 0.00140, 0.00100, 0.00020,
     1  0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.00000,
     1 0.0207/)
c No c7a (for aftershocks). not included.
       c9= (/ 0.79000, 0.81290, 0.81880, 0.82800, 0.84070, 0.84390,
     1  0.85020, 0.85940, 0.86240, 0.87400, 0.87950, 0.88480, 0.88740, 0.88990, 0.89490,
     1  0.89960, 0.91050, 0.92040, 0.92920, 0.93250, 0.93710, 0.94420, 0.95050, 0.95590,
     1  0.96060, 0.96450, 0.96770, 0.97180, 0.97330, 0.97250, 0.97190, 0.96990, 0.96600,
     1  0.96090, 0.95490, 0.94820, 0.94100, 0.93340, 0.91790, 0.90230, 0.89460, 0.88710,
     1  0.87260, 0.86570, 0.85900, 0.84620, 0.83420, 0.82840, 0.82280, 0.81210, 0.80190,
     1  0.79220, 0.78300, 0.77860, 0.77430, 0.76590, 0.75780, 0.73910, 0.72210, 0.70650,
     1  0.70150, 0.69220, 0.67880, 0.66620, 0.65400, 0.64230, 0.63080, 0.61960, 0.59750,
     1  0.57560, 0.55380, 0.53200, 0.51010, 0.48770, 0.46490, 0.44120, 0.41690, 0.39170,
     1  0.33900, 0.28330, 0.25460, 0.22620, 0.17220, 0.12440, 0.08460, 0.05380, 0.04200,
     1  0.03220, 0.01770, 0.00860, 0.00310, 0.00040, 0.000, 0.000, 0.000, 0.000,
     1  0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.00000,
     + 0.3079/)
      c9a= (/ 1.50050, 1.50276, 1.50351, 1.50456, 1.50667, 1.50712,
     1  1.50818, 1.51044, 1.51104, 1.51376, 1.51573, 1.51771, 1.51862, 1.51953, 1.52135,
     1  1.52303, 1.52974, 1.53587, 1.54280, 1.54635, 1.55162, 1.55971, 1.56784, 1.57917,
     1  1.59011, 1.60047, 1.61043, 1.63837, 1.66446, 1.69266, 1.70233, 1.72461, 1.75488,
     1  1.78479, 1.81939, 1.85280, 1.88476, 1.91573, 1.98060, 2.04153, 2.07094, 2.09824,
     1  2.15050, 2.17581, 2.20053, 2.24678, 2.28462, 2.30297, 2.32100, 2.35585, 2.38858,
     1  2.41259, 2.43562, 2.44685, 2.45788, 2.47936, 2.50002, 2.53375, 2.56459, 2.58933,
     1  2.59529, 2.60648, 2.62243, 2.63663, 2.64561, 2.65382, 2.66153, 2.66899, 2.67728,
     1  2.68505, 2.69096, 2.69474, 2.69851, 2.70148, 2.70337, 2.70527, 2.70689, 2.70851,
     1  2.71014, 2.71177, 2.71231, 2.71285, 2.71367, 2.71448, 2.71502, 2.71529, 2.71556,
     1  2.71584, 2.71611, 2.71638, 2.71665, 2.71665, 2.71692, 2.71692, 2.71720, 2.71747,
     1  2.71747, 2.71774, 2.71774, 2.71774, 2.71801, 2.71801, 2.71801, 2.71801, 2.71801,
     + 2.6690/)
      cgamma1= (/-0.008040,-0.008113,-0.008155,-0.008230,-0.008351,-0.008387,
     1 -0.008454,-0.008564,-0.008599,-0.008754,-0.008833,-0.008906,-0.008945,-0.008984,-0.009050,
     1 -0.009121,-0.009288,-0.009433,-0.009561,-0.009603,-0.009656,-0.009733,-0.009782,-0.009808,
     1 -0.009809,-0.009788,-0.009753,-0.009627,-0.009460,-0.009269,-0.009205,-0.009054,-0.008832,
     1 -0.008610,-0.008398,-0.008183,-0.007976,-0.007776,-0.007397,-0.007044,-0.006877,-0.006715,
     1 -0.006408,-0.006263,-0.006123,-0.005859,-0.005614,-0.005497,-0.005386,-0.005175,-0.004980,
     1 -0.004799,-0.004632,-0.004552,-0.004477,-0.004332,-0.004199,-0.003903,-0.003652,-0.003435,
     1 -0.003368,-0.003246,-0.003078,-0.002929,-0.002795,-0.002674,-0.002564,-0.002464,-0.002287,
     1 -0.002138,-0.002010,-0.001898,-0.001802,-0.001717,-0.001643,-0.001578,-0.001519,-0.001467,
     1 -0.001381,-0.001311,-0.001281,-0.001255,-0.001209,-0.001172,-0.001142,-0.001117,-0.001106,
     1 -0.001096,-0.001079,-0.001065,-0.001052,-0.001042,-0.001032,-0.001024,-0.001016,-0.000999,
     1 -0.000987,-0.000977,-0.000968,-0.000961,-0.000955,-0.000950,-0.000945,-0.000941,-0.000937,
     + -0.00275/)
      cgamma2= (/-0.007850,-0.007921,-0.007962,-0.008035,-0.008154,-0.008189,
     1 -0.008255,-0.008362,-0.008396,-0.008547,-0.008624,-0.008696,-0.008734,-0.008771,-0.008836,
     1 -0.008906,-0.009068,-0.009210,-0.009335,-0.009376,-0.009428,-0.009503,-0.009550,-0.009577,
     1 -0.009577,-0.009557,-0.009522,-0.009400,-0.009236,-0.009050,-0.008988,-0.008840,-0.008623,
     1 -0.008406,-0.008199,-0.007989,-0.007787,-0.007592,-0.007222,-0.006878,-0.006714,-0.006556,
     1 -0.006257,-0.006115,-0.005979,-0.005720,-0.005481,-0.005368,-0.005259,-0.005053,-0.004862,
     1 -0.004686,-0.004522,-0.004445,-0.004371,-0.004230,-0.004100,-0.003811,-0.003565,-0.003354,
     1 -0.003288,-0.003169,-0.003005,-0.002860,-0.002729,-0.002611,-0.002504,-0.002406,-0.002233,
     1 -0.002087,-0.001962,-0.001854,-0.001759,-0.001677,-0.001604,-0.001540,-0.001483,-0.001433,
     1 -0.001348,-0.001280,-0.001251,-0.001225,-0.001181,-0.001145,-0.001115,-0.001091,-0.001080,
     1 -0.001071,-0.001054,-0.001040,-0.001027,-0.001017,-0.001007,-0.000999,-0.000992,-0.000976,
     1 -0.000964,-0.000954,-0.000945,-0.000938,-0.000933,-0.000927,-0.000923,-0.000919,-0.000914,
     + -.00625/)
      cgamma3= (/ 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000,
     1  4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000,
     1  4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000,
     1  4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000,
     1  4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000,
     1  4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000,
     1  4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000,
     1  4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000,
     1  4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000,
     1  4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000,
     1  4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000,
     1  4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.000,4./)
c phi values are in subroutine cy2007i, below.
      tau1= (/0.3437,0.3471,0.3505,0.3538,0.3571,0.3603,
     1 0.3633,0.3663,0.3691,0.3718,0.3744,0.3768,0.3791,0.3811,0.3831,
     1 0.3848,0.3863,0.3876,0.3877,0.3881,0.3883,0.3878,0.3872,0.3865,
     1 0.3856,0.3846,0.3835,0.3816,0.3795,0.3775,0.3761,0.3742,0.3719,
     1 0.3696,0.3672,0.3649,0.3626,0.3601,0.3572,0.3543,0.3522,0.3500,
     1 0.3474,0.3455,0.3438,0.3417,0.3398,0.3386,0.3375,0.3362,0.3351,
     1 0.3344,0.3339,0.3340,0.3344,0.3346,0.3353,0.3354,0.3360,0.3369,
     1 0.3390,0.3409,0.3429,0.3452,0.3478,0.3508,0.3541,0.3577,0.3608,
     1 0.3644,0.3682,0.3725,0.3769,0.3816,0.3865,0.3916,0.3968,0.4023,
     1 0.4085,0.4149,0.4212,0.4277,0.4341,0.4406,0.4470,0.4534,0.4598,
     1 0.4661,0.4723,0.4784,0.4845,0.4904,0.4962,0.5019,0.5074,0.5128,
     1 0.5181,0.5232,0.5281,0.5328,0.5374,0.5419,0.5461,0.5502,0.5542,
     + 0.2539/)
      tau2= (/0.2637,0.2671,0.2705,0.2738,0.2771,0.2803,
     1 0.2833,0.2863,0.2891,0.2918,0.2944,0.2968,0.2991,0.3011,0.3031,
     1 0.3048,0.3063,0.3076,0.3095,0.3106,0.3118,0.3129,0.3138,0.3145,
     1 0.3149,0.3151,0.3152,0.3154,0.3153,0.3151,0.3143,0.3135,0.3128,
     1 0.3120,0.3110,0.3100,0.3089,0.3076,0.3068,0.3060,0.3047,0.3034,
     1 0.3026,0.3015,0.3005,0.2999,0.2993,0.2988,0.2983,0.2983,0.2984,
     1 0.2987,0.2993,0.2999,0.3008,0.3021,0.3036,0.3060,0.3085,0.3113,
     1 0.3139,0.3169,0.3205,0.3243,0.3283,0.3326,0.3371,0.3419,0.3472,
     1 0.3527,0.3584,0.3643,0.3703,0.3765,0.3828,0.3892,0.3957,0.4023,
     1 0.4085,0.4149,0.4212,0.4277,0.4341,0.4406,0.4470,0.4534,0.4598,
     1 0.4661,0.4723,0.4784,0.4845,0.4904,0.4962,0.5019,0.5074,0.5128,
     1 0.5181,0.5232,0.5281,0.5328,0.5374,0.5419,0.5461,0.5502,0.5542,
     + 0.2381/)
      sigma1= (/0.4458,0.4458,0.4476,0.4500,0.4529,0.4535,
     1 0.4547,0.4564,0.4569,0.4589,0.4598,0.4607,0.4611,0.4615,0.4623,
     1 0.4630,0.4647,0.4663,0.4677,0.4682,0.4690,0.4702,0.4712,0.4722,
     1 0.4731,0.4740,0.4747,0.4761,0.4773,0.4782,0.4785,0.4791,0.4798,
     1 0.4803,0.4808,0.4811,0.4814,0.4816,0.4817,0.4816,0.4815,0.4813,
     1 0.4808,0.4805,0.4801,0.4794,0.4786,0.4781,0.4777,0.4768,0.4758,
     1 0.4748,0.4738,0.4734,0.4729,0.4719,0.4710,0.4688,0.4667,0.4650,
     1 0.4644,0.4634,0.4621,0.4610,0.4600,0.4592,0.4586,0.4581,0.4555,
     1 0.4535,0.4518,0.4505,0.4493,0.4484,0.4476,0.4469,0.4463,0.4459,
     1 0.4451,0.4444,0.4442,0.4440,0.4436,0.4433,0.4430,0.4428,0.4427,
     1 0.4426,0.4425,0.4424,0.4423,0.4422,0.4421,0.4420,0.4420,0.4418,
     1 0.4417,0.4417,0.4416,0.4416,0.4415,0.4415,0.4415,0.4415,0.4414,
     + 0.4496/)
      sigma2= (/0.3459,0.3459,0.3477,0.3502,0.3530,0.3537,
     1 0.3549,0.3566,0.3572,0.3592,0.3602,0.3611,0.3615,0.3619,0.3627,
     1 0.3635,0.3654,0.3670,0.3686,0.3692,0.3700,0.3713,0.3726,0.3738,
     1 0.3749,0.3759,0.3769,0.3787,0.3804,0.3819,0.3824,0.3834,0.3847,
     1 0.3859,0.3871,0.3882,0.3893,0.3902,0.3921,0.3938,0.3946,0.3953,
     1 0.3967,0.3974,0.3981,0.3993,0.4005,0.4010,0.4016,0.4026,0.4036,
     1 0.4046,0.4054,0.4059,0.4063,0.4071,0.4079,0.4098,0.4114,0.4130,
     1 0.4135,0.4144,0.4157,0.4170,0.4181,0.4192,0.4203,0.4213,0.4213,
     1 0.4213,0.4213,0.4213,0.4213,0.4213,0.4213,0.4213,0.4213,0.4213,
     1 0.4213,0.4213,0.4213,0.4213,0.4213,0.4213,0.4213,0.4213,0.4213,
     1 0.4213,0.4213,0.4213,0.4213,0.4213,0.4213,0.4213,0.4213,0.4213,
     1 0.4213,0.4213,0.4213,0.4213,0.4213,0.4213,0.4213,0.4213,0.4213,
     +0.3554/)
c dlt1 is used for the case of INFERRED Vs30
        dlt1= (/0.8000,0.8000,0.8000,0.8000,0.8000,0.8000,
     1 0.8000,0.8000,0.8000,0.8000,0.8000,0.8000,0.8000,0.8000,0.8000,
     1 0.8000,0.8000,0.8000,0.8000,0.8000,0.8000,0.8000,0.8000,0.8000,
     1 0.8000,0.8000,0.8000,0.8000,0.8000,0.8000,0.8000,0.8000,0.8000,
     1 0.8000,0.8000,0.8000,0.8000,0.8000,0.7999,0.7999,0.7999,0.7998,
     1 0.7998,0.7997,0.7997,0.7996,0.7994,0.7993,0.7992,0.7990,0.7988,
     1 0.7983,0.7979,0.7976,0.7974,0.7970,0.7966,0.7940,0.7917,0.7884,
     1 0.7867,0.7836,0.7792,0.7747,0.7681,0.7619,0.7560,0.7504,0.7400,
     1 0.7304,0.7230,0.7182,0.7136,0.7097,0.7080,0.7064,0.7049,0.7035,
     1 0.7025,0.7017,0.7012,0.7011,0.7008,0.7006,0.7004,0.7003,0.7003,
     1 0.7002,0.7002,0.7001,0.7001,0.7001,0.7001,0.7001,0.7000,0.7000,
     1 0.7000,0.7000,0.7000,0.7000,0.7000,0.7000,0.7000,0.7000,0.7000,.7/)
      F_RV=wtrev
      F_NM=wtnormal
      wtdip=wtrev+wtnormal
      if(wtdip.gt.0.01)then
      call avghw_cy(iprd,avghwcy,nmag,magmin,dmag)
      avghwcy=avghwcy*wtdip
c      write(6,*)'avghwcy im=15, ii=0 & 1 ',avghwcy(0,15),avghwcy(1,15)
      else
      avghwcy =0.0
      endif
      weight= wt(ip,ia,1)
      if(weight.lt.0..or.weight.gt.1.)then
      write(6,*)ip,'getCYnga weight ',weight
      stop 'Can it be?'
      endif
      do 104 kk=1,ntor
      H1=dtor(kk)
      H1sq=H1*H1

c Scaling with other source variables (F_RV, F_NM, and Z_TOR)
      r4 = c1a(iprd)*F_RV + c1b(iprd)*F_NM + c7(iprd)*(H1 - 4.0)
        do 104 mindex=1,nmag
        xmag0= magmin + (mindex-1)*dmag
c body wave to moment mag. CY added 10/14/2008
        M= xmag0
              cc = c5(iprd)* cosh(c6(iprd) * max(M-cHM(iprd),0.))
        gamma = cgamma1(iprd) +
     1          cgamma2(iprd)/cosh(max(M-cgamma3(iprd),0.))
c Magnitude scaling
        r1 = c1(iprd) + c2(iprd) * (M-6.0) +
     1       (c2(iprd)-c3(iprd))/cn(iprd) *
     1             log(1.0 + exp(-cn(iprd)*(M-cM(iprd))))
      if(e_wind(ip))then
          if(M.lt.mcut(1))then
          ime=1
          elseif(M.lt.mcut(2))then
          ime=2
          else
          ime=3
          endif
          endif !extra epistemic
c : attenuation-model epistemic weight applied here, to the Pr array elements.
c....... Aleatory variablility 
c Tau
        tau = tau1(iprd) + (tau2(iprd)-tau1(iprd))/2*(min(max(M,5.),7.)-5.)

c.......
c Sigma
        sigma_M = sigma1(iprd) +
     1        (sigma2(iprd)-sigma1(iprd))/2*(min(max(M,5.),7.)-5.)
c           endif
      weight= wt(ip,ia,1)
c Near-field magnitude and distance scaling
           do 103 ii=1,ndist
      rjb=(ii-0.5)*di      !minimum src-site Joyner-Boore distance 0.5 km WUS gridded
      if(rjb.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
      if(e_wind(ip))then
          if(rjb.lt.dcut(1))then
          ide=1
          elseif(rjb.lt.dcut(2))then
          ide=2
          else
          ide=3
          endif
          gndx=gnd_ep(ide,ime,ip)
          endif
c Below distance is a consequence of the standard vertical-fault assumption.
c  A different R_rup is present for dipping-fault portion 
      R_Rup = sqrt (rjb**2 + H1sq)
      rrup2=R_Rup*R_Rup
        r2 = c4(iprd) * log(R_Rup + cc)

c Far-field distance
        r3 = (c4a(iprd)-c4(iprd))/2.0 *
     1            log( R_Rup*R_Rup+cRB(iprd)*cRB(iprd) ) +
     1       R_Rup * gamma
c Can include average amount of hw effect in coastal California & elsewhere.
c Can also include avg hw in Intermtn west for normal-faulting fraction
      hw = avghwcy(ii-1,mindex)
        psa_ref = r1+r2+r3+r4+hw

c...... Below a,b,c,rkdepth were computed in CY2007I and are available in common/cyinit/
c Soil effect: linear response
c        a(ip) = phi1(iprd) * min(log(V_S30/1130.), 0.)

c Soil effect: nonlinear response. 1130-360= 770 
c        b(ip) = phi2(iprd) *
c     1(exp(phi3(iprd)*(min(V_S30,1130.)-360.))-exp(phi3(iprd)*(770.)))
c        c (ip)= phi4(iprd)

c Modificaiton to ln(Vs30) scaling: bedrock depth (Z1)
c NOTE: max(0,Z1-15) is capped at 300 to avoid overflow of function cosh
c        rkdepth(ip) = phi5(iprd) *
c     1        ( 1 - 1.0/cosh(phi6(iprd)*max(0.,Z1-phi7(iprd)))) +
c     1        phi8(iprd)/cosh(0.15*min(max(0., Z1-15.),300.))

c......
c Median PSA prediction for reference condition
        psa = psa_ref + 
     1 (a(ip) + b(ip) * log((exp(psa_ref)+c(ip))/c(ip))) + rkdepth(ip)
c....... Aleatory variablility (provided 5pm nov 2 2007). SH
        psa_ref = exp(psa_ref)
        if(fix_sigma)then
        sigmaf=1./sqrt2/sigma_fx
        else
        NL = b(ip) * psa_ref/(psa_ref+c(ip))
c nov 6 2007: tau gets a slight effect from NL. code corrected Nov 6. Chiou
c says to remove the sqrt in an email of Nov 8
c tau_nl should not be a function of distance. Inside a distance loop. Andrew Cowell email 
c june 2009.
      tau_nl = tau * (1.0 + NL)
c end of Nov 6 &8 corrections. SH. Brian Chiou emails of Nov 6,8 2007.
        sigma = sigma_M * sqrt(dlt1(iprd)+(1.0 + NL)**2)
        sig = sqrt(sigma**2 + tau_nl**2)
       sigmaf= 1./sig/sqrt2
       endif      !option to fix sigma_aleatory?
       gndout(1) = psa
       if(sdi)then
       sde=gndout(1)+fac_sde(ip)      !fac_sde is log(T**2/(4pisq))
       rhat = min(10.,exp(sde)/dy_sdi)
       gndout(1) = sdi_ratio(prd(iprd),M,rhat,sig,sdisd) + sde
       sigmaf=1./sdisd/sqrt2      !use sdi for all gnd_ep branches
         endif      !if(sdi)
         if(e_wind(ip))then
         gndout(2)= gndout(1)+gndx
         gndout(3)= gndout(1)-gndx
         endif
        do ifn=1,nfi
        do  k= 1,nlev(ip)
        tmp=(gndout(ifn) - xlev(k,ip))*sigmaf
        if(tmp.gt.3.3)then
       ipr=25002
       elseif(tmp.gt.plim)then
       ipr= 1+nint(dp2*(tmp-plim))	!3sigma cutoff n'(mu,sig)
       else
       goto 102	!transfer out if ground motion above mu+3sigma
       endif
       fac=weight*p(ipr)
         pr(ii,mindex,k,ip,kk,ifn)= pr(ii,mindex,k,ip,kk,ifn)+fac      !sum thru ia index
c for deagg. only one gm level so k index is not needed.  kk is needed 
c weight is  applied. 
      if(deagg)e0_wus(ii,mindex,ip,kk,ifn)= e0_wus(ii,mindex,ip,kk,ifn)-tmp*sqrt2*fac
      enddo		!k index
102      continue
      enddo		!ifn for epistemic uncert of median gm
103      continue	!distance increment
104      continue
      return
      end subroutine CY2007H

        subroutine CY2007I(ip,iprd, V_S30, Z1)                  
c this subroutine computes some soil terms (a,b,c,rkdepth) for a fixed
c vs30 and z1 model. These are stored in vectors at element ip. This initialization
c is done to speed up runs. 
c Input:
c   ip, period index in global psha run. IPMAX is 8.
c   iprd, period index of the CY coefficients associated with period(ip)
c    V_S30 = vs in top 30 m (m/s)
c    Z1 = depth (m) where Vs is >= 1 km/s. THis quantity should be fixed for all
c    receivers in the run (like the standard Vs30 maps we have produced). See phi7.
c
c 
        parameter (mxnprd=106)
      common/cyinit/a,b,c,rkdepth
        real V_S30, Z1 
      real, dimension(8) :: a,b,c,rkdepth
      real, dimension(mxnprd) :: phi1,phi2,phi3,phi4,phi5,phi6,phi7,phi8
      phi1= (/-.4417,-.4340,-.4313,-.4267,-.4196,-.4177,
     1 -.4139,-.4082,-.4064,-.4000,-.3973,-.3949,-.3939,-.3930,-.3914,
     1 -.3903,-.3892,-.3903,-.3934,-.3951,-.3981,-.4040,-.4108,-.4182,
     1 -.4261,-.4341,-.4423,-.4585,-.4743,-.4892,-.4935,-.5032,-.5162,
     1 -.5283,-.5396,-.5502,-.5602,-.5697,-.5873,-.6034,-.6109,-.6182,
     1 -.6319,-.6383,-.6444,-.6559,-.6665,-.6715,-.6762,-.6850,-.6931,
     1 -.7005,-.7072,-.7104,-.7135,-.7193,-.7246,-.7365,-.7468,-.7557,
     1 -.7585,-.7636,-.7708,-.7773,-.7833,-.7888,-.7941,-.7990,-.8082,
     1 -.8165,-.8243,-.8315,-.8382,-.8445,-.8504,-.8560,-.8613,-.8663,
     1 -.8755,-.8836,-.8874,-.8909,-.8974,-.9032,-.9083,-.9130,-.9151,
     1 -.9170,-.9205,-.9231,-.9249,-.9257,-.9255,-.9243,-.9222,-.9129,
     1 -.8982,-.8791,-.8572,-.8346,-.8126,-.7914,-.7711,-.7517,-.7332,-0.7861/)
      phi2= (/-.1417,-.1364,-.1361,-.1365,-.1392,-.1403,
     1 -.1430,-.1482,-.1502,-.1591,-.1641,-.1694,-.1721,-.1748,-.1804,
     1 -.1862,-.2008,-.2153,-.2291,-.2344,-.2420,-.2538,-.2644,-.2739,
     1 -.2819,-.2887,-.2943,-.3025,-.3077,-.3106,-.3111,-.3118,-.3113,
     1 -.3093,-.3062,-.3022,-.2976,-.2927,-.2823,-.2716,-.2662,-.2609,
     1 -.2505,-.2455,-.2405,-.2310,-.2220,-.2177,-.2135,-.2053,-.1975,
     1 -.1901,-.1830,-.1795,-.1762,-.1696,-.1633,-.1487,-.1353,-.1232,
     1 -.1194,-.1124,-.1028,-.0943,-.0869,-.0805,-.0748,-.0699,-.0617,
     1 -.0552,-.0501,-.0459,-.0425,-.0395,-.0369,-.0346,-.0323,-.0302,
     1 -.0262,-.0225,-.0207,-.0190,-.0159,-.0129,-.0102,-.0077,-.0066,
     1 -.0055,-.0036,-.0016,0.00,0.00,0.00,0.00,0.00,0.00,
     1 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.0000,-0.0699/)
         phi3= (/-0.007010,-0.007279,-0.007301,-0.007364,-0.007378,-0.007354,
     1 -0.007281,-0.007162,-0.007129,-0.006977,-0.006878,-0.006765,-0.006710,-0.006656,-0.006556,
     1 -0.006467,-0.006279,-0.006117,-0.005970,-0.005914,-0.005835,-0.005734,-0.005670,-0.005632,
     1 -0.005607,-0.005597,-0.005604,-0.005644,-0.005696,-0.005744,-0.005758,-0.005794,-0.005845,
     1 -0.005901,-0.005959,-0.006019,-0.006080,-0.006141,-0.006262,-0.006381,-0.006439,-0.006495,
     1 -0.006604,-0.006655,-0.006704,-0.006795,-0.006882,-0.006923,-0.006965,-0.007047,-0.007125,
     1 -0.007194,-0.007259,-0.007290,-0.007320,-0.007378,-0.007435,-0.007579,-0.007720,-0.007863,
     1 -0.007911,-0.008001,-0.008120,-0.008223,-0.008313,-0.008381,-0.008423,-0.008444,-0.008500,
     1 -0.008478,-0.008307,-0.008042,-0.007707,-0.007317,-0.006862,-0.006265,-0.005541,-0.004792,
     1 -0.003555,-0.002764,-0.002497,-0.002292,-0.002007,-0.001828,-0.001713,-0.001636,-0.001608,
     1 -0.001585,-0.001549,-0.001523,-0.001501,-0.001483,-0.001467,-0.001453,-0.001440,-0.001416,
     1 -0.001397,-0.001384,-0.001375,-0.001369,-0.001364,-0.001362,-0.001360,-0.001360,-0.001361,
     + -.008444/)
         phi4= (/ 0.102151, 0.108360, 0.110372, 0.113710, 0.118600, 0.119888,
     1  0.122493, 0.126540, 0.127926, 0.133641, 0.136572, 0.139596, 0.141112, 0.142659, 0.145774,
     1  0.148927, 0.157001, 0.165249, 0.173635, 0.177001, 0.182082, 0.190596, 0.199129, 0.207505,
     1  0.215628, 0.223398, 0.230662, 0.243315, 0.253169, 0.260175, 0.261767, 0.264504, 0.266468,
     1  0.266468, 0.265060, 0.262501, 0.259163, 0.255253, 0.246252, 0.236525, 0.231541, 0.226570,
     1  0.216796, 0.211993, 0.207277, 0.198077, 0.189304, 0.185074, 0.180920, 0.172976, 0.165464,
     1  0.158358, 0.151662, 0.148466, 0.145352, 0.139415, 0.133828, 0.121226, 0.110339, 0.100842,
     1  0.097891, 0.092504, 0.085153, 0.078622, 0.072788, 0.067563, 0.062850, 0.058595, 0.051206,
     1  0.045054, 0.039879, 0.035504, 0.031787, 0.028613, 0.025890, 0.023537, 0.021496, 0.019716,
     1  0.016771, 0.014434, 0.013436, 0.012534, 0.010962, 0.009643, 0.008521, 0.007561, 0.007130,
     1  0.006730, 0.006008, 0.005379, 0.004830, 0.004349, 0.003925, 0.003553, 0.003223, 0.002551,
     1  0.002047, 0.001662, 0.001366, 0.001134, 0.000952, 0.000806, 0.000689, 0.000593, 0.000515,
     + 5.410/)
         phi5= (/ 0.228900, 0.228900, 0.228900, 0.228900, 0.228900, 0.228900,
     1  0.228900, 0.228900, 0.228900, 0.228900, 0.228900, 0.229000, 0.229000, 0.229000, 0.229000,
     1  0.229000, 0.229000, 0.229000, 0.229100, 0.229100, 0.229100, 0.229200, 0.229300, 0.229400,
     1  0.229500, 0.229600, 0.229700, 0.230200, 0.230500, 0.231100, 0.231300, 0.231900, 0.232600,
     1  0.233400, 0.234800, 0.236100, 0.237400, 0.238600, 0.243300, 0.247700, 0.249700, 0.253300,
     1  0.260600, 0.264100, 0.267400, 0.274600, 0.284700, 0.289500, 0.294200, 0.303200, 0.312000,
     1  0.322700, 0.332900, 0.337800, 0.342700, 0.352000, 0.361000, 0.381000, 0.399300, 0.414200,
     1  0.418000, 0.425200, 0.435300, 0.444400, 0.449400, 0.454200, 0.458700, 0.462900, 0.466800,
     1  0.470300, 0.472900, 0.474300, 0.475600, 0.476700, 0.477200, 0.477700, 0.478100, 0.478500,
     1  0.478900, 0.479200, 0.479300, 0.479400, 0.479500, 0.479600, 0.479700, 0.479800, 0.479800,
     1  0.479800, 0.479800, 0.479900, 0.479900, 0.479900, 0.479900, 0.479900, 0.479900, 0.4800,
     1  0.4800, 0.4800, 0.4800, 0.4800, 0.4800, 0.4800, 0.4800, 0.4800, 0.480000,
     + 0.2899/)
         phi6= (/ 0.014996, 0.014996, 0.014996, 0.014996, 0.014996, 0.014996,
     1  0.014996, 0.014996, 0.014996, 0.014996, 0.014996, 0.014996, 0.014996, 0.014996, 0.014996,
     1  0.014996, 0.014996, 0.014996, 0.014996, 0.014996, 0.014996, 0.014996, 0.014996, 0.014996,
     1  0.014996, 0.014996, 0.014996, 0.014994, 0.014994, 0.014993, 0.014993, 0.014991, 0.014988,
     1  0.014987, 0.014981, 0.014975, 0.014970, 0.014964, 0.014928, 0.014895, 0.014881, 0.014832,
     1  0.014731, 0.014684, 0.014639, 0.014513, 0.014239, 0.014110, 0.013985, 0.013747, 0.013493,
     1  0.012938, 0.012429, 0.012190, 0.011962, 0.011532, 0.011133, 0.009769, 0.008660, 0.007829,
     1  0.007620, 0.007244, 0.006739, 0.006325, 0.006163, 0.006014, 0.005876, 0.005749, 0.005678,
     1  0.005613, 0.005573, 0.005558, 0.005544, 0.005533, 0.005529, 0.005527, 0.005524, 0.005521,
     1  0.005519, 0.005518, 0.005518, 0.005518, 0.005517, 0.005517, 0.005517, 0.005517, 0.005517,
     1  0.005517, 0.005517, 0.005517, 0.005517, 0.005517, 0.005517, 0.005517, 0.005517, 0.005517,
     1  0.005517, 0.005517, 0.005517, 0.005517, 0.005517, 0.005517, 0.005517, 0.005517, 0.005517,
     + 0.006718/)
      phi7= (/ 580.0, 580.0, 580.0, 580.0, 580.0, 580.0,
     1  580.0, 580.0, 580.0, 579.9, 579.9, 579.9, 579.9, 579.9, 579.9,
     1  579.9, 579.8, 579.8, 579.8, 579.7, 579.7, 579.6, 579.6, 579.5,
     1  579.4, 579.3, 579.2, 578.8, 578.6, 578.2, 578.0, 577.7, 577.2,
     1  576.7, 576.0, 575.2, 574.6, 573.9, 571.6, 569.5, 568.5, 566.9,
     1  563.6, 562.0, 560.5, 557.3, 552.6, 550.4, 548.3, 544.1, 540.0,
     1  534.0, 528.4, 525.7, 523.0, 517.8, 512.9, 497.1, 482.7, 468.7,
     1  463.9, 454.8, 441.9, 429.9, 419.5, 409.8, 400.5, 391.8, 379.6,
     1  368.5, 359.8, 353.7, 348.1, 343.1, 340.2, 337.5, 334.9, 332.5,
     1  330.0, 327.8, 326.7, 326.1, 325.1, 324.1, 323.3, 322.9, 322.7,
     1  322.5, 322.1, 321.7, 321.6, 321.4, 321.2, 321.1, 320.9, 320.7,
     1  320.6, 320.4, 320.4, 320.3, 320.2, 320.2, 320.2, 320.1, 320.1,
     + 459.0/)
         phi8= (/ 0.070000, 0.070000, 0.070000, 0.070000, 0.070000, 0.070000,
     1  0.070000, 0.070000, 0.070000, 0.070000, 0.070000, 0.070000, 0.070000, 0.070000, 0.070000,
     1  0.070000, 0.070000, 0.069800, 0.069600, 0.069400, 0.069200, 0.068600, 0.067900, 0.067100,
     1  0.066200, 0.065400, 0.064600, 0.063500, 0.062500, 0.060200, 0.059200, 0.056000, 0.049400,
     1  0.040700, 0.030600, 0.019900, 0.008900,-0.001900,-0.022300,-0.040100,-0.047900,-0.054800,
     1 -0.066500,-0.071300,-0.075600,-0.082500,-0.087500,-0.089500,-0.091200,-0.093900,-0.096000,
     1 -0.097500,-0.098700,-0.099100,-0.099400,-0.099800,-0.099800,-0.098300,-0.094800,-0.089600,
     1 -0.087600,-0.083400,-0.076500,-0.069300,-0.062000,-0.054900,-0.047900,-0.041200,-0.028500,
     1 -0.016700,-0.005700, 0.004500, 0.014000, 0.022900, 0.031300, 0.039300, 0.046900, 0.054400,
     1  0.068700, 0.082600, 0.089500, 0.096300, 0.109800, 0.123200, 0.136600, 0.149800, 0.156200,
     1  0.162500, 0.174600, 0.185900, 0.196400, 0.206000, 0.214700, 0.222500, 0.229500, 0.243500,
     1  0.253200, 0.259500, 0.263500, 0.266000, 0.267500, 0.268300, 0.268600, 0.268500, 0.268200,
     + 0.1138/)
c Above phi? coeffs from a file called cy2007.coe emailed by Brian Chiou, Oct 2007
c Add PGV coeffs Jan 7 2009. SHarmsen.
c Use CY default Z1 if a questionable or bogus value is coming in at this location.
      if(Z1.lt.10.) Z1 = exp(28.5-3.82/8*log(V_S30**8+378.8**8))

c Soil effect: linear response
        a(ip) = phi1(iprd) * min(log(V_S30/1130.), 0.)

c Soil effect: nonlinear response. 1130-360= 770 
        b(ip) = phi2(iprd) *
     1(exp(phi3(iprd)*(min(V_S30,1130.)-360.))-exp(phi3(iprd)*(770.)))
        c (ip)= phi4(iprd)

c Modificaiton to ln(Vs30) scaling: bedrock depth (Z1)
c NOTE: max(0,Z1-15) is capped at 300 to avoid overflow of function cosh
        rkdepth(ip) = phi5(iprd) *
     1        ( 1 - 1.0/cosh(phi6(iprd)*max(0.,Z1-phi7(iprd)))) +
     1        phi8(iprd)/cosh(0.15*min(max(0., Z1-15.),300.))

      return
      end subroutine CY2007I


      subroutine getAB06(ip,iq,ir,ia,ndist,di,nmag,magmin,dmag)
c Atkinson and Boore BSSA 2006. A CEUS relation
c modified from version written by Oliver Boyd. Steve Harmsen Nov 14 2006. mods feb 13 af
c ip = period index for atten model
c iq = period index for that period in this subroutine, for example iq=25 for pga
c ir = flag to indicate to use hard-rock (use ir=2 or 4) or firm-rock coeffs
c     (ir=1 or 3). Siteamp will
c be based on ir and on vs30. Siteamp does not occur if vs30=760 or if hardrock; however,
c S-term is nonzero otherwise (<0 for Vs30>760 m/s)
c  
c For hardrock site condition, code should be called with ir=2 or 4.
c ndist=number of distances for array filling,
c nmag = number of magnitudes,
c sigmanf,distnf = near-source terms not used here.
c v30==site vs30 (m/s) found in common geotec
c clamp is a period-dependent max median based on 2002.
c AB06 has a PGV index, ip = 26. Only one for CEUS currently available. Silva
c could have PGV as well.
      parameter (np=26)
      parameter (emax=3.0,sqrt2=1.414213562,stressfac = 0.5146)      !corrected june 11 2007
      parameter (gfac=6.8875526,sfac=2.3025851,tfac=-0.5108256)	
c precompute some fixed-value factors and terms      
c  gfac = ln(980), sfac = ln(10),
c  and tfac = ln(60/100)
      parameter (fac70=1.8450980,fac140=2.1461280,facv1=-0.5108256,facv2=-0.9295360)	
c  log10(70),log10(140),ln(v1/v2),ln(v2/vref),resp
        parameter (vref = 760., v1 = 180., v2 = 300.)      !for siteamp calcs
      common/geotec/v30,dbasin
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
       common / atten / pr, xlev, nlev, icode, wt, wtdist
      common/deagg/deagg
      common/e0_ceus/e0_ceus(310,31,8)
      real pr(310,38,20,8,3,3),xlev(20,8),wt(8,10,2),wtdist(8,10) 
      integer nlev(8),icode(8,10)
      logical deagg,et,sp      !sp = true for a short-period gm limit in ceus. 
      real f0,f1,f2,R,Mw,bnl,S,magmin,dmag,di,period,test,temp
      real,dimension(np):: abper,Fr,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,bln,b1,b2,clamp,
     + del, m1,mh
c clamp==maximum SA or PGA value (g) except for clamp(26), for PGV, 460 cm/s.
           clamp = (/0.,0.,0.,0.,0.,0.,0.,0.,0.,6.,6.,6.,6.,6.,6.,6.,6.,
     + 6.,6.,6.,6.,6.,3.,3.,3.,460./)
c rounded .3968 to 0.4 s for one element of abper. SH june 30 2008
      abper = (/5.0000, 4.0000, 3.1250, 2.5000, 2.0000, 1.5873, 1.2500, 1.0000,
     1 0.7937, 0.6289, 0.5000, 0.40, 0.3155, 0.2506, 0.2000, 0.1580,
     1 0.1255, 0.0996, 0.0791, 0.0629, 0.0499, 0.0396, 0.0315, 0.0250,
     1 0.0000, -1.000/)
      Fr = (/2.00e-01,2.50e-01,3.20e-01,4.00e-01,5.00e-01,6.30e-01,8.00e-01,1.00e+00,
     1       1.26e+00,1.59e+00,2.00e+00,2.52e+00,3.17e+00,3.99e+00,5.03e+00,6.33e+00,
     1       7.97e+00,1.00e+01,1.26e+01,1.59e+01,2.00e+01,2.52e+01,3.18e+01,4.00e+01,
     1       0.00e+00,-1.00e+00/)
c frequency - independent sigma
      sigma = 0.3*sfac
      sigmaf = 1./sqrt2/sigma
c AB concept adjusts BC to get any  soil or rock amp; except for 2000+m/s, hardrock.
        if (ir.eq.2.or.ir.eq.4) then
c hr coefficients, table 6
        c1 = (/-5.41e+00,-5.79e+00,-6.04e+00,-6.17e+00,-6.18e+00,-6.04e+00,-5.72e+00,
     1        -5.27e+00,-4.60e+00,-3.92e+00,-3.22e+00,-2.44e+00,-1.72e+00,-1.12e+00,
     1        -6.15e-01,-1.46e-01,2.14e-01,4.80e-01,6.91e-01,9.11e-01,1.11e+00,1.26e+00,
     1        1.44e+00,1.52e+00,9.07e-01,-1.44e+00/)
        c2 = (/1.71e+00,1.92e+00,2.08e+00,2.21e+00,2.30e+00,2.34e+00,2.32e+00,2.26e+00,
     1        2.13e+00,1.99e+00,1.83e+00,1.65e+00,1.48e+00,1.34e+00,1.23e+00,1.12e+00,
     1        1.05e+00,1.02e+00,9.97e-01,9.80e-01,9.72e-01,9.68e-01,9.59e-01,9.60e-01,
     1        9.83e-01,9.91e-01/)
        c3 = (/-9.01e-02,-1.07e-01,-1.22e-01,-1.35e-01,-1.44e-01,-1.50e-01,-1.51e-01,
     1        -1.48e-01,-1.41e-01,-1.31e-01,-1.20e-01,-1.08e-01,-9.74e-02,-8.72e-02,
     1        -7.89e-02,-7.14e-02,-6.66e-02,-6.40e-02,-6.28e-02,-6.21e-02,-6.20e-02,
     1        -6.23e-02,-6.28e-02,-6.35e-02,-6.60e-02,-5.85e-02/)
        c4 = (/-2.54e+00,-2.44e+00,-2.37e+00,-2.30e+00,-2.22e+00,-2.16e+00,-2.10e+00,
     1        -2.07e+00,-2.06e+00,-2.05e+00,-2.02e+00,-2.05e+00,-2.08e+00,-2.08e+00,
     1        -2.09e+00,-2.12e+00,-2.15e+00,-2.20e+00,-2.26e+00,-2.36e+00,-2.47e+00,
     1        -2.58e+00,-2.71e+00,-2.81e+00,-2.70e+00,-2.70e+00/)
        c5 = (/2.27e-01,2.11e-01,2.00e-01,1.90e-01,1.77e-01,1.66e-01,1.57e-01,1.50e-01,
     1        1.47e-01,1.42e-01,1.34e-01,1.36e-01,1.38e-01,1.35e-01,1.31e-01,1.30e-01,
     1        1.30e-01,1.27e-01,1.25e-01,1.26e-01,1.28e-01,1.32e-01,1.40e-01,1.46e-01,
     1        1.59e-01,2.16e-01/)
        c6 = (/-1.27e+00,-1.16e+00,-1.07e+00,-9.86e-01,-9.37e-01,-8.70e-01,-8.20e-01,
     1        -8.13e-01,-7.97e-01,-7.82e-01,-8.13e-01,-8.43e-01,-8.89e-01,-9.71e-01,
     1        -1.12e+00,-1.30e+00,-1.61e+00,-2.01e+00,-2.49e+00,-2.97e+00,-3.39e+00,
     1        -3.64e+00,-3.73e+00,-3.65e+00,-2.80e+00,-2.44e+00/)
        c7 = (/1.16e-01,1.02e-01,8.95e-02,7.86e-02,7.07e-02,6.05e-02,5.19e-02,4.67e-02,
     1        4.35e-02,4.30e-02,4.44e-02,4.48e-02,4.87e-02,5.63e-02,6.79e-02,8.31e-02,
     1        1.05e-01,1.33e-01,1.64e-01,1.91e-01,2.14e-01,2.28e-01,2.34e-01,2.36e-01,
     1        2.12e-01,2.66e-01/)
        c8 = (/9.79e-01,1.01e+00,1.00e+00,9.68e-01,9.52e-01,9.21e-01,8.56e-01,8.26e-01,
     1        7.75e-01,7.88e-01,8.84e-01,7.39e-01,6.10e-01,6.14e-01,6.06e-01,5.62e-01,
     1        4.27e-01,3.37e-01,2.14e-01,1.07e-01,-1.39e-01,-3.51e-01,-5.43e-01,-6.54e-01,
     1        -3.01e-01,8.48e-02/)
        c9 = (/-1.77e-01,-1.82e-01,-1.80e-01,-1.77e-01,-1.77e-01,-1.73e-01,-1.66e-01,
     1        -1.62e-01,-1.56e-01,-1.59e-01,-1.75e-01,-1.56e-01,-1.39e-01,-1.43e-01,
     1        -1.46e-01,-1.44e-01,-1.30e-01,-1.27e-01,-1.21e-01,-1.17e-01,-9.84e-02,
     1        -8.13e-02,-6.45e-02,-5.50e-02,-6.53e-02,-6.93e-02/)
        c10 = (/-1.76e-04,-2.01e-04,-2.31e-04,-2.82e-04,-3.22e-04,-3.75e-04,-4.33e-04,
     1        -4.86e-04,-5.79e-04,-6.95e-04,-7.70e-04,-8.51e-04,-9.54e-04,-1.06e-03,
     1        -1.13e-03,-1.18e-03,-1.15e-03,-1.05e-03,-8.47e-04,-5.79e-04,-3.17e-04,
     1        -1.23e-04,-3.23e-05,-4.85e-05,-4.48e-04,-3.73e-04/)
        else
c bc coefficients from AB06 Table 9
        c1 = (/-4.85e+00,-5.26e+00,-5.59e+00,-5.80e+00,-5.85e+00,-5.75e+00,-5.49e+00,
     1         -5.06e+00,-4.45e+00,-3.75e+00,-3.01e+00,-2.28e+00,-1.56e+00,-8.76e-01,
     1         -3.06e-01,1.19e-01,5.36e-01,7.82e-01,9.67e-01,1.11e+00,1.21e+00,1.26e+00,
     1         1.19e+00,1.05e+00,5.23e-01,-1.66e+00/)
        c2 = (/1.58e+00,1.79e+00,1.97e+00,2.13e+00,2.23e+00,2.29e+00,2.29e+00,2.23e+00,
     1        2.12e+00,1.97e+00,1.80e+00,1.63e+00,1.46e+00,1.29e+00,1.16e+00,1.06e+00,
     1        9.65e-01,9.24e-01,9.03e-01,8.88e-01,8.83e-01,8.79e-01,8.88e-01,9.03e-01,
     1        9.69e-01,1.05e+00/)
        c3 = (/-8.07e-02,-9.79e-02,-1.14e-01,-1.28e-01,-1.39e-01,-1.45e-01,-1.48e-01,
     1        -1.45e-01,-1.39e-01,-1.29e-01,-1.18e-01,-1.05e-01,-9.31e-02,-8.19e-02,
     1        -7.21e-02,-6.47e-02,-5.84e-02,-5.56e-02,-5.48e-02,-5.39e-02,-5.44e-02,
     1        -5.52e-02,-5.64e-02,-5.77e-02,-6.20e-02,-6.04e-02/)
        c4 = (/-2.53e+00,-2.44e+00,-2.33e+00,-2.26e+00,-2.20e+00,-2.13e+00,-2.08e+00,
     1        -2.03e+00,-2.01e+00,-2.00e+00,-1.98e+00,-1.97e+00,-1.98e+00,-2.01e+00,
     1        -2.04e+00,-2.05e+00,-2.11e+00,-2.17e+00,-2.25e+00,-2.33e+00,-2.44e+00,
     1        -2.54e+00,-2.58e+00,-2.57e+00,-2.44e+00,-2.50e+00/)
        c5 = (/2.22e-01,2.07e-01,1.91e-01,1.79e-01,1.69e-01,1.58e-01,1.50e-01,1.41e-01,
     1        1.36e-01,1.31e-01,1.27e-01,1.23e-01,1.21e-01,1.23e-01,1.22e-01,1.19e-01,
     1        1.21e-01,1.19e-01,1.22e-01,1.23e-01,1.30e-01,1.39e-01,1.45e-01,1.48e-01,
     1        1.47e-01,1.84e-01/)
        c6 = (/-1.43e+00,-1.31e+00,-1.20e+00,-1.12e+00,-1.04e+00,-9.57e-01,-9.00e-01,
     1        -8.74e-01,-8.58e-01,-8.42e-01,-8.47e-01,-8.88e-01,-9.47e-01,-1.03e+00,
     1        -1.15e+00,-1.36e+00,-1.67e+00,-2.10e+00,-2.53e+00,-2.88e+00,-3.04e+00,
     1        -2.99e+00,-2.84e+00,-2.65e+00,-2.34e+00,-2.30e+00/)
        c7 = (/1.36e-01,1.21e-01,1.10e-01,9.54e-02,8.00e-02,6.76e-02,5.79e-02,5.41e-02,
     1        4.98e-02,4.82e-02,4.70e-02,5.03e-02,5.58e-02,6.34e-02,7.38e-02,9.16e-02,
     1        1.16e-01,1.48e-01,1.78e-01,2.01e-01,2.13e-01,2.16e-01,2.12e-01,2.07e-01,
     1        1.91e-01,2.50e-01/)
        c8 = (/6.34e-01,7.34e-01,8.45e-01,8.91e-01,8.67e-01,8.67e-01,8.21e-01,7.92e-01,
     1        7.08e-01,6.77e-01,6.67e-01,6.84e-01,6.50e-01,5.81e-01,5.08e-01,5.16e-01,
     1        3.43e-01,2.85e-01,1.00e-01,-3.19e-02,-2.10e-01,-3.91e-01,-4.37e-01,-4.08e-01,
     1        -8.70e-02,1.27e-01/)
        c9 = (/-1.41e-01,-1.56e-01,-1.72e-01,-1.80e-01,-1.79e-01,-1.79e-01,-1.72e-01,
     1        -1.70e-01,-1.59e-01,-1.56e-01,-1.55e-01,-1.58e-01,-1.56e-01,-1.49e-01,
     1        -1.43e-01,-1.50e-01,-1.32e-01,-1.32e-01,-1.15e-01,-1.07e-01,-9.00e-02,
     1        -6.75e-02,-5.87e-02,-5.77e-02,-8.29e-02,-8.70e-02/)
        c10 = (/-1.61e-04,-1.96e-04,-2.45e-04,-2.60e-04,-2.86e-04,-3.43e-04,-4.07e-04,
     1        -4.89e-04,-5.75e-04,-6.76e-04,-7.68e-04,-8.59e-04,-9.55e-04,-1.05e-03,
     1        -1.14e-03,-1.18e-03,-1.13e-03,-9.90e-04,-7.72e-04,-5.48e-04,-4.15e-04,
     1        -3.88e-04,-4.33e-04,-5.12e-04,-6.30e-04,-4.27e-04/)
         endif
c Soil amplification
      bln = (/-7.52e-01,-7.45e-01,-7.40e-01,-7.35e-01,-7.30e-01,-7.26e-01,-7.16e-01,
     1        -7.00e-01,-6.90e-01,-6.70e-01,-6.00e-01,-5.00e-01,-4.45e-01,-3.90e-01,
     1        -3.06e-01,-2.80e-01,-2.60e-01,-2.50e-01,-2.32e-01,-2.49e-01,-2.86e-01,
     1        -3.14e-01,-3.22e-01,-3.30e-01,-3.61e-01,-6.00e-01/)
      b1 = (/-3.00e-01,-3.10e-01,-3.30e-01,-3.52e-01,-3.75e-01,-3.95e-01,-3.40e-01,
     1        -4.40e-01,-4.65e-01,-4.80e-01,-4.95e-01,-5.08e-01,-5.13e-01,-5.18e-01,
     1        -5.21e-01,-5.28e-01,-5.60e-01,-5.95e-01,-6.37e-01,-6.42e-01,-6.43e-01,
     1        -6.09e-01,-6.18e-01,-6.24e-01,-6.41e-01,-4.95e-01/)
      b2 = (/0.00e+00,0.00e+00,0.00e+00,0.00e+00,0.00e+00,0.00e+00,0.00e+00,0.00e+00,
     1        -2.00e-03,-3.10e-02,-6.00e-02,-9.50e-02,-1.30e-01,-1.60e-01,-1.85e-01,
     1        -1.85e-01,-1.40e-01,-1.32e-01,-1.17e-01,-1.05e-01,-1.05e-01,-1.05e-01,
     1        -1.08e-01,-1.15e-01,-1.44e-01,-6.00e-02/)
      del=(/0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,
     1 0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.11/)
           m1=(/6.,5.75,5.5,5.25,5.,4.84,4.67,4.5,4.34,4.17,4.,3.65,3.3,2.9,2.5,1.85,1.15,0.5,
     1 0.34,0.17,0.,0.,0.,0.,0.5,2.0/)
       mh=(/8.5,8.37,8.25,8.12,8.,7.7,7.45,7.2,6.95,6.7,6.5,6.37,6.25,6.12,6.0,5.84,
     1 5.67,5.5,5.34,5.17,5.0,5.0,5.0,5.0,5.5,5.5/)
c stress adjustment factors, table 7
c 
      period=abper(iq)
      sp=period.gt.0.02.and.period.lt.0.5
c loop on dtor
c      write(6,*)period,ntor,ndist,nmag,sp
      do 104 kk=1,ntor
c R: For near-surface dtor a singularity is possible. Limit at 2 km minimum.
      H1=max(dtor(kk),2.)
      H1sq=H1*H1
      et = deagg .and. kk.eq.1
c mag loop
        do 104 m=1,nmag
        weight= wt(ip,ia,1)
              xmag0= magmin + (m-1)*dmag
      if(icode(ip,ia).eq.0)then
        Mw= xmag0
        elseif(icode(ip,ia).eq.1)then
         Mw= 1.14 +0.24*xmag0+0.0933*xmag0*xmag0
         else
        Mw = 2.715 -0.277*xmag0+0.127*xmag0*xmag0
        endif
        gndm = c1(25) + c2(25)*Mw + c3(25)*Mw*Mw 
        gndmp = c1(iq) + c2(iq)*Mw + c3(iq)*Mw*Mw 
c      write(6,*)Mw,gndm,weight
c distance loop. R (Rcd) is closest dist to a vertical-dipping fault.
      if(ir.gt.2)then
       diff=max(Mw-m1(iq),0.)
c sf2 is supposed to be eqn(6) of AB06 paper. Note use of Mw.
       sf2=stressfac*min( del(iq)+0.05, 0.05+del(iq)*diff/(mh(iq)-m1(iq)))
c       write(6,*)diff,sf2,ir,iq
      ie=2
       else
       sf2=0.0
c default stress factor, use ie=1
       ie=1
       endif
        do 103 ii=1,ndist
        rjb=(ii-0.5)*di
        R=sqrt(rjb**2+H1sq)
      if(rjb.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)

c pga calculations
      rfac=alog10(R)
      f0 = max(1.-rfac,0.)
      f1 = min(rfac,fac70)
      f2 = max(rfac-fac140,0.)
      if(v30.gt.0.) then
c compute pga on rock
        gnd =gndm+ (c4(25)+c5(25)*Mw)*f1 +
     1        (c6(25)+c7(25)*Mw)*f2 + (c8(25)+c9(25)*Mw)*f0 + c10(25)*R+sf2
c apply stress factor before nonlinear adjustments, which occur in eqn (7) of ab paper.
        if(v30.le.v1) then
          bnl = b1(iq)
        elseif(v30.le.v2) then
          bnl = (b1(iq) - b2(iq))*log(v30/v2)/facv1 + b1(iq)
        elseif(v30.le.vref) then
          bnl = b2(iq)*log(v30/vref)/facv2
        else
          bnl = 0.
        endif
        pga_bc=10**gnd
        if(ir.eq.2.or.ir.eq.4)then
         S=0.0
        elseif(pga_bc.le.60.) then
          S = bln(iq)*log(v30/vref) + bnl*tfac
        else
          S = bln(iq)*log(v30/vref) + bnl*log(pga_bc/100.)
        endif
c need to take alog10(exp(S)) according to eqns. 7a and 7b AB2006. p. 2200 bssa
      S = alog10(exp(S))		!new nov 26 2007.
      endif
      gnd = gndmp + (c4(iq)+c5(iq)*Mw)*f1 +
     1      (c6(iq)+c7(iq)*Mw)*f2 + (c8(iq)+c9(iq)*Mw)*f0 + c10(iq)*R +sf2+ S
      if (ip.lt.26) then
        gnd = gnd*sfac - gfac
      else
c pgv?
        gnd = gnd*sfac
      endif
c---following is for clipping gnd motions: 1.5g PGA, 3.0g 0.3& 0.2 s
          if(period.eq.0.)then
           gnd=min(0.405,gnd)
           elseif(sp)then
           gnd=min(gnd,1.099)
           endif
           t0=gnd + emax*sigma
      test= exp(t0)
c      if(m.eq.1)write(6,*) R,exp(gnd),test,Mw,sigma,exp(sfac*S),iq
      if(clamp(iq).lt.test.and.clamp(iq).gt.0.)then
       clamp2= alog(clamp(iq))
      else
       clamp2= t0
      endif
      tempgt3= (gnd- clamp2)*sigmaf
      probgt3= (erf(tempgt3)+1.)*0.5
      do 102 k=1,nlev(ip)
      temp= (gnd- xlev(k,ip))*sigmaf
      temp1= (erf(temp)+1.)*0.5
      temp1= (temp1-probgt3)/(1.-probgt3)
      if(temp1.lt.0.) goto 103
      fac=weight*temp1
      pr(ii,m,k,ip,kk,1)= pr(ii,m,k,ip,kk,1) + fac
      if(et)e0_ceus(ii,m,ip) = e0_ceus(ii,m,ip)-sqrt2*temp*fac
  102  continue
  103 continue      !dist loop
  104 continue      !mag & dtor loops
      return
      end subroutine getAB06

c 
      subroutine getTP05(ip,iq,ia,ndist,di,nmag,magmin,dmag)
c for what range of vs30 is this one supposed to be valid? SH nov 13 2006
c Coeff c1 has a hard-rock version which is used if v30>1500 m/s. Is this a
c good boundary? For 900 to 1500 m/s, a middle value. Then a BC value.
c cj(0.4s) interpolated from (ln f, a(f)) 
c ditto for 0.04s. Use cubic splines to interpolate (pgm intTP05.f)
      parameter (np=16,emax=3.0,sqrt2=1.414213562)
      common/geotec/v30,dbasin
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
       common / atten / pr, xlev, nlev, icode, wt, wtdist
      common/deagg/deagg
      common/e0_ceus/e0_ceus(310,31,8)
      real pr(310,38,20,8,3,3),xlev(20,8),wt(8,10,2),wtdist(8,10) 
      integer nlev(8),icode(8,10)
      real f1,f2,f3,R,Rrup,Mw,cor,period,magmin,dmag
      real c5sq,corsq,H1sq
      logical et,deagg,sp      !for a short-period gm limit in ceus. 
      real,dimension(np):: Pd,c1,c1h,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,
     + c15,c16,clamp
      Pd = (/0.00e+00,.04,5.00e-02,8.00e-02,1.00e-01,1.50e-01,2.00e-01,3.00e-01,
     1 0.40,5.00e-01,
     1       7.50e-01,1.00e+00,1.50e+00,2.00e+00,3.00e+00,4.00e+00/)
           clamp = (/3.,6.,6.,6.,6.,6.,6.,6.,6.,6.,0.,
     + 0.,0.,0.,0.,0./)
      c1h = (/1.14e+00,2.2217764,1.82e+00,6.83e-01,8.69e-01,2.38e+00,-5.48e-01,-5.13e-01,
     1 0.18295555,
     1       2.40e-01,-6.79e-01,-1.55e+00,-2.30e+00,-2.70e+00,-2.42e+00,-3.69e+00/)
c c1 below is based on a CEUS A->BC conversion from c1h where c1h Vs30 is ? and c1 is ?. 
c Use of earlier models of siteamp for ceus. So for all periods we use Fr. 1996 terms.
c c1 modified at 0.1, 0.3, 0.5, and 2.0 s for Frankel ceus amp. mar 19 2007.
c c1 checked for pga, 1hz and 5hz apr 17 2007. c1(0.4s) added June 30
      c1 = (/1.559e+00,2.6819708,2.24e+00,1.10e+00,1.4229,2.87e+00,1.70e-02,0.0293,
     1 0.9333664,
     1       6.974e-01,-3.23e-01,-1.257e+00,-1.94e+00,-2.5177,-2.28,-2.28/)
      c2 = (/6.23e-01,0.42201685,5.33e-01,7.43e-01,6.07e-01,5.01e-01,8.57e-01,6.67e-01,
     1 0.5887256,
     1       6.11e-01,6.66e-01,7.64e-01,7.94e-01,8.05e-01,8.01e-01,8.17e-01/)
      c3 = (/-4.83e-02,-0.05892166,-4.75e-02,-2.93e-02,-4.74e-02,-6.42e-02,-2.62e-02,
     1 -4.43e-02,-0.068179324,
     1       -7.89e-02,-8.30e-02,-8.59e-02,-8.84e-02,-9.29e-02,
     1       -1.08e-01,-1.18e-01/)
c c4(2.5hz) spline
      c4 = (/-1.81e+00,-1.5474958,-1.63e+00,-1.71e+00,-1.52e+00,-1.73e+00,-1.68e+00,
     1 -1.42,-1.4782926,
     1       -1.55e+00,-1.48e+00,-1.49e+00,-1.45e+00,-1.44e+00,
     1       -1.65e+00,-1.46e+00/)
      c5 = (/-6.52e-01,-0.46962538,-5.67e-01,-7.56e-01,-7.04e-01,-9.76e-01,-8.61e-01,
     1 -4.70e-01,-0.6740682,
     1       -8.44e-01,-7.34e-01,-9.41e-01,-8.86e-01,-9.23e-01,
     1       -8.98e-01,-8.45e-01/)
      c6 = (/4.46e-01,0.44941282,4.54e-01,4.60e-01,4.49e-01,4.14e-01,4.33e-01,4.68e-01,
     1 0.4376,0.43636485,
     1       4.35e-01,4.24e-01,4.12e-01,4.08e-01,4.37e-01,4.25e-01/)
      c7 = (/-2.93e-05,9.11331E-3,7.77e-03,-9.68e-04,-6.19e-03,6.60e-03,2.79e-03,1.08e-02,
     1  9.212394E-3,7.89e-03,
     1      9.53e-03,-5.84e-03,8.30e-03,2.06e-02,1.67e-02,1.13e-02/)
c 
      c8 = (/-4.05e-03,-4.7678155E-3,-4.91e-03,-4.94e-03,-4.70e-03,-4.80e-03,-3.65e-03,
     1 -5.41e-03, -4.63148E-3,
     1       -3.65e-03,-3.37e-03,-2.09e-03,-3.27e-03,-2.14e-03,
     1       -2.03e-03,-1.72e-03/)
      c9 = (/9.46e-03,-1.5620958E-3,-3.14e-03,-5.50e-03,-4.24e-03,3.93e-03,-2.02e-03,6.44e-03,
     1 4.467385E-3,
     1       -2.65e-04,-1.19e-03,3.30e-03,2.51e-03,2.30e-03,3.58e-03,-3.34e-03/)
      c10 = (/1.41e+00,0.90152883,9.80e-01,1.13e+00,1.04e+00,1.51e+00,1.64e+00,1.52e+00,
     1 1.543476,
     1       1.59e+00,1.55e+00,1.52e+00,1.71e+00,1.43e+00,1.93e+00,1.69e+00/)
c c11 c10 and c9 log(f) interp 
      c11 = (/-9.61e-01,-0.95111495,-9.39e-01,-9.16e-01,-9.13e-01,-8.65e-01,-9.25e-01,
     1 -9.15e-01,-0.8872426,
     1       -8.59e-01,-7.84e-01,-7.57e-01,-7.69e-01,-7.55e-01,
     1       -8.18e-01,-7.37e-01/)
      c12 = (/4.32e-04,4.995133E-4,5.12e-04,4.82e-04,4.11e-04,3.64e-04,1.61e-04,4.32e-04,
     1 3.839152E-4,
     1       2.77e-04,2.45e-04,1.17e-04,2.33e-04,2.14e-04,1.16e-04,1.10e-04/)
c 
      c13 = (/1.33e-04,8.605951E-4,9.30e-04,7.33e-04,3.58e-04,6.84e-04,6.43e-04,2.87e-04,
     1 1.2648004E-4,
     1       1.46e-04,5.47e-04,7.59e-04,1.66e-04,3.91e-04,3.98e-04,3.59e-04/)
      c14 = (/1.21e+00,1.221863,1.22e+00,1.22e+00,1.23e+00,1.24e+00,1.24e+00,1.26e+00,
     1 1.2742121,
     1       1.28e+00,1.28e+00,1.28e+00,1.27e+00,1.26e+00,1.26e+00,1.25e+00/)
c for c15, corrected value for the 0.5-s or 2 Hz motion, from email Pezeshk dec 7 2007
      c15 = (/-1.11e-01,-0.10814471,-1.08e-01,-1.08e-01,-1.08e-01,-1.08e-01,-1.08e-01,
     1       -1.09e-01,-0.10839832,
     1 -1.073e-01,-1.05e-01,-1.03e-01,-9.99e-02,-9.78e-02,
     1       -9.52e-02,-9.26e-02/)
      c16 = (/4.09e-01,0.43780863,4.41e-01,4.49e-01,4.56e-01,4.64e-01,4.69e-01,4.79e-01,
     1 0.49330785,5.05e-01,5.22e-01,5.37e-01,5.51e-01,5.62e-01,5.73e-01,5.89e-01/)
cc loop on dtor
      write(6,*)'entering TP05, period ',Pd(iq),ndist,nmag
      period = Pd(iq)
      sp = period.lt.0.5.and. period.gt.0.02
      c5sq=c5(iq)*c5(iq)
      do 104 kk=1,ntor
c R: For near-surface dtor a singularity is possible. Limit at 2 km minimum.
      H1=max(dtor(kk),2.)
      H1sq=H1*H1
      et= kk.eq.1.and.deagg
c mag loop
        do 104 m=1,nmag
        weight= wt(ip,ia,1)
              xmag0= magmin + (m-1)*dmag
      if(icode(ip,ia).eq.0)then
        Mw= xmag0
        elseif(icode(ip,ia).eq.1)then
         Mw= 1.14 +0.24*xmag0+0.0933*xmag0*xmag0
         else
        Mw = 2.715 -0.277*xmag0+0.127*xmag0*xmag0
        endif
      if (Mw.lt.7.2) then
        sigma = c14(iq) + c15(iq)*Mw 
      else
        sigma = c16(iq)
      endif
      sigmasq=sigma*sqrt2
      sigmaf = 1./sigmasq
c possible hardrock factor versus BC rock below:
      if (v30.ge.1500.0) then
c hard rock NEHRP A
        f1 = c1h(iq) + c2(iq)*Mw + c3(iq)*(8.5 - Mw)**2.5
        if(m.eq.1)print *,'TP relation with c1h = ',c1h(iq)
      elseif(v30.gt.900.)then
c add intermediate range B rock coeff, jul 1 2008, 900 to 1500 m/s.
        f1=0.5*(c1h(iq)+c1(iq))+ c2(iq)*Mw + c3(iq)*(8.5 - Mw)**2.5
        if(m.eq.1)print *,'TP relation with c1havg = ',0.5*(c1h(iq)+c1(iq))
      else
        f1 = c1(iq) + c2(iq)*Mw + c3(iq)*(8.5 - Mw)**2.5
        if(m.eq.1)print *,'TP relation with c1 = ',c1(iq)
      endif
      cor = exp(c6(iq)*Mw + c7(iq)*(8.5 - Mw)**2.5)
      corsq=cor*cor
c loop on epicentral dist
      do 103 ir=1,ndist
      rjb=(float(ir)-0.5)*di
      if(rjb.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
      Rrup=sqrt(rjb*rjb+H1sq)
      f2 = c9(iq)*log(Rrup + 4.5)
      if (Rrup.gt.70.) f2 = f2 + c10(iq)*log(Rrup/70.)
      if (Rrup.gt.130.) f2 = f2 + c11(iq)*log(Rrup/130.)
      R = sqrt(Rrup*Rrup + c5sq*corsq)
      f3 = (c4(iq) + c13(iq)*Mw)*log(R) + (c8(iq) + c12(iq)*Mw)*R
      gnd = f1 + f2 + f3
c---following is for clipping gnd motions: 1.5g PGA, 3.75g 0.3, 3.75g 0.2 
          if(period.eq.0.)then
           gnd=min(0.405,gnd)
           elseif(sp)then
           gnd=min(gnd,1.099)
           endif
           t0=gnd + emax*sigma
      test= exp(t0)
c      if(m.eq.10)write(6,*) Rrup,exp(gnd),sigmaf,Mw,R,test
      if((clamp(iq).lt.test).and.(clamp(iq).gt.0.))then
       clamp2= alog(clamp(iq))
      else
       clamp2= t0
      endif
      tempgt3= (gnd- clamp2)*sigmaf
      probgt3= (erf(tempgt3)+1.)*0.5
      prr= 1.0/(1.-probgt3)
      do 102 k=1,nlev(ip)
      temp= (gnd- xlev(k,ip))*sigmaf
      temp1= (erf(temp)+1.)*0.5
      temp1= (temp1-probgt3)*prr
      if(temp1.lt.0.) goto 103
      fac=weight*temp1
      pr(ir,m,k,ip,kk,1)= pr(ir,m,k,ip,kk,1) + fac
      if(et)e0_ceus(ii,m,ip)= e0_ceus(ii,m,ip)-sqrt2*temp*fac
  102  continue
  103 continue      !dist loop
  104 continue      !mag & dtor loops
      return
      end subroutine getTP05

        subroutine SomerIMW(iprd, xmag,  R_Rup, rjb,V_S30, 
     1 gnd,sigmaf)
c Somerville et al prepared this model for USGS from finite-fault gm simulations.
c Coding by Stephen Harmsen. This model was designed for fault hazard in
c intermtn west. Should not be used in compressional regimes. Could be used with
c gridded hazard when M >= 6, i.e., when the faults are modeled with finite length.
c As of Jan 31 2007 not ready for gridded. Do not use.
        integer mxnprd
        parameter (mxnprd=5)
        parameter (pi=3.14159265,sqrt2=1.414213562)
        parameter(Hsq = 42.25)  !H=6.5 in Somerville document
        common/mech/wtss,wtrev,wtnormal
      common/deagg/deagg
c Outputs gnd=ln(median) and sigmaf, two scalar quantities needed for Pex calcs.
c To DO: Find out if we want to include a site_amp feature with this subroutine
c Predictor variables, xmag = moment mag, R_Rup=nearest distance to the 
c fault plane (rupture surface), and rjb=joyner-boore dist. 
c Model requires no dip, no depth to top information. Hmm.
        real  xmag, Width, R_rup,  V_S30, rjb, hw
        logical deagg,ss,rev,normal,obl
c Model coefficients
        real, dimension(mxnprd) :: prd,c1,c2,c3,c4,c5,c6,c7,c9,sigma_t
c prd array not used below. Assume SA 0.01 s is PGA.
c the coefficients
       prd=(/0.010,0.200,0.300,1.000,5.000/)
       c1=(/6.764,7.305,7.183,6.594,-4.598/)
        c2=(/-0.758,-0.758,-0.758,-0.758,0.633/)
        c3=(/-1.8,-1.597,-1.515,-1.480,-0.827/)
        c4=(/0.1375,0.1202,0.1156,0.0954,0.0005/)
        c5=(/-0.0104,-0.0104,-0.0104,-0.0055,-0.0018/)
        c6=(/-0.236,-0.236,-0.236,-0.351,-0.351/)
        c7=(/0.212,0.212,0.212,0.212,0.085/)
        sigma_t=(/0.6016,0.6073,0.6027,0.6270,0.8241/)
c the terms
      if(deagg)stop'hazgridXnga13l: deagg not set up for getSomerIMW'
      ss = wtss.gt.0.9
        rc=sqrt(R_rup**2+Hsq)
        alogR=alog(rc)
        gnd=c1(iprd)+c2(iprd)*xmag+(c3(iprd)+c4(iprd)*xmag)*alogR
        gnd=gnd+c5(iprd)*R_rup+c6(iprd)*(8.5-xmag)**2
         sigmaf=1.0/sigma_t(iprd)/sqrt2
c if strike slip or fw, do not include hanging wall effects.
        if(ss.or.rjb.gt.0.5.or.R_Rup.ge.20.)return
c Otherwise boost median with hanging wall term. may need to taper off edges
        if(R_Rup.lt.5.)then
        hw=0.2*R_Rupz*wtnormal
        elseif(R_Rup.lt.15.)then
        hw=wtnormal
        else
        hw=wtnormal*(1.0-(R_Rup-15.0)*0.2)
        endif
        gnd=gnd+c7(iprd)*hw*(8.5-xmag)
        return
        end subroutine SomerIMW


      subroutine getSilva(ip,iq,ir,ia,ndist,di,nmag,magmin,dmag)
c Inputs: xmag = moment mag, dist = rjb (km), see Nov 1, 2002 doc page 4
c magmin=min mag for array building, nmag= number of mags for aforesaid array
c ip = index of spectral period in the wt() matrix. wt() is the epistemic weight
c       previously assigned to this relation.
c iq is index in pd array for current spectral period, iq shuld be in 1 to 8 range.
c ir is hardrock (-1) or BCrock indicator (+1).
c Silva (2002) table 5, p. 13. Single corner, constant stress drop, w/saturation.
c parts of this subroutine are from frankel hazFXv7 code. S Harmsen
c Added 2.5 and 25 hz July 1 2008 (for NRC projects). Add 20 hz, or 0.05 s. july 6
      parameter (sqrt2=1.414213562,npmx=11)
c There is a new CEUS document (7/2008) at 
c pacificengineering.com. looks different from the 2002 CEUS model.
      common/geotec/v30,dbasin
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
       common / atten / pr, xlev, nlev, icode, wt, wtdist
      common/deagg/deagg
       common/e0_ceus/e0_ceus(310,31,8)
      real pr(310,38,20,8,3,3),xlev(20,8),wt(8,10,2),wtdist(8,10) 
      integer nlev(8),icode(8,10)
c m-index of 30 allows 4.5 to 7.5 because of dM/2 shift (4.55 to 7.45 by 0.1)
         real magmin,dmag,di,fac,fac2,gnd,gnd0,period,test0,test
         logical sp,deagg      !sp=short period data different clamping (included here)
      real, dimension(npmx) :: c1,c1hr,c2,c3,c4,c5,c6,c7,c8,c9,c10,pd,sigma,clamp
      pd=(/0.,0.04,0.05,0.1,0.2,0.3,0.4,0.5,1.,2.,5./)
      clamp = (/3.,6.,6.,6.,6.,6.,6.,6.,0.,0.,0./)	! reviewed apr 10 2008.
      c1hr=(/5.53459,6.81012,6.63937,5.43782,3.71953,2.60689,
     1 1.64228,0.69539,-2.89906,-7.42051,-13.69697/)
c c1 from c1hr using A->BC factors, 1.74 for 0.1s, 1.72 for 0.3s, 1.58 for 0.5s, and 1.20 for 2s
c this from A Frankel advice, Mar 14 2007. For 25 hz use PGA amp. 
c For BC at 2.5 hz use interp between .3 and .5. 1.64116 whose log is 0.4953 
        c1=(/5.9533, 7.2288,7.023,5.9917,4.2848,3.14919,2.13759,
     1 1.15279,-2.60639,-7.23821,-13.39/)
       c2=(/-.11691,-0.13594,-.12193,-0.02059,.12490,.23165,.34751,
     1 .45254,.88116,1.41946,2.03488/)
      c4=(/ 2.9,3.0,3.,2.9,2.8,2.8,2.8,2.8,2.8,2.7,2.5/)     
      c6=(/ -3.42173,-3.48499,-3.45478,-3.25499,-3.04591,-2.96321,-2.87774,
     1 -2.818,-2.58296,-2.26433,-1.91969/)
      c7=(/ .26461,.26220,0.26008,0.24527,.22877,.22112,.21215,
     1 .20613,.18098,.14984,.12052/)
      c10=(/ -.06810,-.06115,-.06201,-0.06853,-.08886,-0.11352,-.13838,
     1 -0.16423,-.25757,-0.33999,-0.35463/)
c note very high sigma for longer period SA:
      sigma= (/.8471,0.8870,0.8753,0.8546,.8338,0.8428,.8386,
     1 0.8484,.8785,1.0142,1.2253/)
c clamping  to be done in main not in subroutines.
        if(ir.eq.1)then
        c=c1(iq)
        else
        c=c1hr(iq)
        write(6,*)'getSilva hardrock c1hr coef used.'
        endif
      period=pd(iq)
      sp=period.gt.0.02.and.period.lt.0.5
c loop on dtor
      write(6,*)period,ntor,ndist,nmag,sp
      sig=sigma(iq)
        sigmaf= 1.0/(sig*sqrt2)
      sigmasq = sig*sqrt2
c mag loop
        do 104 m=1,nmag
        weight= wt(ip,ia,1)
              xmag0= magmin + (m-1)*dmag
      if(icode(ip,ia).eq.0)then
        xmag= xmag0
        elseif(icode(ip,ia).eq.1)then
         xmag= 1.14 +0.24*xmag0+0.0933*xmag0*xmag0
         else
        xmag = 2.715 -0.277*xmag0+0.127*xmag0*xmag0
        endif
        gnd0= c + c2(iq)*xmag+ c10(iq)*(xmag-6.0)**2
       fac=  c6(iq)+c7(iq)*xmag
c loop on epicentral dist
c      write(6,*)'xmag, fac, gnd0',xmag,fac,gnd0
      do 103 ii=1,ndist
      rjb=(float(ii)-0.5)*di
      if(rjb.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
c this formula uses closest distance to surface proj.
        gnd = gnd0+fac*alog(rjb+exp(c4(iq)))
c--- modify for possible median clipping 
c---following is for clipping gnd motions: 1.5g PGA, 3.75g 0.3, 3.75g 0.2 
          if(period.eq.0.)then
           gnd=min(0.405,gnd)
           elseif(sp)then
           gnd=min(gnd,1.099)
           endif
           test0=gnd + 3.*sig
      test= exp(test0)
      if(clamp(iq).lt.test .and. clamp(iq).gt.0.) then
      clamp2= alog(clamp(iq))
      else
       clamp2= test0
       endif
      tempgt3= (gnd- clamp2)/sigmasq
      probgt3= (erf(tempgt3)+1.)*.5
      do 102 k=1,nlev(ip)
      temp= (gnd- xlev(k,ip))/sigmasq
      temp1= (erf(temp)+1.)*.5
      temp1= (temp1-probgt3)/(1.-probgt3)
      if(temp1.lt.0.) goto 103
      fac2=weight*temp1
      if(deagg)e0_ceus(ii,m,ip)= e0_ceus(ii,m,ip)-sqrt2*temp*fac2
      do 102 kk=1,ntor
c no variation wrt depth of rupture in the Silva model.
c Assume no branching on median motion(last subscr) for eastern US
      pr(ii,m,k,ip,kk,1)= pr(ii,m,k,ip,kk,1) + fac2
  102 continue
  103 continue
  104 continue

      return
      end subroutine getSilva

c
      subroutine avghw_cy(ip,avghwcy,nmag,magmin,dmag)
c input:
c ip =period index in prd, c9 below
c nmag = number of magnitudes
c magmin = minimum mag sampled in gridded hazard. 
c dmag mag increment
c output:
c  avghwcy, the average  increase (lnY (g) units) associated with hanging-wall
c site location. Increase is 0 if site happens to be on footwall (R_x<0)
c 

c Purpose of subroutine:
c get the avg chiou-youngs hw term for dipping faults of random orientation, M ranges
c from magmin to upper limit
c      use log(A)=(M-4.07)/0.98
c      set z0=7.5 km deep
c rotate fault through pi radians and find coords of top of fault
c Buried dipping fault, use aspect ratio of 1.5 if possible. 
c Additional Constraint: Top of fault must be at least 0.5 km deep
c Output is the hw term averaged over strike. output is in lnY (g) units
c The average h.w. effect has to be associated with an average Rjb for
c vertical faults. However, we have shown that dipping faults tend to be
c closer than vertical faults. Although the difference is distance and M
c dependent, we define a simplified model of this difference:
c For M<6.3, Rjbbar(SS)=Rjbbar(DS)+2 km
c For M>=6.3 and M < 6.8, Rjbbar(SS)=Rjbbar(DS)+3 km
c and For 6.8< M <=7.1 Rjbbar(SS)=Rjbbar(DS)+ 4 km. 
c For M>7.1, Rjbbar(SS)= rjbbar(DS) +5. This is applied to 60 km, then
c no corrections between the two are made.
c Steve Harmsen dec 18 2007. Add pgv coeffs Jan 2009.
      parameter (d2r=0.0174533,pi=3.14159265,np=106)
      real, dimension (np):: prd,c9,c9a
      real amag,H,Hsq,M,x(2),y(2),magmin,dmag,rjbbar
      real, dimension(0:310,31):: avghwcy
      integer i,ip
c prd array  used below. Assume SA 0.01 s is PGA.
       prd= (/0.010,0.020,0.022,0.025,0.029,0.030,0.032,0.035,0.036,0.040,0.042,0.044,0.045,0.046,
     10.048,0.050,0.055,0.060,0.065,0.067,0.070,0.075,0.080,0.085,0.090,0.095,0.100,0.110,0.120,
     10.130,0.133,0.140,0.150,0.160,0.170,0.180,0.190,0.200,0.220,0.240,0.250,0.260,0.280,0.290,
     10.300,0.320,0.340,0.350,0.360,0.380,0.400,0.420,0.440,0.450,0.460,0.480,0.500,0.550,0.600,
     10.650,0.667,0.700,0.750,0.800,0.850,0.900,0.950,1.000,1.100,1.200,1.300,1.400,1.500,1.600,
     11.700,1.800,1.900,2.000,2.200,2.400,2.500,2.600,2.800,3.000,3.200,3.400,3.500,3.600,3.800,
     14.000,4.200,4.400,4.600,4.800,5.000,5.500,6.000,6.500,7.000,7.500,8.000,8.500,9.000,9.500,
     110.0,-1.0/)
       c9= (/ 0.79000, 0.81290, 0.81880, 0.82800, 0.84070, 0.84390,
     1  0.85020, 0.85940, 0.86240, 0.87400, 0.87950, 0.88480, 0.88740, 0.88990, 0.89490,
     1  0.89960, 0.91050, 0.92040, 0.92920, 0.93250, 0.93710, 0.94420, 0.95050, 0.95590,
     1  0.96060, 0.96450, 0.96770, 0.97180, 0.97330, 0.97250, 0.97190, 0.96990, 0.96600,
     1  0.96090, 0.95490, 0.94820, 0.94100, 0.93340, 0.91790, 0.90230, 0.89460, 0.88710,
     1  0.87260, 0.86570, 0.85900, 0.84620, 0.83420, 0.82840, 0.82280, 0.81210, 0.80190,
     1  0.79220, 0.78300, 0.77860, 0.77430, 0.76590, 0.75780, 0.73910, 0.72210, 0.70650,
     1  0.70150, 0.69220, 0.67880, 0.66620, 0.65400, 0.64230, 0.63080, 0.61960, 0.59750,
     1  0.57560, 0.55380, 0.53200, 0.51010, 0.48770, 0.46490, 0.44120, 0.41690, 0.39170,
     1  0.33900, 0.28330, 0.25460, 0.22620, 0.17220, 0.12440, 0.08460, 0.05380, 0.04200,
     1  0.03220, 0.01770, 0.00860, 0.00310, 0.00040, 0.000, 0.000, 0.000, 0.000,
     1  0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.00000,.3079/)
      c9a= (/ 1.50050, 1.50276, 1.50351, 1.50456, 1.50667, 1.50712,
     1  1.50818, 1.51044, 1.51104, 1.51376, 1.51573, 1.51771, 1.51862, 1.51953, 1.52135,
     1  1.52303, 1.52974, 1.53587, 1.54280, 1.54635, 1.55162, 1.55971, 1.56784, 1.57917,
     1  1.59011, 1.60047, 1.61043, 1.63837, 1.66446, 1.69266, 1.70233, 1.72461, 1.75488,
     1  1.78479, 1.81939, 1.85280, 1.88476, 1.91573, 1.98060, 2.04153, 2.07094, 2.09824,
     1  2.15050, 2.17581, 2.20053, 2.24678, 2.28462, 2.30297, 2.32100, 2.35585, 2.38858,
     1  2.41259, 2.43562, 2.44685, 2.45788, 2.47936, 2.50002, 2.53375, 2.56459, 2.58933,
     1  2.59529, 2.60648, 2.62243, 2.63663, 2.64561, 2.65382, 2.66153, 2.66899, 2.67728,
     1  2.68505, 2.69096, 2.69474, 2.69851, 2.70148, 2.70337, 2.70527, 2.70689, 2.70851,
     1  2.71014, 2.71177, 2.71231, 2.71285, 2.71367, 2.71448, 2.71502, 2.71529, 2.71556,
     1  2.71584, 2.71611, 2.71638, 2.71665, 2.71665, 2.71692, 2.71692, 2.71720, 2.71747,
     1  2.71747, 2.71774, 2.71774, 2.71774, 2.71801, 2.71801, 2.71801, 2.71801, 2.71801,
     + 2.669/)
c      print 5,'Enter spectral period (s) : '
c      read *,per
c      if(per.eq.0.)per=0.01
c      ip=1
c      dowhile(per.ne.prd(ip))
c      ip=ip+1
c      if(ip.gt.105)stop'cy doesnt have this one'
c      enddo
c      print *,prd(ip)
      print *,prd(ip),' CY c9 & c9a for this period ',c9(ip),c9a(ip)
c      open(2,file='test.cy.dip.out',status='unknown')
      M=magmin
c      print *,'output file is test.cy.dip'
c      print 5,'Enter strike sampling increment (deg), 10 22.5 or 45: '
c      read *,dtheta
c delta = dip =50 d
      avghwcy =0.	!initialize to zero. important on PCs.
      dtheta=15.
      dip0=50.0
c      write(2,8)dip0,dtheta
8      format('#test.cy.dip.f generate avg hw effect. Flt dip ',f4.1,' strike sampling ',
     + f5.1,' degree increment')      
      dtheta = dtheta*d2r
      nstep = 1 +nint(pi/dtheta)
c fix all hypocenters at 7.5 km
      z0=7.5
c Set fault centers at <x0,y0,z0>. define profile of sites west starting here.
c Might want to randomize z0 some. Also fault dip
      x0=-100.0
      y0=40.0
      ykm2d = 1./111.
      xkm2d = ykm2d /cos(y0*d2r)
c
c delta = dip =50 d
      dip0=50.0
        cosDELTA=cos(dip0*d2r)
        sinDELTA=sin(dip0*d2r)
c      Loop thru M from low to high limit
5      format(a,$)

      do k=1,15
c base area on w&c formula for all sources. 
        area =  10**((M-4.07)/0.98)
      amag=M
      wmax = 14./sinDELTA
      w=sqrt(area/1.5)	!aspect ratio 1.5
      w= min (w,wmax)
      xl=area/w
c      print *,M,area,w,xl,wmax
      theta=0.
      xl0=xl/2.
      w0= w/2.*cosDELTA
      z1=z0-w/2.*sinDELTA
      H= z1	!campbell H or CY ztor
      Hsq=H*H
c      write(2,6)M,z1,prd(ip)
6      format(/,'#stadist CY_hw exp() Rrbar(km) for M ',f6.2,'; top ',f4.2,' km;',
     +' period(s)=',f6.2)
c           stop
c z1 (km) is depth of top of rupture
      do ista=0,300
c sample receivers at fault center and go West 300 km in 1-km increments
      theta = 0.0
      rx=x0-float(ista) *xkm2d
      ry=y0
      hwavg=0.0
      rrbar=0.; rjbbar=0.0
      do i=1,nstep
c      write(2,22)theta/d2r
22      format(/,'# theta ',f6.1)
      xc=x0-w0*cos(theta)*xkm2d
      yc=y0+w0*sin(theta)*ykm2d
      xmove=xl0*sin(theta)*xkm2d
      ymove=xl0*cos(theta)*ykm2d
      x(1)=xc-xmove
      y(1)=yc-ymove
      x(2)=xc +xmove
      y(2)=yc+ymove
c      write(2,66)x(1),y(1),z1,x(2),y(2),z1
      call mindist1(rrup,azm,rjb,azb,R_x,ry,rx,y,x,2,dip0,w,z1)
      fhw=0.0
      rjbsq=rjb*rjb
c HW effect. R_x < 0 means site is on footwall and no effect.
        if (R_x .lt. 0) then
          hw = 0.0
        else
          hw = c9(ip) * tanh(R_x*cosDELTA**2/c9a(ip)) *
     1        (1.0 - sqrt(rjbsq+Hsq)/(rrup + 0.001))
        endif

      hwavg=hwavg+hw
c      rrbar=rrbar+rrup
      rjbbar=rjbbar+rjb
      theta= theta+ dtheta
66      format(3f10.4)
      enddo
      hwavg=hwavg/nstep
c      rrbar=rrbar/nstep
      rjbbar=rjbbar/nstep
c      write(2,200)ista,hwavg,exp(hwavg),rrbar,rjbbar,rx	!mean value
      iim=nint(rjbbar)
      if(M.lt.6.)then
c Dip slip and strike slip are essentially point sources. same distance
      iip=iim
      else
      if(iim.ge.1.and.iim.lt.50)then
c make a correction based on differecne between rjb(dipslip) and rjb(strikeslip)
c for Rjb < 50 km the dip slip average is closer to receiver than the strikeslip avg.
c Because the ss avg rjb is the one used in MAIN, we have to add this difference
c to the dipslip avg. If in future revisions a separate p() matrix is set
c up for dipslip sources, this little kludge conversion will no longer be needed.
c SHarmsen Dec 17 2007.
      if(M.lt.6.3)then
      iip=iim+2
      elseif(M.lt.6.8)then
      iip=iim+3
      elseif(M.lt.7.1)then
      iip=iim+4
      else
      iip=iim+5
      endif
      if(iim.gt.1)iim=iip	!rapid rise is handled at iim=1
      else
      iip=iim
      endif	!rjb>1 and rjb < 60
      endif	!M>=6
c there are several repi distances with about the same rjb. 
c rjb associated with the largest repi will end up here.
      do ii=iim,iip
      avghwcy(ii,k)=hwavg
      enddo
      enddo	!ista
      M=M+dmag
      enddo
c      close(2)
c      print *,amag,c9(ip),H,hw
200      format(i3,1x,f8.5,1x,f8.5,2(1x,f8.4),1x,f10.5)
      return
      end subroutine avghw_cy

      subroutine avghw_cb(ip,avghwcb,nmag,magmin,dmag)
c get the avg cb hanging-wall term for dipping faults of random orientation, M ranges
c from 6.05 to 7.45
c base area on w&c formula for all sources. 
c        area =  10**((M-4.07)/0.98)
c      set z0=7.5 km deep
c rotate fault through pi radians and find coords of top of fault
c use aspect ratio of 1.5 if possible. top must be at least 0.5 km deep
c output is <dist, effect> where dist =0 to 300 km from center at -100,40.
c effect is lnY effect also in 3rd column is the Y-effect (g).
c the effect is applied at the average rjb distance. avg rjb is the
c fundamental distance at many places in this program
      parameter (d2r=0.0174533,pi=3.14159265,sqrt2=1.414213562,np=24)
      real,dimension (np) :: c9,Pd
      real amag,M,magmin,dmag,x(2),y(2)
      real, dimension(0:310,31) :: avghwcb
       c9=(/ 0.490, 0.490, 0.490, 0.490, 0.490, 0.490, 0.490, 0.490, 0.490, 0.490, 0.490, 0.490, 0.490,
     + 0.490, 0.490, 0.371, 0.154, 0.000, 0.000, 0.000, 0.000, 0.490, 0.358, 0.000/)
      Pd=(/0.010,0.020,0.030,0.050,0.075,0.100,0.150,0.200,0.250,0.300,0.400,0.500,0.750,
     + 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 7.5,10.0, 0.0,-1.0,-2.0/)
      print *,'CB coeff. c9 for this period ',c9(ip),' max factor ',exp(c9(ip))
      M=magmin
      dtheta=15.0	!15 degree strike increment from 0 to 180
c delta = dip =50 d
      dip0=50.0
      dtheta = dtheta*d2r
      nstep = 1 +nint(pi/dtheta)
5      format(a,$)
        cosDELTA=cos(dip0*d2r)
      sinDELTA=sin(dip0*d2r)
      wmax = 14./sinDELTA
      z0=7.5
      x0=-100.0
      y0=40.0
      ykm2d = 1./111.1
      xkm2d = ykm2d /cos(y0*d2r)
c
c
      if(dip0.le.70..or.dip0.ge.110.)then
      cbhwfac=1.
      else
      cbhwfac=abs(90.-dip0)/20.      
      endif
      kmin = max(1,nint((6.05-magmin)/dmag)+1)
      avghwcb =0
      print *,Pd(ip),kmin,magmin+dmag*(kmin-1),' CB min mag', nmag
      if(kmin.gt.nmag)return
c loop on magnitude. For CB NGA model, no HW effect for M<=6
      do k=1,nmag
c base area on w&c formula for all sources. 
        area =  10**((M-4.07)/0.98)
      amag=M
      if(M.lt.6.01)goto 250
      w=sqrt(area/1.5)	!aspect ratio 1.5
      w= min (w,wmax)
      xl=area/w
c      print *,M,area,w,xl,wmax
      theta=0
      xl0=xl/2.
      w0= w/2.*cosDELTA
      z1=z0-w/2.*sinDELTA
      H= z1	!campbell H
c      write(2,6)M,z1,Pd(ip)
c6      format(/,'#stadist Camp_f4 exp() Rrbar(km) for M ',f6.2,'; top ',f4.2,' km;',
c     +' period(s)=',f6.2)
c z1 (km) is depth of top of rupture
      iper=ip
      do ista=0,300
c sample receivers at fault center and go W 300 km in 1-km increments
      theta = 0.0
      rx=x0-float(ista) *xkm2d
      ry=y0
      campdr=0.0
      rjbbar=0.0	!the fundamental distance in this code
      do i=1,nstep
      xc=x0-w0*cos(theta)*xkm2d
      yc=y0+w0*sin(theta)*ykm2d
      xmove=xl0*sin(theta)*xkm2d
      ymove=xl0*cos(theta)*ykm2d
      x(1)=xc-xmove
      y(1)=yc-ymove
      x(2)=xc +xmove
      y(2)=yc+ymove
c      write(2,66)x(1),y(1),z1,x(2),y(2),z1
      call mindist1(rrup,azm,rjb,azb,R_x,ry,rx,y,x,2,
     +                   dip0,w,z1)
      fhw=0.0
      rjbbar=rjbbar+rjb
             if(amag.gt.6.0.and.H.lt.20.0)then
             if(rjb.eq.0.)then
             fhw=1.0      !eqn 7 jan 31 report
             elseif(H.lt.1.)then
c June 2006: new smoothing factor when rupture makes it to the surface or nearly makes it.
             rjbf=sqrt(rjb*rjb+1.0)
c next line is a correction of jan 16 2007. SH.
             fhw= (max(rrup,rjbf)-rjb) /max(rrup,rjbf)
             else
             fhw=(rrup-rjb)/rrup
              endif
             f4=c9(iper)*fhw*cbhwfac*(20.0-H)*0.05
             endif
c next corr is a damping factor for M<6.5. We wont be here if M<6
c so there is no need to consider the rest of CB eqn (8).
       if(amag.lt.6.5)f4 = f4 * 2.*(amag-6.0) 
             
      campdr=campdr+f4
      theta=theta+dtheta
66      format(3f10.4)
      enddo
      hwavg=campdr/nstep
      rjbbar=rjbbar/nstep
      iim = nint(rjbbar)		!because the index used is rjb
      if(iim.ge.1.and.iim.lt.50)then
c make a correction based on differecne between rjb(dipslip) and rjb(strikeslip)
c for Rjb < 60 km the dip slip average is closer than the strikeslip avg.
c Because the ss avg rjb is the one used in MAIN, we have to add this difference
c to the dipslip avg. If in future revisions a separate p() matrix is set
c up for dipslip sources, this little kludge conversion will no longer be needed.
c SHarmsen Dec 17 2007.
      if(M.lt.6.3)then
      iip=iim+2
      elseif(M.lt.6.8)then
      iip=iim+3
      elseif(M.lt.7.1)then
      iip=iim+4
      else
      iip=iim+5
      endif
      if(iim.gt.1)iim=iip	!rapid rise is handled at iim=1
      else
      iip=iim
      endif	!rjb>=1 and rjb < 60
      do ii=iim,iip
      avghwcb(ii,k)=hwavg
      enddo
      enddo	!ista
250      M=M+dmag
      enddo	! magnitude steps
      end subroutine avghw_cb

      subroutine mindist1(dist,azm,disb,azb,rx,stlat,stlon,solat,solon,ns,
     +                   dip,wid,ftop)
c.....................................................................
c  For calculating JB or rupture distance to a curved fault defined 
c  by extending the fault top segment trace down its dip direction
c
c  input:
c         stlat - station latitude
c         stlon - station longitude
c         solat - latitude of fault segment corners
c         solon - longitude of fault segment corners
c         ns    - number of fault segment corners
c         dip   - fault dip angle
c         wid   - fault width along the dip direction. wid>0 is a good constraint
c         ftop  - depth of fault top 
c  output:
c         dist  - minimum distance to rutpure plane
c         azm   - azimuth for rupture distance
c         disb  - JB distance to rutpure plane
c         azb   - azimuth for JB distance
c         rx    - distance to the surface projection of top edge of fault
c                                              Yuehua Zeng, 2007
c.....................................................................
      parameter (d2r = 3.1415926/180.)
      dimension solat(*),solon(*)
c
      dp=dip*d2r
      cosdp=cos(dp)
      sindp=sin(dp)
      dist=1.e10
      disb=1.e10
      call delaz2(solat(1),solon(1),solat(ns),solon(ns),flen,str1)
      call delaz2(solat(1),solon(1),stlat,stlon,dista,az)
      sx=dista*cos(az-str1)
      yy=dista*sin(az-str1)
      if(sx.le.0.0.or.sx.ge.flen)then; rx=yy
      else; rx=sign(sqrt(dista*dista+flen*(flen-sx-sx)),yy); endif
      do i=1,ns-1
         call delaz2(solat(i),solon(i),solat(i+1),solon(i+1),flen,str)
         call delaz2(solat(i),solon(i),stlat,stlon,dista,az)
c
         x=sindp
         y=cosdp*cos(str-str1)
         sindpp=x/sqrt(x*x+y*y)
         cosdpp=sqrt(1.0-sindpp*sindpp)
c
         sx=dista*cos(az-str)
         yy=dista*sin(az-str)
c
         if(sx.ge.0.0.and.sx.le.flen.and.abs(yy).lt.abs(rx))then;rx=yy
         elseif(sx.lt.0.0.and.dista.lt.abs(rx))then;rx=sign(dista,yy);endif
c
c  for JB distance
         sy=yy
         wid1=wid*cosdp
c
         cosfi=sin(str-str1)
         sinfi=sqrt(1.0-cosfi*cosfi)+1.0e-10
         syy=sy/sinfi
         sxx=sx-syy*cosfi
         r=-10.0
c
         if(sxx.lt.0.0.or.sxx.gt.flen)then
           y=sxx*cosfi+syy
           if(sxx.gt.flen)y=(sxx-flen)*cosfi+syy
           if(y.lt.0.0.or.y.gt.wid1)then
             if(y.gt.wid1)syy=syy-wid1
             x=syy*cosfi+sxx
             if(x.gt.flen)then
               sxx=sxx-flen
             elseif(x.ge.0.0)then
               r=abs(syy)*sinfi
               az0=90.0*sign(1.0,syy)
             endif
           else
             if(sxx.gt.flen)sxx=sxx-flen
             r=abs(sxx)*sinfi
             az0=(str1-str)/d2r-90.0+90.0*sign(1.0,sxx)
           endif
         elseif(syy.lt.0.0.or.syy.gt.wid1)then
           if(syy.gt.wid1)syy=syy-wid1
           x=syy*cosfi+sxx
           if(x.gt.flen)then
             sxx=sxx-flen
           elseif(x.ge.0.0)then
             r=abs(syy)*sinfi
             az0=90.0*sign(1.0,syy)
           endif
         else
           r=0.0
           az0=90.0
         endif
c
         if(r.lt.-1.0)then
           sxx=sxx+syy*cosfi
           syy=syy*sinfi
           r=sqrt(sxx*sxx+syy*syy)
           az0=atan2(syy,sxx)/d2r
         endif
         if(r.lt.disb)then
           disb=r
           azb=str/d2r+az0
         endif
c
c  for rupture distance
         sy=yy*cosdpp-ftop*sindpp
         sz=yy*sindpp+ftop*cosdpp
c
         cosfi=sin(str-str1)*cosdp
         sinfi=sqrt(1.0-cosfi*cosfi)+1.0e-10
         syy=sy/sinfi
         sxx=sx-syy*cosfi
         r=-10.0
c
         if(sxx.lt.0.0.or.sxx.gt.flen)then
           y=sxx*cosfi+syy
           if(sxx.gt.flen)y=(sxx-flen)*cosfi+syy
           if(y.lt.0.0.or.y.gt.wid)then
             if(y.gt.wid)syy=syy-wid
             x=syy*cosfi+sxx
             if(x.gt.flen)then
               sxx=sxx-flen
             elseif(x.ge.0.0)then
               r=abs(syy)*sinfi
               az0=90.0*sign(1.0,syy)
             endif
           else
             if(sxx.gt.flen)sxx=sxx-flen
             r=abs(sxx)*sinfi
             az0=(str1-str)/d2r-90.0+90.0*sign(1.0,sxx)
           endif
         elseif(syy.lt.0.0.or.syy.gt.wid)then
           if(syy.gt.wid)syy=syy-wid
           x=syy*cosfi+sxx
           if(x.gt.flen)then
             sxx=sxx-flen
           elseif(x.ge.0.0)then
             r=abs(syy)*sinfi
             az0=90.0*sign(1.0,syy)
           endif
         else
           r=0.0
           az0=90.0
         endif
c
         if(r.gt.-1.0)then
           r=sqrt(r*r+sz*sz)
         else
           sxx=sxx+syy*cosfi
           syy=syy*sinfi
           r=sqrt(sxx*sxx+syy*syy+sz*sz)
           az0=atan2(syy*cosdpp+sz*sindpp,sxx)/d2r
         endif
         if(r.lt.dist)then
           dist=r
           azm=str/d2r+az0
         endif
      end do
c
      return
      end
c
      subroutine delaz2(sorlat,sorlon,stnlat,stnlon,delta,az)
      parameter (coef= 3.1415926/180.)
      xlat= sorlat*coef
      xlon= sorlon*coef
      st0= cos(xlat)
      ct0= sin(xlat) 
      phi0= xlon
      xlat= stnlat*coef
      xlon= stnlon*coef
      ct1= sin(xlat)
      st1= cos(xlat)
      sdlon= sin(xlon-phi0)
      cdlon= cos(xlon-phi0)
      cdelt= st0*st1*cdlon+ct0*ct1
      x= st0*ct1-st1*ct0*cdlon
      y= st1*sdlon
      sdelt= sqrt(x*x+y*y)
      delta= atan2(sdelt,cdelt)
      delta= delta/coef
      az= atan2(y,x)
c     az= az/coef
      delta= delta*111.2
      return
      end    subroutine delaz2
      
      subroutine zhao(ip,iq,islab,ia,ndist,di,nmag,magmin,dmag)
c compute median and sigmaf for the Zhao model with Somerville correction
c added to gridded Nov 20 2008. SHarmsen. Use for inslab at long period?
c Added sdi option. Assumes coeffs. are same as the ones for shallow crustal.
c Meera R is checking on this Mar 2013.
c
c      input:  ndist, di = source distances for filling pr() array.
c      	dist = distance to slab or interface (r_cd, km)
c      	ip=period indicator in main, the global set of periods.
c      	iq = local period indicator, corresponding to per below. iq=1 is per(1)=0.0=PGA, etc.
c      	islab=0 for interface events, =1 for intraplate events. islab=-1 for crustal (not used 2007)
c      	dtor=hslab= depth (km) of slab or interface events (50 km for PacNW?)
c      	Vs30 enters in geotec common. Vs30 is a scalar applied uniformly to all sites.
c      	magmin, dmag = minimum M and delta-M for filling pr() array.
c       Calculated:
c      	ivs = Vs30 indicator, 1 for B or vs30 > 600 m/s, 2 for C, 3 for D
c      	pr() = probability of exceedance for range of R and M at specified
c      	gm levels (g) for site class that best corresponds to Vs30 
c		if sdi = .true. gm is in cm and exceedance is of spec. displ. cm
c
      parameter (nper=11,hi=20.,sqrt2=1.41421356,gfac=6.88755)
      logical deagg, sdi
      common/sdi/sdi,dy_sdi,fac_sde
      real, dimension(8) :: fac_sde
      common/geotec/V_S30,dbasin
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
      common/atten/ pr, xlev, nlev, icode, wt, wtdist
      common/deagg/deagg
      common/e0_sub/e0_sub(310,31,8,3)
      common/prob/p(25005),plim,dp2     !table of complementary normal probab.
      real pr(310,38,20,8,3,3),xlev(20,8),wt(8,10,2),wtdist(8,10) 
      integer nlev(8),icode(8,10)
      real, dimension (nper):: a,b,c,d,e,si,c1,c2,c3,qi,wi,
     + ps,qs,ws,sr,ss,ssl,sig,taui,taus,per
      real magmin,afac, dist0, dist, site, sigma, sigmasq, sigmaf
      real dy_sdi, rhat
c pst,qst, wst in eqn (5) of Zhao et al. (2006)
      real pst,qst,st,sslt,wst
      per = (/0.0,0.1,0.2,0.3,0.5,1.0,1.5,2.,3.,4.,5./)
      a=(/1.101,1.118,1.147,1.163,1.25,1.479,1.621,1.694,1.759,1.826,1.825/)
      b=(/-.00564,-.00787,-0.00659,-0.0052,-0.00338,-.0022,-.00224,-.00201,-.00147,-.00195,-.00237/)
      c=(/0.0055,.009,.012,.015,.006,.002,.002,.0025,.0032,.004,.005/)
      d=(/1.08,1.083,1.014,0.934,1.008,1.115,1.091,1.055,1.025,1.044,1.065/)
      e=(/.01412,.01423,.01462,.01458,.01114,.01005,.00928,.00833,.00644,.00590,.00510/)
      sr=(/.251,.240,.26,.259,.247,.211,.248,.263,.307,.353,.248/)
      si=(/0.,0.,0.,0.,-.053,-0.239,-.306,-.321,-.331,-.390,-.498/)
      ss=(/2.607,2.156,1.901,2.181,2.629,2.233,1.589,0.966,1.037,0.561,0.225/)
c sigt = Table 5 total sigma, from intra- and inter-event sigmas sqrt(SS) without the mag-cor term
c      sigt = (/0.723,0.849,0.811,0.77,0.76,0.775,0.787,0.776,0.751,0.745/)
      sig=(/0.604,0.694,0.692,0.67,0.653,0.657,0.664,0.669,0.667,0.647,0.643/)
c interevnt sig from table 5, intraevent tau with the mag-cor term from table 6. see comment p 910,
c col II, Zhao et al. Somerville says to use the mag-cor term, thus lower sigma_total.      
      taui=(/0.308,0.403,0.328,0.280,0.277,0.328,0.352,0.36,0.338,0.307,0.272/)
      taus=(/0.321,0.420,0.324,0.284,0.272,0.286,0.282,0.30,0.274,0.281,0.296/)
c c1 = rock site term, for NEHRP A and B, vs > 600 m/s. from Zhao table 2 p 901 bssa june 2006
c c2 = stiff soil term for NEHRP C
c c3 = soft soil term for NEHRP D
      c1=(/1.111,2.061,1.669,1.172,.071,-2.152,-3.548,-4.41,-5.431,-6.181,-6.347/)
      c2=(/1.344,2.135,2.085,1.683,0.515,-1.776,-3.169,-4.039,-5.089,-5.882,-6.051/)
      c3=(/1.355,2.031,2.001,1.808,0.934,-1.523,-2.979,-3.871,-4.893,-5.698,-5.873/)
c slab event term not used for subduction
      ssl=(/-.528,-.420,-.372,-.45,-.554,-.509,-.379,-0.248,-.263,-.169,-.120/)
c qi and wi are for the magnitude square term correction..
c qs, ws, and taus for slab event magnitude square term correction.
      ps=(/0.1392,0.1690,0.1631,0.1544,0.1381,0.106,0.0821,0.0628,0.0322,0.0083,-.0117/)
      qi =(/0.,0.,-0.0256,-0.0423,-0.0632,-0.0917,-.1083,-.1202,-.1368,-.1486,-.1578/)
      qs =(/0.1584,0.2057,0.1856,0.1573,0.1078,0.0314,-.0062,-.0235,-.0261,-.0065,0.0246/)
      wi =(/0.,0.,0.0352,0.0445,0.0562,0.0721,0.0814,0.088,0.0972,0.1038,0.109/)
      ws =(/-.0529,-.0877,0.0644,0.0395,-.0008,0.0498,0.0674,0.0692,0.0496,0.0150,-0.0268/)
c      	ivs = Vs30 indicator, 1 for C+ and B or vs30 > 600 m/s, 2 for D+ and C, 3 for D
      if(V_S30 .lt. 300.)then
      ivs=3
c linear siteamp.
        site=c3(iq)
      elseif(V_S30.lt.600.)then
      ivs=2
        site=c2(iq)
      else
      ivs=1
        site=c1(iq)
      endif
      afac=0.0
      if(islab.lt.0)then
      stop 'hazgridXnga13l: not programmed for Zhao w/crustal events'
        endif
      if(islab.eq.0)then
c interface events use si term. No others include si.
      print *, 'New hazgridXnga13l: using Zhao for interface events.'
       sigma=sqrt(sig(iq)**2+taui(iq)**2)
      wst=wi(iq)
      pst=0.0
c mag**2 correction for interface
      qst=qi(iq)
      st=si(iq)
      sslt=0.0
      xmagc=6.3
      elseif(islab.eq.1)then
c taus = tau corresponding to slab eqs. from table 6, final column.
        sigma=sqrt(sig(iq)**2+taus(iq)**2)
      pst=ps(iq)
      wst=ws(iq)
c mag**2 correction for inslab
      qst=qs(iq)
      st=ss(iq)
      sslt=ssl(iq)
      xmagc=6.5
      endif
c depth to top loop. Probably ntor=1 for intraslab NSHMP model.
          sigmasq= sigma*sqrt2
      do kk=1,ntor
         h=min(dtor(kk),125.)
      hsq=dtor(kk)**2	!slab depth effect is limited to 125 km in Zhao. hypo can
c be deeper however.
c hc=15 km is given in the final paragraph left side, pp 902 of Zhao et al 2006.
      if(h.le.15.)then
      hfac=0.
      else
      hfac=e(iq)*(h-15.)
      endif
c gnd0=initial gnd with slab depth, site term, and period-dep constant.
      gnd0 = hfac + wst +site
c mag loop
      do im=1,nmag
      xmag = magmin +(im-1)*dmag
c For Zhao as others, limit magnitude to 8.0 (see AB03 bSSA p 1703). "saturation effect" 
      xmag=min(8.0,xmag)       
c--- mag term with magnitude square term correction
      gndm= gnd0+a(iq)*xmag +pst*(xmag-xmagc) +qst*(xmag-xmagc)**2
      xmfac=c(iq)*exp(d(iq)*xmag)
      dist0=0.5
c dist loop. For consistency with Geomatrix, AB03, etc., loop on epicentral distance.
c Compute g.m. using slant distance.
      do ir=1,ndist
      dist=sqrt(hsq + dist0**2)
      afac= sslt*alog(dist)+ st
      r= dist+ xmfac
      weight= wt(ip,ia,1)
      if(dist0.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
c Possibly add afac. Gfac: always convert to gravity: cm/s/s to g
      gnd= gndm + b(iq)*dist-alog(r)+ afac -gfac
c add SDI otpion Mar 20 2013
      if(sdi)then
       sde=gnd+fac_sde(ip)	!fac_sde is log(T**2/(4pisq))
       rhat = min(10.,exp(sde)/dy_sdi)	!10 is an upper bound for rhat.
       gnd = sdi_ratio(period,xmag,rhat,sigma,sdisd) + sde
       sigmasq=sdisd*sqrt2	!use sdi for all gnd_ep branches
       endif	!sdi requested?
 
c          if(ip.gt.2)print *,gnd,weight,xmag,dist,' Zh'
      do 199 k=1,nlev(ip)
      tmp= (gnd- xlev(k,ip))/sigmasq
        if(tmp.gt.3.3)then
       ipr=25002
       elseif(tmp.gt.plim)then
       ipr= 1+nint(dp2*(tmp-plim))	!3sigma cutoff n'(mu,sig)
       else
       goto 102	!transfer out if ln(SA) above mu+3sigma
       endif
       fac=weight*p(ipr)
      if(deagg)e0_sub(ir,im,ip,kk) = e0_sub(ir,im,ip,kk) -sqrt2 * tmp*fac
 199  pr(ir,im,k,ip,kk,1)= pr(ir,im,k,ip,kk,1)+ fac !sum thru ia index
 102      continue
      dist0 = dist0+di
      enddo      !ir loop
      enddo      !im loop
      enddo      !kk (depth of slab) loop.
      sigmaf = 1./sigmasq
      return
      end subroutine zhao

      subroutine kanno(ip,iq,ia,ndist,di,nmag,magmin,dmag,sigmanf,distnf)
c....................................................................
c  Kanno et al. regression relation, 2006 for shallow earthquakes
c  written by Yuehua Zeng, USGSmods Steve Harmsen Nov 7 2006.
c
c  input: per  : period
c         amag : magnitude
c         rrup : closest fault distance
c         vsfac   : log 10 of site S-velocity in m/s
c
c  output: gnd   : ground motion spectral values (ln) (g). to be consistent
c
c          sigmaf : 1/sigma/sqrt2 errors in ln
c....................................................................
      parameter (gfac=6.8875526,sfac=2.3025851,sqrt2=1.414213562)
c conversion factors gfac cm/s/s to g, sfac log10 to ln.
      real magmin,dmag,sigmanf,distnf,di
      common/prob/p(25005),plim,dp2
      common/mech/wtss,wtrev,wtnormal
      common/dipinf_90/dipang,cosDELTA,cdipsq,cyhwfac,cbhwfac
      common/geotec/V_S30,dbasin
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
      common/atten/ pr, xlev, nlev, icode, wt, wtdist
      real pr(310,38,20,8,3,3),xlev(20,8),wt(8,10,2),wtdist(8,10) 
      integer nlev(8),icode(8,10)
      real, dimension (37) :: T,a1,b1,c1,d1,e1,pp,q
        real sigma,sigmaf,vsfac,gnd,weight
      T =(/0.05,0.06,0.07,0.08,0.09,0.10,0.11,0.12,0.13,0.15,0.17,0.20,0.22,
     +0.25,0.30,0.35,0.40,0.45,0.50,0.60,0.70,0.80,0.90,1.00,1.10,1.20,
     +1.30,1.50,1.70,2.00,2.20,2.50,3.00,3.50,4.00,4.50,5.00/)
      a1=(/0.54,0.54,0.53,0.52,0.52,0.52,0.50,0.51,0.51,0.52,0.53,0.54,0.54,
     +0.54,0.56,0.56,0.58,0.59,0.59,0.62,0.63,0.65,0.68,0.71,0.72,0.73,
     +0.74,0.77,0.79,0.80,0.82,0.84,0.86,0.90,0.92,0.94,0.92/)
      b1=(/-0.0035,-0.0037,-0.0039,-0.0040,-0.0041,-0.0041,-0.0040,-0.0040,
     +-0.0039,-0.0038,-0.0037,-0.0034,-0.0032,-0.0029,-0.0026,-0.0024,
     +-0.0021,-0.0019,-0.0016,-0.0014,-0.0012,-0.0011,-0.0009,-0.0009,
     +-0.0007,-0.0006,-0.0006,-0.0005,-0.0005,-0.0004,-0.0004,-0.0003,
     +-0.0002,-0.0003,-0.0005,-0.0007,-0.0004/)
      c1=(/0.48,0.57,0.67,0.75,0.80,0.85,0.96,0.93,0.91,0.89,0.84,0.76,0.73,
     +0.66,0.51,0.42,0.26,0.13,0.04,-0.22,-0.37,-0.54,-0.80,-1.04,-1.19,
     +-1.32,-1.44,-1.70,-1.89,-2.08,-2.24,-2.46,-2.72,-2.99,-3.21,-3.39,
     +-3.35/)
      d1=(/0.0061,0.0065,0.0066,0.0069,0.0071,0.0073,0.0061,0.0062,0.0062,
     +0.0060,0.0056,0.0053,0.0048,0.0044,0.0039,0.0036,0.0033,0.0030,
     +0.0022,0.0025,0.0022,0.0020,0.0019,0.0021,0.0018,0.0014,0.0014,
     +0.0017,0.0019,0.0020,0.0022,0.0023,0.0021,0.0032,0.0045,0.0064,
     +0.0030/)
      e1=(/0.37,0.38,0.38,0.39,0.40,0.40,0.40,0.40,0.40,0.41,0.41,0.40,0.40,
     +0.40,0.39,0.40,0.40,0.41,0.41,0.41,0.41,0.41,0.41,0.41,0.41,0.41,
     +0.41,0.40,0.39,0.39,0.38,0.38,0.38,0.37,0.38,0.38,0.38/)
      pp= (/-0.32,-0.26,-0.24,-0.26,-0.29,-0.32,-0.35,-0.39,-0.43,-0.53,-0.61,
     + -0.68,-0.72,-0.75,-0.80,-0.85,-0.87,-0.89,-0.91,-0.92,-0.96,-0.98,
     + -0.97,-0.93,-0.92,-0.91,-0.88,-0.85,-0.83,-0.78,-0.76,-0.72,-0.68,
     + -0.66,-0.62,-0.60,-0.59/)
      q= (/0.80,0.65,0.60,0.64,0.72,0.78,0.84,0.94,1.04,1.28,1.47,1.65,1.74,
     + 1.82,1.96,2.09,2.13,2.18,2.25,2.30,2.41,2.46,2.44,2.32,2.30,2.26,
     + 2.20,2.12,2.06,1.92,1.88,1.80,1.70,1.64,1.54,1.50,1.46/)
c
      vsfac=alog10(V_S30)
      weight= wt(ip,ia,1)
      do 104 kk=1,ntor
      H1=dtor(kk)
      H1sq=H1*H1
c mag loop
        do 104 m=1,nmag
        xmag0= magmin + (m-1)*dmag
        amag= xmag0
c distance loop
        do 103 ii=1,ndist
        rjb=(ii-0.5)*di
        rrup=sqrt(rjb**2+H1sq)
      if(iq.eq.0)then
c pga calculations
       gnd=0.56*amag-0.0031*rrup-alog10(rrup+0.0055*10**(0.5*amag))
     +        +0.26-0.55*vsfac+1.35
        sigma=0.37*sfac
        else
c sa calculations
       gnd=a1(iq)*amag+b1(iq)*rrup-alog10(rrup+d1(iq)*10**(0.5*amag))
     +        +c1(iq)+pp(iq)*vsfac+q(iq)
       sigma=e1(iq)*sfac
       endif
       gnd=sfac*gnd-gfac
       sigmaf=1.0/sigma/sqrt2
      do 199 k= 1,nlev(ip)
        tmp=(gnd - xlev(k,ip))*sigmaf
       if(tmp.gt.3.3)then
       ipr=25002
       elseif(tmp.gt.plim)then
       ipr= 1+nint(dp2*(tmp-plim))	!3sigma cutoff n'(mu,sig)
       else
       goto 103	!transfer out if ground motion above mu+3sigma
       endif
199        pr(ii,m,k,ip,kk,1)= pr(ii,m,k,ip,kk,1)+weight*p(ipr)      !sum thru ia index
103      continue
104      continue
      return
      end subroutine kanno

      real function basiteamp(pganl,vs30,vs30r,ip)
c inputs: pganl (g)
c      vs30: vs30 of site
c      vs30r: a reference vs30, usually one value for soil and another for rock
c      ip per index. Implies period2: spectral period (scalar)
c Output: basiteamp = log(AMP at vs30)-log(AMP at vs30r)
      parameter (np=23)	!23 periods apr 07. include 0.01 to 10 s 
      parameter (pi=3.14159265,sqrt2=1.414213562,vref=760.)
      parameter (dx=1.098612289,dxsq=1.206948961,dxcube=1.325968960,plfac=-0.510825624)
c dx = ln(a2/a1), made a param. used in a smoothed nonlin calculation sept 2006.
c plfac = ln(pga_low/0.1)      This never changes so shouldnt be calculated.
      common/ipindx/iperba(10),ipgeom(10)
      real e1nl/-0.53804/,e2nl/-0.50350/,e3nl/-0.75472/,e4nl/-0.50970/
      real e5nl/0.28805/,e6nl/-0.10164/,e7nl/0.0/
      real c1nl/-0.66050/,c2nl/0.11970/,c3nl/-0.011510/,hnl/1.35/,b1nl/0./
      real b2nl/0./,pga_low/0.06/,mhnl/6.75/,mrefnl/4.5/,rrefnl/1.0/
      real  pganl, pganlm,pganlmec,site,siter/0.0/
      real  a1/ 0.030/,a2/ 0.090/,a2fac/0.405465108/
      real, dimension(np):: per,e1,e2,e3,e4,e5,e6,e7,e8
     + ,mh,c1,c2,c3,c4,mref,rref,h,blin,b1,b2,v1,v2,
     +  sig1,sig2u,sigtu,sig2m,sigtm
c e2,e3,e4 are the mech-dependent set. e1 is a mech-unspecified value.
c Notation change from subroutine version of 12/05 and earlier.
c array constructors for f95 Linux
c from ba_02apr07_usnr.xls coef file
      per= (/-1.000, 0.000, 0.010, 0.020, 0.030, 0.050, 0.075, 0.100,
     + 0.150, 0.200, 0.250, 0.300, 0.400, 0.500, 0.750, 1.000,
     + 1.500, 2.000, 3.000, 4.000, 5.000, 7.500,10.0/)
       e1= (/ 5.00121,-0.53804,-0.52883,-0.52192,-0.45285,-0.28476,
     1  0.00767, 0.20109, 0.46128, 0.57180, 0.51884, 0.43825, 0.39220, 0.18957,-0.21338,
     1 -0.46896,-0.86271,-1.22652,-1.82979,-2.24656,-1.28408,-1.43145,-2.15446/)
       e2= (/ 5.04727,-0.50350,-0.49429,-0.48508,-0.41831,-0.25022,
     1  0.04912, 0.23102, 0.48661, 0.59253, 0.53496, 0.44516, 0.40602, 0.19878,-0.19496,
     1 -0.43443,-0.79593,-1.15514,-1.74690,-2.15906,-1.21270,-1.31632,-2.16137/)
c Editorial comment I used the e3(10s)=e3(7.5)+e2(10s)-e2(7.5s) for 10s normal, because BA
c report e3(10s) as 0.0 and this gives a large motion compared to others in nhbd.
c also reported this to Dave Boore in email for his advice. SHarmsen Oct 3 2007. Gail suggests
c that ratio for normal might equal ratio for unspecified or ratio for SS. No consensus. Using
c Gail's sugg. This choice of e3(10s), -2.66, is very low. Normal median is probably too low.
       e3= (/ 4.63188,-0.75472,-0.74551,-0.73906,-0.66722,-0.48462,
     1 -0.20578, 0.03058, 0.30185, 0.40860, 0.33880, 0.25356, 0.21398, 0.00967,-0.49176,
     1 -0.78465,-1.20902,-1.57697,-2.22584,-2.58228,-1.50904,-1.81022, -2.66/)
       e4= (/ 5.08210,-0.50970,-0.49966,-0.48895,-0.42229,-0.26092,
     1  0.02706, 0.22193, 0.49328, 0.61472, 0.57747, 0.51990, 0.46080, 0.26337,-0.10813,
     1 -0.39330,-0.88085,-1.27669,-1.91814,-2.38168,-1.41093,-1.59217,-2.14635/)
       e5= (/ 0.18322, 0.28805, 0.28897, 0.25144, 0.17976, 0.06369,
     1  0.01170, 0.04697, 0.17990, 0.52729, 0.60880, 0.64472, 0.78610, 0.76837, 0.75179,
     1  0.67880, 0.70689, 0.77989, 0.77966, 1.24961, 0.14271, 0.52407, 0.40387/)
       e6= (/-0.12736,-0.10164,-0.10019,-0.11006,-0.12858,-0.15752,
     1 -0.17051,-0.15948,-0.14539,-0.12964,-0.13843,-0.15694,-0.07843,-0.09054,-0.14053,
     1 -0.18257,-0.25950,-0.29657,-0.45384,-0.35874,-0.39006,-0.37578,-0.48492/)
       e7= (/ 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     1  0.00000, 0.00000, 0.00000, 0.00102, 0.08607, 0.10601, 0.02262, 0.00000, 0.10302,
     1  0.05393, 0.19082, 0.29888, 0.67466, 0.79508, 0.00000, 0.00000, 0.00000/)
       e8= (/ 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     1  0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     1  0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000/)
       mh= (/ 8.50000, 6.75000, 6.75000, 6.75000, 6.75000, 6.75000,
     1  6.75000, 6.75000, 6.75000, 6.75000, 6.75000, 6.75000, 6.75000, 6.75000, 6.75000,
     1  6.75000, 6.75000, 6.75000, 6.75000, 6.75000, 8.50000, 8.50000, 8.50000/)
       c1= (/-0.873700,-0.660500,-0.662200,-0.666000,-0.690100,-0.717000,
     1 -0.720500,-0.708100,-0.696100,-0.583000,-0.572600,-0.554300,-0.644300,-0.691400,-0.740800,
     1 -0.818300,-0.830300,-0.828500,-0.784400,-0.685400,-0.509600,-0.372400,-0.098240/)
       c2= (/ 0.100600, 0.119700, 0.120000, 0.122800, 0.128300, 0.131700,
     1  0.123700, 0.111700, 0.098840, 0.042730, 0.029770, 0.019550, 0.043940, 0.060800, 0.075180,
     1  0.102700, 0.097930, 0.094320, 0.072820, 0.037580,-0.023910,-0.065680,-0.138000/)
       c3= (/-0.003340,-0.011510,-0.011510,-0.011510,-0.011510,-0.011510,
     1 -0.011510,-0.011510,-0.011130,-0.009520,-0.008370,-0.007500,-0.006260,-0.005400,-0.004090,
     1 -0.003340,-0.002550,-0.002170,-0.001910,-0.001910,-0.001910,-0.001910,-0.001910/)
       c4= (/ 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     1  0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
     1  0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000/)
       mref= (/4.500,4.500,4.500,4.500,4.500,4.500,
     1 4.500,4.500,4.500,4.500,4.500,4.500,4.500,4.500,4.500,
     1 4.500,4.500,4.500,4.500,4.500,4.500,4.500,4.500/)
       rref= (/1.000,1.000,1.000,1.000,1.000,1.000,
     1 1.000,1.000,1.000,1.000,1.000,1.000,1.000,1.000,1.000,
     1 1.000,1.000,1.000,1.000,1.000,1.000,1.000,1.000/)
          h= (/2.540,1.350,1.350,1.350,1.350,1.350,
     1 1.550,1.680,1.860,1.980,2.070,2.140,2.240,2.320,2.460,
     1 2.540,2.660,2.730,2.830,2.890,2.930,3.000,3.040/)
      blin = (/-0.600,-0.360,-0.360,-0.340,-0.330,-0.290,
     1 -0.230,-0.250,-0.280,-0.310,-0.390,-0.440,-0.500,-0.600,-0.690,
     1 -0.700,-0.720,-0.730,-0.740,-0.750,-0.750,-0.692,-0.650/)
       b1= (/-0.500,-0.640,-0.640,-0.630,-0.620,-0.640,
     1 -0.640,-0.600,-0.530,-0.520,-0.520,-0.520,-0.510,-0.500,-0.470,
     1 -0.440,-0.400,-0.380,-0.340,-0.310,-0.291,-0.247,-0.215/)
       b2= (/-0.060,-0.140,-0.140,-0.120,-0.110,-0.110,
     1 -0.110,-0.130,-0.180,-0.190,-0.160,-0.140,-0.100,-0.060, 0.000,
     1  0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000/)
         v1= (/ 180., 180., 180., 180., 180., 180.,
     1  180., 180., 180., 180., 180., 180., 180., 180., 180.,
     1  180., 180., 180., 180., 180., 180., 180., 180./)
         v2= (/ 300., 300., 300., 300., 300., 300.,
     1  300., 300., 300., 300., 300., 300., 300., 300., 300.,
     1  300., 300., 300., 300., 300., 300., 300., 300./)
       sig1= (/0.500,0.502,0.502,0.502,0.507,0.516,
     1 0.513,0.520,0.518,0.523,0.527,0.546,0.541,0.555,0.571,
     1 0.573,0.566,0.580,0.566,0.583,0.601,0.626,0.645/)
      sig2u= (/0.286,0.265,0.267,0.267,0.276,0.286,
     1 0.322,0.313,0.288,0.283,0.267,0.272,0.267,0.265,0.311,
     1 0.318,0.382,0.398,0.410,0.394,0.414,0.465,0.355/)
      sigtu= (/0.576,0.566,0.569,0.569,0.578,0.589,
     1 0.606,0.608,0.592,0.596,0.592,0.608,0.603,0.615,0.649,
     1 0.654,0.684,0.702,0.700,0.702,0.730,0.781,0.735/)
      sig2m= (/0.256,0.260,0.262,0.262,0.274,0.286,
     1 0.320,0.318,0.290,0.288,0.267,0.269,0.267,0.265,0.299,
     1 0.302,0.373,0.389,0.401,0.385,0.437,0.477,0.477/)
      sigtm= (/0.560,0.564,0.566,0.566,0.576,0.589,
     1 0.606,0.608,0.594,0.596,0.592,0.608,0.603,0.615,0.645,
     1 0.647,0.679,0.700,0.695,0.698,0.744,0.787,0.801/)
c end of April 07 coeff. updates.
c----  Input vs30.  
c  ip index corresponds to period in input file (8 max). 
c--- 
c--- iq is the boore-atkinson period index for period with outer index ip
        iq = iperba(ip)
        if(v1(iq).lt.vs30.and.vs30.le.v2(iq))then
c some site term precalcs that are not M or d dependent
        bnl=(b1(iq)-b2(iq))*
     + alog(vs30/v2(iq))/alog(v1(iq)/v2(iq)) + b2(iq)
        elseif(v2(iq).lt.vs30.and.vs30.le.vref)then
        bnl=b2(iq)*alog(vs30/vref)/alog(v2(iq)/vref)
        elseif(vs30.le.v1(iq))then
        bnl=b1(iq)
        else
        bnl=0.0
        endif
        if(v1(iq).lt.vs30r.and.vs30r.le.v2(iq))then
c repeat site term precalcs that are not M or d dependent @ ref. vs.
        bnlr=(b1(iq)-b2(iq))*
     + alog(vs30r/v2(iq))/alog(v1(iq)/v2(iq)) + b2(iq)
        elseif(v2(iq).lt.vs30r.and.vs30r.le.vref)then
        bnlr=b2(iq)*alog(vs30r/vref)/alog(v2(iq)/vref)
        elseif(vs30r.le.v1(iq))then
        bnlr=b1(iq)
        else
        bnlr=0.0
        endif
c----- ADF added next line
        dy= bnl*a2fac
        dyr = bnlr * a2fac 
        site = blin(iq)*alog(vs30/vref)
        siter = blin(iq)*alog(vs30r/vref)
c Second part, nonlinear siteamp reductions below.
        if(pganl.le.a1)then
        site=site+bnl*plfac
        siter=siter+bnlr*plfac
        pgafac=0.
        elseif(pganl.le.a2)then
c extra lines smooth a kink in siteamp, pp 9-11 of boore sept report.
c c and d from p 10 of boore sept report. Smoothing introduces extra calcs
c in the range a1 < pganl < a2. Otherwise nonlin term same as in june-july.
c many of these terms are fixed and are defined in data or parameter statements
c Of course, if a1 and a2 change from their sept 06 values the parameters will
c also have to be redefined. (a1,a2) represents a siteamp smoothing range (units g)
        c=(3.*dy-bnl*dx)/dxsq
        d=(bnl*dx-2.*dy)/dxcube
        pgafac=alog(pganl/a1)
        psq=pgafac*pgafac
        site=site+bnl*plfac + (c + d*pgafac)*psq
        c=(3.*dyr-bnlr*dx)/dxsq
        d=(bnlr*dx-2.*dyr)/dxcube
        siter= siter +bnlr*plfac + (c + d*pgafac)*psq
        else
        pgafac=alog(pganl/0.1)
        site=site+bnl*pgafac
        siter=siter+bnlr*pgafac
        endif
        basiteamp = site-siter
c As of July 2009, sigma is not modified, only median (gnd), in this function.
        return
       end function basiteamp

cccccccccccccccc
      subroutine getAB06p(ip,iq,fr,ia,ndist,di,nmag,magmin,dmag)
c 13 periods incl PGV.
c added Nov 1 2012.
c Period indexes ip = counter index. iq = index associated with clamp
c fr = frequency (Hz) and code in Atkinson Lexicon 99 = pga; 89 =pgv.
c 
c 
c Table GR/A08revA_Rjb.dat assumes hardrock model .
c clamp on upper-bound ground accel is applied here. As in original hazgridX code.
        parameter (sqrt2=1.414213562, pi=3.141592654,np=13)
        logical et,deagg,sp,lceus_sigma  !sp = short period but not pga?
        common/ceus_sig/lceus_sigma,ceus_sigma
      common/geotec/vs30,dbasin
      common/deagg/deagg
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
      real magmin,dmag,gndm,gnd
             real, dimension(np):: perx(np)
           real   clamp(9)
      common/ia08/ia08
      integer, dimension(8):: ia08
      common / atten / pr, xlev, nlev, icode, wt,wtdist
c e0_ceus not saving a depth of rupture dim, not sens. to this
      common/e0_ceus/e0_ceus(310,31,8)
      real pr(310,38,20,8,3,3),xlev(20,8),wt(8,10,2),wtdist(8,10) 
      integer nlev(8),icode(8,10)
       character*32 name
           clamp = (/3.,6.,0.,6.,6.,6.,0.,6.,6./)
        name ='GR/AB06revA_Rcd.dat'
        name=trim(name)
             open(3,file=name,status='old',err=202)
        call GailTable(2)
c-- loop through magnitudes.
c Fixed sigma_aleatory all spectral periods & all M.
             sigma = 0.3*2.303
       jf=ia08(ip)
        print *,'calling GailTable GR/AB06revA_Rcd.dat fr,jf=',fr,jf
       if(lceus_sigma)sigma=ceus_sigma !for special study 3/2011
       sigmaf=1.0/sigma/sqrt2
      do 104 m=1,nmag
      xmag0= magmin + (m-1)*dmag
c  First convert mb_Lg to Mw if called on to do so.
        if(icode(ip,ia).eq.1) THEN
        xmag= 1.14 +0.24*xmag0+0.0933*xmag0*xmag0
        ELSEif(icode(ip,ia).eq.2) then
        xmag= 2.715 -0.277*xmag0+0.127*xmag0*xmag0
        else
        xmag=xmag0      !Mw coming in.
        endif
c--- loop through atten. relations for each period
c-- gnd for SS; gnd2 for thrust; gnd3 for normal
c Using Rcd metric: Do  loop over depth of rupture. dtor replaces bdepth in this subroutine.
      do 103 kk=1,ntor
      hsq=dtor(kk)**2
c      et = kk.eq.1 .and. deagg
c-- loop through distances. ii index corresponds to rjb.
      do 103 ii=1,ndist
      dist0= (ii-.5)*di 
      rjbp=max(dist0,0.11)	!a lower bound 110 meters. pretty close to the source.

      weight= wt(ip,ia,1)
      if(dist0.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
      dist= sqrt(dist0*dist0+hsq)
      rkm=dist
       gnd = amean11(xmag,rkm,rjbp,vs30,ip,jf,2)      !ka=2
c---following is for clipping gnd motions: 1.5g PGA, 3.0g  for 0.3s, 3.0g 0.2s sa median 
          if(fr.gt.90.)then
           gnd=min(0.405,gnd)
           elseif(fr.gt.2.and.fr.lt.8.)then
           gnd=min(gnd,1.099)
           endif
           test0=gnd + 3.*sigma
      test= exp(test0)
      if(clamp(iq).lt.test .and. clamp(iq).gt.0.) then
      clamp2= alog(clamp(iq))
      else
       clamp2= test0
       endif
      tempgt3= (gnd- clamp2)*sigmaf
      probgt3= (erf(tempgt3)+1.)*0.5
      do 199 k=1,nlev(ip)
      temp= (gnd- xlev(k,ip))*sigmaf
      temp1= (erf(temp)+1.)*0.5
      temp1= (temp1-probgt3)/(1.-probgt3)
      if(temp1.lt.0.) goto 103      !no more calcs once p<0
199        pr(ii,m,k,ip,kk,1)= pr(ii,m,k,ip,kk,1)+weight*temp1      !sum thru ia index
c the depth to top is relevant to this GMPE. So the kk slot may receive depth-dependent hazard.
103      continue
104      continue
      return
202      print *,name
      stop' put this file in the expected folder'
      	end subroutine getAB06p
      	
cccccccccccccccc
      subroutine getA08p(ip,iq,fr,ia,ndist,di,nmag,magmin,dmag)
c 13 periods incl PGV.
c added Oct 31 2012.
c Period indexes ip = counter index. iq = index associated with clamp
c fr = frequency (Hz) and code in Atkinson Lexicon 99 = pga; 89 =pgv.
c 
c 
c Table GR/A08revA_Rjb.dat assumes hardrock model .
c clamp on upper-bound ground accel is applied here. As in original hazgridX code.
        parameter (sqrt2=1.414213562, pi=3.141592654,np=13)
        logical et,deagg,sp,lceus_sigma  !sp = short period but not pga?
        common/ceus_sig/lceus_sigma,ceus_sigma
      common/geotec/vs30,dbasin
      common/deagg/deagg
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
      real magmin,dmag,gndm,gnd
             real, dimension(np):: perx(np)
           real   clamp(9)
      common/ia08/ia08
      integer, dimension(8):: ia08
      common / atten / pr, xlev, nlev, icode, wt,wtdist
c e0_ceus not saving a depth of rupture dim, not sens. to this
      common/e0_ceus/e0_ceus(310,31,8)
      real pr(310,38,20,8,3,3),xlev(20,8),wt(8,10,2),wtdist(8,10) 
      integer nlev(8),icode(8,10)
       character*32 name
           clamp = (/3.,6.,0.,6.,6.,6.,0.,6.,6./)
        name ='GR/A08revA_Rjb.dat'
        name=trim(name)
             open(3,file=name,status='old',err=202)
        call GailTable(1)
c-- loop through magnitudes.
c Fixed sigma_aleatory all spectral periods & all M.
             sigma = 0.3*2.303
       jf=ia08(ip)
        print *,'calling GailTable A08revA_Rjb fr,jf=',fr,jf
       if(lceus_sigma)sigma=ceus_sigma !for special study 3/2011
       sigmaf=1.0/sigma/sqrt2
      do 104 m=1,nmag
      xmag0= magmin + (m-1)*dmag
c  First convert mb_Lg to Mw if called on to do so. Two models are used (icode 1 and 2)
        if(icode(ip,ia).eq.1) THEN
        xmag= 1.14 +0.24*xmag0+0.0933*xmag0*xmag0
        ELSEif(icode(ip,ia).eq.2) then
        xmag= 2.715 -0.277*xmag0+0.127*xmag0*xmag0
        else
        xmag=xmag0      !Mw coming in.
        endif
c--- loop through atten. relations for each period
c-- gnd for SS; gnd2 for thrust; gnd3 for normal
c Using Rjb metric: Do not loop over depth of rupture. dtor replaces bdepth in this subroutine.
c      do 103 kk=1,ntor
c      hsq=dtor(kk)**2
c      et = kk.eq.1 .and. deagg
c-- loop through distances. ii index corresponds to rjb.
      do 103 ii=1,ndist
      dist0= (ii-.5)*di 
      rjbp=max(dist0,0.11)	!a lower bound 110 meters. pretty close to the source.

      rkm=rjbp
      weight= wt(ip,ia,1)
      if(dist0.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
c      dist= sqrt(dist0*dist0+hsq)
       gnd = amean11(xmag,rkm,rjbp,vs30,ip,jf,1)      !ka=1
c---following is for clipping gnd motions: 1.5g PGA, 3.0g  for 0.3s, 3.0g 0.2s sa median 
          if(fr.gt.90.)then
           gnd=min(0.405,gnd)
           elseif(fr.gt.2.and.fr.lt.8.)then
           gnd=min(gnd,1.099)
           endif
           test0=gnd + 3.*sigma
      test= exp(test0)
      if(clamp(iq).lt.test .and. clamp(iq).gt.0.) then
      clamp2= alog(clamp(iq))
      else
       clamp2= test0
       endif
      tempgt3= (gnd- clamp2)*sigmaf
      probgt3= (erf(tempgt3)+1.)*0.5
      do 199 k=1,nlev(ip)
      temp= (gnd- xlev(k,ip))*sigmaf
      temp1= (erf(temp)+1.)*0.5
      temp1= (temp1-probgt3)/(1.-probgt3)
      if(temp1.lt.0.) goto 103      !no more calcs once p<0
199        pr(ii,m,k,ip,1:ntor,1)= pr(ii,m,k,ip,1:ntor,1)+weight*temp1      !sum thru ia index
c the depth to top is immaterial to this GMPE. So the 1:ntor slots all receive the same hazard.
103      continue
104      continue
      return
202      print *,name
      stop' put this file in the expected folder'
      	end subroutine getA08p


cccccccccccccccc
      subroutine getPez11(ip,iq,fr,ia,ndist,di,nmag,magmin,dmag)
c 13 periods incl PGV.
c added Oct 31 2012.
c Period indexes ip = counter index. iq = index associated with clamp
c fr = frequency (Hz) and code in Atkinson Lexicon 99 = pga; 89 =pgv.
c ia = attenuation model # for each preiod ip.
c 
c 
c Table GR/P11A_Rcd.dat.dat assumes hardrock model .
c clamp on upper-bound ground accel is applied here. As in original hazgridX code.
        parameter (sqrt2=1.414213562, pi=3.141592654,np=13)
        logical et,deagg,sp,lceus_sigma  !sp = short period but not pga?
        common/ceus_sig/lceus_sigma,ceus_sigma
      common/geotec/vs30,dbasin
      common/deagg/deagg
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
      real magmin,dmag,gndm,gnd,test0,test
             real, dimension(np):: perx(np)
           real   clamp(9)
           real sigma,sigPez11,xmag,hsq,rjbp,rkm
      common/ia08/ia08
      integer, dimension(8):: ia08
      integer m,jf,kk,ip,ia
      common / atten / pr, xlev, nlev, icode, wt,wtdist
c e0_ceus not saving a depth of rupture dim, not sens. to this
      common/e0_ceus/e0_ceus(310,31,8)
      real pr(310,38,20,8,3,3),xlev(20,8),wt(8,10,2),wtdist(8,10) 
      integer nlev(8),icode(8,10)
       character*32 name
           clamp = (/3.,6.,0.,6.,6.,6.,0.,6.,6./)
        name ='GR/P11A_Rcd.dat'
        name=trim(name)
             open(3,file=name,status='old',err=202)
        call GailTable(3)
c-- loop through magnitudes.
c Fixed sigma_aleatory all spectral periods & all M.
       jf=ia08(ip)
        print *,'calling GailTable P11A_Rcd.dat fr,jf=',fr,jf
      do 104 m=1,nmag
      xmag0= magmin + (m-1)*dmag
c mag-dependent sigma. First convert mb_Lg to Mw if called on to do so.
        if(icode(ip,ia).eq.1) THEN
        xmag= 1.14 +0.24*xmag0+0.0933*xmag0*xmag0
        ELSEif(icode(ip,ia).eq.2) then
        xmag= 2.715 -0.277*xmag0+0.127*xmag0*xmag0
        else
        xmag=xmag0      !Mw coming in.
        endif
      sigma=sigPez11(xmag,jf)
c      print *,fr,xmag,sigma
c      if(sigma.gt.2.)stop
       sigmaf=1.0/sigma/sqrt2
c--- loop through atten. relations for each period
c-- gnd for SS; gnd2 for thrust; gnd3 for normal
c Using Rcd metric: Do loop over depth of rupture. dtor replaces bdepth in this subroutine.
      do 103 kk=1,ntor
      hsq=dtor(kk)**2
c      et = kk.eq.1 .and. deagg
c-- loop through distances. ii index corresponds to rjb.
      do 103 ii=1,ndist
      dist0= (ii-.5)*di 
      rjbp=max(dist0,0.11)	!a lower bound 110 meters. pretty close to the source.
      weight= wt(ip,ia,1)
      if(dist0.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
      dist= sqrt(dist0*dist0+hsq)
      rkm=dist
       gnd = amean11(xmag,rkm,rjbp,vs30,ip,jf,3)      !ka=3 to access Pezeshk model.
c---following is for clipping gnd motions: 1.5g PGA, 3.0g  for 0.3s, 3.0g 0.2s sa median 
          if(fr.gt.90.)then
           gnd=min(0.405,gnd)
           elseif(fr.gt.2.and.fr.lt.8.)then
           gnd=min(gnd,1.099)
           endif
           test0=gnd + 3.*sigma
      test= exp(test0)
      if(clamp(iq).lt.test .and. clamp(iq).gt.0.) then
      clamp2= alog(clamp(iq))
      else
       clamp2= test0
       endif
      tempgt3= (gnd- clamp2)*sigmaf
      probgt3= (erf(tempgt3)+1.)*0.5
      do 199 k=1,nlev(ip)
      temp= (gnd- xlev(k,ip))*sigmaf
      temp1= (erf(temp)+1.)*0.5
      temp1= (temp1-probgt3)/(1.-probgt3)
      if(temp1.lt.0.) goto 103      !no more calcs once p<0
199        pr(ii,m,k,ip,kk,1)= pr(ii,m,k,ip,kk,1)+weight*temp1      !sum thru ia index
c the depth to top is immaterial to this GMPE. So the 1:ntor slots all receive the same hazard.
103      continue
104      continue
      return
202      print *,name
      stop' put this file in the expected folder'
      	end subroutine getPez11





      subroutine GailTable(i)
c the "i" index refers to which model's table is read in. This is a mod
c from the snippet Gail sent, which only allows one model.
c moved open to main. problems passing the string not resolved.
c Currently looking at 3 possible models, AB08, AB06', or Pz11
c wrute ti unit 94.
        parameter (gfac=6.8875526,sfac=2.3025851)	!to convert to base e
      common/gail1/xmag(20,3), gma(20,30,20,3), rlog(30,3), f(20,3),itype(3)
      common/gail2/nf(3), nd(3), nm(3)
      common/ia08/ia08
      integer, dimension(8):: ia08
      logical m7
      real a,b,c
      character*80 header,fname
      if(i.gt.3)stop 'please redimension the arrays in gail1 and gail2.'
      read(3,3)header
3     format(a)
      i2=index(fname,'.dat')-13
      i3=i2+19
      read(3,*) nm(i), nd(i), nf(i), itype(i)
      write(*,9) fname, itype(i)
9     format(' GMfile, itype(0=Repi,1=Rhypo,2=Rcd,3=Rjb): ',/, a20,0p,i2)
99      format(a)
      read(3,*) (f(jf,i), jf=1,nf(i))
c
c      write(94,9)fname(i2:i3), itype(i)
c      write(94,99)'R(km)  1hzSA(g)   5hzSA(g)	  PGA(g) for hard rock'
      do 5000 jm = 1, nm(i)
        read(3,*)xmag(jm,i)
        m7=xmag(jm,i).eq.7.0
        do 4000 jd = 1, nd(i)
          read(3,*)rlog(jd,i),(gma(jf,jd,jm,i), jf = 1,nf(i))
          a=gma(4,jd,jm,i)*sfac-gfac;b=gma(7,jd,jm,i)*sfac-gfac;c=gma(12,jd,jm,i)*sfac-gfac
c          if(m7)write(94,10)10**rlog(jd,i),exp(a),exp(b),exp(c)
10      format(f7.1,1p,3(1x,e11.5))
4000    continue
5000  continue
      close(3)
      return
      end subroutine GailTable

      real function amean11(amag,r,rjb,Vs30,ip,jf,ka)
c Inputs: amag: Mw
c       r= distance (rjb or rcd, depending on ka)
c       Vs30 = top 30 m Vs. A or BC is expected.
c      ip = global period index
c      jf = frequency index
c      ka = 1,2, or 3 depending on which table to use AB06 AB08 or P11
c     Gets ground motion value (ln PSA) from table
      common/gail1/xmag(20,3), gma(20,30,20,3), rlog(30,3), f(20,3), itype(3)
      common/gail2/nf(3), nd(3), nm(3)
      common/gail3/freq(13)
      real sfac,Vs30,r,rjb,amag
      real, dimension(13) :: bcfac
      real, dimension(20) :: avg
      parameter (gfac=6.8875526,sfac=2.3025851)	!to convert to base e
c frequencies: 0.2, 0.33, 0.5, 1.0, 2.0, 3.33, 5., 10., 20., 33.0, 50., PGA, PGV
            bcfac = (/0.06, 0.08,0.09, 0.11, 0.14, 0.14, 0.12, 0.03, -0.2, -.045, -.045, -.045,0.09/)
c bcfac for pga can be a function of rjb= -0.3+.15 log(rjb) (Repi in Gail's notes)
c     
c     Use interpolation to get amean for given freq(jfreq), amag, R (hazard looping values).
c     Note that freq(jfreq) is the defined block of freq. for hazard calcs (common block)
c     GMPE tables give values(gma) for freq array f(nf), for distances rlog(nd), magnitudes xmag(nm)
c
c The frequency is already known. It is input. Don't need to search.
      jfl=jf
      rl = alog10(r)
      jdflag = 0
c     Find bounding jf values.
c     check near the edges (in case match of frequencies not exact)
      jfu = jfl + 1
      fracf = 0.
      if (jf.gt.11) go to 15
      fracf = (alog10 (freq(ip)) - alog10 (f(jfl,ka)) ) /
     *        (alog10 (f(jfu,ka)) - alog10 (f(jfl,ka)) )
c**   fracf gives interpolation fraction in frequency
15    continue
c     Find bounding jm values.
      jml = 0
c      print *,amag,rl,r,Vs30,ip,jf,ka
      do 20 j = 1, nm(ka)-1
       if (amag .ge. xmag(j,ka) .and. amag .lt. xmag(j+1,ka)) jml = j
20    continue
      if (abs(amag - xmag(nm(ka),ka)) .lt. 0.01) jml = nm(ka)
      if (jml .eq. 0) write(*,*)' ERROR. MAGNITUDE OUTSIDE RANGE.'
      jmu = jml + 1
      fracm = (amag - xmag(jml,ka)) / (xmag(jmu,ka)-xmag(jml,ka))
c**   fracm give interpolation fraction in magnitude
c     find bounding distance values.
      if (rl .lt. rlog(1,ka)) write(*,*)' ERROR. DIST. < RANGE '
        jdl = 0
      do 30 j = 1, nd(ka)-1
      if (rl .ge. rlog(j,ka) .and. rl .lt. rlog(j+1,ka)) jdl= j
30    continue
      if (rl .eq. rlog(nd(ka),ka)) jdl = nd(ka)
        if (rl .gt. rlog(nd(ka),ka)) then
c*       dist. beyond table maximum.  Attenuate ground motion by 1/R from last point in table.
         rscale= rl - rlog(nd(ka),ka)
         jdflag= 1
         jdl = nd(ka)
        endif
c        
      if (jdl .eq. 0) write(*,*)' ERROR. CANNOT FIND DIST'
      jdu = jdl + 1
      fracd = (rl - rlog(jdl,ka)) / (rlog(jdu,ka)-rlog(jdl,ka))
c**   fracd gives interpolation fraction in distanc
      do 40 j = jfl, jfu
      arl = gma(j,jdl,jml,ka) + fracm * (gma(j,jdl,jmu,ka)-gma(j,jdl,jml,ka))
      aru = gma(j,jdu,jml,ka) + fracm * (gma(j,jdu,jmu,ka)-gma(j,jdu,jml,ka))
c       arl is the amplitude for lower dist. bound, so arl>aru
      avg(j) = arl - fracd*(arl-aru)
40    continue
      amean = avg(jfl) + fracf * (avg(jfu) - avg(jfl))
      if (jdflag .eq. 1) amean = amean - rscale
c modify for BC rock. PGA BC lower than A at close-in sites according to AB11.
c PGA median is > 5hz median for A and even for BC for close-in sites.
c Current limitation : either A or BC. Nothing in between is provided for.
c Also, nothing in 2011 models is available for handing soil Vs.
      if(Vs30.lt.800.)then
      if(jf.eq.12.or.jf.eq.11)then
      amean = amean -0.3 + 0.15*rl
      else
      amean = amean + bcfac(jf)
      endif	!pga or not?
      endif	!BC rock from A?
c change to base e log to fit into standard framework. Convert to units g
      amean11 = amean*sfac -gfac
c apply the median clamp for some frequencies. Gail email, Mar 23, 2011.
      if(freq(jf).gt.2.1 .and. freq(jf) .lt.8.)then
      amean11=min(amean11,1.792)
      elseif(freq(jf).gt.90.)then
      amean11=min(amean11,0.4055)
      endif
      return
      end function  amean11

      real function sigPez11(mag,ip)
      parameter (fac=-6.95e-3,afac=2.3025851 )
      real mag	!Mw
c Input magnitude and period index, 
c Output sigma_lnY
c magnitude dependent sigma_lnY for the Pezeshk and Zandieh (BSSA,2011)
c GMPE. coeffs c12, c13,c14 from table 2 of their article
       common/ceus_sig/lceus_sigma,ceus_sigma
       logical lceus_sigma
      real, dimension(13) :: per, c12,c13,c14
      per= (/5.,3.,2.,1.,0.5,0.3,0.2,0.1,0.05,0.03,0.02,0.00,0.01/)	!s
      c12= (/-6.9e-3,-8.509e-3,-9.443e-3,-1.18e-2,-1.556e-2,-1.837e-2,-2.046e-2,-2.259e-2,
     & -2.244e-2,-2.094e-2,-1.974e-2,-2.105e-2,-1.974e-2/)
      c13= (/3.577e-1,3.54e-1,3.56e-1,3.588e-1,3.722e-1,3.867e-1,3.979e-1,4.102e-1,3.990e-1,
     & 3.817e-1,3.691e-1,3.778e-1,3.688e-1/)
      c14= (/3.58e-1,3.43e-1,3.387e-1,3.249e-1,3.119e-1,3.068e-1,3.033e-1,3.007e-1,2.905e-1,
     & 2.838e-1,2.796e-1,2.791e-1,2.792e-1/)
        if(lceus_sigma)then
        sigma=ceus_sigma      !for special studies. Use a low sigma for all GMPE periods, magnitudes, etc.
      elseif(mag.le.7.0) then
      sigPez11=c12(ip)*mag+c13(ip)
      else
      sigPez11=fac*mag+c14(ip)
      endif
c the Pezeshk article is in base10 logarithm units. we work in natural log units.
      sigPez11=sigPez11*afac
      return
      end function sigPez11
      
c the BCHydro relation to use with deep intraplate sources Nov 2012
      subroutine getNAAsub(ip,iq,ia,Fevnt,Ffaba,ndist,di,nmag,magmin,dmag,delCi)
c adapted to hazgrid by precomputing tables. SHarmsen Nov 15 2012.
c This is Abrahamson 2010 BCHydro Subduction model that was developed using the dataset of 
c acceleration response spectra of the geometrical mean 5% spectral damping. The coefficients
c  have been written for periods: pga, 0.050, 0.075,0.100, 0.150,0.200,0.250,0.300,0.400,
c 0.500, 0.600, 0.750, 1.000, 1.500, 2.000, 2.500, 3.000, 4.000, 5.000, 6.000, 7.500, 10.000.
c
c
c For values of T=0.02sec, use PGA values
c Recommended values for DelC1 is -0.5, 0.0, 0.5
c PGA1000 = Median PGA value for a Vs30 1,000 m/sec
c***************************************************************************************************
c The parameters are defined as:
c iq      -	Period index for below arrays
c ip        	Period index in global model
c ia      	Attenuation model index in global model
c Fevnt -      Indicator variable for an intraslab & interface earthquake. Intraslab = 1, interface = 0
c Ffaba -       Indicator variable for a forearc or unknown sites & backarc sites. Forearc or unknown
c      	sites = 0, backarc sites = 1.
c xmag -       Magnitdue in Mw
c R      - 	Rupture distance for interface events or hypocentral distance for intraslab events.  
c zH -        Hypocentral Distance (km)
c sigmaf -       sigmaf = 1/sigma/sqrt2
c gm  -       logged SA ground motion (units g)
c delCi =       Integer indicator for low middle hi branch, 1 2 or 3 resp.
c OUTPUT add fterm, the effect on GM of backarc site. SH Mar 1
c***************************************************************************************************
      implicit none
      real sqrt2
c wtor = weights to top of Benioff zone (km). these are applied in main, to rate matrices.
      real, dimension(22):: b,theta1, theta2, theta6, theta7, theta8, vlin
      real theta10(22), theta11(22), theta12(22), theta13(22), theta14(22)
      real theta15(22), theta16(22)
      real dtor,wtor,wtor65,delC(3), delC1,di,p,e0_sub,magmin,dmag
      real dbasin, fac, xmag, R, Rep, zH, zHp, fterm,ftermp,tmp,plim,dp2,pga0,gm0,weight
      integer ntor,Fevnt, Ffaba, delCi, c4/10/,iq,ndist,ii,im,ir
      integer ip,ia,nmag,ipr,k,kk
      logical deagg
      real c1/7.8/, c/1.88/, n/1.18/
      real theta3/0.1/, theta4/0.9/, theta5/0.0/, theta9/0.4/
      real fMag,fMagp,PGArock,gm,f0,f1
      real fDepth,  fDepthp, fSite, Vs30, VsStar, xm10
      real Rmax
      real sigma/0.772/,sigmaf
      real pr(310,38,20,8,3,3),xlev(20,8),wt(8,10,2),wtdist(8,10) 
      integer nlev(8),icode(8,10)
c lines from hazgrid. table production
       common/prob/p(25005),plim,dp2   !table of complementary normal probab
      common / atten / pr, xlev, nlev, icode, wt, wtdist
      common/e0_sub/e0_sub(310,31,8,3)
      common/deagg/deagg
      parameter (sqrt2=1.414213562)
      common/geotec/vs30,dbasin
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
      
      vlin = (/865.1,1053.5,1085.7,1032.5,877.6,748.2,654.3,587.1,503.0,456.6,430.3,410.5,400.0,
     1            400.0, 400.0, 400.0, 400.0, 400.00, 400.0, 400.0, 400.0, 400.0/)
        b = (/-1.186, -1.346, -1.471,-1.624, -1.931,-2.188, -2.381, -2.518, -2.657, -2.669,
     1       -2.599, -2.401, -1.955, -1.025, -0.299, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000/)
        theta1  = (/4.2203, 4.5371, 5.0733, 5.2892, 5.4563,5.2684, 5.0594, 4.7945, 4.4644, 4.0181, 
     1                 3.6055, 3.2174, 2.7981, 2.0123,1.4128, 0.9976, 0.6443, 0.0657, -0.4624, -0.9809,
     2                 -1.6017, -2.2937/)
        theta2  = (/-1.350, -1.400, -1.450, -1.450, -1.450, -1.400, -1.350, -1.280, -1.180, -1.080, 
     1                 -0.990, -0.910, -0.850, -0.770, -0.710, -0.670, -0.640, -0.580, -0.540, -0.500,
     2                  -0.460, -0.400/)
        theta6  = (/-0.0012, -0.0012, -0.0012, -0.0012, -0.0014, -0.0018, -0.0023, -0.0027,
     1                 -0.0035, -0.0044, -0.0050, -0.0058, -0.0062, -0.0064 , -0.0064, -0.0064,
     2                 -0.0064, -0.0064, -0.0064, -0.0064 , -0.0064, -0.0064/)
        theta7  = (/1.0988, 1.2536, 1.4175, 1.3997, 1.3582, 1.1648, 0.9940, 0.8821, 0.7046,
     1                 0.5799, 0.5021, 0.3687, 0.1746, -0.0820, -0.2821, -0.4108, -0.4466, -0.4344,
     2               -0.4368, -0.4586, -0.4433, -0.4828/)
        theta8  = (/-1.42, -1.65, -1.80, -1.80, -1.69, -1.49, -1.30, -1.18, -0.98, -0.82, -0.70, 
     1                 -0.54, -0.34, -0.05, 0.12, 0.25, 0.30, 0.30, 0.30, 0.30, 0.30, 0.30/)
        theta10 = (/3.12,3.37,3.37,3.33, 3.25, 3.03, 2.80, 2.59, 2.20, 1.92, 1.70, 1.42, 1.10, 
     1                  0.70, 0.70, 0.70, 0.70, 0.70, 0.70,0.70, 0.70, 0.70/)
        theta11 = (/0.0130, 0.0130,0.0130,0.0130,0.0130,0.0129,0.0129,0.0128,0.0127,0.0125,
     1                    0.0124,0.0120,0.0114,0.0100,0.0085,0.0069,0.0054, 0.0027,0.0005, -0.0013,
     2                   -0.0033, -0.0060/)
        theta12 = (/0.980, 1.288, 1.483, 1.613, 1.882, 2.076, 2.248, 2.348, 2.427, 2.399, 2.273,
     1                   1.993, 1.470, 0.408, -0.401, -0.723, -0.673, -0.627, -0.596, -0.566,
     2                    -0.528, -0.504/)
        theta13 = (/-0.0135, -0.0138,-0.0142,-0.0145,-0.0153,-0.0162,-0.0172, -0.0183,-0.0206,
     1                   -0.0231, -0.0256, -0.0296, -0.0363, -0.0493, -0.0610, -0.0711, -0.0798, 
     2                   -0.0935, -0.0980 , -0.0980, -0.0980, -0.0980/) 
        theta14 = (/-0.40,-0.40,-0.40,-0.40,-0.40,-0.35,-0.31, -0.28, -0.23, -0.19, -0.16, -0.12,
     1                   -0.07, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00/)
        theta15 = (/0.9996, 1.1030, 1.2732, 1.3042, 1.2600, 1.2230, 1.1600, 1.0500, 0.800,
     1                    0.6620, 0.5800, 0.4800, 0.3300, 0.3100, 0.300 , 0.300, 0.300, 0.300, 0.300,
     2                    0.300, 0.300, 0.300/)
        theta16 = (/-1.00, -1.18, -1.36, -1.36, -1.30, -1.25, -1.17, -1.06, -0.78, -0.62, -0.50,
     1                  -0.34, -0.14, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00/) 
        delC = (/-0.5, 0.0,0.5/)
     
C      Define DelC1
      if(delCi.le.3.and.delCi.gt.0) then
      	delC1 = delC(delCi)
      else 
      	print *, 'Error in delC1'
      	stop 'please call repairman'
      endif
      if(Fevnt > 1.or.Fevnt < 0) then 
      	print *,'Error in Fevnt term'
      	stop 'please call repairman'
      endif	
C sigma has no dependencies, goes outside of all loops.      	
       sigmaf = 1./sigma/sqrt2
c Outer loop: magnitudes to consider
C      Calculate Magnitude Scaling Factor fMag(M)
      xmag=magmin
      if(Ffaba .gt. 1 .or. Ffaba .lt. 0) then 
      	print *,fFaba
      	print *,'Error in Ffaba term'
      endif
c     compute VsStar (outside all loops)
      if(Vs30.gt.1000.) then
      	VsStar = 1000.
      else
      	VsStar = Vs30
      endif
      f0= theta12(iq)*alog(VsStar/vlin(iq))
      f1= b(iq)*n*alog(VsStar/vlin(iq))
c prelim calcs outside loops
      pga0=theta1(1)+theta4*delC1+theta10(1)*Fevnt
      gm0=theta1(iq)+theta4*delC1+theta10(iq)*Fevnt
      do im=1,nmag
c      write(2, 22)xmag,vs30
c22      format(/,'#Magnitude: ',f6.2,1x,'Distance SA(g) for vs30 ',f6.1)
          xm10=(10-xmag)**2
      if(xmag.le.c1+delC1) then 
      	fMag = theta4*(xmag-(c1+delC1))+theta13(iq)*xm10
      	fMagp = theta4*(xmag-(c1+delC1))+theta13(1)*xm10
      else !its greater
      	fMag = theta5*(xmag-(c1+delC1))+theta13(iq)*xm10
      	fMagp = theta5*(xmag-(c1+delC1))+theta13(1)*xm10
      endif	
C
c 2nd loop depth to top of rupture (from common block)      
      do kk=1,ntor
      zH=dtor(kk)
C       Calculate Depth Scaling Factor fDepth(zH)
      zHp=min(zH,125.)	!limiting value for Depth Scaling Factor term add May 2012 SH
      	fDepth = theta11(iq)*(zHp-60.)*Fevnt
      	fDepthp = theta11(1)*(zHp-60.)*Fevnt

c third loop: epicentral distance
      Rep=di/2.	!starting location close.
      	do ii=1,ndist
      	R = sqrt(Rep**2+zH**2)	!dist to top of rupture (km). Like Rcd.
      weight= wt(ip,ia,1)
      if(Rep.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
C
C      Calculate Forearc/Backarc Scaling fFaba
      if(Fevnt.eq.1 .and. Ffaba.eq.1) then ! its a backarc site loc and intraplate src.
      	Rmax = max(R, 85.0)
      	fterm = (theta7(iq)+theta8(iq)*alog(Rmax/40))	!*Ffaba
      	ftermp= theta7(1)+theta8(1)*alog(Rmax/40.)
      elseif (Ffaba.eq.1)then !its a backarc  and interface src . 
      	Rmax = max(R, 100.0)
      	ftermp = theta15(1)+theta16(1)*alog(Rmax/40.)	!*Ffaba
      	fterm = (theta15(iq)+theta16(iq)*alog(Rmax/40))	!*Ffaba
      else	!forearc site or the site is unknown. No effect.
      	fterm=0.0
      	ftermp=0.0
      endif
C
C      Calculate Site Scaling Factor	fSite
C
C Calculate PGArock
      if(Vs30.lt.Vlin(iq))then
c PGArock is like gm below except there is no site term. This was not in
c original code. I believe it is correct. BCHydro document says PGArock is
c the median PGA for Vs30 = 1000 m/s. 
      PGArock = pga0 + (theta2(1)+theta14(1)*Fevnt+theta3*(xmag-7.8))*
     1      alog(R+c4*exp((xmag-6)*theta9))+theta6(1)*R+fMagp+
     2       fDepthp +ftermp 
        PGArock=exp(pgaRock)      !units g
c ! non-linear site response
       fSite = f0 - b(iq)*alog(PGArock+c)+b(iq)*alog(PGArock+c*(VsStar/vlin(iq))**n)
      else
      fSite = f0 + f1
       endif		!nonlinear siteamp?
C      
C

C Calulate ground motion of Base Function
      gm = gm0 +(theta2(iq)+theta14(iq)*Fevnt+theta3*(xmag-7.8))*
     1      alog(R+c4*exp((xmag-6)*theta9))+theta6(iq)*R+fMag+fDepth+
     2       fterm +fSite
c      write(2,23)R,exp(gm)
c23      format(f8.1,1x,e10.5)
c      goto 102      !skip this innermost loop for initial tests.
      do 199 k=1,nlev(ip)
      tmp= (gm- xlev(k,ip))*sigmaf
        if(tmp.gt.3.3)then
       ipr=25002
       elseif(tmp.gt.plim)then
       ipr= 1+nint(dp2*(tmp-plim))	!3sigma cutoff n'(mu,sig)
       else
       goto 102	!transfer out if ln(SA) above mu+3sigma
       endif
       fac=weight*p(ipr)
      if(deagg)e0_sub(ii,im,ip,kk) = e0_sub(ii,im,ip,kk) -sqrt2 * tmp*fac
 199  pr(ii,im,k,ip,kk,1)= pr(ii,im,k,ip,kk,1)+ fac !sum thru ia index
  102 continue
        Rep = Rep + di		!increase distance
      enddo	!ii loop
      enddo	!kk loop
      xmag = xmag+dmag	!increase magnitude
      enddo	!im loop (mag)      
 	print *,(kk,pr(1,5,10,ip,kk,1),kk=1,ntor), '(1,5,10,ip,kk,1)'
       return
       end subroutine getNAAsub

c------------------------------------------------------------------------------
      SUBROUTINE CB12_NGA_SPEC_IN
c read in the coeffs only. Harmsen Nov 30. Out of service. Feb 2013.
C     This subr. read coeff for 5%-damped linear elastic response spectra from the 
C     2012 Campbell-Bozorgnia NGA-West2 Ground Motion Prediction Equation (GMPE)
C
C     It is Based on Campbell-Bozorgnia NGA-West2 Draft Model, November 12, 2012, Rev111
C
C     Written by Yousef Bozorgnia (November 25, 2012)

      parameter (nper=22)
      common/geotec/vs30,dbasin
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
c wtor = weights to top of Benioff zone (km). these are applied in main, to rate matrices.
      common /cb12/Phi,Tau,c0,c1,c2low,c2,c3,c4,c5,c6,c7,c8,c9,c10,c10j,c10jlow,c11,c11j,
     + c12,c13low,c13hi,c14,c15,k1,k2,k3,a2,h1,h2,h3,h4,h5,h6,phi_lny,tau_lny,phi_lnAF,rho
       common/cb12p/Per
      REAL  Phi(nper), Tau(nper) 
      REAL Per(nper), c0(nper), c1(nper), c2low(nper), c2(nper)
      REAL c3(nper), c4(nper)
      REAL c5(nper), c6(nper), c7(nper), c8(nper), c9(nper)
      REAL c10(nper), c10J(nper), c10Jlow(nper) 
      REAL c11(nper), c11J(nper) 
      REAL c12(nper), c13low(nper),c13hi(nper) 
      REAL c14(nper)
      REAL c15(nper)
      REAL k1(nper), k2(nper), k3(nper)
      REAL a2(nper),h1(nper),h2(nper),h3(nper)
      REAL h4(nper),h5(nper),h6(nper)
      REAL phi_lny(nper), tau_lny(nper) 
      REAL phi_lnAF(nper), rho(nper)
      character*1 dum1
   
C.....
C.....READ MODEL COEFFICIENTS FROM AN EXCEL FILE (CSV FORMAT)
C.....
c      if(icase.ne.1) go to 21 
      call get_lun(m)
c _r2 mid december 2012.
        open (m,file='GR/CB12_NGA_COEFFS_Atten111_r2.txt',status='old',err=2012)
      print *,'CB coefficient file GR/CB12_NGA_COEFFS_Atten111_r2.txt opened OK, unit ',m
      read (m,1) dum1
 1    format(a1)

      do 20 iper=1,nper
        read (m,*)Per(iper),c0(iper), c1(iper),c2low(iper),c2(iper),c3(iper),c4(iper),
     +c5(iper),c6(iper),c7(iper),c8(iper),c9(iper),c10(iper),c10Jlow(iper),c10J(iper),
     +c11(iper),c11J(iper),c12(iper),c13low(iper),c13hi(iper),c14(iper),c15(iper),a2(iper), 
     +h1(iper),h2(iper),h3(iper),h4(iper),h5(iper),h6(iper),k1(iper), k2(iper), k3(iper),
     +phi_lny(iper), tau_lny(iper), phi_lnAF(iper), rho(iper)
c      print *,'period ',Per(iper)
c      print *,c14(iper),c15(iper),phi_lnAF(iper), rho(iper),'c14(iper),c15(iper),phi_lnAF(iper), rho(iper)'
 20   CONTINUE
       close(m)
       return
2012      print *,'CB coeff file not found ; put in GR/ folder'
      stop
       end SUBROUTINE CB12_NGA_SPEC_IN
       
      SUBROUTINE CB13_NGA_SPEC  (ip,iper,ia,ndist,di,nmag,magmin,dmag,DIP,SJ,rxsign)
c     +(Mw,Rrup,Rjb,Rx, Frv,Fnm,Ztor,Hhyp,W,Dip,Vs30,Z25,SJ, 
c     &Per,Y,Phi,Tau,Sigmatot,icase)
c Modified May 13 2013 to include an anelastic atten for R>80. Bozorgnia email of May 2013
c call this subroutine after calling CB13_NGA_SPEC_IN
c mods by  Harmsen Feb 25 2013 This is the Feb 2013 update. Includes PGV (index 23).
c call this with PGA as first period to run for a given source. This is needed to get the A1100 term
c used with other periods. SH. Mod of Bozorgnia code which performs internal loop on period.
C.....Input parameters (from file CB12_NGA_infile.txt)
c      iper = local period index
c      ip   = calling pgm pd index, 1 for pga because pga must be called first.
c      nmag = nmber of mags to prepare table for
c      ndist = nmber of distances
c      magmin = minimum magnitude in the table
C     Frv    = 1 for Reverse-faulting, 0 otherwise (communicated via mech common )
C     Fnm    = 1 for Normal-faulting, 0 otherwise
C     Ztor   = Depth to top of coseismic rupture (km)
C     Hhyp   = Hypocentral depth (km)
C     W      = Fault width (km)
C     Dip    = Dip of fault rupture plane (degrees)
C     Vs30   = Average velocity in top 30-m (m/s)
C     Z25    = Depth to 2.5 km/s velocity horizon (km)
C     SJ     = 1 for sites in Japan; =0 otherwise
C     iSpec  = 0 for generating Sa(g) [Not at this point: 1 for Sv(cm/s); 2 for Sd(cm)]
c      DIP = dip (d) of virtual faulting. 90 d?
c       rxsign = 1 for hanginwall side; =-1 for sites on footwall side (all sites on same side per call)
c output
      parameter (nper=23,d2r=0.0174533,sqrt2=1.4142136)
       real, dimension(3) ::gnd
       real, dimension(0:9) :: rxfac
c lines from hazgrid. table production
      common/epistemic/nfi,e_wind,gnd_ep,mcut,dcut
       real gnd_ep(3,3,8),mcut(2),dcut(2),gndout(3),gndx
       logical, dimension (8):: e_wind
c add SDI-related common block sdi feb 22 2013
       common/sdi/sdi,dy_sdi,fac_sde
       real, dimension(8) :: fac_sde
      common/mech/wtss,Frv,Fnm
       common/prob/p(25005),plim,dp2   !table of complementary normal probab
      common / atten / pr, xlev, nlev, icode, wt, wtdist
      common /cb13/Phi,Tau,c0,c1,c2low,c2,c3,c4,c5,c6,c7,c8,c9,c10,c10j,c10jlow,c11,c11j,
     + c12,c13low,c13hi,c14,c15,k1,k2,k3,a2,h1,h2,h3,h4,h5,h6,phi_lny,phi_low, phi_hi,
     + tau_lny,tau_lnyB,tau_low,tau_hi,phi_lnAF,rho
       common/cb13p/Per
      REAL, dimension(nper) ::  Phi, Tau, tau_low,tau_hi,c15ca,c15j,c15_China
      REAL, dimension(nper) ::  Per, c0, c1, c2low, c2, c3, c4,c5, c6, c7, c8, c9,c10, c10J, c10Jlow, c11, c11J 
      REAL, dimension(nper) :: c12, c13low,c13hi, c14,c15,k1, k2, k3,a2,h1,h2,h3
      REAL, dimension(nper) :: h4,h5,h6, phi_low, phi_hi,phi_lny,tau_lny,tau_lnyB,phi_lnAF, rho
c lines from hazgrid. table production
      common/fix_sigma/fix_sigma,sigma_fx
      LOGICAL fix_sigma,sdi
      common/geotec/Vs30,Z25
      common/depth_rup/ntor,dtor(3),wtor(3),wtor65(3)
      common/deagg/deagg
      real pr(310,38,20,8,3,3),xlev(20,8),wt(8,10,2),wtdist(8,10) 
      integer nlev(8),icode(8,10)
       real Mw,A1100(310,31,3),csoil,nsoil,Sigmatot,di,magmin,dmag,sigma_fx,phi_lnPGAB
       save A1100
c T=.01,.02,.03,.05,.075,.1,.15,.2,.25,.3,0.4,0.5,.75,1,1.5,2,3,4,5,7.5,10,0,-1
	c15ca=(/-0.0055,-0.0055,-0.0057,-0.0063,-0.007,-0.0073,-0.0069,-0.006,-0.0055,-0.0049,-0.0037,-0.0027,-0.0016,-0.0006,
     + 0.0,0.0,0.0,0.0,0.0,0.0,0.0,-0.0055,-0.0017/)
	c15j=(/-0.009,-0.009,-0.0091,-0.01,-0.0107,-0.0107,-0.0099,-0.0091,-0.0088,-0.0084,-0.0071,-0.0061,-0.0048,-0.0036,
     + -0.0019,-0.0005,0.0,0.0,0.0,0.0,0.0,-0.009,-0.0023/)
	c15_China=(/-0.0019,-0.0019,-0.002,-0.0023,-0.0031,00.0031,-0.0027,-0.0019,-0.0019,-0.0018,-0.0009,-0.0002,0.0,
     +  0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,-0.0019,0.0/)
       rxfac=(/0.,0.5,1.,2.,3.,4.,4.5,5.,5.5,6./)
c-----Soil model constants. Do not switch these to vectors until they change with T
       nsoil = 1.18
      csoil = 1.88
c site term for hard rock. indep. of all loop variables.
         F_site_1100 = (c10(22) + k2(22)*nsoil)*alog(1100.0/k1(22))
	if(SJ.lt.1.0)then
	c15=c15ca	!use california Qmodel when SJ<1
	elseif(SJ.lt.2.)then
	c15=c15j
	else
	c15=c15_China
	endif
        if(iper.eq.1)iper=22    
c effects that are independent of depth, of M, and of R or distance.
C*****Style-of-fauting term
      f_flt_F = c7(iper)*Frv + c8(iper)*Fnm
C.....f_HW_dip
      f_HW_dip= (90.0 - DIP)/45.0
      sinedip=sin(DIP*d2r)
      cosdip = cos(DIP*d2r)
        wmax = 14./sinedip	!maximum seismogenic width.
C*****Shallow sediment depth and 3-D basin term
      IF (Z25 .LT. 1.0) THEN
        F_sed = (c11(iper) + c11J(iper)*SJ)*(Z25 - 1.0)
      ELSEIF (Z25 .LE. 3.0) THEN
        F_sed = 0.0
      ELSE
        F_sed = c12(iper)*k3(iper)*(EXP(-0.75))*
     +(1.0 - EXP(-0.25*(Z25 - 3.0)))
      ENDIF


      do kk=1,ntor
      Mw=magmin
      Ztor=dtor(kk)
C.....f_HW_Z
      IF(Ztor.le.16.66) THEN
        f_HW_Z=1.0-0.06* Ztor
      ELSE
        f_HW_Z=0.0
      ENDIF

      do jj=1,nmag
C*****Magnitude term
c base area on w&c formula for all sources. Update to Stirling Wesnouski 2013?
        area =  10**((Mw-4.07)/0.98)
        W=sqrt(area/1.5)        !aspect ratio 1.5
        W= min (W,wmax)
      Hhyp = min(15.,Ztor +0.50*W*sinedip)	!virtual hypocentrs 1/2 of the way down dip.
       if(e_wind(ip))then
          if (Mw.lt.mcut(1))then
          ime=1
          elseif(Mw.lt.mcut(2))then
          ime=2
          else
          ime=3
          endif
        endif !extra epistemic
C*****Hypo depth term
      IF(Hhyp.le.7.0) THEN
        f_Hhyp_H=0.
      ELSEIF (Hhyp.le.20.0) THEN
        f_Hhyp_H= Hhyp-7.0
      ELSE
        f_Hhyp_H=13.0
      ENDIF
      IF (Mw .LE. 4.5) THEN
        F_mag = c0(iper) + c1(iper)*Mw
      ELSEIF (Mw .LE. 5.5) THEN
        F_mag = c0(iper) + c1(iper)*Mw + c2low(iper)*(Mw-4.5)
      ELSEIF (Mw .LE. 6.5) THEN
        F_mag = c0(iper) + c1(iper)*Mw + c2low(iper)*(Mw-4.5) + 
     &c2(iper)*(Mw-5.5)
      ELSE
        F_mag = c0(iper) + c1(iper)*Mw + c2low(iper)*(Mw-4.5) + 
     &c2(iper)*(Mw-5.5) + c3(iper)*(Mw-6.5)
      ENDIF
c magnitude dependent faulting term...
C.....Note: Magnitude limits and equation have been changed
      IF (Mw.LE.4.5) THEN
        f_flt_M=0.
      ELSEIF (Mw.LE.5.5) THEN
        f_flt_M= Mw-4.5 
      ELSE
        f_flt_M= 1.
      ENDIF

      F_flt= f_flt_F * f_flt_M

C.....f_HW_M
C.....Note: Equation for f_HW_M has been changed
      IF (Mw.le.5.5) THEN
        f_HW_M=0.
      ELSEIF (Mw.le.6.5) THEN 
        f_HW_M= (Mw-5.5)*(1+a2(iper)*(Mw-6.5))
      ELSE
        f_HW_M= 1. + a2(iper)*(Mw-6.5)
      ENDIF
C*****Dip term
C.....Dip term has been changed
      IF (Mw.le.4.5) THEN
        F_Dip= c14(iper)* DIP
      ELSEIF (Mw.le.5.5) THEN 
        F_Dip= c14(iper)* (5.5 - Mw)* Dip
      ELSE
        F_Dip= 0.
      ENDIF

      IF (Mw.le.5.5) THEN
        F_Hhyp= c13low(iper) * f_Hhyp_H
      ELSEIF (Mw.le.6.5) THEN        
        F_Hhyp= (c13low(iper)+ (c13hi(iper) - c13low(iper))*(Mw-5.5))* 
     &           f_Hhyp_H
      ELSE
        F_Hhyp= c13hi(iper) * f_Hhyp_H
      ENDIF
      
c R1, R2 used with hanging wall effects
        R1= W * cosdip
        R2= 62.*Mw - 350.
        F_atn=0.0	!initialize anelastic attn at zero. Kicks in at 80 km
      if(abs(Mw-6.05).lt.0.02)write(12,122)Mw,Ztor,iper,F_Dip
122      format(/,'#Rrup GM  sigma_lnY f_HW for Mw,Ztor,iper,Fdip ',f6.2,1x,f6.1,1x,i2,1x,e11.5)
        do ii=1,ndist
        rjb=di*0.5+float(ii-1)*di
       weight= wt(ip,ia,1)
       if(rjb.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
      if(e_wind(ip))then
          if(rjb.lt.dcut(1))then
          ide=1
          elseif(rjb.lt.dcut(2))then
          ide=2
          else
          ide=3
          endif
          gndx=gnd_ep(ide,ime,ip)
          endif
        Rrup = sqrt(rjb**2+dtor(kk)**2)
        Rx = rxsign*(rjb+rxfac(icode(ip,ia)))
C*****Distance term
      R = SQRT(Rrup**2 + c6(iper)**2)
      F_dis = (c4(iper) + c5(iper)*Mw)*LOG(R)

C*****Hanging-wall term Skip this for first goaround. SH 12/2012 (skipping assumes vertical dip)
C     Jennifer Donahue's HW Model plus CB08 distance taper 
      f1_Rx= h1(iper) + h2(iper)*(Rx/R1) + h3(iper)*((Rx/R1)**2)
      f2_Rx= h4(iper) + h5(iper)*((Rx-R1)/(R2-R1)) + 
     +       h6(iper)*((Rx-R1)/(R2-R1))**2

C.... CB08 distance taper modified to v3 Dec 3, 2012.
       IF (Rrup.eq.0.0) THEN
         f_HW_Rrup= 1.0
       ELSE 
         f_HW_Rrup= (Rrup - Rjb)/Rrup
       ENDIF
C
C.....f_HW_R note: Rx is either positive or negative in the above. To randomize
c this effect user should run both cases and treat as logic tree branches SH Dec 27 2012.
      IF (Rx.lt.0.0) THEN
        f_HW_R= 0.0
      ELSEIF (Rx.lt.R1) THEN
        f_HW_R= f1_Rx * f_HW_Rrup
      ELSE
        f_HW_R= (max(f2_Rx, 0.0))* f_HW_Rrup
      ENDIF
      F_HW= c9(iper)* f_HW_R * f_HW_M * f_HW_Z * f_HW_Dip
C*****Anelastic attenuation term: modified May 13 2013 SH.
      if(Rrup.gt.80.)F_atn=c15(iper)*(Rrup-80.)

C*****For the first period (loop), computer A1100 *****************************
      IF (ip.eq.1)THEN
C........Shallow site conditions term for ROCK PGA (i.e., Vs30 = 1100 m/s)
C........Rock PGA
c	if(kk.eq.1.and.jj.ge.10)print *,F_atn,Mw
         A1100(ii,jj,kk) = EXP(F_mag + F_dis + F_flt + F_HW + 
     +               F_site_1100 + F_sed + F_Hhyp + F_Dip + F_atn)
      ENDIF

C*****Site term for other iper values 
       IF (Vs30 .LE. k1(iper)) THEN
          F_site = c10(iper)*LOG(Vs30/k1(iper))
     &             + k2(iper)*(LOG(A1100(ii,jj,kk)+csoil*((Vs30/k1(iper))**nsoil)) 
     &             - LOG(A1100(ii,jj,kk) + csoil))
       ELSE
          F_site = (c10(iper) + k2(iper)*nsoil)*LOG(Vs30/k1(iper))
       ENDIF


c******************************************************************************

c*****Ground motion parameter (log space)(units g)

      gm = F_mag + F_dis + F_flt + F_HW  + F_sed + F_Hhyp + F_Dip + F_atn
c PGA was not stored. Get the required effect from A1100
      if(Per(iper).gt.0.0 .and.Per(iper).le. 0.25)then
      if(exp(gm).lt.A1100(ii,jj,kk))print *,exp(gm),A1100(ii,jj,kk),Per(iper),Rrup
c SA, before siteamp, must be greater than PGA(Rock 1100). From Boz. email May 2013
      gm = max(gm,alog(A1100(ii,jj,kk)))
      endif
      gm = gm + F_site
C.....
C.....CALCULATE ALEATORY UNCERTAINTY

      IF (Vs30 .LT. k1(iper)) THEN
        alpha = 
     +    k2(iper)*A1100(ii,jj,kk)*(1.0/(A1100 (ii,jj,kk)+ csoil*(Vs30/k1(iper))**nsoil) 
     +    -1.0/(A1100(ii,jj,kk) + csoil))
      ELSE
        alpha = 0.0
      ENDIF
      if(fix_sigma)then
      sigmaf=1./sqrt2/sigma_fx
      else
c computation of std. deviation changed Feb 2013.
      If (Mw.le.4.5) then
         tau_lnyB(iper) =tau_low(iper)
      elseif (Mw.lt.5.5) then
         tau_lnyB(iper) =tau_hi(iper) + 
     &    (tau_low(iper) - tau_hi(iper))*(5.5-Mw)
      else
         tau_lnyB(iper) =tau_hi(iper) 
      endif

      tau_lnPGAB = tau_lnyB(22) 

      tau(iper) = SQRT(tau_lnyB(iper)**2 +  
     &           (alpha * tau_lnPGAB)**2 +
     &           2.0*alpha*rho(iper)*tau_lnyB(iper)*tau_lnPGAB)

      If (Mw.le.4.5) then
         phi_lny(iper) =phi_low(iper)
      elseif (Mw.lt.5.5) then
         phi_lny(iper) =phi_hi(iper) + 
     &    (phi_low(iper) - phi_hi(iper))*(5.5-Mw)
      else
         phi_lny(iper) =phi_hi(iper) 
      endif

      phi_lnyB = SQRT(phi_lny(iper)**2 - phi_lnAF(iper)**2)

      phi_lnPGAB = SQRT(phi_lny(22)**2 - phi_lnAF(22)**2)

      phi(iper) = SQRT(phi_lny(iper)**2 + 
     &           (alpha*phi_lnPGAB)**2 +
     &           2.0*alpha*rho(iper)*phi_lnyB*phi_lnPGAB)
        Sigmatot = SQRT(phi(iper)**2 + Tau(iper)**2)
      
c      if(abs(Mw-6.05).lt.0.02)write(12,*)rrup,exp(gm),sigmatot,F_HW
      sigmaf=1./sqrt2/Sigmatot
      endif	!user specified sigma or CB model?
      gndout(1)=gm
      if(sdi)then
       sde=gndout(1)+fac_sde(ip)      !fac_sde is log(T**2/(4pisq))
       rhat = min(10.,exp(sde)/dy_sdi)      !10 is an upper bound for rhat.
       gndout(1) = sdi_ratio(per(iper),Mw,rhat,Sigmatot,sdisd) + sde
       sigmaf=1./sdisd/sqrt2      !use sdi for all gnd_ep branches
       endif      !sdi requested?
      
      if(e_wind(ip)) then
      gndout(2)=gndout(1)+gndx
      gndout(3)=gndout(1)-gndx
      endif
      do ie=1,nfi
      do 199 k=1,nlev(ip)
      tmp= (gndout(ie)- xlev(k,ip))*sigmaf
        if(tmp.gt.3.3)then
       ipr=25002
       elseif(tmp.gt.plim)then
       ipr= 1+nint(dp2*(tmp-plim))	!3sigma cutoff n'(mu,sig)
       else
       goto 102	!transfer out if ln(SA) above mu+3sigma
       endif
       fac=weight*p(ipr)
 199  pr(ii,jj,k,ip,kk,ie)= pr(ii,jj,k,ip,kk,ie)+ fac !sum thru ia index
  102 continue
      enddo	!ie loop
      enddo	!distance loop
      Mw=Mw+dmag
      enddo	!mag loop
      enddo	!depth of top of rupture loop
      
      RETURN
      END SUBROUTINE CB13_NGA_SPEC
c------------------------------------------------------------------------------

      subroutine get_lun(lun)

* Finds a logical unit number not in use; returns
* -1 if it cannot find one.

* Dates -- 05/19/98 - Written by D. Boore, following
*                     Larry Baker's suggestion

      logical isopen
      do i = 99,10,-1
        inquire (unit=i, opened=isopen)
        if(.not.isopen) then
          lun = i
          return
        end if
      end do
      lun = -1

      return
      end subroutine get_lun

      subroutine AS2013_v10_model  (ip,iper,ia,ndist,di,nmag,magmin,dmag,DIP,z10,useRy0,vs30,hardrock,rxsign)
c Original arguments:
c      (iper, mag, dip, FltWidth, ZTOR, Frv, Fn, rRup, rjb, Rx, Ry0, 
c     1                     vs30, Sa1100, Z1, hwflag, vs30_class, lnSa, phi, tau, useRy0)
c Modified V5 to V10 Mar 18 2013. Several lines change. Loop flow preserved.
c Special consideration:. In the gridded code, SA1100 has to be computed prior to
c SA. SA1100 is saved as a 3-dimensional array. Call this routine twice per period, first for
c hard rock, then for the Vs30 condition of interest
c 12/17/2012: Modified to use Ry0 version if user requests.
c This mod is controlled by the logical variable useRy0.
c ip = global period index. 
c iper = local period index (assoc. with coeffs).
c rxsign=1 for hangingwall side of fault; rxsign=-1 for footwall (two branches that may need to be
c run separately). These might be epistemic alternatives. 
c 
      implicit none
      integer MAXPER 
      real c,n,sqrt2  
      parameter (MAXPER=22,n=1.5,c=1.8,sqrt2=1.414213562)
c lines from hazgrid. table production
      common/fix_sigma/fix_sigma,sigma_fx
      LOGICAL fix_sigma,hardrock
c hardrock .true. for initial pass thru.
      common/mech/wtss,Frv,Fn
       common/prob/p,plim,dp2   !table of complementary normal probab
      common / atten / pr, xlev, nlev, icode, wt, wtdist
c lines from hazgrid. table production
      common/epistemic/nfi,e_wind,gnd_ep,mcut,dcut
       real gnd_ep(3,3,8),mcut(2),dcut(2),gndout(3),gndx
      common/depth_rup/ntor,dtor,wtor,wtor65
c      common/deagg/deagg
      real, dimension(25005):: p
       real, dimension (310,38,20,8,3,3):: pr
       real, dimension(20,8):: xlev
       real, dimension(3):: dtor,wtor,wtor65
       real, dimension(310,38,3):: Sa1100      !rock median
       integer nlev(8),icode(8,10),nfi,ntor
       real wt(8,10,2),wtdist(8,10),sigma_fx,wtss
       real, dimension(0:9) :: rxfac
      real, dimension(MAXPER):: c4, a1, a2, a3, a4, a5, a6,
     1     a7, a8, a9, a10, a11,
     1     a12, a13, a14, a15, a17,
     1     a43, a44, a45, a46,
     2     s1, s2, s3, s4,period, b, vLin
      real M1, M2,tmp,fac
      real lnSa,  rjb, rRup, Rx, Ry0, dip, mag, vs30,magmin,dmag,di
      real HW_taper1, HW_taper2, HW_taper3, HW_taper4, HW_taper5
      real damp_dSA1100, sigAmp, fltWidth, testv1
      real f1, f4, f5, f6, f7, f8, f9, f10
      real Ry1, ZTOR, Frv, Fn, SpecT,rxsign
      real phiA, phiB, tauA, tauB, phi, tau
      integer vs30_class, ia,iPer,ie,ii,jj,k,kk,ipr,ime,ide,ip,nmag,ndist
      logical hwflag,useRy0,e_wind(8)      !don't use. but keep options open in case AS change their mind
      real z10, Z1, zhat, c4_mag,weight,plim,dp2,sigmaf
      real R, V1, Vs30Star, hw_a2, h1, h2, h3, R1, R2, z1_ref,fac00,fac_c,tanfac
      save sa1100
      data period / 0.00, 0.02, 0.03, 0.05, 0.075, 0.1, 0.15, 0.2, 0.25, 
     1              0.3, 0.4, 0.5, 0.75, 1., 1.5, 2., 3., 4., 5., 6., 7.5, 10.0 /
      data Vlin/ 660, 680, 770, 800, 800, 800, 740, 590, 495, 430, 360, 340, 330, 
     1           330, 330, 330, 330, 330, 330, 330, 330, 330 /
      data b/ -1.37, -1.35, -1.26, -1.16, -1.15, -1.23, -1.53, -1.86, -2.16, -2.411,
     1        -2.785, -3.006, -3.113, -2.851, -1.891, -0.792, 0, 0, 0, 0, 0, 0 /
      data c4/ 6, 6, 6, 6, 6, 5.9, 5.8, 5.7, 5.6, 5.5, 5.2, 4.8, 4.4, 4, 3.75, 3.5,
     1         3.25, 3, 3, 3, 3, 3 /
      data s1/ 0.7541, 0.7593, 0.7742, 0.8179, 0.826, 0.805, 0.796, 0.7788, 
     1         0.75, 0.731, 0.6934, 0.6682, 0.6209, 0.5848, 0.5632, 0.5452, 
     1          0.5302, 0.5152, 0.4956, 0.4755, 0.44, 0.4365 /
      data s2/ 0.5439, 0.5466, 0.5488, 0.5587, 0.5837, 0.6035, 0.6069, 0.6112,
     1          0.6148, 0.6171, 0.6123, 0.6206, 0.6395, 0.6618, 0.6574, 0.6563, 
     1          0.6231, 0.5996, 0.5834, 0.5834, 0.56, 0.5273 /
      data s3/ 0.47, 0.47, 0.47, 0.47, 0.47, 0.47, 0.47, 0.47, 0.47, 0.47,
     1         0.47, 0.47, 0.47, 0.47, 0.47, 0.47, 0.47, 0.47, 0.47, 0.47, 0.47, 0.47 /
      data s4/ 0.38, 0.38, 0.38, 0.38, 0.38, 0.38, 0.38, 0.38, 0.38, 0.38,
     1         0.38, 0.38, 0.38, 0.38, 0.38, 0.38, 0.38, 0.38, 0.38, 0.38, 0.38, 00.38 /

      data a1/ 1.0889, 1.1027, 1.2548, 1.5266, 1.753, 1.79, 2.0379, 2.2006, 2.2707, 
     1         2.28, 2.2564, 2.152, 1.8695, 1.5505, 1.0223, 0.6529, 0.1946, -0.1555, 
     2        -0.4919, -0.9061, -1.414, -2.3488/
      data a2/ -1.03, -1.03, -1.07, -1.09, -1.09, -1.07, -1.05, -1.02, -1, -0.98, 
     1         -0.96, -0.94, -0.91, -0.88, -0.84, -0.82, -0.78, -0.75, -0.72, -0.66, -0.595, -0.48 /
      data a3/ 0.281, 0.281, 0.281, 0.281, 0.278, 0.27, 0.258, 0.25, 0.242, 0.239, 
     1         0.231, 0.23, 0.23, 0.23, 0.23, 0.23, 0.23, 0.23, 0.23, 0.23, 0.23, 0.23 /
      data a4/ -0.1, -0.1, -0.1, -0.1, -0.1, -0.1, -0.1, -0.1, -0.1, -0.1, -0.1, -0.1, -0.1,
     1         -0.1, -0.1, -0.1, -0.1, -0.1, -0.1, -0.1, -0.1, -0.1/
      data a5/ -0.49, -0.49, -0.49, -0.49, -0.49, -0.49, -0.49, -0.49, -0.49, -0.49,
     1         -0.49, -0.49, -0.49, -0.49, -0.49, -0.49, -0.49, -0.49, -0.49, -0.49, -0.49, -0.49/
      data a6/ 2.2882, 2.2863, 2.2497, 2.1728, 2.1246, 2.1728, 2.2013, 2.2591, 2.3286, 
     1         2.3237, 2.4414, 2.5174, 2.6745, 2.7543, 2.8332, 2.8674, 2.8927, 2.8194, 2.9062, 
     2         3.0193, 3.1474, 3.4479 /
      data a7/ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 /
      data a8/ 0, 0, 0, 0, 0, 0, -0.029, -0.05, -0.066, -0.079, -0.099, -0.115, 
     1         -0.144, -0.165, -0.194, -0.214, -0.243, -0.264, -0.27, -0.27, -0.27, -0.27 /
      data a9/ 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75,
     1         6.75, 6.75, 6.75, 6.75, 6.82, 6.92, 7, 7.06, 7.145, 7.25 /
      data a10/ 1.56, 1.54, 1.43, 1.35, 1.3, 1.31, 1.57, 1.99, 2.39, 2.73, 3.27, 
     1          3.58, 3.74, 3.35, 1.91, 0.26, -0.93, -0.93, -0.93, -0.93, -0.93, -0.93 /
      data a11/ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 /
      data a12/ -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, 
     1          -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2 /
      data a13/ 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.58, 0.56, 0.53,
     1          0.5, 0.42, 0.35, 0.2, 0, 0, 0, 0, 0 /
      data a14/ -0.3, -0.3, -0.3, -0.3, -0.3, -0.3, -0.3, -0.3, -0.24, -0.19, -0.11,
     1          -0.04, 0.07, 0.15, 0.27, 0.35, 0.46, 0.54, 0.61, 0.65, 0.72, 0.8 /
      data a15/ 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.03, 0.92, 0.84, 0.68, 
     1          0.57, 0.42, 0.31, 0.16, 0.05, -0.04, -0.11, -0.19, -0.3 /
      data a17/ -0.0025, -0.0025, -0.0025, -0.003, -0.0037, -0.004, -0.0037, 
     1          -0.0032, -0.0028, -0.0023, -0.0013, -0.0007, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 /
      data a43/ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.08, 0.1, 0.1, 0.1, 0.13, 0.24, 
     1          0.3, 0.36, 0.43, 0.51, 0.61, 0.55, 0.42/
      data a44/ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.04, 0.06, 0.11, 
     1          0.15, 0.2, 0.21, 0.25, 0.29, 0.32, 0.33, 0.32, 0.265, 0.21 /
      data a45/ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.02, 0.04, 0.07, 0.13, 0.17, 
     1          0.2, 0.22, 0.25, 0.23, 0.21, 0.18, 0.155, 0.13 /
      data a46/ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.03, 0.07, 0.11, 0.13, 
     1         0.14, 0.15, 0.16, 0.14, 0.12, 0.11, 0.07, 0.07, 0.07 /
     
c      n = 1.5      !PARAMETERS
c      c = 1.8
        dAmp_dSA1100 = 0.
      tanfac=tan(20.*3.1415926/180.)
c     Set CA z1 reference
      z1_ref = exp ( -7.67/4. * alog( (Vs30**4 + 610.**4)/(1360.**4+610.**4) ) ) / 1000.
      z1 =z10*0.001	!convert z1 units to km new 2013 version.
C     Soil Depth Model
C     Soil Depth Model (eq 17)
      if ( vs30 .lt. 200. ) then 
        f10 = a43(iper) * alog( (z1+0.01) /(z1_ref+0.01) )
      elseif ( vs30 .lt. 300. ) then
        f10 = a44(iper) * alog( (z1+0.01) /(z1_ref+0.01) )
      elseif ( vs30 .lt. 500. ) then
        f10 = a45(iper) * alog( (z1+0.01) /(z1_ref+0.01) )
      elseif ( vs30 .lt. 700. ) then
        f10 = a46(iper) * alog( (z1+0.01) /(z1_ref+0.01) )
      else
        f10 = 0.
      endif        
c     Set VS30_star
      if ( period(iper) .ge. 3.0 ) then
        V1 = 800.
      elseif ( period(iper) .gt. 0.5 ) then
       V1 = exp( -0.351 * alog(period(iper)/0.5)  + alog(1500.) )
c        V1 = exp( alog(period(iper)/0.5) * alog(800./1500.)/alog(3.0/0.5) + alog(800.) )
      else
        V1=1500.
      endif
      if ( vs30 .lt. v1 ) then
         vs30Star = vs30
      else
      vs30Star = v1
      endif      	
      fac00=(vs30Star/vLin(iper))**n
c     Compute site amplification (Eq. 3) (linear case: most common in NSHMP work) 
           if(vs30 .ge. vLin(iPer)) f5 = (a10(iper) + b(iper)*n) * alog(vs30Star/vLin(iper))
c     Compute HW taper1 
      if ( dip .lt. 30. ) then
        HW_taper1 = 60./ 45.
      else
        HW_taper1 = (90.-dip)/45.
      endif

      h1 = 0.25
      h2 = 1.5
      h3 = -0.75
     
c loop on depth to top of rupture.
C     Base Model
      M1 = a9(iper) 
      M2 = 5.0
       do kk=1,ntor
      Ztor=dtor(kk)
C.....f_HW_Z
c     ZTOR 
      if (ZTOR .le. 20.) then 
        f6 = a15(iper) * ZTOR/20.0
      else
        f6 = a15(iper)
      endif    

c     Compute HW taper 4 
      if ( ZTOR .lt. 10. ) then
        HW_taper4 = 1. - (ZTOR**2) / 100.
      else
        HW_taper4 = 0.
      endif
               
c loop on magnitude
      mag=magmin
      do jj=1,nmag
C*****Magnitude term
      fltWidth=mag+2*rxfac(icode(ip,ia))	!assign width = magnitude+delta for initial checkup. Later need a model..
       if(e_wind(ip))then
          if (mag.lt.mcut(1))then
          ime=1
          elseif(mag.lt.mcut(2))then
          ime=2
          else
          ime=3
          endif
        endif !extra epistemic
        fac_c = (8.5-mag)**2
c     Taper fictitious depth term, c4
      if ( mag .ge. 6.5 ) then
        c4_mag = c4(iper)
      elseif ( mag .ge. 4.5 ) then
        c4_mag = c4(iper) * (mag-4.5)/2.
      else
        c4_mag = 0.
      endif
c     style of faulting 
      if ( mag .lt. 4. ) then
        f7 = 0.
        f8 = 0.
      elseif ( mag .le. 5. ) then
        f7 = Frv * a11(iper) * (mag-4.)
        f8 = Fn * a12(iper) * (mag-4.)
      else 
        f7 = Frv * a11(iper)
        f8 = Fn * a12(iper)
      endif



c     Compute HW taper2 
      hw_a2 = 0.2
      if( mag .gt. 6.5 ) then
        HW_taper2 = 1. + hw_a2 * (mag-6.5) 
      elseif ( mag .gt. 5.5 ) then
c correct a + to a - for the quadratic term from NA email mar 13
        HW_taper2 = 1. + HW_a2 * (mag-6.5) - (1-HW_a2)*(mag-6.5)**2
      else
        HW_taper2 = 0.
      endif

        do ii=1,ndist
        rjb=di*0.5+float(ii-1)*di
        hwflag= ii.eq.1      !hanging wall first distance only
       weight= wt(ip,ia,1)
       if(rjb.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
      if(e_wind(ip))then
          if(rjb.lt.dcut(1))then
          ide=1
          elseif(rjb.lt.dcut(2))then
          ide=2
          else
          ide=3
          endif
          gndx=gnd_ep(ide,ime,ip)
          endif
        Rrup = sqrt(rjb**2+dtor(kk)**2)
        Rx = rxsign*(rjb+rxfac(icode(ip,ia)))      !same test model as in CB12. Needs work.
c     Set distance
      R = sqrt(rRup**2 + c4_mag**2)
c     Compute HW taper 3 *** NoRy0 version, uses tapers from As08 for Rx > R1***
      R1 = fltWidth * cos(dip*3.1415926/180.)
      R2 = 3.*R1
      if ( Rx .le. R1 ) then
        HW_taper3 = h1 + h2*(Rx/R1) + h3*(Rx/R1)**2
      elseif ( Rx . lt. R2 ) then
        HW_taper3 = 1. - (Rx-R1)/(R2-R1)
      else
c        HW_taper3 = 1.
	HW_taper3= 0.0	!corrected an error from Ronnie Kamai email apr 11 2013.
      endif 
      if ( mag .le. M2 ) then
        f1 = a1(iper) + a6(iper)*(Mag-M2) + a7(iper)*(Mag-M2)**2 + a4(iper)*(M2-M1) + a8(iper)*(8.5-M2)**2 +
     +                (a2(iper) + a3(iper)*(M2-M1)) * alog(R) + a17(iper)*R
      elseif ( mag .le. M1 ) then
        f1 = a1(iper) + a4(iper)*(Mag-M1) + a8(iper)*fac_c + (a2(iper) + a3(iper)*(Mag-M1)) * alog(R) + a17(iper)*R
      else
        f1 = a1(iper) + a5(iper)*(Mag-M1) + a8(iper)*fac_c + (a2(iper) + a3(iper)*(Mag-M1)) * alog(R) + a17(iper)*R
      endif

      
c     Compute HW taper 5 (eq. 11)  **** No Ry0 version ***     
      if(useRy0)then
       Ry1 = Rx * tanfac
       if ( Ry0 .lt. Ry1 ) then
        HW_taper5 = 1.
        elseif ( Ry0-Ry1 .lt. 5. ) then
        HW_taper5 = 1. - (Ry0-Ry1) / 5.
       else
        HW_taper5 = 0.
       endif
      else      !no Ry0 version
      if (Rjb .eq. 0. ) then
        HW_taper5 = 1. 
      elseif ( Rjb .lt. 30. ) then
        HW_taper5 = 1 - Rjb/30.
      else
        HW_taper5 = 0.
      endif
      endif ! Ry0 version or not?
c     Hanging wall Model 
      if ( HWFlag ) then
        f4 = a13(iper) * HW_taper1 * HW_taper2 * HW_taper3 * HW_taper4 * HW_taper5
      else
        f4 = 0.
      endif
c f5 for hard rock was computed outside all loops.
      if (vs30 .lt. vLin(iPer))
     1 f5 = a10(iper)*alog(vs30Star/vLin(iper)) - b(iper)*alog(c+Sa1100(ii,jj,kk)) 
     1              + b(iper)*alog(Sa1100(ii,jj,kk)+c*fac00 )
      
c     Compute median ground motion
      lnSa = f1 + f4 + f5 + f6 + f7 + f8 + f9 + f10  

       if(hardrock)then
      Sa1100(ii,jj,kk)=exp(lnSa)
      goto 2013
      endif      !hardrock ... skip the table production.
C     Set the Sigma Values
      if(fix_sigma)then
      sigmaf = 1./sqrt2/sigma_fx
      else
c     Compute within-event term, phiA, at the surface for linear site response (Eq. 27)      
c     Compute within-event term, phiA, at the surface for linear site response 
      if (mag .lt. 3.0) then
         phiA = s1(iper)
      elseif (mag .le. 7.0) then
         phiA = s1(iper) + ((s2(iper)-s1(iper))/3.5)*(mag-3.5)
      else
         phiA = s2(iper)
      endif

c     Compute between-event term, tau 
      if (mag .lt. 5.0) then
         tauA = s3(iper)
      elseif (mag .le. 7.0) then
         tauA = s3(iper) + ((s4(iper)-s3(iper))/2.0)*(mag-5.0)
      else
         tauA = s4(iper)
      endif
      tauB = tauA

c     Compute phiB, within-event term with site amp variablity removed 
      sigAmp = 0.4
      phiB = sqrt( phiA**2 - sigAmp**2)
      
c     Compute parital derivative of alog(soil amp) w.r.t. alog(SA1100) 
      if ( vs30 .lt. vLin(iper))
     1   dAmp_dSA1100 = b(iper)*SA1100(ii,jj,kk) * ( -1. / (SA1100(ii,jj,kk)+c) 
     1              + 1./ (SA1100(ii,jj,kk) + c*(vs30/vLin(iper))**(n)) )
C     Compute phi, with non-linear effects (eq. 20)
c
c      phi = sqrt( phiB**2 * (1. + 2.*(dAmp_dSA1100)) +sigAmp**2 )
      phi = sqrt( phiB**2 * (1. + dAmp_dSA1100)**2 + sigAmp**2 )
C     Compute tau, with non-linear effects
c      tau = sqrt( tauB**2 * (1. + 2.*(dAmp_dSA1100))  )
      tau = tauB * (1. + dAmp_dSA1100)
      sigmaf=1./sqrt2/sqrt(tau**2+phi**2)
      endif
           gndout(1)=lnSa
         if(e_wind(ip))then
         gndout(2)= lnSa+gndx
         gndout(3)= lnSa-gndx
         endif
      do ie=1,nfi
      do 199 k=1,nlev(ip)
      tmp= (gndout(ie)- xlev(k,ip))*sigmaf
        if(tmp.gt.3.3)then
       ipr=25002
       elseif(tmp.gt.plim)then
       ipr= 1+nint(dp2*(tmp-plim))	!3sigma cutoff n'(mu,sig)
       else
       goto 102	!transfer out if ln(SA) above mu+3sigma
       endif
       fac=weight*p(ipr)
 199  pr(ii,jj,k,ip,kk, ie)= pr(ii,jj,k,ip,kk,ie)+ fac !sum thru ia index
  102 continue
      enddo	!ie loop.
 2013      continue
      enddo	!distance loop
      mag=mag+dmag
      enddo	!mag loop
      enddo	!depth of top of rupture loop
      
      

       return
      end subroutine AS2013_V10_MODEL 

 
c-----------------------------------------------------------------------
        subroutine CY2012_NGA(ip,iprd,ia,ndist,di,nmag,magmin,dmag,DELTA,z1,v_s30,rxsign )
cM, R_Rup, R_JB, R_x, V_S30,
c     1                   F_Measured, F_Inferred, Z1, DELTA, Z_TOR,
c     1                   F_RV, F_NM,
c     1                   psa_ref, psa, NL0, tau, sigma_NL0, sigmaf
c  PERIOD       Spectral period (sec), enter -2 for peak velocity
c  M            Magnitude
c  F_RV         Enter 1 for reverse faulting, 0 otherwise default is SS)
c  F_NM         Enter 1 for normal faulting, 0 otherwise (default is SS)
c  Z_TOR        Depth to top of rupture (km)
c  DELTA        Fault dip (degrees)
c  V_S30        Average shear wave velocity (m/s)
c  F_Inferred   Enter 1 if Vs30 is inferred, 0 if measured
c  Z1           Depth to Vs = 1 km/sec (m), enter -999 for default
c  R_Rup        Distance to rupture plane (km)
c  R_JB         Joyner-Boore distance (km)
c  R_x          Normal distance to strike of fault (km), negative on footwall
c rxsign = instruction to put all sites on footwall if <0, on hangingwall side if >0.

        implicit none
c ip =global period index
c iper =local period index
c ia =attenuation model index
c Predictor variables
        real PERIOD, M, Width, R_rup, R_JB, R_x, rxsign, V_S30, F_Measured,
     1       F_Inferred, Z1, DELTA, Z_TOR, F_RV, F_NM
c Common epistemic added Jan 7 2013. You may add extra epistemic uncert to the median motion.
c lines from hazgrid. table production
      common/fix_sigma/fix_sigma,sigma_fx
      common/mech/wtss,F_RV, F_NM
       common/prob/p,plim,dp2   !table of complementary normal probab
      common / atten / pr, xlev, nlev, icode, wt, wtdist
c lines from hazgrid. table production
      common/depth_rup/ntor,dtor,wtor,wtor65
      common/epistemic/nfi,e_wind,gnd_ep,mcut,dcut
       real gnd_ep(3,3,8),mcut(2),dcut(2),gndout(3),gndx
      real, dimension(25005):: p
       real, dimension (310,38,20,8,3,3):: pr
       real, dimension(20,8):: xlev
       real, dimension(3):: dtor,wtor,wtor65
       integer nlev(8),icode(8,10),nfi
       real wt(8,10,2),wtdist(8,10),sigma_fx
       real, dimension(0:9) :: rxfac
      logical e_wind(8),fix_sigma
c Model cofficients
        integer nprd,ipr,ntor,ip
        REAL sqrt2,tmp,fac,wtss,weight
        parameter (nprd=3,sqrt2=1.4142136)
        integer ia,ie,ide,ime,ii,jj,kk,k,ndist,nmag
        real magmin,dmag,di,plim,dp2
        real prd(nprd),
     1       c1(nprd), c1a(nprd), c1b(nprd), c2(nprd),
     1       c3(nprd), cn(nprd),  cM(nprd),  c4(nprd),
     1       c4a(nprd),cRB(nprd), c5(nprd),  c6(nprd),
     1       cHM(nprd),c7(nprd),  c9(nprd),  c9a(nprd), c11(nprd),
     1       cgamma1(nprd), cgamma2(nprd), cgamma3(nprd),
     1       phi1(nprd), phi2(nprd), phi3(nprd), phi4(nprd),
     1       phi5(nprd), phi6(nprd), phi7(nprd), phi8(nprd),
     1       tau1(nprd), tau2(nprd),
     1       sigma1(nprd), sigma2(nprd), sigma3(nprd)
      data prd     /  0.0100, 0.2000, 1.0000/

      data c1      / -1.0944608,-0.4072448,-2.0178770/

      data c1a     /  0.1000, 0.1000, 0.0766/

      data c1b     / -0.2550,-0.2449,-0.1400/

      data c2      /  1.06,    1.06,   1.06/

      data c3      /  1.975122, 2.186490, 3.019458/

      data cn      /  2.9960, 2.8312, 1.6480/

      data cM      /  5.699819, 5.428224, 5.459493/

      data c4      / -2.1,   -2.1,   -2.1/

      data c4a     / -0.5,   -0.5,   -0.5/

      data cRB     /  50,     50,     50/

      data c5      /  6.1600, 5.8699, 5.2480/

      data c6      /  0.4893, 0.4755, 0.4517/

      data cHM     /  3, 3, 3/

      data c7      /  0.08281534, 0.05232253, 0.0000000/

      data c9      /  0.7900, 0.9334, 0.6196/

      data c9a     /  1.500502, 1.915732, 2.668990/

      data c11     /  0.0125256, 0.010086769, 0.002604898/

      data cgamma1 / -0.0075,-0.0090,-0.0030/

      data cgamma2 / -0.0065,-0.0040,-0.0025/

      data cgamma3 / 4, 4, 4/

      data phi1    / -0.4417,-0.5697,-0.7990/

      data phi2    / -0.1417,-0.2927,-0.0699/

      data phi3    / -0.007010,-0.006141,-0.008444/

      data phi4    /  0.1021510, 0.255253, 0.058595/

      data phi5    /  0.2289, 0.2386, 0.4629/

      data phi6    /  0.014996, 0.014964, 0.005749/

      data phi7    /  580.0, 573.9, 391.8/

      data phi8    /  0.0700,-0.0019,-0.0412/

      data tau1    /  0.3437, 0.3601, 0.3577/

      data tau2    /  0.2637, 0.3076, 0.3419/

      data sigma1  /  0.4458, 0.4816, 0.4581/

      data sigma2  /  0.3459, 0.3902, 0.4213/

      data sigma3  /  0.8000, 0.8000, 0.7504/
        real cc, gamma, cosDELTA, psa, psa_ref, NL0, tau, sigma_NL0,
     1       total_app
        real pi, d2r, r1, r2, r3, r4, fw, hw, a, b, c, rkdepth
      real	sigmaf
        integer iprd, sa
        rxfac=(/0.,0.5,1.,2.,3.,4.,4.5,5.,5.5,6./)

      F_measured=1.0
      F_inferred=0.0	!Chiou recommendation Nov 2012.
        pi = atan(1.0)*4.0
        d2r = pi/180.0
        cosDELTA = cos(DELTA*d2r)

c Soil effect: linear response
        a = phi1(iprd) * min(log(V_S30/1130.0), 0.0)

c Soil effect: nonlinear response
        b = phi2(iprd) *
     1(exp(phi3(iprd)*(min(V_S30,1130.)-360.))-exp(phi3(iprd)*(1130.-360.)))

        c = phi4(iprd)

c Corrections to ln(Vs30) scaling
c
c !!  NOTE: On the 3rd line, I cap max(0,Z1-15) at 300 to avoid
c !!          the numerical overflow of intrinsic function 'cosh'.
c
        rkdepth = phi5(iprd) *
     1        ( 1.0 - 1.0/cosh(phi6(iprd)*max(0.0,Z1-phi7(iprd)))) +
     1        phi8(iprd)/cosh(0.15*min(max(0.0, Z1-15.0),300.0))


c loop on depth to top of rupture.
       do kk=1,ntor
      Z_tor=dtor(kk)
c loop on magnitude
      M=magmin
      do jj=1,nmag
C*****Magnitude term
c      fltWidth= M +2*rxfac(icode(ip,ia))	!CY not using fltwidth 
       if(e_wind(ip))then
          if(M.lt.mcut(1))then
          ime=1
          elseif(M.lt.mcut(2))then
          ime=2
          else
          ime=3
          endif
        endif !extra epistemic
        cc = c5(iprd)* cosh(c6(iprd) * max(M-cHM(iprd),0.0))
        gamma = cgamma1(iprd) +
     1          cgamma2(iprd)/cosh(max(M-cgamma3(iprd),0.0))

c Magnitude scaling
        r1 = c1(iprd) + c2(iprd) * (M-6.0) +
     1       (c2(iprd)-c3(iprd))/cn(iprd) *
     1             log(1.0 + exp(cn(iprd)*(cM(iprd)-M)))
c Scaling with other source variables (F_RV, F_NM, and Z_TOR)
        r4 = c1a(iprd)*F_RV +
     1       c1b(iprd)*F_NM +
     1       c7(iprd)*(Z_TOR - 4)
        if (M .lt. 6.0) r4 = r4 + c11(iprd)*min(DELTA-70.,0.)

        do ii=1,ndist
        R_JB=di*0.5+float(ii-1)*di
       weight= wt(ip,ia,1)
       if(R_JB.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
      if(e_wind(ip))then
          if(R_JB.lt.dcut(1))then
          ide=1
          elseif(R_JB.lt.dcut(2))then
          ide=2
          else
          ide=3
          endif
          gndx=gnd_ep(ide,ime,ip)
          endif

        R_Rup = sqrt(R_JB**2+dtor(kk)**2)
        R_x = rxsign*(R_JB+rxfac(icode(ip,ia)))      !same test model as in CB12. Needs work.
c Near-field magnitude and distance scaling
        r2 = c4(iprd) * log(R_Rup + cc)

c Far-field distance scaling
        r3 = (c4a(iprd)-c4(iprd)) *
     1            log(sqrt(R_Rup*R_Rup+cRB(iprd)*cRB(iprd))) +
     1       R_Rup * gamma


c HW effect
        if (R_x .lt. 0) then
          hw = 0.0
        else
          hw = c9(iprd) * tanh(R_x*cosDELTA**2/c9a(iprd)) *
     1        (1.0 - sqrt(R_JB**2+Z_TOR**2)/(R_Rup + 0.001))
        endif


        psa_ref = r1+r2+r3+r4+hw

c....... Polulation mean of ln(psa) (eta=0)

c        psa  remains in log space while building table
c        
        psa = psa_ref + (a + b * log((exp(psa_ref)+c)/c)) + rkdepth

c....... Total variance of ln(psa) about the population mean:
c          The approximate method (Equation 21)
       psa_ref=exp(psa_ref)
      if(fix_sigma)then
      sigmaf = 1./sqrt2/sigma_fx
      else
        NL0 = b * psa_ref/(psa_ref+c)
        tau = tau1(iprd) +
     1            (tau2(iprd)-tau1(iprd))/2*(min(max(M,5.),7.)-5.)

        sigma_NL0 = sigma1(iprd) +
     1              (sigma2(iprd)-sigma1(iprd))/2*(min(max(M,5.),7.)-5.)

        sigma_NL0 = sigma_NL0 *
     1        sqrt(0.7*F_Measured+F_Inferred*sigma3(iprd)+(1+NL0)**2)

        total_app = sqrt((tau*(1+NL0))**2+sigma_NL0**2)
        sigmaf=1./total_app/sqrt2
        endif      !fix sigma at command-line value?
c        if(ii.eq.1)print *,M,psa,sigmaf,iprd
           gndout(1)=psa
         if(e_wind(ip))then
         gndout(2)= psa+gndx
         gndout(3)= psa-gndx
         endif
      do ie=1,nfi
      do 199 k=1,nlev(ip)
      tmp= (gndout(ie) - xlev(k,ip))*sigmaf
        if(tmp.gt.3.3)then
       ipr=25002
       elseif(tmp.gt.plim)then
       ipr= 1+nint(dp2*(tmp-plim))	!3sigma cutoff n'(mu,sig)
       else
       goto 102	!transfer out if ln(SA) above mu+3sigma
       endif
       fac=weight*p(ipr)
 199  pr(ii,jj,k,ip,kk,ie)= pr(ii,jj,k,ip,kk,ie)+ fac !sum thru ia index
  102 continue
      enddo !ie loop (extra epistemic)
      enddo	!distance loop
      M= M+dmag
      enddo	!mag loop
      enddo	!depth of top of rupture loop

        return

        end subroutine CY2012_NGA
     
      subroutine gksa13v2(ip,L,ia,ndist,di,nmag,magmin,dmag,vs,Bdepth,Q)
c Revised Graizer and Kalkan model with continuous response variation with 
c      basin depth. Also PGA has been identified with 0.01s SA due to basin
c      effect. 
c Revised to April V2 2013 version. Apr 9 2013. SHarmsen. Changed these coeff. values:
c c9, e2, e4, t2, and t4. All others the same as in previous GK13.
c Input: L = period index in below per array.
c Bdepth = basin depth (km). new parm. 2012. Geotech: depth to Vs=1.5 km/s
c       Q quality factor 435 for California according to GK
c mec is sense-of-slip but is now communicated in common/mech/. Previous Graizer defn:
ccccc      Mec = 1 for strike slip    Normal Faults (3) are treated like strike slip
ccccc      Mec = 2 for thrust faults
ccccc      Mec = 4 combination of thrust and strike
c loop on
c      x = Rcd (km).
c      Mw = moment magnitude.
c Output:
c pr = exc. table of logged median motion (SA) (g).
c 2
       real sqrt2,Mw,magmin,dmag,di,Z_torsq
       integer nmag,ii,jj,kk,k
        parameter (nper=35,sqrt2=1.41421356)
c lines from hazgrid. table production
      common/fix_sigma/fix_sigma,sigma_fx
      common/mech/wtss,wtrev,wtnm
       common/prob/p,plim,dp2   !table of complementary normal probab
      common / atten / pr, xlev, nlev, icode, wt, wtdist
c lines from hazgrid. table production
      common/depth_rup/ntor,dtor,wtor,wtor65
      common/epistemic/nfi,e_wind,gnd_ep,mcut,dcut
       real gnd_ep(3,3,8),mcut(2),dcut(2),gndout(3),gndx,sigma_fx
      real, dimension(25005):: p
       real, dimension (310,38,20,8,3,3):: pr
       real, dimension(20,8):: xlev
       real, dimension(3):: dtor,wtor,wtor65
       integer nlev(8),icode(8,10)
       real wt(8,10,2),wtdist(8,10)
       real Y      !pga
      logical e_wind(8),fix_sigma

      real bv, Va, c1, c2, c3, c4, c5, c6, c7, c8, c9
      real R0, D0, R1, D1, Y1, A, Dsp, Mu
      real per(35), sigma(35)
      real e1, e2, e3, e4
      real a1, a2, a3
      real t1, t2, t3, t4
      real s1, s2, s3

      DATA PER/0.01,0.02,0.03,0.04,0.06,0.08,0.1,0.12,0.14,
     &         0.16,0.18,0.20,0.22,0.24,0.27,0.30,0.33,
     &         0.36,0.4,0.46,0.5,0.6,0.75,0.85,1.0,1.5,
     &         2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0/
c      DATA sigma/0.542,0.543,0.544,0.547,0.549,0.549,0.553,0.558,0.568,
c     &         0.577,0.584,0.591,0.597,0.602,0.610,0.616,0.622,
c     &         0.627,0.634,0.642,0.647,0.658,0.667,0.672,0.681,0.703,
c     &         0.718,0.74,0.756,0.768,0.775,0.78,0.78,0.78,0.78/
C***********************************************************
C*********Coefficients file, dec 2012 ***************
         c1 =  0.140
         c2 = -6.250
         c3 =  0.370
         c4 =  2.237
         c5 = -7.542
         c6 = -0.125
         c7 =  1.190
         c8 = -6.150
c         c9 =  0.525
	c9 = 0.6
         bv = -0.240 
         Va = 484.5
         R1 = 100.0
         c11= 1.0
         D1 = 0.65
         sigpga = 0.550
         sigmaf=1./sigpga/sqrt2
c revised sigma in the latest GK13fl model... added apr 4 2013.
         if (per(L).le.0.12) then
            Sigma(L)=0.0047*alog(per(L))+0.5522
          else
            Sigma(L)=0.0497*alog(per(L))+0.646
          endif
c------SA calculations ----------mod coeffs mar 29 2013 SH-----
          e1=-0.0012
c          e2=-0.40854
          e2=-0.38
          e3= 0.0006
c          e4= 3.63
	  e4=3.9
          a1= 0.01686
          a2= 1.2695
          a3= 0.0001
          Dsp=0.75
c          t1= 0.0022
          t1= 0.001
c          t2= 0.60
          t2= 0.59
          t3=-0.0005
c          t4=-2.1
          t4=-2.3
c          s1=0.001
          s1=0.00
          s2=0.077
          s3=0.3251

c********* Basin Effect *******************************

c-------  Depth dependance ----------------------------

      Abdepth = 1.4 / sqrt((1.0-(1.5/(Bdepth+0.1))**2)**2

     &           + 1.96*(1.5/(Bdepth+0.1))**2)
c site amp (linear)
      sfac=bv * (alog(Vs/Va))
c********* Distance Dependence ********************

c********* Amplification Factor depending upon style of faulting **********
ccccc      Mec = 1 for strike slip    Normal Faults are treated as strike
ccccc      Mec = 2 for thrust faults
ccccc      Mec = 4 combination of thrust and strike. 
c the above have been replaced by weights assoc. with different styles.

      IF(wtss.EQ.1.0.or. wtnm.eq.1.) THEN
          Frv = 1.0
       ELSE IF(wtrev.EQ.1.) THEN
          Frv = 1.28
       ELSEIF(wtss+wtrev.eq.1.) THEN
          Frv = 1.14
      ENDIF
c loop on depth to top of rupture.
       do kk=1,ntor
      Z_torsq=dtor(kk)*dtor(kk)
c loop on magnitude
      Mw=magmin
      do jj=1,nmag
C*****Magnitude term
      A = (c1*atan(Mw+c2)+c3)*Frv
      A = A/1.096
c------- Vs30 site effect in sfac--------------------------
      Y1 = alog(A) +sfac
       if(e_wind(ip))then
          if(Mw.lt.mcut(1))then
          ime=1
          elseif(Mw.lt.mcut(2))then
          ime=2
          else
          ime=3
          endif
        endif !extra epistemic
ccccc    Corner distance R0 depends upon magnitude

         R0 = c4 * Mw + c5

c********* Damping D0 Factor **************************
ccccc    Damping is magnitude dependent

         D0 = c6 * cos(c7*(Mw + c8)) + c9
c-------  Distance dependence ------------------------- 
       do ii=1,ndist
        R_JB=di*0.5+float(ii-1)*di
       weight= wt(ip,ia,1)
       if(R_JB.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
      if(e_wind(ip))then
          if(R_JB.lt.dcut(1))then
          ide=1
          elseif(R_JB.lt.dcut(2))then
          ide=2
          else
          ide=3
          endif
          gndx=gnd_ep(ide,ime,ip)
          endif
        x = sqrt(R_JB**2+Z_torsq)

      Abdist = 1. / sqrt((1.0-(40./(x+0.1))**2)**2

     &           + 1.96*(40./(x+0.1))**2)

c-------  Slope of SA at long-periods ----------------
      Slope = 1.763 - 0.25 * atan(1.4*(Bdepth-1.))
c*************** Calculating non-basin PGA *****************

c-------- Core Filter and Anelastic ----------------

         x0 = x/R0
         x1 = sqrt(x/R1)
         Y = Y1 - 0.5 * alog((1-x0)**2 + 4*D0**2*x0)
     &       - (c11 * x/Q)
ccccccc End non-basin PGA Calculation cccccccccccccccccccccccc


c------SA calculations ---------------------------------------
         Mu = e1*x+e2*Mw+e3*Vs+e4

          Amp = (a1*Mw+a2)*exp(a3*x)

          Si = s1*x-(s2*Mw+s3)
          Tspo = MAX(0.3,ABS(t1*x+t2*Mw+t3*Vs+t4))	!changed 3/29/2013
c          Tspo = t1*x+t2*Mw+t3*Vs+t4
          Pern = (per(L)/Tspo)**Slope

          temp1 = (alog(per(L))+Mu)/Si
          temp2 = temp1**2
          SA1 = Amp*exp(-0.5*temp2)
          SA2 = 1./sqrt((1-Pern)**2 + 4.*Dsp**2
     &               *Pern)

          SA = SA1 + SA2
          SA1 = SA*exp(Y)
     &              * (1.+ABdist*ABdepth/1.3)
c         if (ii.eq.1.or.ii.eq.2)print *,x,SA1,Mw,sigma(L)
          SA = alog(SA1)
           gndout(1)=SA
         if(e_wind(ip))then
         gndout(2)= SA+gndx
         gndout(3)= SA-gndx
         endif
         if(fix_sigma)then
      sigmaf = 1./sqrt2/sigma_fx
      else

           sigmaf=1./sigma(L)/sqrt2
           endif      !user specified sigma or GK tabulated value?
      do ie=1,nfi
      do 199 k=1,nlev(ip)
      tmp= (gndout(ie) - xlev(k,ip))*sigmaf
        if(tmp.gt.3.3)then
       ipr=25002
       elseif(tmp.gt.plim)then
       ipr= 1+nint(dp2*(tmp-plim))	!3sigma cutoff n'(mu,sig)
       else
       goto 102	!transfer out if ln(SA) above mu+3sigma
       endif
       fac=weight*p(ipr)
 199  pr(ii,jj,k,ip,kk,ie)= pr(ii,jj,k,ip,kk,ie)+ fac !sum thru ia index
  102 continue
        enddo	!ie	extra epistemic.
           enddo	!ii
           Mw=Mw + dmag
           enddo	!jj mag loop
           enddo	!kk source-depth loop
           return
        END subroutine gksa13v2

      subroutine Idriss2013(iper,ip,ia,ndist,di,nmag,magmin,dmag,vs30)
c Apr 2013: for pga and many periods to 10s. Idriss Coeffs are updated april 11 2013.
c ip is period index in calling program. 
c iper is period index in this subroutine.
c User can fix sigma_aleatory to a preset value if fix_sigma is .true. Jan 9 2013. 
      integer Nper
      parameter (pi=3.14159265,sqrt2=1.414213562,Nper=22)
c lines from hazgrid. table production
      common/fix_sigma/fix_sigma,sigma_fx
      common/mech/wtss,wtrev,wtnm
       common/prob/p,plim,dp2   !table of complementary normal probab
      common / atten / pr, xlev, nlev, icode, wt, wtdist
c lines from hazgrid. table production
      common/depth_rup/ntor,dtor,wtor,wtor65
      common/epistemic/nfi,e_wind,gnd_ep,mcut,dcut
      real, dimension (nper):: a1, a2, a3, b1,b2, x,g, phi, Period
      real gnd_ep(3,3,8),mcut(2),dcut(2),gndout(3),gndx,gnd0,gndm,gnd,sigma_fx
      real, dimension(25005):: p
      real, dimension (310,38,20,8,3,3):: pr
      real, dimension(20,8):: xlev
      real, dimension(3):: dtor,wtor,wtor65
      integer nlev(8),icode(8,10)
      real wt(8,10,2),wtdist(8,10)
c      real gndout(3)
      logical e_wind(8),fix_sigma
c 22 periods in Idriss NGA Dec 2012:

c----  This version assumes v30 effect is linear with rock gm.
c----  uses ln coefficients
      real xmag,magmin,dmag
      logical changem
c coeffs. from apr 2013 email
c	Period=(/0.01,0.02,0.03,0.04,0.05,0.075,0.1,0.15,0.2,0.25,0.3,0.4,0.5,0.75,1.,1.5,2.,3.,4.,5.,7.5,10.0/)
        Period  = (/0.01,0.02,0.03,0.04,0.05,0.075,0.1,0.15,0.2,0.25,0.3,0.4,0.5,0.75,1.0,1.5,2.,3.,4.0,5.,7.5,10./)
	a1=(/7.0887,7.1157,7.2087,7.3287,6.2638,5.9051,7.5791,8.0190,9.2812,9.5804,9.8912,9.5342,
     +9.2142,8.3517,7.0453,5.1307,3.3610,0.1784,-2.4301,-4.3570,-7.8275,-9.2857/)
	a2=(/0.2058,0.2058,0.2058,0.2058,0.0625,0.1128,0.0848,0.1713,0.1041,
     +0.0875,0.0003,0.0027,0.0399,0.0689,0.1600,0.2429,0.3966,0.7560,0.9283,1.1209,1.4016,1.5574/)
	a3=(/0.0589,0.0589,0.0589,0.0589,0.0417,0.0527,0.0442,0.0329,0.0188,
     +0.0095,-0.0039,-0.0133,-0.0224,-0.0267,-0.0198,-0.0367,-0.0291,-0.0214,-0.0240,-0.0202,-0.0219,-0.0035/)
	b1=(/2.9935,2.9935,2.9935,2.9935,2.8664,2.9406,3.0190,2.7871,2.8611,
     +2.8289,2.8423,2.8300,2.8560,2.7544,2.7339,2.6800,2.6837,2.6907,2.5782,2.5468,2.4478,2.3922/)
	b2=(/-0.2287,-0.2287,-0.2287,-0.2287,-0.2418,-0.2513,-0.2516,-0.2236,
     +-0.2229,-0.2200,-0.2284,-0.2318,-0.2337,-0.2392,-0.2398,-0.2417,-0.2450,-0.2389,-0.2514,-0.2541,-0.2593,-0.2586/)
	x=(/-0.854,-0.854,-0.854,-0.854,-0.631,-0.591,-0.757,-0.911,-0.998,
     +-1.042,-1.030,-1.019,-1.023,-1.056,-1.009,-0.898,-0.851,-0.761,-0.675,-0.629,-0.531,-0.586/)
	g=(/-0.0027,-0.0027,-0.0027,-0.0027,-0.0061,-0.0056,-0.0042,-0.0046,
     +-0.0030,-0.0028,-0.0029,-0.0028,-0.0021,-0.0029,-0.0032,-0.0033,
     +-0.0032,-0.0031,-0.0051,-0.0059,-0.0057,-0.0061/)
	phi=(/0.08,0.08,0.08,0.08,0.08,0.08,0.08,0.08,0.08,0.08,0.08,0.08,0.08,0.08,0.06,0.04,0.02,0.02,0.,0.,0.,0./)
c Thie below sigma from Eq Spectra 2008 may be revised.
      T = max(period(iper),0.05)
      T = min(T,3.0)
      if(fix_sigma)then
      sigmaf=1./sigma_fx/sqrt2
      endif
c-- 
c vs30 dependence (linear)
          vscap=min(vs30,1200.)
      gnd0=a1(iper)+wtrev*phi(iper)+ x(iper)*alog(vscap)
c loop on depth to top of rupture.
       do kk=1,ntor
      Z_torsq=dtor(kk)**2
c loop on magnitude
      xmag=magmin
      do jj=1,nmag
C*****Magnitude dependent terms
      if(.not.fix_sigma)then
        sig = 1.28 + 0.05*alog(T) - 0.08 * xmag
          sigmaf= 1./sig/sqrt2
          endif
         gndm=gnd0+a2(iper)*xmag+a3(iper)*(8.5-xmag)**2
       if(e_wind(ip))then
          if(xmag.lt.mcut(1))then
          ime=1
          elseif(xmag.lt.mcut(2))then
          ime=2
          else
          ime=3
          endif
        endif !extra epistemic
c-------  Distance dependence ------------------------- 
       do ii=1,ndist
        R_JB=di*0.5+float(ii-1)*di
       weight= wt(ip,ia,1)
       if(R_JB.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
      if(e_wind(ip))then
          if(R_JB.lt.dcut(1))then
          ide=1
          elseif(R_JB.lt.dcut(2))then
          ide=2
          else
          ide=3
          endif
          gndx=gnd_ep(ide,ime,ip)
          endif      !extra epistemic?
         rrup = sqrt(R_JB**2+Z_torsq)
          gnd= gndm-(b1(iper)+b2(iper)*xmag)*alog(rrup+10.)+g(iper)*rrup
        gndout(1)=gnd
         if(e_wind(ip))then
         gndout(2)= gnd+gndx
         gndout(3)= gnd-gndx
         endif
      do ie=1,nfi
      do 199 k=1,nlev(ip)
      tmp= (gndout(ie) - xlev(k,ip))*sigmaf
        if(tmp.gt.3.3)then
       ipr=25002
       elseif(tmp.gt.plim)then
       ipr= 1+nint(dp2*(tmp-plim))	!3sigma cutoff n'(mu,sig)
       else
       goto 102	!transfer out if ln(SA) above mu+3sigma
       endif
       fac=weight*p(ipr)
 199  pr(ii,jj,k,ip,kk,ie)= pr(ii,jj,k,ip,kk,ie)+ fac !sum thru ia index
  102 continue
        enddo	!ie	extra epistemic.
         enddo      !ii
         xmag=xmag+dmag
         changem=xmag.gt.6.75.and.xmag.lt.6.9
         if(changem)then
	a1=(/9.0138,9.0408,9.1338,9.2538,7.9837,7.7560,9.4252,9.6242,11.1300,
     + 11.3629,11.7818,11.6097,11.4484,10.9065,9.8565,8.3363,6.8656,4.1178,1.8102,0.0977,-3.0563,-4.4387/)
	a2=(/-0.0794,-0.0794,-0.0794,-0.0794,-0.1923,-0.1614,-0.1887,-0.0665,
     + -0.1698,-0.1766,-0.2798,-0.3048,-0.2911,-0.3097,-0.2565,-0.2320,-0.1226,0.1724,0.3001,0.4609,0.6948,0.8393/)
	a3=(/0.0589,0.0589,0.0589,0.0589,0.0417,0.0527,0.0442,0.0329,0.0188,
     + 0.0095,-0.0039,-0.0133,-0.0224,-0.0267,-0.0198,-0.0367,-0.0291,-0.0214,-0.0240,-0.0202,-0.0219,-0.0035/)
	b1=(/2.9935,2.9935,2.9935,2.9935,2.7995,2.8143,2.8131,2.4091,2.4938,
     + 2.3773,2.3772,2.3413,2.3477,2.2042,2.1493,2.0408,2.0013,1.9408,1.7763,1.7030,1.5212,1.4195/)
	b2=(/-0.2287,-0.2287,-0.2287,-0.2287,-0.2319,-0.2326,-0.2211,-0.1676,
     + -0.1685,-0.1531,-0.1595,-0.1594,-0.1584,-0.1577,-0.1532,-0.1470,-0.1439,-0.1278,-0.1326,-0.1291,-0.1220,-0.1145/)
	x=(/-0.854,-0.854,-0.854,-0.854,-0.631,-0.591,-0.757,-0.911,-0.998,
     + -1.042,-1.030,-1.019,-1.023,-1.056,-1.009,-0.898,-0.851,-0.761,-0.675,-0.629,-0.531,-0.586/)
	g=(/-0.0027,-0.0027,-0.0027,-0.0027,-0.0061,-0.0056,-0.0042,-0.0046,
     +-0.0030,-0.0028,-0.0029,-0.0028,-0.0021,-0.0029,-0.0032,-0.0033,-0.0032,-0.0031,-0.0051,-0.0059,-0.0057,-0.0061/)
	phi=(/0.08,0.08,0.08,0.08,0.08,0.08,0.08,0.08,0.08,0.08,0.08,0.08,0.08,0.08,0.06,0.04,0.02,0.02,0.,0.,0.,0./)
      gnd0=a1(iper) +wtrev*phi(iper) + x(iper)*alog(vscap)
      endif
      enddo	!jj or mag loop
      enddo	!kk or depth of source loop
      return
      end subroutine Idriss2013

      subroutine lin_interp(x, y, n, j, x_intrp, y_intrp)
      
* Computes linearly interpolated value of y

* Values out of range are assigned end values

* Dates: 03/16/05 - Written by D. Boore
*        07/24/05 - Added index j for end cases

      real x(*), y(*), slope, x_intrp, y_intrp
      integer j, n
      
      if (x_intrp .le. x(1)) then
        j = 1
        y_intrp = y(1)
        return
      end if
      
      if (x_intrp .ge. x(n)) then
        j = n
        y_intrp = y(n)
        return
      end if          
      
      call locate(x,n,x_intrp,j)
      
      slope = (y(j+1) - y(j))/(x(j+1)-x(j))
      y_intrp = y(j) + slope*(x_intrp - x(j))
      
      return
      end

      subroutine locate(x,n,y,j)
      real x(*)
      jp=2
      dowhile(y.gt.x(jp).and.jp.lt.n)
      jp=jp+1
      enddo
      j=jp-1
      return
      end subroutine locate

      real function sdi_ratio(per,M,rhat,sige,sdi)
      real M,rhat,td,dt,sde,sdi
c inputs:
c per = spectral period per (s)
c rhat= elastic spectral displacement Sd_e/dY. (Sd_e is not input)
c M = moment magnitude
c elastic ln(S_d dispersion), sige
c 
c Outputs:
C compute tothung-cornell spectral displacement ratio, ln(S_di/S_d)
c Also compute the inelastic log st. deviation, sdi
c steve harmsen feb 14 2013.
c Use regression coeffs from table 2.
c The regression coeffs were designed for a specific GMPE Abrahmson Silva(which?)
c but we will use these with any crustal-event GMPE at least WUS...
c Possibly different coeffs may be found for subduction event GMPEs...
        real, dimension(18):: beta1,beta2,beta3,beta4,beta5,beta6, 
     + c1p,c2p,c3p,c4p,ap,bp,T
c special functions g1, g2
        g1(r,xm,b1,b2,b3,b4,b5)=(b1+b2*xm)*r+
     + (b3+b4*xm)*r*alog(r) +b5*r**2.5
         g2(r,b6)=0.37*b6*(r-0.3)
         T=(/ 0.30, 0.40, 0.50, 0.60, 0.70, 0.750, 0.80, 
     + 0.850, 0.90, 1.0, 1.100, 1.250, 1.50, 2.0, 2.50, 3.0, 4.0, 5.0/)
        beta1=(/-0.10370, 0.12260, 0.04490, 0.11160,-0.07590,-0.13070,-0.32330,-0.37980,-0.37910,
     + -0.38000,-0.33240,-0.35820,-0.42440,-0.13040,-0.22750, 0.06930,-0.16920,-0.41700/)
        beta2=(/ 0.01380,-0.01970,-0.00730,-0.02110, 0.00660, 0.01570, 0.04340, 0.05040, 
     + 0.04890, 0.05150, 0.04440, 0.04630, 0.05610, 0.01300, 0.02640,-0.01950, 0.01610, 0.05170/)
        beta3=(/-0.00590,-0.06960,-0.04890,-0.09530,-0.03500,-0.01560, 0.05680, 0.09710, 
     + 0.09130, 0.06600, 0.03780, 0.07960, 0.11250,-0.00420, 0.05370,-0.06030, 0.03480, 0.07880/)
        beta4=(/ 0.01050, 0.01600, 0.01060, 0.01780, 0.00760, 0.00380,-0.00690,-0.01170,
     + -0.01020,-0.00840,-0.00510,-0.01120,-0.01570, 0.00090,-0.00720, 0.01200,-0.00380,-0.01080/)
        beta5=(/-0.00220,-0.00080,-0.00070,-0.00030,-0.00030, 0.00000, 0.00000,-0.00040,
     + -0.00050,-0.00050, 0.00000, 0.00060, 0.00050, 0.00100, 0.00090, 0.00010, 0.00040, 0.00000/)
        beta6=(/-0.07400, 0.01300, 0.01700, 0.03700, 0.05000, 0.03000,-0.02500,-0.05000,
     + -0.05000,-0.06100,-0.05000,-0.02000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000/)
        c1p=(/ 0.00200, 0.00800, 0.00600, 0.00800, 0.00700, 0.00600, 
     + 0.00900, 0.01100, 0.01400, 0.01300, 0.011, 0.012, 0.008, 0.008, 0.008, 0.013, 0.01800, 0.03500/)
        c2p=(/-0.01000,-0.04000,-0.02800,-0.04000,-0.03300,-0.03000,-0.04700,
     + -0.05600,-0.07200,-0.06400,-0.05600,-0.06200,-0.04000,-0.04100,-0.03800,-0.06700,-0.08800,-0.1770/)
        c3p=(/ 0.09600, 0.09500, 0.07500, 0.06500, 0.05900, 0.05600, 0.04800, 
     + 0.03700, 0.04600, 0.07300, 0.07800, 0.03900, 0.02000, 0.04500, 0.05300,
     + 0.08500, 0.09100, 0.16500/)
        c4p=(/-0.07700,-0.04500,-0.03600,-0.01000,-0.01300,-0.01200, 0.01600, 
     + 0.03500, 0.04100, 0.00700,-0.00800, 0.03700, 0.03800, 0.01400,-0.00600,
     + -0.00900,-0.00500, 0.01700/)
         ap=(/0.9,0.7,0.9,1.0,1.8,1.8,1.2,1.2,1.2,1.4,1.8,1.4,1.0,1.4,1.6,
     + 1.2,1.0,0.8/)
         bp=(/3.8,3.8,3.0,2.9,5.0,4.5,2.0,1.8,1.4,3.4,5.0,2.0,2.2,3.5,5.0,
     + 2.0,4.5,5.0/)
c
c find the index corresponding to the requested period 
       i=1
       if(per.le.T(1))then
c first try: do not extrapolate, just use 0.3s coeffs for shorter periods.
         b1=beta1(1); b2=beta2(1); b3=beta3(1)
         b4=beta4(1); b5=beta5(1); b6=beta6(1)
         a=ap(1); b=bp(1); c1 = c1p(1); c2= c2p(1)
         c4=c4p(1); c3=c3p(1)
         goto 3
       endif
         ip=i+1
         dowhile(per.gt.T(ip).and.ip.lt.18)
         ip=ip+1
         enddo
       if(abs(per-T(ip)).lt.0.01)then
c no need to interpolate
        b1=beta1(ip); b2=beta2(ip); b3=beta3(ip)
        b4=beta4(ip); b5=beta5(ip); b6=beta6(ip)
        a=ap(ip); b=bp(ip); c1 = c1p(ip); c2= c2p(ip)
         c4=c4p(ip); c3=c3p(ip)
        elseif(T(ip).lt.per)then
c extrapolate: Need a rule. for now just use 5s coeffs.
        b1=beta1(ip); b2=beta2(ip); b3=beta3(ip)
        b4=beta4(ip); b5=beta5(ip); b6=beta6(ip)
        a=ap(ip); b=bp(ip); c1 = c1p(ip); c2= c2p(ip)
         c4=c4p(ip); c3=c3p(ip)
       else
c interpolate. From meeting Feb 12 2013 try linear interpolation.
      i=ip-1
      dt=(per-T(i))/(T(ip)-T(i))
      td=1.0-dt
      b1=beta1(ip)*dt+beta1(i)*td
      b2=beta2(ip)*dt+beta2(i)*td
      b3=beta3(ip)*dt+beta3(i)*td
      b4=beta4(ip)*dt+beta4(i)*td
      b5=beta5(ip)*dt+beta5(i)*td
      b6=beta6(ip)*dt+beta6(i)*td
      a = ap(ip)*dt+ap(i)*td
      b=  bp(ip)*dt+bp(i)*td
      c1=  c1p(ip)*dt+c1p(i)*td
      c2=  c2p(ip)*dt+c2p(i)*td
      c3=  c3p(ip)*dt+c3p(i)*td
      c4=  c4p(ip)*dt+c4p(i)*td
      endif
3      continue
c      print *,'b1,b2,b3,b4,b5,b6,a,b:'
c      print *,b1,b2,b3,b4,b5,b6,a,b
       if(rhat.lt.0.2)then
        sdi_ratio=0.0
        sdi = sige
        elseif(rhat.lt.0.3)then
        sdi_ratio=g1(rhat,M,b1,b2,b3,b4,b5) - g1(0.2,M,b1,b2,b3,b4,b5)
c because in this interval g2 is zero we don't see it ablove
        elseif(0.3.le. rhat .and. rhat .lt. 3.0)then
        sdi_ratio=g1(rhat,M,b1,b2,b3,b4,b5) - g1(0.2,M,b1,b2,b3,b4,b5)+
     +  g2(rhat,b6)*(M-6.5)
        elseif(3.0.le.rhat.and. rhat.le.10.)then
        sdi_ratio=g1(rhat,M,b1,b2,b3,b4,b5) - g1(0.2,M,b1,b2,b3,b4,b5)+
     +  b6*(M-6.5)
        else
        stop' no rule when rhat >100'
        endif
c compute sdi for rhat.ge. 0.2
      if(rhat.ge.0.2)then
        sdi = sige+c1+c2*rhat
c        print *,c3,c4
        if(rhat.gt.a)sdi= sdi + c3*(rhat-a)      
        if(rhat.gt.b)sdi= sdi + c4*(rhat-b)
        endif      
        return
        end     function sdi_ratio   
c------------------------------------------------------------------------------
      SUBROUTINE CB13_NGA_SPEC_IN
c read in the coeffs only. Harmsen Feb 25 2013. Additional coeffs such as phi_low
C     This program computes 5%-damped linear elastic response spectra from the 
C     2012 Campbell-Bozorgnia NGA-West2 Ground Motion Prediction Equation (GMPE)
C
C     It is Based on Campbell-Bozorgnia NGA-West2 Draft Model, November 12, 2012, Rev111
C
C     Written by Yousef Bozorgnia (November 25, 2012)

      parameter (nper=23)
      common /cb13/Phi,Tau,c0,c1,c2low,c2,c3,c4,c5,c6,c7,c8,c9,c10,c10j,c10jlow,c11,c11j,
     + c12,c13low,c13hi,c14,c15,k1,k2,k3,a2,h1,h2,h3,h4,h5,h6,phi_lny,phi_low, phi_hi,
     + tau_lny,tau_lnyB,tau_low,tau_hi,phi_lnAF,rho
       common/cb13p/Per
       real phi_lnyB
      REAL, dimension(nper) ::  Phi, Tau, csoil,nsoil,tau_low,tau_hi
      REAL Per(nper), c0(nper), c1(nper), c2low(nper), c2(nper)
      REAL c3(nper), c4(nper)
      REAL c5(nper), c6(nper), c7(nper), c8(nper), c9(nper)
      REAL c10(nper), c10J(nper), c10Jlow(nper) 
      REAL c11(nper), c11J(nper) 
      REAL, dimension(nper) :: c12, c13low,c13hi, c14,c15,k1, k2, k3,a2,h1,h2,h3
      REAL, dimension(nper) :: h4,h5,h6, phi_low, phi_hi,phi_lny,tau_lny,tau_lnyB
      REAL phi_lnAF(nper), rho(nper)
      character*5 dum1
   
C.....
C.....READ MODEL COEFFICIENTS FROM AN EXCEL FILE (text FORMAT, csv does not work on sun workstation)
C.....
c      if(icase.ne.1) go to 21 
      call get_lun(m)
c updated input file name Feb 25 2013.
c        open (m,file='GR/CB13_Coeffs_Atten113_RE_fix_all_Feb_15_2013.txt',status='old',err=2012)
        open (m,file='GR/CB13_Apr8_coeffs.txt',status='old',err=2012)
c CB coefficient file modified April 8 2013. Same structure. Different values. Also 3 comment lines
c instead of 1.
      print *,'CB coefficient file opened OK unit ',m
      read (m,1) dum1
 1    format(a)
 	print *,dum1
 	read(m,1)dum1
 	print *,dum1
 	read(m,1)dum1
 	print *,dum1	!three lines

      do 20 iper=1,nper
        read (m,*)Per(iper),c0(iper),c1(iper),c2low(iper),c2(iper),c3(iper),
     +c4(iper),c5(iper),c6(iper),c7(iper),c8(iper),c9(iper),
     +c10(iper),c10Jlow(iper),c10J(iper),c11(iper),c11J(iper),c12(iper),
     +c13low(iper),c13hi(iper),c14(iper),
     +c15(iper),a2(iper), h1(iper),h2(iper),h3(iper),h4(iper),h5(iper),h6(iper),
     +k1(iper), k2(iper), k3(iper),
     +csoil(iper), nsoil(iper),
     +phi_low(iper), phi_hi(iper),tau_low(iper), tau_hi(iper), phi_lnAF(iper), sigma_c, rho(iper)
c      print *,'period ',Per(iper)
c      print *,c14(iper),c15(iper),phi_lnAF(iper), rho(iper),'c14(iper),c15(iper),phi_lnAF(iper), rho(iper)'
 20   CONTINUE
c Although read in csoil and nsoil will be real variables in the actual CB_SPEC_IN
       close(m)
       return
2012      print *,'CB coeff file not found ; put in GR/ folder'
      stop
       end SUBROUTINE CB13_NGA_SPEC_IN

c Below version of CY is April 12 2013...Includes option for source directivity response
c but due to lack of guidance on coef. values, this is turned off.
        subroutine CY2013_NGA(ip,iprd,ia,ndist,di,nmag,magmin,dmag,
     *    DELTA,deltaz1,v_s30,rxsign )
c        call CY2013_NGA(ip,iper,ia,ndist,di,nmag,magmin,dmag,DIP,deltaz1,vs30,rxfac )
c        (ip,iprd, M, R_Rup, R_JB, R_x, V_S30,
c     1                   F_Measured, F_Inferred, deltaZ1, DELTA, Z_TOR,
c     1                   F_RV, F_NM, cDPP, gndout, tau, sigma_NL0, sigmaf)

c        implicit none
        integer nprd, ip, ia, nmag
        real pi,d2r,sqrt2, dp2, plim
      real sigmaf,sigma_fx,magmin,dmag,di,rxsign,wtss,tmp
c added MPM 20130320
        integer ndist
c        real magmin, dmag, rxsign
        real gnd_ep(3,3,8),mcut(2),dcut(2),gndout(3),gndx
      real, dimension(25005):: p
       real, dimension (310,38,20,8,3,3):: pr
       real, dimension(20,8):: xlev
       real, dimension(3):: dtor,wtor,wtor65
       integer nlev(8),icode(8,10),nfi,ntor
       real wt(8,10,2),wtdist(8,10), fac
       real, dimension(0:9) :: rxfac
      logical e_wind(8),fix_sigma
      integer ide,ime,ie,ipr,ii,jj,kk,k
      logical direct/.false./
        real PERIOD, M,  R_rup, R_JB, R_x, V_S30, F_Measured,weight,
     1       F_Inferred, Z1, DELTA, Z_TOR, F_RV, F_NM, deltaZ1, cDPP
        real cc, gamma, cosDELTA, psa, psa_ref, NL0, tau, sigma_NL0,
     1       total_app
        real r1, r2, r3, r4, fw, hw, fd, a, b, c, rkdepth
        integer iprd, sa
        parameter (nprd=22,pi=3.14159265,d2r=17.45329252e-3,sqrt2=1.414213562)
c nprd drops from 24 to 22 in april update because PGD and PGV were eliminated this time.
c ip =global period index
c iper =local period index
c ia =attenuation model index
c Predictor variables
c cDPP = source directivity parameter. Need guidance on what to use Mar 6 2013.
c ip = global period index
c iprd = local period index corresponding to below coeff. vectors.
c rxsign = instruction to put all sites on footwall if <0, on hangingwall side if >0.
c  F_Inferred   Enter 1 if Vs30 is inferred, 0 if measured
c  Z1           Depth to Vs = 1 km/sec (m), enter -999 for default
c  R_Rup        Distance to rupture plane (km)
c  R_JB         Joyner-Boore distance (km)
c  R_x          Normal distance to strike of fault (km), negative on footwall

c Model cofficients
        real prd(nprd),
     1       c1(nprd), c1a(nprd), c1b(nprd), c2(nprd),
     1       c3(nprd), cn(nprd),  cM(nprd),  c4(nprd),
     1       c4a(nprd),cRB(nprd), c5(nprd),  c6(nprd),
     1       cHM(nprd),c7(nprd),  c8(nprd),  c8a(nprd), c8b(nprd),
     1       c9(nprd),  c9a(nprd), c9b(nprd),c11(nprd),
     1       cgamma1(nprd), cgamma2(nprd), cgamma3(nprd),
     1       phi1(nprd), phi2(nprd), phi3(nprd), phi4(nprd),
     1       phi5(nprd), phi6(nprd), phi7(nprd), phi8(nprd),
     1       tau1(nprd), tau2(nprd),
     1       sigma1(nprd), sigma2(nprd), sigma3(nprd)

c common
      common/mech/wtss,F_RV, F_NM
       common/prob/p,plim,dp2   !table of complementary normal probab
       common / atten / pr, xlev, nlev, icode, wt, wtdist
c lines from hazgrid. table production
      common/depth_rup/ntor,dtor,wtor,wtor65
      common/epistemic/nfi,e_wind,gnd_ep,mcut,dcut
       common/fix_sigma/fix_sigma,sigma_fx
c new CY coeff set April 12 2013.
      data prd     /  0.0100, 0.0200, 0.0300, 0.0400, 0.0500,
     1                0.0750, 0.1000, 0.1500, 0.2000, 0.2500,
     1                0.3000, 0.4000, 0.5000, 0.7500, 1.0000,
     1                1.5000, 2.0000, 3.0000, 4.0000, 5.0000,
     1                7.5000,10.0000/

      data c1      / -1.3119, -1.2726, -1.1569, -0.9957, -0.8557,
     1               -0.5871, -0.4488, -0.4579, -0.5738, -0.7995,
     1               -0.9570, -1.3232, -1.6170, -2.0822, -2.3840,
     1               -2.8623, -3.0783, -3.4024, -3.5170, -3.5724,
     1               -3.6675, -4.1080/

      data c1a     /  0.1000,  0.1000,  0.1000,  0.1000,  0.1000,
     1                0.1000,  0.1000,  0.1000,  0.1000,  0.0999,
     1                0.0999,  0.0997,  0.0991,  0.0936,  0.0766,
     1               -0.0154, -0.0591, -0.0931, -0.0982, -0.0994,
     1               -0.0999, -0.1000/

      data c1b     / -0.2550,-0.2550,-0.2550,-0.2550,-0.2550,
     1               -0.2540,-0.2530,-0.2500,-0.2449,-0.2382,
     1               -0.2313,-0.2146,-0.1972,-0.1620,-0.1400,
     1               -0.1184,-0.1100,-0.1040,-0.1020,-0.1010,
     1               -0.1010,-0.1000/

      data c2 /      1.06,1.06,1.06,1.06,1.06,
     1               1.06,1.06,1.06,1.06,1.06,
     1               1.06,1.06,1.06,1.06,1.06,
     1               1.06,1.06,1.06,1.06,1.06,
     1               1.06,1.06/

      data c3 /      1.9710, 1.9625, 1.9104, 1.8649, 1.8480,
     1               1.8577, 1.9284, 2.0672, 2.1372, 2.2284,
     1               2.2874, 2.4321, 2.5498, 2.7000, 2.8071,
     1               2.8822, 2.8769, 2.8415, 2.8394, 2.8414,
     1               2.7647, 2.8853/

      data cn /      3.5225, 3.5243, 3.5170, 3.5027, 3.4993,
     1               3.5882, 3.8521, 4.7683, 5.1549, 5.3422,
     1               5.2761, 4.9076, 4.3065, 2.9979, 2.3976,
     1               1.9792, 1.8683, 1.6218, 1.5067, 1.4826,
     1               1.4953, 1.4933/

      data cM /      5.4931, 5.5070, 5.5648, 5.6095, 5.6157,
     1               5.5619, 5.5017, 5.4197, 5.3976, 5.3859,
     1               5.3778, 5.3452, 5.3318, 5.4584, 5.5616,
     1               5.8153, 5.9613, 6.2606, 6.5014, 6.6433,
     1               7.1801, 6.9695/


      data c4 /      -2.1,-2.1,-2.1,-2.1,-2.1,
     1               -2.1,-2.1,-2.1,-2.1,-2.1,
     1               -2.1,-2.1,-2.1,-2.1,-2.1,
     1               -2.1,-2.1,-2.1,-2.1,-2.1,
     1               -2.1,-2.1/

      data c4a/      -0.5,-0.5,-0.5,-0.5,-0.5,
     1               -0.5,-0.5,-0.5,-0.5,-0.5,
     1               -0.5,-0.5,-0.5,-0.5,-0.5,
     1               -0.5,-0.5,-0.5,-0.5,-0.5,
     1               -0.5,-0.5/

      data cRB/      50,50,50,50,50,
     1               50,50,50,50,50,
     1               50,50,50,50,50,
     1               50,50,50,50,50,
     1               50,50/

      data c5/       7.6076, 7.6051, 7.6004, 7.5962, 7.5880,
     1               7.5582, 7.5150, 7.3348, 7.2493, 7.0758,
     1               6.9811, 6.7921, 6.6726, 6.5332, 6.4813,
     1               6.4494, 6.4342, 6.4269, 6.4245, 6.4232,
     1               6.4220, 6.4220/

      data c6/       0.4893, 0.4892, 0.4890, 0.4888, 0.4884,
     1               0.4872, 0.4854, 0.4787, 0.4755, 0.4697,
     1               0.4665, 0.4607, 0.4571, 0.4531, 0.4517,
     1               0.4508, 0.4504, 0.4501, 0.4501, 0.4500,
     1               0.4500, 0.4500/

      data cHM/      3.454,3.454,3.454,3.454,3.454,
     1               3.454,3.454,3.454,3.454,3.454,
     1               3.454,3.454,3.454,3.454,3.454,
     1               3.454,3.454,3.454,3.454,3.454,
     1               3.454,3.454/

      data c7/       0.0848, 0.0868, 0.0930, 0.0984, 0.1015,
     1               0.0971, 0.0875, 0.0665, 0.0565, 0.0443,
     1               0.0376, 0.0267, 0.0206, 0.0148, 0.0124,
     1               0.0078, 0.0056, 0.0025, 0.0011, 0.0005,
     1               0.0000, 0.0000/

      data c8/       0.2154,0.2154,0.2154,0.2154,0.2154,
     1               0.2154,0.2154,0.2154,0.2154,0.2154,
     1               0.2154,0.2154,0.2154,0.2154,0.2154,
     1               0.2154,0.2154,0.2154,0.2154,0.2154,
     1               0.2154,0.2154/

      data c8a/      0.2695,0.2695,0.2695,0.2695,0.2695,
     1               0.2695,0.2695,0.2695,0.2695,0.2695,
     1               0.2695,0.2695,0.2695,0.2695,0.2695,
     1               0.2695,0.2695,0.2695,0.2695,0.2695,
     1               0.2695,0.2695/

      data c8b/      0.4833, 1.2144, 1.6064, 1.9456, 2.1810,
     1               2.6087, 2.9122, 3.4080, 3.6434, 3.9201,
     1               4.0711, 4.3745, 4.6099, 5.0376, 5.3411,
     1               5.8369, 6.0723, 6.5000, 6.8035, 7.0389,
     1               7.4666, 7.7700/

      data c9/       0.9228, 0.9296, 0.9492, 0.9661, 0.9794,
     1               1.0260, 1.0177, 0.9690, 0.9459, 0.9051,
     1               0.8829, 0.8302, 0.7884, 0.6754, 0.6196,
     1               0.4651, 0.3917, 0.1244, 0.0086, 0.0000,
     1               0.0000, 0.0000/

      data c9a/      0.1202, 0.1217, 0.1190, 0.1166, 0.1176,
     1               0.1171, 0.1146, 0.1188, 0.1208, 0.1187,
     1               0.1175, 0.1060, 0.1061, 0.1000, 0.1000,
     1               0.1000, 0.1000, 0.1000, 0.1000, 0.1000,
     1               0.1000, 0.1000/

      data c9b/      6.8607, 6.8697, 6.9541, 7.0271, 7.0959,
     1               7.3298, 7.2588, 7.2859, 7.2988, 7.0271,
     1               6.8789, 6.5334, 6.5260, 6.5000, 6.5000,
     1               6.5000, 6.5000, 6.5000, 6.5000, 6.5000,
     1               6.5000, 6.5000/

      data c11/      0.0129, 0.0131, 0.0137, 0.0143, 0.0146,
     1               0.0147, 0.0136, 0.0106, 0.0092, 0.0078,
     1               0.0071, 0.0059, 0.0051, 0.0037, 0.0028,
     1               0.0015, 0.0009, 0.0002, 0.0000, 0.0000,
     1               0.0000, 0.0000/

      data cgamma1/  -0.006958,-0.006968,-0.007257,-0.007506,-0.007883,
     1               -0.008875,-0.009479,-0.009455,-0.009444,-0.008654,
     1               -0.008224,-0.007219,-0.006493,-0.005209,-0.004372,
     1               -0.003271,-0.002748,-0.002199,-0.001943,-0.001839,
     1               -0.001712,-0.001624/

      data cgamma2/  -0.008572,-0.008867,-0.009468,-0.009988,-0.010026,
     1               -0.008662,-0.006957,-0.005075,-0.004181,-0.003898,
     1               -0.003743,-0.003524,-0.003319,-0.003092,-0.003190,
     1               -0.003974,-0.004346,-0.004828,-0.004955,-0.004964,
     1               -0.004936,-0.004922/

      data cgamma3/  4.1293, 4.0715, 4.0142, 3.9647, 3.9832,
     1               4.1949, 4.4844, 4.7524, 4.8796, 4.8009,
     1               4.7579, 4.5523, 4.4049, 4.2079, 4.0126,
     1               3.6700, 3.5073, 3.4748, 3.5179, 3.5479,
     1               3.5954, 3.6253/

      data phi1/     -0.5771, -0.5543, -0.4989, -0.4510, -0.4266,
     1               -0.4332, -0.4782, -0.6213, -0.6893, -0.7851,
     1               -0.8373, -0.9283, -0.9854, -1.0547, -1.0864,
     1               -1.1050, -1.1138, -1.1095, -1.0628, -1.0098,
     1               -0.8703, -0.7451/

      data phi2/     -0.1417, -0.1364, -0.1486, -0.1591, -0.1862,
     1               -0.2538, -0.2943, -0.2932, -0.2927, -0.2589,
     1               -0.2405, -0.1975, -0.1633, -0.1028, -0.0699,
     1               -0.0430, -0.0302, -0.0129, -0.0016,  0.0000,
     1                0.0000,  0.0000/

      data phi3/     -0.007010,-0.007279,-0.007116,-0.006977,-0.006467,
     1               -0.005734,-0.005604,-0.005963,-0.006141,-0.006500,
     1               -0.006704,-0.007125,-0.007435,-0.008120,-0.008444,
     1               -0.005751,-0.004792,-0.001828,-0.001523,-0.001440,
     1               -0.001369,-0.001361/

      data phi4/     0.102151, 0.108360, 0.121251, 0.133641, 0.148927,
     1               0.190596, 0.230662, 0.247063, 0.255253, 0.223081,
     1               0.207277, 0.165464, 0.133828, 0.085153, 0.058595,
     1               0.027997, 0.019716, 0.009643, 0.005379, 0.003223,
     1               0.001134, 0.000515/

      data phi5/       0.0000, 0.0000, 0.0000, 0.0000, 0.0000,
     1                 0.0000, 0.0000, 0.0000, 0.0000, 0.0006,
     1                 0.0010, 0.0040, 0.0100, 0.0340, 0.0670,
     1                 0.1592, 0.2030, 0.2770, 0.3090, 0.3210,
     1                 0.3290, 0.3300/

      data phi6/      300.00,  300.00,  300.00,  300.00,  300.00,
     1                300.00,  300.00,  300.00,  300.00,  300.00,
     1                300.00,  300.00,  300.00,  300.00,  300.00,
     1                300.00,  300.00,  300.00,  300.00,  300.00,
     1                300.00,  300.00/

      data phi7/       00.00,   00.00,   00.00,   00.00,   00.00,
     1                 00.00,   00.00,   00.00,   00.00,   00.00,
     1                 00.00,   00.00,   00.00,   00.00,   00.00,
     1                 00.00,   00.00,   00.00,   00.00,   00.00,
     1                 00.00,   00.00/

      data phi8/     4000.00, 4000.00, 4000.00, 4000.00, 4000.00,
     1               4000.00, 4000.00, 4000.00, 4000.00, 4000.00,
     1               4000.00, 4000.00, 4000.00, 4000.00, 4000.00,
     1               4000.00, 4000.00, 4000.00, 4000.00, 4000.00,
     1               4000.00, 4000.00/

      data tau1/     0.3437,0.3471,0.3603,0.3718,0.3848,
     1               0.3878,0.3835,0.3719,0.3601,0.3522,
     1               0.3438,0.3351,0.3353,0.3429,0.3577,
     1               0.3769,0.4023,0.4406,0.4784,0.5074,
     1               0.5328,0.5542/

      data tau2/     0.2637,0.2671,0.2803,0.2918,0.3048,
     1               0.3129,0.3152,0.3128,0.3076,0.3047,
     1               0.3005,0.2984,0.3036,0.3205,0.3419,
     1               0.3703,0.4023,0.4406,0.4784,0.5074,
     1               0.5328,0.5542/

      data sigma1/   0.4458,0.4458,0.4535,0.4589,0.4630,
     1               0.4702,0.4747,0.4798,0.4816,0.4815,
     1               0.4801,0.4758,0.4710,0.4621,0.4581,
     1               0.4493,0.4459,0.4433,0.4424,0.4420,
     1               0.4416,0.4414/

      data sigma2/   0.3459,0.3459,0.3537,0.3592,0.3635,
     1               0.3713,0.3769,0.3847,0.3902,0.3946,
     1               0.3981,0.4036,0.4079,0.4157,0.4213,
     1               0.4213,0.4213,0.4213,0.4213,0.4213,
     1               0.4213,0.4213/

      data sigma3/   0.8000,0.8000,0.8000,0.8000,0.8000,
     1               0.8000,0.8000,0.8000,0.8000,0.7999,
     1               0.7997,0.7988,0.7966,0.7792,0.7504,
     1               0.7136,0.7035,0.7006,0.7001,0.7000,
     1               0.7000,0.7000/

c        pi = atan(1.0)*4.0
c        d2r = pi/180.0
      F_measured=1.0
      F_inferred=0.0	!Chiou recommendation Nov 2012.
      fd=0.0
        cosDELTA = cos(DELTA*d2r)
c Soil effect: linear response
        a = phi1(iprd) * min(log(V_S30/1130.0), 0.0)

c Soil effect: nonlinear response
        b = phi2(iprd) *
     1(exp(phi3(iprd)*(min(V_S30,1130.0)-360.0))-exp(phi3(iprd)*
     *(1130.0-360.0)))

        c = phi4(iprd)

c Corrections to ln(Vs30) scaling
c
c
        rkdepth = phi5(iprd) * ( 1.0 - exp(-deltaZ1/phi6(iprd) ) ) +
     1            phi7(iprd) * ( 1.0 - exp(-deltaZ1/phi8(iprd) ) )


c loop on depth to top of rupture.
       do kk=1,ntor
      Z_tor=dtor(kk)
c loop on magnitude
      M=magmin
      do jj=1,nmag
       if(e_wind(ip))then
          if(M.lt.mcut(1))then
          ime=1
          elseif(M.lt.mcut(2))then
          ime=2
          else
          ime=3
          endif
        endif !extra epistemic

c Magnitude scaling
        cc = c5(iprd)* cosh(c6(iprd) * max(M-cHM(iprd),0.0))
        gamma = cgamma1(iprd) +
     1          cgamma2(iprd)/cosh(max(M-cgamma3(iprd),0.0))
        r1 = c1(iprd) + c2(iprd) * (M-6.0) +
     1       (c2(iprd)-c3(iprd))/cn(iprd) *
     1             log(1.0 + exp(cn(iprd)*(cM(iprd)-M)))

        do ii=1,ndist
        R_JB=di*0.5+float(ii-1)*di
       weight= wt(ip,ia,1)
       if(R_JB.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
      if(e_wind(ip))then
          if(R_JB.lt.dcut(1))then
          ide=1
          elseif(R_JB.lt.dcut(2))then
          ide=2
          else
          ide=3
          endif
          gndx=gnd_ep(ide,ime,ip)
          endif

        R_Rup = sqrt(R_JB**2+dtor(kk)**2)
        R_x = rxsign*(R_JB+rxfac(icode(ip,ia)))      !same test model as in CB12. Needs work.
c Near-field magnitude and distance scaling
        r2 = c4(iprd) * log(R_Rup + cc)

c Far-field distance scaling
        r3 = (c4a(iprd)-c4(iprd)) *
     1            log(sqrt(R_Rup*R_Rup+cRB(iprd)*cRB(iprd))) +
     1       R_Rup * gamma

c Scaling with other source variables (F_RV, F_NM, and Z_TOR)
        r4 = c1a(iprd)*F_RV +
     1       c1b(iprd)*F_NM +
     1       c7(iprd)*(Z_TOR - 4)
        if (M .lt. 6.0) r4 = r4 + c11(iprd)*min(DELTA-70.0,0.0)

c HW effect
        if (R_x .lt. 0) then
         hw = 0.0
        else
c         hw = c9(iprd) * (cosDELTA**2) * (0.2+0.8*tanh(R_x/c9a(iprd))) *
c     1        (1.0 - sqrt(R_JB**2+Z_TOR**2)/(R_Rup + 0.001))
          hw = c9(iprd) * (cosDELTA) * (c9a(iprd)+(1.-c9a(iprd))
     1        *tanh(R_x/c9b(iprd))) *
     1        (1.0 - sqrt(R_JB**2+Z_TOR**2)/(R_Rup + 1.0))
        endif

c Directivity effect
        if(direct)fd = c8(iprd) * exp(-c8a(iprd) * (M-c8b(iprd))**2) *
     1       max(0.0, 1.0-max(0.0,R_Rup-40.0)/30.0) *
     1       min(max(0.0,M-5.5)/0.8, 1.0) * cDPP

        psa_ref = r1+r2+r3+r4+hw+fd
c        write (*,'(7f10.4)') r1, r2, r3, r4, hw, fd, psa_ref

c....... Polulation mean of ln(psa) (eta=0)

        psa = psa_ref + (a + b * log((exp(psa_ref)+c)/c)) + rkdepth
        psa_ref = exp(psa_ref)
      gndout(1)=psa
         if(e_wind(ip))then
         gndout(2)= psa+gnd_ep(ide,ime,ip)
         gndout(3)= psa-gnd_ep(ide,ime,ip)
         endif
c....... Total variance of ln(psa) about the population mean:
c          The approximate method (Equation 21)
      if(fix_sigma)then
      sigmaf = 1./sqrt2/sigma_fx
      else

        NL0 = b * psa_ref/(psa_ref+c)

        tau = tau1(iprd) +
     1            (tau2(iprd)-tau1(iprd))/2*(min(max(M,5.),7.)-5.)

        sigma_NL0 = sigma1(iprd) +
     1              (sigma2(iprd)-sigma1(iprd))/2*(min(max(M,5.),7.)-5.)

        sigma_NL0 = sigma_NL0 *
     1        sqrt(0.7*F_Measured+F_Inferred*sigma3(iprd)+(1.0+NL0)**2)

        total_app = sqrt((tau*(1.0+NL0))**2+sigma_NL0**2)
        sigmaf=1./sqrt2/total_app
        endif      !fix sigma at command-line value?
      do ie=1,nfi
      do 199 k=1,nlev(ip)
      tmp= (gndout(ie) - xlev(k,ip))*sigmaf
        if(tmp.gt.3.3)then
       ipr=25002
       elseif(tmp.gt.plim)then
       ipr= 1+nint(dp2*(tmp-plim))	!3sigma cutoff n'(mu,sig)
       else
       goto 102	!transfer out if ln(SA) above mu+3sigma
       endif
       fac=weight*p(ipr)
 199  pr(ii,jj,k,ip,kk,ie)= pr(ii,jj,k,ip,kk,ie)+ fac !sum thru ia index
  102 continue
      enddo !ie loop (extra epistemic)
      enddo	!distance loop
      M= M+dmag
      enddo	!mag loop
      enddo	!depth of top of rupture loop

        return

        end subroutine CY2013_NGA

      subroutine bssa2013drv( ip,indx_per, ia,ndist,di,nmag,magmin,
     * dmag,v30,z1ref)
      parameter (npermx=107, sqrt2 = 1.414213562)
      real, dimension(3)::  c,gndout
c this driver code runs the NGAW BSSA model for PGA and then for period with index indx_per
c the outputs are lny = logged SA, and sigmaf =1/sigma/sqrt2 
c currently the California - Global deltac3 is hardwired but the China and Italy-Japan versions are
c available in coeffs below. SHarmsen.
c ip is the global period index, used in SDI calcs for example. 
c indx_per is the local  period index. Apr 11 2013: now 107 periods in latest update. 
c Inelastic spectral displacement option added. Option if logical varible sdi is "true"
c The method of Tothong and Cornell is used. See common block /sdi/ where dy_sdi is brought in.
c v30 = vs30 (m/s) input.
      real e(0:6)
      
      real, dimension(npermx):: T,clin, vclin, vref,
     :     c1,c2,c3,phi2, phi3,e0,e1,e2,e3,e4,e5,e6,
     :     f1, f3, f4, f5, h, Dc3CATW,Dc3China,Dc3Italy,
     :     lambda1, lambda2,Mref,Rref,Rjb_bar,delta_c3,
     :     tau1, tau2,delta_phiR, delta_phiV, Mh
     
      
      real m, logy_pred, rjb, z1
      real lny, gnd,z1ref
c z1ref is the reference depth where Vs is 1 km/s. Units km. Included apr 12 but so far
c not clear how to use. Boore says he is working on the basin term. Not ready but OK for BC rock
c      
      integer mech, iregion,ip
 

      real r, r_pga4nl
      
      real :: sigt, 
     :  fs, fsb,
     :  fp, fpb,
     :  fe,
     :  amp_total, 
     :  amp_nl, 
     :  amp_lin, 
     :  fp_pga4nl, fpb_pga4nl,
     :  fe_pga4nl,
     :  gspread_pga4nl,
     :  pga4nl, 
     :  per1, 
     :  per2,
     :  per_max, 
     :  sigt_dummy, 
     :  v30, 
     :  slope_logy, 
     :  slope_phi, 
     :  slope_tau, 
     :  slope_sigma, 
     :  phi, tau, sigmaf,
     :  yg, 
     :  ycgs,
     :  pi, twopi,
     :  gspread,
     :  weight

      real :: 
     :  r_t1,
     :  y_t1,
     :  fsb_t1, 
     :  fs_t1, 
     :  fpb_t1,
     :  fp_t1,
     :  fe_t1,
     :  amp_total_t1, 
     :  amp_nl_t1, 
     :  amp_lin_t1, 
     :  phi_t1, tau_t1, sigma_t1,
     :  gspread_t1
     
      real :: 
     :  r_t2,
     :  y_t2,
     :  fsb_t2, 
     :  fs_t2, 
     :  fpb_t2,
     :  fp_t2,
     :  fe_t2,
     :  amp_total_t2, 
     :  amp_nl_t2, 
     :  amp_lin_t2, 
     :  phi_t2, tau_t2, sigma_t2,
     :  gspread_t2
     
c lines from hazgrid. table production
      common/mech/wtss,wtrev,wtnm
      common/fix_sigma/fix_sigma,sigma_fx
      common/prob/p,plim,dp2   !table of complementary normal probab
      common / atten / pr, xlev, nlev, icode, wt, wtdist
c lines from hazgrid. table production
c add SDI-related common block sdi feb 22 2013
       common/sdi/sdi,dy_sdi,fac_sde
       real, dimension(8) :: fac_sde
      common/depth_rup/ntor,dtor,wtor,wtor65
      common/epistemic/nfi,e_wind,gnd_ep,mcut,dcut
      real gnd_ep(3,3,8),mcut(2),dcut(2),gndx,plim,dp2
      real, dimension(25005):: p
      real, dimension (310,38,20,8,3,3):: pr
      real, dimension(20,8):: xlev
      real, dimension(3):: dtor,wtor,wtor65
      integer nlev(8),icode(8,10),ntor,nmag,ndist
      real wt(8,10,2),wtdist(8,10),fac,tmp,wtss,wtrev,wtnm
      real di,magmin,dmag,sigma_fx
      logical fix_sigma,e_wind(8), sdi
	T  =(/-1.000000, 0.000000, 0.010000, 0.020000, 0.022000, 0.025000, 0.029000,
     + 0.030000, 0.032000, 0.035000, 0.036000, 0.040000, 0.042000, 0.044000, 0.045000, 0.046000, 0.048000,
     + 0.050000, 0.055000, 0.060000, 0.065000, 0.067000, 0.070000, 0.075000, 0.080000, 0.085000, 0.090000,
     + 0.095000, 0.100000, 0.110000, 0.120000, 0.130000, 0.133000, 0.140000, 0.150000, 0.160000, 0.170000,
     + 0.180000, 0.190000, 0.200000, 0.220000, 0.240000, 0.250000, 0.260000, 0.280000, 0.290000, 0.300000,
     + 0.320000, 0.340000, 0.350000, 0.360000, 0.380000, 0.400000, 0.420000, 0.440000, 0.450000, 0.460000,
     + 0.480000, 0.500000, 0.550000, 0.600000, 0.650000, 0.667000, 0.700000, 0.750000, 0.800000, 0.850000,
     + 0.900000, 0.950000, 1.000000, 1.100000, 1.200000, 1.300000, 1.400000, 1.500000, 1.600000, 1.700000,
     + 1.800000, 1.900000, 2.000000, 2.200000, 2.400000, 2.500000, 2.600000, 2.800000, 3.000000, 3.200000,
     + 3.400000, 3.500000, 3.600000, 3.800000, 4.000000, 4.200000, 4.400000, 4.600000, 4.800000, 5.000000,
     + 5.500000, 6.000000, 6.500000, 7.000000, 7.500000, 8.000000, 8.500000, 9.000000, 9.500000,10.000000/)
	e0      =(/ 5.037000, 0.447300, 0.453400, 0.485980, 0.498660, 0.522830, 0.559490,
     + 0.569160, 0.588020, 0.616360, 0.625540, 0.662810, 0.680870, 0.698820, 0.708220, 0.717790, 0.735740,
     + 0.754360, 0.799600, 0.843940, 0.886550, 0.902700, 0.926520, 0.964470, 1.000300, 1.034000, 1.066600,
     + 1.098100, 1.126800, 1.178500, 1.223000, 1.259600, 1.269200, 1.288300, 1.309500, 1.323500, 1.330600,
     + 1.332700, 1.330700, 1.325500, 1.309100, 1.288100, 1.276600, 1.265100, 1.242900, 1.232400, 1.221700,
     + 1.200700, 1.179000, 1.167400, 1.155800, 1.130500, 1.104600, 1.078200, 1.051500, 1.037600, 1.023400,
     + 0.997190, 0.969910, 0.904800, 0.841650, 0.781810, 0.762620, 0.725130, 0.669030, 0.613460, 0.558530,
     + 0.502960, 0.447010, 0.393200, 0.284840, 0.173400, 0.061520,-0.045750,-0.149540,-0.248600,-0.341450,
     + -0.429750,-0.512760,-0.586690,-0.721430,-0.848100,-0.909660,-0.968630,-1.081700,-1.189800,-1.291400,
     + -1.386000,-1.433200,-1.476200,-1.561700,-1.638800,-1.711600,-1.779800,-1.846900,-1.906300,-1.966000,
     + -2.105100,-2.242100,-2.368600,-2.482700,-2.586500,-2.686100,-2.782000,-2.879200,-2.976900,-3.070200/)
	e1      =(/ 5.078000, 0.485600, 0.491600, 0.523590, 0.536470, 0.561300, 0.599230,
     + 0.609200, 0.628750, 0.658180, 0.667720, 0.706040, 0.724430, 0.742770, 0.752320, 0.762020, 0.780150,
     + 0.799050, 0.844500, 0.888840, 0.931160, 0.947110, 0.970570, 1.007700, 1.042600, 1.075500, 1.107600,
     + 1.138500, 1.166900, 1.217900, 1.262100, 1.298600, 1.308200, 1.327000, 1.348100, 1.361500, 1.367900,
     + 1.368900, 1.365600, 1.359000, 1.339400, 1.315000, 1.301700, 1.288600, 1.263500, 1.251700, 1.240100,
     + 1.217700, 1.195500, 1.183600, 1.172000, 1.146800, 1.121400, 1.095500, 1.069700, 1.056200, 1.042600,
     + 1.017200, 0.991060, 0.928300, 0.867150, 0.808760, 0.789940, 0.753020, 0.697370, 0.641960, 0.586980,
     + 0.531360, 0.475410, 0.421800, 0.313740, 0.202590, 0.091060,-0.015700,-0.118660,-0.216720,-0.308400,
     + -0.395580,-0.477310,-0.550030,-0.682200,-0.806900,-0.867650,-0.925770,-1.036700,-1.142000,-1.240600,
     + -1.332200,-1.377800,-1.419300,-1.501400,-1.574800,-1.643900,-1.708900,-1.773100,-1.830300,-1.888200,
     + -2.023200,-2.156300,-2.278500,-2.388100,-2.487400,-2.582900,-2.675200,-2.768700,-2.863400,-2.953700/)
	e2      =(/ 4.849000, 0.245900, 0.251900, 0.297070, 0.313470, 0.344260, 0.391460,
     + 0.403910, 0.427880, 0.462520, 0.473380, 0.515320, 0.534450, 0.552820, 0.562220, 0.571660, 0.588880,
     + 0.606520, 0.647700, 0.685620, 0.719410, 0.731710, 0.749400, 0.776780, 0.801610, 0.824230, 0.845910,
     + 0.867030, 0.887100, 0.927020, 0.966160, 1.003100, 1.013500, 1.036000, 1.064800, 1.087600, 1.104000,
     + 1.114900, 1.120800, 1.122000, 1.113300, 1.094500, 1.082800, 1.071000, 1.047600, 1.036300, 1.024600,
     + 1.001100, 0.976770, 0.963800, 0.951200, 0.924400, 0.897650, 0.870670, 0.843550, 0.829410, 0.815090,
     + 0.788600, 0.761500, 0.698400, 0.638750, 0.582310, 0.564220, 0.528780, 0.475230, 0.421730, 0.368130,
     + 0.313760, 0.259190, 0.207000, 0.101820,-0.006200,-0.113450,-0.215500,-0.313800,-0.406820,-0.492950,
     + -0.573880,-0.648990,-0.714660,-0.830030,-0.932600,-0.982280,-1.031300,-1.130100,-1.230000,-1.325500,
     + -1.415000,-1.459900,-1.501400,-1.586500,-1.667300,-1.745100,-1.819200,-1.892300,-1.957300,-2.024500,
     + -2.190800,-2.365900,-2.532200,-2.681800,-2.817600,-2.943800,-3.059700,-3.171300,-3.278500,-3.377600/)
	e3      =(/ 5.033000, 0.453900, 0.459900, 0.488750, 0.499730, 0.519990, 0.549950,
     + 0.557830, 0.573300, 0.597040, 0.604960, 0.638280, 0.655050, 0.672250, 0.681390, 0.690760, 0.708540,
     + 0.727260, 0.773700, 0.820670, 0.867240, 0.885260, 0.912270, 0.956300, 0.998180, 1.037900, 1.076200,
     + 1.112700, 1.145400, 1.203000, 1.250200, 1.286900, 1.296100, 1.313700, 1.332400, 1.343700, 1.348700,
     + 1.349200, 1.346300, 1.341400, 1.328100, 1.313200, 1.305200, 1.297200, 1.281500, 1.273600, 1.265300,
     + 1.247900, 1.228600, 1.217700, 1.206600, 1.181600, 1.155200, 1.127600, 1.099500, 1.084700, 1.069600,
     + 1.041500, 1.012000, 0.941700, 0.873510, 0.809480, 0.789160, 0.749850, 0.691730, 0.635190, 0.579690,
     + 0.523610, 0.467060, 0.412400, 0.302090, 0.188660, 0.074330,-0.036070,-0.143700,-0.247080,-0.344650,
     + -0.438180,-0.526820,-0.606580,-0.754020,-0.894100,-0.961870,-1.026600,-1.149500,-1.266400,-1.376000,
     + -1.478600,-1.529700,-1.576400,-1.668500,-1.751600,-1.829000,-1.901100,-1.971200,-2.032600,-2.092800,
     + -2.228800,-2.357900,-2.477000,-2.585400,-2.685400,-2.782300,-2.877600,-2.975900,-3.076000,-3.172600/)
	e4      =(/ 1.073000, 1.431000, 1.421000, 1.433100, 1.433600, 1.432800, 1.427900,
     + 1.426100, 1.422700, 1.417400, 1.415800, 1.409000, 1.405900, 1.403300, 1.402100, 1.400900, 1.399100,
     + 1.397400, 1.394700, 1.395400, 1.400400, 1.403200, 1.408200, 1.417400, 1.426100, 1.432200, 1.435000,
     + 1.433900, 1.429300, 1.411000, 1.383100, 1.349700, 1.339500, 1.316200, 1.284400, 1.254100, 1.224400,
     + 1.194100, 1.163500, 1.134900, 1.082300, 1.036600, 1.016600, 0.999320, 0.972820, 0.963480, 0.956760,
     + 0.950040, 0.949560, 0.950770, 0.952780, 0.958990, 0.967660, 0.978620, 0.991440, 0.998760, 1.006400,
     + 1.021500, 1.038400, 1.083300, 1.133600, 1.186100, 1.203500, 1.237500, 1.287100, 1.334100, 1.378000,
     + 1.420800, 1.462300, 1.500400, 1.569000, 1.628200, 1.679400, 1.723900, 1.762200, 1.795500, 1.825900,
     + 1.856400, 1.886800, 1.915200, 1.968100, 2.017000, 2.040600, 2.062800, 2.101400, 2.132300, 2.154500,
     + 2.170400, 2.177500, 2.183400, 2.193800, 2.204000, 2.212300, 2.218100, 2.223000, 2.226800, 2.229900,
     + 2.238900, 2.237700, 2.215000, 2.172000, 2.118700, 2.061300, 2.008400, 1.960500, 1.918900, 1.883700/)
	e5      =(/-0.153600, 0.050530, 0.049320, 0.053388, 0.054888, 0.057529, 0.060,732
     + 0.061444, 0.062806, 0.064559, 0.065028, 0.066183, 0.066438, 0.066663, 0.066774, 0.066891, 0.0,67127
     + 0.067357, 0.067797, 0.068591, 0.070127, 0.070895, 0.072075, 0.073549, 0.073735, 0.071940, 0.068097,
     + 0.062327, 0.055231, 0.037389, 0.016373,-0.005158,-0.011354,-0.024711,-0.042065,-0.057593,-0.071861,
     + -0.085640,-0.098884,-0.110960,-0.133000,-0.152990,-0.162130,-0.170410,-0.184630,-0.190570,-0.195900,
     + -0.204540,-0.211340,-0.214460,-0.217160,-0.222140,-0.226080,-0.229240,-0.231660,-0.232630,-0.233500,
     + -0.234640,-0.235220,-0.234490,-0.231280,-0.226660,-0.224970,-0.221430,-0.215910,-0.210470,-0.205280,
     + -0.200110,-0.194900,-0.189830,-0.180010,-0.170900,-0.162330,-0.154130,-0.146700,-0.139970,-0.133610,
     + -0.126860,-0.119590,-0.112370,-0.098017,-0.083765,-0.076308,-0.068925,-0.055229,-0.043320,-0.034440,
     + -0.027889,-0.024997,-0.022575,-0.018362,-0.014642,-0.012248,-0.011459,-0.011760,-0.012879,-0.014855,
     + -0.019502,-0.026383,-0.039505,-0.059140,-0.081606,-0.103820,-0.121140,-0.134070,-0.143640,-0.150960/)
	e6      =(/ 0.225200,-0.166200,-0.165900,-0.165610,-0.165200,-0.164990,-0.166320,
     + -0.166900,-0.168130,-0.170150,-0.170830,-0.173570,-0.174850,-0.176190,-0.176930,-0.177690,-0.179200,
     + -0.180820,-0.184800,-0.188580,-0.191760,-0.192910,-0.194510,-0.196650,-0.198160,-0.199020,-0.199290,
     + -0.199000,-0.198380,-0.196010,-0.192650,-0.188980,-0.187920,-0.185660,-0.182340,-0.178530,-0.174210,
     + -0.169390,-0.164040,-0.158520,-0.147040,-0.134450,-0.127840,-0.121150,-0.107140,-0.100110,-0.092860,
     + -0.078920,-0.065130,-0.057920,-0.051040,-0.036760,-0.023190,-0.010420, 0.001170, 0.006590, 0.011870,
     + 0.020770, 0.029120, 0.046930, 0.062670, 0.078000, 0.083060, 0.093190, 0.108290, 0.122560, 0.136080,
     + 0.149830, 0.164320, 0.178950, 0.210420, 0.244100, 0.277990, 0.309560, 0.338960, 0.366160, 0.390650,
     + 0.412440, 0.431510, 0.447880, 0.480240, 0.518730, 0.538830, 0.558100, 0.593940, 0.626940, 0.658110,
     + 0.687550, 0.702160, 0.715230, 0.740280, 0.763030, 0.785520, 0.807920, 0.831260, 0.852400, 0.873140,
     + 0.914660, 0.948700, 0.976430, 0.997570, 1.012100, 1.023200, 1.033500, 1.045300, 1.056700, 1.065100/)
	Mh      =(/   6.2,   5.5,   5.5,   5.5,   5.5,   5.5,   5.5,
     +   5.5,   5.5,   5.5,   5.5,   5.5,   5.5,   5.5,   5.5,   5.5,   5.5,
     +   5.5,   5.5,   5.5,   5.5,   5.5,   5.5,   5.5,   5.5,   5.5,   5.5,
     +   5.5,   5.5,   5.6,   5.6,   5.7,   5.7,   5.7,   5.7,   5.8,   5.8,
     +   5.8,   5.9,   5.9,   6.0,   6.0,   6.1,   6.1,   6.1,   6.1,   6.1,
     +   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,
     +   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,
     +   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,
     +   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,
     +   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,
     +   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,   6.2,   6.2/)
	c1      =(/-1.243000,-1.134000,-1.134000,-1.139400,-1.140500,-1.141900,-1.142300,
     + -1.142100,-1.141200,-1.138800,-1.137800,-1.132400,-1.129200,-1.125900,-1.124200,-1.122400,-1.119200,
     + -1.115900,-1.108200,-1.100900,-1.094200,-1.091800,-1.088400,-1.083100,-1.078500,-1.074500,-1.070900,
     + -1.067800,-1.065200,-1.060700,-1.057200,-1.054900,-1.054500,-1.053700,-1.053200,-1.053300,-1.054100,
     + -1.055600,-1.057900,-1.060700,-1.067000,-1.073700,-1.077300,-1.080800,-1.087900,-1.091300,-1.094800,
     + -1.101300,-1.107400,-1.110500,-1.113300,-1.119000,-1.124300,-1.129100,-1.133700,-1.135900,-1.138100,
     + -1.142000,-1.145900,-1.154300,-1.161500,-1.167600,-1.169400,-1.172800,-1.177700,-1.181900,-1.185400,
     + -1.188400,-1.190900,-1.193000,-1.196600,-1.199600,-1.201800,-1.203900,-1.206300,-1.208600,-1.210600,
     + -1.212300,-1.214100,-1.215900,-1.219000,-1.220200,-1.220100,-1.219800,-1.218900,-1.217900,-1.216900,
     + -1.216000,-1.215600,-1.215600,-1.215800,-1.216200,-1.216500,-1.216900,-1.217500,-1.218200,-1.218900,
     + -1.220400,-1.223200,-1.229900,-1.240800,-1.254300,-1.268800,-1.283900,-1.298900,-1.313000,-1.325300/)
	c2      =(/ 0.148900, 0.191700, 0.191600, 0.189620, 0.189240, 0.188750, 0.188440,
     + 0.188420, 0.188400, 0.188390, 0.188370, 0.188160, 0.187970, 0.187750, 0.187640, 0.187520, 0.187300,
     + 0.187090, 0.186550, 0.185820, 0.184850, 0.184420, 0.183690, 0.182250, 0.180520, 0.178560, 0.176430,
     + 0.174200, 0.172030, 0.167700, 0.163520, 0.159820, 0.158820, 0.156720, 0.154010, 0.151580, 0.149480,
     + 0.147680, 0.146160, 0.144890, 0.142630, 0.140350, 0.139250, 0.138180, 0.136040, 0.134990, 0.133880,
     + 0.131790, 0.129840, 0.128900, 0.128060, 0.126470, 0.125120, 0.123890, 0.122780, 0.122270, 0.121770,
     + 0.120930, 0.120150, 0.118470, 0.116710, 0.114650, 0.113940, 0.112530, 0.110540, 0.108730, 0.107090,
     + 0.105480, 0.103890, 0.102480, 0.100160, 0.098480, 0.097380, 0.096740, 0.096450, 0.096340, 0.096250,
     + 0.096210, 0.096260, 0.096360, 0.096500, 0.096200, 0.096110, 0.096140, 0.096670, 0.097640, 0.098650,
     + 0.099550, 0.099990, 0.100430, 0.101420, 0.102180, 0.102690, 0.103040, 0.103240, 0.103370, 0.103530,
     + 0.104600, 0.107500, 0.112310, 0.118530, 0.125070, 0.131460, 0.137420, 0.142940, 0.147810, 0.151830/)
	c3      =(/-0.003440,-0.008088,-0.008088,-0.008074,-0.008095,-0.008153,-0.008290,
     + -0.008336,-0.008445,-0.008642,-0.008715,-0.009030,-0.009195,-0.009360,-0.009441,-0.009521,-0.009676,
     + -0.009819,-0.010120,-0.010330,-0.010480,-0.010520,-0.010560,-0.010580,-0.010560,-0.010510,-0.010420,
     + -0.010320,-0.010200,-0.009964,-0.009722,-0.009476,-0.009402,-0.009228,-0.008977,-0.008725,-0.008472,
     + -0.008219,-0.007967,-0.007717,-0.007224,-0.006747,-0.006517,-0.006293,-0.005866,-0.005666,-0.005475,
     + -0.005122,-0.004808,-0.004663,-0.004527,-0.004276,-0.004053,-0.003853,-0.003673,-0.003590,-0.003510,
     + -0.003360,-0.003220,-0.002897,-0.002610,-0.002356,-0.002276,-0.002131,-0.001931,-0.001754,-0.001597,
     + -0.001456,-0.001328,-0.001210,-0.000994,-0.000803,-0.000635,-0.000490,-0.000365,-0.000259,-0.000171,
     + -0.000099,-0.000042, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,-0.000023,
     + -0.000040,-0.000045,-0.000049,-0.000053,-0.000052,-0.000047,-0.000039,-0.000027,-0.000014, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000/)
	Mref    =(/   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,
     +   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,
     +   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,
     +   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,
     +   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,
     +   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,
     +   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,
     +   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,
     +   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,
     +   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,
     +   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5,   4.5/)
	Rref    =(/   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,
     +   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,
     +   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,
     +   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,
     +   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,
     +   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,
     +   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,
     +   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,
     +   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,
     +   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,
     +   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0,   1.0/)
	h       =(/ 5.300000, 4.500000, 4.500000, 4.500000, 4.500000, 4.500000, 4.500000,
     + 4.490000, 4.450000, 4.400000, 4.380000, 4.320000, 4.290000, 4.270000, 4.250000, 4.240000, 4.220000,
     + 4.200000, 4.150000, 4.110000, 4.080000, 4.070000, 4.060000, 4.040000, 4.020000, 4.030000, 4.070000,
     + 4.100000, 4.130000, 4.190000, 4.240000, 4.290000, 4.300000, 4.340000, 4.390000, 4.440000, 4.490000,
     + 4.530000, 4.570000, 4.610000, 4.680000, 4.750000, 4.780000, 4.820000, 4.880000, 4.900000, 4.930000,
     + 4.980000, 5.030000, 5.060000, 5.080000, 5.120000, 5.160000, 5.200000, 5.240000, 5.250000, 5.270000,
     + 5.300000, 5.340000, 5.410000, 5.480000, 5.530000, 5.540000, 5.560000, 5.600000, 5.630000, 5.660000,
     + 5.690000, 5.720000, 5.740000, 5.820000, 5.920000, 6.010000, 6.100000, 6.180000, 6.260000, 6.330000,
     + 6.400000, 6.480000, 6.540000, 6.660000, 6.730000, 6.770000, 6.810000, 6.870000, 6.930000, 6.990000,
     + 7.080000, 7.120000, 7.160000, 7.240000, 7.320000, 7.390000, 7.460000, 7.520000, 7.640000, 7.780000,
     + 8.070000, 8.480000, 8.900000, 9.200000, 9.480000, 9.570000, 9.620000, 9.660000, 9.660000, 9.660000/)
	Dc3CATW  =(/ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000/)
	Dc3China =(/ 0.004345, 0.002858, 0.002816, 0.002780, 0.002760, 0.002754, 0.00,2762
     + 0.002765, 0.002769, 0.002784, 0.002801, 0.002822, 0.002846, 0.002874, 0.002900, 0.002923, 0.002944,
     + 0.002957, 0.002964, 0.002968, 0.002968, 0.002968, 0.002964, 0.002957, 0.002945, 0.002930, 0.002914,
     + 0.002897, 0.002879, 0.002863, 0.002846, 0.002831, 0.002816, 0.002802, 0.002786, 0.002765, 0.002734,
     + 0.002699, 0.002660, 0.002612, 0.002560, 0.002505, 0.002444, 0.002380, 0.002314, 0.002250, 0.002196,
     + 0.002155, 0.002124, 0.002104, 0.002097, 0.002098, 0.002107, 0.002127, 0.002160, 0.002202, 0.002250,
     + 0.002298, 0.002348, 0.002399, 0.002452, 0.002508, 0.002568, 0.002629, 0.002690, 0.002746, 0.002797,
     + 0.002843, 0.002885, 0.002921, 0.002954, 0.002982, 0.003007, 0.003026, 0.003039, 0.003041, 0.003026,
     + 0.003000, 0.002968, 0.002923, 0.002870, 0.002815, 0.002761, 0.002708, 0.002658, 0.002616, 0.002588,
     + 0.002575, 0.002572, 0.002573, 0.002586, 0.002605, 0.002619, 0.002624, 0.002622, 0.002615, 0.002604,
     + 0.002591, 0.002583, 0.002586, 0.002603, 0.002600, 0.002630, 0.002670, 0.002760, 0.002890, 0.003030/)
	Dc3Italy =(/-0.000330,-0.002550,-0.002437,-0.002340,-0.002289,-0.002250,-0.00,2215
     + -0.002168,-0.002117,-0.002096,-0.002075,-0.002054,-0.002035,-0.002016,-0.002001,-0.001993,-0.001988,
     + -0.001991,-0.002001,-0.002019,-0.002045,-0.002077,-0.002115,-0.002159,-0.002212,-0.002270,-0.002327,
     + -0.002383,-0.002439,-0.002492,-0.002540,-0.002584,-0.002626,-0.002666,-0.002706,-0.002751,-0.002802,
     + -0.002855,-0.002911,-0.002970,-0.003028,-0.003085,-0.003140,-0.003190,-0.003235,-0.003274,-0.003297,
     + -0.003303,-0.003300,-0.003287,-0.003267,-0.003242,-0.003212,-0.003177,-0.003132,-0.003079,-0.003021,
     + -0.002964,-0.002907,-0.002848,-0.002789,-0.002727,-0.002662,-0.002595,-0.002527,-0.002456,-0.002379,
     + -0.002293,-0.002196,-0.002089,-0.001977,-0.001862,-0.001745,-0.001630,-0.001518,-0.001411,-0.001323,
     + -0.001253,-0.001201,-0.001170,-0.001157,-0.001155,-0.001159,-0.001168,-0.001180,-0.001188,-0.001192,
     + -0.001187,-0.001174,-0.001154,-0.001123,-0.001083,-0.001025,-0.000946,-0.000844,-0.000718,-0.000571,
     + -0.000408,-0.000228,-0.000036, 0.000168, 0.000385, 0.000720, 0.000940, 0.001130, 0.001310, 0.001490/)
	clin    =(/-0.805000,-0.515000,-0.525667,-0.536200,-0.540286,-0.541000,-0.539091,
     + -0.539903,-0.539448,-0.535808,-0.531531,-0.526435,-0.520884,-0.514150,-0.506688,-0.499135,-0.491582,
     + -0.485030,-0.478842,-0.473473,-0.468650,-0.464555,-0.461643,-0.459823,-0.460096,-0.462007,-0.465192,
     + -0.468832,-0.473200,-0.478660,-0.485303,-0.493129,-0.502229,-0.512603,-0.524433,-0.539175,-0.556920,
     + -0.575848,-0.596232,-0.619164,-0.642551,-0.665847,-0.689689,-0.713258,-0.735644,-0.756665,-0.774865,
     + -0.790244,-0.804804,-0.818636,-0.829829,-0.840112,-0.850122,-0.859040,-0.868504,-0.878969,-0.890253,
     + -0.901082,-0.911820,-0.922740,-0.933751,-0.945308,-0.957320,-0.969241,-0.981071,-0.992355,-1.003275,
     + -1.013922,-1.025024,-1.036126,-1.046682,-1.056510,-1.065519,-1.073618,-1.080807,-1.086722,-1.090362,
     + -1.092273,-1.092546,-1.090817,-1.087177,-1.081899,-1.075347,-1.068158,-1.060514,-1.052142,-1.043497,
     + -1.035034,-1.026480,-1.018017,-1.010100,-1.002820,-0.994903,-0.985894,-0.974792,-0.961324,-0.945581,
     + -0.927290,-0.906269,-0.882245,-0.855127,-0.824915,-0.799000,-0.762000,-0.723000,-0.684000,-0.644000/)
	Vclin      =(/1130.0, 836.7, 867.2, 896.1, 908.7, 914.4, 916.7,
     + 925.1, 932.4, 931.1, 929.0, 926.2, 923.3, 920.3, 917.7, 915.9, 914.6,
     + 914.4, 915.5, 918.0, 921.9, 927.2, 934.1, 942.4, 952.8, 964.9, 978.1,
     + 991.6,1005.8,1021.1,1037.9,1056.4,1076.6,1098.2,1121.0,1144.6,1167.6,
     +1189.6,1211.8,1234.7,1256.5,1276.6,1295.5,1312.6,1327.4,1340.4,1351.1,
     +1360.8,1369.7,1377.6,1383.3,1387.6,1390.3,1390.5,1387.2,1381.1,1372.4,
     +1362.4,1350.8,1337.3,1322.3,1306.0,1288.6,1270.6,1252.4,1234.7,1217.9,
     +1202.3,1186.5,1170.8,1155.6,1140.3,1124.8,1108.8,1092.2,1073.9,1055.3,
     +1037.1,1019.3,1001.2, 983.0, 964.7, 946.4, 929.0, 912.6, 896.0, 880.7,
     + 866.1, 851.2, 836.1, 821.7, 808.1, 794.7, 781.9, 769.1, 756.7, 745.9,
     + 737.0, 730.3, 725.6, 723.0, 722.4, 715.0, 712.0, 721.9, 735.4, 750.0/)
	Vref    =(/ 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0,
     + 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0,
     + 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0,
     + 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0,
     + 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0,
     + 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0,
     + 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0,
     + 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0,
     + 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0,
     + 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0,
     + 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0, 760.0/)
	phi2      =(/-0.100000,-0.150000,-0.148330,-0.147100,-0.147740,-0.149590,-0.152490,
     + -0.154850,-0.157440,-0.160660,-0.164070,-0.167770,-0.171530,-0.176000,-0.180990,-0.186190,-0.191460,
     + -0.196330,-0.201400,-0.206600,-0.212040,-0.217640,-0.223200,-0.228660,-0.233690,-0.238200,-0.242130,
     + -0.245830,-0.249160,-0.251890,-0.254040,-0.255600,-0.256630,-0.257130,-0.257130,-0.256200,-0.254440,
     + -0.252220,-0.249690,-0.246580,-0.243210,-0.239650,-0.235740,-0.231550,-0.227350,-0.223190,-0.219120,
     + -0.215200,-0.211170,-0.207030,-0.203270,-0.199590,-0.195820,-0.192230,-0.188360,-0.184040,-0.179330,
     + -0.174860,-0.170410,-0.165790,-0.161010,-0.155840,-0.150300,-0.144570,-0.138660,-0.132520,-0.126190,
     + -0.119670,-0.112590,-0.105210,-0.097740,-0.090230,-0.082730,-0.075280,-0.067940,-0.060420,-0.053390,
     + -0.047050,-0.041350,-0.036140,-0.031400,-0.027070,-0.023110,-0.019590,-0.016460,-0.013580,-0.011230,
     + -0.009270,-0.007460,-0.005790,-0.004390,-0.003210,-0.002290,-0.001610,-0.001040,-0.000560,-0.000250,
     + -0.000100,-0.000050,-0.000040,-0.000050,-0.000050, 0.000100, 0.000100, 0.000100, 0.000100, 0.000000/)
	phi3      =(/-0.008440,-0.007010,-0.007010,-0.007280,-0.007320,-0.007360,-0.007370,
     + -0.007350,-0.007310,-0.007210,-0.007170,-0.006980,-0.006870,-0.006770,-0.006720,-0.006670,-0.006560,
     + -0.006470,-0.006250,-0.006070,-0.005930,-0.005880,-0.005820,-0.005730,-0.005670,-0.005630,-0.005610,
     + -0.005600,-0.005600,-0.005620,-0.005670,-0.005720,-0.005740,-0.005780,-0.005850,-0.005910,-0.005970,
     + -0.006020,-0.006080,-0.006140,-0.006260,-0.006380,-0.006440,-0.006500,-0.006600,-0.006650,-0.006700,
     + -0.006800,-0.006890,-0.006930,-0.006970,-0.007050,-0.007130,-0.007190,-0.007260,-0.007290,-0.007320,
     + -0.007380,-0.007440,-0.007580,-0.007730,-0.007870,-0.007920,-0.008000,-0.008120,-0.008220,-0.008300,
     + -0.008360,-0.008410,-0.008440,-0.008470,-0.008420,-0.008290,-0.008060,-0.007710,-0.007230,-0.006660,
     + -0.006030,-0.005400,-0.004790,-0.003780,-0.003020,-0.002720,-0.002460,-0.002080,-0.001830,-0.001670,
     + -0.001580,-0.001550,-0.001540,-0.001520,-0.001520,-0.001520,-0.001500,-0.001480,-0.001460,-0.001440,
     + -0.001400,-0.001380,-0.001370,-0.001370,-0.001370,-0.001370,-0.001370,-0.001370,-0.001360,-0.001360/)
	f1      =(/ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000/)
	f3      =(/ 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000,
     + 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000,
     + 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000,
     + 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000,
     + 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000,
     + 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000,
     + 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000,
     + 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000,
     + 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000,
     + 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000,
     + 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000, 0.100000/)
	f4      =(/ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,-0.000100,-0.000200,-0.000200,
     + -0.000200,-0.000100, 0.000100, 0.000200, 0.000500, 0.000600, 0.000600,-0.000400,-0.002700,-0.005800,
     + -0.008900,-0.011500,-0.011600,-0.006500, 0.005800, 0.026400, 0.055500, 0.092300, 0.140400, 0.195000,
     + 0.252000, 0.309400, 0.367000, 0.424500, 0.481200, 0.536000, 0.588300, 0.637900, 0.688900, 0.735800,
     + 0.779900, 0.824300, 0.871400, 0.920300, 0.969300, 1.016700, 1.060100, 1.099000, 1.134800, 1.163800,
     + 1.188200, 1.211400, 1.233600, 1.253400, 1.271100, 1.287000, 1.300400, 1.312500, 1.322500, 1.328900,
     + 1.345000, 1.349600, 1.348900, 1.342200, 1.328800, 1.308400, 1.282200, 1.251500, 1.217900, 1.182900/)
	f5      =(/ 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
     + 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,-0.000100,-0.000100,-0.000100,
     + -0.000100,-0.000100, 0.000000, 0.000200, 0.000300, 0.000400, 0.000400,-0.000200,-0.001700,-0.003800,
     + -0.005800,-0.007600,-0.007600,-0.004300, 0.003800, 0.017100, 0.035700, 0.059000, 0.088500, 0.120300,
     + 0.151600, 0.180800, 0.207900, 0.233100, 0.256100, 0.276500, 0.294200, 0.309400, 0.324500, 0.337200,
     + 0.349600, 0.364100, 0.382500, 0.404000, 0.427400, 0.451400, 0.474200, 0.495400, 0.515900, 0.534100,
     + 0.551400, 0.569800, 0.589300, 0.609200, 0.629400, 0.651600, 0.674200, 0.697000, 0.718900, 0.738100,
     + 0.777900, 0.802800, 0.814800, 0.816100, 0.809000, 0.795400, 0.776700, 0.754200, 0.729300, 0.703000/)
	Rjb_bar  =(/ 159.5, 159.5, 159.5, 159.5, 159.5, 159.5, 159.5,
     + 159.5, 159.5, 159.5, 159.5, 159.5, 159.5, 159.5, 159.5, 159.5, 159.5,
     + 159.5, 159.5, 159.5, 159.5, 159.5, 159.5, 159.5, 159.5, 159.5, 159.5,
     + 159.5, 159.5, 159.5, 159.5, 159.5, 159.5, 159.5, 159.5, 159.5, 159.5,
     + 159.5, 159.5, 159.5, 159.5, 159.5, 159.5, 159.5, 159.5, 159.5, 159.5,
     + 159.5, 159.5, 159.5, 159.5, 159.5, 159.5, 159.5, 159.5, 159.5, 159.5,
     + 159.5, 159.5, 159.6, 159.6, 159.7, 159.7, 159.7, 159.8, 159.8, 159.9,
     + 160.0, 160.0, 160.1, 160.4, 160.7, 161.0, 161.4, 161.8, 162.2, 162.6,
     + 163.0, 163.4, 163.9, 164.9, 165.9, 166.4, 167.0, 168.0, 168.9, 169.7,
     + 170.4, 170.7, 170.9, 171.5, 171.9, 172.3, 172.7, 173.1, 173.4, 173.7,
     + 174.3, 174.8, 175.2, 175.6, 175.9, 176.2, 176.4, 176.7, 177.0, 177.2/)
	delta_phiR =(/ 0.081800, 0.088800, 0.082600, 0.079800, 0.077500, 0.075500, 0.073800,
     + 0.071900, 0.070900, 0.069900, 0.069200, 0.068800, 0.068400, 0.068200, 0.068300, 0.068700, 0.069200,
     + 0.069600, 0.070100, 0.070800, 0.071800, 0.073200, 0.075000, 0.077400, 0.080600, 0.084500, 0.088500,
     + 0.092900, 0.097700, 0.102700, 0.107700, 0.112500, 0.117200, 0.121600, 0.125800, 0.129400, 0.132000,
     + 0.134000, 0.135100, 0.135200, 0.134700, 0.133400, 0.131500, 0.129200, 0.126500, 0.123400, 0.119700,
     + 0.115900, 0.112000, 0.108600, 0.105400, 0.102200, 0.099200, 0.095900, 0.092600, 0.089800, 0.087700,
     + 0.085900, 0.084600, 0.084000, 0.083700, 0.083500, 0.083700, 0.084100, 0.085100, 0.086300, 0.087400,
     + 0.088100, 0.088900, 0.089600, 0.089900, 0.089900, 0.089900, 0.089700, 0.089200, 0.088300, 0.086700,
     + 0.084500, 0.081800, 0.078500, 0.074700, 0.070900, 0.066900, 0.063200, 0.060000, 0.057200, 0.055000,
     + 0.053300, 0.051700, 0.050200, 0.049100, 0.047000, 0.045000, 0.044000, 0.043000, 0.041000, 0.040000,
     + 0.037000, 0.037800, 0.041300, 0.046700, 0.052900, 0.058900, 0.064300, 0.069200, 0.073700, 0.072100/)
	delta_phiV =(/ 0.068300, 0.083500, 0.076900, 0.077700, 0.078700, 0.079900, 0.081100,
     + 0.082400, 0.082500, 0.083500, 0.084400, 0.084800, 0.085200, 0.085100, 0.084300, 0.083200, 0.081500,
     + 0.079500, 0.077000, 0.074000, 0.070700, 0.067100, 0.063400, 0.059600, 0.056400, 0.054100, 0.052600,
     + 0.051600, 0.051800, 0.053300, 0.056000, 0.059800, 0.064300, 0.069300, 0.074300, 0.078500, 0.081600,
     + 0.084100, 0.086000, 0.087700, 0.088800, 0.089400, 0.089800, 0.090000, 0.090100, 0.090400, 0.091500,
     + 0.093100, 0.094700, 0.096200, 0.097100, 0.097600, 0.097500, 0.096600, 0.094700, 0.092600, 0.090500,
     + 0.088300, 0.086400, 0.084900, 0.083800, 0.082700, 0.081500, 0.080300, 0.079300, 0.078500, 0.077800,
     + 0.077400, 0.077300, 0.077400, 0.077500, 0.077500, 0.077500, 0.077500, 0.077400, 0.076600, 0.075800,
     + 0.074800, 0.073000, 0.070600, 0.067600, 0.064400, 0.061000, 0.057700, 0.054700, 0.051900, 0.049500,
     + 0.047100, 0.044600, 0.042100, 0.039700, 0.038600, 0.034300, 0.030300, 0.027100, 0.024800, 0.022700,
     + 0.026500, 0.031400, 0.035700, 0.037800, 0.036900, 0.034500, 0.031300, 0.027900, 0.024700, 0.026100/)
	lambda1 =(/ 0.644000, 0.695100, 0.698000, 0.701800, 0.706500, 0.711200, 0.716000,
     + 0.721200, 0.725900, 0.730200, 0.734300, 0.738200, 0.741600, 0.745000, 0.748000, 0.750200, 0.752100,
     + 0.753100, 0.753300, 0.752800, 0.751700, 0.750000, 0.747600, 0.744700, 0.741100, 0.737400, 0.734000,
     + 0.730800, 0.727900, 0.725600, 0.723900, 0.722600, 0.721600, 0.720900, 0.720300, 0.719600, 0.718300,
     + 0.716600, 0.714400, 0.711300, 0.707500, 0.703300, 0.698400, 0.692800, 0.687100, 0.681300, 0.675400,
     + 0.669700, 0.663800, 0.657900, 0.652700, 0.647700, 0.642800, 0.638400, 0.634100, 0.629400, 0.624200,
     + 0.619400, 0.614700, 0.609800, 0.604600, 0.599100, 0.593300, 0.587400, 0.581500, 0.575500, 0.569700,
     + 0.564200, 0.558400, 0.552700, 0.547500, 0.542900, 0.538700, 0.534900, 0.531700, 0.529000, 0.527300,
     + 0.526300, 0.526000, 0.526300, 0.527200, 0.528300, 0.529700, 0.531000, 0.532300, 0.533500, 0.534500,
     + 0.535200, 0.535700, 0.536100, 0.536200, 0.536000, 0.535300, 0.534200, 0.532700, 0.530700, 0.528500,
     + 0.526100, 0.523600, 0.519600, 0.515200, 0.511700, 0.509600, 0.508700, 0.508700, 0.509400, 0.510300/)
	lambda2 =(/ 0.551800, 0.495100, 0.499200, 0.502300, 0.505000, 0.507700, 0.510400,
     + 0.513600, 0.515800, 0.517900, 0.519800, 0.521400, 0.523100, 0.525000, 0.526800, 0.528700, 0.530400,
     + 0.532300, 0.534200, 0.536200, 0.538000, 0.539800, 0.541300, 0.542300, 0.542700, 0.542600, 0.542300,
     + 0.541600, 0.540700, 0.539700, 0.538800, 0.538100, 0.537600, 0.537200, 0.536800, 0.536200, 0.535900,
     + 0.535900, 0.537000, 0.538800, 0.541000, 0.543900, 0.547100, 0.550300, 0.553600, 0.557300, 0.561400,
     + 0.565600, 0.569800, 0.573000, 0.575800, 0.578400, 0.580400, 0.582600, 0.585300, 0.588500, 0.591800,
     + 0.595200, 0.599000, 0.602800, 0.606900, 0.611000, 0.615000, 0.618800, 0.621800, 0.623900, 0.625100,
     + 0.625700, 0.625600, 0.625000, 0.624000, 0.622800, 0.621600, 0.620300, 0.619200, 0.618300, 0.617700,
     + 0.617600, 0.617800, 0.618200, 0.618800, 0.619200, 0.619500, 0.619600, 0.619400, 0.619000, 0.618300,
     + 0.617600, 0.616900, 0.616200, 0.615700, 0.615600, 0.616100, 0.617100, 0.618700, 0.620600, 0.622300,
     + 0.623800, 0.624600, 0.633500, 0.635800, 0.634400, 0.629600, 0.622300, 0.613400, 0.603600, 0.603600/)
	tau1    =(/ 0.400800, 0.398200, 0.401900, 0.408700, 0.418200, 0.427200, 0.436100,
     + 0.444900, 0.453800, 0.462100, 0.470200, 0.477700, 0.484100, 0.490500, 0.495700, 0.499200, 0.502000,
     + 0.502700, 0.501700, 0.499000, 0.494900, 0.489500, 0.482600, 0.474400, 0.464100, 0.452400, 0.440100,
     + 0.427800, 0.415300, 0.403200, 0.391500, 0.380700, 0.370700, 0.361900, 0.354100, 0.348700, 0.345500,
     + 0.344100, 0.343200, 0.343600, 0.345000, 0.347100, 0.350000, 0.353300, 0.356700, 0.360100, 0.363400,
     + 0.366300, 0.369200, 0.372300, 0.375100, 0.377900, 0.381000, 0.384200, 0.388100, 0.392900, 0.398500,
     + 0.404100, 0.410100, 0.416700, 0.423700, 0.431400, 0.439700, 0.448300, 0.457200, 0.466000, 0.474500,
     + 0.482600, 0.490600, 0.498300, 0.505100, 0.511200, 0.516500, 0.521000, 0.524800, 0.528000, 0.530000,
     + 0.531300, 0.532100, 0.532500, 0.532800, 0.533300, 0.533900, 0.534700, 0.535700, 0.536900, 0.538300,
     + 0.539700, 0.541000, 0.542000, 0.542600, 0.542700, 0.541800, 0.540100, 0.537900, 0.535200, 0.532000,
     + 0.528300, 0.524200, 0.517000, 0.514000, 0.511000, 0.507200, 0.502800, 0.497800, 0.492500, 0.486900/)
	tau2   =(/ 0.346000, 0.348000, 0.344600, 0.346400, 0.349400, 0.353700, 0.359500,
     + 0.364000, 0.368800, 0.373800, 0.379100, 0.384300, 0.390400, 0.397300, 0.404600, 0.412100, 0.419000,
     + 0.426300, 0.433600, 0.441100, 0.448400, 0.455300, 0.461500, 0.465800, 0.467900, 0.467600, 0.466400,
     + 0.463600, 0.458300, 0.450700, 0.441200, 0.429900, 0.417100, 0.403200, 0.387900, 0.372100, 0.356700,
     + 0.340900, 0.324300, 0.308500, 0.293700, 0.279500, 0.266400, 0.254700, 0.244200, 0.235700, 0.229000,
     + 0.223100, 0.218000, 0.214800, 0.212300, 0.210500, 0.209700, 0.209800, 0.210800, 0.213000, 0.215600,
     + 0.219000, 0.223500, 0.229100, 0.235500, 0.242500, 0.250200, 0.258200, 0.266400, 0.274100, 0.281000,
     + 0.287600, 0.293500, 0.298400, 0.302500, 0.306000, 0.309200, 0.312100, 0.315100, 0.317900, 0.320600,
     + 0.323300, 0.326100, 0.329100, 0.332000, 0.334900, 0.337500, 0.339900, 0.342000, 0.343800, 0.345100,
     + 0.346300, 0.347500, 0.348400, 0.349000, 0.349200, 0.348700, 0.347200, 0.344500, 0.340600, 0.335400,
     + 0.329000, 0.321300, 0.312300, 0.302100, 0.269900, 0.277900, 0.264900, 0.252000, 0.239200, 0.239200/)

c      pi = 4.0*atan(1.0)
c      twopi = 2.0 * pi
      indx_pga=2
c 0 period.
c convert weights of slip models to mech index.
      if(wtss.eq.1.)then
      mech=1
      elseif(wtnm.eq.1.)then
      mech=2
      elseif(wtrev.eq.1.)then
      mech=3
      else
      stop'current version of bssa requires pure ss,normal or 
     * reverse slip'
      endif
      m=magmin
      do jj=1,nmag
c       delta_c3 = dc3CATW      !Use CA-Taiwan version for now. Can add options for other regions. iregion=1
       if(e_wind(ip))then
          if(m.lt.mcut(1))then
          ime=1
          elseif(m.lt.mcut(2))then
          ime=2
          else
          ime=3
          endif
          endif      !e_wind?
      do ii=1,ndist
      rjb=0.5+(ii-1)*di
       c(1)=c1(indx_pga)
       c(2)=c2(indx_pga)
       c(3)=c3(indx_pga)
       e(0)=e0(indx_pga)
       e(1)=e1(indx_pga)
       e(2)=e2(indx_pga)
       e(3)=e3(indx_pga)
       e(4)=e4(indx_pga)
       e(5)=e5(indx_pga)
       e(6)=e6(indx_pga)
       weight= wt(ip,ia,1)
       if(rjb.gt.wtdist(ip,ia)) weight= wt(ip,ia,2)
      if(e_wind(ip))then
          if(rjb.lt.dcut(1))then
          ide=1
          elseif(rjb.lt.dcut(2))then
          ide=2
          else
          ide=3
          endif
          gndx=gnd_ep(ide,ime,ip)
          endif      !extra epistemic?
            r_pga4nl = sqrt(rjb**2+h(indx_pga)**2)
        call y_bssa13_no_site_amps( m, r_pga4nl, mech,  c, Mref(indx_pga), 
     :           Rref(indx_pga), dc3CATW(indx_pga),
     :           e, Mh(indx_pga), pga4nl) 
       if(abs(m-7.).lt.0.05.and.rjb.lt.10.)print *,rjb,pga4nl,m,' pga4nl',ip    
c   pga4nl is not logged in this code.
            r = sqrt(rjb**2+h(indx_per)**2)
        c(1)=c1(indx_per)
        c(2)=c2(indx_per)
        c(3)=c3(indx_per)
        e(0)=e0(indx_per)
        e(1)=e1(indx_per)
        e(2)=e2(indx_per)
        e(3)=e3(indx_per)
        e(4)=e4(indx_per)
        e(5)=e5(indx_per)
        e(6)=e6(indx_per)
        v1 = 225.
        v2 = 300.	!from bssa13_gm_tmr.for
c v1 and v2 are new control velocities. 4/11/2013. 
c Set v1, v2 to values in text below equation (4.13) ("pending further study")
c     
            call bssa13_gm_sub4y(m, rjb, r, v30, mech,  z1, pga4nl,c, Mref(indx_per), 
     :        Rref(indx_per), dc3CATW(indx_per),
     :        e, Mh(indx_per),clin(indx_per), vclin(indx_per), vref(indx_per),
     :        phi2(indx_per), phi3(indx_per),   
     :        f1(indx_per), f3(indx_per), f4(indx_per),f5(indx_per),
     :        rjb_bar(indx_per), delta_phiR(indx_per), 
     :        v1, v2, delta_phiV(indx_per),
     :        lambda1(indx_per), lambda2(indx_per), 
     :        tau1(indx_per), tau2(indx_per),
     :        lny, sigmaf)  
       if(abs(m-7.).lt.0.05.and.rjb.lt.10.)print *,rjb,exp(lny),ip,1./sigmaf/sqrt2,m   
       gndout(1)=lny
       if(sdi)then
       sigma=1./sigmaf/sqrt2
       sde=lny+fac_sde(ip)	!fac_sde is log(T**2/(4pisq))
       rhat = min(10.,exp(sde)/dy_sdi)	!10 is an upper bound for rhat.
       gndout(1) = sdi_ratio(T(indx_per),m,rhat,sigma,sdisd) + sde
       lny=gndout(1)	!actually log (inelastic displ. median)
       sigmaf=1./sdisd/sqrt2	!use sdi for all gnd_ep branches
       endif	!sdi requested?


         if(e_wind(ip))then
         gndout(2)= lny+gndx
         gndout(3)= lny-gndx
c         if(ii.eq.1)print *,m,gndout(1),gndout(2),gndout(3),lny
         endif
       if(fix_sigma)sigmaf=1./sigma_fx/sqrt2
      do ie=1,nfi
      do 199 kk = 1,nlev(ip)
      tmp= (gndout(ie) - xlev(kk,ip))*sigmaf
        if(tmp.gt.3.3)then
       ipr=25002
       elseif(tmp.gt.plim)then
       ipr= 1+nint(dp2*(tmp-plim))	!3sigma cutoff n'(mu,sig)
       else
       goto 102	!transfer out if ln(SA) above mu+3sigma
       endif
       fac=weight*p(ipr)
 199   pr(ii,jj,kk,ip,1:ntor,ie)= pr(ii,jj,kk,ip,1:ntor,ie)+ fac !sum thru ia index
  102  continue
        enddo	!ie	extra epistemic.
         enddo      !ii
         m=m+dmag
        enddo      !jj	or mag index
        return
        end subroutine bssa2013drv

! >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>      
      subroutine y_bssa13_no_site_amps(m, r, mech, c, mref, rref, delta_c3,
     :           e, mh, y)
c        call y_bssa13_no_site_amps( m, r_pga4nl, mech,  c, Mref(indx_pga), 
c     :           Rref(indx_pga), dc3CATW(indx_pga),
c     :           e, amh(indx_pga), pga4nl) 
c      call y_bssa13_no_site_amps( m, r, mech, 
c     :           c, amref, rref, delta_c3, e, amh,y_xamp)     
c avoid passing fe etc back and forth. New version of Apr 8 2013.
     
! Use this version with coefficients in PEER report format

! NOTE: y in g, unless pgv!!!!  

! ncoeff_s1, ncoeff_s2 are not included as arguments because it is
! assumed that they are 3 and 7, respectively.

! Assume no site amp

! mech = 0, 1, 2, 3 for unspecified, SS, NS, RS, respectively

! Dates: 02/27/13 - Modified from y_ngaw2_no_site_amps
 
      IMPLICIT none
      
      real :: m, r, 
     :        c(1:3), mref, rref, delta_c3, 
     :        e(0:6), mh, 
     :        alny, y, fpb, fp, fe, fs, fault_type_term, gspread     
     
      integer :: mech, iregion
      iregion=1
        fault_type_term = e(mech)

      if (m < mh ) then      
        fe = e(4)*(m-mh)
     :       + e(5)*(m-mh)**2 
      else
        fe = e(6)*(m-mh)
      end if
 
      fe = fault_type_term + fe
 
      gspread = c(1) + c(2)*(m-mref)

      fpb = gspread*alog(r/rref)
     :   + c(3)*(r-rref)

      fp = fpb + delta_c3*(r-rref)
      
      fs = 0.0  ! No amps
         
      alny = fe + fp + fs 
      
      y = exp(alny)
      
      return
      end subroutine y_bssa13_no_site_amps
! >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>      


! --------------------------------------------------------- bssa13_gm_sub4y
      subroutine bssa13_gm_sub4y(
     :        m, rjb, r, v30, mech, z1, pga4nl,c, amref, rref, delta_c3,e, amh,
     :        clin, vclin, vref,phi2, phi3, f1, f3, f4, f5,rjb_bar, delta_phiR, 
     :        v1, v2, delta_phiV,lambda1, lambda2, tau1, tau2,lny, sigmaf)
c version of April 9 2013     
 
!Input arguments:

!          per (not input SH), m, rjb, 
!          mech, v30, 
!          e_gmpe, amh_gmpe, c_gmpe, amref_gmpe,
!          rref_gmpe, h_gmpe, 
!          v30ref, 
!          sigt_gmpe,
!          e_pga4nl, amh_pga4nl, c_pga4nl, amref_pga4nl,
!          rref_pga4nl, h_pga4nl,


!Output arguments:

!          lny, sigmaf (for use in PSHA)
!          
!          bnl, amp_lin, amp_nl, amp_total,
!          fm_gmpe, fd_gmpe, fs_gmpe,
!          gspread


! Computes NGAW2 NGA motions for given input variables

! Note: For generality, include a magnitude-dependent anelastic
! term, although the coefficients are 0.0 for the 2007 BA NGA GMPEs

 
! Dates: 02/27/13 - Written by D.M. Boore, based on ngaw2_gm_sub4y
!        04/09/13 - Revise in light of the new report and coefficient table.
!                 - Sediment depth term in terms of delta_z1, which requires the relation
!                   between z1 and Vs30.  There are two relations in the report
!                   (equations (4.9a) and (4.9b)), one for Japan and one for California.
!                   I need to add an input argument to specify which relation to use, but for
!                   now, just skip the sediment term altogether (even if it is included, specifying
!                   Z1<0 will turn it off).
!                 - Return a large value of phi if Rjb> 300

      implicit none
      
      real sqrt2
      parameter (sqrt2=1.414213562)
      real m, rjb, r, v30, z1,      
     :        pga4nl,
     :        c(1:3), amref, 
     :        rref, delta_c3,
     :        e(0:6), amh,
     :        clin, vclin, vref,
     :        phi2, phi3,   
     :        f1, f2, f3, f4, f5,
     :        rjb_bar, delta_phiR, 
     :        delta_phiV, v1, v2,
     :        lambda1, lambda2, 
     :        tau1, tau2,
     :        y, fe, fpb, fp, fsb, fs, 
     :        phiM, phiMR, phi, tau, sigma, 
     :        gspread,     
     :        amp_lin, amp_nl, amp_total, bnl,
     :        delta_z1, f_delta_z1
     
      real y_xamp, sigmaf,lny
     
      integer :: mech, iregion

!GET Y FOR GMPE, WITHOUT SITE AMPS:

      call y_bssa13_no_site_amps( m, r, mech, 
     :           c, amref, rref, delta_c3, e, amh,y_xamp)     
      
!Compute site amps

      if (v30 <= vclin) then
        amp_lin  =  (v30/vref)**clin
      else
        amp_lin  =  (vclin/vref)**clin
      end if
        
      f2 = phi2 * (exp(phi3*(amin1(v30,760.0)-360.0)) -
     :             exp(phi3*(760.0-360.0)           )   )
      
      bnl = f2
      
      amp_nl = exp(f1+f2*alog( (pga4nl+f3)/f3 ))

      amp_total = amp_lin * amp_nl
      
      fsb  = alog(amp_total)   ! Natural log!!
      
! dont reset z1 to -9.9 Do hardwire delta_z1 = 0.0 in this version:
c      z1 = -9.9
      delta_z1 = 0.0
      if (delta_z1 <= 0.0) then
        f_delta_z1 = 0.0
      else if (delta_z1<= f5/f4) then
        f_delta_z1 = f4*delta_z1
      else
        f_delta_z1 = f5
      end if
      
      fs = fsb + f_delta_z1
c working in log(y) space. difference from BSSA source code.      
       lny =fs + alog(y_xamp)
       
!Compute phi, tau, and sigma   

      if (m <= 4.5) then
        tau = tau1
      else if (m >= 5.5) then
        tau = tau2
      else 
        tau = tau1+(tau2-tau1)*(m-4.5)
      end if
      
      if (m <= 4.5) then
        phiM = lambda1
      else if (m >= 5.5) then
        phiM = lambda2
      else 
        phiM = lambda1+(lambda2-lambda1)*(m-4.5)
      end if
      
      if (Rjb <= 80.0) then
        phiMR = phiM
      else if (Rjb <= 300.0) then
        phiMR = phiM+delta_phiR*(Rjb-80.0)/(Rjb_bar-80.0)
      else
        phiMR=9.99 ! invalid value of Rjb
      end if

      if (v30 <= v1) then
        phi = phiMR - delta_phiV
      else if (v30 >= v2) then
        phi = phiMR
      else
        phi = phiMR - delta_phiV*(v2-v30)/(v2-v1)
      end if
      
      sigma = sqrt(phi**2 + tau**2)
      sigmaf = 1./sigma/sqrt2	!needed in Pex computations.
         
  
      return
      end subroutine bssa13_gm_sub4y
! --------------------------------------------------------- bssa13_gm_sub4y
! --------------------------------------------------------- bssa13_gm_sub4y
        
c ----------------------------------------------------------------------

      subroutine AS_072007_model ( iper,mag, dip, width, rRup, rjb,R_x,
     1                     vs30, pgaRock,  lnSa, sigma, tau, 
     2                     specT, depthtop, Frv, Fn,  vs30_class,
     3                     z10, hwflag )
c "Rake" variable removed because not used SH Mar 15 2013.      
      parameter (MAXPER=108)
      real a1(MAXPER), a2(MAXPER), a3(MAXPER), a4(MAXPER), a5(MAXPER),
     1     a6(MAXPER), a7(MAXPER), a8(MAXPER), a9(MAXPER), a10(MAXPER), a11(MAXPER),
     1     a12(MAXPER), a13(MAXPER), a14(MAXPER), a15(MAXPER),
     1     c4(MAXPER), a16(MAXPER), a17(MAXPER), a18(MAXPER),
     2     s1e(MAXPER), s2e(MAXPER), s1m(MAXPER), s2m(MAXPER), s3(MAXPER), s4(MAXPER)
      real period(MAXPER), b_soil(MAXPER), vLin(MAXPER), M1
      real sigma, tau,lnSa, pgaRock, vs30, rjb, rRup, R_x, aspectratio, rake,
     1     dip, mag, sigcorr(MAXPER), taucorr(MAXPER) 
c      real sig1(MAXPER), sig2(MAXPER), tau1(MAXPER), tau2(MAXPER)
      real taper1, taper2, taper3, taper4, taper5
      real a1T, a2T, a3T, a5T, a6T, a7T, a8T, a9T
      real a10T, a11T, a12T, a13T, a14T, a15T, a18T
      real c4T, M1T, a4T
      real s1eT, s2eT, s1mT, s2mT, s3T, s4T, s1T, s2T
      real sigcorrT, taucorrT, vLinT, b_soilT, sum, Frv, Fn
      real damp_dpga, sigamp, width, testv1
      real sigmanot, sigmanotPGA, taunot, taunotPGA, sigmaB, sigmaBPGA
      integer iper,count1, count2,  vs30_class, hwflag
      real n, c, z10, c2, e2, a21, a22, test, zhat

c      	Updated coefficients according to AS08 paper by SR from matlab code
      data period / 0.0, -1.0, -2.0, 0.01, 0.02, 0.022, 0.025, 0.029,
     1              0.03, 0.032, 0.035, 0.036, 0.04, 0.042, 0.044, 
     2              0.045, 0.046, 0.048, 0.05, 0.055, 0.06, 0.065, 
     3              0.067, 0.07, 0.075, 0.08, 0.085, 0.09, 0.095, 0.1, 
     4              0.11, 0.12, 0.13, 0.133, 0.14, 0.15, 0.16, 0.17, 
     5              0.18, 0.19, 0.2, 0.22, 0.24, 0.25, 0.26, 0.28, 0.29, 
     6              0.3, 0.32, 0.34, 0.35, 0.36, 0.38, 0.4, 0.42, 0.44,
     7              0.45, 0.46, 0.48, 0.5, 0.55, 0.6, 0.65, 0.667, 0.7,
     8              0.75, 0.8, 0.85, 0.9, 0.95, 1.0, 1.1, 1.2, 1.3, 1.4, 
     9              1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.2, 2.4, 2.5, 2.6, 2.8, 
     1              3.0, 3.2, 3.4, 3.5, 3.6, 3.8, 4.0, 4.2, 4.4, 4.6, 4.8, 
     1              5.0, 5.5, 6.0, 6.5, 7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 10.0 /
      data Vlin / 865.1, 400.0, 400.0, 865.1, 865.1, 865.1, 865.1, 898.6, 
     1            907.8, 926.4, 953.6, 962.3, 994.5, 1008.9, 1022.0, 
     2           1028.0, 1033.8, 1044.3, 1053.5, 1071.5, 1082.8, 1088.3, 
     3           1089.1, 1089, 1085.7, 1079.2, 1070.1, 1059.0, 1046.3, 
     4           1032.5, 1002.5, 970.9, 939.1, 929.7, 907.8, 877.6, 
     5            848.7, 821.2, 795.3, 771.0, 748.2, 706.8, 670.6, 
     6            654.3, 639.0, 611.4, 598.9, 587.1, 565.9, 547.1, 
     7            538.6, 530.6, 516.0, 503.0, 491.5, 481.2, 476.5, 
     8            472.1, 463.9, 456.6, 441.6, 430.3, 421.7, 419.3, 
     9            415.2, 410.5, 407.0, 404.6, 402.9, 401.8, 400.0, 400.0,
     1            400.0, 400.0, 400.0, 400.0, 400.0, 400.0, 400.0, 400.0, 
     1            400.0, 400.0, 400.0, 400.0, 400.0, 400.0, 400.0, 400.0,
     2            400.0, 400.0, 400.0, 400.0, 400.0, 400.0, 400.0, 400.0, 
     3            400.0, 400.0, 400.0, 400.0, 400.0, 400.0, 400.0, 400.0,
     4            400.0, 400.0, 400.0, 400.0 /
      data b_soil / -1.186, -1.955, 0.0, -1.186, -1.219, -1.232, -1.25,
     1              -1.269, -1.273, -1.281, -1.291, -1.295, -1.308,
     2              -1.315, -1.323, -1.326, -1.33, -1.338, -1.346, 
     3              -1.367, -1.391, -1.416, -1.426, -1.443, -1.471,
     4              -1.5, -1.53, -1.561, -1.592, -1.624, -1.687, -1.751,
     5              -1.813, -1.831, -1.873, -1.931, -1.988, -2.041,
     6              -2.093, -2.141, -2.188, -2.272, -2.347, -2.381,
     7              -2.412, -2.469, -2.494, -2.518, -2.558, -2.592,
     8              -2.607, -2.62, -2.641, -2.657, -2.668, -2.674,
     9              -2.676, -2.676, -2.675, -2.669, -2.643, -2.599,
     1              -2.543, -2.521, -2.476, -2.401, -2.319, -2.233,
     1              -2.142, -2.049, -1.955, -1.762, -1.57, -1.382, 
     2              -1.199, -1.025, -0.859, -0.703, -0.558, -0.423,
     3              -0.299, -0.086, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
     4               0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
     5               0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 /
      data c4 / 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5,
     1          4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5,
     2          4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5,
     3          4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5,
     4          4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5,
     5          4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 
     6          4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5,
     7          4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5,
     8          4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5,
     9          4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5 /
      data a1 / 0.725, 5.772, 5.065, 0.731, 0.797, 0.826, 0.869, 0.917, 
     1          0.929, 0.954, 0.99, 0.998, 1.033, 1.054, 1.075, 1.086,
     2          1.096, 1.118, 1.138, 1.194, 1.25, 1.302, 1.322, 1.349, 
     3          1.393, 1.433, 1.469, 1.503, 1.538, 1.566, 1.608, 1.643,
     4          1.66, 1.663, 1.657, 1.667, 1.667, 1.667, 1.66, 1.653,
     5          1.64, 1.611, 1.574, 1.56, 1.544, 1.508, 1.487, 1.466,
     6          1.457, 1.433, 1.422, 1.411, 1.392, 1.372, 1.353, 1.335,
     7          1.326, 1.317, 1.298, 1.28, 1.239, 1.195, 1.149, 1.133, 
     8          1.1, 1.054, 1.002, 0.945, 0.893, 0.844, 0.816, 0.757,
     9          0.7, 0.636, 0.564, 0.496, 0.429, 0.366, 0.304, 0.244,
     1          0.187, 0.094, 0.007, -0.035, -0.074, -0.152, -0.225,
     1         -0.294, -0.361, -0.393, -0.425, -0.485, -0.544, -0.601,
     2         -0.654, -0.707, -0.766, -0.823, -0.959, -1.085, -1.202,
     3         -1.312, -1.416, -1.515, -1.609, -1.698, -1.783, -1.865 /
      data a2 / -0.968, -0.91, -0.88, -0.968, -0.9818, -0.9869, -0.9952, -1.0066, -1.0095, -1.0152, 
     1          -1.0235, -1.0262, -1.0367, -1.0416, -1.0463, -1.0486, -1.0509, -1.0552, -1.0593, 
     2          -1.0685, -1.0764, -1.0829, -1.0852, -1.0882, -1.0921, -1.0949, -1.0965, -1.097, 
     3          -1.0962, -1.0941, -1.0872, -1.0777, -1.0668, -1.0634, -1.0551, -1.0431, -1.0309, 
     4          -1.0188, -1.0069, -0.9952, -0.9837, -0.9616, -0.9406, -0.9305, -0.9207, -0.9016, 
     5          -0.8924, -0.8834, -0.8781, -0.8732, -0.8709, -0.8686, -0.8643, -0.8601, -0.8562, 
     6          -0.8524, -0.8506, -0.8488, -0.8454, -0.8421, -0.8344, -0.8273, -0.8209, -0.8188, 
     7          -0.8149, -0.8093, -0.8041, -0.7992, -0.7946, -0.7946, -0.7946, -0.7946, -0.7946,
     8          -0.7946, -0.7946, -0.7946, -0.7946, -0.7946, -0.7946, -0.7946, -0.7946, -0.7946, 
     9          -0.7946, -0.7946, -0.7946, -0.7946, -0.7946, -0.7946, -0.7946, -0.7946, -0.7946, 
     1          -0.7946, -0.7946, -0.7946, -0.7946, -0.7946, -0.7946, -0.7946, -0.7946, -0.7946, 
     1          -0.7946, -0.7946, -0.7946, -0.7946, -0.7946, -0.7946, -0.7946, -0.7946 /

      data a3 / 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 
     1          0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 
     2          0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 
     3          0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 
     4          0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 
     5          0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 
     6          0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 
     7          0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 
     8          0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 
     9          0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 
     1          0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 
     1          0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265, 0.265 /

      data a4 / -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, 
     1     -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, 
     2     -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, 
     3     -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, 
     4     -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, 
     5     -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, 
     6     -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, 
     7     -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, 
     8     -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, 
     9     -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, 
     1     -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, 
     1     -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, 
     2     -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, -0.231, 
     3     -0.231, -0.231, -0.231, -0.231 /

      data a5 / -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, 
     1     -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, 
     1     -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, 
     1     -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, 
     1     -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, 
     1     -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, 
     1     -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, 
     1     -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, 
     1     -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, 
     1     -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, 
     1     -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, 
     1     -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, 
     1     -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, -0.398, 
     1     -0.398, -0.398, -0.398, -0.398 /

      data a6 / -1.44, 0.0, 0.0, -1.445, -1.4522, -1.4571, -1.4612, -1.4672, -1.4708, 
     1     -1.4774, -1.4862, -1.4891, -1.4964, -1.4998, -1.5043, -1.5079, 
     1     -1.5108, -1.517, -1.523, -1.5374, -1.5489, -1.5613, -1.5646, 
     1     -1.5681, -1.5776, -1.5806, -1.5863, -1.5854, -1.5778, -1.5814, 
     1     -1.5797, -1.5595, -1.5487, -1.5469, -1.5426, -1.5342, -1.5109, 
     1     -1.4782, -1.4512, -1.447, -1.4433, -1.4284, -1.4027, -1.3899, 
     1     -1.3823, -1.367, -1.3558, -1.3499, -1.3349, -1.2933, -1.2765, 
     1     -1.26, -1.2475, -1.2559, -1.2797, -1.293, -1.2965, -1.2991, 
     1     -1.2982, -1.2904, -1.3051, -1.316, -1.3201, -1.3282, -1.3393, 
     1     -1.3497, -1.3851, -1.4046, -1.4074, -1.4034, -1.3932, -1.3681, 
     1     -1.3589, -1.3236, -1.2717, -1.2353, -1.2152, -1.0434, -1.0328, 
     1     -1.0274, -1.0294, -0.9823, -0.9892, -0.9739, -0.9596, -0.951, 
     1     -0.9342, -0.8645, -0.8872, -0.8958, -0.8995, -0.8827, -0.8856,
     1     -1.0348, -1.0212, -0.9985, -0.9753, -0.9638, -1.0028, -0.995, 
     1     -0.9702, -0.9565, -0.8952, -0.8398, -0.7739, -0.7367, -0.696, -0.6738 /

      data a7 / 1.052, 0.0, 0.0, 1.1342, 1.108, 1.1018, 1.0817, 1.0532, 1.0538, 
     1     1.0534, 1.051, 1.0543, 1.0528, 1.0479, 1.0492, 1.0552, 1.0596, 
     1     1.0696, 1.0799, 1.101, 1.1179, 1.1465, 1.152, 1.1599, 1.1908, 
     1     1.1995, 1.2268, 1.2231, 1.1967, 1.2247, 1.2514, 1.1943, 1.1923, 
     1     1.2006, 1.2071, 1.2259, 1.1671, 1.0688, 0.9916, 1.0116, 1.0363,
     1     1.0702, 1.0293, 1.0022, 0.9936, 0.9791, 0.9577, 0.9576, 0.9298,
     1     0.7901, 0.7361, 0.6788, 0.6406, 0.6815, 0.7915, 0.8621, 0.882,
     1     0.8975, 0.8996, 0.872, 0.9525, 1.0075, 1.0243, 1.0537, 1.1042,
     1     1.1578, 1.3146, 1.4079, 1.4183, 1.3971, 1.3486, 1.239, 1.2047, 
     1     1.0786, 0.8978, 0.7434, 0.6499, 0.0272, -0.0402, -0.0778, 
     1     -0.0837, -0.2088, -0.1682, -0.2436, -0.3096, -0.1603, -0.2573, 
     1     -0.5093, -0.4603, -0.448, -0.455, -0.5916, -0.6181, 0.1125, 
     1     0.03, -0.0984, -0.2211, -0.2868, -0.0427, -0.1023, -0.2274, 
     1     -0.3748, -0.6794, -0.9725, -0.6304, -0.8524, -1.0953, -1.2714 /

      data a8 / 0.0, -0.1, -0.25, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0008, 0.0038, 0.0052,
     1      0.0065, 0.0072, 0.0078, 0.009, 0.0102, 0.0129, 0.0154, 0.0177, 
     1      0.0186, 0.0198, 0.0218, 0.0236, 0.0254, 0.027, 0.0268, 0.0266, 
     1      0.0262, 0.0258, 0.0255, 0.0254, 0.0251, 0.0206, 0.0164, 0.0124, 
     1      0.0087, 0.0052, 0.0018, -0.0044, -0.0101, -0.0128, -0.0153, -0.0202, 
     1      -0.0225, -0.0247, -0.0289, -0.0329, -0.0348, -0.0366, -0.0402, -0.0435, 
     1      -0.0467, -0.0497, -0.0512, -0.0527, -0.0554, -0.0581, -0.0651, 
     1          -0.0715, -0.0774, -0.0793, -0.0829, -0.088, -0.0927, -0.0972, 
     1          -0.1014, -0.1054, -0.1092, -0.1162, -0.1226, -0.1285, -0.134, 
     1          -0.1391, -0.1438, -0.1483, -0.1525, -0.1565, -0.1603, -0.1681, 
     1          -0.1753, -0.1786, -0.1819, -0.188, -0.1936, -0.199, -0.2039, 
     1          -0.2063, -0.2086, -0.2131, -0.2173, -0.2213, -0.2252, -0.2288, 
     1          -0.2323, -0.2357, -0.2435, -0.2507, -0.2573, -0.2634, -0.2691, 
     1          -0.2744, -0.2794, -0.2841, -0.2885, -0.2927 /

      data a9 / 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
     1          0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
     2          0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
     3          0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
     4          0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
     5          0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
     6          0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
     7          0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
     8          0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
     9          0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 /

      data a10 / 0.9485, 1.587, -0.9, 0.9485, 0.9874, 1.0028, 1.024, 1.0464, 
     1         1.0511, 1.0606, 1.0724, 1.0771, 1.0924, 1.1007, 1.1101, 1.1137, 
     1         1.1184, 1.1278, 1.1373, 1.1621, 1.1904, 1.2199, 1.2317, 1.2517, 
     1         1.2848, 1.319, 1.3544, 1.391, 1.4276, 1.4653, 1.5397, 1.6152, 
     1         1.6883, 1.7069, 1.7504, 1.8107, 1.8703, 1.9257, 1.9803, 2.0306, 
     1         2.08, 2.1679, 2.2461, 2.2814, 2.3134, 2.3719, 2.3972, 2.4216, 
     1         2.4611, 2.4941, 2.5084, 2.5204, 2.5388, 2.5516, 2.5589, 2.5604,
     1          2.5602, 2.5576, 2.5514, 2.5395, 2.4975, 2.4354, 2.3598, 2.3308, 
     1          2.272, 2.1643, 2.0496, 1.9313, 1.808, 1.6833, 1.5581, 1.3038, 
     1          1.0531, 0.809, 0.5725, 0.348, 0.1341, -0.0668, -0.2538, -0.4281, 
     1          -0.5887, -0.84, -0.9415, -0.9415, -0.9415, -0.9415, -0.9415, 
     1          -0.9415, -0.9415, -0.9415, -0.9415, -0.9415, -0.9415, -0.9415, 
     1          -0.9415, -0.9415, -0.9263, -0.9118, -0.8779, -0.8469, -0.8184, 
     1          -0.792, -0.7675, -0.7445, -0.7229, -0.7026, -0.6833, -0.6651 /

      data a11 / 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
     1           0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
     2           0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
     3           0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
     4           0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
     5           0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
     6           0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
     7           0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
     8           0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
     9           0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 /

      data a12 / -0.12, -0.05, -0.05, -0.12, -0.12, -0.12, -0.12, 
     1         -0.12, -0.12, -0.12, -0.12, -0.12, -0.12, -0.12, -0.12, 
     1         -0.12, -0.12, -0.12, -0.12, -0.12, -0.12, -0.12, -0.12, 
     1         -0.12, -0.12, -0.12, -0.12, -0.12, -0.12, -0.12, -0.1171, 
     1         -0.1145, -0.112, -0.1113, -0.1098, -0.1077, -0.1057, 
     1         -0.1039, -0.1021, -0.1005, -0.0989, -0.096, -0.0934, 
     1         -0.0921, -0.091, -0.0887, -0.0876, -0.0866, -0.0846, 
     1         -0.0828, -0.0819, -0.0811, -0.0794, -0.0779, -0.0764, 
     1         -0.075, -0.0743, -0.0736, -0.0723, -0.0711, -0.0682, 
     1         -0.0655, -0.0631, -0.0623, -0.0608, -0.0587, -0.0568, 
     1         -0.0549, -0.0532, -0.0516, -0.05, -0.05, -0.05, -0.05, 
     1         -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, 
     1         -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, 
     1         -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, 
     1         -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, 
     1         -0.05, -0.05 /

      data a13 / -0.05, -0.2, -0.2, -0.05, -0.05, -0.05, -0.05, -0.05, 
     1         -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, 
     1         -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, 
     1         -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, -0.05,
     1         -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, -0.05,
     1         -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, 
     1         -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, 
     1         -0.05, -0.05, -0.05, -0.05, -0.05, -0.05, -0.06, -0.0632,
     1          -0.0692, -0.0778, -0.0858, -0.0934, -0.1005, -0.1073, 
     1          -0.1136, -0.1255, -0.1364, -0.1463, -0.1556, -0.1642, 
     1          -0.1722, -0.1798, -0.1869, -0.1936, -0.2, -0.2, -0.2, 
     1          -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, 
     1          -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, 
     1          -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2 /

      data a14 / 1.08, 0.7, 0.5, 1.08, 1.08, 1.0925, 1.1092, 1.1287, 
     1         1.1331, 1.1416, 1.1533, 1.157, 1.1708, 1.1772, 1.1833, 
     1         1.1862, 1.1891, 1.1947, 1.2, 1.2, 1.2, 1.2, 1.2, 1.2, 
     1         1.2, 1.2, 1.2, 1.2, 1.2, 1.2, 1.2, 1.2, 1.1886, 1.1854,
     1         1.1781, 1.1683, 1.1591, 1.1505, 1.1424, 1.1347, 1.1274, 
     1         1.1138, 1.1015, 1.0956, 1.0901, 1.0795, 1.0745, 1.0697,
     1         1.0605, 1.0519, 1.0478, 1.0438, 1.0361, 1.0288, 1.0219,
     1         1.0153, 1.0121, 1.009, 1.0029, 0.9971, 0.9835, 0.9712,
     1         0.9598, 0.9561, 0.9493, 0.9395, 0.9303, 0.9217, 0.9135,
     1         0.9058, 0.8985, 0.885, 0.8726, 0.8612, 0.8507, 0.8409,
     1         0.8317, 0.8231, 0.815, 0.8073, 0.8, 0.7246, 0.6558, 
     1         0.6235, 0.5925, 0.5339, 0.4793, 0.4283, 0.3804, 0.3574,
     1         0.3352, 0.2924, 0.2518, 0.2133, 0.1765, 0.1413, 0.1077,
     1         0.0754, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 /

      data a15 / -0.405, -0.284, 0, -0.4018, -0.4098, -0.4133, -0.4186, 
     1         -0.4277, -0.4295, -0.432, -0.4345, -0.4377, -0.4478, -0.451, 
     1         -0.4533, -0.4558, -0.4587, -0.4675, -0.4723, -0.4829, -0.4879,
     1         -0.4956, -0.5032, -0.5056, -0.5036, -0.5085, -0.5153, -0.5248,
     1         -0.5223, -0.5178, -0.5138, -0.5257, -0.537, -0.5364, -0.547, 
     1         -0.5227, -0.4967, -0.4784, -0.4685, -0.4587, -0.4407, -0.3986,
     1         -0.3678, -0.3646, -0.3631, -0.3803, -0.3942, -0.4061, -0.3844,
     1         -0.3674, -0.3601, -0.3543, -0.3453, -0.349, -0.3499, -0.3535,
     1         -0.3541, -0.3576, -0.361, -0.3614, -0.3573, -0.3552, -0.3612, 
     1         -0.345, -0.329, -0.3153, -0.3089, -0.2754, -0.2565, -0.2557, 
     1         -0.2591, -0.2289, -0.2198, -0.2159, -0.1606, -0.1626, -0.1738, 
     1         -0.0893, -0.0899, -0.112, -0.1236, -0.0906, -0.092, -0.0602, 
     1         -0.0434, -0.009, -0.0225, -0.086, -0.0818, -0.0936, -0.111, 
     1         -0.1482, -0.1531, 0.0879, 0.0715, 0.0409, -0.0034, -0.011, 
     1         -0.0711, -0.0503, -0.0237, 0.0069, -0.0099, -0.0227, -0.1238, 
     1         -0.2288, -0.2924, -0.3319 /

      data a16 / 0.65, 0.46, 0, 0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 
     1         0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 
     1         0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 
     1         0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 
     1         0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 
     1         0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 0.65, 
     1         0.6202, 0.593, 0.568, 0.5599, 0.5448, 0.5233, 0.5031, 0.4841, 
     1         0.4663, 0.4494, 0.4333, 0.4035, 0.3763, 0.3513, 0.3282, 0.3066, 
     1         0.2864, 0.2675, 0.2496, 0.2327, 0.2167, 0.1869, 0.1597, 0.1469, 
     1         0.1347, 0.1115, 0.0899, 0.0698, 0.0508, 0.0417, 0.0329, 0.016, 
     1         0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
     1         0.0, 0.0, 0.0, 0.0, 0.0 /

      data a17 / 0.6, 0.35, 0.0, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 
     1         0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6,
     1         0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6,
     1         0.6, 0.6, 0.6, 0.5789, 0.5596, 0.5506, 0.5419, 0.5255, 0.5177, 
     1         0.5102, 0.4959, 0.4824, 0.476, 0.4698, 0.4578, 0.4464, 0.4356, 
     1         0.4253, 0.4203, 0.4155, 0.406, 0.397, 0.3759, 0.3566, 0.3389, 
     1         0.3331, 0.3224, 0.3071, 0.2929, 0.2794, 0.2668, 0.2548, 0.2434, 
     1         0.2223, 0.203, 0.1853, 0.1689, 0.1536, 0.1393, 0.1258, 0.1132, 
     1         0.1012, 0.0898, 0.0687, 0.0494, 0.0404, 0.0317, 0.0153, 0.0, 0.0, 
     1         0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
     1         0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 /

      data a18 / -0.0067, 0.0, 0.0, -0.0067, -0.0067, -0.0067, -0.0067, -0.0067,
     1         -0.0067, -0.0067, -0.0067, -0.0067, -0.0067, -0.0069, -0.0071, 
     1         -0.0072, -0.0073, -0.0075, -0.0076, -0.008, -0.0084, -0.0087, 
     1         -0.0088, -0.009, -0.0093, -0.0093, -0.0093, -0.0093, -0.0093, 
     1         -0.0093, -0.0093, -0.0093, -0.0093, -0.0093, -0.0093, -0.0093, 
     1         -0.0093, -0.0093, -0.0089, -0.0086, -0.0083, -0.0077, -0.0071, 
     1         -0.0069, -0.0066, -0.0062, -0.006, -0.0057, -0.0053, -0.005, 
     1         -0.0048, -0.0046, -0.0043, -0.0039, -0.0036, -0.0033, -0.0032, 
     1         -0.0031, -0.0028, -0.0025, -0.0019, -0.0014, -0.0009, -0.0007, 
     1         -0.0004, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
     1         0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
     1         0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
     1         0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
     1         0.0, 0.0, 0.0, 0.0, 0.0, 0.0 /

      data s1e / 0.576, 0.612, 0.733336393, 0.576, 0.575, 0.577, 0.579, 
     1           0.582, 0.582, 0.583, 0.585, 0.585, 0.587, 0.588, 0.589, 0.589,
     1           0.589, 0.59, 0.591, 0.592, 0.594, 0.595, 0.596, 0.596, 0.598, 
     1           0.599, 0.6, 0.601, 0.602, 0.603, 0.605, 0.607, 0.609, 0.61, 
     1           0.611, 0.613, 0.615, 0.616, 0.618, 0.619, 0.621, 0.623, 0.626,
     1           0.627, 0.628, 0.63, 0.631, 0.632, 0.633, 0.634, 0.635, 0.636,
     1           0.637, 0.638, 0.639, 0.64, 0.641, 0.641, 0.642, 0.643, 0.645,
     1           0.647, 0.649, 0.649, 0.65, 0.652, 0.654, 0.655, 0.657, 0.658,
     1           0.66, 0.662, 0.664, 0.666, 0.668, 0.67, 0.672, 0.673, 0.675, 
     1           0.676, 0.677, 0.678, 0.679, 0.679, 0.679, 0.679, 0.679, 0.679,
     1           0.679, 0.679, 0.679, 0.679, 0.679, 0.679, 0.679, 0.679, 0.679,
     1           0.679, 0.679, 0.679, 0.679, 0.679, 0.679, 0.679, 0.679, 
     1           0.679, 0.679, 0.679 /

      data s2e / 0.456, 0.489, 0.739515254, 0.456, 0.455, 0.457, 0.459, 0.462,
     1           0.462, 0.464, 0.465, 0.466, 0.467, 0.468, 0.469, 0.469, 0.47, 0.47,
     1           0.471, 0.473, 0.474, 0.476, 0.476, 0.477, 0.478, 0.479, 0.481, 
     1           0.482, 0.483, 0.484, 0.486, 0.488, 0.49, 0.49, 0.492, 0.493, 
     1           0.495, 0.497, 0.498, 0.499, 0.501, 0.503, 0.505, 0.506, 0.507,
     1           0.509, 0.51, 0.511, 0.512, 0.514, 0.514, 0.515, 0.516, 0.517, 
     1           0.518, 0.519, 0.52, 0.52, 0.521, 0.522, 0.524, 0.526, 0.527, 
     1           0.528, 0.529, 0.53, 0.532, 0.533, 0.534, 0.535, 0.536, 0.538, 
     1           0.54, 0.541, 0.543, 0.544, 0.545, 0.547, 0.548, 0.549, 0.55, 
     1           0.552, 0.553, 0.554, 0.555, 0.556, 0.558, 0.559, 0.56, 0.561, 
     1           0.561, 0.563, 0.567, 0.572, 0.575, 0.579, 0.583, 0.586, 0.594, 
     1           0.601, 0.608, 0.614, 0.619, 0.625, 0.63, 0.634, 0.639, 0.643 /

      data s3 / 0.479, 0.416, 0.686401383, 0.479, 0.479, 0.481, 0.482, 0.484, 
     1          0.485, 0.486, 0.487, 0.488, 0.489, 0.49, 0.491, 0.491, 0.491, 0.492, 
     1          0.493, 0.494, 0.496, 0.497, 0.497, 0.498, 0.499, 0.5, 0.501, 0.502,
     1          0.503, 0.503, 0.505, 0.506, 0.507, 0.507, 0.508, 0.509, 0.51, 
     1          0.511, 0.512, 0.512, 0.513, 0.515, 0.516, 0.517, 0.517, 0.518, 
     1          0.519, 0.519, 0.52, 0.521, 0.521, 0.522, 0.522, 0.523, 0.524,
     1          0.524, 0.525, 0.525, 0.525, 0.526, 0.527, 0.528, 0.529, 0.529, 
     1          0.53, 0.531, 0.531, 0.532, 0.532, 0.533, 0.533, 0.534, 0.535, 
     1          0.535, 0.536, 0.536, 0.537, 0.537, 0.538, 0.538, 0.538, 0.539,
     1          0.539, 0.539, 0.54, 0.54, 0.541, 0.541, 0.541, 0.541, 0.541, 
     1          0.542, 0.542, 0.542, 0.543, 0.543, 0.543, 0.543, 0.544, 0.544,
     1          0.544, 0.545, 0.545, 0.545, 0.545, 0.546, 0.546, 0.546 /

      data s4 / 0.286, 0.262, 0.441385296, 0.286, 0.286, 0.288, 0.289, 0.291,
     1          0.292, 0.293, 0.294, 0.295, 0.296, 0.297, 0.298, 0.298, 0.299,
     1          0.299, 0.3, 0.302, 0.303, 0.304, 0.305, 0.306, 0.307, 0.308, 
     1          0.309, 0.31, 0.31, 0.311, 0.312, 0.314, 0.315, 0.315, 0.316, 
     1          0.316, 0.317, 0.317, 0.318, 0.318, 0.319, 0.32, 0.32, 0.321, 
     1          0.321, 0.322, 0.322, 0.322, 0.323, 0.323, 0.324, 0.324, 0.324,
     1          0.325, 0.325, 0.326, 0.326, 0.326, 0.326, 0.327, 0.327, 0.328,
     1          0.328, 0.329, 0.329, 0.329, 0.33, 0.33, 0.33, 0.331, 0.331, 
     1          0.331, 0.332, 0.332, 0.333, 0.333, 0.333, 0.334, 0.334, 0.334,
     1          0.334, 0.335, 0.335, 0.335, 0.335, 0.335, 0.336, 0.336, 0.336,
     1          0.336, 0.336, 0.336, 0.336, 0.336, 0.336, 0.336, 0.336, 0.336,
     1          0.337, 0.337, 0.337, 0.337, 0.337, 0.337, 0.337, 0.337, 0.337,
     1          0.337 /

      data s1m / 0.562, 0.578, 0.688678637, 0.562, 0.561, 0.563, 
     1         0.565, 0.568, 0.568, 0.57, 0.571, 0.572, 0.573, 0.574, 0.575, 
     1         0.575, 0.576, 0.576, 0.577, 0.579, 0.58, 0.582, 0.582, 0.583, 
     1         0.584, 0.585, 0.587, 0.588, 0.589, 0.59, 0.592, 0.594, 0.596, 
     1         0.597, 0.598, 0.599, 0.6, 0.601, 0.603, 0.604, 0.605, 0.606, 
     1         0.608, 0.609, 0.61, 0.611, 0.612, 0.613, 0.614, 0.614, 0.615, 
     1         0.615, 0.616, 0.617, 0.617, 0.618, 0.618, 0.619, 0.619, 0.62, 
     1         0.621, 0.622, 0.623, 0.624, 0.624, 0.624, 0.625, 0.625, 0.625, 
     1         0.625, 0.625, 0.625, 0.625, 0.625, 0.625, 0.625, 0.625, 0.625, 
     1         0.624, 0.624, 0.624, 0.625, 0.625, 0.626, 0.626, 0.626, 0.626, 
     1         0.626, 0.626, 0.626, 0.626, 0.626, 0.626, 0.626, 0.626, 0.626, 
     1         0.627, 0.629, 0.633, 0.636, 0.639, 0.642, 0.644, 0.646, 0.648, 
     1         0.65, 0.651, 0.653 /

      data s2m / 0.438, 0.445, 0.695254494, 0.438, 0.437, 0.439, 
     1         0.441, 0.444, 0.445, 0.446, 0.448, 0.448, 0.45, 0.451, 0.452, 
     1         0.452, 0.452, 0.453, 0.454, 0.456, 0.457, 0.459, 0.459, 0.46, 
     1         0.461, 0.463, 0.464, 0.465, 0.466, 0.467, 0.469, 0.471, 0.473, 
     1         0.474, 0.475, 0.476, 0.477, 0.478, 0.479, 0.48, 0.48, 0.482, 
     1         0.483, 0.484, 0.485, 0.486, 0.487, 0.487, 0.488, 0.489, 0.489, 
     1         0.489, 0.49, 0.491, 0.491, 0.492, 0.492, 0.492, 0.493, 0.493, 
     1         0.494, 0.495, 0.496, 0.496, 0.497, 0.496, 0.496, 0.495, 0.495, 
     1         0.494, 0.494, 0.492, 0.491, 0.49, 0.489, 0.488, 0.487, 0.486, 
     1         0.485, 0.483, 0.482, 0.485, 0.487, 0.487, 0.488, 0.49, 0.491, 
     1         0.493, 0.494, 0.495, 0.495, 0.498, 0.503, 0.507, 0.511, 0.516, 
     1         0.522, 0.527, 0.541, 0.552, 0.563, 0.572, 0.581, 0.589, 0.596, 
     1         0.603, 0.61, 0.616 /
      data sigcorr / 1.000, 0.74, 0.47, 1.000, 1.000, 0.998, 0.996, 0.992,
     1               0.991, 0.989, 0.987, 0.986, 0.982, 0.98, 0.978, 0.978,
     2               0.977, 0.975, 0.973, 0.969, 0.965, 0.961, 0.96, 0.957, 
     3               0.952, 0.946, 0.942, 0.937, 0.933, 0.929, 0.921, 0.914,
     4               0.908, 0.906, 0.902, 0.896, 0.891, 0.886, 0.882, 0.878,
     5               0.874, 0.866, 0.859, 0.856, 0.853, 0.847, 0.844, 0.841,
     6               0.836, 0.831, 0.829, 0.827, 0.823, 0.818, 0.815, 0.811, 
     7               0.81, 0.804, 0.794, 0.783, 0.759, 0.737, 0.717, 0.71, 
     8               0.698, 0.68, 0.664, 0.648, 0.634, 0.62, 0.607, 0.583, 
     9               0.561, 0.541, 0.522, 0.504, 0.488, 0.472, 0.458, 0.444, 
     1               0.431, 0.407, 0.385, 0.374, 0.364, 0.346, 0.328, 0.312, 
     2               0.296, 0.289, 0.282, 0.268, 0.255, 0.243, 0.231, 0.22,
     3               0.209, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2 /
      data taucorr / 1.000, 0.74, 0.47, 1.000, 1.000, 0.998, 0.996, 0.992,
     1               0.991, 0.989, 0.987, 0.986, 0.982, 0.98, 0.978, 0.978,
     2               0.977, 0.975, 0.973, 0.969, 0.965, 0.961, 0.96, 0.957, 
     3               0.952, 0.946, 0.942, 0.937, 0.933, 0.929, 0.921, 0.914,
     4               0.908, 0.906, 0.902, 0.896, 0.891, 0.886, 0.882, 0.878,
     5               0.874, 0.866, 0.859, 0.856, 0.853, 0.847, 0.844, 0.841,
     6               0.836, 0.831, 0.829, 0.827, 0.823, 0.818, 0.815, 0.811, 
     7               0.81, 0.804, 0.794, 0.783, 0.759, 0.737, 0.717, 0.71, 
     8               0.698, 0.68, 0.664, 0.648, 0.634, 0.62, 0.607, 0.583, 
     9               0.561, 0.541, 0.522, 0.504, 0.488, 0.472, 0.458, 0.444, 
     1               0.431, 0.407, 0.385, 0.374, 0.364, 0.346, 0.328, 0.312, 
     2               0.296, 0.289, 0.282, 0.268, 0.255, 0.243, 0.231, 0.22,
     3               0.209, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2 /

      n = 1.18
      c = 1.88
      sigamp = 0.30

C Find the requested spectral period and corresponding coefficients
c      nPer = 3
      i1=iper
C  PGA, PGV, PGD cases  1,2,3 respectively
         period1 = period(i1)
         a1T = a1(i1)
         a2T = a2(i1)
         a3T = a3(i1)
         a4T = a4(i1)
         a5T = a5(i1)
         a6T = a6(i1)
         a7T = a7(i1)
         a8T = a8(i1)
         a9T = a9(i1)
         a10T = a10(i1)
         a11T = a11(i1)
         a12T = a12(i1)
         a13T = a13(i1)
         a14T = a14(i1)
         a15T = a15(i1)
         a16T = a16(i1)
         a17T = a17(i1)
         a18T = a18(i1)
         c4T = c4(i1)
         b_soilT = b_soil(i1)
         vLinT   = vLin(i1)
         if (vs30_class .eq. 0) then
            s1T = s1e(i1)
            s2T = s2e(i1)
         elseif (vs30_class .eq. 1) then
            s1T = s1m(i1)
            s2T = s2m(i1)
         endif
         s3T = s3(i1)
         s4T = s4(i1)
         taucorrT = taucorr(i1)
         sigcorrT = sigcorr(i1)

c     Set distance (Eq. 3)
      R = sqrt(rRup**2 + c4T**2)

C     No longer : Compute Rx value given source to site azimuth
c      if (srcsiteA .eq. 90.0) then         
c         Rx = Rrup/sin(dip*3.14159/180.0) - DepthTop/tan(dip*3.14159/180.0)
c      elseif (srcsiteA .gt. 0.0) then
c         Rx = Rjb*tan(srcSiteA*3.14159/180.0)
c      elseif (srcsiteA .lt. 0.0) then
c         Rx = 0.0
c      endif
       Rx=R_x
C     Set the 5 taper models (Eq. 8-12 SR)
C     Taper 1 (Eq. 8)
      if ( rjb .ge. 30. ) then
         taper1 = 0.
      else
         taper1 = (30. - rjb) / 30.
      endif

c     Taper 2 (Eq. 9)
      if ( dip .eq. 90.0 .or. Rx .gt. width*cos(dip*3.14159/180.0) ) then
         taper2 = 1.
       else
         taper2 = 0.5 + Rx/(2.0*width*cos(dip*3.14159/180.0))
       endif

c     Set Taper 3 (Eq. 10)
      if (Rx .ge. DepthTop) then
         taper3 = 1.0
      else
         taper3 = Rx/depthTop      
      endif

c     Set Taper 4 (Eq. 11)
      if ( mag .ge. 7. ) then
        taper4 = 1.0
      elseif ( mag .gt. 6.0) then
        taper4 = (mag-6.0)
      else
        taper4 = 0.0
      endif

c     Set Taper 5 (Eq. 12)
c     Modified by SR based on 2009 errata
      if ( dip .lt. 30. ) then
        taper5 = 1.
      else
        taper5 = 1. - (dip-30.)/60.
      endif
              
C     Base Model (Eq. 2)
      c1 = 6.75
       if ( mag .le. c1 ) then
        sum = a1T + a4T*(Mag-c1) + a8T*(8.5-Mag)**2 + (a2T + a3T*(Mag-c1))*alog(R)
       else
        sum = a1T + a5T*(Mag-c1) + a8T*(8.5-Mag)**2 + (a2T + a3T*(Mag-c1))*alog(R)
       endif

c     style of faulting
      sum = sum + a12T*Frv + a13T*Fn
      
c     Site response
c     Set Velocity for break in slope (Eq. 6)
      if ( specT .ge. 2.0) then
          v1 = 700.
      elseif ( specT .gt. 1.00 ) then
          v1 = exp(6.76-0.297*alog(specT))
      elseif ( specT .gt. 0.50 ) then
          v1 = exp(8.0-0.795*alog(specT/0.21))
      elseif (specT .eq. -1.0) then
c      	SR: this is different in paper, 826	
          v1 = 700.0
      elseif (specT .eq. -2.0) then
          v1 = 700.0
      else
            v1 = 1500.
      endif

C     Set the Vs30* (Eq. 5)
      if ( vs30 .lt. v1 ) then
          vs = vs30
      else
          vs = v1
      endif      	

c     Compute site amplification (Eq. 4)  
      if (vs30 .lt. vLinT) then
          soilamp = a10T*alog(vs/vLinT) - 1.0*b_soilT*alog(c+pgaRock) 
     1              + b_soilT*alog(pgaRock+c*((vs/vLinT)**(n)) )
      else
             soilamp = (a10T + b_soilT*n) * alog(vs/vLinT)
      endif
      sum = sum + soilamp


C     Soil Depth Model
C     (Eq. 17 SR)
      if (vs30 .lt. 180) then
         zhat = exp(6.745)
      elseif (vs30 .le. 500.0) then
         zhat = exp(6.745-1.35*alog(vs30/180.0) )
      else
         zhat = exp(5.394-4.48*alog(vs30/500.0) )
      endif
C     (Eq. 19 SR)
      if (vs30 .gt. 1000 .or. specT .lt. 0.35) then
         e2 = 0.0
      elseif (specT .ge. 0.35 .and. specT .le. 2.0) then
         e2 = -0.25*alog(vs30/1000)*alog(specT/0.35)
      else
         e2 = -0.25*alog(vs30/1000)*alog(2.00/0.35)
      endif
C     (Eq. 20 SR)
      if (specT .ge. 2.0) then
         a22 = 0.0625*(specT-2.00)
      else
         a22 = 0.0
      endif
C     Test Value for Eq. 18 SR
      c2 = 50.0
      if (v1 .lt. 1000.0) then
         testv1 = v1
      else
         testv1 = 1000.0
      endif
      
      test = (a10T+b_soilT*n)*alog(vs/(testv1)) + 
     1        e2*alog((z10*1000.0+c2)/(zhat+c2))

C     (Eq. 18 SR)
      if (vs30 .ge. 1000.0) then 
         a21 = 0.0
      elseif (test .lt. 0.0) then
         a21 = -1.0*(a10T+b_soilT*n)*alog(vs/testv1) /
     1           alog((z10*1000.0+c2)/(zhat+c2))
      else
         a21 = e2
      endif

C     (Eq. 16 SR)
      if (z10*1000.0 .ge. 200) then
         sum = sum + a21*alog((z10*1000.0+c2)/(zhat+c2)) + 
     1               a22*alog(z10*1000.0/200.0)
      else
         sum = sum+ a21*alog((z10*1000.0+c2)/(zhat+c2))
      endif

c     Hanging wall Model (Eq. 7 SR)
      if ( HWFlag .eq. 1 ) then
        sum = sum + a14T * taper1 * taper2 * taper3 * taper4 * taper5
      endif
      
c     Depth to top of Rupture Model
c        Modified by SR to follow Eq. 13 of AS08 paper
      z0 = 2.
      z1 = 5.
      z2 = 10.       
        if (depthTop .lt. z2) then
        	sum = sum + a16T*depthTop/10.0
        else
      	sum = sum + a16T
      endif

       
C     Large Distance Model
c        Modified by SR to follow Eq. 15 of AS08 paper
      if (mag .lt. 5.5) then
         T6 = 1.0
      elseif (mag .le. 6.5) then
         T6 = 0.5*(6.5 - mag)+0.5
      else
         T6 = 0.5
      endif

C     (Eq. 14 SR)
       if (Rrup .gt. 100.0)sum = sum + a18T*(Rrup - 100.0)*T6 

C     Set the Sigma Values

c     Compute parital derivative of alog(soil amp) w.r.t. alog(rock PGA)
c     (Eq. 26) SR: This is in agreement with Errata 2009
      if ( vs30 .ge. vLinT) then
        dAmp_dPGA = 0.
      else
        dAmp_dPGA = b_soilT*pgaRock * ( -1. / (pgaRock+c) 
     1              + 1./ (pgaRock + c*(vs30/vLinT)**(n)) )
      endif

c     (Eq. 27 SR)
      if (mag .lt. 5.0) then
         sigmanot = s1T
         if (vs30_class .eq. 0) then
            sigmanotPGA = s1e(1)
         else
            sigmanotPGA = s1m(1)
         endif
      elseif (mag .le. 7.0) then
         sigmanot = s1T + ((s2T-s1T)/2.0)*(mag-5.0)
         if (vs30_class .eq. 0) then
            sigmanotPGA = s1e(1) + ((s2e(1)-s1e(1))/2.0)*(mag-5.0)
         else
            sigmanotPGA = s1m(1) + ((s2m(1)-s1m(1))/2.0)*(mag-5.0)
         endif
      else
         sigmanot = s2T
         if (vs30_class .eq. 0) then
            sigmanotPGA = s2e(1)
         else
            sigmanotPGA = s2m(1)
         endif
      endif

c     (Eq. 28 SR)
      if (mag .lt. 5.0) then
         taunot = s3T
         taunotPGA = s3(1)
      elseif (mag .le. 7.0) then
         taunot = s3T + ((s4T-s3T)/2.0)*(mag-5.0)
         taunotPGA = s3(1) + ((s4(1)-s3(1))/2.0)*(mag-5.0)
      else
         taunot = s4T
         taunotPGA = s4(1)
      endif

C     (Eq. 23 SR)
      sigmaB = sqrt(sigmanot*sigmanot - sigamp*sigamp)
      sigmaBPGA = sqrt(sigmanotPGA*sigmanotPGA - sigamp*sigamp)

C     (Eq. 24) SR: checks with Errata 2009
      sigma = sqrt( sigmaB**2 + sigAmp**2 + (dAmp_dPGA * sigmaBPGA)**2
     1        + 2. * dAmp_dPGA * sigmaBPGA * sigmaB * sigCorrT )

C     (Eq. 25)
      tau = sqrt( taunot**2 + (dAmp_dPGA * taunotPGA)**2
     1        + 2. * dAmp_dPGA * taunotPGA * taunot * tauCorrT )

c     Set total to return
      lnSa = sum

      return
      end subroutine AS_072007_model
