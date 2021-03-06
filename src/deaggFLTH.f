c--- program deaggFLTH.2013.f; 01/03/2014; Use  with 2nd gen NGA relations, or others.
c Jan 22 2014: Correct sigma_aleatory in Idriss2013 to         sig = 1.18 + 0.035*alog(T) - 0.06 * xmagc       !see P Powers email jan 21 2014
c 01/04/2014: continue with clustered event. Amean11 clamp revisions from PPowers.
c 12/31/2013: reviving "cluster_me". Just compute probability of exc for each scenario. 
c		No rbar, mbar, ebar. The
c		probability will be used to rescale the independent-event probabilities.
c 12/18/2013: updated to run with gfortran (M.Moschetti).
c 12/17/2013: in ASK13, add hardrock median calcs at periods defining the CMS
c 12/16/2013: update some a1 coeffs in ASK13 model for short periods. Email from Sanaz R.
c 11/26/2013: global indexes for AB06',A08', and Pez11 set up.
c 10/18/2013: put caps on Idriss-2013 aleatory s.d. when M<5 or M>7.5
c 9/11/2013: In-line CB13 coeffs and remove subroutine CB13_NGA_SPECIN
c 08/01/2013: Incorporate CY2013 vers of July 29. Use estimated Vs30 if index is 35.
c		Use measured Vs30 if index is -35 (new 8/01/2013)? not available
c 8/02/2013: The correlation coeff vector rho was updated in CB13. It is now
c 	    stored as a data vector rather than being read in.
c 07/25/2013: Incorporate ASK_NGA_2013_V11.f which is the July 24 version of A S &Kamai. Uses Ry0 distance.
c	Using estimated Vs30 vs30_class=0. This parameter could be input
c 7/22/2013: BSSA: clin and Vclin updated July 2013. 
c 6/24/2013: begin working on CMS for newer GMPEs. WUS: good progress. CEUS: not so much
c 6/17/2013: ADD Atkinson code for A06' AB08', Pez11. Table look-up method.
c 6/11: up ndmax to 310
c 5/31/2013: Use CB default Z25 as fcn of Vs30.
c 5/22: update bssa & correct c11 in GKSA13
c 5/17/2013: repair some e5 coeffs in bssa2013drv. CY model: set cDPP to zero for all sources.
c 5/16/2013: Update AS13 to May version. Norm A recommends using this instead of AS08 as of May 15.
c 5/15/2013: update CY NGA-W to May version. 5/16: correct small typo from Chiou email
c 5/14/2013: Add anelastic attenuation in CB13, for R>80 km. Bozorgnia email May 2013.
c 4/17/2013: GK13 updates (v2)
c 4/11 New Idriss coeffs. New CB Coeffs.
c 4/16 New CY2013 coeffs and  modified hw term. deltaZ1 revision. BSSA updated to 107 per.
c  3/20/2013:AS13 (finished). CB13 3/21.
c 3/14/2013: revise AS08 to use our Rx. 3/15:Use vs30_class=1 (measured). Index 16
c Jan 2012. Six Dec 2012 NGA-W GMPES plus GK12 are implemented here. Without the CMS option initially.
c Indexes are in the 32 to 38 range. Same as those in hazFXnga7.temp.f.
c 3/06/2013: working on CY2013. Dirctivity, cDPP, is turned off for initial exercise.
c 8/02: repaired a variable name in getToro subroutine (SH). jms not j_ms
c
c 6/01/2011: add CMS computations for these CEUS relations: Silva, Somerville, Toro,
c	getCampCEUS, getAB03. 6/06 add getFEA
c 5/02/2011: fix declaration of NL0 in CY2007H. Remove references to old AS_2005
c model. This A&S model was updated in 2008 but not included in this code.
c 10/28/2010: add conditional mean spectrum calc for each (R,M,ie,ia) bin. 
c Work in progress but may be good to go in WUS
c  to program mean spectrum: BA-NGA-W. Added CB. Added CY
c NEW OUTPUT FILES:
c *.SPCTRA (binned cms) and (added 1/05/2011) *.MEANSPC (mean of cms, one for each attn model
c 2/2011: these ascii files are no longer output. they are not needed once determined that OK. Instead, binary
c output.
c  1/20/2011: *.bin SPCTRA file in binary format. Used when combining. Fast I/O. 
c Binary version will replace the ascii SPCTRA files once confident of CMS calcs.
c  if using the deagg_attn_model option, or just one meanspec if not.
c 11/15/2010: include Jack Baker & N Jayaram correlation of spectral epsilons Eq Spectra Mar 2008 
c 11/08/2010: include specific epsilon index in mean spectrum bookkeeping. Initial epsilon
c associated with requested T is spread over the other T. Future, multiply by corr. coeff rho
c 11/01/2010: added mean spectrum calc to CY NGA-W relation.
c 11/05/2010: these mean spectra  incorporate rho(Sa_j, Sa_k) in the epsilon*sigma term
c Vector of rho ( supplied by Jack Baker)
c 9/17/2010: streamlined in a few places. 
c 8/08/2010: work on the contributions from clustered src (not working commented out).
c  Consider Venn diagram of 3 events, proportion of probability to assign to each:
c (p1-1/2(p1 p2+p1 p3) + 1/3 p1 p2 p3)/p, where p is the prob of at least 1. Does this work?
c 6/23/2010: explicit inclusion of geog deagg file if requested arg11
c 10/13/2009: correct TP05 c1(0.3 s) for BC rock.
c March 3 2009: add back-azimuth field to fault file output (*.FDEAG output file)
c April 2009: allow individual attn model deaggs to be included in the output.
c 4/28/2009: add option to deaggregate individual atten models and output same data for
c each model as was output for the mean in deaggGRID.2008.f. The mean is still output
c and its data are associated with index 0. Positive indexes corrrespond to specific GMPEs. A run can
c have up to 8 GMPEs. Thus, the output file size is potentially 8 times larger than that of 
c  the earlier code deaggFLTH.2008.f. 
c 2008 mod: The reported distance is average Rcd or Rrup in each bin, 
c not avg of r_jb and rrup as in previous versions.
c The reported M is average moment magnitude in each bin. We do not report bin
c centers. The conditional mean in each bin is more informative.
c from hazFXnga7c.f. This version does not has event-clustering option. 
c If this option is
c selected, all events in input file must be part of the cluster model. Initial
c work on this was for NMSZ scenarios. These scenarios dictate several limits
c on the available model. Do not mix unclustered sources (faults) with clustered
c in any given input file,
c but you can  use this code on either clustered or independent events. Clustered events
c are set up for Characteristic without uncertainty. Other rup. models need more work. 
c clusterd not ready for deagg 8/2008.
c VS30: if >1500, iatten codes are changed to negative values from input values>0.
c for these iatten indexes:  2, 4, 6, 7, and 10. However, 19 and 21 are unchanged.
c This f95 source code has been compiled & run on SUN solaris and PC Linux machines.
c      	deaggFLTH.2013.f
c--- Solaris compile: cc -c iosubs.c 
c                 f95 -o ../bin/deaggFLTH.2013   deaggFLTH.2013.f -O -e -ftrap=%none
c -e to extend linelength. Several statements go past column 72. This code does not
c use iosubs_128.o, unlike the gridded-source counterpart. Ascii input & output
c The ftrap flag is required to prevent crashing when NaNs such as log(0) are
c attempted. Code has been modified to avoid some of these where known.
c The -O flag works but -fast does not on the Solaris compiler f95.
c 
c for detailed source listing -Xlist is the argument. -Xlistf list no compile
c
c Linux compile, with Intel fortran compiler:
c  ifort -o deaggFLTH.2013   deaggFLTH.2013.f iosubs.o -O -132
c  Note: on cluster, if using Intel version must use flag -V:  qsub -V job
c
c PC, windows, use gnu fortran:
c   gfortran -static -O -finit-local-zero  -ffixed-line-length-none -ffpe-trap= -o deaggFLTH.2013   deaggFLTH.2013.f 
c
c Example run command:
c   deaggFLTH.2013 SAmd.fixed.char   tsac $lat $long $per $sa $vs30 $LOC Deagg/ $attn $GEO
c
c The final field $GEO is an instr to do a geographic deagg, $GEO=1, or mean spectrum calc $GEO=0
c 8/28/2007: add option GR branches with b=0 wherever there is currently a branch with some other b. 
c This new set of branches is weighed equally with the old ones. For example, if a fault
c GR branch on input has b=0.8 and weight 0.25, 
c on output the b=.8 branch has weight 0.125 and the b=0 branch
c also has weight 0.125. This option is invoked by making itype(ift)=-2, previously an illegal value.
c The effect is to slightly decrease the rate of M6.5 eqs in the model and slightly increase the
c rate of M7.0 eqs in the model. The M6.5 rate model bulge is slightly reduced by trying this.
c
c 
c deagg work was not completed for clustered events or for CEUS. Should work for WUS fault files.
c More work is needed for the CEUS or anyplace with clamped motions or  clustered-event option
c
c
c 10/30/2008: further work on deaggs of clustered events. Not finished.
c Aug,2008: Add list of fault names for outputting in deagg text file to input file
c These names precede the list of fault parameters. The number of such faults precedes
c the list. Example:
c 3
c Big fault
c Conjugate fault
c Mother of all faults
c ...
c Apr 7 2009: Use rjb in getSomer (K Campbell noticed we were using rrup in this subr)
c aug 20 2008: clamped motion deaggregated for 4 CEUS models, Char w or w/o uncert, GR w or w/o uncert.
c july 1 2008: add 2.5 and 25 hz to getSilva
c 5/05/2008: in resample_fault deltax is now defined as deltaz*cot(dip). This mod affects GR scenarios for some
c steep but non-vertical dipping faults such as Imperial flt, southern CA-Mexico.
c 5/01/2008: fix the clustered-event output for 1 station, every curve for a given SA outputs to 1 file.
c 3/20/2008: update BA-NGA relation to compute pga_nl using the final PGA coeffs, which
c include mechanism dependency, for example. Follows a new pdf file from Dave Boore, 3/19/2008.
c This modification does not affect the BC rock (reference site condition) calculations. 
c 3/06/2008: add some logic to allow input fault dips to be > 90 or < -90 degrees (K.Campbell sugg);
c      also check for VS30 > 1500 and stop if using Campbell NGA relation.
c 2/22/2008: GR source model epistemicM uncertainty is no longer removed if sdal is 0.
c Note: For the single magnitude GR case you must include nonzero sdal if dM_epistemic is non-zero
c
c 2/21/2008: Only changes are to comment lines (updated) and cosmetic format changes
c 1/08/2008: uncommented out a required statement,  cs=1.88 in getCampNGA0308
c 12/07/2007: add median clamps to getSilva and getTP05 (inadvertent omission prior to)
c 12/05/2007: the irab() array is now 2-dimensional (was 1-d before). to get proper AB06, need 2-D.
c 11/26/2007: AB2006 (CEUS) nonlinear S term is modified for Vs<760. Does not affect BC rock
c 11/19/2007: Campbell sigma terms are modified slightly for nonlinear soil. These mods
c can affect pga when Vs30 = 760 because Campbell k1 is 865 m/s, and nonlinearity kicks in
c when Vs < k1. However, the effect is quite minute for PGA of rock at BC boundary.
c 11/07: Chiou makes another small correction to his tau-term. Increases tau very slightly.
c 11/06: Chiou makes a small correction to his tau-term. Reduces tau very slightly.
c 11/02: use very latest Chiou-youngs model with a new dlt1 effect in the sigma calc.
c 11/01: Use Chiou M-dependent sigma which is interim
c 10/25/2007: Add the new CY2007 NGA model (B. Chiou emailed this), 
c               which uses new R_x signed distance, now computed
c      in the revised mindist1 (Y. Zeng)
c 10/17/2007: Invoke the downdip rupture option only if top of fault within 1 km of surface
c      of Earth. Blind thrusts and so on will not have additional rupture tops.
c 10.12.2007: improve log file output info for b=0 branch. Show crossover M.
c 10/03/2007: Update Boore Atkinson atten with Apr 02, 2007 coeffs.
c
c 8/28/2007: make the dMa on aleatory a function of the sigma. dMa previously was fixed at 0.05, now
c 	dM is 2sigma_ale / 5 = 0.4 sigma_ale The Mmin=5.8 low limit has been removed.
c
c 8/13/2007: add aleatory dM with sigma<0 to keep event rate fixed at input value.
c      if sigma>0, moment rate is fixed.
c july 20 2008 NO deterministic source Just deagg. simplification of hazFX
c august 3 2007: modify output of determinstic GR to only show the nearest src
c	i.e., remove all but one of the aleatory rupture location scenarios
c May 16: add scenario and geographic index to the output 
c
c polygon feature removed from interactive deagg aug 2008.
c April 23 2007: add polygon feature. Only include a fault source if at least
c      one point on fault when projected to earth surface is 
c      interior/on a polygon surface. The polygon-checking
c      feature is optional, and is included if the polygon file name
c      is included as arg 2 in the command line input stream.
c      May 25: this check was refined to include check whether individual
c	 segments are inbounds or not for GR segments or floating ruptures. In
c	other words a fault can be inbounds but several floating segments on that
c	fault may be out-of-bounds. When determining event rates, this distinction
c	can be important for many relatively long WUS faults.
c Clustered source model has been checked for characteristic-without-uncertainty-in-M
c types of ruptures only. Future work, add aleatory uncert to clustered source model.
c
c late March: use Zeng's mindist1 algorithm for all rjb, rcd dist calculations.
c 3/19/2007: use Frankel HR->FR factors for TP05 at 7 periods (this still needs work at other
c      periods). Somerville HR revised slightly.
c 3/13/2007: revise BA NGA relation, now has 21 spectral periods. see feb 14 doc.
c 1/27/2007: add/subtr. additional epistemic uncertainty to all median relations with the uncert
c in a 3x3 matrix gnd_ep(3,3) if l_gnd_ep is true. Advisory panel
c has recommended smoothing this gnd_ep matrix in some way. 
c 
c Mod Nov 7 to report rates of events when the "list of stations" option is
c invoked. For each station or receiver, a file is written, eqrate.sta_name.
c  NGA7: This code has potential downdip ruptures with tops at 2 and 4 km depth
c when GR-distributed sources and 6.5<=M<=7.0. Testing is nearly complete. 
c  Added GR with 6 < M < 6.5. For these, rupture tops are equally distributed 
c               at ztor+0,2,4,and 6 km. Revised so that AspectRatio>=1 for all rups,
c            even those associated with M6.0 sources.
c What's in a name?
c   Some of the downdip rupture branching is triggered or not triggered by
c a match to part of a filename. This feature definitely needs a more failsafe
c logic approach. For example, filename containing 'aFault_unseg' is a trigger to
c not include downdip rupture scenarios even though these are type 2 faults (GR)
c Because different rules are being used in different regions, it might
c be possible to make rule sets depending on state boundaries or other
c geopolitical features. This has not been done as of Feb 2008. SHarmsen.
c Jan 2007: increase or decrease in median is possible with amount of increase
c contained in a 3 x 3 x nper matrix, gnd_ep. If you do not want to modify
c gnd, make the indicator variable wind 0 for that period. All attenuation models will
c be affected. We are planning to use this only with NGA relations, because there
c is already enough variety of ideas about the median in CEUS, intraplate, and
c so on. If this option is on, three curves per site are computed and output,
c one for median, one for median+augment, and one for median - augment. They
c go to different files. This option can be turned on for some spectral periods,
c off for others. If on, and not NGA, the .p and .m files will be zero (10**-21)
c
c Deaggregation example (new Oct 2008): 
c
c  deaggFLTH.2013   orwa_c.in  outfi 44.4 -123.4 0.1 0.5 760. 1
c
c The first arg after pgm name is the input file name, 2nd is output file name
c 3rd is lat, 4th  is long, 5th is spectral per,
c 6th is SA level (units g); and 7th is Vs30 at the site. 
c The input file is designed specifically for the deagg program. It does not have
c spectral period information. It does have a list of fault names.
c The command-line information replaces (supercedes) the corresponding info in
c the input file. For example, input file might have 20 sa levels, but there is
c always just one sa level per period for deaggregation, which is input on command line.
c Deagg bins: dM is 0.1, dR is variable, 10 km inner 100, 25 km for awhile, then a catchall.
c      Epsilon bins are 1 sigma in size with edges at k*sigma, k=0, +-1,+-2
c      Epsilon binning might be considered coarse. Follows 2002 1996 web sites.
c  Command-line info follows the interactive deagg web site precedents of 2002 and 1996.
c This code should be compatible with certain Linux Cluster as well as Solaris
c compilers. Solaris version: -e in gfortran is fixed-line-length-none. 
c Linux: gfortran -o deaggFLTH.2013   deaggFLTH.2013.f iosubs.o -ffixed-line-length-none
c   linux compiler is accepting this code Oct 13 2006. 
c "array constructors" are modern replacement for "data" statements. This is the
c main modification to make code gfortran-compatible. SHarmsen
c
c new 6/06:  sources now can have up to 12 magnitude branches per fault.
c For each mag there is a specific cmag and crate. If no epistemic uncert on
c magnitude-frequency is modeled for a given fault, ift line must
c have a 1 for number of mags per fault (this means all 2002-era input files must be modified)
c Has similar mods for GR-distribution of sources. This required dimension increase on
c several arrays including xmo2
c  
c Modified Mar 8 2006 to improve identification of HW sites.
c Also, transfer out of labor-intensive downdip calcs if appropriate. This change
c may bypass the Frankel abrahamson-hw part of code which is not used with
c NGA. If this code is to work with old subroutines, need to revisit...
c
c Some older relations are in the nga-style subroutine format with coeffs 
c      explicitly included as statements. These are:
c iatten=0 Truth. This one hasn't been programmed. It is the oldest but least accessible
c iatten=1 Spudich ea, 2000 Extensional-tectonics regions, with BJF97 site amp
c iatten=2 Toro ea; CEUS 7 periods and BC rock geotech. M has to be Mw. finite fault
c iatten=-2 Toro ea; CEUS 7 periods and A rock geotech. New 11/06: finite fault
c iatten=3 Sadigh 7 periods rock
c iatten=-3 Somerville IMW. 5 periods available. No site response var. add jan19 2007.
c iatten=4 or -4. AB06, -4 for hardrock (is overridden if Vs30<1500 m/s). Mod Mar 14 2008. SH.
c iatten=6 Fea ceus 7 periods BC rock
c iatten=-6 Fea ceus 7 periods A rock
c iatten=5 AB94 BC ceus (New index, previously had same 6 index as fea. Too confusing)
c iatten=-5 AB94 A ceus (New, hard rock only)
c iatten=7 Somerville finite, BC rock. ceus
c iatten=-7 Somerville finite, A rock. Will get -7 if Vs30>= 1500. ceus
c iatten=8 Abrahamson & Silva 7 periods rock. Using the logical variable "hwsite" to
c       note for A&S: increase ground motion when hwsite is true. THis is a quick fix and does not include
c       the 22 degree wings.
c iatten= 9 Campbell and Bozorgnia 2003. 7 periods BCrock. july 27 2006
c   added iatten=10 Campbell CEUS. bc rock. july 29
c   added iatten=-10 Campbell CEUS.  hardrock. 
c iatten=19 Tabakoli and Pezeshk can be firm rock or hard rock.
c  BACK TO WUS atten models:
c iatten=11 BJF97, any vs30. 7 periods. july 27.
c Important note, if any of the above require a different than moment mag, must
c do the conversion outside of the subroutine. icode=1 do something before calling...
c   iatten=12 Motazetti and Atkinson, for PR/VI. Limited period set.
c
c ---  New relations: 
c --- Include the latest NGA developer-team updates here asap. 
c --- Iatten=13 for B&A 4/07; to 10-s SA maximum T, has PGV model.
c B&A April update includes 7.5 and 10-s SA predictions; coeffs change from Feb
c for some T, no change for 1s or 0.2-s SA and the reference 760 m/s site class.
c --- Iatten=14 C&B, 11/10/06. Includes PGV&PGD models. Sigma for random H-comp.
c              C&B hanging-wall term (f4) applies to both Normal and Reverse.
c --- Iatten=15 C&Y. This is model of Oct 2007. No PGV for C&Y, but 105 T-vals  (rev Oct 2007)
c --- 
c --- 
c --- Iatten=16 for A&S 8/05; they are changing model this one will deep-6. 
c ********* SH Oct 26 2005
c --- Iatten=17 Idriss. Added nov 2005. Note Sept 2006: Idriss has coeffs for several
c --- iatten=20. Silva, Gregor, Darragh 2002. Hard rock and BC rock for CEUS. New jan 30 2007. 8 periods
c --- iatten=21 AB06, CEUS, 200 bar . should work with any reasonable vs30. (S term may or may
c     not be present. Hardrock coeffs used  if Vs30>=2000 m/s, in which case S is 0.0)
c --- iatten=-21 AB06, CEUS, 200 bar. Specifically request hardrock coeffs even though Vs30 is in
c      the 1500 to 2000 m/s range.
c    
c ***
c
c *** New Oct 27 2005: Enter vs30 after the site description. Also enter depth of
c *** basin 
c *** dbasin= 0 for surficial hardrock; Depth to 2.5 km/s VS in
c *** Campbell&Bozorgnia (Nov 2007 NGAmodels) ***
c *** what about firm rock basement? Z1 value. New default Z1=.025 * dbasin Oct 2007, converted to m.
c ***
c *** Towards parallel processing: Y. Zeng has developed a separate code for
c *** parallel processing. It is now used on gldlabm, a PC Cluster Linux OS

c       iosubs.o:       ELF 64-bit MSB relocatable SPARCV9 Version 1
c
c --- Nov 2005: New Feature corresponding to feature of hazgridXnga2:
c --- code works for a large grid of sites or a small set (<=30) of sites.
c ---   Input file first line is number of sites, nrec.
c --- Make nrec 0 to perform the calculations for a grid of sites.
c --- Make nrec 1 to 30 to specify set of sites <lat(i),long(i),i=1,...,nrec>
c If you use small station set, output includes eq rates*model weight files,
c one for each station.
c --- Output file names are specified in input file, one per period.
c --- This version calls atten. subroutine each time the mean,sd are needed.
c--- uses NGA  subroutines for attenuation relations 
c--- Important: if sdal is zero, the epistemic dM branches will be ignored and
c --- only the central branch will be used (dM=0). This is a hard to remember
c --- feature of this code. 
c----  HazFX originally written by Art Frankel, with many modifications & updates 
c        by Steve Harmsen, USGS, Golden,CO
c---- averages strike of fault segment. dip direction is from an avg strike
c---- Frankel revised hanging wall test for AS97, including 22.5 degree wings.
c ---   the 22.5 degree wings are no longer supported. SH 2007.
c-- Can use up to 8 attenuation relations for each period. Atten model weights should sum to 1.
c --- This vers. does not save atten-model pex info in arrays. SH 
c---- added getMota 10/16/02
c---- revised Campbell2002
c---- added hanging wall term for Campbell 2002
c---- hanging wall term, separate reverse from thrust faulting
c---- fixed hanging wall for floating rupture
c---- changed to dmove increment for floating rupture 9/30/02
c---- added getBJF97 9/30/02
c--- changed length to WC all 7/1/02
c--- changed to only epistemic uncertainty for GR faults
c----- changed to Mmin= 5.8  nmag= 55
c---- added clamp for CEUS   max gnd motions
c---- added Mchar epistemic uncertainty 10/16/01
c---- added Mchar aleatory uncertainty 10/16/01
c---- checks to see if distribution goes below M6.5 for GR
c---- or below 6.0 for char.
c---- if so, ignores uncertainties
cc----- truncates at 3 sigma
c--- with clipping for Toro and Boore new table
c--- calculates mean annual frequency of exceedance for dipping faults
c--- Orig version was written by Art Frankel 4/95, modified 10/95
c--- Many updates since then for the 2002 and 2007 NSHMP updates.
c-----  
c--- Output of this program is input into hazallXL.v2 to get probabilistic
c    ground motions
c--- PGA & SA ground motion levels should be in units of g
c--- period=0 indicates PGA
c --- PGV ground motions are in units cm/s (BA and CB as of feb07)
c --- PGD units cm (CB only, oct 2006)
      parameter ( pi=3.14159265,pi2=pi*0.5,tiny=1e-12,d2r=0.0174533)
c Prob. calcs associated with fault rates less than tiny will be omitted.
c Some of the Aug 2007 AFault segmodels have rates of 0 and of 1e-20 for example.
      parameter (nfltmx=1000, nlvmx=1, npmx=1)  
      dimension icode(10)
      real xlev	!one gm level and one period. don't put xlev into array
      dimension p(250005)      !table of complementary normal probab.
c You can raise p dim & make some minor code changes to improve accuracy. Currently
c p() has about 4 or 5 decimal place accuracy which is likely good enough.
      real, dimension(13) :: a11fr    !,a11per        Atkinson 2011. frequency set 99=pga, 89=pgv
      real, dimension(nfltmx):: xaz,xlen
      real, dimension(800,nfltmx):: x,y
      real, dimension(3,8,5) :: prob_s, r_s, m_s, eps_s
	integer jms,iptoro,nlev,iReg
       common/gail3/freq(13)
      real, dimension(8):: dmin,prob_c
      real, dimension(12) :: pdSilva
c wind used to determine if additional epistemic uncert will be added to
c or subtracted from log(median) of each relation for that period
      real, dimension (6,6) :: dminr
      real, dimension (3,3) :: gnd_ep
      real, dimension(3) :: gnd,gmwt 
c gnd(1) contains the median; gnd(2) contains median+gnd_ep(); and gnd(3)
c      contains median - gnd_ep(). Ultimately, curves go to different files,
c One goes to output name given, two, to output//.p and three, to output//.m
      real, dimension(2) :: mcut,dcut,tarray
      real dum(5)	!for bssa nov 2012
        real, dimension(32) :: slat,slong 
        real, dimension(100) :: ale, ale2
c  array of station coordinates if using list option
      integer, dimension(nfltmx):: igroup,jseg,nmagf,itest,mx_index
      integer, dimension(12) :: imsc_ga	!atkinson-ceus to CMS period map
       real, dimension(nfltmx):: cDPP
      integer, dimension (50,nfltmx) :: nrupd,nrups
c add some arrays for storing information related to downdip ruptures.
c azimuth stores station-to-source azimuth, or back-az.
      real rupln(50,nfltmx),dmin2(20,1000,6,6),wtscene(8,5),azimuth(20,1000,6)
      integer nmag0(nfltmx,12),immax/1/,vs30_class
      real ratenew(nfltmx,12,6),xmo2(nfltmx,12),relwt(nfltmx,12)
      real aperiod(22),camper(24),Percb13(23)     !abrhamson, campbell-boz period sets resp. Code pgv=-1
       real perb(23),abper(26),tpper(17),xdiff,ydiff
c abper atkinson boore ceus2006 tp=tabakoli & pezeshk
c Deagg array storage: rbar,mbar,ebar,haz indexed by R,M,epsilon,GMuncert, and spectral period
      real, dimension (17,33,10,5,0:10):: rbar,mbar,ebar,haz
c add epsilon index (3rd dim) to meanspecs, hazmsp, etc.
      real, dimension (17,33,10,21,0:10) :: meanspecs	!save avg meanspec in bins.
      real, dimension (17,33,10,0:10) :: hazmsp,epsmsp,rmsp,mmsp
c meanspec and sigmaspec: for each source. accumulate in meanspecs. 
      real, dimension (21,0:10):: mean2spec	!mean of the mean specs
c mean2haz, etc mean of the means, averaged over the r- m- and epsilon- bins, one for each
c attn model and one for the avg of all attn models (in slot 0)
      real, dimension (0:10):: mean2haz,mean2r,mean2m,mean2e0
      real, dimension(21) :: meanspec,sigspec,rho_jb,psa_hr	!for each request. Fills inside each GMPE subroutine.
c psa_hr is an array of hard-rock medians for ASK13, needed in later CMS calculations (added dec 2013)
c
c New Oct 28, 2010: add bookkeeping for mean source spectrum. in each M,R bin. Work in progress.
c  N Luco will better define model. Early effort is just a proof of concept.
c meanspec is a mean spectrum for  sources in a given M,R bin from a specific attn model. The spectrum
c is the median SA at a predefined set of periods. This set is defined in ms_p(j). The set of indexes
c of attenuation model ia is stored in imsp(ia,j), j=1,...,npnga
	real, dimension(21):: ms_p,st
	integer imsp(8,21),kmsp(0:10)
	logical, dimension(3):: callme
	logical lmsp(0:10,21),ltmp(21),lceus_sigma/.false./	!.true. if GMPE ia can handle  period ms_p(ip), .false. otherwise.
c Fault deagg array storage, indexed by fault number (ift), GMuncert, and spectral period
      real, dimension (nfltmx,5,0:10):: frbar,fmbar,febar,fhaz
      real prob5(17,33,10,5,0:10,5)	!30 possible M bins M5.8 to M8.7 by 0.1 dM. Less than 1megabyte storage
      integer ip,nrupdd,ii,igpmax/0/,icy12      
c      character*12 sname(2)    !station names might be useful.
      character*12, dimension(-10:39) :: att_typ   
      character*32, dimension(nfltmx) :: aft	!fault names may go into report  
      real ar(nfltmx,6)      !aspect ratio for floating ruptures. Can have 5 downdip
      logical ss,rev,normal,obl,nearsrc,l_ms/.false./,l_gnd_ep ,useRy0
c l_ms = .true. if you want to compute mean spectrum in each R,M,ia bin. This becomes true if iarg()=?   
      logical dea_attn,lb0,cluster,grid,isok,norpt(8,8),noshow
      logical segin,geog/.false./
c     grid = true if stations form a regular grid
c firstf is a logical variable to instruct code to perform certain fault calcs
c the first time the fault is worked on. When many stations are present, it makes
c sense to economize on these repeated fault calcs. New Nov 15 2006.
c Some of these laborious calcs only necessary for nearby sources. Logical
c variable nearsrc is true if nearest distance to current fault < 30 km.
c Variable poly is true if arg2 is polygon  file.
c fault sources will be included only if f_is_in(ift)=.true. 
c norpt(ip,ia) is true if no report has been filed for fault(ift) (deterministic
c      calcs only)
       logical, dimension(nfltmx):: firstf,f_is_in,nodowndip
c type replaces structure & requires gfortran or f95 to compile. It is included
c so that this code has compatibility with Linux cluster-computer compilers.
      real magmin(nfltmx,12),magmax(nfltmx,12), mmax,clamp(8),wts
c clamp can limit the probabilistic motion in CEUS. THis is applied in main
c in deaggFLTH.2013   (Clamp applied in CEUS only. Set clamp(i) to 0 to skip this constraint).
      real dbasin,vs30,Z1,pr,rx,ry,lnSa
      real, dimension (5) :: prdsom
      integer nmag,ix0,ix1,iy0,jsegmin/10/,jsegmax/0/,hwflag
      character*128 nameout,adum,outdir,name
      character*12 g_name(5)
c cluster group names, currently g1,g2,g3,g4,g5. Could be more geographic such as w1, w2, c0, e1, e2.
c Could be input
c      character*4 gname(5)	!grouped cluster region-name 
       common/sdi/sdi,dy_sdi,fac_sde
       common/ask/psa_hr
      common/cb13p/Percb13
      common/mech/ss,rev,normal,obl
      common/dipinf/dipang,cosDELTA,cdipsq,cyhwfac,cbhwfac
c hardrock is true if Vs30 >=2000 m/s or greater (why not 1500 m/s)
c      common/hardrock/hardrock
	common/cluster/prob_s
      common/epistemic/l_gnd_ep,gnd_ep,ide,ime
      common/fault/x,y,u,v
      common/ms/ia,jms,npnga,l_ms,lmsp,imsp,meanspec,sigspec
      common/ms2/icu_2_nga(7),k_ms,k_mss,k_mst
      real*8 dp,dp2,pr0,prl,prlr,prr,plim
      real*8 emax/3.0/, sqrt2/1.4142135623730951/
      real a10,xmob0,xmorate,sum,alet/0.0/
      logical byeca,byeext,byeoreg,hwsite,byenv,cal_fl,bfault,sdi/.false./
c determ = true if deterministic model: make nrec -100 for gridded smaple or -n,
c for n=1,30 for station set.
c cal_fl: true if  California floating eq. If true use length based on xmag(area)
c for california faults Hanks? or Ellsworth?
c
c hwsite: once ascertained that a site is on hanging wall many calcs can be bypassed.
c for footwall, same is true but code not altered for this case.
c some arrays for BSSA NGAW model 11/2012
      real, dimension (990,4,nfltmx) :: u,v      
      real, dimension (10) :: dmbranch,wtbranch,grp_rate
      real,dimension(11):: pertoro
      real prd(105),prob(5,10),mbarc(5),rbarc(5),ebarc(5),wt(10,2),wtdist(10)
	real gweight(5) 
	real baz	!back-azimuth tmp storage.
      integer, dimension(10):: iatten,irab
      real fac_sde
c ipertp = map to tabakoli-pezeshsk;iperb = map from input file to boore set of per
c irab is an index for 4 possible varieties of the AB06 model. 2 for 140 bar & 2 for 200 bar stress
c irab became 2-D on December 5, 2007. S Harmsen.
      integer ifn,isz,ia,ipera,iperb,iperk,nscene,nft,nattn,nfi,ngroup,
     + npnga/21/,ipas13,ipcb12,ipercy,isomer
c npnga is the number of periods to use when sampling mean spectra, nga models.
c other GMPES have far fewer periods available. 
c m_att is a master index list. The index that combine_cms recognizes 
	integer, dimension(10)::  m_att
      integer, dimension (nfltmx) :: itype,npts,npts1,iftype,ibtype
      logical, dimension(10) :: nga,wus02,ceus02,ceus11      
c logical variables for subsets of attenuation models should help narrow
c the search more efficiently.  
c Benioff or deep-seismicity relations n/a here: see gridded hazard code hazgridXnga2.f      
c new 6/06: potentially variable a and b values for up to 12 branches for each fault
c Provides extra flexibility to model epistemic uncertainty of size of eq. 
c dmag also needs a branch-specific
c value. The customary 0.1 dM wont work when M precision is carried to 2 dec. places
      real, dimension (0:37) :: perka
      real, dimension (6) :: ptail
      real, dimension(8):: perx
      real, dimension(15):: per_camp
      real, dimension(23):: perAS13
      real, dimension(22)::PerIMIdriss
      real, dimension (24) :: percy13
      real, dimension(35):: pergk13
      real, dimension(nfltmx,12) :: a,b,dmag
      real, dimension(nfltmx,12):: cmag,crate
      real, dimension(nfltmx,2) :: fbaz
      real, dimension (107):: perbssa13
      real, dimension (108) :: peras08
c fbaz= storage of cos(backazimuth), sin(backazimuth) for each fault. Averages thru
c fault uncert (along strike, down dip, and M uncert on GR branches)
      real, dimension(nfltmx):: dip,dip0,width,depth0,tlen
c Below, the array constructor business. No repeat (8*.01) unlike data statement.
c gfortran required replacement of "data" statements in our Linux PC system. 10/06. SH.
c 
c Abrahamson Silva 2013 model 23 periods but #23 is bogus.
      data perAS13 /0., 0.02, 0.03, 0.05, 0.075, 0.1, 0.15, 0.2, 0.25, 0.3,
     1             0.4, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 6., 7.5, 10., -1. /
      DATA pergk13/0.01,0.02,0.03,0.04,0.06,0.08,0.1,0.12,0.14,
     &         0.16,0.18,0.20,0.22,0.24,0.27,0.30,0.33,
     &         0.36,0.4,0.46,0.5,0.6,0.75,0.85,1.0,1.5,
     &         2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0/
c atkinson and pezeshk 2011 frequency set in a11fr (added June 17 2013)
       a11fr =(/0.20,    0.33, 0.50, 1.00, 2.00, 3.33, 5.00,10.00,20.,33.00,50.00,99.00,89.00/)
	       imsc_ga= (/19,17,16,14,12,10,8,6,4,3,2,1/)
c perbssa13 is the available set of spectral periods for the  April 2013 BSSA NGAW gmpe
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
     + 5.500000, 6.000000, 6.500000, 7.000000, 7.500000, 8.000000, 8.500000, 9.000000, 9.500000,10.000000/)
c abper is the set of spectral periods for the AB2006 CEUS model. -1 => PGV
c Abper: change 0.39... to 0.4 to get a match with this value in cms set: sept 16 2013.
      abper = (/5.0000, 4.0000, 3.0, 2.5000, 2.0000, 1.5, 1.2500, 1.0000,
     1 0.75, 0.6289, 0.5000, 0.4, 0.3, 0.2506, 0.2000, 0.1580,
     1 0.1255, 0.1, 0.0791, 0.0629, 0.05, 0.04, 0.03, 0.0250,
     1 0.0000, -1.000/)
c Campbell hybrid CEUS
       per_camp = (/0.01,0.2,1.0,0.1,0.3,0.4,
     + 0.5,2.0,.03,.04,.05,1.5,3.,0.75,-1.0/)
       peras08= (/ 0.0, -1.0, -2.0, 0.01, 0.02, 0.022, 0.025, 0.029,
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
c Idriss 2012 set:
        PerIMIdriss  = (/0.01,0.02,0.03,0.04,0.05,0.075,0.1,0.15,0.2,0.25,0.3,0.4,
     + 0.5,0.75,1.,1.5,2.,3.,4.,5.,7.5,10./)

c Somerville IMW period set (5 of 'em). pga is 0.0
       prdsom=(/0.000,0.200,0.300,1.000,5.000/)
c Silva period set.
      pdSilva=(/0.,0.04,0.05,0.1,0.2,0.3,0.4,0.5,1.,2.,5.,-1./)
c Campbell-Bozorgnia period set July 2013.
	PerCB13=(/0.01,0.02,0.03,0.05,0.075,0.1,0.15,0.2,0.25,0.3,0.4,
     + 0.5,0.75,1.,1.5,2.,3.,4.,5.,7.5,10.,0.,-1./)
c Chiou-Youngs May 2013 (remove PGD and PGV coeffs apr 2013 add 0.12 aand 0.17)
       percy13=     (/0.0100, 0.0200, 0.0300, 0.0400, 0.0500,
     1              0.0750, 0.1000, 0.1200, 0.1500, 0.1700,
     1              0.2000, 0.2500, 0.3000, 0.4000, 0.5000,
     1              0.7500, 1.0000, 1.5000, 2.0000, 3.0000,
     1              4.00, 5.00, 7.50,10.0/)

c Tavakoli periods 0 = pga. added 0.04 & 0.4 s july 8 2008 (spline interpolation)
      tpper = (/0.0,.04, 0.05, 0.08, 1.00e-01,1.50e-01,2.00e-01,
     1 0.3, 0.40, 0.5, 0.75, 1.0, 1.50, 2.0, 3.0, 4.0,-1.0/)
c Toro et al. period set add 0.03, 0.04 0.40 for CMS work. June 2011.
       pertoro = (/0.,0.2,1.0,0.1,0.3,0.5,2.0,0.03,0.04,0.4,-1./)
c perka = period set for Kanno et al., BSSA 2006. 0 = pga.
       perka=(/0.0,0.05,0.06,0.07,0.08,0.09,0.10,0.11,0.12,0.13,0.15,0.17,0.20,
     +0.22,0.25,0.30,0.35,0.40,0.45,0.50,0.60,0.70,0.80,0.90,1.00,1.10,1.20,
     +1.30,1.50,1.70,2.00,2.20,2.50,3.00,3.50,4.00,4.50,5.00/)
c perb = Boore-Atkinson NGA 4/2007 period set, -1 = pgv. N(T)= 23. 10 s is longest.
      perb= (/-1.000, 0.000, 0.010, 0.020, 0.030, 0.050, 0.075, 0.100,
     + 0.150, 0.200, 0.250, 0.300, 0.400, 0.500, 0.750, 1.000,
     + 1.500, 2.000, 3.000, 4.000, 5.0, 7.5, 10.0/)
c perx = a default set of spectral periods used in 2002 PSHA maps. PGV=-1 was not
c available then and should not be tried for those models
        perx=(/0.,0.2,1.0,0.1,0.3,0.5,2.0,-1./)
c       perxx = (/0.,0.1,0.2,0.3,0.5,1.0,2.0,3./) !want this but cant have it
       gmwt = (/0.63, 0.185, 0.185/)	!weights for gm uncert branches
       clamp = (/3.,6.,3.,6.,6.,6.,3.,300./)
       aperiod = (/ 0.0,0.01,0.02,0.03,0.04,0.05,0.075,0.1,0.15,
     1  0.2,0.25,0.3,0.4,0.5,0.75,1.,1.5,2.,3.,4.,5.,-1.0/)
c camper=Campbell-Bozorgnia NGA spectral period set, from 03-08 final report. 
c 0.0=pga here, equiv to 0.01 in their report. -1=pgv, -2=pgd set
      camper =(/0.01,0.020,0.030,0.050,0.075,0.100,0.150,0.200,0.250,0.300,0.400,
     1 0.500,0.750,1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 7.5,10.0,0.,-1.0,-2./)
c prd is the C&Y period set, 105 of 'em, june 2006. Same, Oct 2007. PGA=0.0s in our code. 
      prd= (/0.01,0.020,0.022,0.025,0.029,0.030,0.032,0.035,0.036,0.040,0.042,0.044,0.045,0.046,
     10.048,0.050,0.055,0.060,0.065,0.067,0.070,0.075,0.080,0.085,0.090,0.095,0.100,0.110,0.120,
     10.130,0.133,0.140,0.150,0.160,0.170,0.180,0.190,0.200,0.220,0.240,0.250,0.260,0.280,0.290,
     10.300,0.320,0.340,0.350,0.360,0.380,0.400,0.420,0.440,0.450,0.460,0.480,0.500,0.550,0.600,
     10.650,0.667,0.700,0.750,0.800,0.850,0.900,0.950,1.000,1.100,1.200,1.300,1.400,1.500,1.600,
     11.700,1.800,1.900,2.000,2.200,2.400,2.500,2.600,2.800,3.000,3.200,3.400,3.500,3.600,3.800,
     14.000,4.200,4.400,4.600,4.800,5.000,5.500,6.000,6.500,7.000,7.500,8.000,8.500,9.000,9.500,
     110.0/)
c initial set of predefined periods T at which mean spectrum is to be determined. Oct 28 2010.
       ms_p = (/0.010, 0.020, 0.030, 0.050, 0.075, 0.100,
     + 0.150, 0.200, 0.250, 0.300, 0.400, 0.500, 0.750, 1.000,
     + 1.500, 2.000, 3.000, 4.000, 5.0, 7.5, 10.0/)
       ptail = (/0.9772499,.8413447,0.5,.1586553,.022750139, 0.0013499/)
	icu_2_nga=(/1,8,14,6,10,12,16/)
c      pithy = (/'Using Median','Median+EpUnc','Median-EpUnc'/)
      g_name =(/'Cluster GRP1','Cluster GRP2','Cluster GRP3','Cluster GRP4','Cluster GRP5'/)
c att_typ is a local matchup. not the same as the one in combine_cms.2013.f
      att_typ =  (/ 'CampH CEUS A','Space Unoccu','Space Unoccu',
     1 'Somervill HR','FeaHard CEUS','AB-hard CEUS','A&BHR CEUS06',
     1 'Somervil IMW','TORO-CEUS HR','Space Unoccu','Truth -  N/A',
     1 'Spudich 2000','TORO-CEUS BC','Sadigh ea 97',
     1 'A&B06BC CEUS','AB95-CEUS BC','Frankel eaBC','Somervill BC',
     1 'Abr-Silva 97','Campbell2003',
     2 'Camp CEUS BC','BJF     1997','Mota ea PRVI',
     2 'B&A 03/08NGA','C&B03/08 NGA',
     2 'ChiouY 03/08','Ab-Sil NGA08','Idriss   PGA','Kanno ea2006',
     2 'T&P CEUS  06','Silva CEUS02','AB06s200CEUS',
     3 'Space Unoccu','Space Unoccu','Space Unoccu',
     3 'AB08p Prelim','AB06p Prelim','Pez11 Prelim','Silva M-depS',
     3 'Space Unoccu','Space Unoccu','Space Unoccu',
     3 'Space Unoccu','BSSA 03/2013','C&B02/13 NGA',
     3 'ChiouY 03/13','Ab-Silva2013','IIdriss 2013','GraizKalkn12',
     4 'GrazKalkan09'/)
c       gname=(/'West','MidW','Midl','MidE','East'/)
c        gweight = (/0.05,0.1,0.7,0.1,0.05/)	!branch weights for geographically groups of clustered
c earthquakes.
c Oct 2013: Read in gweight from a field in the source description
      nga=.false.
      wus02=.false.
      ceus02=.false.
      ceus11=.false.
            callme=.true.
      mcut(1)=6.0
      mcut(2)=7.0
      dcut(1)=10.
      dcut(2)=30.
      gnd_ep=0.      !initialize epistemic variation of gnd to 0.
	wtsum=0.
c Initialize truncated normal array Pex, store in p().
        prl=0.5*(erf(emax/sqrt2) + 1.0)
        prlr=1.0/prl
        prr=1.0-prl
        plim=-emax/sqrt2
        pr0=plim
        dp=0.000004*(3.3-plim)
        dp2=1.0/dp
        p(1)=1.e-9
        do i=2,250001
        pr0=pr0+dp
        p(i)=((erf(pr0)+1.)*0.5-prr)*prlr
        enddo
        p(250002)=1.0
        grp_rate=0.0	!may accumulate wt*rate for clustered event groups
        gweight = 0.0
c End initializing the truncated normal PEx() array=p()
c The indep. variable is a real*8 to reduce discretization error.
 900  format(a)
      call getarg(1,name)
c      headr%name(1)= name(1:30)
      inquire(file=name,exist=isok)
      if(isok)then
      open(unit=1,file=name,status='old')
      else
      write(6,*)'deaggFLTH.2013  : File not found: ',name
      stop 'Put in working dir and retry'
      endif
c deaggregation information. initialize most to zero.
      haz=0.
      rbar=0.
      ebar=0.
      mbar=0.
      fmbar=0.; frbar=0.; febar=0.; fhaz=0.
      prob5=0.
      fbaz=0.
      call getarg(2,nameout)
      call getarg(3,adum)
      read(adum,'(f7.4)')rlatd
      ymax=rlatd
      call getarg(4,adum)
      read(adum,'(f9.4)')rlond
c rlatd rlond are the coordinates of the deagg-analysis site. This location overrides the stuff
c in the input file.
	if(abs(30.-rlatd).lt.15..and.abs(140.-rlond).lt.11.)then
	SJ=1.	!in Japan or thereabouts
        iReg = 10		!Japan
        elseif(abs(22.-rlatd).lt.3..and.abs(121.-rlond).lt.3.)then
        iReg = 3	!Taiwan, for ASK 13 code.
	else
	SJ=0.	!Western USA Taiwan or other similar tectonics
	iReg = 1
	endif
      call getarg(5,adum)
      read(adum,'(f4.2)')period
      nper=1
c adum could be sa(g) or pgv (cm/s). need flexi format
      call getarg(6,adum)
      read(adum,'(f9.6)')safix
c      write(6,,*)'#command line sa ',safix
      call getarg(7,adum)
      read(adum,'(f6.1)')vs30
c the below Z1 is defined from Brian Chiou's recommendation. 2013 update.
c Units m.
c updated slightly apr 15 2013 to avoid overflow
        Z1cal = exp(-7.15/4 * log(((VS30/1000.)**4 + .57094**4)/(1.360**4 + .57094**4)))
c     Norm Abrahamson's CA z1 reference (eq 18) units: km.
       z1_ref = exp ( -7.67/4. * alog( (Vs30**4 + 610.**4)/(1360.**4+610.**4) ) ) / 1000.
	z1=z1cal	!CY2013 function used until we know better for wus...
	z1km = Z1*0.001	!for AS need units km
c this Z1 is  the recommended value of CY. May need to be changed (40 m for 760 m/s vs30)
c      write(6,,*)' Vs30 (m/s), Z1 (m) and depth of basin (km): ',vs30,Z1,dbasin
      if(vs30.lt.90..and.vs30.gt.0.)then
c      write(6,,*)'Vs30 = ',vs30,'. This looks unreasonable.'
      stop'please check input vs30'
      endif
      vs30_class = 1	!assumed vs30 is measured. 
       dbasin = exp(7.089 - 1.144*alog(vs30) )	!New Campbell default depth Z25 may 22 2013
	call getarg(9,outdir)
      isize=index(outdir,' ')-1
      nameout=outdir(1:isize)//nameout
       isz=index(nameout,' ')-1
c new apr 2008, argument to control whether to deagg individual GMPE logic-tree branches.
	call getarg(10,adum)
	read(adum,'(i1)')i
	if(iargc().gt.10)then
	call getarg(11,adum)
	read(adum,'(i1)')j
	geog=j.eq.1
	l_ms=j.eq.2	!temp instruction to compute mean spectra (if including arg 11 but no geogrphic)
	endif	
	dea_attn = i .gt.0
      write (6,61)name
61      format('# *** deaggFLTH.2013  vers. 01/22/2014 log file. ',/,
     +'# *** Input control file: ',a)
c Below bypasses are based on input-file name. Bypass wont work if file names change
      byeext=index(name,'brange').gt.0
      byenv = index(name,'nv.').gt.0
c Calif fault file names 6/2007: aFault bFault
      byeca=index(name,'a_Fault').gt.0.
     1  .or.index(name,'b_Fault').gt.0
c Oregon/Washington: orwa_c or orwa_n beginning of file names.
      byeoreg=index(name,'orwa').gt.0
      cal_fl = index(name,'_unseg').gt.0 	!A-floaters. creeping section included here.
      bfault = index(name,'b_Fault').gt.0
c above name is used to determine if CAL floater: need a better way.
c creeping section is also host to california floaters. Parkfield did not rupture to
c surface. After short discussion with Wesson, I did not include creeping sec
c set of calif. floaters that always rupture to surface. 
c      write(6,*)'Enter a zero for grid of sites 1 to 30 for list: '
	i=1
      slat(i)=rlatd
      slong(i)=rlond
c      sname(i)='deag'
c      write(6,,*)slat(i),slong(i),sname(i)
      if(slat(i).lt.-88.)stop 'invalid station location. Version 7c?'
      slat(1)=rlatd
      slong(1)=rlond
      nx=1
      ny=1
      srcSiteA=90.      !this angle should vary with site location. See delaz calls
c      write(6,*) "enter distance increment, dmax"
      read(1,*) di,dmax
c      write(6,,*)'Distance increment and dmax (km): ',di,dmax
cccccccccccccccccccccccccccccccccc
c add epistemic uncert to gm relation? wind=1 to make it so.
      read(1,*)  wind
      per= period
      ip=1
      k=1
      dowhile(per.ne.perx(k))
      k=k+1
      if(k.gt.8)then
c      write(6,,*) '*** Input period not in 2002 group ***', per
c      write(6,,*)'Warning: some atten relations may not be ready.'
c      write(6,,*)'Warning 2: clamp is only prepared for 2002 group.'
      k=6
      goto 801      !not really a solution
      endif
      enddo
801    continue 
c       write(6,*)'Period ',per,' underway'
      iper=k
      if(wind.gt.0.)then
      cluster=.false.
      l_gnd_ep=.true.
      do im=1,3
      read(1,*)gnd_ep(1,im),gnd_ep(2,im),gnd_ep(3,im)
c increase or decrease logged median gm by equal amounts in the atten subroutines
      enddo      !im loop
      nfi=3
      ngroup=1
c      icc(ip,1)=9+ip
      elseif(wind.eq.0.)then
      gmwt=1.0
      nfi=1
      ifn=1      !always use index 1 for this case.
      ngroup=1
      cluster=.false.
c      icc(ip,1)=9+ip
      else
c current indicator to perform clustering is wind < 0. You can make up to 5 independent clustered-event curves
c set wind=-1 for one, wind=-2 for 2, ..., wind = -5 for 5. These could be the 5 virtual NMSZ faults in 2002 hz model
c The use of this variable for different things depending on its sign might be considered clumsy & contemptible.
c Should be revised.
	gmwt=1.0
      nfi=1
      ifn=1
      cluster=.true.
      ngroup=abs(wind)
      r_s=0.; m_s=0.; e_s=0.; prob_s=0.0
      endif      !if additional epistemic sigma is read in or model clustering is asked for: one or the other
c but not both at least initially
       if(nfi.ne.3.and.nfi.ne.1)then
       stop'deaggFLTH.2013 not ready for deagg with nfi not 1 or 3'
       endif
c677	format('#deaggFLTH.2013   sources. Sp_Per= ',f5.2,' s. Run on ',a,' at ',a,/,
c     +'# *** Input control file: ',a,/,
c     +'#MedianSA(g)     sd   iatt  iflt    M  Rjb(km) Rcd(km)  Wt*Rate',
c     +' Dtor(km) SlipCode EPS_AT')
c       do kg=1,ngroup
c       if(cluster)then
c       nameout=nameout(1:isz)//gname(kg)
c       icc(ip,kg)=9+ip+9+kg
c       endif
c if ascii put each curve in same output file. Slight repair May 1 2008. SH.
c      if(kg.eq.1)then
c cannot have both deaggregation and determinstic output. Safe to use same unit number.
c First try: deagg. epistemic gm uncert or CEUS geographic flt loc uncert will get combined into
c same rbar, mbar, ebar, haz array. These could be separated if nec (add a "kg" dimension).
c open ascii deagg output. Index arrays by distance, magnitude, epsilon, gmuncert, period.
      open(21,file=nameout,status='unknown')
      write(21,907)safix,period,name,rlatd,rlond,vs30
c Separate file for individual fault hazard. Does SAF dominate S Hayward at site S, etc?
      open(41,file=nameout(1:isz)//'.FDEAG',status='unknown')
      if(geog)then
      open(61,file=nameout(1:isz)//'.GEOG',status='unknown')
      write(61,939)safix,period,name,rlatd,rlond,vs30
      elseif(l_ms)then
c      open(31,file=nameout(1:isz)//'.SPCTRA',status='unknown')
c unit 33 is binary, used when combining.
      open(33,file=nameout(1:isz)//'.bin',status='unknown',form='unformatted')
c      write(31,907)safix,period,name,rlatd,rlond,vs30
      write(33)safix,period,rlatd,rlond,vs30
c      open(32,file=nameout(1:isz)//'.MEANSPC',status='unknown')
c      write(32,907)safix,period,name,rlatd,rlond,vs30
      hazmsp=0.	!initialize if needed
      wtmsp=0.
      rmsp=0.; mmsp=0.	!rbar,mbar for the source spectra in bins.
      epsmsp=0.
      meanspecs=0.
      mean2spec=0.
      mean2haz=0.
      mean2r=0.
      mean2m=0.
      mean2e0=0.
      	kmsp(0)=npnga	!initialize assuming full set of periods may be computed
c intialize rho_jb from the article in Baker Jayaram, Eq Spectra Mar 2008.
	t1=period
	do i=1,npnga
	t_min=min(t1,ms_p(i))
	t_max=max(t1,ms_p(i))
	c1=(1.-cos(pi2-alog(t_max/max(t_min, 0.109))*0.366))
	if(t_min .eq. t_max)then
	rho_jb(i)=1.0
	else
	if(t_max.lt.0.2)
     +   c2=1.0-0.105*(1.-1./(1.+exp(100*t_max-5.)))*(t_max-t_min)/(t_max-0.0099)
	if (t_max .lt.0.109)then
	c3=c2
	else
	c3=c1
	endif
	c4=c1+0.5*(sqrt(c3)-c3)*(1.+cos(pi*t_min/0.109))
	if (t_max .le. 0.109)then
	rho_jb(i) = c2
	elseif(t_min .gt. 0.109)then
	rho_jb(i) = c1
	elseif(t_max .lt. 0.2)then
	rho_jb(i) = min(c2,c4)
	else
	rho_jb(i) = c4
	endif
	endif
c	print *,ms_p(i),rho_jb(i)
        if(abs(ms_p(i)-max(period,0.01)).lt.0.002)jms=i
	enddo
	if(rlond.ge.-115.)then
	if(period.le.0.01)then
	k_ms=1
	else
	i=2
	dowhile(abs(ms_p(icu_2_nga(i))-max(period,0.01)).gt.0.002)
	i=i+1
	if(i.gt.7)stop'unavailable period for cms'
	enddo
	k_ms=icu_2_nga(i)
	endif
	print *,i,k_ms,' CEUS index and corresponding NGA index for input pd'
	endif	!Central & eastern longitude
      endif	!if l_ms
      write(41,929)safix,period,name,rlatd,rlond,vs30
 907	format('#deaggFLTH.2013 deagg @SA=',f5.3,' g. T='f5.2,
     +' s,  fi ',a,
     +/,'#site lat long = ',f8.4,1x,f9.4,' Vs30 (m/s) ',f6.1)	
 929	format('#deaggFLTH.2013 deagg @SA=',f5.3,' g. T='f5.2,
     +' s,  fi ',a,
     +/,'#site lat long = ',f8.4,1x,f9.4,' Vs30 (m/s) is ',f6.1,/,
     +'#Rbar(km)  Mbar(Mw) E0bar Wt*Rate_Exc Sta_to_SrcAz(d) Fault Name  ')
 939	format('#deaggFLTH.2013 geog_deagg @SA=',f5.3,' g. T='f5.2,
     +' s,  fi ',a,
     +/,'#site lat long = ',f8.4,1x,f9.4,' Vs30 (m/s) is ',f6.1,/,
     +'#IFLT Wt*Rate Rbar(km)  Mbar(Mw)  Sta_to_SrcAz(d) Fault Name  ')
c      endif	!open up those 3 files.	
c      write(6,*) "enter number of ground motion levels"
         nlev=1
         xlev=safix
       xlev= alog(xlev)
c-----------
c      write(6,*) "enter number of atten. relations for this period"
      read(1,*) nattn
c      write(6,,*)"number of atten. relations for this period ",nattn
c--- loop through atten relations for that period
      do 701 ia=1,nattn
c      write(6,*) "enter type of atten. relation, weight1, wtdist, 
c     &  weight2 , mb to M conv."
      read(1,*) iatten(ia),wt(ia,1),wtdist(ia),wt(ia,2),
     &   icode(ia)
      iatt=iatten(ia)
      if(iatt.lt.12.and.vs30.gt.1490.)then
c this little check uses the hard rock attenuation for CEUS. WUS should
c not have vs30 > 1500
	iatt=-iatt
        iatten(ia)=iatt
      endif
c add Somerville  imw to WUS02 set (even though it is more recent than 2002).
c This relation will need more periods and site response if  it is to be 
c routinely used. Added for special studies Jan 19 2007. SHarmsen.
	iaa=abs(iatt)
	m_att(ia)=iaa		!this has to change to a master list. temp soln
       wus02(ia)=ia.eq.1 .or.iaa.eq.3.or.
     1 iaa.eq.8.or.iatt.eq.9.or.iaa.eq.11
       ceus02(ia)=iaa.eq.2 .or.iaa.eq.19.or.iaa.eq.20.or.
     1 iaa.eq.4.or.iaa.eq.5.or.iaa.eq.21.or.
     1 iaa.eq.6.or.iaa.eq.7.or.iaa.eq.10
       ceus11(ia)=iaa.gt.24.and.iaa.lt.28  !new mar 2011.
       nga(ia)=(iaa.gt.12.and.iaa.lt.19).or.iaa.gt.32
c kanno et. al. is included with NGA even though it's not. But is modern.
c prepare look-up tables for certain CEUS relations.
c First group, the 2011 tables from Gail A.
        if(ceus11(ia))then
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
        freq=a11fr(kf)
        if(iatt.eq.25)then
        m_att(ia) = 30
        if(callme(1))then
        print *,'calling GailTable A08revA_Rjb fr,per,kf=',fr,per,kf
        name ='GR/A08revA_Rjb.dat'
        name=trim(name)
             open(3,file=name,status='old',err=202)
        call GailTable(1)
        callme(1)=.false.
        endif 
        ia08=kf  
        elseif(iatt.eq.26)then
        m_att(ia) = 32
         if(callme(2))then
       name ='GR/AB06revA_Rcd.dat'
        print *,'calling GailTable AB06revA_Rcd fr,per=',fr,per,kf
             open(3,file=name,status='old',err=202)
       call GailTable(2)
       callme(2)=.false.
       endif
        ia06=kf 
        elseif(iatt.eq.27)then
        m_att(ia) = 25
        if(per.lt.0.0)stop' Pezeshk 2011 does not have PGV coeffs'
        if(callme(3))then
        name= 'GR/P11A_Rcd.dat'
             open(3,file=name,status='old',err=202)
       call GailTable(3) 
        print *," just read Gail's Pezeshk 2011 A-table",fr,per,kf
       callme(3)=.false.
       endif   !read table 3?
        ip11=kf
	do j=1,12
	lmsp(ia,imsc_ga(j))=.true.
	imsp(ia,imsc_ga(j))=j
c	print *,lmsp(ia,imsc_ga(j)),imsp(ia,imsc_ga(j)),a11fr(j)
	enddo	!j=1,12 
c For new CEUS relations t=5.0 s longest available period (fr=0.2 Hz). Index of 5s is npnga-2
	kmsp(ia)=npnga-2 ; kmsp(0)=min(kmsp(0),npnga-2)
       endif       !if ia = 25, 26, or 27
       endif		!ceus11?
       if(iatt.eq.6) then
       call getFEAtab(iper,1)
c      write(6,,*)'FEA BC table OK for period ',perx(iper)
       elseif(iatt.eq.5) then
       call getFEAtab(iper,2)       
c       write(6,*)'ABceus BC table OK for period ',perx(iper)
       elseif(iatt.eq.-6)then
       call getFEAtab(iper,3)
c       write(6,*)'FEA hardrock table OK for period ',perx(iper)
      if(vs30.lt.800.)write(6,*)'Warning: vs30 ',vs30,' not consistent with HR'
       elseif(iatt.eq.-5)then
       call getFEAtab(iper,4)
c       write(6,*)'ABceus hardrock table OK for period ',perx(iper)       
      if(vs30.lt.800.)write(6,*)'Warning: vs30 ',vs30,' not consistent with HR'
       endif
             wtsum=wtsum+wt(ia,1)
             if(wtsum.gt.1.01)then
c             write(6,*)' For period ',per,' sum of atten-model wts = ',wtsum
             stop'This is unreasonable. Please check input file.'
             endif
c
c      write(6,,807)att_typ(ia),ia
        if(iaa.eq.4.or.iatt.eq.21)then
        if(period.le.0.01)then
        iperab=25
        else
          ka=1
          dowhile(abs(per-abper(ka)).gt.0.001)
            ka=ka+1
            if(ka.gt.26)then
              write(6,*) 'As of 6/06 input period doesnt correspond to A&B06 set'
              stop 'Please remove this relation from input file'
            endif
          enddo
          iperab=ka 
          endif
3          if(iatt.eq.21)m_att(ia)=20	!AB 200 bar has index 20 in gridded.    
c You can call the hardrock table when Vs30 >= 1500 m/s. But not clear that AB would approve
          if(vs30.lt.1500..and.iatt.lt.0)write(6,808)vs30
          if(vs30.ge.2000.and.iatt.eq.21)then
          irab(ia)=4
          iatten(ia)=4	!redefine
c          write(6,*)'A (no S) rock & 200-bar CEUS stress parameter assumed for AB06'
          elseif(vs30.lt.2000..and.iatt.eq.21)then
          irab(ia)=3
          iatten(ia)=4	!redefine
c          write(6,*)'Site-corrected (S) rock & 200bar CEUS stress parameter assumed for AB06'
          elseif(vs30.ge.1500..and.iatt.eq.-21)then
          irab(ia)=4
          iatten(ia)=4
c          write(6,*)'A (no S) rock & 200-bar CEUS stress parameter assumed for AB06'          
          elseif(iatt.eq.-4)then
c          write(6,*)'A (no S) rock & 140-bar CEUS stress parameter assumed for AB06'
          iatten(ia)=4
          irab(ia)=2
          else
c          write(6,*)'Site-corrected (S) rock & 140-bar CEUS stress parameter assumed for AB06'
          irab(ia)=1
          endif
c          write(6,*)ip,ka,' A&B 9/06 ip map; irab(ia)= ',irab(ia)
  808      format('You have called hardrock version of AB06 even though vs30 is ',f6.1)   
        endif
        if(iatt.eq.19)then
        if(per.le.0.01)then
        ipertp=1
        k_mst = 1
        else
          ka=2
          dowhile(per.ne.tpper(ka))
            ka=ka+1
            if(ka.gt.16)then
c              write(6,*) 'As of 7/2008 input period doesnt correspond to T&P05 set'
              stop 'Please remove this relation from input file'
            endif
          enddo
          ipertp=ka
c          write(6,*)ip,ka,' T&P 7/08 ip map'
	endif	!pga or not?
       if(l_ms)then
c fill imsp and lmsp arrays with can do information.
	imsp(ia,1)=1	!pga
	lmsp(ia,1)=.true.
	do j=2,npnga
	ka=2
	dowhile(ms_p(j).ne.tpper(ka).and.ka.lt.17)
	ka=ka+1
	enddo
	if (ka.gt.16)then
	lmsp(ia,j)=.false.
	else
	imsp(ia,j)=ka
	lmsp(ia,j)=.true.
	if(abs(per-tpper(ka)).lt.0.011)k_mst=ka
c	print *,ia,j,imsp(ia,j),lmsp(ia,j),tpper(ka)
	endif	!ka<16?
	enddo	!j=1,npnga
	kmsp(ia)=17  
	kmsp(0)=min(kmsp(0),kmsp(ia))
c	print *,ia,1,imsp(ia,1),lmsp(ia,1),tpper(1), ' TP05 concluding'
	endif	!mean spectrum details 
      if(vs30.ge.1500.)then
      irtb=-1
c      write(6,,*)'TP05 relation is called with hardrock coeff'
      else
      irtb=1
      endif
      elseif(iaa.eq.2 ) then
c toro with additional periods, june 2011.
	if(per .le. 0.01)then
	iptoro=1
	else
	ka = 2
          dowhile(abs(per-pertoro(ka)).gt.0.001)
            ka=ka+1
            if(ka.gt.10)then
C        write(6,*) 'As of 6/11 input period doesnt correspond to Toro97 set'
              stop 'Toro: please remove this relation from input file'
            endif
          enddo
          iptoro=ka
	endif		!per <= 0.01 ?
       if(l_ms)then
c fill imsp and lmsp arrays with can do information.
	lmsp(ia,1)=.true.
	imsp(ia,1)=1
c	print *,'Toroper ',ms_p(1),lmsp(ia,1),imsp(ia,1)
	do j=2,16
	ka=2
	dowhile(ms_p(j).ne.pertoro(ka).and.ka.lt.11)
	ka=ka+1
	enddo
	if (ka.gt.10)then
	lmsp(ia,j)=.false.
	else
	imsp(ia,j)=ka
	lmsp(ia,j)=.true.
	endif
c	print *,'Toroper ',ms_p(j),lmsp(ia,j),imsp(ia,j)
	enddo	!j=1,npnga 
	kmsp(ia)=16 ; kmsp(0)=min(kmsp(0),16)
	endif	!mean spectrum details 
      m_att(ia)=iaa
      elseif(iaa.eq.10)then
      kmsp(ia)=17	!campbell has 3-s coeffs. june 2011.
      kmsp(0)=min(kmsp(0),17)
      m_att(ia)=iaa
	if(per.le.0.01)then
	ipcmpc=1
	else
	ka=2
	dowhile(abs(per-per_camp(ka)).gt.0.005)
c add several periods july 17 2008
	ka=ka+1
	if(ka.gt.14)then
c      WRITE(6,*)'Input spectral period not available for CampCEUS model'
	stop 'please remove CampCEUS from the input file for this period'
	endif
	enddo
c      WRITE(6,*)'period index in CampCEUS is ',ka
	ipcmpc=ka
	endif	!if per <= 0.01s? added apr 12 2011
       if(l_ms)then
c fill imsp and lmsp arrays with can do information.
c	print *,'Campbell CEUS CMS periods?'
	lmsp(ia,2:npnga)=.false. 
	imsp(ia,1)=1
	lmsp(ia,1)=.true.
c	print *,ms_p(1),lmsp(ia,1)
	do j=2,npnga-4
	ka=2
	dowhile(abs(ms_p(j)-per_camp(ka)).gt.0.005 .and. ka.lt.15)
	ka=ka+1
	enddo
	if(ka.lt.15)then
	imsp(ia,j)=ka
	lmsp(ia,j)=.true.
	endif
c	print *,'Campbell CEUS: ',ms_p(j),lmsp(ia,j)
	enddo	!j=1,npnga 
c  end cms prepwork for Campbell hybrid (indx 10).
	endif	!compute cms?
      elseif(iaa.eq.6 .or. iaa.eq.7)then
c for several CEUS gmpes, a standard set of 7 periods have data available.
c These include Toro(2), Frankel (6), Somerville(7), 
c Some of these have other periods but those were not included
      kmsp(ia)=16
      kmsp(0)=min(kmsp(0),16)
      m_att(ia)=iaa
c      print *,ia,ia,' std 7 period fillup for CU GMPE'
      lmsp(ia,1:npnga)=.false.
      do i=1,7
      lmsp(ia,icu_2_nga(i))=.true.
      enddo	
        elseif(iatt.eq.20)then
	if(per.le.0.01)then
	isilva=1
	k_mss=1
	else
          ka=2
          dowhile(per.ne.pdSilva(ka))
            ka=ka+1
            if(ka.gt.11)then
c              write(6,*) 'As of 7/2008 input period doesnt correspond to Silva2002 set'
              stop 'Suggestion: remove this relation from input file for this period'
            endif
          enddo
          isilva=ka
          endif	!pga or otherwise
          m_att(ia)=15	!Silva is numbered 15 in the gridded-hazard atten list.
       if(l_ms)then
c fill imsp and lmsp arrays with can do information.
	imsp(ia,1)=1
	lmsp(ia,1)=.true.
	do j=2,npnga
	ka=2
	dowhile(abs(ms_p(j)-pdSilva(ka)).gt.0.005.and.ka.lt.12)
	ka=ka+1
	enddo
	if (ka.gt.11)then
	lmsp(ia,j)=.false.
	else
	imsp(ia,j)=ka
	lmsp(ia,j)=.true.
	if(abs(per-pdSilva(ka)).lt.0.005)k_mss=ka
c	print *,pdSilva(ka),imsp(ia,j),lmsp(ia,j),' For CMS: Doable Silva period; index'
	endif
	enddo	!j=1,npnga
c	print *,'For Silva input period corresponds to index ',k_mss 
	kmsp(ia)=19	!Silva has a 5-s model 
	kmsp(0)=min(kmsp(0),kmsp(ia))
	endif	!mean spectrum details 
c          write(6,*)ip,ka,' Silva 7/2008 ip map'
          if(vs30.ge.1500.)then
          irsilva=-1
c      write(6,,*)'Silva relation is called with hardrock coeff'
          else
          irsilva=1
          endif
        endif
        if(iatt.eq.-3)then
c Somerville IMW, 5 periods
      ka=1
      dowhile(per.ne.prdsom(ka))
      ka=ka+1
      if(ka.gt.5)stop 'input period doesnt correspond to Somerville IMW set'
      enddo
       isomer=ka
      if(vs30.lt.600..or.vs30.gt.900.)then
c      write(6,,*)'********** WARNING Somerville IMW called with non-BC rock *******'
c      write(6,,*)'** Please consider modifying Somerville for this site condition**'
      endif
c For NGA relations, is the requested spectral period available?
      elseif(iatt.eq.16)then
c Below, find index from abrahamson period set
      ka=1
      dowhile(per.ne.peras08(ka))
      ka=ka+1
      if(ka.gt.108)stop 'input period doesnt correspond to abram.silva08 set'
      enddo
       ipera=ka
       if(l_ms)then
c fill imsp and lmsp arrays with can do information.
	do j=1,npnga
	ka=1
	dowhile(ms_p(j).ne.aperiod(ka).and.ka.lt.23)
	ka=ka+1
	if (ka.gt.23)lmsp(ia,j)=.false.
	enddo
	imsp(ia,j)=ka
	lmsp(ia,j)=.true.
	enddo	!j=1,npnga  
	endif	!mean spectrum details
	kmsp(ia)=17 
	kmsp(0)=min(kmsp(0),kmsp(ia))
       elseif( ia.eq.14 )then   
c Below, campbell-bozorgnia 11-07  period set
      ka=1
      dowhile(per.ne.camper(ka))
      ka=ka+1
      if(ka.gt.24)stop 'Input period doesnt correspond to Campbell-Bozorgnia 11-07 set'
      enddo
       ipercb=ka
       m_att(ia)=22  
       if(l_ms)then
c fill imsp and lmsp arrays with can do information.
	do j=1,npnga
	ka=1
	dowhile(abs(ms_p(j)-camper(ka)).gt.0.005.and.ka.lt.25)
	ka=ka+1
	if (ka.gt.24)lmsp(ia,j)=.false.
	enddo
	imsp(ia,j)=ka
	lmsp(ia,j)=.true.
	enddo	!j=1,npnga 
	kmsp(ia)=21 	!campbell and bozorgnia NGA-W.
	endif	!mean spectrum details 
c       write(6,*)ip,ipercb,' C&B 11/07 ip map'
c below added mar 6 2008 from email comment by Ken Campbell
       if(vs30.gt.1500.)stop 'Vs30 >1500 m/s and CB NGA relation does not permit this.'   
	elseif(iatt.eq.33)then
c 2013 bssa just include the coeffs in the subr. do not read in. too much detail
c
	indx_pga=2;indx_pgv=1
	m_att(ia)=iatt
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
	if(k.eq.107.and.per.ne.10.)stop' Period not found for BSSA relation.'
c      if(fix_sigma)sigt_gmpe=sigma_fx	!override table with fixed sigma jan 7 2012.
       nper_gmpe = 107
	print *,per,Perbssa13(k),' BSSA period match? Index is ',k
	endif
	indbssa=k
c 
       if(l_ms)then
c fill imsp and lmsp arrays with can do information.
	do j=1,npnga
	ka=1
	dowhile(ms_p(j).ne.Perbssa13(ka).and.ka.le.107)
	ka=ka+1
	if (ka.gt.107)then
	lmsp(ia,j)=.false.
	else
	imsp(ia,j)=ka
	lmsp(ia,j)=.true.
	endif
	enddo	!dowhile
	enddo	!j=1,npnga  
	kmsp(ia)=21 
	kmsp(0)=min(kmsp(0),kmsp(ia))
	endif	!mean spectrum requested?
	elseif(iatt.eq.34)then
	m_att(ia)=iatt
	k=1
      dowhile (Percb13(k).ne.per.and.k.lt.23)
      k=k+1
      enddo
      if(k.eq.23)stop' Requested period not found for CB13 relation.'
      ipcb13 = k
c      print *,'CB13 relation period index ',k,' for period ',per
      print *,'CB13 Depth of basin or rock with Vs2.5 is ',dbasin
      if(l_ms)then
c fill imsp and lmsp arrays with can do information.
	imsp(ia,1)=1
	lmsp(ia,1)=.true.
	do j=2,npnga
	ka=1
	dowhile(ms_p(j).ne.Percb13(ka).and.ka.lt.23)
	ka=ka+1
	if (ka.eq.23.and.ms_p(j).ne.Percb13(ka))then
	lmsp(ia,j)=.false.
	else
	imsp(ia,j)=ka
	lmsp(ia,j)=.true.
	endif
	enddo	!dowhile
	enddo	!j=2,npnga  
	kmsp(ia)=21 
	kmsp(0)=min(kmsp(0),kmsp(ia))
	m_att(ia)=iatt
	print *,imsp(ia,1:21),' CB13'
	endif	!mean spectrum requested?
	elseif(iatt.eq.38)then
c Graizer-Kalkan 2013 model with continuous SA variation with basin depth
	if (per.le.0.01)then
	ipgk12=1
	else
	k=2
	dowhile(pergk13(k).ne.per)
	k=k+1
	if(k.gt.35)stop' Graizer Kalkan model does not have this pd'
	enddo
	ipgk12=k
	endif
	write(6,*)'Calling Grazier Kalkan13 model.  Pd index ',ipgk12
	if(vs30.ge.600.)then
	dgkbasin=1.1*z1km
	else
        dgkbasin=0.75 * z1km + 0.25*dbasin      !Vladimir says his basin is 1.5 km/s isosurface. Campbell is
	endif
	write(6,*)'Graizer13 basin depth (km) set to ',dgkbasin
      Q_CA=157.	!New Q for California from Vladimir Graizer. His Q was 435
      Q_BR = 205.     ! Possible reasonable average value for basin and range Q.
      write(6,*)'Graizer13 Quality factor for California= ',Q_CA
      write(6,*)'For WUS sites with longitude>-120E, use this Q ',Q_BR
       if(l_ms)then
       imsp(ia,1)=1
       lmsp(ia,1)=.true.	!pga information
c fill imsp and lmsp arrays with can do information.
	do j=2,npnga
	ka=1
	dowhile(ms_p(j).ne.Pergk13(ka).and.ka.lt.35)
	ka=ka+1
	if (ka.eq.35.and.ms_p(j).ne.Pergk13(ka))then
	lmsp(ia,j)=.false.
	else
	imsp(ia,j)=ka
	lmsp(ia,j)=.true.
	endif
	enddo	!dowhile
	enddo	!j=1,npnga  
	kmsp(ia)=21 
	kmsp(0)=min(kmsp(0),kmsp(ia))
	m_att(ia)=38
	print *,imsp(ia,1:21),' GK13'
	print *,lmsp(ia,1:21),' GK13'
	endif	!mean spectrum requested?
      elseif(iatt.eq.13)then
      ka=1
      dowhile(per.ne.perb(ka))
      ka=ka+1
cc Below, boore/atkinson period set. 4/07 version of BA model has 23 periods. 
c  3 s SA corresponds to index 7.
c BA revision of march 2008: 23 spectral periods incl pga and pgv.
      if(ka.gt.23)then
c      write(6,,*)'Period ',per
      stop 'For this period please remove the BA relation from input file'
      endif
      enddo
       iperb=ka     
c       write(6,*)ip,iperb,' BA 4/2008 ip map'
	if(l_ms)then
c fill imsp and lmsp arrays with can do information.
	do j=1,npnga
	ka=1
	dowhile(abs(ms_p(j)-perb(ka)).gt.0.005.and.ka.lt.24)
	ka=ka+1
	if (ka.gt.23)lmsp(ia,j)=.false.
	enddo
	imsp(ia,j)=ka
	lmsp(ia,j)=.true.
c	print *,j,imsp(ia,j),ms_p(j),' BA'
	enddo	!j=1,npnga  
	endif	!mean spectrum details 
	kmsp(ia)=21 
	m_att(ia)=21
      elseif(iatt.eq.15)then
c Below, Chiou/Youngs 11/2007 period set
      ka=1
      if(per.gt.0.01)then
      ka=2
      dowhile(per.ne.prd(ka))
      ka=ka+1
      if(ka.gt.105)then
c      write(6,,*) 'As of 11/2007 input period doesnt correspond to chiou&y.set'
      stop 'Please remove this relation from input file'
      endif
      enddo
      endif
       ipercy=ka     
        call CY2007I(ka, vs30, Z1)
	if(l_ms)then
c fill imsp and lmsp arrays with can do information.
	do j=1,npnga
	ka=1
	dowhile(abs(ms_p(j)-prd(ka)).gt.0.005.and.ka.lt.106)
	ka=ka+1
	if (ka.gt.105)lmsp(ia,j)=.false.
	enddo
	imsp(ia,j)=ka
	lmsp(ia,j)=.true.
	enddo	!j=1,npnga  
	kmsp(ia)=21 
	endif	!mean spectrum details 
c        write(6,*)(ms_p(j),imsp(ia,j),j=1,npnga),' CY 11/07 ip map'   
        m_att(ia)=23
c initialize some site-related terms for the new CY relation for each spectral period.
	elseif(iatt.eq.35)then
        deltaZ1 = z1cal -
     1  exp(-7.15/4 *
     1      log(((VS30/1000.)**4 + .57094**4)/(1.360**4 + .57094**4)))
	if (per.ge.0..and. per.le.0.01)then
	icy13=1	!PGA index is 1 in May 2013 update
	write(6,*)'Calling CY2013 NGA-W with period index 3: PGA'
	else
	k=2
	dowhile(percy13(k).ne.per.and.k.lt.24)
	k=k+1
	enddo
	if(abs(percy13(k)-per).gt.0.002)stop'period not available for CY2013 GMPE'
	write(6,*)'Calling CY2013 NGA-W revision with deltaz1=',deltaz1
	write(6,*)'Calling CY2013 NGA-W with period index ',k
	icy13 = k
	endif	!pga or other?
       if(l_ms)then
       imsp(ia,1)=1
       lmsp(ia,1)=.true.	!pga information
c fill imsp and lmsp arrays with can do information.
	do j=2,npnga
	ka=1
	dowhile(ms_p(j).ne.Percy13(ka).and.ka.le.24)
	ka=ka+1
	if (ka.gt.24)then
	lmsp(ia,j)=.false.
	else
	imsp(ia,j)=ka
	lmsp(ia,j)=.true.
	endif
	enddo	!dowhile
	enddo	!j=1,npnga  
	print *,imsp(ia,1:21),' CY13'
	print *,lmsp(ia,1:21),' CY13'
	kmsp(ia)=21 
	kmsp(0)=min(kmsp(0),kmsp(ia))
	m_att(ia)=iatt
	endif	!mean spectrum requested?
	elseif(iatt.eq.36)then
	if (per.le.0.01)then
	ipas13=1
	else
	k=2
	dowhile(per.ne.PerAS13(k).and.k.lt.23)
	k=k+1
	enddo
	if(per.ne.PerAS13(k))then
	print *,' period ',per,' not available for ASK13 model'
	stop 'please remove this GMPE from your input file'
	endif
	ipas13=k
		endif
	useRy0=.false.	!dont use the Ry0 metric until verified
	print *,'Using Ry0 metric for this spectral period?',useRy0
        vs30_rock = 1180.
        z10_rock = -1.0 !mod 8/13/2013.
        vs30_class=0	!use estimated Vs30 (Abrahamson suggested.)
        print *,'ASK13: Using vs30_class = ',vs30_class
       if(l_ms)then
       imsp(ia,1)=1
       lmsp(ia,1)=.true.	!pga information
c fill imsp and lmsp arrays with can do information.
	do j=2,npnga
	ka=1
	dowhile(ms_p(j).ne.PerAS13(ka).and.ka.le.23)
	ka=ka+1
	if (ka.gt.23)then
	lmsp(ia,j)=.false.
	else
	imsp(ia,j)=ka
	lmsp(ia,j)=.true.
	endif
	enddo	!dowhile
	enddo	!j=1,npnga
	print *,imsp(ia,1:21),' ASK13'
	print *,lmsp(ia,1:21),' ASK13'  
	kmsp(ia)=21 
	kmsp(0)=min(kmsp(0),kmsp(ia))
	m_att(ia)=iatt
	endif	!mean spectrum requested?
	elseif(iatt.eq.37)then
	if(per.le.0.01)then
	k=1
	else
	k=2
	dowhile(PerIMIdriss(k).ne.per.and.k.lt.22)
	k=k+1
	enddo
	if(k.eq.22.and.per.ne.10.)stop' Period not found for IMIdriss relation.'
	endif	!pga or other spectral accel?
	idriss=k
	print *,'Idriss relation period index ',k,' for period ',per
       if(l_ms)then
       imsp(ia,1)=1
       lmsp(ia,1)=.true.	!pga information
c fill imsp and lmsp arrays with can do information.
	do j=2,npnga
	ka=1
	dowhile(abs(ms_p(j)-PerIMIdriss(ka)).gt.0.002.and.ka.lt.22)
	ka=ka+1
	if (ka.eq.22.and.abs(ms_p(j)-PerIMIdriss(ka)).gt.0.002)then
	lmsp(ia,j)=.false.
	else
	imsp(ia,j)=ka
	lmsp(ia,j)=.true.
	endif
	enddo	!dowhile
	enddo	!j=1,npnga  
	kmsp(ia)=21 
	kmsp(0)=min(kmsp(0),kmsp(ia))
	m_att(ia)=iatt
c	print *,imsp(ia,1:npnga),ms_p(1:npnga),' idriss'
	endif	!mean spectrum requested?
	
        elseif(iatt.eq.18)then
      ka=0
      dowhile(per.ne.perka(ka))
      ka=ka+1
      if(ka.gt.37)then
c      write(6,,*)'Period ',per
      stop 'For this period please remove the Kanno relation from input file'
      endif
      enddo
       iperk=ka     
c       write(6,*)ip,iperk,' Kanno 10/06 ip map '   
c vsfac used for site-amp in  the Kanno et al. relation.
        vsfac=alog10(vs30)          
      endif      !spectral period indexes for NGA relations
c      if(ia.eq.1)headr%name(2)=att_typ(ia)
c807      format(a12,1x,'attenuation model assoc. with index ',i1)
 701  continue
c determine whether period j can be computed for the mean spectrum
	if(l_ms)then
	lmsp(0,1:npnga)=lmsp(1,1:npnga)
	do ia=2,nattn
	lmsp(0,1:npnga)=lmsp(0,1:npnga) .and. lmsp(ia,1:npnga)
	enddo
	endif	!if l_ms
	print *,'m_att ',m_att
c      write(6,*) "enter increment dlen and dmove for floating rup"
      read(1,*) dlen, dmove
c      write(6,,*)'dlen, dmove (km)=',dlen,dmove
c      write(6,*) "enter number of branches for Mchar logic tree"
      read(1,*) nbranch
c      write(6,,*)'Number of epistemic M-branches: ',nbranch
      if(cluster.and.nbranch.ne.1)then
      write(*,*)'Clustering is not currently compatible with Mchar branching.'
      write(*,*)'Clustering requires fixed event rates, branching induces variable rate'
      stop'deaggFLTH.2013  : Please use no mag variability when clustering eq events.'
      endif
c      write(6,*) "enter dM of each branch"
      read(1,*) (dmbranch(i),i=1,nbranch)
c      write(6,*) "enter weight of each branch"
      read(1,*) (wtbranch(i),i=1,nbranch)
c      write(6,*)'epistemic dM= ',(dmbranch(i),i=1,nbranch)
c      write(6,*) "enter std dev and width for Mchar aleatory uncer"
      wts=0.
      do i=1,nbranch
      wts=wts+wtbranch(i)
      enddo
      if(abs(wts-1.).gt.0.001)stop 'epistemic Mbranch wts do not sum to 1.'
      read(1,*) sdal,mwid
      dma=0.4*sdal      !so that 5 dma  = 2 sd_aleatory
c      write(6,,*)sdal,' sd_aleatory, step is ',dma
      if(sdal.gt.0.) then
         denom=0.
         alet=0.0
c sum of moments to equal initial moment (slip? constraint)
         do 670 i= -mwid, mwid
         pwr=float(i)*dma
         ale(i+mwid+1)= exp(-pwr*pwr/(2.*sdal*sdal))
         denom= denom+ ale(i+mwid+1)*10.**(1.5*pwr)
c         write(6,*) ale(i+mwid+1)
 670     continue
         do i=1,2*mwid+1
       ale2(i)= ale(i)/denom
       alet=alet+ale2(i)
       enddo      
c         write(6,*) 'aletot ',alet,' denom ',denom
c         read(5,*) idum
      elseif(sdal.lt.0.) then
c sum of rates to equal initial rate (other geologic constraint)
c added aug 13 2007. SH.
         denom=0.
         alet=0.0
         sdfac=2.*sdal**2
         do 680 i= -mwid, mwid
         pwr=float(i)*dma
         ale(i+mwid+1)= exp(-pwr*pwr/sdfac)
         denom= denom+ ale(i+mwid+1)
c         write(6,*) ale(i+mwid+1)
 680     continue
         do i=1,2*mwid+1
       ale2(i)= ale(i)/denom
       alet=alet+ale2(i)
       enddo      
c         write(6,*) 'Rate-fixed aletot ',alet,' denom ',denom
c         read(5,*) idum
         endif            !sdal .ne. 0
ccc-------read fault data
c for deagg, we know number of faults=nft. First read the names then read the list
	read(1,*)nft
	do i=1,nft
	read(1,900)aft(i)
	enddo
      do 1 ift=1,nft
c      write(6,*) "enter 1 for char. 2 for G-R; 1 for SS, 2 for reverse; nmagep"
      read(1,900,end=999) adum
c blank lines at end of file are ok. should not cause hiccough below.
c nmagf (ift) is a new required field 6-06. Number of mag branches. Used for
c several SF bay area faults (WG99), for NMSZ and others where the epistemic
c model needs some flexibility. 
c Added relwt to each fault-mag line. This relwt is relative to all faults
c in the current input file, not just this particular fault. For example, if
c combining 25-wt and 50-wt California faults into one file, and the relwt for the
c 25-wt items is X, then the relwt for the 50-wt items is 2X. This was discussed
c at a software meeting late Oct 2006. S Harmsen.
      if(cluster)then
      read(adum,*,err=999,end=999)itype(ift),iftype(ift),nmagf(ift),igroup(ift),jseg(ift)
c May 16 2007: igroup is a new index, for the geographic or other group index for clustering. 
c Idea is : Do not mix scenarios from different groups.
c jseg is the segmentation model, should be 1, 2, or 3 for north, central, or south segment of NMSZ fault system
c jseg is also 1,2, or 3 for Wasatch-SLC 1 = Warm Springs 2=tear fault; 3=Cottonwood New Nov 2013
c
      else
c code should be able to work with earlier file format if clustering is not requested.
      read(adum,*,err=999,end=999)itype(ift),iftype(ift),nmagf(ift)
      endif
      	if(iftype(ift).eq.1)then
	ibtype(ift)=1
	cDPP(ift)=0.0	! not ready to use forward directivity.
	elseif(iftype(ift).eq.2)then
	ibtype(ift)=3	!boore 2012 swithces
	cDPP(ift)=0.0
	else
	ibtype(ift)=2
	cDPP(ift)=0.0	!temporary setting for amount of directivity effect
	endif
      if(itype(ift).gt.0)then
      nmg= nmagf(ift)
      lb0=.false.
      elseif(itype(ift).lt.-1)then
c -2 is a trick number, it means n branches are specified, and n others with bvalue=0 are derived here.
c mod of aug 28 2007 to study sensitivity of rate to b=0 (half relative wt)
        lb0= .true.
      nmg=2*nmagf(ift)
c      print *,ift,' modified nmagf ',nmagf(ift),' to ',nmg
      else
      print *,adum
      stop 'invalid itype 0'
      endif
        if(lb0)itype(ift)=2
      if(nmg.lt.1.or.nmg.gt.12)then
c      write(6,,*)'Number of magnitude branches outside of acceptable range (1 to 12).'
c      write(6,,*)'Please check input file near ',adum
      stop'deaggFLTH.2013  : fatal error.'
      endif
      if(cluster)then
      jsegmin=min(jsegmin,jseg(ift))
      jsegmax=max(jsegmax,jseg(ift))
c checks associated with clustering
      igpmax=max(igpmax,igroup(ift))
      if(igroup(ift).lt.1.or.igpmax.gt.5)then
c      write(6,*)'igroup outside of acceptable range (1 to 5).'
      write(6,*)'Please check input file near ',adum
      stop'deaggFLTH.2013  : fatal error.'
      endif	!igroup bound check
      if(ift.gt.1.and.nmagf(ift).ne.nmagf(ift-1))then
      write(6,*)'Number of M-recurrence scenarios must be same on all fault segs'
      write(6,*)'For flt ',ift,' nmagf is ',nmagf(ift),' but for previous nmagf was ',nmagf(ift-1)
      stop'deaggFLTH.2013  : fatal error.'
      elseif(ift.eq.1)then
      nscene=nmagf(1)
      endif	!incompatible nmagf
      endif	!if cluster
      if(itype(ift).eq.1) then
      cmnow=3.0	!initialize a characteristic magnitude at a small value
      do imag=1,nmagf(ift)      !new: combine all fault mags
c        write(6,*) "enter char. M, rate, and relative weight"
c Added relwt to each fault-mag line. This relwt is relative to all faults
c in the current input file, not just this particular fault. For example, if
c combining 25-wt and 50-wt California faults into one file, and the relwt for the
c 25-wt items is X, then the relwt for the 50-wt items is 2X. This was discussed
c at a software meeting late Oct 2006. S Harmsen. This relwt should be an epistemic
c uncert weight. For example, related to fault location for NMSZ, or to freq
c of recurrence, to fault dip, or other issues.
        read(1,*) cmag(ift,imag),crate(ift,imag),relwt(ift,imag)
        if(ift.eq.1)print *,cmag(ift,imag),crate(ift,imag),relwt(ift,imag)
        if(cmag(ift,imag).gt.cmnow)then
        cmnow=cmag(ift,imag)
        mx_index(ift)=imag
        endif
        if(cluster)then
        wtscene(imag,igroup(ift))=relwt(ift,imag)
 	if(jseg(ift).eq.1)then
 	gweight(igroup(ift))=gweight(igroup(ift))+relwt(ift,imag)
 	print *,'igroup, gweight: ',igroup(ift),gweight(igroup(ift))
 	endif
        if(ift.eq.1)then
        rate_cl=crate(ift,imag)
        grp_rate(igroup(1)) = grp_rate(igroup(1))+rate_cl*relwt(1,imag)
        elseif(crate(ift,imag).ne.rate_cl)then
        write(6,*)'Rates of clustered events must all be equal. Trouble:'
        write(6,*) rate_cl,crate(ift,imag),' for ift ',ift
        stop 'please correct input file'
        endif !check that event rates are same
        endif	!clustered events
c for clustered events all faults in a group should have the same weight. This is new may 17.        
c      write(6,*) 'Cmag, rate, rel_wt: ',cmag(ift,imag),crate(ift,imag),relwt(ift,imag)
      if(crate(ift,imag).le.tiny)write(6,*)'**** Warning, eq rate <= 1e-12 for this fault. ****'
c mod 0ct 31, 2006 from Oliver Boyd discovery
      if(imag.gt.1)then
      if(abs(cmag(ift,imag)-cmag(ift,imag-1)).gt.0.8)then
c      write(6,,*)' characteristic magnitudes varying too rapidly.'
c      write(6,,*)' This seems like an error. Please check input file near ',adum
      stop'deaggFLTH.2013  : fatal error.'
      endif
      endif
        itest(ift)=0      !initially lets not worry about this test for multi-mag
        test= cmag(ift,imag)+dmbranch(1)-mwid*0.05
       if(test.lt.5.8) then
c          itest(ift)=1
c           write(6,*) "ale mag < 5.8, but not doing anything about it ",test,itest(ift)
c
c           read(5,*) idum
           endif
        enddo      !imag loop, multi mags.
        endif
      if(itype(ift).eq.2) then
      nmg=nmagf(ift)
c      write(6,,*) 'Zeng algorithm for floating ruptures w/variable dip direction'
c      write(6,,*) '**************************#####************************************'
      do imag=1,nmagf(ift)      !new: combine all fault mags
c         write(6,*) "enter a,b,min M,max M,dmag for freq mag curve"
c Added relwt to each fault-mag line. This relwt is relative to all faults
c in the current input file, not just this particular fault. For example, if
c combining 25-wt and 50-wt California faults into one file, and the relwt for the
c 25-wt items is X, then the relwt for the 50-wt items is 2X. This was discussed
c at a software meeting late Oct 2006. S Harmsen.
c Note, a(ift,imag) is an interval rate in this code (i.e., rate of M0+-dmag)
        read (1,*) a(ift,imag),b(ift,imag),magmin(ift,imag),magmax(ift,imag),
     + dmag(ift,imag),relwt(ift,imag)
       if(b(ift,imag).lt.0.2)write(6,*)'Probable error: a b magmin magmax relwt',
     + a(ift,imag),b(ift,imag),magmin(ift,imag),magmax(ift,imag),relwt(ift,imag)
c---- center magnitude bins. Follow earlier hazFX code, but generalize
c on dmag. Dmag was 0.1, now dmag is a flexible quantity.
c---- But first, check that dmag(ift,imag) is valid. If not valid, fix it.
       if(dmag(ift,imag).le.0.004)then
c       write(6,*)dmag(ift,imag),' invalid dmag for ',adum
c       write(6,*)"Code reset this fault's dmag to 0.1"
       dmag(ift,imag)=0.1
       endif
        if(magmin(ift,imag).eq.magmax(ift,imag))nmag0(ift,imag)=1
        if(magmin(ift,imag).ne.magmax(ift,imag)) then
          magmin(ift,imag)= magmin(ift,imag)+dmag(ift,imag)/2.
          magmax(ift,imag)= magmax(ift,imag)-dmag(ift,imag)/2.+.0001      !small delta may be
        if(lb0)then
        magmin(ift,imag+nmg)=magmin(ift,imag)
        magmax(ift,imag+nmg)=magmax(ift,imag)
        dmag(ift,imag+nmg)=dmag(ift,imag)
        relwt(ift,imag)=relwt(ift,imag)*0.5
        relwt(ift,imag+nmg)=relwt(ift,imag)
        if(sdal.ne.0)then
        print *,'deaggFLTH.2013   does not work with extra GR branches w/b=0 and sdal >0'
        print *,'Please revise input file to have sdal = 0; or revise this code.'
        stop 'deaggFLTH.2013  : unsuccessful input combination'
        endif
        endif
c needed to insure that magmax(ift,imag) > magmin(ift,imag)          
          endif	!magmin.ne.magmax
        nmag0(ift,imag)= int((magmax(ift,imag)-magmin(ift,imag))/dmag(ift,imag) + 1.4)
      if(lb0)nmag0(ift,imag+nmg)=nmag0(ift,imag)
        itest(ift)=0
        test= magmax(ift,imag)+dmbranch(1)
        if((test.lt.6.5).and.(nmag0(ift,imag).gt.1)) then
          itest(ift)=1
c if one of the mag branches yields test < 6.5, then all branches will have itest=1
c this is going to give a different answer than if each mag branch is run separately.
c May want to take another look at this. SHarmsen. Feb 5 2007.
c          write(6,*) "test.lt.6.5", ift, itest(ift)
          endif
        if(nmag0(ift,imag).eq.1) then
           test= magmax(ift,imag)+dmbranch(1)-mwid*dma
           if(test.lt.6.5) then
              itest(ift)=1
c              write(6,*) "test.lt.6.5 for fault #", ift, ' itest ',itest(ift)
           endif
           endif
c---- calculate moment rate
c initialize to nonzero because a log will be taken
        xmorate=1.0e-10
        do 600 i=1,nmag0(ift,imag)
        xmag= magmin(ift,imag)+ dmag(ift,imag)*(i-1)
        xmorate= xmorate+10.**(a(ift,imag)-b(ift,imag)*xmag+1.5*xmag+9.05)
 600    continue
 	if(lb0)then
 	xmob0=1.e-20
 	do 620 i=1,nmag0(ift,imag+nmg)
        xmag= magmin(ift,imag+nmg)+ dmag(ift,imag+nmg)*(i-1)
620	xmob0=xmob0+10.**(1.5*xmag+ 9.05) 
      afo=xmorate/xmob0
      a(ift,imag+nmg)	= alog10(afo)
      b(ift,imag+nmg) = 0.0
c      if(nmag0(ift,imag).eq.1)write(6,*)'xmag, Rate(M0|b0) a ',magmin(ift,imag+nmg),afo,a(ift,imag+nmg)
      xmo2(ift,imag+nmg) = xmorate
      endif 	!lb0 true
c xmo2 can be different for each "imag" branch. Needs dimension corresponding
c to this potential variation. SH Nov 2006.
        xmo2(ift,imag)= xmorate
c        write(6,*) xmorate,' moment rate J/yr'
c----- find rates for epistemic uncertainty
       if(nmag0(ift,imag).gt.1) then
         do 603 ilt= 1, nbranch
         mmax= magmax(ift,imag)+ dmbranch(ilt)
         nmagg= int((mmax-magmin(ift,imag))/dmag(ift,imag) + 1.4)
         nmagg = max(1,nmagg)	!added Mar 4 2008. 
         sum= 1.e-20
         do 602 m=1,nmagg
         xmag= magmin(ift,imag)+ (m-1)*dmag(ift,imag)
  602    sum= sum + 10.**(-b(ift,imag)*xmag+1.5*xmag+9.05)
         a10 = xmorate/sum
         al10=alog10(a10)
c         write(6,*) 'xmag, rate(M0),a ',xmag,a10,al10
         ratenew(ift,imag,ilt)=al10
        
c         write(6,*) "sum2=",sum2
c         read(5,*) idum
  603    continue
         endif	!nmag0(ift,imag).gt.1
c added below aug 28 2007
c----- find rates for epistemic uncertainty, b=0 branch
       if(lb0.and.nmag0(ift,imag+nmg).gt.1) then
         do 623 ilt= 1, nbranch
         mmax= magmax(ift,imag+nmg)+ dmbranch(ilt)
         nmagg= int((mmax-magmin(ift,imag+nmg))/dmag(ift,imag+nmg) + 1.4)
         nmagg=max(1,nmagg)		!new mar 4 2008 
         sum= 1.e-20
         do 622 m=1,nmagg
         xmag= magmin(ift,imag+nmg)+ (m-1)*dmag(ift,imag+nmg)
  622    sum= sum + 10.**(1.5*xmag+9.05)
         a10= xmorate/sum
c         write(6,*) 'xmag, rate(M0|b0),a ',xmag,a10,a(ift,imag+nmg)
         a10=alog10(a10)
c display crossover M, where rate|b0 equals rate|input b. for M>Mcross, the b=0 model 
c predicts more events, whereas for M<Mcross, the b=.8 model (or whatever) predicts more.
         ratenew(ift,imag+nmg,ilt) =a10
      xmag= (ratenew(ift,imag,ilt)-a10)/b(ift,imag)
c      write(6,,*)'Crossover M beyond which b0 branch rate exceeds other one:',xmag         
c         write(6,*) "sum2=",sum2
c         read(5,*) idum
  623    continue
         endif	!nmag0(ift,imag).gt.1
         enddo      !imag
         if(lb0)then
         nmagf(ift)=2*nmagf(ift)
         endif
        endif      !itype=2 
c the below line was changed feb 22 2008 Old version is commented out. New vers
c requires both epistemic and aleatory Muncert to be zero to set itest() to 1
      if(sdal.eq.0. .and. itype(ift).eq.1) itest(ift)=1
      if(sdal.eq.0. .and. itype(ift).eq.2 .and. nbranch.eq.1) itest(ift)=1	!line added feb28 2008
c      if(sdal.eq.0.) itest(ift)=1		!this line seems to remove epistemic branching
c  
c	write(6,*)ift,itest(ift),nmag0(ift,1),' fault number, itest,nmag0(ift,1)'
c       write(6,*) "enter dip, downdip width, depth0 of fault plane"
      read(1,*) dip(ift), width(ift), depth0(ift)
c      write(6,*)'Dip width depth0 ',dip(ift), width(ift), depth0(ift)
      if(abs(dip(ift)).gt.180.)stop'deaggFLTH.2013  : Allowed fault dip in the range -180 to 180 degrees'
c      if(depth0(ift).gt.8.)print 2458,depth0(ift),ift
c      write(6,*) "enter number of segment points"
      read(1,*) npts(ift)
c      write(6,*) "enter lat,lon for each point"
      tlen(ift)= 0.
c nodowndip new Oct 17 2007. Include downdip rupture scenarios only if original
c top of fault is at or near Earth surface. Deep blind thrusts don't need this.
      nodowndip(ift)=depth0(ift).gt.1.	!km. 
c Non-daylighting faults will not have additional downdip tops, just 1 at depth0.
c Below is new apr 3 2007.
c Make dip positive. Distance algorithm is known to give us problems if dip<0.
c Below enforces a standard: look right of strike to find dip direction. 
      if(dip(ift).lt.0..and.dip(ift).ge.-90.)then
      dip(ift)=-dip(ift)
      j1=npts(ift)
      j2=1
      j3=-1
      elseif(dip(ift).gt.90.)then
c Ken Campbell suggests that unconventional fault descriptions should be handled. email mar 6 2008.
      dip(ift)= 180. - dip(ift)
      j1=npts(ift)
      j2=1
      j3=-1
      elseif(dip(ift).lt.-90.)then
c Ken Campbell ditto.
      dip(ift)= 180. - dip(ift)
      j1=1
      j2=npts(ift)
      j3=1
      else
      j1=1
      j2=npts(ift)
      j3=1
      endif 
      do j=j1,j2,j3
      read(1,*)y(j,ift),x(j,ift)
c      print *,y(j,ift),x(j,ift)
      enddo 
c end new apr 3.    
      do 2 j=1,npts(ift)
c      read(1,*) y(j,ift),x(j,ift)
      if(j.gt.1) then
        sy= y(j-1,ift)
        sx= x(j-1,ift)
        ry= y(j,ift)
        rx= x(j,ift)
        if((sy.eq.ry).and.(sx.eq.rx)) then
             delta=0.
             az=0.
             go to 1020
        else
           call delaz(sy,sx,ry,rx,delta,az,baz)
        endif
 1020   if(j.gt.2) xlen(j-1)= delta +xlen(j-2)
        if(j.eq.2) xlen(1)= delta
        xaz(j-1)= az
        tlen(ift)= tlen(ift)+ delta
        endif
c      write(6,*) xlen(j-1),delta,xaz(j-1)
   2  continue
c----- next line added 10/18 based on Harmsen comment
       xaz(npts(ift))= xaz(npts(ift)-1)
c      write(6,*) npts(ift),tlen(ift)
      if(tlen(ift).le.0.) then
          write (6,*) "tlen le 0",ift
          read(5,*) idum
          elseif(tlen(ift).gt.970.*dmove)then
c          write(6,*)"Fault length > 970*dmove km. Please increase u,v dim 1"
          stop 'deaggFLTH.2013  : underdimensioned arrays u and v'
          endif
      coef= 3.14159/180.
      dip0(ift)= dip(ift)
c dip(ift) in radians henceforth
      dip(ift) =dip(ift)*coef
c      if(poly)then
c      zwide = 15.-depth0(ift)
c zwide is the vertical extent of fault=  15 km brittle crust - top depth
c Here is the test to determine if fault is at least partly inside a polygon
c      f_is_in(ift)=.false.	!presumed outside initially
c      if(ift.eq.1.and..not.deagg)open(29,file='resample.flt',status='unknown')
c the following resampling computes points along bottom of fault to determine if
c downdip part of fault is inside the polygon
c      call resample(ift,npts(ift),xlen,xaz,dip(ift),depth0(ift),
c     + 2,tlen(ift),dmove,zwide,npts1(ift))
c      if(.not.deagg)write(29,55)'# ',ift,npts1(ift)
c55      format(a2,i4,1x,i3)	
c      do j=1,2
c      do i=1,npts1(ift)
c      f_is_in(ift)= f_is_in(ift).or. LXYIN(u(i,j,ift),v(i,j,ift),PX,PY,npmax)
c      if(.not.deagg)write(29,*)u(i,j,ift),v(i,j,ift),i,j,f_is_in(ift)
cc      enddo	!i or along-strike loop 
c      if(.not.deagg)write(29,*)
c      if(.not.deagg)write(29,900)'#'	!gmt marker
c      enddo	!j or depth loop
c Note that just because some part of the fault is inside
c the perimeter, this is not the last word. For GR events with partial rupture,
c some of these might be entirely outside the polygon. More checking
c is required for these cases.
c      if(.not.f_is_in(ift))then
c      write(6,,57)adum
c57      format('#Fault outside perimeter: ',a,/,'# This source will not be included')
c      nft_out = nft_out+1
c      endif
c      else
      f_is_in(ift)=.true.	!standard presumption when not testing.
c       endif      !polygon test (no test for web site deagg)
c added March 28 2007: need uniform sampling along the fault for floaters
      if(itype(ift).eq.2)then
      dlen2 = 2.      ! 2 km vertical separation between downdip ruptures
      nleny = 4      ! 4 contours, 1 at depth0, 1 at d+2, 1 at d+4km, 1 at d+6,
c the last is for lowmag faults such as creeping section saf, with M6.2
      call resample(ift,npts(ift),xlen,xaz,dip(ift),depth0(ift),
     + nleny,tlen(ift),dmove,dlen2,npts1(ift))
c       write(6,*)'Resampling at ',dmove,' km for fault number ',ift,npts1(ift)
c      if(openme)then
c      open(49,file='resample.fault',status='unknown')
c      openme=.false.
c      endif
c      write(49,*)'# ',ift,npts1(ift)
       endif      !iftype=2
   1  continue
 999  continue
      write(6,*) "# nft=",nft
      if(nft.eq.nfltmx)write(6,*)'WARNING: maximum fault index reached. Is this all?'
      firstf(1:nft)=.true.
ccccccccccccccccccccccccccccc
c---- dont write header --------------
c Discussion at Software meeting Dec 16 2005: header record needs to be
c lengthened to include more input-file information.
c New no header for deagg. 
ccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc
      icnt=1
      prob = 0.1e-20      !initialze the array to negligible
c      if(cluster)then
cc      write(6,*)'CLUSTERED EVENT WEIGHTS * RATES: '
c      do i=1,3
c      write(6,885)i,grp_rate(i)
c      enddo
c	write(6,*)'jsegmin jsegmax ',jsegmin,jsegmax
885      format('group # ',i1,' rate*wt = ',f8.5)
c      endif	!write out group weight * rate. added diagnostic june 5 2007
c---Here's the guts
c
c---For deagg, one receiver site.
       i=1
            rx=slong(1)
            ry=slat(1)
c            write(6,*)'Computing seismic hazard for ',sname(1)
c following lines omit several site checks for ca and/or extensional faults.
      if(byeca.and.ry.gt.43.9) goto 860
c      if(byewg99.and.rx.gt.-118.)goto 860      !wg faults 120.5+
      if(byenv.and.(rx.gt.-111.1.or.rx.lt.-122.5))goto 860
      if(byenv.and.(ry.lt.32.1.or.ry.gt.44.1))goto 860
      if(byeext.and.ry.lt.38..and.rx.lt.-121.)goto 860
      if(byeext.and.ry.lt.40..and.rx.lt.-122.)goto 860
      if(byeoreg.and.(ry.lt.40..or.rx.gt.-113.))goto 860
c--- loop through faults
      prob_s = 0.
      do 850 ift=1,nft
c new apr 23 2007: exit if fault not inside polygon
      if(.not.f_is_in(ift))goto 850
      dipang=dip(ift)
      sinedip=sin(abs(dipang))
c      print *,'iflt and sine(dip)',ift,sinedip
      if(dip0(ift).le.70..or.dip0(ift).ge.110..or.dip0(ift).lt.0.)then
      cbhwfac=1.
      else
      cbhwfac=abs(90.-dip0(ift))/20.      !changed july 12 2006 SH
      endif
      cosDELTA=cos(dipang)
      cdipsq=cosDELTA**2
      dtor=depth0(ift)
c Heads up: the below factor changes when top of rupture is moved downdip
        cyhwfac=atan(width(ift)*0.5*cosDELTA/(dtor+1.0))/(pi*0.5)
      if(iftype(ift).eq.1)then
      ss=.true.
      rev=.false.
      normal=.false.
      rake=0.
      F_RV=0.0
      F_NM=0.0
      elseif(iftype(ift).eq.2)then
      rev=.true.
      normal=.false.
      ss=.false.
      rake=90.
      F_RV=1.0
      F_NM=0.0
      elseif(iftype(ift).eq.3)then
      normal=.true.
      rev=.false.
      ss=.false.
      F_RV=0.0
      F_NM=1.0
      rake=-90.
      else
c oblique thrust currently assumed. If transtensional, consider -135.
      obl=.true.
      rev=.true.      !check this Oblique in DB?
      ss=.false.
      normal=.false.
      rake=135.
      F_RV=0.5      !intuitive choice. May require colleagues OK.
      F_NM=0.0
      endif
      xdiff=1.e6
      ydiff=1.e6
      do ii=1,npts(ift)
      xdiff= min(xdiff,abs(rx-x(ii,ift)))
      ydiff= min(ydiff,abs(ry-y(ii,ift)))
      enddo
      xdmax= (dmax+200.)/(111.11*cos(ymax*coef))
      ydmax= (dmax+200.)/111.11
      if(xdiff.gt.xdmax) go to 850
      if(ydiff.gt.ydmax) go to 850
      do 35 iatype=1,5
 35   dmin(iatype)=10000.
c Currently, all char events rupture to top of fault. Only gr includes downdip top possibilitty      
c Steve Harmsen, Nov 16 2006. This needs to be discussed. Downdip only applies to
c faults with tops at Earth surface. Oct 2007.
c----- new for AS hanging wall test 
      aspectratio=tlen(ift)/width(ift)      !if rupture occupies entire fault.
c--- calculate distance to site for points (ix,iy) on fault plane
      hwsite=.false.
c added below dec 14 2006 to perform checks on dipping faults that might have rupture top below
c top-of-fault. If rupture top is below fault top, more dmin checks must be performed
c      if(magmin(ift,1).ge.7.0)then
c      iymx=1
c      elseif(magmin(ift,1).ge.6.5)then
c      iymx=5
c      else
c      iymx=9
c      endif
c      write(6,*)ift,iymx,sinedip,nseg,nlenx,' ift iymx sin(dip) nseg,nlenx'
c do 101 loop entirely eliminated from deaggFLTH.2013  . Just trying char event ruptures (entire fault surface) initially
c with Yuehua Zeng code mindist1. 
c azm and azb are azimuths to a seg boundary not to nearest place on the segment, therefore ,in general, not the best
c choice (when deaggregating).
c      call mindist(rcd,azm,rjb,azb,ry,rx,y(1,ift),x(1,ift),npts(ift),
c     +                   dip0(ift),width(ift),depth0(ift))
c Zeng code mindist1 uses a continuous fault surface rather than series of rectangles
c added R_x, distance to top of fault, oct 22 2007
      call mindist1(rcd,azm,rjb,azb,R_x,ry,rx,y(1,ift),x(1,ift),npts(ift),
     +                   dip0(ift),width(ift),depth0(ift))
c        print *,rcd,rjb,ift,dip0(ift),width(ift),depth0(ift),npts(ift),x(1,ift),y(1,ift)
        dmin(1)=rjb
        dmin(2)=rcd; dmin(3) = rcd; 
        dmin(4)= R_x      !used in CY NGA 11/07
        dmin(5)= -1.0	!R_x*tan(azb*coef)
c        if(dmin(5).lt.0.)dmin(5)=1000.      !This step is supposed to nullify footwall. Stopgap dec 10 2012.
        azi_c=d2r*mod(azb+180.,360.)
c	!use Rjb azimuth. Geographic deagg will show fault surfaces.
c        print *,aft(ift),azi_c/d2r,' fault and azimuth_jb(degrees)'
c this is the end of the previous do 101 loop. Initially just itype()=1 is programmed.
c  dmin is minimum distance from fault to receiver 
      nearsrc=dmin(1).lt.30.0.and.depth0(ift).lt.1.5      !certain calcs can be bypassed for distant  flts
      if(dmin(1).gt.dmax) go to 850 
      if(itype(ift).eq.2) then
c----  loop through floating rupture zones along fault
c--- find minimum distance dmin2 to receiver for each rupture zone
c--- nrups(m,ift) rupture zones per magnitude bin m
c-- move rupture zones by dlen horizontally along fault
      ntmp=0
      do imag=1,nmagf(ift)
      ntmp=max(ntmp,nmag0(ift,imag))
      enddo
        do 222 m=1,ntmp      !+2 no need for overkill.
        xmag= magmin(ift,1)+(m-1)*dmag(ift,1)      
c magmin: can change slightly with imag. Using first branch value here
c------find rupture length from Wells Coppersmith relation 
c here is one place where certain calcs are done only once. New nov 2006
      if(firstf(ift))then
c---- In general, ruplen based on W&C all flt slip types. changed 7/1/02
c--- New Apr 2007: ruplen for CA floaters based on H&B, if input file is CA floater
      if(cal_fl.or.bfault)then
      area1 = 10.**(xmag-4.2)
      area2 = 10.**((xmag-4.07)/0.98)
      if(area1.ge. 500.)then
      ruplen = min(area1/width(ift),tlen(ift))
      else
      ruplen = area2/width(ift)
      endif
c      write (6,*) xmag,ruplen,area1,area2,ift	!temp check.
      else
c general case: ruplen is W&C length based on Mchar      
        ruplen= -3.22+ 0.69*xmag
        ruplen= 10**ruplen
        endif
c down-dip rupture possibilities for M<= 7 . This information
c  xxx not ready for any but top-of-fault to bottom-of-fault rupture. 
c Mods of mar 26 are for entire downdip rupture. Active fault is assumed to be there below these
c downdip tops. Some 2007 California fault models are shallow: Hosgri 0 to 7 km, Bartlett Spr. 0 to 7 km.
c However, these downdip limits do not appear to have been thought out very carefully in some cases.
      if(cal_fl.or.nodowndip(ift))then
      nrupdd =1      !floaters are characteristic events. Occupy full fault width
      elseif(xmag.lt.6.5)then
      nrupdd=4      !smaller events can have deeper tops. new dec 2006. 
c      print *, ift,'xmag < 6.5 trying 4 top-of-rupture with Zeng code mindist1'
      elseif(xmag.le.6.75)then
      nrupdd=3
      elseif(xmag.le.7.0)then
      nrupdd=2
      else
      nrupdd=1
      endif
      deltaw = dlen2/sin(dip(ift))      !for 2 km loss in Z, what is reduction in flt width?
      do idn=1,nrupdd
c below guards against the long strip downdip in case M is less than 6.2 or so.
      widthrup=max(1.0, min(width(ift)-deltaw*float(idn-1),ruplen))
        ar(m,idn)=ruplen/widthrup
        enddo      !variable aspect ratio for floating rupture downdip.
c--- changed to dmove move for floating rupture
        nrups(m,ift)= (tlen(ift)-ruplen)/dmove +1.
        nrupd(m,ift)=nrupdd
      rupln(m,ift)=min(ruplen,tlen(ift))
        if(ruplen.ge.tlen(ift))nrups(m,ift)=1
c the above calcs are done once per fault, when firstf(ift) is .true.      
      endif
c do jrup below is the new downdip rupture loop: if M<7 then nrupd>1.
c nrupd is 4 for M<6.5. Maximum top of rupture 8 km deep in that case.
c nrup is nrups * nrupd (number along strike * number downdip)
c simple rectangle is assumed. Does this have problems for complicated geom?
c
        iy0 = 1
c each station -source pair has calculation branch that is based on "nearsrc"
        if(nearsrc)then
        nrupdd=nrupd(m,ift)
        else
        nrupdd=1
c nearsource sensitivity. far away ASSUME no sensitivity to depth of rupture top.
c Note: this has been tested and found correct for CA GR sources.
      endif
      nxxp = rupln(m,ift)/dmove +1
      deltaw = dlen2/sin(dip(ift))      !for 2 km loss in Z, what is reduction in flt width?
        do jrup=1,nrupdd
        ztop = depth0(ift)+dlen2*(jrup-1)
c rupture width decreases as top of rupture goes deeper. Bottom is fixed at Z=15km
c or other fault bottom except for skinny faults (CALIF). Widthp is width of
c rupture at this time. Minimum width 2 km.
        widthp = max(2.0,width(ift)-deltaw*(jrup-1))
        do 302 irup=1,nrups(m,ift)
        if(jrup.eq.1)segin=.false.
        xmove= dmove*(irup-1)
c The below process will only work for faults sampled at dmove km increments.
        ix0= irup
        ix1=min(nxxp+ix0,npts1(ift))      
      nx1=1+ix1-ix0
c ix1 is supposed to be index of last point on rup seg. nx1 is the number of points
c in the segment.
c Next: Another check if polygon option is on. Added May 25 2007 SH. not used
c for deagg. on Web.
c This test checks whether the top of flt segment is inside the polygon
c      if(poly.and.jrup.eq.1)then
c      do ix=ix0,ix1
c      segin=segin.or. LXYIN(u(ix,1,ift),v(ix,1,ift),PX,PY,npmax)
c      enddo
c      endif
c Code ready for downdip ruptures, Oct 22 2007
        call mindist1(rcd,azm,rjb,azb,R_x,ry,rx,v(ix0,jrup,ift),u(ix0,jrup,ift),nx1,
     +                   dip0(ift),widthp,ztop)
c      if(poly.and..not.segin)then
c how far away is the moon?
c      dminr(1,jrup)=200000.
c      dminr(2,jrup)=200000.
c      dminr(3,jrup)=200000.
c     else
        dminr(1,jrup)=rjb
        dminr(2,jrup)=rcd
        dminr(3,jrup)=rcd
        dminr(4,jrup)= R_x      !used in CY NGA 11/07
        dminr(5,jrup)=R_x*tan(azb*coef)         !used in ASK13.    
c index 5: wings were clipped, winged metric no longer available. SH Mar 2007.
c      endif
        do 39 iatype=1,4      !type 4 added oct 23 2007
 39     dmin2(m,irup,jrup,iatype)=dminr(iatype,jrup)
c convert azimuth output by mindist1 to back-azimuth, or baz. In units degrees, out radians.
c save baz for ruptures along strike, down-dip, and with M uncert (3 dim array)
        azimuth(m,irup,jrup)=mod(azb+180.,360.)*d2r	!for geographic deagg.  Rjb azimuth saved   
  302   continue
      iy0=iy0+2
      enddo      !downdip index
  222   continue
      firstf(ift)=.false.
c end of down-dip related changes
      endif
c 
c
c-----------------------------------------
c----  GR with nmag0>1 with Mmax uncertainties
      if((itype(ift).eq.2).and.(nmag0(ift,1).gt.1).and.
     &   (itest(ift).eq.0)) then
      do imag=1,nmagf(ift)      !can have two or more distributions often
c with diffrent Mmax.
      dtor= depth0(ift)
      if(cluster)then
      ks=imag
      kg=igroup(ift)
      else
      ks=1
      kg=1
      endif
       do 403 ilt=1,nbranch
        mmax= magmax(ift,imag)+ dmbranch(ilt)
        totmo= 0.
        nmag= (mmax- magmin(ift,imag))/dmag(ift,imag) + 1.4
c-- loop through magnitudes
c       if(abs(rx+101.).lt.0.1.and.abs(ry-38.).lt.0.1)then
c       if(ilt.eq.1)write(6,*)rx,ry,' gr with uncrt ift',ift
c       write(6,*) "nmag=",nmag,"nmag0(ift,imag)",nmag0(ift,imag),nrups(m,ift)
c       endif
        do 285 m=1,nmag
c      isbig=nmag.eq.m
        xmag= magmin(ift,imag)+(m-1)*dmag(ift,imag)
        rate= ratenew(ift,imag,ilt) - b(ift,imag)*xmag
c rate is now a relative rate, because of new relwt factor Nov 2 2006. SH.
        rate= relwt(ift,imag) * 10.**rate
        if(rate.lt.tiny)goto 403      !bypass irrelevant models aug 23 2007
        totmo= totmo+ rate*(10.**(1.5*xmag+ 9.05))
c        torate(mm)= torate(mm)+ rate*ale(idis+mwid+1)
c cluster model new may 16 2007. Base cluster on mag and geographic branch for Char. For GR
c no cluster model has been specifically discussed
      if(cluster)then
      ks=1
      kg=1
      else
      ks=1
      kg=1
      endif
c dM bins have width 0.1 here 
                  im=nint((xmag-5.749)*10.)+1
                  im=min(33,im)	!current dimension 30
                  im=max(im,1)
                  immax=max(immax,im)
c new, possible downdip top surface of rupture. nrupd can be 1, 2 or 3 
      if(nearsrc)then
      nrupdd=nrupd(m,ift)
      else
      nrupdd=1
      endif 
        rate= rate/float(nrups(m,ift)*nrupdd)
          if(xmag.lt.mcut(1))then
          ime=1
          elseif(xmag.lt.mcut(2))then
          ime=2
          else
          ime=3
          endif
c      if(slist)write(30+i,8899)dmin(1),nearsrc,nrupd(m,ift)
c8899      format('#',t30,f6.1,'km; nearsrc=',l4,1x,i4,'=nrupd(m,ift)')
      do 284 jrup=1,nrupdd      !new loop downdip rup.
       norpt=.true.      !can have a report for rupture at each downdip level
        aspectratio=ar(m,jrup)
        dz=dlen2*float(jrup-1)      !dlen2 is probably 2 km
        dtor1=dtor + dz      !all important depth to top of rupture.
        cyhwfac=atan((width(ift)-dz)*0.5*cosDELTA/(dtor1+1.0))/(pi*0.5)
c--- loop through floating rupture zones
        do 284 irup=1,nrups(m,ift)
c report rate of eqs * weight applied to logic-tree branch, R,M,rate'
        rjb=dmin2(m,irup,jrup,1)
          if(rjb.lt.dcut(1))then
          ide=1
          elseif(rjb.lt.dcut(2))then
          ide=2
          else
          ide=3
          endif
c399      format(f7.2,1x,f6.2,1x,e12.5,1x,i3,1x,f5.1,3(1x,i3))
        ip=1
        iq=iper      !std periods in 2002. 
        R_x=dmin2(m,irup,jrup,4)      !type 4 for the new R_x
        do 282 ia=1,nattn
        rrup= dmin2(m,irup,jrup,3)      !type 3 supposed to be rrup
        weight= wt(ia,1)
        if(rjb.gt.wtdist(ia)) weight=wt(ia,2)
        if(rjb.gt.dmax) go to 282
        if(rrup.le.110.)then
        ir=0.1*rrup + 1
        elseif(rrup.le.300.)then
        ir=12+(rrup-100.)/50.
        elseif(rrup.le.500.)then
        ir=16
        else
        ir=17
        endif 
      iatt=iatten(ia)
c nga relations are collected into the first set of models to check
      if(nga(ia)) then
        if(iatt.eq.13) then
      call getBANGA0308(iperb,xmag,rjb,vs30,gnd,sigmaf)
         elseif(iatt.eq.14) then
        call getCampNGA0308 (ipercb,xmag,rrup,rjb,dtor1,
     1 vs30,dbasin,gnd,sigmaf)
	elseif(iatt.eq.33)then
	indx1=indbssa
	mech = ibtype(ift)
	iregion=1	!CA-Taiwan version
	call bssa2013drv(indx_pga,indx1,xmag,rjb,vs30,z1cal,mech,iregion,alny,sigmaf)
c skip the 2nd period for now assume the period of interest was tabulated.
	gnd(1)=alny
         if(l_gnd_ep)then
         gnd(2)= gnd(1)+gnd_ep(ide,ime)
         gnd(3)= gnd(1)-gnd_ep(ide,ime)
         endif
	elseif(iatt.eq.34)then
c	SJ=0.0	!Are we in Japan? 1 = yes.
	Hhyp = dtor1+0.5*sinedip*W_rup
      call CB13_NGA_SPEC  (ipcb13, xmag,Rrup,R_x,Rjb,F_RV, F_NM,dtor1,Hhyp,W_rup,dbasin,Vs30,
     +Dip0(ift),SJ,gnd,sigmaf)
	elseif(iatt.eq.38)then
      if(rx.lt.-120..and.ry.gt.39.)then
      Q=Q_CA
      elseif(ry.le.39.-0.8*(rx+120.))then
      Q=Q_CA      
      else
      Q=Q_BR
      endif
	call gksa13v2(ipgk12,ip,xmag,rrup,gnd,sigmaf,vs30,iftype(ift),dgkbasin,Q)
      
      elseif(iatt.eq.15)then
c 10/2007 implementation of getCYNGA 
      call CY2007H(ipercy, xmag, rrup, rjb, R_x, vs30,z1, dtor1,
     1                 F_RV, F_NM,  gnd, sigmaf)
	elseif(iatt.eq.35)then
c from BChiou email use fmeasured=0. f_inferred is the model to use Aug 2013.
c dtor1 is top of floating rupture may be downdip
	F_Measured=0.
	F_Inferred=1.0	!could change these. Reference rock.
       call CY2013_NGA(icy13, xmag, rrup, rjb, R_x, vs30,
     1                   F_Measured, F_Inferred, deltaZ1, dip0(ift), dtor1,
     1                   F_RV, F_NM, cDPP(ift), gnd, tau, sigma_NL0, sigmaf)
c	print *,gnd(1),ift
        elseif (iatt.eq.16) then
c hanging-wall flag for as08 model added mar 20 2013.
	print *,'going into AS08 model why?'
      if(dip0(ift).eq.90.)then
      hwflag=0
      elseif(rjb.le.0.01.and.r_x.ge.0.)then
      hwflag=1
      else
      hwflag=0
      endif

c Although iflag makes a token appearance in SR code, it isn't used. So I dropped iflag (SH).
       call AS_072007 ( ipera,xmag, dip0(ift), F_NM,F_RV, W_rup, rRup, rjb,R_x,
     1                     vs30, hwflag, gnd(1), sigma1, dtor1,  vs30_class,
     3                     z1km )
         if(l_gnd_ep)then
         gnd(2)= gnd(1)+gnd_ep(ide,ime)
         gnd(3)= gnd(1)-gnd_ep(ide,ime)
         endif
c gnd is lnSA in AS code. need to fill in some other input. vs30_class ?
c period1 is output by AS_modelXX. period1 should equal per(ip)
c	print *,sigma1,gnd(1),'AS08'
       sigmaf=1./sqrt2/sigma1
        elseif (iatt.eq.36) then
      SA_rock = 0.
c hanging-wall flag for as12 model added dec 7 2012.
      if(dip0(ift).eq.90.)then
      hwflag=0
      elseif(rjb.le.0.01.and.R_x.ge.0.)then
      hwflag=1
      else
      hwflag=0
      endif
      call ASK13_v11_model ( ipas13,xmag, dip0(ift), W_rup, dtor1, F_rv, F_NM, rRup, rjb, r_x, Ry0, 
     1                     vs30, SA_rock, Z10_rock, z1_ref, hwflag, vs30_class,iReg,lnSa, phi, tau)
c 
c     Compute Sa at spectral period for hard rock
      Sa1180 = exp(lnSa)
	if(l_ms)then
	do jp=1,npnga
	if(jp.ne.jms)then
	jper = imsp(ia,jp)
      call ASK13_v11_model ( jper,xmag,dip0(ift),  W_rup, dtor1, F_rv, F_NM, rRup, rjb, r_x, Ry0, 
     1                     vs30_rock, SA_rock, Z10_rock, z1_ref, hwflag, vs30_class,iReg,lnSa, phi, tau)
      psa_hr(jp) = exp(lnSa)
      endif	!jp .ne. jms
      enddo	!CMS periods
      endif	!want CMS?
c 
c     Compute Sa at spectral period for given Vs30
      Ry0= -1.	!do not use this metric sept 2013
      call ASK13_v11_model ( ipas13,xmag, dip0(ift), W_rup, dtor1, F_rv, F_NM, rRup, rjb, r_x, Ry0, 
     1                     vs30, SA1180, z1km, z1_ref, hwflag, vs30_class,iReg,lnSa, phi, tau)
	gnd(1)=lnSa
         if(l_gnd_ep)then
         gnd(2)= gnd(1)+gnd_ep(ide,ime)
         gnd(3)= gnd(1)-gnd_ep(ide,ime)
         endif
        sigmaf = 1./sqrt( phi**2 + tau**2 )/sqrt2
	elseif(iatt.eq.37)then
	call  getIdriss2013(idriss,ip,xmag,rrup,vs30,gnd,sigmaf)
      elseif(iatt.eq.17)then
      call getIdriss(ip,iper,xmag,rjb,vs30,gnd,sigmaf)
      elseif(iatt.eq.18)then
c new nov 7,2006. Kanno. Warning: in Kanno, Median is vector amp, not Geometric Mean
      call kanno(ip,iperk,gnd,sigmaf,xmag,rrup,vsfac)
      endif
      elseif(wus02(ia))then
c WUS pre-nga (2002 atten models)
      if(iatt.eq.1)then
      call getSpu2000(ip,iq,xmag,rjb,vs30,gnd,sigmaf)
      elseif(iatt.eq.3)then
      call getsadigh(ip,iq,xmag,rrup,gnd,sigmaf)
      elseif(iatt.eq.8)then
      call getAS97(ip,iq,xmag,rrup,hwsite,gnd,sigmaf)
       elseif(iatt.eq.9)then
       call getCamp2003(ip,iq,xmag,rrup,rjb,gnd,sigmaf)
      elseif(iatt.eq.11)then
      call getBJF97(ip,iq,xmag,rjb,vs30,gnd,sigmaf)
      elseif(iatt.eq.-3)then
        call SomerIMW(ip,isomer, xmag,  rrup, rjb,vs30,gnd,sigmaf)
      endif
      elseif(ceus11(ia))Then
c new code for CEUS11 GMPEs added june 17 2013.
       rjbp=max(rjb,0.11)
       if(iatt.eq.25)then
      rkm=rjbp
      jf=ia08
             ka=1
             sigma = 0.3*2.303
       gnd(1) = amean11(xmag,rkm,rjbp,vs30,jf,ka)
	if(l_ms)then
	sigspec=sigma	!same value all periods
	meanspec(jms)=gnd(1)
	do j=1,npnga-2	!5s max for the CEUS11 relations.
	if(lmsp(ia,j) .and. j.ne.jms)then
	jp=imsp(ia,j)
	meanspec(j)=amean11(xmag,rkm,rjbp,vs30,jp,ka)
	endif
	enddo
	endif
       if(lceus_sigma)sigma=ceus_sigma !for special study 3/2011
c     print *,gnd,rkm,ip,jf,ka
       sigmaf = 1./sqrt2/sigma
       elseif(iatt.eq.26)then
       rkm=rrup
       jf=ia06
       ka=2
             sigma = 0.3*2.303
       gnd(1) = amean11(xmag,rkm,rjbp,vs30,jf,ka)
	if(l_ms)then
	sigspec=sigma	!same value all periods
	meanspec(jms)=gnd(1)
	do j=1,npnga-2	!5s max for the CEUS11 relations.
	if(lmsp(ia,j) .and. j.ne.jms)then
	jp=imsp(ia,j)
	meanspec(j)=amean11(xmag,rkm,rjbp,vs30,jp,ka)
	endif
	enddo
	endif
       if(lceus_sigma)sigma=ceus_sigma !for special study 3/2011
c     print *,gnd,rkm,ip,jf,ka
       sigmaf = 1./sqrt2/sigma
       elseif(iatt.eq.27)then
       rkm=rrup
       jf=ip11
c 2nd variable in sigPez11 is the frequency index according to the GailA set 2011.
      sigma = sigPez11(xmag,jf)	!new 10/30/2012. SH.
       ka=3
       gnd(1) = amean11(xmag,rkm,rjbp,vs30,jf,ka)
	if(l_ms)then
	sigspec=sigma	!same value all periods
	meanspec(jms)=gnd(1)
	do j=1,npnga-2	!5s max for the CEUS11 relations.
	if(lmsp(ia,j) .and. j.ne.jms)then
	jp=imsp(ia,j)
	meanspec(j)=amean11(xmag,rkm,rjbp,vs30,jp,ka)
	endif
	enddo
	endif	!l_ms? extra code for Conditional mean spectrum
       if(lceus_sigma)sigma=ceus_sigma !for special study 3/2011
c     print *,gnd,rkm,ip,jf,ka
       sigmaf = 1./sqrt2/sigma
c the rest of these are pre-2011 models
      	endif !iatt=25,26, or 27?
      elseif(ceus02(ia))then
c CEUS pre-nga (2002 atten models)
        if(iatt.eq.2)then
        call getToro(iptoro,1,xmag,rjb,gnd,sigma,sigmaf)
        elseif(iatt.eq.-2)then
        call getToro(iptoro,2,xmag,rjb,gnd,sigma,sigmaf)
        elseif(iatt.eq.4)then
        call getAB06(iperab,irab(ia),xmag,rrup,gnd,sigma,sigmaf,vs30)
        elseif(iatt.eq.19)then
        call getTP05(ipertp,irtb,xmag,rrup,gnd,sigma,sigmaf)
        elseif(iatt.eq.20)then
        call getSilva(isilva,irsilva,xmag,rjb,gnd,sigma,sigmaf)
        elseif(iatt.eq.6)then
        call getFEA(ip,iq,1,xmag,rrup,gnd,sigma,sigmaf)
        elseif(iatt.eq.-6)then      
        call getFEA(ip,iq,3,xmag,rrup,gnd,sigma,sigmaf)
        elseif(iatt.eq.5)then      !to distinguish ab95 from fea
        call getFEA(ip,iq,2,xmag,rrup,gnd,sigma,sigmaf)
        elseif(iatt.eq.-5)then      !HR for atkinson-boore
        call getFEA(ip,iq,4,xmag,rrup,gnd,sigma,sigmaf)
        elseif(iatt.eq.7) then
        call getSomer(iq,1,xmag,rjb,gnd,sigma,sigmaf)
        elseif(iatt.eq.-7) then
        call getSomer(iq,2,xmag,rjb,gnd,sigma,sigmaf)
        elseif(iatt.eq.10)then
        call getCampCEUS(ipcmpc,1,xmag,rrup,gnd,sigma,sigmaf)
        elseif(iatt.eq.-10)then
        call getCampCEUS(ipcmpc,2,xmag,rrup,gnd,sigma,sigmaf)
        endif
c CEUS only: This is a good place to apply the extra clamp constraint which
c in 2002 was used only for CEUS sources. The precomputed p() array does
c not work for this case because truncation is no longer at mu+3sig
      test0=gnd(1)+3.*sigma
      test= exp(test0)
      if(clamp(iq).lt.test .and. clamp(iq).gt.0.) then
        clamp2= alog(clamp(iq))
        sigmasq=1./sigma/sqrt2
        tempgt3= (gnd(1) - clamp2)*sigmasq
        probgt3= (erf(tempgt3)+1.)*0.5
        k=1
        ifn=1
        temp= (gnd(1) - xlev)*sigmasq
        temp1= (erf(temp)+1.)*0.5
        temp1= (temp1-probgt3)/(1.-probgt3)
        if(temp1.lt.0.) goto 282      !no more calcs once p<0
        wttmp=wtbranch(ilt)*weight*rate
        prob(1,1)= prob(1,1)+ wttmp*temp1
c deagg matrices need to be filled in here for clamped Ground motion.
c Deagg is set up for one ground motion per period. Thus no k index here.
c for individual fault
        eps= -temp*sqrt2
c the 1000 factor may be useful to avoid arctan of small number pairs
        fbaz(ift,1)=fbaz(ift,1)+cfac*cos(azimuth(m,irup,jrup))*1000.
        fbaz(ift,2)=fbaz(ift,2)+cfac*sin(azimuth(m,irup,jrup))*1000.
        if(eps.lt.emax)then
	cfr=cfac*rrup; cma= cfac*xmag; ceps=cfac*eps
        frbar(ift,ifn,0)=frbar(ift,ifn,0)+cfr
        fmbar(ift,ifn,0)=fmbar(ift,ifn,0)+cma
        febar(ift,ifn,0)=febar(ift,ifn,0)+ceps
        fhaz(ift,ifn,0)=fhaz(ift,ifn,0)+cfac
          ieps=max(1,min(int((eps+2.)*2.),10))
          ie=ieps
          rbar(ir,im,ieps,ifn,0)=rbar(ir,im,ieps,ifn,0)+cfr
          mbar(ir,im,ieps,ifn,0)=mbar(ir,im,ieps,ifn,0)+cma
          ebar(ir,im,ieps,ifn,0)=ebar(ir,im,ieps,ifn,0)+ceps
          haz(ir,im,ieps,ifn,0)=haz(ir,im,ieps,ifn,0)+cfac
          if(l_ms.and.ifn.eq.1)then
c Add epsilon*rho*sigma
	meanspec=meanspec + eps*rho_jb*sigspec
c how to average? Nico Nov 4 says geometric avg. The cfac factor will change
c depending on what period T you are looking at. If T matches the peak amplitude
c of one of the GMPEs, this GMPE will dominate. Somehow, the mean should not depend
c on which T is analysed. Trying wttmp which does not depend on period T.
          do jp=1,npnga
          meanspecs(ir,im,ie,jp,0)= meanspecs(ir,im,ie,jp,0)+ meanspec(jp)*cfac
          mean2spec(jp,0)= mean2spec(jp,0)+ meanspec(jp)*cfac
          enddo
c mean2spec(jp,0)=big average spectrum and its big average distance, M, e0 over all variables.
          mean2haz(0)=mean2haz(0)+cfac
          mean2r(0)=mean2r(0)+cfr
          mean2m(0)=mean2m(0)+cma
          mean2e0(0)=mean2e0(0)+ceps
          hazmsp(ir,im,ie,0)=hazmsp(ir,im,ie,0)+cfac
          epsmsp(ir,im,ie,0)=epsmsp(ir,im,ie,0)+ceps
cc          wtmsp(ir,im,ie,0)=wtmsp(ir,im,ie,0)+wttmp

          rmsp(ir,im,ie,0)=rmsp(ir,im,ie,0)+cfr
          mmsp(ir,im,ie,0)=mmsp(ir,im,ie,0)+cma
c wttmp all weight factors except probability of exceedance
          endif
      if(dea_attn)then
      frbar(ift,ifn,ia)=frbar(ift,ifn,ia)+cfr
      fmbar(ift,ifn,ia)=fmbar(ift,ifn,ia)+cma
      febar(ift,ifn,ia)=febar(ift,ifn,ia)+ceps
      fhaz(ift,ifn,ia) =fhaz(ift,ifn,ia)+cfac
      rbar(ir,im,ieps,ifn,ia)=rbar(ir,im,ieps,ifn,ia)+cfr
      mbar(ir,im,ieps,ifn,ia)=mbar(ir,im,ieps,ifn,ia)+cma
      ebar(ir,im,ieps,ifn,ia)=ebar(ir,im,ieps,ifn,ia)+ceps
      haz(ir,im,ieps,ifn,ia) =haz(ir,im,ieps,ifn,ia)+cfac
          if(l_ms.and.ifn.eq.1)then
c Below logic implies that meanspec is well defined at each frequency jp
          do jp=1,npnga
          meanspecs(ir,im,ie,jp,ia)= meanspecs(ir,im,ie,jp,ia)+ meanspec(jp)*cfac
           mean2spec(jp,ia)= mean2spec(jp,ia)+ meanspec(jp)*cfac
         enddo
c mean2spec(jp,ia)=big average spectrum and its big average distance, M, e0 for attn model ia.
          mean2haz(ia)=mean2haz(ia)+cfac
          mean2r(ia)=mean2r(ia)+cfr
          mean2m(ia)=mean2m(ia)+cma
          mean2e0(ia)=mean2e0(ia)+ceps
           hazmsp(ir,im,ie,ia)=hazmsp(ir,im,ie,ia)+cfac
          epsmsp(ir,im,ie,ia)=epsmsp(ir,im,ie,ia)+ceps
          rmsp(ir,im,ie,ia)=rmsp(ir,im,ie,ia)+cfr
          mmsp(ir,im,ie,ia)=mmsp(ir,im,ie,ia)+cma
          endif
      endif	!deagg indiv GMPEs
          if(eps.ge.2.)goto 282
c Below keeps the books on epsilon distribution for e0<2. if e0>2 dont bother.
          ka=5
          prx= temp1-ptail(ka)
          dowhile(prx.gt.1.e-9)
          tp=wttmp*gmwt(ifn)*prx
             prob5(ir,im,ieps,ifn,0,ka)=prob5(ir,im,ieps,ifn,0,ka)+tp
             if(dea_attn)prob5(ir,im,ieps,ifn,ia,ka)=prob5(ir,im,ieps,ifn,ia,ka)+tp
       
             ka=ka-1
             if(ka.eq.0)goto 282
             prx= temp1-ptail(ka)
          enddo
          endif  !eps .lt. emax     
          goto 282
        endif  !clamping is in effect
      elseif(iatt.eq.12)then
      call getMota(ip,iper,xmag,rrup,vs30,gnd,sigmaf)
      endif
      wttmp=wtbranch(ilt)*weight*rate
        do ifn=1,nfi
       k=1	!one level of g.m.
       pr=(gnd(ifn) - xlev)*sigmaf
       if(pr.gt.3.3)then
       ipr=250002
       elseif(pr.gt.plim)then
       ipr= 1+nint(dp2*(pr-plim))      !3sigma cutoff n'(mu,sig)
       else
       goto 283      !transfer out if ground motion above mu+3sigma
       endif
        cfac= wttmp*p(ipr)*gmwt(ifn)
c kg index is present: 2nd to last frontier.
        prob(ifn,kg)= prob(ifn,kg)+ cfac
c Deagg is set up for one ground motion per period. Thus no k index here.
c for individual fault
       eps= -pr*sqrt2
      if(ifn.eq.1)then
        fbaz(ift,1)=fbaz(ift,1)+cfac*cos(azimuth(m,irup,jrup))*1000.
        fbaz(ift,2)=fbaz(ift,2)+cfac*sin(azimuth(m,irup,jrup))*1000.
      endif
      if(eps.lt.emax)then
 	cfr=cfac*rrup; cma=cfac*xmag; ceps=cfac*eps
        frbar(ift,ifn,0)=frbar(ift,ifn,0)+cfr
        fmbar(ift,ifn,0)=fmbar(ift,ifn,0)+cma
        febar(ift,ifn,0)=febar(ift,ifn,0)+ceps
        fhaz(ift,ifn,0)=fhaz(ift,ifn,0)+cfac
        ieps=max(1,min(int((eps+2.)*2.),10))
        ie=ieps
       rbar(ir,im,ieps,ifn,0)=rbar(ir,im,ieps,ifn,0)+cfr
       mbar(ir,im,ieps,ifn,0)=mbar(ir,im,ieps,ifn,0)+cma
       ebar(ir,im,ieps,ifn,0)=ebar(ir,im,ieps,ifn,0)+ceps
       haz(ir,im,ieps,ifn,0)=haz(ir,im,ieps,ifn,0)+cfac
          if(l_ms.and.ifn.eq.1)then
c Add epsilon*rho*sigma. Currently sigspec is defined for each source (period and gm dependencies)
	meanspec=meanspec + eps*rho_jb*sigspec
          do jp=1,npnga
          meanspecs(ir,im,ie,jp,0)= meanspecs(ir,im,ie,jp,0)+ meanspec(jp)*cfac
          mean2spec(jp,0)= mean2spec(jp,0)+ meanspec(jp)*cfac
          enddo
c mean2spec(jp,ia)=big average spectrum and its big average distance, M, e0 for attn model ia.
          mean2haz(0)=mean2haz(0)+cfac
          mean2r(0)=mean2r(0)+cfr
          mean2m(0)=mean2m(0)+cma
          mean2e0(0)=mean2e0(0)+ceps
          hazmsp(ir,im,ie,0)=hazmsp(ir,im,ie,0)+cfac
          epsmsp(ir,im,ie,0)=epsmsp(ir,im,ie,0)+ceps
c          wtmsp(ir,im,ie,0)=wtmsp(ir,im,ie,0)+wttmp

          rmsp(ir,im,ie,0)=rmsp(ir,im,ie,0)+cfr
          mmsp(ir,im,ie,0)=mmsp(ir,im,ie,0)+cma
          endif
      if(dea_attn)then
        frbar(ift,ifn,ia)=frbar(ift,ifn,ia)+cfr
        fmbar(ift,ifn,ia)=fmbar(ift,ifn,ia)+cma
        febar(ift,ifn,ia)=febar(ift,ifn,ia)+ceps
        fhaz(ift,ifn,ia) =fhaz(ift,ifn,ia)+cfac
        rbar(ir,im,ieps,ifn,ia)=rbar(ir,im,ieps,ifn,ia)+cfr
        mbar(ir,im,ieps,ifn,ia)=mbar(ir,im,ieps,ifn,ia)+cma
        ebar(ir,im,ieps,ifn,ia)=ebar(ir,im,ieps,ifn,ia)+ceps
        haz(ir,im,ieps,ifn,ia) =haz(ir,im,ieps,ifn,ia)+cfac
          if(l_ms.and.ifn.eq.1)then
          do jp=1,npnga
          meanspecs(ir,im,ie,jp,ia)= meanspecs(ir,im,ie,jp,ia)+ meanspec(jp)*cfac
          mean2spec(jp,ia)= mean2spec(jp,ia)+ meanspec(jp)*cfac
          enddo
c mean2spec(jp,ia)=big average spectrum and its big average distance, M, e0 for attn model ia.
          mean2haz(ia)=mean2haz(ia)+cfac
          mean2r(ia)=mean2r(ia)+cfr
          mean2m(ia)=mean2m(ia)+cma
          mean2e0(ia)=mean2e0(ia)+ceps
          hazmsp(ir,im,ie,ia)=hazmsp(ir,im,ie,ia)+cfac
          epsmsp(ir,im,ie,ia)=epsmsp(ir,im,ie,ia)+ceps
c          wtmsp(ir,im,ie,ia)=wtmsp(ir,im,ie,ia)+wttmp

          rmsp(ir,im,ie,ia)=rmsp(ir,im,ie,ia)+cfac*rrup
          mmsp(ir,im,ie,ia)=mmsp(ir,im,ie,ia)+cma
c wttmp all weight factors except probability of exceedance
          endif
      endif	!deagg indiv GMPEs
      if(eps.ge.2.)goto 283
c Below keeps the books on epsilon distribution for e0<2. if e0>2 dont bother.
      ka=5
      temp=p(ipr)
      prx= temp-ptail(ka)
      dowhile(prx.gt.1.e-9)
      tp = wttmp*gmwt(ifn)*prx
      prob5(ir,im,ieps,ifn,0,ka)=prob5(ir,im,ieps,ifn,0,ka)+tp
      if(dea_attn)prob5(ir,im,ieps,ifn,ia,ka)=prob5(ir,im,ieps,ifn,ia,ka)+tp
       
      ka=ka-1
      if(ka.eq.0)goto 283
      prx= temp-ptail(ka)
      enddo
      endif      !eps <emax
283      continue
      enddo      !files
 282    continue
 284    continue
 285    continue

 403    continue
       enddo      !imag loop, diff. distributions.
        go to 850
        endif
ccccccccccccccccccccccccccccc
ccc---- GR with nmag0=1, one magnitude floated, with uncertainties,
c       used for some faults outside of CA and in 2002 Maacama northern CA
ccc--- for very long faults when Mmmax set to 7.5. In 2007 Maacama char has itype 1 
      if((itype(ift).eq.2).and.(nmag0(ift,1).eq.1).and.
     &  (itest(ift).eq.0)) then
      do imag=1,nmagf(ift)      !can have two or more distributions often
c with different Mmax.
        totmo=0.
        aspectratio=ar(1,1)      
c        write(6,*)ift,aspectratio,' one mag floated'
        do 1406 ilt=1,nbranch
c        isbig=ilt.gt.nbranch/2      !smaller M-branch omit from determ report
        xmag= magmax(ift,imag)+ dmbranch(ilt)
c cluster model new may 16 2007. Base cluster on mag and geographic branch for Char. For GR
c no cluster model has been specifically discussed
      if(cluster)then
      ks=1
      kg=1
      else
      ks=1
      kg=1
      endif
        xmo= 10.**(1.5*xmag+9.05)
c relative rate, nov 2006
        rate= relwt(ift,imag) * xmo2(ift,imag)/xmo
        if(rate.lt.tiny)goto 1406      !bypass irrelevant models aug 23 2007
        rate= rate/float(nrups(1,ift))
        do 1403 idis= -mwid, mwid
        xmag2= xmag+ idis*dma      !note change from 0.05 to the variable dma
c	print *,idis,xmag2,rate
          if(xmag2.lt.mcut(1))then
          ime=1
          elseif(xmag2.lt.mcut(2))then
          ime=2
          else
          ime=3
          endif
          im = nint((xmag2-5.7)*10.) +1
          im= max(1,im)
          im= min(33,im)
          immax=max(immax,im)
        wt1wt2=ale2(idis+mwid+1)*wtbranch(ilt)
c--- loop through floating rupture zones
      norpt=.true.	!Array ASSIGNMENT (ip, ia)
        do 1284 irup=1,nrups(1,ift)
c        totmo= totmo+ ale2(idis+mwid+1)*rate*10.**(1.5*xmag2+ 9.05)
C      write rate data if station list option is in effect.
c for big long faults assume all ruptures to surface... Discuss with colleagues?
c this case can happen for short faults such as creeping section. could have down-
c  dip rupture on these smaller sources.
        rjb=dmin2(1,irup,1,1)
c        isclose=abs(rjb-dmin(1)).lt.0.95      !just consider closest rupture for determ. report
          if(rjb.lt.dcut(1))then
          ide=1
          elseif(rjb.lt.dcut(2))then
          ide=2
          else
          ide=3
          endif
        ip=1
        iq=iper
        R_x = dmin2(1,irup,1,4)      !new signed distance oct 2007
        do 1282 ia=1,nattn
        rrup= dmin2(1,irup,1,3)
        weight= wt(ia,1)
        if(rjb.gt.wtdist(ia)) weight=wt(ia,2)
        if(rjb.gt.dmax) go to 1282
        if(rrup.le.110.)then
        ir=0.1*rrup + 1
        elseif(rrup.le.300.)then
        ir=12+(rrup-100.)/50.
        elseif(rrup.le.500.)then
        ir=16
        else
        ir=17
        endif 
      iatt=iatten(ia)
c
c nga relations are collected into the first set of models to check
      if(nga(ia)) then
        if(iatt.eq.13) then
      call getBANGA0308(iperb,xmag2,rjb,vs30,gnd,sigmaf)
         elseif(iatt.eq.14) then
        call getCampNGA0308 (ipercb,xmag2,rrup,rjb,dtor,
     1 vs30,dbasin,gnd,sigmaf)
	elseif(iatt.eq.33)then
	indx1=indbssa
	mech = ibtype(ift)
	call bssa2013drv(indx_pga,indx1,xmag2,rjb,vs30,z1cal,mech,iregion,alny,sigmaf)
c skip the 2nd period for now assume the period of interest was tabulated.
	gnd(1)=alny
         if(l_gnd_ep)then
         gnd(2)= gnd(1)+gnd_ep(ide,ime)
         gnd(3)= gnd(1)-gnd_ep(ide,ime)
         endif
	elseif(iatt.eq.34)then
c	SJ=0.0	!Are we in Japan? 1 = yes.
	Hhyp = dtor + 0.5*sinedip*width(ift)
	call CB13_NGA_SPEC  (ipcb13, xmag2,Rrup,R_x,Rjb,F_RV, F_NM,dtor,Hhyp,Width(ift),dbasin,Vs30,
     +Dip0(ift),SJ,gnd,sigmaf)
	elseif(iatt.eq.38)then
      if(rx.lt.-120..and.ry.gt.39.)then
      Q=Q_CA
      elseif(ry.le.39.-0.8*(rx+120.))then
      Q=Q_CA      
      else
      Q=Q_BR
      endif
	call gksa13v2(ipgk12,ip,xmag2,rrup,gnd,sigmaf,vs30,iftype(ift),dgkbasin,Q)
      elseif(iatt.eq.15)then
c 7/2007 implementation of getCYNGA 
      call CY2007H(ipercy, xmag2, rrup, rjb, R_x, vs30,z1, dtor,
     1                 F_RV, F_NM,  gnd, sigmaf)
c these particular floating ruptures always rupture to top of fault, dtor.
	elseif(iatt.eq.35)then
c from BChiou email use fmeasured=0. f_inferred is the model to use Aug 2013.
c dtor1 is top of floating rupture may be downdip
	F_Measured=0.
	F_Inferred=1.0	!could change these. Reference rock.
       call CY2013_NGA(icy13, xmag2, rrup, rjb, R_x, vs30,
     1                   F_Measured, F_Inferred, deltaZ1, dip0(ift), dtor,
     1                   F_RV, F_NM, cDPP(ift), gnd, tau, sigma_NL0, sigmaf)
c	print *,gnd(1),ift
c hanging-wall flag for as08 model added dec 7 2012.
	elseif(iatt.eq.16)then
c AS07 model
      if(dip0(ift).eq.90.)then
      hwflag=0
      elseif(rjb.le.0.01.and.r_x.ge.0.)then
      hwflag=1
      else
      hwflag=0
      endif

c Although iflag makes a token appearance in SR code, it isn't used. So I dropped iflag (SH).
       call AS_072007 (ipera,xmag2, dip0(ift), F_NM,F_RV, Width(ift), rRup, rjb,R_x,
     1                     vs30, hwflag, gnd(1), sigma1, dtor,  vs30_class,
     3                     z1km )
	sigmaf = 1./sqrt2/sigma1
c	print *,sigma1,gnd(1),'AS08'
         if(l_gnd_ep)then
         gnd(2)= gnd(1)+gnd_ep(ide,ime)
         gnd(3)= gnd(1)-gnd_ep(ide,ime)
         endif
        elseif (iatt.eq.36) then
c     Compute SA1100 for AS2013.  @W_rup is the rupture width (km). Downdip ruptures.
      SA_rock = 0.
c hanging-wall flag for as12 model added dec 7 2012.
      if(dip0(ift).eq.90.)then
      hwflag=0
      elseif(rjb.le.0.01.and.R_x.ge.0.)then
      hwflag=1
      else
      hwflag=0
      endif
      Ry0= -1.	!do not use this metric sept 2013
      call ASK13_v11_model ( ipas13,xmag2,dip0(ift), Width(ift), dtor, F_rv, F_NM, rRup, rjb, r_x, Ry0, 
     1                     vs30_rock, SA_rock, Z10_rock, z1_ref, hwflag, vs30_class,iReg,lnSa, phi, tau)
      Sa1180 = exp(lnSa)
	if(l_ms)then
	do jp=1,npnga
	if(jp.ne.jms)then
	jper = imsp(ia,jp)
      call ASK13_v11_model ( jper,xmag2,dip0(ift), Width(ift), dtor, F_rv, F_NM, rRup, rjb, r_x, Ry0, 
     1                     vs30_rock, SA_rock, Z10_rock, z1_ref, hwflag, vs30_class,iReg,lnSa, phi, tau)
      psa_hr(jp) = exp(lnSa)
      endif	!jp .ne. jms
      enddo	!CMS periods
      endif	!want CMS?
c 
c     Compute Sa at spectral period for given Vs30
      call ASK13_v11_model ( ipas13,xmag2, dip0(ift), Width(ift), dtor, F_rv, F_NM, rRup, rjb, r_x, Ry0, 
     1                     vs30, SA1180, z1km, z1_ref, hwflag, vs30_class,iReg,lnSa, phi, tau)
	gnd(1)=lnSa
         if(l_gnd_ep)then
         gnd(2)= gnd(1)+gnd_ep(ide,ime)
         gnd(3)= gnd(1)-gnd_ep(ide,ime)
         endif
        sigmaf = 1./sqrt( phi**2 + tau**2 )/sqrt2
	elseif(iatt.eq.37)then
	call  getIdriss2013(idriss,ip,xmag2,rrup,vs30,gnd,sigmaf)
        
      elseif(iatt.eq.17)then
      call getIdriss(ip,iper,xmag2,rjb,vs30,gnd,sigmaf)
      elseif(iatt.eq.18)then
c new nov 7,2006. Kanno
      call kanno(ip,iperk,gnd,sigmaf,xmag2,rrup,vsfac)
      endif
      elseif(wus02(ia))then
c WUS pre-nga (2002 atten models)
      if(iatt.eq.1)then
      call getSpu2000(ip,iq,xmag2,rjb,vs30,gnd,sigmaf)
      elseif(iatt.eq.3)then
      call getsadigh(ip,iq,xmag2,rrup,gnd,sigmaf)
      elseif(iatt.eq.8)then
      call getAS97(ip,iq,xmag2,rrup,hwsite,gnd,sigmaf)
       elseif(iatt.eq.9)then
       call getCamp2003(ip,iq,xmag2,rrup,rjb,gnd,sigmaf)
      elseif(iatt.eq.11)then
      call getBJF97(ip,iq,xmag2,rjb,vs30,gnd,sigmaf)
      elseif(iatt.eq.-3)then
        call SomerIMW(ip,isomer, xmag2,  rrup, rjb,vs30,gnd,sigmaf)
      endif
      elseif(ceus11(ia))Then
c new code for CEUS11 GMPEs added june 17 2013.
       rjbp=max(rjb,0.11)
       if(iatt.eq.25)then
      rkm=rjbp
      jf=ia08
             ka=1
             sigma = 0.3*2.303
       gnd(1) = amean11(xmag2,rkm,rjbp,vs30,jf,ka)
	if(l_ms)then
	sigspec=sigma	!same value all periods
	meanspec(jms)=gnd(1)
	do j=1,npnga-2	!5s max for the CEUS11 relations.
	if(lmsp(ia,j) .and. j.ne.jms)then
	jp=imsp(ia,j)
	meanspec(j)=amean11(xmag,rkm,rjbp,vs30,jp,ka)
	endif
	enddo
	endif
       if(lceus_sigma)sigma=ceus_sigma !for special study 3/2011
c     print *,gnd,rkm,ip,jf,ka
       sigmaf = 1./sqrt2/sigma
       elseif(iatt.eq.26)then
       rkm=rrup
       jf=ia06
       ka=2
             sigma = 0.3*2.303
       gnd(1) = amean11(xmag2,rkm,rjbp,vs30,jf,ka)
	if(l_ms)then
	sigspec=sigma	!same value all periods
	meanspec(jms)=gnd(1)
	do j=1,npnga-2	!5s max for the CEUS11 relations.
	if(lmsp(ia,j) .and. j.ne.jms)then
	jp=imsp(ia,j)
	meanspec(j)=amean11(xmag,rkm,rjbp,vs30,jp,ka)
	endif
	enddo
	endif
       if(lceus_sigma)sigma=ceus_sigma !for special study 3/2011
c     print *,gnd,rkm,ip,jf,ka
       sigmaf = 1./sqrt2/sigma
       elseif(iatt.eq.27)then
       rkm=rrup
       jf=ip11
c 2nd variable in sigPez11 is the frequency index according to the GailA set 2011.
      sigma = sigPez11(xmag2,jf)	!new 10/30/2012. SH.
       ka=3
       gnd(1) = amean11(xmag,rkm,rjbp,vs30,jf,ka)
	if(l_ms)then
	sigspec=sigma	!same value all periods
	meanspec(jms)=gnd(1)
	do j=1,npnga-2	!5s max for the CEUS11 relations.
	if(lmsp(ia,j) .and. j.ne.jms)then
	jp=imsp(ia,j)
	meanspec(j)=amean11(xmag,rkm,rjbp,vs30,jp,ka)
	endif
	enddo
	endif
       if(lceus_sigma)sigma=ceus_sigma !for special study 3/2011
c     print *,gnd,rkm,ip,jf,ka
       sigmaf = 1./sqrt2/sigma
c the rest of these are pre-2011 models
      	endif !iatt=25,26, or 27?
      elseif(ceus02(ia))then
c CEUS  (2002 and 2006 atten models)
c
      if(iatt.eq.2)then
      call getToro(iptoro,1,xmag2,rjb,gnd,sigma,sigmaf)
      elseif(iatt.eq.-2)then
      call getToro(iptoro,2,xmag2,rjb,gnd,sigma,sigmaf)
        elseif(iatt.eq.4)then
        call getAB06(iperab,irab(ia),xmag2,rrup,gnd,sigma,sigmaf,vs30)
        elseif(iatt.eq.19)then
      call getTP05(ipertp,irtb,xmag2,rrup,gnd,sigma,sigmaf)
        elseif(iatt.eq.20)then
      call getSilva(isilva,irsilva,xmag2,rjb,gnd,sigma,sigmaf)
      elseif(iatt.eq.6)then
      call getFEA(ip,iq,1,xmag2,rrup,gnd,sigma,sigmaf)
      elseif(iatt.eq.-6)then      !to distinguish ab95 from fea
      call getFEA(ip,iq,3,xmag2,rrup,gnd,sigma,sigmaf)
      elseif(iatt.eq.5)then      !HR
c hard rock possibilities. 
      call getFEA(ip,iq,2,xmag2,rrup,gnd,sigma,sigmaf)
      elseif(iatt.eq.-5)then      !HR for atkinson-boore
      call getFEA(ip,iq,4,xmag2,rrup,gnd,sigma,sigmaf)
      elseif(iatt.eq.7) then
        call getSomer(iq,1,xmag2,rjb,gnd,sigma,sigmaf)
      elseif(iatt.eq.-7) then
        call getSomer(iq,2,xmag2,rjb,gnd,sigma,sigmaf)
             elseif(iatt.eq.10)then
        call getCampCEUS(ipcmpc,1,xmag2,rrup,gnd,sigma,sigmaf)
             elseif(iatt.eq.-10)then
        call getCampCEUS(ipcmpc,2,xmag2,rrup,gnd,sigma,sigmaf)
      endif
c This is a good place to apply the extra clamp constraint which
c in 2002 was used only for CEUS sources. The precomputed p() matrix does
c not work for this case because truncation is no longer at mu+3sig
      test0=gnd(1)+3.*sigma
      test= exp(test0)
      if(clamp(iq).lt.test .and. clamp(iq).gt.0.) then
      clamp2= alog(clamp(iq))
      sigmasq=1./sigma/sqrt2
      tempgt3= (gnd(1) - clamp2)*sigmasq
      probgt3= (erf(tempgt3)+1.)*0.5
      prr= 1./(1.-probgt3)
c GR-region is not ready for clustered event. KG index (last dim of prob) is 1.
      temp= (gnd(1) - xlev)*sigmasq
      temp1= (erf(temp)+1.)*0.5
      temp1= (temp1-probgt3)*prr
      if(temp1.lt.0.) goto 1282      !no more calcs once p<0
        prob(1,1)= prob(1,1)+ wt1wt2*weight*rate*temp1
c deaggregation for the special case. not prepared oct 30 2007. This model is not in use in CEUS.
         goto 1282
        endif
      elseif(iatt.eq.12)then
      call getMota(ip,iper,xmag2,rrup,vs30,gnd,sigmaf)
      endif
      wttmp=wt1wt2*weight*rate
        do ifn=1,nfi
       pr=(gnd(ifn) - xlev)*sigmaf
       if(pr.gt.3.3)then
       ipr=250002
       elseif(pr.gt.plim)then
       ipr= 1+nint(dp2*(pr-plim))      !3sigma cutoff n'(mu,sig)
       else
       goto 1283      !transfer out if ground motion above mu+3sigma
       endif
      cfac=wttmp*p(ipr)*gmwt(ifn)
        prob(ifn,kg)= prob(ifn,kg)+cfac
c for individual fault
               eps= -pr*sqrt2
      if(ifn.eq.1)then
        fbaz(ift,1)=fbaz(ift,1)+cfac*cos(azimuth(1,irup,1))*1000.
        fbaz(ift,2)=fbaz(ift,2)+cfac*sin(azimuth(1,irup,1))*1000.
c          print  *,fbaz(ift,1),azimuth(1,irup,1),rrup,irup,' gr1 with unc'
      endif
c ifn index is present: 2nd to last frontier. ieps is  an explicit dimension, recomm. by Bazzuro
c Some attn. models will say a given M,R is a low eps0 combination, others will say a higher eps0.
c 
      if(eps.lt.emax)then
	cfr=cfac*rrup; cma=cfac*xmag2; ceps=cfac*eps
      frbar(ift,ifn,0)=frbar(ift,ifn,0)+cfr
      fmbar(ift,ifn,0)=fmbar(ift,ifn,0)+cma
      febar(ift,ifn,0)=febar(ift,ifn,0)+ceps
      fhaz(ift,ifn,0) =fhaz(ift,ifn,0)+cfac
      ieps=max(1,min(int((eps+2.)*2.),10))
      ie=ieps
      rbar(ir,im,ieps,ifn,0)=rbar(ir,im,ieps,ifn,0)+cfr
      mbar(ir,im,ieps,ifn,0)=mbar(ir,im,ieps,ifn,0)+cma
      ebar(ir,im,ieps,ifn,0)=ebar(ir,im,ieps,ifn,0)+ceps
      haz(ir,im,ieps,ifn,0) =haz(ir,im,ieps,ifn,0)+cfac
          if(l_ms.and.ifn.eq.1)then
c Add epsilon*sigma(T)
	meanspec=meanspec + eps*rho_jb*sigspec
          do jp=1,npnga
          meanspecs(ir,im,ie,jp,0)= meanspecs(ir,im,ie,jp,0)+ meanspec(jp)*cfac
          mean2spec(jp,0)= mean2spec(jp,0)+ meanspec(jp)*cfac
          enddo
c mean2spec(jp,0)=big average spectrum and its big average distance, M, e0 over all variables.
          mean2haz(0)=mean2haz(0)+cfac
          mean2r(0)=mean2r(0)+cfr
          mean2m(0)=mean2m(0)+cma
          mean2e0(0)=mean2e0(0)+ceps
           hazmsp(ir,im,ie,0)=hazmsp(ir,im,ie,0)+cfac
          epsmsp(ir,im,ie,0)=epsmsp(ir,im,ie,0)+ceps
c          wtmsp(ir,im,ie,0)=wtmsp(ir,im,ie,0)+wttmp

c wttmp all weight factors except probability of exceedance
          rmsp(ir,im,ie,0)=rmsp(ir,im,ie,0)+cfr
          mmsp(ir,im,ie,0)=mmsp(ir,im,ie,0)+cma
          endif
      if(dea_attn)then
      frbar(ift,ifn,ia)=frbar(ift,ifn,ia)+cfr
      fmbar(ift,ifn,ia)=fmbar(ift,ifn,ia)+cma
      febar(ift,ifn,ia)=febar(ift,ifn,ia)+ceps
      fhaz(ift,ifn,ia) =fhaz(ift,ifn,ia)+cfac
      rbar(ir,im,ieps,ifn,ia)=rbar(ir,im,ieps,ifn,ia)+cfr
      mbar(ir,im,ieps,ifn,ia)=mbar(ir,im,ieps,ifn,ia)+cma
      ebar(ir,im,ieps,ifn,ia)=ebar(ir,im,ieps,ifn,ia)+ceps
      haz(ir,im,ieps,ifn,ia) =haz(ir,im,ieps,ifn,ia)+cfac
          if(l_ms.and.ifn.eq.1)then
          do jp=1,npnga
          meanspecs(ir,im,ie,jp,ia)= meanspecs(ir,im,ie,jp,ia)+ meanspec(jp)*cfac
          mean2spec(jp,ia)= mean2spec(jp,ia)+ meanspec(jp)*cfac
          enddo
c mean2spec(jp,ia)=big average spectrum and its big average distance, M, e0 for attn model ia.
          mean2haz(ia)=mean2haz(ia)+cfac
          mean2r(ia)=mean2r(ia)+cfr
          mean2m(ia)=mean2m(ia)+cma
          mean2e0(ia)=mean2e0(ia)+ceps
          hazmsp(ir,im,ie,ia)=hazmsp(ir,im,ie,ia)+cfac
          epsmsp(ir,im,ie,ia)=epsmsp(ir,im,ie,ia)+ceps
          rmsp(ir,im,ie,ia)=rmsp(ir,im,ie,ia)+cfr
          mmsp(ir,im,ie,ia)=mmsp(ir,im,ie,ia)+cma
          endif
      endif	!deagg indiv GMPEs
      if(eps.ge.2.)goto 1283
c Below keeps the books on epsilon distribution for e0<2. if e0>2 dont bother.
      ka=5
      temp=p(ipr)
      prx= temp-ptail(ka)
      dowhile(prx.gt.1.e-9)
      tp=wttmp*gmwt(ifn)*prx
      prob5(ir,im,ieps,ifn,0,ka)=prob5(ir,im,ieps,ifn,0,ka) +tp
      if(dea_attn)prob5(ir,im,ieps,ifn,ia,ka)=prob5(ir,im,ieps,ifn,ia,ka)+tp
      ka=ka-1
      if(ka.eq.0)goto 1283
      prx= temp-ptail(ka)
      enddo
      endif      !eps <emax
           enddo
1283      continue
1282    continue
1284    continue
1403    continue
1406      continue	!added outer loop 8/2007, for goto if rate<tiny
      enddo      !imag new index 6/2006. Multiple mmax rate per fault.
c        write(6,*) totmo,(xmo2(ift,j),j=1,nmagf(ift))
c        read(5,*) idum
        go to 850
        endif
c---------------------
c------ all GR without uncertainties, with possible downdip ruptures, z=dtor1
      if((itype(ift).eq.2).and.(itest(ift).eq.1)) then
c-- loop through magnitudes
        iftype2= iftype(ift)
        dtor = depth0(ift)      !depth to top of fault
      do imag=1,nmagf(ift)      !can have two or more distributions often
c with diffrent Mmax.
        do 2285 m=1,nmag0(ift,imag)
        xmag= magmin(ift,imag)+(m-1)*dmag(ift,imag)
        rate= a(ift,imag) - b(ift,imag)*xmag
c relative rate
        rate= relwt(ift,imag) * 10.**rate
        if(rate.lt.tiny)goto 2285      !bypass irrelevant models aug 23 2007
       im = nint((xmag-5.7)*10.)+1
       im=max(im, 1)
       im=min(im,33)
       immax=max(immax,im)
          if(xmag.lt.mcut(1))then
          ime=1
          elseif(xmag.lt.mcut(2))then
          ime=2
          else
          ime=3
          endif
      if(nearsrc)then
      nrupdd=nrupd(m,ift)
      else
      nrupdd=1
      endif 
        rate= rate/float(nrups(m,ift)*nrupdd)
        kg=1      !no clustering in GR region june 2007
c--- down-dip loop through floating rupture zones
      do 2284 jrup=1,nrupdd
      norpt=.true.      !report deterministic only once vector assignment
        aspectratio=ar(m,jrup)
        dz=dlen2*float(jrup-1)
        w_rup=width(ift)-dz
        dtor1=dtor + dz      !all important depth to top of rupture.
        cyhwfac=atan((width(ift)-dz)*0.5*cosDELTA/(dtor1+1.0))/(pi*0.5)
c variable factor above for CY relation when downdip rupture occurs        
c--- along-strike loop through floating rupture zones
        do 2284 irup=1,nrups(m,ift)
        rjb  = dmin2(m,irup,jrup,1)
          if(rjb.lt.dcut(1))then
          ide=1
          elseif(rjb.lt.dcut(2))then
          ide=2
          else
          ide=3
          endif
        ip=1
        iq=iper      !std period index
        R_x = dmin2(m,irup,jrup,4)      !new R_x signed distance 10/07
        do 2282 ia=1,nattn
         iftype2= iftype(ift)
         rrup = dmin2(m,irup,jrup,3)
        weight= wt(ia,1)
        if(rjb.gt.wtdist(ia)) weight=wt(ia,2)
        if(rjb.gt.dmax) go to 2282
        if(rrup.le.110.)then
        ir=0.1*rrup + 1
        elseif(rrup.le.300.)then
        ir=12+(rrup-100.)/50.
        elseif(rrup.le.500.)then
        ir=16
        else
        ir=17
        endif 
      iatt=iatten(ia)
c nga relations are collected into the first set of models to check
      if(nga(ia)) then
        if(iatt.eq.13) then
      call getBANGA0308(iperb,xmag,rjb,vs30,gnd,sigmaf)
         elseif(iatt.eq.14) then
        call getCampNGA0308 (ipercb,xmag,rrup,rjb,dtor1,
     1 vs30,dbasin,gnd,sigmaf)
	elseif(iatt.eq.33)then
	indx1=indbssa
	mech = ibtype(ift)
	call bssa2013drv(indx_pga,indx1,xmag,rjb,vs30,z1cal,mech,iregion,alny,sigmaf)
c skip the 2nd period for now assume the period of interest was tabulated.
	gnd(1)=alny
         if(l_gnd_ep)then
         gnd(2)= gnd(1)+gnd_ep(ide,ime)
         gnd(3)= gnd(1)-gnd_ep(ide,ime)
         endif
	elseif(iatt.eq.34)then
c	SJ=0.0	!Are we in Japan? 1 = yes.
c	Hhyp=min(12.,dtor+8.)	!Take a stab at hypocenter depth.
	Hhyp = dtor1+0.5*sinedip*w_rup
c use same definition as Open SHA (half-way down the rupture plane)
	call CB13_NGA_SPEC  (ipcb13, xmag,Rrup,R_x,Rjb,F_RV, F_NM,dtor,Hhyp,Width(ift),dbasin,Vs30,
     +Dip0(ift),SJ,gnd,sigmaf)
	elseif(iatt.eq.38)then
      if(rx.lt.-120..and.ry.gt.39.)then
      Q=Q_CA
      elseif(ry.le.39.-0.8*(rx+120.))then
      Q=Q_CA      
      else
      Q=Q_BR
      endif
	call gksa13v2(ipgk12,ip,xmag,rrup,gnd,sigmaf,vs30,iftype(ift),dgkbasin,Q)
      elseif(iatt.eq.15)then
c 10/2007 implementation of getCYNGA 
      call CY2007H(ipercy, xmag, rrup, rjb, R_x, vs30,z1, dtor1,
     1                 F_RV, F_NM,  gnd, sigmaf)
	elseif(iatt.eq.35)then
c from BChiou email use fmeasured=0. f_inferred is the model to use Aug 2013.
c dtor1 is top of floating rupture may be downdip
	F_Measured=0.
	F_Inferred=1.0	!could change these. Reference rock.
       call CY2013_NGA(icy13, xmag, rrup, rjb, R_x, vs30,
     1                   F_Measured, F_Inferred, deltaZ1, dip0(ift), dtor1,
     1                   F_RV, F_NM, cDPP(ift), gnd, tau, sigma_NL0, sigmaf)
c	print *,gnd(1),ift
        elseif (iatt.eq.16) then
c hanging-wall flag for as08 model added dec 7 2012.
	print *,'going into AS08 model why?'
      if(dip0(ift).eq.90.)then
      hwflag=0
      elseif(rjb.le.0.01.and.r_x.ge.0.)then
      hwflag=1
      else
      hwflag=0
      endif
c Although iflag makes a token appearance in SR code, it isn't used. So I dropped iflag (SH).
       call AS_072007 (ipera,xmag, dip0(ift), F_NM,F_RV, W_rup, rRup, rjb,R_x,
     1                     vs30, hwflag, gnd(1), sigma1, dtor1,  vs30_class,
     3                     z1km )
        sigmaf = 1./sqrt2/sigma1
c	print *,sigma1,gnd(1),'AS08'
                 if(l_gnd_ep)then
         gnd(2)= gnd(1)+gnd_ep(ide,ime)
         gnd(3)= gnd(1)-gnd_ep(ide,ime)
         endif
        elseif (iatt.eq.36) then
c     Compute SA1180 for AS2013. New Dec 7 2012. @W_rup is the rupture width (km). Downdip ruptures.
      SA_rock = 0.
c hanging-wall flag for as12 model added dec 7 2012.
      if(dip0(ift).eq.90.)then
      hwflag=0
      elseif(rjb.le.0.01.and.R_x.ge.0.)then
      hwflag=1
      else
      hwflag=0
      endif
      SA_rock = 0.
      Ry0= -1.	!do not use this metric sept 2013
      call ASK13_v11_model ( ipas13,xmag,dip0(ift), W_rup, dtor1, F_rv, F_NM, rRup, rjb, r_x, Ry0, 
     1                     vs30_rock, SA_rock, Z10_rock, z1_ref, hwflag, vs30_class,iReg,lnSa, phi, tau)
      Sa1180 = exp(lnSa)
	if(l_ms)then
	do jp=1,npnga
	if(jp.ne.jms)then
	jper = imsp(ia,jp)
      call ASK13_v11_model ( jper,xmag,dip0(ift), W_rup, dtor1, F_rv, F_NM, rRup, rjb, r_x, Ry0, 
     1                     vs30_rock, SA_rock, Z10_rock, z1_ref, hwflag, vs30_class,iReg,lnSa, phi, tau)
      psa_hr(jp) = exp(lnSa)
      endif	!jp .ne. jms
      enddo	!CMS periods
      endif	!want CMS?
c 
c     Compute Sa at spectral period for given Vs30
      call ASK13_v11_model ( ipas13,xmag, dip0(ift), W_rup, dtor1, F_rv, F_NM, rRup, rjb, r_x, Ry0, 
     1                     vs30, SA1180, z1km, z1_ref, hwflag, vs30_class,iReg,lnSa, phi, tau)
	gnd(1)=lnSa
         if(l_gnd_ep)then
         gnd(2)= gnd(1)+gnd_ep(ide,ime)
         gnd(3)= gnd(1)-gnd_ep(ide,ime)
         endif
        sigmaf = 1./sqrt( phi**2 + tau**2 )/sqrt2
	elseif(iatt.eq.37)then
	call  getIdriss2013(idriss,ip,xmag,rrup,vs30,gnd,sigmaf)
      elseif(iatt.eq.17)then
      call getIdriss(ip,iper,xmag,rjb,vs30,gnd,sigmaf)
      elseif(iatt.eq.18)then
c new nov 7,2006. Kanno
      call kanno(ip,iperk,gnd,sigmaf,xmag,rrup,vsfac)
      endif
      elseif(wus02(ia))then
c WUS pre-nga (2002 atten models)
      if(iatt.eq.1)then
      call getSpu2000(ip,iq,xmag,rjb,vs30,gnd,sigmaf)
      elseif(iatt.eq.3)then
      call getsadigh(ip,iq,xmag,rrup,gnd,sigmaf)
      elseif(iatt.eq.8)then
      call getAS97(ip,iq,xmag,rrup,hwsite,gnd,sigmaf)
       elseif(iatt.eq.9)then
       call getCamp2003(ip,iq,xmag,rrup,rjb,gnd,sigmaf)
      elseif(iatt.eq.11)then
      call getBJF97(ip,iq,xmag,rjb,vs30,gnd,sigmaf)
      elseif(iatt.eq.-3)then
        call SomerIMW(ip,isomer, xmag,  rrup, rjb,vs30,gnd,sigmaf)
      endif
      elseif(ceus11(ia))Then
c new code for CEUS11 GMPEs added june 17 2013.
       rjbp=max(rjb,0.11)
       if(iatt.eq.25)then
      rkm=rjbp
      jf=ia08
             ka=1
             sigma = 0.3*2.303
       gnd(1) = amean11(xmag,rkm,rjbp,vs30,jf,ka)
	if(l_ms)then
	sigspec=sigma	!same value all periods
	meanspec(jms)=gnd(1)
	do j=1,npnga-2	!5s max for the CEUS11 relations.
	if(lmsp(ia,j) .and. j.ne.jms)then
	jp=imsp(ia,j)
	meanspec(j)=amean11(xmag,rkm,rjbp,vs30,jp,ka)
	endif
	enddo
	endif
       if(lceus_sigma)sigma=ceus_sigma !for special study 3/2011
c     print *,gnd,rkm,ip,jf,ka
       sigmaf = 1./sqrt2/sigma
       elseif(iatt.eq.26)then
       rkm=rrup
       jf=ia06
       ka=2
             sigma = 0.3*2.303
       gnd(1) = amean11(xmag,rkm,rjbp,vs30,jf,ka)
	if(l_ms)then
	sigspec=sigma	!same value all periods
	meanspec(jms)=gnd(1)
	do j=1,npnga-2	!5s max for the CEUS11 relations.
	if(lmsp(ia,j) .and. j.ne.jms)then
	jp=imsp(ia,j)
	meanspec(j)=amean11(xmag,rkm,rjbp,vs30,jp,ka)
	endif
	enddo
	endif
       if(lceus_sigma)sigma=ceus_sigma !for special study 3/2011
c     print *,gnd,rkm,ip,jf,ka
       sigmaf = 1./sqrt2/sigma
       elseif(iatt.eq.27)then
       rkm=rrup
       jf=ip11
c 2nd variable in sigPez11 is the frequency index according to the GailA set 2011.
      sigma = sigPez11(xmag,jf)	!new 10/30/2012. SH.
       ka=3
       gnd(1) = amean11(xmag,rkm,rjbp,vs30,jf,ka)
	if(l_ms)then
	sigspec=sigma	!same value all periods
	meanspec(jms)=gnd(1)
	do j=1,npnga-2	!5s max for the CEUS11 relations.
	if(lmsp(ia,j) .and. j.ne.jms)then
	jp=imsp(ia,j)
	meanspec(j)=amean11(xmag,rkm,rjbp,vs30,jp,ka)
	endif
	enddo
	endif
       if(lceus_sigma)sigma=ceus_sigma !for special study 3/2011
c     print *,gnd,rkm,ip,jf,ka
       sigmaf = 1./sqrt2/sigma
c the rest of these are pre-2011 models
      	endif !iatt=25,26, or 27?
      elseif(ceus02(ia))then
c
c CEUS pre-nga (2002 atten models). These motions can be "clamped"
c
      if(iatt.eq.2)then
      call getToro(iptoro,1,xmag,rjb,gnd,sigma,sigmaf)
      elseif(iatt.eq.-2)then
      call getToro(iptoro,2,xmag,rjb,gnd,sigma,sigmaf)
        elseif(iatt.eq.4)then
        call getAB06(iperab,irab(ia),xmag,rrup,gnd,sigma,sigmaf,vs30)
        elseif(iatt.eq.19)then
      call getTP05(ipertp,irtb,xmag,rrup,gnd,sigma,sigmaf)
        elseif(iatt.eq.20)then
      call getSilva(isilva,irsilva,xmag,rjb,gnd,sigma,sigmaf)
      elseif(iatt.eq.6)then
      call getFEA(ip,iq,1,xmag,rrup,gnd,sigma,sigmaf)
      elseif(iatt.eq.-6)then      !HR
      call getFEA(ip,iq,3,xmag,rrup,gnd,sigma,sigmaf)
      elseif(iatt.eq.5)then      !Rto distinguish ab95 from fea
      call getFEA(ip,iq,2,xmag,rrup,gnd,sigma,sigmaf)
      elseif(iatt.eq.-5)then      !HR for atkinson-boore
      call getFEA(ip,iq,4,xmag,rrup,gnd,sigma,sigmaf)
      elseif(iatt.eq.7) then
        call getSomer(iq,1,xmag,rjb,gnd,sigma,sigmaf)
      elseif(iatt.eq.-7) then
        call getSomer(iq,2,xmag,rjb,gnd,sigma,sigmaf)
             elseif(iatt.eq.10)then
        call getCampCEUS(ipcmpc,1,xmag,rrup,gnd,sigma,sigmaf)
             elseif(iatt.eq.-10)then
        call getCampCEUS(ipcmpc,2,xmag,rrup,gnd,sigma,sigmaf)
      endif
c This is a good place to apply the extra clamp constraint which
c in 2002 was used only for CEUS sources. The precomputed p() matrix does
c not work for this case because truncation is no longer at mu+3sig.
c In 2007-2008 there is no epistemic branching on gnd (within an attn model). 
c Thus, look at gnd(1) only.
      test0=gnd(1)+3.*sigma
      test= exp(test0)
      if(clamp(iq).lt.test .and. clamp(iq).gt.0.) then
      clamp2= alog(clamp(iq))
      sigmasq=1./sigma/sqrt2
      tempgt3= (gnd(1) - clamp2)*sigmasq
      probgt3= (erf(tempgt3)+1.)*0.5
      prr=1./(1.-probgt3)
       k=1
      temp= (gnd(1) - xlev)*sigmasq
      temp1= (erf(temp)+1.)*0.5
      temp1= (temp1-probgt3)*prr
      if(temp1.le.0.) goto 2282      !no more calcs if p<0
      wttmp=weight*rate
      cfac=wttmp*temp1
c GR, without uncert: deagg matrices need to be filled in here.
      if(cluster)then
            prx=weight*temp1
            eps= -temp*sqrt2
            prob_s(jseg(ift),ks,kg)= prob_s(jseg(ift),ks,kg)+prx
            r_s(jseg(ift),ks,kg)= r_s(jseg(ift),ks,kg)+rrup*prx
            m_s(jseg(ift),ks,kg)= m_s(jseg(ift),ks,kg)+xmag*prx
            eps_s(jseg(ift),ks,kg)= eps_s(jseg(ift),ks,kg)+eps *prx 
c            n_s(jseg(ift),ks,kg)= n_s   (jseg(ift),ks,kg)+1     
      else
        prob(1,kg)= prob(1,kg)+ cfac
c for individual fault
        eps= -temp*sqrt2
      if(ifn.eq.1)then
        fbaz(ift,1)=fbaz(ift,1)+cfac*cos(azimuth(m,irup,jrup))*1000.
        fbaz(ift,2)=fbaz(ift,2)+cfac*sin(azimuth(m,irup,jrup))*1000.
      endif
c ifn index is related to epistemic uncert. ieps is  an explicit dimension, recomm. by Bazzuro
c Some attn. models may claim a given M,R is a low eps0 combination, others will say a higher eps0.
c 
	cfr=cfac*rrup; cma=cfac*xmag; ceps=cfac*eps
        if(eps.lt.emax)then
        frbar(ift,ifn,0)=frbar(ift,ifn,0)+cfr
        fmbar(ift,ifn,0)=fmbar(ift,ifn,0)+cma
        febar(ift,ifn,0)=febar(ift,ifn,0)+ceps
        fhaz(ift,ifn,0)=fhaz(ift,ifn,0)+cfac
        ieps=max(1,min(int((eps+2.)*2.),10))
        ie=ieps
        rbar(ir,im,ieps,ifn,0)=rbar(ir,im,ieps,ifn,0)+cfr
        mbar(ir,im,ieps,ifn,0)=mbar(ir,im,ieps,ifn,0)+cma
        ebar(ir,im,ieps,ifn,0)=ebar(ir,im,ieps,ifn,0)+ceps
        haz(ir,im,ieps,ifn,0)=haz(ir,im,ieps,ifn,0)+cfac
          if(l_ms.and.ifn.eq.1)then
c Add epsilon*sigma
	meanspec=meanspec + epsb*rho_jb*sigspec
          do jp=1,npnga
          meanspecs(ir,im,ie,jp,0)= meanspecs(ir,im,ie,jp,0)+ meanspec(jp)*cfac
          mean2spec(jp,0)= mean2spec(jp,0)+ meanspec(jp)*cfac
          enddo
c mean2spec(jp,0)=big average spectrum and its big average distance, M, e0 over all variables.
          mean2haz(0)=mean2haz(0)+cfac
          mean2r(0)=mean2r(0)+cfr
          mean2m(0)=mean2m(0)+cma
          mean2e0(0)=mean2e0(0)+ceps
          hazmsp(ir,im,ie,0)=hazmsp(ir,im,ie,0)+cfac
          epsmsp(ir,im,ie,0)=epsmsp(ir,im,ie,0)+ceps
c          wtmsp(ir,im,ie,0)=wtmsp(ir,im,ie,0)+wttmp

          rmsp(ir,im,ie,0)=rmsp(ir,im,ie,0)+cfac*rrup
          mmsp(ir,im,ie,0)=mmsp(ir,im,ie,0)+cma
          endif
      if(dea_attn)then
      frbar(ift,ifn,ia)=frbar(ift,ifn,ia)+cfr
      fmbar(ift,ifn,ia)=fmbar(ift,ifn,ia)+cma
      febar(ift,ifn,ia)=febar(ift,ifn,ia)+cfac*eps
      fhaz(ift,ifn,ia) =fhaz(ift,ifn,ia)+cfac
      rbar(ir,im,ieps,ifn,ia)=rbar(ir,im,ieps,ifn,ia)+cfr
      mbar(ir,im,ieps,ifn,ia)=mbar(ir,im,ieps,ifn,ia)+cma
      ebar(ir,im,ieps,ifn,ia)=ebar(ir,im,ieps,ifn,ia)+ceps
      haz(ir,im,ieps,ifn,ia) =haz(ir,im,ieps,ifn,ia)+cfac
          if(l_ms.and.ifn.eq.1)then
          do jp=1,npnga
          meanspecs(ir,im,ie,jp,ia)= meanspecs(ir,im,ie,jp,ia)+ meanspec(jp)*cfac
          mean2spec(jp,ia)= mean2spec(jp,ia)+ meanspec(jp)*cfac
          enddo
c mean2spec(jp,ia)=big average spectrum and its big average distance, M, e0 for attn model ia.
          mean2haz(ia)=mean2haz(ia)+cfac
          mean2r(ia)=mean2r(ia)+cfr
          mean2m(ia)=mean2m(ia)+cma
          mean2e0(ia)=mean2e0(ia)+ceps
          hazmsp(ir,im,ie,ia)=hazmsp(ir,im,ie,ia)+cfac
          epsmsp(ir,im,ie,ia)=epsmsp(ir,im,ie,ia)+ceps
           rmsp(ir,im,ie,ia)=rmsp(ir,im,ie,ia)+cfac*rrup
          mmsp(ir,im,ie,ia)=mmsp(ir,im,ie,ia)+cma
         endif
      endif	!deagg indiv GMPEs
        if(eps.ge.2.)goto 2282
c Below keeps the books on epsilon distribution for e0<2. Resid for e0>2 .
        wttmp=weight*rate
        ka=5
        prx= temp1-ptail(ka)
        dowhile(prx.gt.1.e-9)
        tp = wttmp*gmwt(ifn)*prx
        prob5(ir,im,ieps,ifn,0,ka)=prob5(ir,im,ieps,ifn,0,ka)+tp
        if(dea_attn)prob5(ir,im,ieps,ifn,ia,ka)=prob5(ir,im,ieps,ifn,ia,ka)+tp
c  
        ka=ka-1
        if(ka.eq.0)goto 2282
        prx= temp1 -ptail(ka)
        enddo
        endif      !eps <emax
        endif      !if cluster
        goto 2282
      endif   !clamp in use.
      elseif(iatt.eq.12)then
      call getMota(ip,iper,xmag,rrup,vs30,gnd,sigmaf)
      endif
      wttmp=weight*rate
        do ifn=1,nfi
        k=1
        pr=(gnd(ifn) - xlev)*sigmaf
       if(pr.gt.3.3)then
       ipr=250002
       elseif(pr.gt.plim)then
       ipr= 1+nint(dp2*(pr-plim))      !3sigma cutoff n'(mu,sig)
       else
       goto 2283      !transfer out if ground motion above mu+3sigma
       endif
c apply gmuncert weight here. aug 4 2008
      cfac =  wttmp*p(ipr)*gmwt(ifn)
        prob(ifn,kg)= prob(ifn,kg)+cfac 
c for individual fault
               eps= -pr*sqrt2
      if(ifn.eq.1)then
        fbaz(ift,1)=fbaz(ift,1)+cfac*cos(azimuth(m,irup,jrup))*1000.
        fbaz(ift,2)=fbaz(ift,2)+cfac*sin(azimuth(m,irup,jrup))*1000.
      endif
c ifn index is present: 2nd to last frontier. ieps is  an explicit dimension, recomm. by Bazzuro
c Some attn. models will say a given M,R is a low eps0 combination, others will say a higher eps0.
c store separate ifn in different records. Why? to give 'em diff. weights when combining.
      if(eps.lt.emax)then
      cfr=cfac*rrup; cma=cfac*xmag; ceps=cfac*eps
      frbar(ift,ifn,0)=frbar(ift,ifn,0)+cfr
      fmbar(ift,ifn,0)=fmbar(ift,ifn,0)+cma
      febar(ift,ifn,0)=febar(ift,ifn,0)+ceps
      fhaz(ift,ifn,0)=fhaz(ift,ifn,0)+cfac
      ieps=max(1,min(int((eps+2.)*2.),10))
      ie=ieps
      rbar(ir,im,ieps,ifn,0)=rbar(ir,im,ieps,ifn,0)+cfr
      mbar(ir,im,ieps,ifn,0)=mbar(ir,im,ieps,ifn,0)+cma
      ebar(ir,im,ieps,ifn,0)=ebar(ir,im,ieps,ifn,0)+ceps
      haz(ir,im,ieps,ifn,0)=haz(ir,im,ieps,ifn,0)+cfac
          if(l_ms.and.ifn.eq.1)then
c Add epsilon*sigma
	meanspec=meanspec + eps*rho_jb*sigspec
          do jp=1,npnga
          meanspecs(ir,im,ie,jp,0)= meanspecs(ir,im,ie,jp,0)+ meanspec(jp)*cfac
          mean2spec(jp,0)= mean2spec(jp,0)+ meanspec(jp)*cfac
          enddo
c mean2spec(jp,0)=big average spectrum and its big average distance, M, e0 over all variables.
          mean2haz(0)=mean2haz(0)+cfac
          mean2r(0)=mean2r(0)+cfr
          mean2m(0)=mean2m(0)+cma
          mean2e0(0)=mean2e0(0)+ceps
          hazmsp(ir,im,ie,0)=hazmsp(ir,im,ie,0)+cfac
          epsmsp(ir,im,ie,0)=epsmsp(ir,im,ie,0)+ceps
c          wtmsp(ir,im,ie,0)=wtmsp(ir,im,ie,0)+wttmp

          rmsp(ir,im,ie,0)=rmsp(ir,im,ie,0)+cfr
          mmsp(ir,im,ie,0)=mmsp(ir,im,ie,0)+cma
          endif
      if(dea_attn)then
      frbar(ift,ifn,ia)=frbar(ift,ifn,ia)+cfr
      fmbar(ift,ifn,ia)=fmbar(ift,ifn,ia)+cma
      febar(ift,ifn,ia)=febar(ift,ifn,ia)+ceps
      fhaz(ift,ifn,ia) =fhaz(ift,ifn,ia)+cfac
      rbar(ir,im,ieps,ifn,ia)=rbar(ir,im,ieps,ifn,ia)+cfr
      mbar(ir,im,ieps,ifn,ia)=mbar(ir,im,ieps,ifn,ia)+cma
      ebar(ir,im,ieps,ifn,ia)=ebar(ir,im,ieps,ifn,ia)+ceps
      haz(ir,im,ieps,ifn,ia) =haz(ir,im,ieps,ifn,ia)+cfac
          if(l_ms.and.ifn.eq.1)then
          do jp=1,npnga
          meanspecs(ir,im,ie,jp,ia)= meanspecs(ir,im,ie,jp,ia)+ meanspec(jp)*cfac
          mean2spec(jp,ia)= mean2spec(jp,ia)+ meanspec(jp)*cfac
          enddo
c mean2spec(jp,ia)=big average spectrum and its big average distance, M, e0 for attn model ia.
          mean2haz(ia)=mean2haz(ia)+cfac
          mean2r(ia)=mean2r(ia)+cfr
          mean2m(ia)=mean2m(ia)+cma
          mean2e0(ia)=mean2e0(ia)+ceps
          hazmsp(ir,im,ie,ia)=hazmsp(ir,im,ie,ia)+cfac
          epsmsp(ir,im,ie,ia)=epsmsp(ir,im,ie,ia)+ceps
          rmsp(ir,im,ie,ia)=rmsp(ir,im,ie,ia)+cfr
          mmsp(ir,im,ie,ia)=mmsp(ir,im,ie,ia)+cma
          endif
      endif	!deagg indiv GMPEs
      if(eps.ge.2.)goto 2283
c Below keeps the books on epsilon distribution for e0<2.  e0>2 contrib is residual.
      ka=5
      temp=p(ipr)
      prx= temp-ptail(ka)
      dowhile(prx.gt.1.e-9)
      tp=wttmp*gmwt(ifn)*prx
      prob5(ir,im,ieps,ifn,0,ka)=prob5(ir,im,ieps,ifn,0,ka)+tp
      if(dea_attn)prob5(ir,im,ieps,ifn,ia,ka)=prob5(ir,im,ieps,ifn,ia,ka)+tp
c  gmwt is the branch weight of the ifn gm uncert. or geographic uncert for NMSZ
      ka=ka-1
      if(ka.eq.0)goto 2283
      prx= temp-ptail(ka)
      enddo
      endif      !eps <emax
      enddo	!ifn
2283      continue
2282    continue
2284    continue
2285    continue
      enddo      !imag loop, different GR distributions.
        go to 850
        endif
c---------------------------
c--- for characteristic event, modified to include multiple mags per fault
c---- characteristic with uncertainties
c To some extent diff M(RA) uncertainties take care of mag. variation. We seem to
c be repeating some mag uncertainty here.
      if((itype(ift).eq.1).and.(itest(ift).eq.0)) then
      do imag=1,nmagf(ift)      !new 6/06 consolidate mag variation for given fault
        xmag= cmag(ift,imag)
c        print *,ift,imag,xmag
c        if(ift.eq.3)print *,xmag,imag,' xmag imag char with uncert'
        xmo= 1.5*xmag +9.05
        xmo= 10.**xmo
c relative rate nov 2006. SH. But not for cluster model. May 2007.
      if(cluster)then
      rate= crate(ift,imag)	!weights will be treated differently, using wtscene(*,*)
      else
        rate= relwt(ift,imag) * crate(ift,imag)
        orate=rate
        endif
        if(rate.lt.tiny)goto 4203      !bypass irrelevant models aug 23 2007
        xmorate= xmo *rate
c cluster model new may 16 2007. Base cluster on mag and geographic branch for Char. For GR
c no cluster model has been specifically discussed
      if(cluster)then
      ks=imag
      kg=igroup(ift)
      else
      ks=1
      kg=1
      endif
        do 203 ilt=1,nbranch
        xmag= cmag(ift,imag) + dmbranch(ilt)
        xmo= 1.5*xmag+9.05
        xmo= 10.**xmo
        rate= xmorate/xmo
        totmo =0.
c        if(ift.eq.3)print *,rate,orate
        do 244 idis= -mwid, mwid
        xmag2= xmag + idis*dma
c        if(ift.eq.3)print *,xmag2,idis,' xmag idis alea.'
          if(xmag2.lt.mcut(1))then
          ime=1
          elseif(xmag2.lt.mcut(2))then
          ime=2
          else
          ime=3
          endif
        rjb = dmin(1)
        R_x = dmin(4)      !new signed distance 10/07
        rrup = dmin(3)      !type3 r_cd or rrup
          if(rjb.lt.dcut(1))then
          ide=1
          elseif(rjb.lt.dcut(2))then
          ide=2
          else
          ide=3
          endif
        wt1wt2=wtbranch(ilt)*ale2(idis+mwid+1)
       im = nint((xmag2-5.7)*10.)+1
       im=max(1,im)
       im=min(30,im)
       immax=max(immax,im)
        ip=1
        iq = iper
        do 204 ia=1,nattn
        iftype2= iftype(ift)
        if(rjb.gt.dmax)goto 204      !sail on out if too far.
      iatt=iatten(ia)
c       if(imag.eq.1.and.ia.eq.1.and.ilt.eq.1)write(6,*)rx,ry,R_x,rjb,ift,crate(ift,imag)
        weight= wt(ia,1)
        if(rjb.gt.wtdist(ia)) weight=wt(ia,2)
        if(rrup.le.110.)then
        ir=0.1*rrup + 1
        elseif(rrup.le.300.)then
        ir=12+(rrup-100.)/50.
        elseif(rrup.le.500.)then
        ir=16
        else
        ir=17
        endif 
c nga relations are collected into the first set of models to check
      if(nga(ia)) then
        if(iatt.eq.13) then
      call getBANGA0308(iperb,xmag2,rjb,vs30,gnd,sigmaf)
         elseif(iatt.eq.14) then
        call getCampNGA0308 (ipercb,xmag2,rrup,rjb,dtor,
     1 vs30,dbasin,gnd,sigmaf)
	elseif(iatt.eq.33)then
	indx1=indbssa
	mech = ibtype(ift)
	call bssa2013drv(indx_pga,indx1,xmag2,rjb,vs30,z1cal,mech,iregion,alny,sigmaf)
c skip the 2nd period for now assume the period of interest was tabulated.
	gnd(1)=alny
         if(l_gnd_ep)then
         gnd(2)= gnd(1)+gnd_ep(ide,ime)
         gnd(3)= gnd(1)-gnd_ep(ide,ime)
         endif
	elseif(iatt.eq.34)then
c	SJ=0.0	!Are we in Japan? 1 = yes.
c	Hhyp=min(12.,dtor+8.)	!Take a stab at hypocenter depth.
	Hhyp = dtor+0.5*sinedip*width(ift)
	call CB13_NGA_SPEC  (ipcb13, xmag2,Rrup,R_x,Rjb,F_RV, F_NM,dtor,Hhyp,Width(ift),dbasin,Vs30,
     +Dip0(ift),SJ,gnd,sigmaf)
c       print *,xmag2,rrup,exp(gnd(1)),sigmaf
	elseif(iatt.eq.38)then
      if(rx.lt.-120..and.ry.gt.39.)then
      Q=Q_CA
      elseif(ry.le.39.-0.8*(rx+120.))then
      Q=Q_CA      
      else
      Q=Q_BR
      endif
	call gksa13v2(ipgk12,ip,xmag2,rrup,gnd,sigmaf,vs30,iftype(ift),dgkbasin,Q)
      elseif(iatt.eq.15)then
c 10/2007 implementation of getCYNGA 
      call CY2007H(ipercy, xmag2, rrup, rjb, R_x, vs30,z1, dtor,
     1                 F_RV, F_NM,  gnd, sigmaf)
	elseif(iatt.eq.35)then
c from BChiou email use fmeasured=0. f_inferred is the model to use Aug 2013.
c dtor1 is top of floating rupture may be downdip
	F_Measured=0.
	F_Inferred=1.0	!could change these. Reference rock.
       call CY2013_NGA(icy13, xmag2, rrup, rjb, R_x, vs30,
     1                   F_Measured, F_Inferred, deltaZ1, dip0(ift), dtor,
     1                   F_RV, F_NM, cDPP(ift), gnd, tau, sigma_NL0, sigmaf)
c	print *,gnd(1),ift
        elseif (iatt.eq.16) then
	print *,'going into AS08 model why?'
c hanging-wall flag for as08 model added dec 7 2012.
      if(dip0(ift).eq.90.)then
      hwflag=0
      elseif(rjb.le.0.01.and.r_x.ge.0.)then
      hwflag=1
      else
      hwflag=0
      endif
c Although iflag makes a token appearance in SR code, it isn't used. So I dropped iflag (SH).
c the following call should include Rx rather than trying  to compute Rx.
       call AS_072007 ( ipera,xmag2, dip0(ift), F_NM,F_RV, Width(ift), rRup, rjb,R_x,
     1                     vs30, hwflag, gnd(1), sigma1, dtor,  vs30_class,
     3                     z1km )
        sigmaf = 1./sqrt2/sigma1
c	print *,sigma1,gnd(1),'AS08'
         if(l_gnd_ep)then
         gnd(2)= gnd(1)+gnd_ep(ide,ime)
         gnd(3)= gnd(1)-gnd_ep(ide,ime)
         endif
        elseif (iatt.eq.36) then
c     Compute SA1180 for AS2013. New Dec 7 2012. @W_rup is the rupture width (km). Downdip ruptures.
      SA_rock = 0.
c hanging-wall flag for as12 model added dec 7 2012.
      if(dip0(ift).eq.90.)then
      hwflag=0
      elseif(rjb.le.0.01.and.R_x.ge.0.)then
      hwflag=1
      else
      hwflag=0
      endif
      Ry0= -1.	!do not use this metric sept 2013
      call ASK13_v11_model ( ipas13,xmag2,dip0(ift), Width(ift), dtor, F_rv, F_NM, rRup, rjb, r_x, Ry0, 
     1                     vs30_rock, SA_rock, Z10_rock, z1_ref, hwflag, vs30_class,iReg,lnSa, phi, tau)
	if(l_ms)then
	do jp=1,npnga
	if(jp.ne.jms)then
	jper = imsp(ia,jp)
      call ASK13_v11_model ( jper,xmag2,dip0(ift), Width(ift), dtor, F_rv, F_NM, rRup, rjb, r_x, Ry0, 
     1                     vs30_rock, SA_rock, Z10_rock, z1_ref, hwflag, vs30_class,iReg,lnSa, phi, tau)
      psa_hr(jp) = exp(lnSa)
      endif	!jp .ne. jms
      enddo	!CMS periods
      endif	!want CMS?
      Sa1180 = exp(lnSa)
c 
c     Compute Sa at spectral period for given Vs30 March 2013 model.
      call ASK13_v11_model ( ipas13,xmag2, dip0(ift), Width(ift), dtor, F_rv, F_NM, rRup, rjb, r_x, Ry0, 
     1                     vs30, SA1180, z1km, z1_ref, hwflag, vs30_class,iReg,lnSa, phi, tau)
	gnd(1)=lnSa
         if(l_gnd_ep)then
         gnd(2)= gnd(1)+gnd_ep(ide,ime)
         gnd(3)= gnd(1)-gnd_ep(ide,ime)
         endif
        sigmaf = 1./sqrt( phi**2 + tau**2 )/sqrt2
	elseif(iatt.eq.37)then
	call  getIdriss2013(idriss,ip,xmag2,rrup,vs30,gnd,sigmaf)
      elseif(iatt.eq.17)then
      call getIdriss(ip,iper,xmag2,rjb,vs30,gnd,sigmaf)
      elseif(iatt.eq.18)then
c new nov 7,2006. Kanno
      call kanno(ip,iperk,gnd,sigmaf,xmag2,rrup,vsfac)
      endif
      elseif(wus02(ia))then
c WUS pre-nga (2002 atten models)
      if(iatt.eq.1)then
      call getSpu2000(ip,iq,xmag2,rjb,vs30,gnd,sigmaf)
      elseif(iatt.eq.3)then
      call getsadigh(ip,iq,xmag2,rrup,gnd,sigmaf)
      elseif(iatt.eq.8)then
      call getAS97(ip,iq,xmag2,rrup,hwsite,gnd,sigmaf)
       elseif(iatt.eq.9)then
       call getCamp2003(ip,iq,xmag2,rrup,rjb,gnd,sigmaf)
      elseif(iatt.eq.11)then
      call getBJF97(ip,iq,xmag2,rjb,vs30,gnd,sigmaf)
      elseif(iatt.eq.-3)then
        call SomerIMW(ip,isomer, xmag2,  rrup, rjb,vs30,gnd,sigmaf)
      endif
      elseif(ceus11(ia))Then
c new code for CEUS11 GMPEs added june 17 2013.
       rjbp=max(rjb,0.11)
       if(iatt.eq.25)then
      rkm=rjbp
      jf=ia08
             ka=1
             sigma = 0.3*2.303
       gnd(1) = amean11(xmag2,rkm,rjbp,vs30,jf,ka)
	if(l_ms)then
	sigspec=sigma	!same value all periods
	meanspec(jms)=gnd(1)
	do j=1,npnga-2	!5s max for the CEUS11 relations.
	if(lmsp(ia,j) .and. j.ne.jms)then
	jp=imsp(ia,j)
	meanspec(j)=amean11(xmag,rkm,rjbp,vs30,jp,ka)
	endif
	enddo
	endif
       if(lceus_sigma)sigma=ceus_sigma !for special study 3/2011
c     print *,gnd,rkm,ip,jf,ka
       sigmaf = 1./sqrt2/sigma
       elseif(iatt.eq.26)then
       rkm=rrup
       jf=ia06
       ka=2
             sigma = 0.3*2.303
       gnd(1) = amean11(xmag2,rkm,rjbp,vs30,jf,ka)
	if(l_ms)then
	sigspec=sigma	!same value all periods
	meanspec(jms)=gnd(1)
	do j=1,npnga-2	!5s max for the CEUS11 relations.
	if(lmsp(ia,j) .and. j.ne.jms)then
	jp=imsp(ia,j)
	meanspec(j)=amean11(xmag,rkm,rjbp,vs30,jp,ka)
	endif
	enddo
	endif
       if(lceus_sigma)sigma=ceus_sigma !for special study 3/2011
c     print *,gnd,rkm,ip,jf,ka
       sigmaf = 1./sqrt2/sigma
       elseif(iatt.eq.27)then
       rkm=rrup
       jf=ip11
c 2nd variable in sigPez11 is the frequency index according to the GailA set 2011.
      sigma = sigPez11(xmag,jf)	!new 10/30/2012. SH.
       ka=3
       gnd(1) = amean11(xmag2,rkm,rjbp,vs30,jf,ka)
	if(l_ms)then
	sigspec=sigma	!same value all periods
	meanspec(jms)=gnd(1)
	do j=1,npnga-2	!5s max for the CEUS11 relations.
	if(lmsp(ia,j) .and. j.ne.jms)then
	jp=imsp(ia,j)
	meanspec(j)=amean11(xmag,rkm,rjbp,vs30,jp,ka)
	endif
	enddo
	endif
       if(lceus_sigma)sigma=ceus_sigma !for special study 3/2011
c     print *,gnd,rkm,ip,jf,ka
       sigmaf = 1./sqrt2/sigma
c the rest of these are pre-2011 models
      	endif !iatt=25,26, or 27?
      elseif(ceus02(ia))then
c CEUS pre-nga (2002 atten models)
      if(iatt.eq.2)then
c        write(6,*)'iq clamp(iq) gnd rrup ip Toro ',iq,clamp(iq),gnd,rrup,ip
      call getToro(iptoro,1,xmag2,rjb,gnd,sigma,sigmaf)
      elseif(iatt.eq.-2)then
      call getToro(iptoro,2,xmag2,rjb,gnd,sigma,sigmaf)
        elseif(iatt.eq.4)then
        call getAB06(iperab,irab(ia),xmag2,rrup,gnd,sigma,sigmaf,vs30)
        elseif(iatt.eq.19)then
      call getTP05(ipertp,irtb,xmag2,rrup,gnd,sigma,sigmaf)
        elseif(iatt.eq.20)then
      call getSilva(isilva,irsilva,xmag2,rjb,gnd,sigma,sigmaf)
      elseif(iatt.eq.6)then
      call getFEA(ip,iq,1,xmag2,rrup,gnd,sigma,sigmaf)
      elseif(iatt.eq.-6)then      !FEA- HR
      call getFEA(ip,iq,3,xmag2,rrup,gnd,sigma,sigmaf)
      elseif(iatt.eq.5)then      !to distinguish ab95 from fea
c hard rock possibilities. These are  available for CEUS atten models as
c of July or August 2006.
      call getFEA(ip,iq,2,xmag2,rrup,gnd,sigma,sigmaf)
      elseif(iatt.eq.-5)then      !HR for atkinson-boore
      call getFEA(ip,iq,4,xmag2,rrup,gnd,sigma,sigmaf)
      elseif(iatt.eq.7) then
        call getSomer(iq,1,xmag2,rjb,gnd,sigma,sigmaf)
      elseif(iatt.eq.-7) then
        call getSomer(iq,2,xmag2,rjb,gnd,sigma,sigmaf)
             elseif(iatt.eq.10)then
        call getCampCEUS(ipcmpc,1,xmag2,rrup,gnd,sigma,sigmaf)
             elseif(iatt.eq.-10)then
        call getCampCEUS(ipcmpc,2,xmag2,rrup,gnd,sigma,sigmaf)
      endif
c This is a good place to apply the extra clamp constraint which
c in 2002 was used only for CEUS sources. The precomputed p() matrix does
c not work for this case because truncation is no longer at mu+3sig
      test0=gnd(1)+3.*sigma
      test= exp(test0)
      if(clamp(iq).lt.test .and. clamp(iq).gt.0.) then
      clamp2= alog(clamp(iq))
      sigmasq=1./sigma/sqrt2
      tempgt3= (gnd(1) - clamp2)*sigmasq
      probgt3= (erf(tempgt3)+1.)*0.5
      prr=1./(1.-probgt3)
c in the CEUS, only one epistemic branch on gnd. This could change.
c CEUS deagg works for unclustered source only.
      k=1
      ifn=1
      temp= (gnd(1) - xlev)*sigmasq
      temp1= (erf(temp)+1.)*0.5
      temp1= (temp1-probgt3)*prr
      if(temp1.lt.0.) goto 204      !no more calcs once p<0
      wttmp=wt1wt2*weight*rate
      if(cluster)then
            prx=wttmp*temp1
            eps=-sqrt2*temp
c Dont cluster char with uncert: not ready
            prob_s(jseg(ift),ks,kg)= prx
            r_s(jseg(ift),ks,kg)=rrup
            m_s(jseg(ift),ks,kg)= xmag2
            eps_s(jseg(ift),ks,kg)=eps    
cc            n_s  (jseg(ift),ks,kg)=n_s(jseg(ift),ks,kg)+1     
      else
        cfac=wttmp*temp1*gmwt(ifn)
        prob(ifn,kg)= prob(ifn,kg)+ cfac
c deagg not ready for clustered events oct 2007
c some of the standard arrays have been added but this is not enough. 
c for individual fault
               eps= -temp*sqrt2
       fbaz(ift,1)=fbaz(ift,1)+cfac*cos(azi_c)*1000.
        fbaz(ift,2)=fbaz(ift,2)+cfac*sin(azi_c)*1000.
c
c ieps is  an explicit dimension, recomm. by P. Bazzuro
c Some attn. models will say a given M,R is a low eps0 combination, others will say a higher eps0.
c 
      if(eps.lt.emax)then
	cfr=cfac*rrup; cma=cfac*xmag2; ceps=cfac*eps
      frbar(ift,ifn,0)=frbar(ift,ifn,0)+cfr
      fmbar(ift,ifn,0)=fmbar(ift,ifn,0)+cma
       febar(ift,ifn,0)=febar(ift,ifn,0)+ceps
       fhaz(ift,ifn,0)=fhaz(ift,ifn,0)+cfac
	      ieps=max(1,min(int((eps+2.)*2.),10))
	      ie=ieps
	      rbar(ir,im,ieps,ifn,0)=rbar(ir,im,ieps,ifn,0)+cfr
	      mbar(ir,im,ieps,ifn,0)=mbar(ir,im,ieps,ifn,0)+cma
	      ebar(ir,im,ieps,ifn,0)=ebar(ir,im,ieps,ifn,0)+ceps
	      haz(ir,im,ieps,ifn,0)=haz(ir,im,ieps,ifn,0)+cfac
          if(l_ms.and.ifn.eq.1)then
c Add epsilon*sigma
	meanspec=meanspec + eps*rho_jb*sigspec
          do jp=1,npnga
          meanspecs(ir,im,ie,jp,0)= meanspecs(ir,im,ie,jp,0)+ meanspec(jp)*cfac
           mean2spec(jp,0)= mean2spec(jp,0)+ meanspec(jp)*cfac
         enddo
c          if(ir.eq.12)print *,ir,rrup,cfac,eps,xmag2
c mean2spec(jp,0)=big average spectrum and its big average distance, M, e0 over all variables.
          mean2haz(0)=mean2haz(0)+cfac
          mean2r(0)=mean2r(0)+cfr
          mean2m(0)=mean2m(0)+cma
          mean2e0(0)=mean2e0(0)+ceps
          hazmsp(ir,im,ie,0)=hazmsp(ir,im,ie,0)+cfac
          epsmsp(ir,im,ie,0)=epsmsp(ir,im,ie,0)+ceps
c          wtmsp(ir,im,ie,0)=wtmsp(ir,im,ie,0)+wttmp

          rmsp(ir,im,ie,0)=rmsp(ir,im,ie,0)+cfr
          mmsp(ir,im,ie,0)=mmsp(ir,im,ie,0)+cma
          endif
      if(dea_attn)then
      frbar(ift,ifn,ia)=frbar(ift,ifn,ia)+cfr
      fmbar(ift,ifn,ia)=fmbar(ift,ifn,ia)+cma
      febar(ift,ifn,ia)=febar(ift,ifn,ia)+ceps
      fhaz(ift,ifn,ia) =fhaz(ift,ifn,ia)+cfac
      rbar(ir,im,ieps,ifn,ia)=rbar(ir,im,ieps,ifn,ia)+cfr
      mbar(ir,im,ieps,ifn,ia)=mbar(ir,im,ieps,ifn,ia)+cma
      ebar(ir,im,ieps,ifn,ia)=ebar(ir,im,ieps,ifn,ia)+ceps
      haz(ir,im,ieps,ifn,ia) =haz(ir,im,ieps,ifn,ia)+cfac
          if(l_ms.and.ifn.eq.1)then
          do jp=1,npnga
          meanspecs(ir,im,ie,jp,ia)= meanspecs(ir,im,ie,jp,ia)+ meanspec(jp)*cfac
          mean2spec(jp,ia)= mean2spec(jp,ia)+ meanspec(jp)*cfac
          enddo
c mean2spec(jp,ia)=big average spectrum and its big average distance, M, e0 for attn model ia.
          mean2haz(ia)=mean2haz(ia)+cfac
          mean2r(ia)=mean2r(ia)+cfr
          mean2m(ia)=mean2m(ia)+cma
          mean2e0(ia)=mean2e0(ia)+ceps
          hazmsp(ir,im,ie,ia)=hazmsp(ir,im,ie,ia)+cfac
          epsmsp(ir,im,ie,ia)=epsmsp(ir,im,ie,ia)+ceps
          rmsp(ir,im,ie,ia)=rmsp(ir,im,ie,ia)+cfr
          mmsp(ir,im,ie,ia)=mmsp(ir,im,ie,ia)+cma
          endif
      endif	!deagg indiv GMPEs
	      if(eps.ge.2.)goto 204
c Below keeps the books on epsilon distribution for e0<2. Then, e0>2 residual.
 	     ka=5
	      prx= temp1-ptail(ka)
	      dowhile(prx.gt.1.e-9)
	      tp=wttmp*gmwt(ifn)*prx
	      prob5(ir,im,ieps,ifn,0,ka)=prob5(ir,im,ieps,ifn,0,ka)+tp
	      if(dea_attn)prob5(ir,im,ieps,ifn,ia,ka)=prob5(ir,im,ieps,ifn,ia,ka)+tp
c  
	      ka=ka-1
	      if(ka.eq.0)goto 204
	      prx= temp1-ptail(ka)
	      enddo	!dowhile prx...
        endif      !eps <emax
      endif 	!cluster/no cluster?
         goto 204
      endif	!clipping in effect for ceus atten models 
      elseif(iatt.eq.12)then
      call getMota(ip,iper,xmag2,rrup,vs30,gnd,sigmaf)
      endif
c back to non-CEUS calcs...
      wttmp=wt1wt2*weight*rate
        do ifn = 1,nfi      !can have 3 gm levs one per epistemic branch
        k=1
       pr=(gnd(ifn) - xlev)*sigmaf
c       if (ifn.eq.1)print *,pr,ia,cluster,wttmp
       if(pr.gt.3.3)then
       ipr=250002
       elseif(pr.gt.plim)then
       ipr= 1+nint(dp2*(pr-plim))      !3sigma cutoff n'(mu,sig)
       else
       goto 206      !transfer out if ground motion above mu+3sigma
       endif
c       print *,ipr
      if(cluster)then
c deagg not ready for clustered events oct 2007
             prx=wttmp*temp1
            prob_s(jseg(ift),ks,kg)=prx
            r_s(jseg(ift),ks,kg)=rrup
            m_s(jseg(ift),ks,kg)=xmag2 
            eps_s(jseg(ift),ks,kg)= eps           
cc            n_s  (jseg(ift),ks,kg)=n_s(jseg(ift),ks,kg)+1     
       else
       cfac= wttmp*p(ipr)*gmwt(ifn)
        prob(ifn,kg)= prob(ifn,kg)+ cfac
c some of the standard arrays have been added but this is not enough. 
c for individual fault
        eps= -pr*sqrt2
      if(ifn.eq.1)then
        fbaz(ift,1)=fbaz(ift,1)+cfac*cos(azi_c)*1000.
        fbaz(ift,2)=fbaz(ift,2)+cfac*sin(azi_c)*1000.
      endif
c
c ieps is  an explicit dimension, recomm. by P. Bazzuro
c Some attn. models will say a given M,R is a low eps0 combination, others will say a higher eps0.
c 
      if(eps.lt.emax)then
	cfr=cfac*rrup; cma=cfac*xmag2; ceps=cfac*eps
         frbar(ift,ifn,0)=frbar(ift,ifn,0)+cfr
         fmbar(ift,ifn,0)=fmbar(ift,ifn,0)+cma
          febar(ift,ifn,0)=febar(ift,ifn,0)+ceps
          fhaz(ift,ifn,0)=fhaz(ift,ifn,0)+cfac
	      ieps=max(1,min(int((eps+2.)*2.),10))
	      ie=ieps
	      rbar(ir,im,ieps,ifn,0)=rbar(ir,im,ieps,ifn,0)+cfr
	      mbar(ir,im,ieps,ifn,0)=mbar(ir,im,ieps,ifn,0)+cma
	      ebar(ir,im,ieps,ifn,0)=ebar(ir,im,ieps,ifn,0)+ceps
	      haz(ir,im,ieps,ifn,0)=haz(ir,im,ieps,ifn,0)+cfac
          if(l_ms.and.ifn.eq.1)then
c Add epsilon*sigma. To do: add rho*eps*sigspec.
	meanspec=meanspec + eps*rho_jb*sigspec
          do jp=1,npnga
	if(iatt.eq.15.and.(xmag.lt.6.6.or.xmag.gt.7.7))then
c	if(jp.eq.1)print 246,xmag2,cfac
246	format(/,'#xmag ',f6.2,1x,' CY ',e11.5)
c	print *,ms_p(jp),meanspec(jp),sigspec(jp),eps*rho_jb(jp)
	endif
          meanspecs(ir,im,ieps,jp,0)= meanspecs(ir,im,ieps,jp,0)+ meanspec(jp)*cfac
          mean2spec(jp,0)= mean2spec(jp,0)+ meanspec(jp)*cfac
          enddo
c mean2spec(jp,0)=big average spectrum and its big average distance, M, e0 over all variables.
          mean2haz(0)=mean2haz(0)+cfac
          mean2r(0)=mean2r(0)+cfr
          mean2m(0)=mean2m(0)+cma
          mean2e0(0)=mean2e0(0)+ceps
          hazmsp(ir,im,ie,0)=hazmsp(ir,im,ie,0)+cfac
          epsmsp(ir,im,ie,0)=epsmsp(ir,im,ie,0)+ceps
          rmsp(ir,im,ie,0)=rmsp(ir,im,ie,0)+cfr
          mmsp(ir,im,ie,0)=mmsp(ir,im,ie,0)+cma
        endif
      if(dea_attn)then
      frbar(ift,ifn,ia)=frbar(ift,ifn,ia)+cfr
      fmbar(ift,ifn,ia)=fmbar(ift,ifn,ia)+cma
      febar(ift,ifn,ia)=febar(ift,ifn,ia)+ceps
      fhaz(ift,ifn,ia) =fhaz(ift,ifn,ia)+cfac
      rbar(ir,im,ieps,ifn,ia)=rbar(ir,im,ieps,ifn,ia)+cfr
      mbar(ir,im,ieps,ifn,ia)=mbar(ir,im,ieps,ifn,ia)+cma
      ebar(ir,im,ieps,ifn,ia)=ebar(ir,im,ieps,ifn,ia)+ceps
      haz(ir,im,ieps,ifn,ia) =haz(ir,im,ieps,ifn,ia)+cfac
          if(l_ms.and.ifn.eq.1)then
          do jp=1,npnga
          meanspecs(ir,im,ie,jp,ia)= meanspecs(ir,im,ie,jp,ia)+ meanspec(jp)*cfac
          mean2spec(jp,ia)= mean2spec(jp,ia)+ meanspec(jp)*cfac
          enddo
c mean2spec(jp,ia)=big average spectrum and its big average distance, M, e0 for attn model ia.
          mean2haz(ia)=mean2haz(ia)+cfac
          mean2r(ia)=mean2r(ia)+cfr
          mean2m(ia)=mean2m(ia)+cma
          mean2e0(ia)=mean2e0(ia)+ceps
          hazmsp(ir,im,ie,ia)=hazmsp(ir,im,ie,ia)+cfac
          epsmsp(ir,im,ie,ia)=epsmsp(ir,im,ie,ia)+ceps
           rmsp(ir,im,ie,ia)=rmsp(ir,im,ie,ia)+cfr
          mmsp(ir,im,ie,ia)=mmsp(ir,im,ie,ia)+cma
         endif
      endif	!deagg indiv GMPEs
	      if(eps.ge.2.)goto 206
c Below keeps the books on epsilon distribution for e0<2. Then, e0>2 residual.
 	     ka=5
	      temp=p(ipr)
	      prx= temp-ptail(ka)
	      dowhile(prx.gt.1.e-9)
	      tp=wttmp*gmwt(ifn)*prx
	      prob5(ir,im,ieps,ifn,0,ka)=prob5(ir,im,ieps,ifn,0,ka)+tp
	      if(dea_attn)prob5(ir,im,ieps,ifn,ia,ka)=prob5(ir,im,ieps,ifn,ia,ka)+tp
c  
	      ka=ka-1
	      if(ka.eq.0)goto 206
	      prx= temp-ptail(ka)
	      enddo	!dowhile prx...
        endif      !eps <emax
       endif	!if cluster (?)
206      continue
      enddo       !ifn files
 
ccccccccc
 204    continue
 244    continue
c        write(6,*) "totmo, xmorate",ift,ilt,totmo, xmorate
c        read(5,*) idum
 203    continue
4203      continue
      enddo      !imag index
        endif
ccccccccccccccccc
cc-- characteristic without uncertainties. remove cluster for the most part 1/02/2014
      if((itype(ift).eq.1).and.(itest(ift).eq.1)) then
      do imag=1,nmagf(ift)      !new 6/06 consolidate mag variation for given fault
        xmag= cmag(ift,imag)
        xmag0=xmag
c cluster model new may 16 2007. Base cluster on mag and geographic branch for Char. 
c Characteristic w/o uncert is the only valid eq source cluster model
      if(cluster)then
       ks=imag
       kg=igroup(ift)
       rate= 1.	!weights will be treated differently, using wtscene(*,*)
       else
c relative rate nov 2006. SH. But not for cluster model. May 2007.
        rate= relwt(ift,imag) * crate(ift,imag)
      ks=1
      kg=1
      endif
      if(rate.lt.tiny)goto 3303
      im=nint((xmag-5.749)*10.) +1
      im=max(im,1)
      im=min(im,33)
         immax=max(immax,im)
        rjb = dmin(1)
        iftype2= iftype(ift)
      if(l_gnd_ep)then
          if(xmag.lt.mcut(1))then
          ime=1
          elseif(xmag.lt.mcut(2))then
          ime=2
          else
          ime=3
          endif
          if(rjb.lt.dcut(1))then
          ide=1
          elseif(rjb.lt.dcut(2))then
          ide=2
          else
          ide=3
          endif
          endif       !(gnd_ep calcs to be performed)
c      if(slist)write(30+i,399)rjb,xmag,rate,ift,depth0(ift),imag
        ip=1
      R_x = dmin(4)	!new signed distance, 10/2007
      prx_t=0.0	!acumulate prob of exc from clustered events.
        do 3203 ia=1,nattn
        rrup= dmin(3)
        if(rjb.gt.dmax)goto 3203
c       if(imag.eq.1.and.ia.eq.1.and.ip.eq.1)write(6,*)rx,ry,R_x,rjb,ift,crate(ift,imag)
        if(rrup.le.110.)then
        ir=0.1*rrup + 1
        elseif(rrup.le.300.)then
        ir=12+(rrup-100.)/50.
        elseif(rrup.le.500.)then
        ir=16
        else
        ir=17
        endif 
        iq=iper
        iatt=iatten(ia)
        weight= wt(ia,1)
        if(rjb.gt.wtdist(ia)) weight=wt(ia,2)
c nga relations are collected into the first set of models to check
      if(nga(ia)) then
        if(iatt.eq.13) then
      call getBANGA0308(iperb,xmag,rjb,vs30,gnd,sigmaf)
         elseif(iatt.eq.14) then
        call getCampNGA0308 (ipercb,xmag,rrup,rjb,dtor,
     1 vs30,dbasin,gnd,sigmaf)
	elseif(iatt.eq.33)then
	indx1=indbssa
	mech = ibtype(ift)
	call bssa2013drv(indx_pga,indx1,xmag,rjb,vs30,z1cal,mech,iregion,alny,sigmaf)
c skip the 2nd period for now assume the period of interest was tabulated.
	gnd(1)=alny
         if(l_gnd_ep)then
         gnd(2)= gnd(1)+gnd_ep(ide,ime)
         gnd(3)= gnd(1)-gnd_ep(ide,ime)
         endif
	elseif(iatt.eq.34)then
c	SJ=0.0	!Are we in Japan? 1 = yes.
c	Hhyp=min(12.,dtor+8.)	!Take a stab at hypocenter depth.
	Hhyp = dtor+0.5*sinedip*width(ift)
	call CB13_NGA_SPEC  (ipcb13, xmag,Rrup,R_x,Rjb,F_RV, F_NM,dtor,Hhyp,Width(ift),dbasin,Vs30,
     +Dip0(ift),SJ,gnd,sigmaf)
       elseif(iatt.eq.37)then
       call getIdriss2013(idriss,ip,xmag,rrup,vs30,gnd,sigmaf)
c       print *,'idriss ',xmag,rrup,exp(gnd),sigmaf
	elseif(iatt.eq.38)then
      if(rx.lt.-120..and.ry.gt.39.)then
      Q=Q_CA
      elseif(ry.le.39.-0.8*(rx+120.))then
      Q=Q_CA      
      else
      Q=Q_BR
      endif
	call gksa13v2(ipgk12,ip,xmag,rrup,gnd,sigmaf,vs30,iftype(ift),dgkbasin,Q)
      elseif(iatt.eq.15)then
c 10/2007 implementation of getCYNGA 
      call CY2007H(ipercy, xmag, rrup, rjb, R_x, vs30,z1, dtor,
     1                 F_RV, F_NM,  gnd, sigmaf)
      elseif(iatt.eq.35)then
c from BChiou email use fmeasured=0.
      F_Measured=0.
      F_Inferred=1.0	!could change these. Reference rock.
       call CY2013_NGA(icy13, xmag, rrup, rjb, R_x, vs30,
     1                   F_Measured, F_Inferred, deltaZ1, dip0(ift), dtor,
     1                   F_RV, F_NM, cDPP(ift), gnd, tau, sigma_NL0, sigmaf)
c	print *,exp(gnd),sigmaf,xmag,'CY2013'

c      print *,gnd(1),ift
        elseif (iatt.eq.16) then
c hanging-wall flag for as08 model added dec 7 2012.
	print *,'going into AS08 model why?'
      if(dip0(ift).eq.90.)then
      hwflag=0
      elseif(rjb.le.0.01.and.r_x.ge.0.)then
      hwflag=1
      else
      hwflag=0
      endif
c Although iflag makes a token appearance in SR code, it isn't used. So I dropped iflag (SH).
       call AS_072007 ( ipera,xmag, dip0(ift), F_NM,F_RV, Width(ift), rRup, rjb,R_x,
     1                     vs30, hwflag, gnd(1), sigma1, dtor,  vs30_class,
     3                     z1km )
        sigmaf = 1./sqrt2/sigma1
c	print *,sigma1,gnd(1),'AS08'
         if(l_gnd_ep)then
         gnd(2)= gnd(1)+gnd_ep(ide,ime)
         gnd(3)= gnd(1)-gnd_ep(ide,ime)
         endif

        elseif (iatt.eq.36) then
c     Compute SA1180 for AS2013. New Dec 7 2012. @W_rup is the rupture width (km). Downdip ruptures.
      SA_rock = 0.
c hanging-wall flag for as12 model added dec 7 2012.
      if(dip0(ift).eq.90.)then
      hwflag=0
      elseif(rjb.le.0.01.and.R_x.ge.0.)then
      hwflag=1
      else
      hwflag=0
      endif
      Ry0= -1.	!do not use this metric sept 2013
      call ASK13_v11_model ( ipas13,xmag,dip0(ift), Width(ift), dtor, F_rv, F_NM, rRup, rjb, r_x, Ry0, 
     1                     vs30_rock, SA_rock, Z10_rock, z1_ref, hwflag, vs30_class,iReg,lnSa, phi, tau)
      Sa1180 = exp(lnSa)
	if(l_ms)then
	do jp=1,npnga
	if(jp.ne.jms)then
	jper = imsp(ia,jp)
      call ASK13_v11_model ( jper,xmag,dip0(ift), Width(ift), dtor, F_rv, F_NM, rRup, rjb, r_x, Ry0, 
     1                     vs30_rock, SA_rock, Z10_rock, z1_ref, hwflag, vs30_class,iReg,lnSa, phi, tau)
      psa_hr(jp) = exp(lnSa)
      endif	!jp .ne. jms
      enddo	!CMS periods
      endif	!want CMS?
c	print *,rx,ry,xmag,rRup,r_x,Sa1180,period(ip),' AS12 '
c 
c     Compute Sa at spectral period for given Vs30
      call ASK13_v11_model ( ipas13,xmag, dip0(ift), Width(ift), dtor, F_rv, F_NM, rRup, rjb, r_x, Ry0, 
     1                     vs30, SA1180, z1km, z1_ref, hwflag, vs30_class,iReg,lnSa, phi, tau)
	gnd(1)=lnSa
         if(l_gnd_ep)then
         gnd(2)= gnd(1)+gnd_ep(ide,ime)
         gnd(3)= gnd(1)-gnd_ep(ide,ime)
         endif
        sigmaf = 1./sqrt( phi**2 + tau**2 )/sqrt2
      elseif(iatt.eq.17)then
      call getIdriss(ip,iper,xmag,rjb,vs30,gnd,sigmaf)
      elseif(iatt.eq.18)then
c new nov 7,2006. Kanno
      call kanno(ip,iperk,gnd,sigmaf,xmag,rrup,vsfac)
      endif
      elseif(wus02(ia))then
c WUS pre-nga (2002 atten models)
      if(iatt.eq.1)then
      call getSpu2000(ip,iq,xmag,rjb,vs30,gnd,sigmaf)
      elseif(iatt.eq.3)then
      call getsadigh(ip,iq,xmag,rrup,gnd,sigmaf)
      elseif(iatt.eq.8)then
      call getAS97(ip,iq,xmag,rrup,hwsite,gnd,sigmaf)
       elseif(iatt.eq.9)then
       call getCamp2003(ip,iq,xmag,rrup,rjb,gnd,sigmaf)
      elseif(iatt.eq.11)then
      call getBJF97(ip,iq,xmag,rjb,vs30,gnd,sigmaf)
      elseif(iatt.eq.-3)then
        call SomerIMW(ip,isomer, xmag,  rrup, rjb,vs30,gnd,sigmaf)
      endif
      elseif(ceus11(ia))Then
c new code for CEUS11 GMPEs added june 17 2013.
       rjbp=max(rjb,0.11)
       if(iatt.eq.25)then
      rkm=rjbp
      jf=ia08
             ka=1
             sigma = 0.3*2.303
       gnd(1) = amean11(xmag,rkm,rjbp,vs30,jf,ka)
	if(l_ms)then
	sigspec=sigma	!same value all periods
	meanspec(jms)=gnd(1)
	do j=1,npnga-2	!5s max for the CEUS11 relations.
	if(lmsp(ia,j) .and. j.ne.jms)then
	jp=imsp(ia,j)
	meanspec(j)=amean11(xmag,rkm,rjbp,vs30,jp,ka)
	endif
	enddo
	endif
       if(lceus_sigma)sigma=ceus_sigma !for special study 3/2011
c     print *,gnd,rkm,ip,jf,ka
       sigmaf = 1./sqrt2/sigma
       elseif(iatt.eq.26)then
       rkm=rrup
       jf=ia06
       ka=2
             sigma = 0.3*2.303
       gnd(1) = amean11(xmag,rkm,rjbp,vs30,jf,ka)
	if(l_ms)then
	sigspec=sigma	!same value all periods
	meanspec(jms)=gnd(1)
	do j=1,npnga-2	!5s max for the CEUS11 relations.
	if(lmsp(ia,j) .and. j.ne.jms)then
	jp=imsp(ia,j)
	meanspec(j)=amean11(xmag,rkm,rjbp,vs30,jp,ka)
	endif
	enddo
	endif
       if(lceus_sigma)sigma=ceus_sigma !for special study 3/2011
c     print *,gnd,rkm,ip,jf,ka
       sigmaf = 1./sqrt2/sigma
       elseif(iatt.eq.27)then
       rkm=rrup
       jf=ip11
c 2nd variable in sigPez11 is the frequency index according to the GailA set 2011.
      sigma = sigPez11(xmag,jf)	!new 10/30/2012. SH.
       ka=3
       gnd(1) = amean11(xmag,rkm,rjbp,vs30,jf,ka)
	if(l_ms)then
	sigspec=sigma	!same value all periods
	meanspec(jms)=gnd(1)
	do j=1,npnga-2	!5s max for the CEUS11 relations.
	if(lmsp(ia,j) .and. j.ne.jms)then
	jp=imsp(ia,j)
	meanspec(j)=amean11(xmag,rkm,rjbp,vs30,jp,ka)
	endif
	enddo
	endif
       if(lceus_sigma)sigma=ceus_sigma !for special study 3/2011
c     print *,gnd,rkm,ip,jf,ka
       sigmaf = 1./sqrt2/sigma
c the rest of these are pre-2011 models
      	endif !iatt=25,26, or 27?
      elseif(ceus02(ia))then
      ifn=1
c CEUS pre-nga (2002 atten models)
c
      if(iatt.eq.2)then
      call getToro(iptoro,1,xmag,rjb,gnd,sigma,sigmaf)
      elseif(iatt.eq.-2)then
      call getToro(iptoro,2,xmag,rjb,gnd,sigma,sigmaf )
        elseif(iatt.eq.4)then
        call getAB06(iperab,irab(ia),xmag,rrup,gnd,sigma,sigmaf,vs30)
        elseif(iatt.eq.19)then
      call getTP05(ipertp,irtb,xmag,rrup,gnd,sigma,sigmaf)
c        write(6,*)'iq clamp(iq) gnd rrup ip TP ',iq,clamp(iq),gnd,rrup,ip
        elseif(iatt.eq.20)then
      call getSilva(isilva,irsilva,xmag,rjb,gnd,sigma,sigmaf)
      elseif(iatt.eq.5)then      !to distinguish ab95 from fea
      call getFEA(ip,iq,2,xmag,rrup,gnd,sigma,sigmaf)
      elseif(iatt.eq.-5)then      !HR for atkinson-boore
      call getFEA(ip,iq,4,xmag,rrup,gnd,sigma,sigmaf)
      elseif(iatt.eq.6)then
      call getFEA(ip,iq,1,xmag,rrup,gnd,sigma,sigmaf)
      elseif(iatt.eq.-6)then      !hr
      call getFEA(ip,iq,3,xmag,rrup,gnd,sigma,sigmaf)
      elseif(iatt.eq.7) then
        call getSomer(iq,1,xmag,rjb,gnd,sigma,sigmaf)
      elseif(iatt.eq.-7) then
        call getSomer(iq,2,xmag,rjb,gnd,sigma,sigmaf)
      elseif(iatt.eq.10)then
        call getCampCEUS(ipcmpc,1,xmag,rrup,gnd,sigma,sigmaf)
      elseif(iatt.eq.-10)then
        call getCampCEUS(ipcmpc,2,xmag,rrup,gnd,sigma,sigmaf)
      endif
c This is a good place to apply the extra clamp constraint which
c in 2002 was used only for CEUS sources. The precomputed p() matrix does
c not work for this case because truncation is no longer at mu+3sig
      test0=gnd(1)+3.*sigma
      test= exp(test0)
c      print *,test,iq,clamp(iq)
c clamp is relying on the iq index. Some CEUS models now have different set than the 7 std
      if(clamp(iq).lt.test .and. clamp(iq).gt.0.) then
      clamp2= alog(clamp(iq))
      sigmasq=1./sigma/sqrt2
      tempgt3= (gnd(1) - clamp2)*sigmasq
      probgt3= (erf(tempgt3)+1.)*0.5
      k=1
      ifn=1
      temp= (gnd(1) - xlev)*sigmasq
      temp1= (erf(temp)+1.)*0.5
      temp1= (temp1-probgt3)/(1.-probgt3)
      if(temp1.lt.0.) goto 3203      !no more calcs once p<0
      if(cluster)then
            prx=weight*temp1
c            eps = -temp*sqrt2
            prob_s(jseg(ift),ks,kg)=prob_s(jseg(ift),ks,kg)+prx
            endif	!accumulate in prob_s. Will be used later.
c            r_s(jseg(ift),ks,kg)= r_s(jseg(ift),ks,kg)+rrup*prx
c            m_s(jseg(ift),ks,kg)= m_s(jseg(ift),ks,kg)+xmag*prx
c            eps_s(jseg(ift),ks,kg)= eps_s(jseg(ift),ks,kg)+eps*prx 
c            print *,prx,rrup,xmag,eps,jseg(ift),ks,kg,' clamped below 3sig'       
cc            n_s  (jseg(ift),ks,kg)=n_s(jseg(ift),ks,kg)+1     
c      else
      wttmp=weight*rate
      cfac=wttmp*temp1
        prob(1,kg)= prob(1,kg)+ cfac
c for individual fault
        eps= -temp*sqrt2
        fbaz(ift,1)=fbaz(ift,1)+cfac*cos(azi_c)*1000.
        fbaz(ift,2)=fbaz(ift,2)+cfac*sin(azi_c)*1000.
c ifn index is not present: 2nd to last frontier. ieps is  an explicit dimension, recomm. by Bazzuro
c Some attn. models may claim a given M,R is a low eps0 combination, others will say a higher eps0.
c 
      if(eps.lt.emax)then
	cfr=cfac*rrup; cma=cfac*xmag; ceps=cfac*eps
      frbar(ift,ifn,0)=frbar(ift,ifn,0)+cfr
      fmbar(ift,ifn,0)=fmbar(ift,ifn,0)+cma
      febar(ift,ifn,0)=febar(ift,ifn,0)+ceps
      fhaz(ift,ifn,0)=fhaz(ift,ifn,0)+cfac
      ieps=max(1,min(int((eps+2.)*2.),10))
      ie=ieps
      rbar(ir,im,ieps,ifn,0)=rbar(ir,im,ieps,ifn,0)+cfr
      mbar(ir,im,ieps,ifn,0)=mbar(ir,im,ieps,ifn,0)+cma
      ebar(ir,im,ieps,ifn,0)=ebar(ir,im,ieps,ifn,0)+ceps
      haz(ir,im,ieps,ifn,0)=haz(ir,im,ieps,ifn,0)+cfac
          if(l_ms.and.ifn.eq.1)then
c Add epsilon*sigma
	meanspec=meanspec + eps*rho_jb*sigspec
          do jp=1,npnga
           meanspecs(ir,im,ie,jp,0)= meanspecs(ir,im,ie,jp,0) + meanspec(jp)*cfac
          mean2spec(jp,0)= mean2spec(jp,0)+ meanspec(jp)*cfac
          enddo
c mean2spec(jp,0)=big average spectrum and its big average distance, M, e0 over all variables.
          mean2haz(0)=mean2haz(0)+cfac
          mean2r(0)=mean2r(0)+cfr
          mean2m(0)=mean2m(0)+cma
          mean2e0(0)=mean2e0(0)+ceps
          hazmsp(ir,im,ie,0)=hazmsp(ir,im,ie,0)+cfac
          epsmsp(ir,im,ie,0)=epsmsp(ir,im,ie,0)+ceps
          rmsp(ir,im,ie,0)=rmsp(ir,im,ie,0)+cfr
          mmsp(ir,im,ie,0)=mmsp(ir,im,ie,0)+cma
          endif
      if(dea_attn)then
      frbar(ift,ifn,ia)=frbar(ift,ifn,ia)+cfr
      fmbar(ift,ifn,ia)=fmbar(ift,ifn,ia)+cma
      febar(ift,ifn,ia)=febar(ift,ifn,ia)+ceps
      fhaz(ift,ifn,ia) =fhaz(ift,ifn,ia)+cfac
      rbar(ir,im,ieps,ifn,ia)=rbar(ir,im,ieps,ifn,ia)+cfr
      mbar(ir,im,ieps,ifn,ia)=mbar(ir,im,ieps,ifn,ia)+cma
      ebar(ir,im,ieps,ifn,ia)=ebar(ir,im,ieps,ifn,ia)+ceps
      haz(ir,im,ieps,ifn,ia) =haz(ir,im,ieps,ifn,ia)+cfac
          if(l_ms.and.ifn.eq.1)then
          do jp=1,npnga
          meanspecs(ir,im,ie,jp,ia)= meanspecs(ir,im,ie,jp,ia)+ meanspec(jp)*cfac
          mean2spec(jp,ia)= mean2spec(jp,ia)+ meanspec(jp)*cfac
          enddo
c mean2spec(jp,ia)=big average spectrum and its big average distance, M, e0 for attn model ia.
          mean2haz(ia)=mean2haz(ia)+cfac
          mean2r(ia)=mean2r(ia)+cfr
          mean2m(ia)=mean2m(ia)+cma
          mean2e0(ia)=mean2e0(ia)+ceps
          hazmsp(ir,im,ie,ia)=hazmsp(ir,im,ie,ia)+cfac
          epsmsp(ir,im,ie,ia)=epsmsp(ir,im,ie,ia)+ceps
          rmsp(ir,im,ie,ia)=rmsp(ir,im,ie,ia)+cfr
          mmsp(ir,im,ie,ia)=mmsp(ir,im,ie,ia)+cma
          endif
      endif	!deagg indiv GMPEs
      if(eps.ge.2.)goto 3203
c Below keeps the books on epsilon distribution for e0<2. Resid for e0>2 .
      wttmp=weight*rate
      ka=5
      prx= temp1-ptail(ka)
      dowhile(prx.gt.1.e-9)
      tp=wttmp*gmwt(ifn)*prx
      prob5(ir,im,ieps,ifn,0,ka)=prob5(ir,im,ieps,ifn,0,ka)+tp
      if(dea_attn)prob5(ir,im,ieps,ifn,ia,ka)=prob5(ir,im,ieps,ifn,ia,ka)+tp
c  
      ka=ka-1
      if(ka.eq.0)goto 3203
      prx= temp1 -ptail(ka)
      enddo
      endif      !eps <emax
c      endif      !if cluster
        goto 3203
      endif !if clamping is in effect
      elseif(iatt.eq.12)then
      call getMota(ip,iper,xmag,rrup,vs30,gnd,sigmaf)
      endif
      wttmp=weight*rate
        do ifn=1,nfi
        k=1
       pr=(gnd(ifn) - xlev)*sigmaf
       if(pr.gt.3.3)then
       ipr=250002
       elseif(pr.gt.plim)then
       ipr= 1+nint(dp2*(pr-plim))      !3sigma cutoff n'(mu,sig)
       else
       goto 3201      !transfer out if ground motion above mu+3sigma
       endif
      if(cluster)then
            prx=weight*p(ipr)
c                eps= -pr*sqrt2
           prob_s(jseg(ift),ks,kg)=prob_s(jseg(ift),ks,kg)+prx
           endif
c            r_s(jseg(ift),ks,kg)= r_s(jseg(ift),ks,kg)+rrup*prx
c            m_s(jseg(ift),ks,kg)= m_s(jseg(ift),ks,kg)+xmag*prx
c            eps_s(jseg(ift),ks,kg)= eps_s(jseg(ift),ks,kg)+eps*prx 
c            print *,prx,rrup,xmag,eps,jseg(ift),ks,kg,' not clamped'         
cc            n_s  (jseg(ift),ks,kg)=n_s(jseg(ift),ks,kg)+1     
c      else
c apply gmuncert weight here. aug 4 2008
      cfac = wttmp*p(ipr)*gmwt(ifn)
        prob(ifn,kg)= prob(ifn,kg)+ cfac
c for individual fault
               eps= -pr*sqrt2
      if(ifn.eq.1)then
        fbaz(ift,1)=fbaz(ift,1)+cfac*cos(azi_c)*1000.
        fbaz(ift,2)=fbaz(ift,2)+cfac*sin(azi_c)*1000.
      endif
c ifn index is present: 2nd to last frontier. ieps is  an explicit dimension, recomm. by Bazzuro
c Some attn. models may claim a given M,R is a low eps0 combination, others will say a higher eps0.
c 
      if(eps.lt.emax)then
	cfr=cfac*rrup; cma=cfac*xmag; ceps=cfac*eps
      frbar(ift,ifn,0)=frbar(ift,ifn,0)+cfr
      fmbar(ift,ifn,0)=fmbar(ift,ifn,0)+cma
      febar(ift,ifn,0)=febar(ift,ifn,0)+ceps
      fhaz(ift,ifn,0)=fhaz(ift,ifn,0)+cfac
      ieps=max(1,min(int((eps+2.)*2.),10))
      ie=ieps
      rbar(ir,im,ieps,ifn,0)=rbar(ir,im,ieps,ifn,0)+cfr
      mbar(ir,im,ieps,ifn,0)=mbar(ir,im,ieps,ifn,0)+cma
      ebar(ir,im,ieps,ifn,0)=ebar(ir,im,ieps,ifn,0)+ceps
      haz(ir,im,ieps,ifn,0)=haz(ir,im,ieps,ifn,0)+cfac
          if(l_ms.and.ifn.eq.1)then
c Add epsilon*sigma
	meanspec=meanspec + eps*rho_jb*sigspec
          do jp=1,npnga
          meanspecs(ir,im,ie,jp,0)= meanspecs(ir,im,ie,jp,0)+ meanspec(jp)*cfac
          mean2spec(jp,0)= mean2spec(jp,0)+ meanspec(jp)*cfac
c	if(iatt.eq.15.and.xmag.gt.7.8)then
c	if(jp.eq.1)print 246,xmag2,cfac
c	print *,ms_p(jp),meanspec(jp),sigspec(jp),eps*rho_jb(jp)
c	endif
	
          enddo
c mean2spec(jp,0)=big average spectrum and its big average distance, M, e0 over all variables.
          mean2haz(0)=mean2haz(0)+cfac
          mean2r(0)=mean2r(0)+cfr
          mean2m(0)=mean2m(0)+cma
          mean2e0(0)=mean2e0(0)+ceps
          hazmsp(ir,im,ie,0)=hazmsp(ir,im,ie,0)+cfac
          epsmsp(ir,im,ie,0)=epsmsp(ir,im,ie,0)+ceps
c          wtmsp(ir,im,ie,0)=wtmsp(ir,im,ie,0)+wttmp

          rmsp(ir,im,ie,0)=rmsp(ir,im,ie,0)+cfac*rrup
          mmsp(ir,im,ie,0)=mmsp(ir,im,ie,0)+cma
          endif
      if(dea_attn)then
      frbar(ift,ifn,ia)=frbar(ift,ifn,ia)+cfr
      fmbar(ift,ifn,ia)=fmbar(ift,ifn,ia)+cma
      febar(ift,ifn,ia)=febar(ift,ifn,ia)+ceps
      fhaz(ift,ifn,ia) =fhaz(ift,ifn,ia)+cfac
      rbar(ir,im,ieps,ifn,ia)=rbar(ir,im,ieps,ifn,ia)+cfr
      mbar(ir,im,ieps,ifn,ia)=mbar(ir,im,ieps,ifn,ia)+cma
      ebar(ir,im,ieps,ifn,ia)=ebar(ir,im,ieps,ifn,ia)+ceps
      haz(ir,im,ieps,ifn,ia) =haz(ir,im,ieps,ifn,ia)+cfac
          if(l_ms.and.ifn.eq.1)then
          do jp=1,npnga
          meanspecs(ir,im,ie,jp,ia)= meanspecs(ir,im,ie,jp,ia)+ meanspec(jp)*cfac
          mean2spec(jp,ia)= mean2spec(jp,ia)+ meanspec(jp)*cfac
          enddo
          hazmsp(ir,im,ie,ia)=hazmsp(ir,im,ie,ia)+cfac
c mean2spec(jp,ia)=big average spectrum and its big average distance, M, e0 for attn model ia.
          mean2haz(ia)=mean2haz(ia)+cfac
          mean2r(ia)=mean2r(ia)+cfr
          mean2m(ia)=mean2m(ia)+cma
          mean2e0(ia)=mean2e0(ia)+ceps
           epsmsp(ir,im,ie,ia)=epsmsp(ir,im,ie,ia)+ceps
          rmsp(ir,im,ie,ia)=rmsp(ir,im,ie,ia)+cfr
          mmsp(ir,im,ie,ia)=mmsp(ir,im,ie,ia)+cma
         endif
      endif	!deagg indiv GMPEs
      if(eps.ge.2.)goto 3201
c Below keeps the books on epsilon distribution for e0<2. if e0>2 dont bother.
      ka=5
      temp=p(ipr)
      prx= temp-ptail(ka)
      dowhile(prx.gt.1.e-9)
      tp=wttmp*gmwt(ifn)*prx
      prob5(ir,im,ieps,ifn,0,ka)=prob5(ir,im,ieps,ifn,0,ka)+tp
      if(dea_attn)prob5(ir,im,ieps,ifn,ia,ka)=prob5(ir,im,ieps,ifn,ia,ka)+tp
c  
      ka=ka-1
      if(ka.eq.0)goto 3201
      prx= temp-ptail(ka)
      enddo
      endif      !eps <emax
c        endif      !if cluster
3201      continue
      enddo      !files
c if clustered events we next convert segment rates 
c  to mean rates in prob() array
c 
 3203   continue	!ia index
3303      continue	!if char event rate is tiny skip above calcs and go here
      enddo      !imag set
        endif
ccccccccccccccccccc
 850  continue
       if(cluster)then
	print *,prob_s(1,1:3,1),' 1 g1'
	print *,prob_s(1,1:3,2),' 1 g2'
	print *,prob_s(1,1:3,3),' 1 g3'
	print *,prob_s(2,1:3,1),' 2 g1'
	print *,prob_s(2,1:3,2),' 2 g2'
	print *,prob_s(2,1:3,3),' 2 g3'
	print *,prob_s(3,1:3,1),' 3 g1'
	print *,prob_s(3,1:3,2),' 3 g2'
	print *,prob_s(3,1:3,3),' 3 g3'
	
       call cluster_me(prob_c,wtscene,nscene,ngroup,jsegmin,jsegmax)
	pr_cl=0.0
      do j=1,ngroup
            pr_cl=pr_cl+prob_c(j)*rate_cl	!*gweight(j)
            print *,prob_c(j),gweight(j)
            enddo	!j=..ngroup
      print *,' probability of exc  from cluster_me: ',pr_cl
      print *,' prob_c: ',(prob_c(j),j=1,ngroup)
        endif
c  All faults have been dealt with; 
 860    continue
67      format(/,'#Station ',f7.4,1x,f10.4,1x,a,' vs30 ',f6.1)       

69      format('#',f9.2,1x,i2,1x,a12)
  100 continue
c      dum=dtime(tarray)
       ip=1
c      if(cluster)then
c      fac=rate_cl
c      do js=1,3
c      do ks=1,8
cc      do kg=1,5
cc            ns=      n_s  (js,ks,kg) 
cc            if(ns.gt.0)print *,js,ks,kg,ns,m_s(js,ks,kg),r_s(js,ks,kg)
cc            enddo
cc            enddo
cc            enddo	!js   

c      do ifn=1,ngroup
c geographic or dip-uncert branch weights in gweight. central branch has 70% weight. Gweight is
c internally applied in deagg whereas differnt gfiles were written for the main hazard calcs
c and gweight was applied during the summation (combine... files)
c      prx=prob(1,ifn)*fac*gweight(ifn)
c backazimuth for clustered events. choose one?
c      if(prx.gt.tiny)write(41,27)
c     + rbarc(ifn),mbarc(ifn),ebarc(ifn),prx,baz_tbd,g_name(ifn)
c also write to unit 21 when act is together
c      enddo	!ifn index
c      else	!no cluster below
	if(cluster)then
	tmp=0.0
       do ieps=1,10
       do im=1,immax
       do ir=1,17
       tmp=tmp+haz(ir,im,ieps,1,0)
       enddo
       enddo
       enddo
	print *,'Cluster rescaling. pr_cl and haz =',pr_cl,tmp
       if(tmp.gt.0.)tmp=pr_cl/tmp
	haz=haz*tmp
	ebar=ebar*tmp
	mbar=mbar*tmp
	rbar=rbar*tmp
	prob5=prob5*tmp
	endif
       do ifn=1,nfi
       do ieps=1,10
       ie=ieps
       noshow=ifn.eq.1
       do im=1,immax
       do ir=1,17
      prx=haz(ir,im,ieps,ifn,0)
       if(prx.gt.tiny)then
       e0=max(-9.99,ebar(ir,im,ieps,ifn,0)/prx)
c Need to keep track of important faults. May need another array to write out
c ifn below lets downstream programs know which gm uncert branch this item came from       
       write(21,25)rbar(ir,im,ieps,ifn,0)/prx,
     + mbar(ir,im,ieps,ifn,0)/prx,prx,(prob5(ir,im,ieps,ifn,0,k),k=5,1,-1),
     + ifn,e0,0
       
       if(dea_attn)then
              do ia=1,nattn
		prx=haz(ir,im,ieps,ifn,ia)
      		 if(prx.gt.tiny)then
       		e0=max(-9.99,ebar(ir,im,ieps,ifn,ia)/prx)
  	        write(21,25)rbar(ir,im,ieps,ifn,ia)/prx,
     + 		mbar(ir,im,ieps,ifn,ia)/prx,prx,(prob5(ir,im,ieps,ifn,ia,k),k=5,1,-1),
     + 		ifn,e0,m_att(ia)
      		 endif	!inner prx.gt.tiny
       		enddo	!attenuation model loop
       		endif	!if dea_attn
      endif	!first prx.gt.tiny
25      format(f9.3,1x,f7.3,6(1x,e11.5),
     + 1x,i2,1x,f5.2,1x,i2)
       if(l_ms .and. noshow)then
c write  mean spectrum for each binned src. 
c The ifn=1 is the only branch where the mean spectrum is being  computed (initially = Dec10-Jan2011).
	prx=hazmsp(ir,im,ie,0)
       if(prx.gt.tiny)then
       eps00=epsmsp(ir,im,ie,0)/prx
       prxx=prx/gmwt(1)	!concentrate all wt from gmuncert into ifn.eq.1 branch
       rcd=rmsp(ir,im,ie,0)/prx
       xm=mmsp(ir,im,ie,0)/prx
c	write(31,255)rcd,xm,prxx,eps00,att_typ(0)
255      format(/,'#T(s)  Mean_SA(g) for Rcdbar(km), Mbar, haz, eps0, GMPE: ',f6.1,1x,f5.2,1x,e11.5,
     + 1x,f6.2,1x,a)
c im+6 is a shift to put M=5.7 to 5.79 into slot 7 during the combine step.
      write(33)0,ir,im+6,ie,rcd,xm,prxx, eps00
c the mean spectra are weighed by  ann rate of exceed.
      do jp=1,kmsp(0)
      st(jp)=meanspecs(ir,im,ie,jp,0)
      ltmp(jp)=lmsp(0,jp)
c      write(31,257)ms_p(jp),exp(st(jp)/prx)
257	format(f7.3,1x,1pe11.4)
       enddo
      write(33)kmsp(0),st,ltmp		!temp storage used to output CMS
       if(dea_attn)then
       do ia=1,nattn
	prx=hazmsp(ir,im,ie,ia)
       if(prx.gt.tiny)then
       eps00=epsmsp(ir,im,ie,ia)/prx
       prxx=prx/gmwt(1)
       rcd=rmsp(ir,im,ie,ia)/prx
       xm=mmsp(ir,im,ie,ia)/prx
c	write(31,255)rcd,xm,prxx,eps00,att_typ(iatten(ia))
c m_att(ia) is a global mapping of attenuation models 21 is BA-NGA(1), 22 is CB-NGA,etc
      write(33)m_att(ia),ir,im+6,ie,rcd,xm,prxx,eps00
      do jp=1,kmsp(ia)
      ltmp(jp)=lmsp(ia,jp)
      st(jp)=meanspecs(ir,im,ie,jp,ia)
c      write(31,257)ms_p(jp),exp(st(jp)/prx)
       enddo
      write(33)kmsp(ia),st,ltmp		!temp storage used to output CMS
       endif	!latest prx>tiny
       enddo	!attn models
       endif	!deaggregate the individ attn models dea_attn?
       endif	!2nd latest prx>tiny
       endif	!l_ms
       enddo	!ir 
       enddo	!im 
       enddo	!ieps
       enddo	!ifn (typically NGA gm median uncertainty)
c write some mean deagg info for each fault with more than tiny contribution
       do iflt=1,nft
       prx=0.0
       faebar=0.0
       fambar=0.0
       farbar=0.0	!fault rbar
       do ifn=1,nfi
       prx=prx+fhaz(iflt,ifn,0)
       faebar=faebar+febar(iflt,ifn,0)
       farbar=farbar+frbar(iflt,ifn,0)
       fambar=fambar+fmbar(iflt,ifn,0)
       enddo	!ifn
c fbazbar is the avg station-to-source angle, measured + clockwise from N, for fault with
c index iflt. This angle is only computed for the primary gm branch, ifn=1, initially.
c GR branches have different iflt index than char. branches for the same fault.
       fbazbar=atan2(fbaz(iflt,2),fbaz(iflt,1))/d2r
c	print *,fbazbar,fbaz(iflt,2),fbaz(iflt,1),iflt
       if(prx.gt.tiny)then
       write(41,27)farbar/prx,fambar/prx,faebar/prx,prx,fbazbar,aft(iflt),0
c unit 61 is temp input to geog_deagg assimilator for 2010.
	if(geog)then
       write(61,47)iflt,prx,farbar/prx,fambar/prx,fbazbar,aft(iflt)
       endif
47	format(i3,1x,e11.5,1x,f7.3,1x,f5.2,1x,f7.2,1x,a)
c only check on individual atten components if the mean hzard exceeds tiny.
       if(dea_attn)then
       do ia=1,nattn
       prx=0.0
       faebar=0.0
       fambar=0.0
       farbar=0.0	!fault rbar. 
       do ifn=1,nfi
       prx=prx+fhaz(iflt,ifn,ia)
       faebar=faebar+febar(iflt,ifn,ia)
       farbar=farbar+frbar(iflt,ifn,ia)
       fambar=fambar+fmbar(iflt,ifn,ia)
       enddo	!ifn
       if(prx.gt.tiny)
     +   write(41,27)farbar/prx,fambar/prx,faebar/prx,prx,fbazbar,aft(iflt),m_att(ia)
       enddo	!attenuation models
       endif	!if deagg of individual GMPES was requested.
       endif	!outer prx .gt. tiny
27      format(1x,f9.3,1x,f7.3,1x,f5.2,1x,e11.5,1x,f8.2,1x,a32,1x,i2)
	enddo	!iflt
c	endif	!cluster or not? No longer.
       close(21)
       if(l_ms)then
c       close(31)		!mean spectrum file. new oct 2010.
	close(33)
c the below writes to unit 32 correspond to detail that is no longer saved at 2011 deagg web site
c 	print *,'Mean conditional spectrum for binned sources in *.SPCTRA'
c 	print *,'Mean conditional spectrum for mean of all sources in *.MEANSPC'
c	prx=mean2haz(0)
cc       if(prx.gt.tiny)then
c       eps00=mean2e0(0)/prx
c       rcd=mean2r(0)/prx
c       xm=mean2m(0)/prx
c	write(32,255)rcd,xm,prx,eps00,att_typ(0)
c the mean spectra are weighed by prob. of exceed.
c      do jp=1,npnga
c      if (mean2spec(jp,0) .ne. 0.)write(32,257)ms_p(jp),exp(mean2spec(jp,0)/prx)
c       enddo
c       if(dea_attn)then
c       do ia=1,nattn
c	prx=mean2haz(ia)
c       if(prx.gt.tiny)then
c       eps00=mean2e0(ia)/prx
c       rcd=mean2r(ia)/prx
c       xm=mean2m(ia)/prx
c	write(32,255)rcd,xm,prx,eps00,att_typ(iatten(ia))
c      do jp=1,npnga
c      if(mean2spec(jp,ia).ne.0.)write(32,257)ms_p(jp),exp(mean2spec(jp,ia)/prx)
c       enddo
c       endif	!latest prx>tiny
c       enddo	!attn models
c       endif	!deaggregate the individ attn models dea_attn?
cc       endif	!2nd latest prx>tiny
c       close(32)
	endif	! l_ms deagg data

       close(41)
       stop 'normal exit deaggFLTH.2013'
202   print *,name,' not found'
       stop 'put in W.D.'
2014	print *,'GR/BSSAcoef.dat not found. coef file for BSSA model needed'
	stop 'put in the folder indicated'
      end
c
      subroutine delaz(sorlat,sorlon,stnlat,stnlon,delta,az,baz)
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
      az= az/coef
      x= st1*ct0-st0*ct1*cdlon
      y= -sdlon*st0
      baz= atan2(y,x)
      baz= baz/coef
      delta= delta*111.2
      return
      end         

      subroutine back(delta0,az,sorlat,sorlon,stnlat,stnlon)
      parameter (coef= 3.1415926/180.)
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

cccccccccccccccccccccccccccccc
      subroutine getSpu2000(ip,iq,xmag,dist0,vs30,gndout,sigmaf)
c commandeered by Spudich ea. from BJF93 of "hazFXv3" etc.
c To distinguish from BJF97. 7 periods.
c Inputs:
c iq is the index of the current period, see perx(iq)
c dist0 is Rjb
c xmag = M or moment magnitude
c vs30 = site Vs top 30 m
c Outputs gnd = ln(median motion,g)
c        sigmaf = 1/sigma/sqrt2  where sigma is dispersion natural log
c
c adapted to Fortran 95 july 26 2006.SH
      parameter (sqrt2=1.414213562, pi=3.141592654,np=7,aln10=2.30258509)
      parameter (vref=760.)
c spudich coeffs...BSSA Oct 1999
      real magmin,perx(8),gndout(3)
      common/epistemic/l_gnd_ep,gnd_ep,ide,ime
      real gnd_ep(3,3)
      logical l_gnd_ep	!scalar apr 2011

c spudich coeffs...
c site amp: for now use that of BJF97. THis should be reviewed July26 2006.
      real bv(np),va(np)
        real b1(np),b2(np),b3(np),b4(np),b5(np),h(np),sigma(np)
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
         sig=sigma(iq)*aln10
          sigmaf = 1./(sig*sqrt2)
c site amp from BJF97. THis will need review. Placeholder july 27 2006.
      period=perx(iq)
       dist= sqrt(dist0*dist0+h(iq)**2)
          gnd=  b1(iq) +b2(iq)*(xmag-6.) +b3(iq)*(xmag-6.)**2
          gnd= gnd + b5(iq)*alog10(dist)      !+ b4(iq)*dist nuisance is 0
c--- convert from psv in cm/sec to psa in g
          if(period.ne.0.) gnd=gnd+alog10(2.*pi/(980.*period))
c bse 10 to base e
c site amp is last term because it is a natural log term. 
c Not too useful when soil siteamp has known nonlinear response.
          gnd= gnd *aln10 +bv(iq)*alog(vs30/vref)
       gndout(1)=gnd
         if(l_gnd_ep)then
         gndout(2)= gnd+gnd_ep(ide,ime)
         gndout(3)= gnd-gnd_ep(ide,ime)
         endif
      return
      end subroutine getSpu2000

cccccccccccccccc
      subroutine getToro(ip,ir,xmag0,dist0,gndout,sigma,sigmaf)
c midcontinent w/moment mag. Adapted to NGA code SH June 2006. 7 periods used in2002.
c ip = index in perx() array, 
c ir=1 use BC rock; ir=2 use hardrock model.
c Hard-rock in tc1h, otherwise same regression model & coeffs.
c dist0 is rjb (km). Eqn 4 SRL converts to "R_M".
c median motions are capped. Max motions are not really constrained here.
c Warning: Clamp business will have to be done in main.
c replaced data statements with array constructors oct 2006.
        parameter (sqrt2=1.414213562,np=10)
c the gnd_ep branching will not be done for CEUS relations. 
      common/epistemic/l_gnd_ep,gnd_ep,ide,ime
      common/ms/ia,jms,npnga,l_ms,lmsp,imsp,meanspec,sigspec
      logical l_ms,lmsp(0:10,21)
      integer imsp(8,21)
      real, dimension (21) :: meanspec,sigspec	!fill this if l_ms = .true.
      real gnd_ep(3,3),gndout(3)
      logical l_gnd_ep	!scalar apr 2011

             real, dimension(np):: tc1,tc2,tc3,tc4,tc5,tc6
      real, dimension(np):: perx,tc1h,th,tsigma 
c add 0.03 s for CMS june 2011. SH.	
c array constructors. add 0.04 and 0.4 s coeffs july 16 2008. From NRC files
       perx = (/0.,0.2,1.0,0.1,0.3,0.5,2.0,0.03,0.04,0.4/)
c Below tc coeffs correspond to midcontinent, equations using moment mag.
c tc Mw coeffs for BC rock. 3hz BC-A is 0.5423 (BC/A siteamp is then 1.72)
	tc1 = (/2.619,2.295,0.383,2.92,1.8823,1.2887,-0.558,4.32,4.,1.4/)
c tc Mw coeffs. 3.33 hz is log-log from the 2.5 and 5 hz values. 
        tc1h = (/2.20,1.73,0.09,2.37,1.34,0.8313,-0.740,4.0,3.68,1.07/)
c example tc1h(10hz) = 2.37, as in Toro et al., Table 2 midcontinent Moment Magnitude coeffs.
	tc2 = (/0.81,0.84,1.42,0.81,0.964,1.14,1.86,0.79,0.80,1.05/)
	tc3 = (/0.,0.0,-0.2,0.,-0.059,-0.1244,-0.31,0.,0.0,-0.10/)
	tc4 = (/1.27,0.98,0.90,1.1,0.951,0.9227,0.92,1.57,1.46,0.93/)
	tc5 = (/1.16,0.66,0.49,1.02,0.601,0.5429,0.46,1.83,1.77,0.56/)
	tc6 = (/0.0021,0.0042,0.0023,0.004,0.00367,0.00306,0.0017,0.0008,0.0013,0.0033/)
     	th = (/9.3,7.5,6.8,8.3,7.26,7.027,6.9,11.1,10.5,7.1/)
c
     	tsigma = (/0.7506,0.7506,0.799,.7506,.7506,.7506,0.799,.7506,.7506,.7506/)	
        xmag= xmag0
        xmagfac=(xmag-6.)**2
c correct mag will be used in calling program. never need to convert here.
          sigma= tsigma(ip)
          sigmaf= 1./sigma/sqrt2
        cor = exp(-1.25 + 0.227*xmag)
c        dist= sqrt(dist0*dist0+th(ip)*th(ip))
c Modified Toro for finite-fault Oliver. Nov 2006.
          dist= sqrt(dist0*dist0+th(ip)*th(ip)*cor*cor)
      if(ir.eq.1)then
c firm rock const coeff.
          gnd= tc1(ip)
          else
c hard rock. Could have other possibilities as well. For now default to h.r.
          gnd=tc1h(ip)
          endif
          gnd=gnd+tc2(ip)*(xmag-6.)+ tc3(ip)*xmagfac
          gnd= gnd-tc4(ip)*alog(dist)-tc6(ip)*dist
          factor= alog(dist/100.)
          if(factor.gt.0.) gnd= gnd-(tc5(ip)-tc4(ip))*factor
c---following is for clipping gnd motions: 1.5g PGA, 3.0g for rest 
          if(ip.eq.1) then
c  the PGA 1.5g median limit (g). SH June 2006.
           gnd=min(gnd,0.405)
          elseif(perx(ip).lt.0.5)then
c 3.3, 5, 10 hz median limited to 3 g
           gnd=min(1.099,gnd)
          endif
       gndout(1)=gnd
         if(l_gnd_ep)then
         gndout(2)= gnd+gnd_ep(ide,ime)
         gndout(3)= gnd-gnd_ep(ide,ime)
         endif
	if(.not.l_ms)return
c Play it again, Gabe, for the conditional mean spectrum
	do k=1,16
	j=imsp(ia,k)
        if ( k .eq. jms) then
        sigspec(k)=tsigma(j)
c use the available information. May have to add epsilon0*sigma_t.
        meanspec(k)=gndout(1)
	elseif( lmsp(ia,k) )then
        sigspec(k)=tsigma(j)
      if(ir.eq.1)then
c firm rock const coeff.
          gnd= tc1(j)
          else
c hard rock. Could have other possibilities as well. For now default to h.r.
          gnd=tc1h(j)
          endif
          gnd=gnd+tc2(j)*(xmag-6.)+ tc3(j)*xmagfac
          gnd= gnd-tc4(j)*alog(dist)-tc6(j)*dist
          if(factor.gt.0.) gnd= gnd-(tc5(j)-tc4(j))*factor
c---following is for clipping gnd motions: 1.5g PGA, 3.0g for rest 
          if(j.eq.1) then
c  the PGA 1.5g median limit (g). SH June 2006.
           gnd=min(gnd,0.405)
          elseif(perx(j).lt.0.5)then
c 3.3, 5, 10 hz median limited to 3 g
           gnd=min(1.099,gnd)
          endif
          meanspec(k)=gnd
          endif	!k = k_ms or not
          enddo	!multiple periods for Toro (added a few june 2011)
      return
      end subroutine getToro

cccccccccccccccccc
      subroutine getsadigh(ip,iq,xmag,rrup,gndout,sigmaf)
c modified to perform like nga functions. SH June 2 2006 workin progress...
c iq is the index of perx() associated with period being run with index ip in main
c we are not using sigmanf or distnf at this time in deaggFLTH.2013  
        parameter (sqrt2=1.414213562)
c Rock-site coefs only, written below for 7 periods. How fast is that rock?
c Walt Silva says SM sites avg about 500 m/s (NGA discussion hot topic). 
c This code does
c not vary the median response with rock Vs30. You get one. That is it.
c replaced data statements with array constructors oct 2006.
      common/epistemic/l_gnd_ep,gnd_ep,ide,ime
      real gnd_ep(3,3),gndout(3)
      logical l_gnd_ep	!scalar apr 2011

      real sc1(7),sc2(7),sc3(7),sc4(7),sc5(7),sc6(7),perx(7)
      real sd1(7),sd2(7),sd3(7),sd4(7),sd5(7),sd6(7),sd7(7)      
      real ssigma1(7),ssigma2(7),ssigmacoef(7),smagsig(7)
        common/mech/ss,rev,normal,obl
c        common/dipinf/dipang,cdipsq
        logical ss,rev,normal,obl
c prepared for 7 periods jun 22 2006. gnd is modified
c for sense-of-slip  from common/mech/ 
      real sh(7)/7*5./
      real sthrust(7)/7*.1823/
c sc1 and sd1 are from the SRL table and might correspond to 600 m/s? rock
      sc1 = (/-0.624,.153,-1.705,0.2750,-0.057,-0.5880,-2.945/)
      sc2 = (/1.0,1.,1.,1.,1.,1.,1./)
      sc3 = (/0.0,-0.004,-0.055,0.006,-0.017,-0.04,-0.07/)
      sc4 = (/-2.1,-2.08,-1.8,-2.148,-2.028,-1.945,-1.67/)
      sc5 = (/1.29649,1.29649,1.29649,1.29649,1.29649,1.29649,1.29649/)
      sc6 = (/0.25,.25,.25,.25,.25,.25,.25/)
      perx = (/0.0,0.2,1.0,0.1,0.3,0.5,2.0/)
      sd1 = (/-1.274,-.497,-2.355,-0.375,-0.707,-1.238,-3.595/)
      sd2 = (/1.1,1.1,1.1,1.1,1.1,1.1,1.1/)
      sd3 = (/0.,-.004,-0.055,0.006,-0.071,-0.040,-0.07/)
      sd4 = (/-2.1,-2.08,-1.8,-2.148,-2.028,-1.945,-1.67/)
      sd5 = (/-.48451,-.48451, -.48451,-.48451,-.48451, -.48451,-.48451/)
      sd6 = (/.524,.524,.524,.524,0.524,.524,.524/)
      sd7 = (/0.,0.,0.,-0.041,0.,0.,0./)
      ssigma1 = (/1.39,1.43,1.53,1.41,1.45,1.5,1.53/)
      ssigmacoef = (/0.14,0.14,0.14,0.14,0.14,0.14,0.14/)
      ssigma2 = (/0.38,0.42,0.52,0.4,0.44,0.49,0.52/)
      smagsig = (/7.21,7.21,7.21,7.21,7.21,7.21,7.21/)
        xmag0=xmag
c        if(icode(ia).eq.1) xmag= 2.715 -0.277*xmag0+0.127*xmag0*xmag0
          if(xmag.lt.smagsig(iq))then
           sig= ssigma1(iq)- ssigmacoef(iq)*xmag
          else
           sig= ssigma2(iq)
           endif
          sigmaf= 1./(sig*sqrt2)
          dist= sqrt(rrup*rrup + sh(iq)**2)
          if(xmag.lt.6.5) then
      gnd= sc1(iq)+sc2(iq)*xmag+sc3(iq)*((8.5-xmag)**2.5)
      gnd= gnd+ sc4(iq)*alog(dist+ exp(sc5(iq)+sc6(iq)*xmag))
           else
      gnd= sd1(iq)+sd2(iq)*xmag+sd3(iq)*((8.5-xmag)**2.5)
      gnd= gnd+ sd4(iq)*alog(dist+ exp(sd5(iq)+sd6(iq)*xmag))
      if(rev)gnd=gnd + sthrust(iq)
            endif
          if(sd7(iq).ne.0.)gnd= gnd+sd7(iq)*alog(rrup+2.)
       gndout(1)=gnd
         if(l_gnd_ep)then
         gndout(2)= gnd+gnd_ep(ide,ime)
         gndout(3)= gnd-gnd_ep(ide,ime)
         endif
      return
      end subroutine getsadigh

c getCamp removed: no longer used. Replace with getCamp2003
c getAB95 removed. Seems to be too archaic.

      subroutine getFEAtab(ip,iq)
c  hardrock and   BC rock tables can be read in here.
c 
c replaced data statements with array constructors oct 2006.
c June 2011: can read all 7 periods in if computing CMS (i.e., if l_ms = .true.).
      parameter (np=7)
      real gma(20,21,28),tabdist(21,4)
      logical isok
      common/gmat/gma,tabdist
      common/ms/ia,jms,npnga,l_ms,lmsp,imsp,meanspec,sigspec
      logical l_ms,lmsp(0:10,21)
      integer imsp(8,21)
      real, dimension (21) :: meanspec,sigspec	!fill this if l_ms = .true.
      character*30 nametab(np),nameab(np),hardtab(np),hardab(np)
      character*4 adum
c assumes these files are in working directory or GR/ sub-directory.
      nametab=(/'pgak01l.tbl ','t0p2k01l.tbl','t1p0k01l.tbl',
     1 't0p1k01l.tbl','t0p3k01l.tbl','t0p5k01l.tbl','t2p0k01l.tbl'/)
      nameab=(/'Abbc_pga.tbl','Abbc0p20.tbl','Abbc1p00.tbl',
     1 'Abbc0p10.tbl','Abbc0p30.tbl','Abbc0p50.tbl','Abbc2p00.tbl'/)
       hardtab=(/'pgak006.tbl ','t0p2k006.tbl','t1p0k006.tbl',
     1 't0p1k006.tbl','t0p3k006.tbl','t0p5k006.tbl','t2p0k006.tbl'/)
      hardab=(/'ABHR_PGA.TBL','ABHR0P20.TBL','ABHR1P00.TBL',
     1'ABHR0P10.TBL','ABHR0P30.TBL','ABHR0P50.TBL','ABHR2P00.TBL'/)
	if(l_ms)then
	ip1=1;ip2=np
	else
	ip1=ip;ip2=ip
	endif
c	print *,'FEAtab, ip1,ip2,l_ms ', ip1,ip2,l_ms
      do i=ip1,ip2
      if(iq.eq.1)then            !fea BCtable
      nametab(i)='GR/'//nametab(i)
      inquire(file=nametab(i),exist=isok)
      if(.not.isok)goto 20
         open(unit=15,file=nametab(i),status='old')
         ipq=i
c         print *,i,ipq,nametab(i)
         elseif(iq.eq.2)then      !ab BC table
      nameab(i)='GR/'//nameab(i)
      inquire(file=nameab(i),exist=isok)
      if(.not.isok)goto 21
         open(unit=15,file=nameab(i),status='old')
         ipq=i+np
         elseif(iq.eq.3)then      !fea A table
      hardtab(i)='GR/'//hardtab(i)
      inquire(file=hardtab(i),exist=isok)
      if(.not.isok)goto 23
         open(unit=15,file=hardtab(i),status='old')
         ipq=i+np+np
c         print *,i,ipq,hardtab(i)
         elseif(iq.eq.4)then      !ab A table
      hardab(i)='GR/'//hardab(i)
      inquire(file=hardab(i),exist=isok)
      if(.not.isok)goto 24
         open(unit=15,file=hardab(i),status='old')
         ipq=i+np*3
         endif
         read(15,900) adum
900      format(a)
         do 80 idist=1,21
   80    read(15,*) tabdist(idist,iq),(gma(imag,idist,ipq),imag=1,20)
         close(15)
c         print *,ipq,gma(1,1,ipq),gma(16,1,ipq),gma(20,21,ipq)
         enddo	!1 or 7 table filling operations. added june 3 2011.
      return
20      write(6,*)'getFEAtab open failed for ',nametab(i)
      stop 'deaggFLTH.2013  : put in working dir or rewrite program'
21      write(6,*)'getFEAtab  open failed for ',nameab(i)
      stop 'deaggFLTH.2013  : put in working dir or rewrite program'
23      write(6,*)'getFEAtab  open failed for ',hardtab(i)
      stop 'deaggFLTH.2013  : put in working dir or rewrite program'
24      write(6,*)'getFEAtab  open failed for ',hardab(i)
      stop 'deaggFLTH.2013  : put in working dir or rewrite program'
      end subroutine getFEAtab

ccccccccccccccccccccccc
      subroutine getFEA(iper,ip,iq,xmag,dist0,gndout,sigma,sigmaf)
c table info is available, from common/gmat/. See getFEAtab.
c this routine should work for finite CEUS faults. What if 0 depth suchas meers?
c four tables are set up and good to go as of july 28 2006.
c if iq = 1 use feaBC. if  iq=2, use ab95 BC table. 
c if iq = 3 fea A rock, and iq=4, ab95 A rock table.
c primary outputs:
c gnd=log median motion
c sigma = logarthmic s.d.
c sigmaf = 1/sigma/sqrt(2) 
c inputs:
c ip=period index in perx() below. This controls which period coeffs are used
c iq=table index used with ip for table lookup
c xmag= moment mag (only)
c dist0= hypo distance used in getfea
c sigmanf, distnf = nearfield sigma apply when distance < distnf (not used 2002)
c replaced data statements with array constructors oct 2006.
c
        parameter (np=7,sqrt2i=0.707106781)
      common/gmat/gma,tabdist
      common/epistemic/l_gnd_ep,gnd_ep,ide,ime
      common/ms/ia,jms,npnga,l_ms,lmsp,imsp,meanspec,sigspec
      common/ms2/icu_2_nga(7),k_ms,k_mss,k_mst
      logical l_ms,lmsp(0:10,21)
      integer imsp(8,21)
      real, dimension (21) :: meanspec,sigspec	!fill this if l_ms = .true.
      real gnd_ep(3,3),gndout(3)
      logical l_gnd_ep,sp	!scalar apr 2011,sp

      real bdepth(7),bsigma(7)
      real gma(20,21,28),tabdist(21,4)
             real perx(8)      !a reference set including pgv which wasn't used in 2002
        perx= (/0.,0.2,1.0,0.1,0.3,0.5,2.0,-1./ )
           bdepth= (/5.0,5.0,5.0,5.0,5.0,5.0,5.0/)
           bsigma= (/0.7506,0.7506,0.799,0.7506,0.7506,.7506,0.799/)      !converted to nat log
c           xlogfac/7*0./
c---- following for  FEA or Atkinson-Boore look-up table
      ipq=ip+np*(iq-1)
c        if(icode(ia).eq.1) xmag= 2.715 -0.277*xmag0+0.127*xmag0*xmag0
          sigma= bsigma(ip)      !in correct log base already
          sigmaf= sqrt2i/sigma
          dist= dist0
          sp = perx(ip).gt.0.02 .and.perx(ip).lt.0.5
ccccccccc if fault depth0 ne 0. then this depth term not needed 
c          dist= sqrt(dist0*dist0+bdepth*bdepth)
          if(dist.lt.10.) dist=10.
          imag= (xmag-4.4)/0.2 +1
          rdist= alog10(dist)
          idist= (rdist-tabdist(1,iq))/0.1 + 1
          xm1= (imag-1)*0.2 + 4.4
          fracm= (xmag-xm1)/0.2
          xd1= (idist-1)*0.1 +tabdist(1,iq)
          fracd= (rdist-xd1)/0.1
          idist1= idist+1
          if(idist.gt.21) idist=21
          if(idist1.gt.21) idist1=21
          gm1= gma(imag,idist,ipq)
          gm2= gma(imag+1,idist,ipq)
          gm3= gma(imag,idist1,ipq)
          gm4= gma(imag+1,idist1,ipq)
          arl= gm1 + fracm*(gm2-gm1)
          aru= gm3 + fracm*(gm4-gm3)
          gnd= arl +fracd*(aru-arl)
c          gnd= gnd+ xlogfac      !nuisance. is 0
          gnd= gnd/0.4343
c--- following is for clipping 
          if(ip.eq.1)then
c pga has index ip=1
           gnd=min(0.405,gnd)
           elseif(sp)then
c sp (short period) clipping on median.
           gnd=min(gnd,1.099)
           endif
       gndout(1)=gnd
         if(l_gnd_ep)then
         gndout(2)= gnd+gnd_ep(ide,ime)
         gndout(3)= gnd-gnd_ep(ide,ime)
         endif
  103 continue
	if(.not.l_ms)return
c Play it again, Art, for the conditional mean spectrum
	imag1=imag+1
	do j=1,7
	k=icu_2_nga(j)
        if ( k .eq. k_ms) then
c use the available information. May have to add epsilon0*sigma_t.
        meanspec(k)=gndout(1)
        sigspec(k)=sigma
c	print *,'In FEA input period index for CMS ',perx(j),exp(gndout(1))
	else
c fracm and fracd are used as computed above. 
	 ipq = j+np*(iq-1)
          sp = perx(j).gt.0.02 .and.perx(j).lt.0.5
          gm1= gma(imag,idist,ipq)
          gm2= gma(imag1,idist,ipq)
          gm3= gma(imag,idist1,ipq)
          gm4= gma(imag1,idist1,ipq)
          arl= gm1 + fracm*(gm2-gm1)
          aru= gm3 + fracm*(gm4-gm3)
          gnd= arl +fracd*(aru-arl)
          gnd= gnd/0.4343
c--- following is for clipping 
          if(j.eq.1)then
c pga has index j=1
           gnd=min(0.405,gnd)
           elseif(sp)then
c sp (short period) clipping on median.
           gnd=min(gnd,1.099)
           endif
       meanspec(k)=gnd
       sigspec(k)=bsigma(j)
       endif	!input period or not?
	enddo	!standard period set for CEUS.
      return
      end subroutine getFEA

ccccccccccccccccccccccccc
      subroutine getSomer(ip,ir,xmag0,dist0,gndout,sig,sigmaf)
c---- Somerville et al. (2001) for CEUS
c input dist0 (km) and xmag0 (moment mag) 
c Input ir to control rock conditions:
c ip = index in period array that is currently of interest, ip=1 => PGA for example
c ir=1 BC or firm rock
c ir=2 hard rock (2800 m/s?)
c output gnd=log(median) and sigmaf=1/sigma/sqrt2
c replaced data statements with array constructors oct 2006.
c
      parameter(dist1=50.358713,sqrt2=1.41421356)
c      dist1= sqrt(50.*50.+ 6.*6.) in above parameter statement
      common/epistemic/l_gnd_ep,gnd_ep,ide,ime
      common/ms/ia,jms,npnga,l_ms,lmsp,imsp,meanspec,sigspec
      common/ms2/icu_2_nga(7),k_ms,k_mss,k_mst
      logical l_ms,lmsp(0:10,21)
      integer imsp(8,21)
      real, dimension (21) :: meanspec,sigspec	!fill this if l_ms = .true.
      real gnd_ep(3,3),gndout(3)
      logical l_gnd_ep	!scalar apr 2011

      real a1(7),a2(7),a3(7),a4(7),a5(7),a6(7),a7(7),sig0(7)
c enter statements with coeff values.
             real perx(8),a1h(7)      !a reference set including pgv which wasn't used in 2002
      perx = (/0.,0.2,1.0,0.1,0.3,0.5,2.0,-1./)
      a1 = (/0.658,1.358,-0.0143,1.442,1.2353,.8532,-0.9497/)
      a1h = (/0.239,0.793,-0.307,0.888,0.6930,0.3958,-1.132/)
      a2 = (/0.805,0.805,0.805,0.805,0.805,0.805,0.805/)
      a3 = (/-0.679,-.679,-.696,-.679,-.67023,-.671792,-0.728/)
      a4 = (/0.0861,0.0861,.0861,.0861,0.0861,.0861,.0861/)
      a5 = (/-0.00498,-.00498,-0.00362,-.00498,-.0048045,-.00442189,-0.00221/)
      a6 = (/-0.477,-.477,-0.755,-.477,-.523792,-.605213,-.946/)
      a7 = (/0.,0.,-0.102,0.,-.030298,-.0640237,-.140/)
      sig0 = (/0.587,0.611,0.693,0.595,.6057,.6242,0.824/)
c      clamp = (/3.,6.,3.,6.,6.,6.,6./)
c compute SOmerville median and dispersion estimates.
      sig= sig0(ip)
      sigmaf= 1/sig/sqrt2
      dist= sqrt(dist0*dist0+ 36.)
      if(ir.eq.1)then
      gnd=a1(ip)
      else
      gnd=a1h(ip)
c hard rock/firm rock variation in Somerville only affects a1 coef.
      endif      
      xmag= xmag0
      xmfac=(8.5-xmag)*(8.5-xmag)
c      if(icode(ia).eq.1) xmag= 2.715 -0.277*xmag0+0.127*xmag0*xmag0
      if(dist0.lt.50.) then
      gnd= gnd + a2(ip)*(xmag-6.4) + a3(ip)*alog(dist)
     1 +a4(ip)*(xmag-6.4)*alog(dist)
     2  + a5(ip)*dist0 + a7(ip)*xmfac
        else
      gnd= gnd + a2(ip)*(xmag-6.4) + a3(ip)*alog(dist1)
     1 +a4(ip)*(xmag-6.4)*alog(dist)+a5(ip)*dist0
     2 + a6(ip)*(alog(dist)-alog(dist1))+a7(ip)*xmfac
      endif
c      write(16,*) period,dist0,xmag,exp(gnd)
          if(ip.eq.1.or.ip.eq.7) then
c for long period I also put the PGA  limit (g). SH June 2006.
           gnd=min(gnd,0.405)
          else
           gnd=min(1.099,gnd)
          endif
c apply before or after these limits? here, trying after.
       gndout(1)=gnd
         if(l_gnd_ep)then
         gndout(2)= gnd+gnd_ep(ide,ime)
         gndout(3)= gnd-gnd_ep(ide,ime)
         endif
	if(.not.l_ms)return
c Play it again, Paul, for the conditional mean spectrum
	do j=1,7
	k=icu_2_nga(j)
c	jp=imsp(ia,j)
        sigspec(k)=sig0(j)
        if ( k .eq. k_ms) then
c use the available information. May have to add epsilon0*sigma_t.
        meanspec(k)=gndout(1)
	else
      if(ir.eq.1)then
      gnd=a1(j)
      else
      gnd=a1h(j)
c hard rock/firm rock variation in Somerville only affects a1 coef.
      endif      
      if(dist0.lt.50.) then
      gnd= gnd + a2(j)*(xmag-6.4) + a3(j)*alog(dist)
     1 +a4(j)*(xmag-6.4)*alog(dist)
     2  + a5(j)*dist0 + a7(j)*xmfac
        else
      gnd= gnd + a2(j)*(xmag-6.4) + a3(j)*alog(dist1)
     1 +a4(j)*(xmag-6.4)*alog(dist)+a5(j)*dist0
     2 + a6(j)*(alog(dist)-alog(dist1))+a7(j)*xmfac
      endif
c      write(16,*) period,dist0,xmag,exp(gnd)
          if(j.eq.1.or.j.eq.7) then
c for long period I also put the PGA  limit (g). SH June 2006.
           gnd=min(gnd,0.405)
          else
           gnd=min(1.099,gnd)
          endif
          meanspec(k)=gnd
          endif
          enddo	!7 periods for CEUS
c compute mean value (gnd) for each available period in set
      return
      end subroutine getSomer

ccccccccccccccccccccccccc
      subroutine getAS97(iper,ip,xmag0,dist0,hw,gndout,sigmaf)
c modified for nga style, 7 periods, rock. SHarmsen June 2006.
c input xmag0=moment mag
c dist0 = r_cd or r_rup (km)
c : near-field terms to modify s.d. 0 if none.
c hw = logical variable, true if site on hanging wall
c output:
c gnd,sigmaf
c replaced data statements with array constructors oct 2006.
        parameter (sqrt2=1.414213562)
      common/mech/ss,rev,normal,obl
      common/epistemic/l_gnd_ep,gnd_ep,ide,ime
      real gnd_ep(3,3),gndout(3)
      logical l_gnd_ep	!scalar apr 2011

      logical hw      !.true. if site on hanging wall established in calling pgm
      logical ss,rev,normal,obl
      real, dimension(7):: as1,as2,as3,as4,as5,as6
      real, dimension(7)::  as9,as12,as13,asc1,asc4,b5,b6
             real perx(8)      !a reference set including pgv which wasn't used in 2002
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
c from 2003 input files: no correction (20% median redux?) for normal faults. Is this
c the current understanding?
c-- normal faults do not use the HW term in our 2002 model
        xmag= xmag0
c        if(icode(ia).eq.1) xmag= 2.715 -0.277*xmag0+0.127*xmag0*xmag0
        if(xmag.lt.7.0)then
         sig= b5(ip)- b6(ip)*(xmag-5.0)
        else
         sig= b5(ip)- b6(ip)*2.0
         endif
        sigmaf= 1./(sig*sqrt2)
          r= sqrt(dist0*dist0+ asc4(ip)*asc4(ip))
          if(xmag.le.asc1(ip)) then
          gnd= as1(ip)+as2(ip)*(xmag-asc1(ip))+as12(ip)*((8.5-xmag)**2)
     &         + (as3(ip)+ as13(ip)*(xmag-asc1(ip)))*alog(r)
          
          else 
          gnd= as1(ip)+as4(ip)*(xmag-asc1(ip))+as12(ip)*((8.5-xmag)**2)
     &         + (as3(ip)+ as13(ip)*(xmag-asc1(ip)))*alog(r)
          endif
       gndout(1)=gnd
         if(l_gnd_ep)then
         gndout(2)= gnd+gnd_ep(ide,ime)
         gndout(3)= gnd-gnd_ep(ide,ime)
         endif
          if(.not.rev)return      
c Subsequent AS97 calculations are for reverse-slip sources. 
c There could be a HW term
c for normal slip but this is not considered in USGS 2002 PSHA. And is not
c considered here for consistency.
        if(xmag.le.5.8) then
          fltfac= as5(ip)
        elseif(xmag.lt.asc1(ip))then
           fltfac= as5(ip)
     &        +(as6(ip)-as5(ip))*(xmag-5.8)/(asc1(ip)-5.8)
        else
           fltfac= as6(ip)
        endif
          gnd= gnd+ fltfac
        if(.not.hw)return
c------- for hanging wall sites some additional increments of ground motion
           if(xmag.lt.6.5) then
             fac1= xmag-5.5
           else
              fac1= 1.
           endif
          if(dist0.le.4..or.dist0.gt.25.)return
          if(dist0.lt.8.)then
               fac2= as9(ip)*(dist0-4.)*0.25
          elseif(dist0.lt.18.)then
              fac2= as9(ip)
          else
               fac2= as9(ip)*(1.-(dist0-18.)/7.)
          endif
             gnd= gnd+ fac1*fac2
       gndout(1)=gnd
         if(l_gnd_ep)then
         gndout(2)= gnd+gnd_ep(ide,ime)
         gndout(3)= gnd-gnd_ep(ide,ime)
         endif
c      write(14,*) period,dist0,xmag,exp(gnd)
      return
      end

ccccccccccccccccccccccccccccc
      subroutine getCamp2003(iper,ip,xmag,dist,rjb,gndout,sigmaf)
c  Campbell and Bozorgnia (2003). modifying for nga style. Input rock coeffs.
c Later, add soil coeffs?
c Hangingwall indicated by relation between dist and rjb (both input)
c Coeffs written but not checked july 27 2006. SH. Checked oct 2007. 
        parameter (sqrt2=1.414213562)
      common/mech/ss,rev,normal,obl
      logical ss,rev,normal,obl      
      common/dipinf/dipang,cosDELTA,cdipsq,cyhwfac,cbhwfac
      common/epistemic/l_gnd_ep,gnd_ep,ide,ime
      real gnd_ep(3,3),gndout(3)
      logical l_gnd_ep	!scalar apr 2011

      real, dimension(7):: c1,c2,c3,c4,c5,c6,c7,c8,c9,cmagsig
      real, dimension(7):: csigma1,csigmacoef,csigma2,c10,c11,csite,c15
      real mfac
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
      c15= (/.370,.370,0.281,0.370,0.370,0.370,0.160/)      !HW effect.
      csite= (/-0.289,-0.331,-0.607,-0.299,-0.453,-0.528,-0.649/)      !is this a vs30-dependent term?
      csigma1= (/0.920,0.981,1.021,0.958,0.984,0.990,1.021/)
      csigmacoef= (/0.07, 0.07,0.07,0.07, 0.07,0.07,0.07/)
      csigma2= (/.402,0.463,0.503,0.44,0.466,0.472,0.503/)
      cmagsig= (/ 7.4,7.4,7.4,7.4,7.4,7.4,7.4/)
      mfac=(8.5-xmag)*(8.5-xmag)
c
c        if(icode(ia).eq.1) xmag= 2.715 -0.277*xmag0+0.127*xmag0*xmag0
      gnd= c1(ip) + c2(ip)*xmag + c3(ip)*mfac
      arg0= c8(ip)*xmag + c9(ip)*mfac
      arg= dist*dist + ((c5(ip) + 0.5*c6(ip) +0.5*c7(ip))*exp(arg0))**2
      arg= sqrt(arg)
      gnd = gnd + c4(ip)*alog(arg) + csite(ip)
      if(.not.rev)goto 2
c----  for thrust faults and reverse faults, exta kick. Not for normal
c though.
      if(cosDELTA.lt.0.76)then
      gnd= gnd+ c11(ip)
c--- Another coef for steeper dipping reverse faults
      else
      gnd= gnd+ c10(ip)
      endif
      if(dist.le.30.0 .and. rjb.lt.5.) then
      fhw= (5.-rjb)/5.
      if(xmag.le.6.5) fhw= fhw*(xmag-5.5)
      if(dist.lt.8.)then
       fhw= fhw*c15(ip)*dist/8.
      else
       fhw= fhw*c15(ip)
       endif
c---- hanging wall term for thrust faults or more steeply dipping reverse faults.
      gnd= gnd + fhw
      endif
ccc   sigma C&B with mag-dependence
2          if(xmag.lt.cmagsig(ip)) csigma= csigma1(ip)- 
     &     csigmacoef(ip)*xmag
          if(xmag.ge.cmagsig(ip)) csigma= csigma2(ip)
      sigmaf= 1./csigma/sqrt2
       gndout(1)=gnd
         if(l_gnd_ep)then
         gndout(2)= gnd+gnd_ep(ide,ime)
         gndout(3)= gnd-gnd_ep(ide,ime)
         endif
      return
      end

cccccccccccccc
      subroutine getCampCEUS(ip,ir,xmag,dist,gndout,csigma,sigmaf)
        parameter (sqrt2=1.414213562,alg70=4.2484952,alg130=4.8675345)
        parameter (np=14)
      common/mech/ss,rev,normal,obl
      logical ss,rev,normal,obl      
c      Inputs:
c      ip = period index in coeff arrays below.
c  Campbell CEUS BSSA June 2003. BC or A rock. 14 periods, june 2011.
c Campbell has exceptionally low sigma for higher M events (NMSZ M7.7 for example) 
c input xmag= moment mag
c input dist = rrup (km) appropriate for Camp Ceus.
c ir=1 BC or firm rock
c ir=2 A or hard rock. Only difference is in constant term (check this)
c output gnd = log(median SA) (geometric mean), sigmaf= sigmafactor, and csigma
c
      common/epistemic/l_gnd_ep,gnd_ep,ide,ime
       common/ms/ ia,jms,npnga,l_ms,lmsp,imsp,meanspec,sigspec
c       common/ms2/ icu_2_nga(7),k_ms,k_mss,k_mst
      logical l_ms,lmsp(0:10,21)
      integer imsp(8,21)
      real, dimension (21) :: meanspec,sigspec	!fill this if l_ms = .true.
       real gnd_ep(3,3),gndout(3)
      logical l_gnd_ep,sp	!scalar apr 2011,sp

      real,dimension(np):: c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,
     1 c1h,csigma1,csigmacoef,csigma2,cmagsig,perx
       perx = (/0.01,0.2,1.0,0.1,0.3,0.4,
     + 0.5,2.0,.03,.04,.05,1.5,3.,0.75/)
c Tried using A->BC factors of 0.7, 0.6, and 0.4 for periods 0.05, 0.04, an 0.03, respectively
c from K Campbell suggestion to use kappa=0.02s for 760. see pgm siteamp. 
c however, this reduced from PGA because PGA could not be changed (previously defined).
c So I raised them to 1.1, 1.0, and 0.85, respectively, about what you would expect for
c kappa = 0.01 s. So, with these .01-related factors, no need to discuss. 
c Reference K Campbell (BSSA, 2009)
c
      c1= (/0.4492,.1325,-.3177,.4064,-0.1483,-0.17039,
     + -0.1333,-1.2483,1.033,0.72857,0.469,-0.72,-2.04,-.2429/)
      c1h= (/0.0305,-0.4328,-.6104,-0.1475,-.6906,-0.67076736,
     + -.5907,-1.4306,1.186,0.72857,0.3736,-.9666,-2.2331,-.5429/)
      c2= (/.633,.617,.451,.613,0.609,0.5722637,
     + 0.534,0.459,.622,.618622,.616,0.441,0.492,0.48/)
      c3= (/-.0427,-.0586,-.2090,-.0353,-0.0786,-0.10939892,
     + -0.1379,-0.2552,-.0362,-.035693,-.0353,-.2405,-.2646,-0.1806/)
      c4= (/-1.591,-1.32,-1.158,-1.369,-1.28,-1.244142,
     + -1.216,-1.124,-1.691,-1.5660,-1.469,-1.135,-1.121,-1.184/)
      c5= (/.683,.399,.299,0.484,0.349,0.32603806,
     + 0.318,.310,0.922,0.75759,0.630,.304,0.31,.304/)  !paper's c7
      c6= (/.416,.493,.503,0.467,0.502,0.5040741,
     + 0.503,.499,.376,0.40246,0.423,0.5,0.499,0.504/) !paper's c8
      c7= (/1.140,1.25,1.067,1.096,1.241,1.1833254,
     + 1.116,1.015,0.759,0.76576,0.771,1.029,1.014,1.11/) !paper's c9
      c8= (/-.873,-.928,-.482,-1.284,-.753,-0.6529481,
     + -0.606,-.4170,-.922,-1.1005,-1.239,-.438,-.393,-.526/) !paper's c10
      c9= (/-.00428,-.0046,-.00255,-.00454,-.00414,-3.7463151E-3,
     + -.00341,-.00187,-.00367,-.0037319,-.00378,-.00213,-.00154,-.00288/) !paper's c5
      c10= (/.000483,.000337,.000141,.00046,.000263,2.1878805E-4,
     + .000194,.000103,.000501,.00050044,.0005,.000119,.000084,.00016/) !paper's c6
      csigma1= (/1.030,1.077,1.110,1.059,1.081,1.0901983,
     + 1.098,1.093,1.03,1.037,1.042,1.099,1.09,1.105/)  !paper's c11 or csigma1
      csigmacoef= (/-.0860,-.0838,-.0793,-.0838,-0.0838,-0.083180725,
     + -0.0824,-.0758,-.086,-0.0848,-.0838,-.0771,-.0737,-.0806/) !paper's c12
      csigma2= (/0.414,.478,.543,0.460,0.482,0.49511834,
     + 0.508,0.551,.414,0.43,.443,.547,.562,.528/)  !paper's c13
      sp = perx(ip).gt.0.02.and.perx(ip).lt.0.5
      if(ir.eq.1)then
      gnd=c1(ip)
      else
      gnd= c1h(ip)
      endif
      xmagfac=(8.5-xmag)*(8.5-xmag)
      gnd= gnd + c2(ip)*xmag + c3(ip)*xmagfac
      arg= dist*dist + (c5(ip)*exp(c6(ip)*xmag))**2
      arg= sqrt(arg)
      fac=0.
      if(dist.gt.70.) fac= c7(ip)*(alog(dist)- alg70)
      if(dist.gt.130.) fac= fac+ c8(ip)*(alog(dist)-alg130)
      gnd = gnd + c4(ip)*alog(arg) + fac +(c9(ip)+c10(ip)*xmag)*dist
c      write(12,*) period,dist0,xmag,exp(gnd)
c--- following is for clipping 
         if(ip.eq.1) then
          gnd=min(gnd,0.405)
         elseif(sp)then
           gnd=min(gnd,1.099)
          endif
         if(xmag.lt.cmagsig(ip))then
           csigma= csigma1(ip)+ csigmacoef(ip)*xmag
          else
           csigma= csigma2(ip)
          endif
       gndout(1)=gnd
         if(l_gnd_ep)then
         gndout(2)= gnd+gnd_ep(ide,ime)
         gndout(3)= gnd-gnd_ep(ide,ime)
         endif
      sigmaf= 1./csigma/sqrt2
	if(.not.l_ms)return
c Play it again, Ken C, for the conditional mean spectrum
	do jp=1,17
	j=imsp(ia,jp)
        if ( j .eq. jms) then
c use the available information. May have to add epsilon0*sigma_t.
        sigspec(jp)=csigma
        meanspec(jp)=gndout(1)
	elseif(lmsp(ia,jp)) then
      sp = perx(j).gt.0.02.and.perx(j).lt.0.5
      if(ir.eq.1)then
      gnd=c1(j)
      else
      gnd= c1h(j)
      endif
      gnd= gnd + c2(j)*xmag + c3(j)*xmagfac
      arg= dist*dist + (c5(j)*exp(c6(j)*xmag))**2
      arg= sqrt(arg)
      fac=0.
      if(dist.gt.70.) fac= c7(j)*(alog(dist)- alg70)
      if(dist.gt.130.) fac= fac+ c8(j)*(alog(dist)-alg130)
      gnd = gnd + c4(j)*alog(arg) + fac +(c9(j)+c10(j)*xmag)*dist
c      write(12,*) period,dist0,xmag,exp(gnd)
c--- following is for clipping 
         if(j.eq.1) then
          gnd=min(gnd,0.405)
         elseif(sp)then
           gnd=min(gnd,1.099)
          endif
          meanspec(jp)=gnd
         if(xmag.lt.cmagsig(j))then
           sigspec(jp) = csigma1(j)+ csigmacoef(j)*xmag
          else
           sigspec(jp) = csigma2(j)
          endif
          endif !doable periods
          enddo	!possible periods.
      return
      end subroutine getCampCEUS

ccccccc
      subroutine getBJF97(ip,iq,xmag,dist0,vs30,gndout,sigmaf)
c adapted to nga 7 periods. any vs30.
c dist0 is rjb
c returns gnd, sigmaf
         parameter (sqrt2=1.414213562,np=7)
      common/mech/ss,rev,normal,obl
      common/epistemic/l_gnd_ep,gnd_ep,ide,ime
      real gnd_ep(3,3),gndout(3)
      logical l_gnd_ep	!scalar apr 2011

      logical ss,rev,normal,obl      
        real,dimension(np):: b1ss,b2,b3,b4,b5,hsq,sigma,
     1 b1rv,b1all,bv,va
             real,dimension(8):: perx
c      !a reference set including pgv which wasn't used in 2002
c array constructors
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
c what about near-source dispersion?
      sig = sigma(iq)
          sigmaf= 1./sig/sqrt2
c mech-dependent and site Vs30 dependency
      if(ss)then
      gnd0=b1ss(iq)
      elseif(rev)then
      gnd0 =b1rv(iq)
      else
      gnd0=b1all(iq)
      endif
      gnd0=gnd0+bv(iq)*alog(vs30/va(iq))
          dist= sqrt(dist0*dist0+hsq(iq))
          gnd= gnd0 +b2(iq)*(xmag-6.)+b3(iq)*(xmag-6.)**2
          gnd= gnd + b4(iq)*dist + b5(iq)*alog(dist)
       gndout(1)=gnd
         if(l_gnd_ep)then
         gndout(2)= gnd+gnd_ep(ide,ime)
         gndout(3)= gnd-gnd_ep(ide,ime)
         endif
      return
      end subroutine getBJF97

cccccccc
      subroutine getMota(ip,iq,xmag,dist0,vs30,gndout,sigmaf)
c input xmag = moment mag
c      dist0 = rrup (check with Chuck) (km)
c      vs30  = top30 m Vs. for site amp term. (ditto)
c--  for Motazedian and Atkinson 2003 Puerto Rico relations
c adaptations: predefine some frequently used scalars. put in bjf97 siteamp
       parameter (np=7,alg75=1.8750613,sqrt2=1.41421356)
       parameter (vref=760.0,aln10=2.30258509,alg=2.99122608)
      real bv(np),va(np)
c alg = log10(980)      
      common/epistemic/l_gnd_ep,gnd_ep,ide,ime
      real gnd_ep(3,3),gndout(3)
      logical l_gnd_ep	!scalar apr 2011

      real deltasq,fac,perx(8)
      real c1(np),c2(np),c3(np),c4(np),sigma(np)
c array constructors 10/2006. SH
          perx= (/0.,0.2,1.0,0.1,0.3,0.5,2.0,-1./)      !-1 shall be reserved for pgv
        bv= (/-.371,-.292,-.698,-.212,-.401,-.553,-.655/)
        va= (/1396.,2118.,1406.,1112.,2133.,1816.,1795./)
      c1= (/3.87,4.33,3.40,3.,3.,3.,2.86/)
      c2= (/0.39062,0.38815,0.64818,1.,1.,1.,0.77055/)
      c3= (/-0.11289,-0.13977,-0.15222,0.,0.,0.,-0.11963/)
      c4= (/-0.00213,-0.00189,-0.00091,0.,0.,0.,-0.00082/)
      sigma= (/0.28,0.28,0.28,0.28,0.28,0.28,0.28/)
c      h= (/5.,5.,5.,5.,5.,5.,5./)
c site amp first, convert to base 10 for compatibility
c first try at siteamp is the BJF 97 version. no site nonlinearity. Needs work for better compatibility w/nga
      gnd0 = bv(iq)*alog(vs30/vref)/aln10
      sig = sigma(iq)
          sigmaf= 1./sig/sqrt2
      period = perx(iq)
c gnd0 the site term is added to the magnitude-dependent terms
        deltasq = (-7.333 + 2.333*xmag)**2
        dist= sqrt(dist0*dist0 + deltasq)
        gnd=gnd0 +c1(iq)+c2(iq)*(xmag-6.)+c3(iq)*((xmag-6.)**2)+ c4(iq)*dist
        if(dist.le.75.) then
        fac= (-1.88+0.14*xmag)*alog10(dist)
        elseif(dist.le.100.)then
        fac= (-1.88+0.14*xmag)*alg75
        else 
        fac= (-1.88+0.14*xmag)*alg75 -0.5*alog10(dist/100.)
        endif
c alg serves to convert cm/s/s to g
        gnd= gnd + fac - alg
c base10 to base e
        gnd= gnd*aln10
       gndout(1)=gnd
         if(l_gnd_ep)then
         gndout(2)= gnd+gnd_ep(ide,ime)
         gndout(3)= gnd-gnd_ep(ide,ime)
         endif
      return
      end subroutine getMota
c

      
c ----------------------------------------------------------------------

      
      subroutine getIdriss(iper,ip,xmag,rjb,vs30,gndout,sigmaf)
c Oct 2005: for pga only.
c ip is period index in calling program. 
c iq is period index in this subroutine. But there is no need for period
c subscripting because only pga is available.
      parameter (pi=3.14159265,sqrt2=1.414213562,vref=760.)
      common/epistemic/l_gnd_ep,gnd_ep,ide,ime
      real gnd_ep(3,3),gndout(3)
      logical l_gnd_ep	!scalar apr 2011

      common/mech/ss,rev,normal,obl
      common/dipinf/dipang,cosDELTA,cdipsq,cyhwfac,cbhwfac
c----  This version assumes v30 in neighborhood of 760 m/sec (no Vs30 dependency)
c----  uses ln coefficients
      real magmin,dmag,xmag
      real a1/2.14/,a2/0.134/,b1/2.8/,b2/-0.197/
      real phi/0.08/,sigma/0.68/
      real a16/6.052/,a26/-.473/,b16/3.256/,b26/-0.273/
      logical ss,rev,normal,obl
      if(ip.ne.1)stop'getIdriss: pga only.'
c coeffs. from oct 5 2005 powerpoint progress report
      sig=sigma
          sigmaf= 1./sig/sqrt2
c-- 
      dist0= rjb
          dist= dist0
          if(xmag.lt.6.0) then
          gnd= a1+a2*xmag-(b1+b2*xmag)*alog(dist+10.)
        else
          gnd= a16+a26*xmag- (b16+b26*xmag)*alog(dist+10.)
          endif
          if(rev)then
          gnd = gnd+ phi
          endif
       gndout(1)=gnd
         if(l_gnd_ep)then
         gndout(2)= gnd+gnd_ep(ide,ime)
         gndout(3)= gnd-gnd_ep(ide,ime)
         endif
      return
      end subroutine getIdriss

      subroutine getBANGA0308(ip,xmag,rjb,vs30_in,gndout,sigmaf)
c
c In: ip = period index in per() array below,
c      xmag=moment mag
c      rjb= distance (km)
c      vs30_in = top30 m Vs, (m/s)
c Out: gnd = ln(median), sigmaf = 1/sigma/sqrt2
c
c Mar 2008 update of Boore-Atkinson documentation.  Includes 23 periods
c up to 10-s T.
c----  enter vs30 (need not be 760 m/sec). Usable for Vs30 <= 1300 m/s.
c *** gnd is sensitive to mech type, based on logical variable ss, rev, normal
c----  non-lin soil terms.  
c --- returns log(median) and sigmaf, or "sigma-factor"=1/sigma/sqrt(2)
c --- testing mar 07. Several coeffs have changed meaning compared to earlier.
      parameter (pi=3.14159265,sqrt2=1.414213562,vref=760.,np=23)
      parameter (dx=1.098612289,dxsq=1.206948961,dxcube=1.325968960,plfac=-0.510825624)
c plfac = ln(pga_low/0.1)      This never changes so shouldnt be calculated.
      common/epistemic/l_gnd_ep,gnd_ep,ide,ime
      real gnd_ep(3,3),gndout(3)
      logical l_gnd_ep	!scalar apr 2011

      common/mech/ss,rev,normal,obl
      common/ms/ia,jms,npnga,l_ms,lmsp,imsp,meanspec,sigspec
      logical ss,rev,normal,obl,l_ms,lmsp(0:10,21)
      integer imsp(8,21)
      real, dimension (21) :: meanspec,sigspec	!fill this if l_ms = .true.
      real per(np),e1(np),e2(np),e3(np),e4(np),e5(np),e6(np),e7(np),e8(np)
     1 ,mh(np),c1(np),c2(np),c3(np),c4(np),mref(np),rref(np),h(np),
     2blin(np),b1(np),b2(np),v1(np),v2(np),
     2 sig1(np),sig2u(np),sigtu(np),sig2m(np),sigtm(np)
c Boore & Atkinson consider 23 periods in April 2007 rev. 
c Smooths a kink pp 9-11 of boore sept report.
c
c The e_jnl coeffs prior to Mar 20 2008, used for some SoilC and SoilD analysis for TS3 subcomm.
c      real e1nl/-0.03279/,e2nl/-0.03279/,e3nl/-0.03279/,e4nl/-0.03279/
c      real e5nl/0.29795/,e6nl/-0.20341/,e7nl/0.0/
c      real c1nl/-0.55/,c2nl/0./,c3nl/-0.01151/,hnl/1.35/,b1nl/0./
c BA now suggest using the final PGA coefficients for PGAnl in a followup article to the Mar 08 Eq
c Spectra paper. The above commented-out coeffs are the original "nl" coefficients, and the
c below coefficients are the pga coeffs which correspond to element 2 of the below arrays. 
c Update of Mar 20 2008.
	real e1nl/-0.53804/,e2nl/-0.50350/,e3nl/-0.75472/,e4nl/-0.50970/
	real e5nl/0.28805/,e6nl/-0.10164/,e7nl/0.0/
	real c1nl/-0.66050/,c2nl/0.11970/,c3nl/-0.011510/,hnl/1.35/,b1nl/0./
      real b2nl/0./,pga_low/0.06/,mhnl/6.75/,mrefnl/4.5/,rrefnl/1.0/
c a1,a2 are scalars here. Boore has 'em as vectors in the spreadsheet, but
c unchanging with spectral period. mhnl is the same as mh for pga, i.e., 6.75.
      real  a1/ 0.030/
      real  a2/ 0.090/,a2fac/0.405465108/
      integer ip,jp
      real alpha,pgafac,p2,p3
      logical unspec
c dx = ln(a2/a1), made a param. used in a smoothed nonlin calculation. Mod of sept 2006.
c a2fac=ln(a2/pga_low)
c e2,e3,e4 are the mech-dependent set. e1 is a mech-unspecified value. 
c Mech-dep. coeffs are now used for pganl as well
c   as all other periods, mar 20, 2008. From BA pdf file of Mar 19, 2008. SH.
c 
c array constructors for f95 Linux
c from ba_02apr07_usnr.txt or xlx coef file.
c e1 unspecified; e2 ss; e3 normal; e4 thrust/reverse. Table 2 BA Sept 07 doc.
      per= (/-1.000, 0.000, 0.010, 0.020, 0.030, 0.050, 0.075, 0.100,
     + 0.150, 0.200, 0.250, 0.300, 0.400, 0.500, 0.750, 1.000,
     + 1.500, 2.000, 3.000, 4.000, 5.000, 7.500,10.0/)
       e1= (/ 5.00121,-0.53804,-0.52883,-0.52192,-0.45285,-0.28476,
     1  0.00767, 0.20109, 0.46128, 0.57180, 0.51884, 0.43825, 0.39220, 0.18957,-0.21338,
     1 -0.46896,-0.86271,-1.22652,-1.82979,-2.24656,-1.28408,-1.43145,-2.15446/)
       e2= (/ 5.04727,-0.50350,-0.49429,-0.48508,-0.41831,-0.25022,
     1  0.04912, 0.23102, 0.48661, 0.59253, 0.53496, 0.44516, 0.40602, 0.19878,-0.19496,
     1 -0.43443,-0.79593,-1.15514,-1.74690,-2.15906,-1.21270,-1.31632,-2.16137/)
c Editorial comment Oct 4 2007:
c I (SH) used the e3(10s)=e3(7.5)+e2(10s)-e2(7.5s) for 10s normal, because BA
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
c       e8= (/ 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
c     1  0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
c     1  0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000/)
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
c       c4= (/ 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
c     1  0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,
c     1  0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000/)
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
c sigtu = total aleatory sigma, mech unspecified
      sigtu= (/0.576,0.566,0.569,0.569,0.578,0.589,
     1 0.606,0.608,0.592,0.596,0.592,0.608,0.603,0.615,0.649,
     1 0.654,0.684,0.702,0.700,0.702,0.730,0.781,0.735/)
c sigtm = total aleatory sigma, mech specified
      sigtm= (/0.560,0.564,0.566,0.566,0.576,0.589,
     1 0.606,0.608,0.594,0.596,0.592,0.608,0.603,0.615,0.645,
     1 0.647,0.679,0.700,0.695,0.698,0.744,0.787,0.801/)

c end of April 2007 coeff. updates.
c      
c----  limit vs30. Ref v30= 760 m/sec. B&A say that their model is valid for
c vs30 < 1300 m/s. See Eq Spectra Feb 2008 Abstract % p 113.
	vs30 = min(vs30_in, 1300.)
c
c  ip index corresponds to period. (check per correspondence with main perx)
c--- 
      site=0.0      !site term, nonzero for nonrefernce vs30
      unspec = .false.
c sigma for specific mech type. If unspecified, sigmaf is redefined.
      sig=sigtm(ip)
          sigmaf= 1./sig/sqrt2      ! used with erf( ) in rate/prob calcs.
          rjbsq=rjb*rjb
          dist= sqrt(rjbsq + h(ip)**2)
          if(xmag.le.mh(ip)) then
          gnd= e5(ip)*(xmag-mh(ip))
     1  +e6(ip)*((xmag-mh(ip))**2)
          else
           gnd= e7(ip)*(xmag-mh(ip))
c      1+e8(ip)*((xmag-mh(ip))**2)      !commented out because e8 is zero
           endif
          gnd= gnd+ (c1(ip)+ c2(ip)*(xmag-mref(ip)))*alog(dist/rref(ip))
     1  +c3(ip)*(dist-rref(ip))      
c      2 +c4(ip)*(dist-rref(ip))*(xmag-mref(ip))             
c 2nd continuation line commented out:nuisance
c computation because c4 is zero. c4=0 in Mar 2008 pub.     
          if(rev) then
          gnd = gnd + e4(ip)      !e4 can be lower than e2, the ss-mech coeff.
          elseif(normal) then
          gnd = gnd + e3(ip)      !e3 is lower.
          elseif(ss) then
          gnd = gnd + e2(ip)
          else                  !unspecified slip case
          gnd = gnd + e1(ip)
          sig=sigtu(ip)
          unspec=.true.
           sigmaf= 1./sig/sqrt2      ! used with erf( ) in rate/prob calcs.
          endif
       gndout(1)=gnd
         if(l_gnd_ep)then
         gndout(2)= gnd+gnd_ep(ide,ime)
         gndout(3)= gnd-gnd_ep(ide,ime)
         endif
	if(l_ms)then
	do j=1,npnga
	jp=imsp(ia,j)
	if(unspec)then
        sigspec(j)=sigtu(jp)
        else
        sigspec(j)=sigtm(jp)
        endif
        if ( j .eq. jms) then
c use the available information. May have to add epsilon0*sigma_t.
        meanspec(j)=gndout(1)
	elseif(lmsp(ia,j))then 
c compute mean value (gnd) for each available period in set
	          dist= sqrt(rjbsq + h(jp)**2)
          if(xmag.le.mh(jp)) then
          gnd= e5(jp)*(xmag-mh(jp))
     1  +e6(jp)*((xmag-mh(jp))**2)
c     	  if (xmag.gt.8.0)print *,xmag,gnd,per(jp),jp,ip,j
          else
           gnd= e7(jp)*(xmag-mh(jp))
           endif
          gnd= gnd+ (c1(jp)+ c2(jp)*(xmag-mref(jp)))*alog(dist/rref(jp))
     1  +c3(jp)*(dist-rref(jp))      
          if(rev) then
          gnd = gnd + e4(jp)      !e4 can be lower than e2, the ss-mech coeff.
          elseif(normal) then
          gnd = gnd + e3(jp)      !e3 is lower.
          elseif(ss) then
          gnd = gnd + e2(jp)
          else                  !unspecified slip case
          gnd = gnd + e1(jp)
          endif
c gnd: the 0.2 s mean value can be lower than the 0.1 s mean for large M.  
c     	  if (xmag.gt.8.0.and.per(jp).lt.0.3)print *,xmag,gnd,per(jp),e2(jp),jp,j
       meanspec(j)=gnd
       endif	!lmsp is true
       enddo
       endif	!l_ms is true

          if(vs30.eq.vref)return
c Otherwise correct for non-reference site conditions.
c nonlinear effects, updated March 20 2008. Mech -dependent pga4nl
c  pga estimation for the nonlinearly responding earth
          distnl = sqrt(rjb**2+hnl*hnl)
c Initialize pganl with mech-dep. value. New Mar 20 2008: see BA article following EqSpectra one.
          if(rev) then
          pganl = e4nl      !e4nl slightly lower than e2nl, the ss-mech coeff.
          elseif(normal) then
          pganl = e3nl     !e3 is lower than e4.
          elseif(ss) then
          pganl =  e2nl
          else                  !unspecified slip case
          pganl = e1nl
          endif
c compute magnitude-dependent part of pganl  
c The slip-type dependency was not present in BA_NGA, oct 2007; but is present Mar 2008.
          if(xmag.le.mhnl)then
      pganl = pganl+e5nl*(xmag-mhnl)+e6nl*((xmag-mhnl)**2)
          else
c no increase in Near-Field PGA above mhnl (6.75?), because e7nl is 0.
      pganl = pganl + e7nl*(xmag-mhnl)
           endif
c This pganl is needed when vs30 is not equal to vref. Now compute the
c distance dependency of pganl and add it to current value (log domain). 
          pganl= pganl+ c1nl*alog(distnl/rrefnl)+c3nl*(distnl-rrefnl)
     1 + c2nl*(xmag-mrefnl)*alog(distnl/rrefnl)   
c Note***: c2nl is no longer zero. ***
          pganl=exp(pganl)      !units g
c          
	alpha=alog(vs30/vref)
        if(v1(ip).lt.vs30.and.vs30.le.v2(ip))then
        bnl=(b1(ip)-b2(ip))*
     1 alog(vs30/v2(ip))/alog(v1(ip)/v2(ip)) + b2(ip)
        elseif(v2(ip).lt.vs30.and.vs30.le.vref)then
        bnl=b2(ip)*alpha/alog(v2(ip)/vref)
        elseif(vs30.le.v1(ip))then
        bnl=b1(ip)
        else
        bnl=0.0
        endif
        dy=bnl*a2fac
c Below: include site term. C.f., site with 760 m/s vref.
        site=blin(ip)*alpha
        if(pganl.le.a1)then
        site=site+bnl*plfac
        pgafac=0.
        elseif(pganl.le.a2)then
c c and d from p 10 of boore sept report. Smoothing introduces extra calcs
c in the range a1 < pganl < a2. Otherwise nonlin term same as in june-july.
c many of these terms are fixed and are defined in or parameter statements
c Of course, if a1 and a2 change from their sept 06 values the parameters will
c also have to be redefined.
        c=(3.*dy-bnl*dx)/dxsq
        d=(bnl*dx-2.*dy)/dxcube
        pgafac=alog(pganl/a1)
        p2=pgafac*pgafac; p3=pgafac*p2
        site=site+bnl*plfac + c*p2 + d*p3
        else
        pgafac=alog(pganl/0.1)
        site=site+bnl*pgafac
        endif
c modify gndout if gnd is modified by nonlinear soil amp. But, how to modify gnd_ep?
       gndout(1)=gndout(1)+site
         if(l_gnd_ep)then
         gndout(2)= gndout(1)+gnd_ep(ide,ime)
         gndout(3)= gndout(1)-gnd_ep(ide,ime)
         endif
c There may be a different sigma for nonlin soil. Not included.
c  There is a sigma associated with pganl. 
c go thru the nonlinear calcs for the mean spectrum too if required...
	if(l_ms)then
	do j=1,npnga
	jp=imsp(ia,j)
	if(j .eq. jms)then
	meanspec(j)=gndout(1)
c	if(sig.ne.sigspec(j))print *,'BA sig, sigspec not equal?',sig,sigspec(j),j
c Play it again, Dave, for the CMS
	elseif(lmsp(ia,j))then
c compute adjusted mean value (meanspec(j)) for each available period in set.
c use the previously computed pganl.
        if(v1(jp).lt.vs30.and.vs30.le.v2(jp))then
        bnl=(b1(jp)-b2(jp))*
     1 alog(vs30/v2(jp))/alog(v1(jp)/v2(jp)) + b2(jp)
        elseif(v2(jp).lt.vs30.and.vs30.le.vref)then
        bnl=b2(jp)*alpha/alog(v2(jp)/vref)
        elseif(vs30.le.v1(jp))then
        bnl=b1(jp)
        else
        bnl=0.0
        endif
        dy=bnl*a2fac
c Below: include site term. Use previously computed pganl
        site=blin(jp)*alpha
        if(pganl.le.a1)then
        site=site+bnl*plfac
        elseif(pganl.le.a2)then
c c and d from p 10 of boore sept report. Smoothing introduces extra calcs
c in the range a1 < pganl < a2. Otherwise nonlin term same as in june-july.
c many of these terms are fixed and are defined in or parameter statements
c Of course, if a1 and a2 change from their sept 06 values the parameters will
c also have to be redefined.
        c=(3.*dy-bnl*dx)/dxsq
        d=(bnl*dx-2.*dy)/dxcube
c p2 has already been defined as has p3.
        site=site+bnl*plfac + c*p2 + d*p3
        else
        site=site+bnl*pgafac
        endif
c modify mean value by nonlinear soil amp. 
        meanspec(j)=meanspec(j) +site
       endif	!lmsp is true
       enddo	!loop thru periods that define meanspec
       endif	!l_ms is true
      return
      end subroutine getBANGA0308

        subroutine CY2007H(iprd, M, R_Rup, R_JB, R_x, V_S30, Z1, Z_TOR,
     1                 F_RV, F_NM,  gndout, sigmaf)

        parameter (mxnprd=105)
      parameter (sqrt2=1.414213562)
c      implicit none
c Previously output psa=ln(median) and sigmaf, two scalar quantities needed for Pex calcs.
c Jan 24 2007: psa replaced by gndout, a 3-component vector
c gndout(1)=psa, gndout(2)=psa+gnd_ep, gndout(3)=psa-gnd_ep. Mod was inspired
c by need to increase variability not present in the 3 or 4 NGA relations
c From Nov 2007 Chiou & Youngs NGA subroutine "cy2007".
c Added meanspectrum calculation Nov 1, 2010. SH.
c
c  A few efficiencies added to CY fortran.
c Predictor variables
c DELTA = fault dip (degrees) no longer an argument
c dipang (radians) is available in common/dipinf/
c z1 = depth (m) where vs is 1.0 km/s. THis is now used Oct 2007 code.
c vs30 top 30 m avg vs30,
c R_x new signed distance, < 0 on footwall for big extension of fault
c R_rup and R_JB the usual distance metrics.
c iprd the period index in the 105 element arrays below
c	of the hot input period
c	Prior to Apr 2011 an "ip" index was passed into CY2007H. This was not needed and was removed.
c M the source moment mag
c Z_TOR depth to top of rupture (km).
c 
c This version returns gndout and sigmaf. It does not return psa_ref.
c psa_ref is the median SA for the "reference" site class, might be useful.
c
      common/dipinf/dipang,cosDELTA,cdipsq,cyhwfac,cbhwfac
      common/epistemic/l_gnd_ep,gnd_ep,ide,ime
      common/cyinit/a,b,c,coshfac,rkdepth
      common/ms/ia,jms,npnga,l_ms,lmsp,imsp,meanspec,sigspec
      real gnd_ep(3,3),gndout(3)
      logical l_gnd_ep,l_ms,lmsp(0:10,21)
   	integer imsp(8,21)
      real, dimension (21) :: meanspec,sigspec
c Predictor variables
        real PERIOD, M, Width, R_rup, R_JB, R_x, V_S30, Z1, 
     1       Z_TOR, F_RV, F_NM

c Model coefficients. Phi moved to cy2007i, oct 25 2007. SHarmsen.
        real, dimension(mxnprd):: prd,
     1       c1, c1a, c1b, c2,
     1       c3, cn,  cM,  c4,
     1       c4a,cRB, c5,  c6,
     1       cHM,c7,  c9, c9a,
     1       cgamma1, cgamma2, cgamma3,
     1       phi1,phi2,phi3,phi4,phi5,phi6,phi7,phi8,
     1       sigma_t,tau1,tau2,sigma1,sigma2,dlt1
c sigma_t is from the 2006 CY model and is retained here only to make comparisons with current estimate
c of this important quantity. Steve Harmsen.
      real aa,bb,cc, gamma, cosDELTA, cyhwfac, cbhwfac, psa, psa_ref
      real dipang,cdipsq,sigmaf, NL, NL0, coshfac
      real r1,r2, r3, r4, fw, hw, hwfac, minimax,signl
      integer iprd, jp
c prd array not used below. Assume SA 0.01 s is PGA.
      prd= (/0.010,0.020,0.022,0.025,0.029,0.030,0.032,0.035,0.036,0.040,0.042,0.044,0.045,0.046,
     10.048,0.050,0.055,0.060,0.065,0.067,0.070,0.075,0.080,0.085,0.090,0.095,0.100,0.110,0.120,
     10.130,0.133,0.140,0.150,0.160,0.170,0.180,0.190,0.200,0.220,0.240,0.250,0.260,0.280,0.290,
     10.300,0.320,0.340,0.350,0.360,0.380,0.400,0.420,0.440,0.450,0.460,0.480,0.500,0.550,0.600,
     10.650,0.667,0.700,0.750,0.800,0.850,0.900,0.950,1.000,1.100,1.200,1.300,1.400,1.500,1.600,
     11.700,1.800,1.900,2.000,2.200,2.400,2.500,2.600,2.800,3.000,3.200,3.400,3.500,3.600,3.800,
     14.000,4.200,4.400,4.600,4.800,5.000,5.500,6.000,6.500,7.000,7.500,8.000,8.500,9.000,9.500,
     110.0/)
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
     1 -4.78938,-4.90790,-5.01833,-5.12243,-5.22154,-5.31657,-5.40817,-5.49675,-5.58722/)
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
     1 -0.09980,-0.09980,-0.09990,-0.09990,-0.09990,-0.100,-0.100,-0.100,-0.10000/)
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
     1 -0.10100,-0.10100,-0.10100,-0.10100,-0.100,-0.100,-0.100,-0.100,-0.10000/)
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
     1 1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.060,1.060/)
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
     1 3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.450,3.450/)
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
     1  1.48780, 1.49230, 1.49550, 1.49750, 1.49900, 1.500, 1.50100, 1.50100, 1.50200/)
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
     1  5.84040, 5.89240, 5.94220, 5.98910, 6.03390, 6.07700, 6.11720, 6.15610, 6.19300/)
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
     1 -2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1,-2.1/)
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
     1 -0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5/)
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
     1 50.0,50.0,50.0,50.0,50.0,50.0,50.0,50.0,50.0/)
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
     1  5.20100, 5.20100, 5.20100, 5.200, 5.200, 5.200, 5.200, 5.200, 5.20000/)
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
     1  0.45000, 0.45000, 0.45000, 0.45000, 0.45000, 0.45000, 0.45000, 0.45000, 0.45000/)
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
     1  3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0/)
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
     1  0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.00000/)
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
     1  0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.00000/)
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
     1  2.71747, 2.71774, 2.71774, 2.71774, 2.71801, 2.71801, 2.71801, 2.71801, 2.71801/)
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
     1 -0.000987,-0.000977,-0.000968,-0.000961,-0.000955,-0.000950,-0.000945,-0.000941,-0.000937/)
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
     1 -0.000964,-0.000954,-0.000945,-0.000938,-0.000933,-0.000927,-0.000923,-0.000919,-0.000914/)
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
     1  4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.0000, 4.000/)
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
     1 -.8982,-.8791,-.8572,-.8346,-.8126,-.7914,-.7711,-.7517,-.7332/)
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
     1 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.0000/)
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
     1 -0.001397,-0.001384,-0.001375,-0.001369,-0.001364,-0.001362,-0.001360,-0.001360,-0.001361/)
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
     1  0.002047, 0.001662, 0.001366, 0.001134, 0.000952, 0.000806, 0.000689, 0.000593, 0.000515/)
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
     1  0.4800, 0.4800, 0.4800, 0.4800, 0.4800, 0.4800, 0.4800, 0.4800, 0.480000/)
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
     1  0.005517, 0.005517, 0.005517, 0.005517, 0.005517, 0.005517, 0.005517, 0.005517, 0.005517/)
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
     1  320.6, 320.4, 320.4, 320.3, 320.2, 320.2, 320.2, 320.1, 320.1/)
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
     1  0.253200, 0.259500, 0.263500, 0.266000, 0.267500, 0.268300, 0.268600, 0.268500, 0.268200/)
c the below tau1,2, sigma1,2 dlta are new 5pm nov 2 2007.
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
     1 0.5181,0.5232,0.5281,0.5328,0.5374,0.5419,0.5461,0.5502,0.5542/)
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
     1 0.5181,0.5232,0.5281,0.5328,0.5374,0.5419,0.5461,0.5502,0.5542/)
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
     1 0.4417,0.4417,0.4416,0.4416,0.4415,0.4415,0.4415,0.4415,0.4414/)
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
     1 0.4213,0.4213,0.4213,0.4213,0.4213,0.4213,0.4213,0.4213,0.4213/)
c dlt1 is used for the case of INFERRED Vs30. dlt1 is sigma3 of Eq Spectra paper
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
     1 0.7000,0.7000,0.7000,0.7000,0.7000,0.7000,0.7000,0.7000,0.7000/)
c sigma_t = 2006 not to be used with final CY model
      sigma_t= (/ 0.5606, 0.5624, 0.5664, 0.5716, 0.5801, 0.5819, 0.5855, 0.5901, 0.5916, 0.5976, 0.6020, 0.6050, 0.6059, 0.6073,
     1 0.6120, 0.6172, 0.6313, 0.6372, 0.6447, 0.6470, 0.6472, 0.6500, 0.6532, 0.6556, 0.6601, 0.6621, 0.6629, 0.6579, 0.6672,
     1 0.6575, 0.6547, 0.6496, 0.6435, 0.6356, 0.6287, 0.6256, 0.6186, 0.6085, 0.6024, 0.5981, 0.5981, 0.5977, 0.5989, 0.6032,
     1 0.6081, 0.6123, 0.6145, 0.6169, 0.6165, 0.6155, 0.6197, 0.6255, 0.6288, 0.6282, 0.6261, 0.6224, 0.6249, 0.6320, 0.6447,
     1 0.6485, 0.6507, 0.6504, 0.6403, 0.6412, 0.6326, 0.6333, 0.6352, 0.6326, 0.6428, 0.6425, 0.6418, 0.6397, 0.6424, 0.6518,
     1 0.6559, 0.6599, 0.6619, 0.6645, 0.6632, 0.6689, 0.6684, 0.6709, 0.6717, 0.6744, 0.6860, 0.6937, 0.6922, 0.6934, 0.6967,
     1 0.7023, 0.7217, 0.7204, 0.7234, 0.7306, 0.7313, 0.7343, 0.7348, 0.7538, 0.7582, 0.7776, 0.7997, 0.7085, 0.7223, 0.7271,
     1 0.7081/)
              cc = c5(iprd)* cosh(c6(iprd) * max(M-cHM(iprd),0.))
        gamma = cgamma1(iprd) +
     1          cgamma2(iprd)/cosh(max(M-cgamma3(iprd),0.))
c        cosDELTA = cos(DELTA*d2r)
	sig=0.0; tau=0.0

c Magnitude scaling
        r1 = c1(iprd) + c2(iprd) * (M-6.0) +
     1       (c2(iprd)-c3(iprd))/cn(iprd) *
     1             log(1.0 + exp(-cn(iprd)*(M-cM(iprd))))

c Near-field magnitude and distance scaling
        r2 = c4(iprd) * log(R_Rup + cc)

c Far-field distance
        r3 = (c4a(iprd)-c4(iprd))/2.0 *
     1            log( R_Rup*R_Rup+cRB(iprd)*cRB(iprd) ) +
     1       R_Rup * gamma

c Scaling with other source variables (F_RV, F_NM, and Z_TOR)
        r4 = c1a(iprd)*F_RV +
     1       c1b(iprd)*F_NM +
     1       c7(iprd)*(Z_TOR - 4.)

c HW effect. R_x < 0? A signed distance measure. R_x < 0 occurs at footwall locations
        if (R_x .lt. 0) then
          hw = 0.0
        else
        	hwfac = (1.0 - sqrt(R_JB**2+Z_TOR**2)/(R_Rup + 0.001))
          hw = c9(iprd) * tanh(R_x*cosDELTA**2/c9a(iprd)) * hwfac
c hwfac will be used again below when computing mean spectrum.
        endif


        psa_ref = r1+r2+r3+r4+hw

c......
c Soil effect: linear response. The commented-out lines are done in CY2007I, below
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
c Median PSA prediction for reference condition. Keep psa a logged quantity. SH.
        psa = psa_ref + 
     1 (a + b * log((exp(psa_ref)+c)/c)) + rkdepth
c....... Aleatory variablility (to be provided soon)
c Tau
	minimax=(min(max(M,.5),7.)-5.)
        tau = tau1(iprd) + (tau2(iprd)-tau1(iprd))/2. * minimax
c To compute NL, psa_ref is Not Logged
	psa_ref=exp(psa_ref)
        NL = b * psa_ref/(psa_ref+c)
c correction by B Chiou, 11/06/2007& 11/08
c      tau = tau * sqrt(1.0+ NL)
      tau = tau * (1.0 + NL)
c.......
c Sigma
        sigma_M = sigma1(iprd) +
     1        (sigma2(iprd)-sigma1(iprd))/2* minimax
c dlt1 below is an additional feature of the 5pm nov 2 model from Chiou email.
        sig = sigma_M * sqrt(dlt1(iprd)+ (1.0 + NL)**2)
      sig = sqrt(sig**2 + tau**2)

c 2007 sigma is returned. 
c   sigma is  heteroscedastic. lower sigma for soil sites and high ref. rock PGA.
       gndout(1) = psa
         if(l_gnd_ep)then
         gndout(2)= psa+gnd_ep(ide,ime)
         gndout(3)= psa-gnd_ep(ide,ime)
         endif
       sigmaf= 1.0/sig/sqrt2
c Play it again, Brian, when mean spectra are needed. First pass: mean values but no
c updates to sigma_t. We may need sigma_t(T) as well. Sigma nad tau lines above will need
c to be copied below.      
	if(l_ms)then
	do j=1,npnga
	jp=imsp(ia,j)
        if ( jms .eq. j)then
c use the available information
        meanspec(j)=gndout(1)
        sigspec (j)=sig
c        if(M.gt.8.)print *,M,j,jp,prd(jp),gndout(1)
	elseif(lmsp(ia,j))then
c if past the barrier, spectrum is computable at T (index j)
              cc = c5(jp)* cosh(c6(jp) * max(M-cHM(jp),0.))
        gamma = cgamma1(jp) +
     1          cgamma2(jp)/cosh(max(M-cgamma3(jp),0.))
c Magnitude scaling
        r1 = c1(jp) + c2(jp) * (M-6.0) +
     1       (c2(jp)-c3(jp))/cn(jp) *
     1             log(1.0 + exp(-cn(jp)*(M-cM(jp))))

c Near-field magnitude and distance scaling
        r2 = c4(jp) * log(R_Rup + cc)

c Far-field distance
        r3 = (c4a(jp)-c4(jp))/2.0 *
     1            log( R_Rup*R_Rup+cRB(jp)*cRB(jp) ) +
     1       R_Rup * gamma

c Scaling with other source variables (F_RV, F_NM, and Z_TOR)
        r4 = c1a(jp)*F_RV +
     1       c1b(jp)*F_NM +
     1       c7(jp)*(Z_TOR - 4.)

c HW effect. R_x < 0? A signed distance measure. R_x < 0 occurs at footwall locations
        if (R_x .lt. 0) then
          hw = 0.0
        else
          hw = c9(jp) * tanh(R_x*cosDELTA**2/c9a(jp)) * hwfac
        endif


        psa_ref = r1+r2+r3+r4+hw

c......
c Soil effect: linear response. 
        aa = phi1(jp) * min(log(V_S30/1130.), 0.)

c Soil effect: nonlinear response. 1130-360= 770 
        bb = phi2(jp) *
     1(exp(phi3(jp)*(min(V_S30,1130.)-360.))-exp(phi3(jp)*(770.)))
        cc= phi4(jp)

c Modification to ln(Vs30) scaling: bedrock depth (Z1)
c NOTE: max(0,Z1-15) is capped at 300 to avoid overflow of function cosh
        rkdepthd = phi5(jp) *
     1        ( 1.0 - 1.0/cosh(phi6(jp)*max(0.,Z1-phi7(jp)))) +
     1        phi8(jp)/coshfac

c......
c Median PSA prediction for reference condition. Keep psa a logged quantity. SH.
        psa = psa_ref + 
     1 (aa + bb * log((exp(psa_ref)+cc)/cc)) + rkdepthd
        meanspec(j)=psa
c Tau
        tau = tau1(jp) + (tau2(jp)-tau1(jp))/2. * minimax
c Recompute NL
	psa_ref=exp(psa_ref)
        NL = bb * psa_ref/(psa_ref+cc)
c psa_ref is not logged and has units g.
c
	NL0= abs (1. + NL)
	tau=tau*NL0
c        tau = tau * (1.0 + NL)
c.......
c Sigma
        sigma_M = sigma1(jp) +
     1        (sigma2(jp)-sigma1(jp))/2 * minimax
c dlt1 below is an additional feature of the 5pm nov 2 model from Chiou email.
c        signl = sigma_M * sqrt(dlt1(jp)+ (1.0 + NL)**2)
        signl = sigma_M * sqrt(dlt1(jp)+ NL0**2)
       sigspec(j) = sqrt(signl**2 + tau**2)
c       if(sigspec(j).gt.1.)then
c       print *, j,M,aa,bb,cc,rkdepthd,tau,nl,signl
c       print *,psa_ref,gamma,minimax,sigspec(j),'CY'
c       endif	!extra prints to figure out what the heck is going on here
        endif	!this period is computable?
        enddo
        endif	!if (l_ms)

      return
      end subroutine CY2007H

        subroutine CY2007I(iprd, V_S30, Z1)                  
c this subroutine computes some soil terms (a,b,c,rkdepth) for a fixed
c vs30 and z1 model. These are stored in scalars in named common. 
c This initialization
c is done to speed up runs. 
c Input:
c   ip, period index in global psha run. IPMAX is 1 (not storing vectors Nov 2010)
c   iprd, period index of the CY coefficients associated with period
c    V_S30 = vs in top 30 m (m/s)
c    Z1 = depth (m) where Vs is >= 1 km/s. THis quantity should be fixed for all
c    receivers in the run (like the standard Vs30 maps we have produced). See phi7.
c
c 
        parameter (mxnprd=105)
c      parameter (pi=3.14159265,d2r=0.0174533,sqrt2=1.414213562)
      common/cyinit/a,b,c,coshfac,rkdepth
        real V_S30, Z1,coshfac
c only one period. no need to make a,b,c, rkdepth inot vectors.
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
     1 -.8982,-.8791,-.8572,-.8346,-.8126,-.7914,-.7711,-.7517,-.7332/)
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
     1 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.0000/)
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
     1 -0.001397,-0.001384,-0.001375,-0.001369,-0.001364,-0.001362,-0.001360,-0.001360,-0.001361/)
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
     1  0.002047, 0.001662, 0.001366, 0.001134, 0.000952, 0.000806, 0.000689, 0.000593, 0.000515/)
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
     1  0.4800, 0.4800, 0.4800, 0.4800, 0.4800, 0.4800, 0.4800, 0.4800, 0.480000/)
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
     1  0.005517, 0.005517, 0.005517, 0.005517, 0.005517, 0.005517, 0.005517, 0.005517, 0.005517/)
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
     1  320.6, 320.4, 320.4, 320.3, 320.2, 320.2, 320.2, 320.1, 320.1/)
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
     1  0.253200, 0.259500, 0.263500, 0.266000, 0.267500, 0.268300, 0.268600, 0.268500, 0.268200/)
c Soil effect: linear response
      if(Z1 .le.5.)then
        Z1 = exp(28.5-3.82/8*log(V_S30**8+378.8**8)) 
c        write(6,*)'CY uses a default Z1 (m) of ',Z1
        endif
        a = phi1(iprd) * min(log(V_S30/1130.), 0.)

c Soil effect: nonlinear response. 1130-360= 770 
        b = phi2(iprd) *
     1(exp(phi3(iprd)*(min(V_S30,1130.)-360.))-exp(phi3(iprd)*(770.)))
        c = phi4(iprd)
	coshfac = cosh(0.15*min(max(0., Z1-15.),300.))
c Modificaiton to ln(Vs30) scaling: bedrock depth (Z1)
c NOTE: max(0,Z1-15) is capped at 300 to avoid overflow of function cosh
        rkdepth = phi5(iprd) *
     1        ( 1 - 1.0/cosh(phi6(iprd)*max(0.,Z1-phi7(iprd)))) +
     1        phi8(iprd)/ coshfac
      return
      end subroutine CY2007I

      subroutine getCampNGA0308(ip,amag,rrup,rjb,H,
     1 vs,d,gndout,sigmaf)
c....................................................................
c  Campbell and Bozorgnia NGA regression relation, Nov 15 2007. Update of
c  November 2007 affects aleatory uncert only, add PGD (index 24).
c  from getCampNGA0601 based on code of Yuehua Zeng, USGS
c  add mean spectrum calc Oct 29 2010.
c Steve Harmsen. 
c Note: this version always computes pgar, Other periods need pgar
c hard-rock value for subsequent nonlin soil calcs.
c Coeffs from Campbell_Bozorgnia_NGA_MAR08_EERI_SPECTRA.txt (xls) November 2007
c  input: 
c        
c   Note "iper" no longer sent over: not needed. trying to repair by simplifying apr 2011
c        ip      :index for period in Pd array below
c         amag : moment magnitude
c         rrup : closest fault distance
c         rjb  : distance to the fault projection on the surface
c         rak  : rake angle (d). Replaced by style of faulting coming in in common, SH.
c         vs   : site S-velocity in m/s (should be Vs30 )
c         H    : depth to top of the fault
c         d    : sediment depth now defined as Z2.5, depth to 2.5 km/s Vs.
c
c  output: gnd   : ln(ground motion spectral value, g)
c          
c          sigmaf= 1/sig_t/sqrt2 = sigma-factor in natural log
c....................................................................
c Update: compute mean spectrum when l_ms = .true.: add option Oct 28 2010
c random component sig_t:
c sig_t = sqrt (tau**2+sigma**2+chisq) see coeff values below.
c but we use a lower-sigma "geometric" oct 2007.
      parameter (sqrt2=1.414213562,rockcoef=0.24033595,expm75=0.47236655,slnAF=0.3)
c rockcoef = alog(1100/k1(1)), expm75=exp(-0.75)         
c C-B NGA Report: november 2007. 
        parameter (np=24)
      common/mech/ss,rev,normal,obl
      common/dipinf/dipang,cosDELTA,cdipsq,cyhwfac,cbhwfac
      common/epistemic/l_gnd_ep,gnd_ep,ide,ime
      common/ms/ia,jms,npnga,l_ms,lmsp,imsp,meanspec,sigspec
      real gnd_ep(3,3),gndout(3)
      real sln_Ab, sln_yb      !sigma at base of soil column. New additions
c of late Nov 2007. These are in the Ken Campbell & Yusef Bozorgnia paper to 
c Earthquake Spectra March 2008
      logical l_gnd_ep	!scalar apr 2011

      real sigsqu,spgasq/0.228484/,f6fac,slnAFsq/0.09/
      logical ss,rev,normal,obl,l_ms,lmsp(0:10,21)
       integer imsp(8,21)
      real, dimension (21) :: meanspec,sigspec
        real pgar,f1r,f2r,f3r,f4r,f5r,f6r
        real,dimension(np):: Pd,c0,c1,c2,c3,c4,c5,c6,c7,c8,
     1 c9,c10,c11,c12,k1,k2,k3,rhos,slny,tlny,sC
c Coeffs from Campbell_Bozorgnia_NGA_MAR08_EERI_SPECTRA.txt  (xls) November 2007
c 24 periods available, -1 is PGV. -2 is PGD. 0.00 is PGA. Removed the vector slnAF apr 2011 and just use slnAFsq.
c SHarmsen Nov 15 2006. Pd=spectral period vector.
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
      c10=(/1.058,1.102,1.174,1.272,1.438,1.604,1.928, 2.194,2.351,2.460,2.587,2.544,2.133,
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
c      slnAF=(/ 0.300, 0.300, 0.300, 0.300, 0.300, 0.300,
c     + 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300,
c     + 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300, 0.300/)
      sC   =(/ 0.166, 0.166, 0.165, 0.162, 0.158, 0.170,
     + 0.180, 0.186, 0.191, 0.198, 0.206, 0.208, 0.221, 0.225, 0.222,
     + 0.226, 0.229, 0.237, 0.237, 0.271, 0.290, 0.166, 0.190, 0.290/)
          rhos=(/ 1.000, 0.999, 0.989, 0.963, 0.922, 0.898,
     + 0.890, 0.871, 0.852, 0.831, 0.785, 0.735, 0.628, 0.534, 0.411,
     + 0.331, 0.289, 0.261, 0.200, 0.174, 0.174, 1.000, 0.691, 0.174/)
        cs= 1.88
        cn= 1.18      !these 2 c-values did not change from the 1-06 report.
c
        i=ip      !period index
c return to ground-motion independent sigma, C&B 11/06.
            tausq=tlny(i)**2
            sigsq=slny(i)**2
            sigsqu = sigsq      !add for use in non-linear sigma. Nov 2007
c            chisq=sC(i)**2
c random horizontal component, include the chisq boost compared to geom. mean.
c            sigt=sqrt(tausq+sigsq+chisq)      !campbell has a kchi=1 factor for USGS
         sigt = sqrt(tausq + sigsq)	!campbell note Oct 2007. Be consistent with others,
c who use geometric mean.
c  Originally CB recom. RHC for use by USGS. Other apps might want geometric mean, whose sigt is lower.
c sigmaf is a factor in the normal prob. 
            sigmaf=1.0/sigt/sqrt2
c           f(i)=1./per(i)      !dont need
c f1=median dependence on magnitude. f2= joint M,R dependence
           f1=c0(i)+c1(i)*amag
           f1r=c0(1)+c1(1)*amag
           if(amag.gt.5.5)then
           f1=f1+c2(i)*(amag-5.5)
           f1r=f1r+c2(1)*(amag-5.5)
           endif
           if(amag.gt.6.5)then
           f1=f1+c3(i)*(amag-6.5)
           f1r=f1r+c3(1)*(amag-6.5)
           endif
           f2=(c4(i)+c5(i)*amag)*0.5*alog(rrup*rrup+c6(i)*c6(i))
           f2r=(c4(1)+c5(1)*amag)*0.5*alog(rrup*rrup+c6(1)*c6(1))
           f3=0.0
           f4=0.0
c f3 dependence on source mechanism; f4 hanging-wall dependence N&R both
c           if(rak.gt.30.0.and.rak.lt.150.0)then
      if(rev)then      !less precise but corresponds to current classification
             if(H.gt.1.0)then
               f3=c7(i)
               f3r=c7(1)
             else
               f3=c7(i)*H
               f3r=c7(1)*H
             endif
c           elseif(rak.gt.-150.0.and.rak.lt.-30.0)then
      elseif(normal)then      !less precise but corresponds to current classification
             f3=c8(i)
             f3r=c8(1)
         endif      !reverse or normal slip. Hangingwall can be on for normal too.
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
             f4=c9(i)*fhw*cbhwfac*(20.0-H)*0.05      
             f4r=c9(1)*fhw*cbhwfac*(20.0-H)*0.05      
c cbhwfac new july 2006, computed in main
               if(amag.lt.6.5)then
               f4=f4*(amag-6.0)*2.0
               f4r=f4r*(amag-6.0)*2.0
               endif
             endif
c f6 = Shallow sediment thickness dependence:
c Null depth effect for 1<d<3. 
           f6=0.0
           f6r=0.0
           if(d.lt.1.0)then
             f6=c11(i)*(d-1.0)
             f6r=c11(1)*(d-1.0)
           elseif(d.gt.3.0)then
              f6fac=expm75*(1.0-exp(-0.25*(d-3.)))
             f6=c12(i)*k3(i)*f6fac
             f6r=c12(1)*k3(1)*f6fac
           endif
         vscap = min(vs,1100.)
c in deaggFLTH.2013.f pgar is always calculated at this point. in other codes with
c several periods pgar could be calculated once and then reused through the period loop.
c There can be a period loop here; top part: just one period, which may or may not be PGA.
c Then, if l_ms is true, a collection of other periods. The soil part for the l_ms loop is booyah.
             pgar=exp(f1r+f2r+f3r+f4r+f6r+(c10(1)+k2(1)*cn)*rockcoef)
           vsrk=vscap/k1(i)
c Ken Campbell email mar 6 2008: cap Vs at 1100 m/s for these calcs. See Eq Spectra
c report.
           if(vsrk.lt.1.0)then
c Also, ip index loop has to be inside any distance and mag index loops. It is in current code.
             csfac=cs*vsrk**cn
             f5=c10(i)*alog(vsrk)
     +            +k2(i)*alog((pgar+csfac)/(pgar+cs))
c additional alpha term CB eqn (17) Sept 1 2006, in sigma computation
c need spgasq=spga**2 & tpgasq=tpga**2. Use the sigma(1) & tau(1). 
c these are conveniently defined in a statement to save calculations.
            alpha=k2(i)*pgar*(1./(pgar+csfac)-1./(pgar+cs))
            alfsq=alpha*alpha 
c tau no dependency on soil nonlinearity in the CB EQ Spectra article, see. eqn (14) & eqn (16)
c sln_Ab sigma of pga at base of site profile. see "doc" Eq Spectra paper, p 13 midway thru.
c      	sln_Ab= sqrt(spgasq - slnAFsq)
	sln_Ab = 0.51736836	!why compute this? Fixed quantity.
      	sln_yb= sqrt(slny(i)**2 - slnAFsq)
c sln_yb is sigma for spectral period j at base of soil column. Campbell corr.
c Nov 30 2007
      	sigsq=sigsqu +alfsq*sln_Ab**2+2.*alpha*rhos(i)*sln_Ab*sln_yb
c nonlinear motion-dependent sigma, but no motion-dependent tau.
           sigt = sqrt(tausq + sigsq)	
            sigmaf=1.0/sigt/sqrt2
            else
             alpha=0.
             f5=(c10(i)+k2(i)*cn)*alog(vsrk)
c             sigt=sig_t(i)
           endif
           gnd=f1+f2+f3+f4+f5+f6
       gndout(1)=gnd
c for QA tests, look at near-source log mean values
         if(l_gnd_ep)then
         gndout(2)= gnd+gnd_ep(ide,ime)
         gndout(3)= gnd-gnd_ep(ide,ime)
         endif
         sigmat=sigt	!store sigma(T0) for use in vector of sigma(T)
	if (l_ms)then
c Play it again, Ken Campbell, to compute the mean spectrum. New Oct 29 2010.
	do jp=1,npnga
c The below conditional says, compute if coeffs are available at the period with index jp. This
c will generally be true for the NGA-W relations but less so for older GMPEs with fewer periods.
c  
	j=imsp(ia,jp)
        if ( jp .eq. jms)then
c use the available information. May have to add epsilon0*sigma_t.
        meanspec(jp)=gndout(1)
        sigspec(jp)=sigmat
	elseif (lmsp(ia,jp)) then
            tausq=tlny(j)**2
            sigsq=slny(j)**2
            sigsqu=sigsq
            sigt = sqrt(tausq + sigsq)
	   f1=c0(j)+c1(j)*amag
           vsrk=vscap/k1(j)
           if(amag.gt.5.5)f1=f1+c2(j)*(amag-5.5)
           if(amag.gt.6.5)f1=f1+c3(j)*(amag-6.5)
           f2=(c4(j)+c5(j)*amag)*0.5*alog(rrup*rrup+c6(j)*c6(j))
           f3=0.0
           f4=0.0
c f3 dependence on source mechanism; f4 hanging-wall dependence N&R both
      if(rev)then      !less precise but corresponds to current classification
             if(H.gt.1.0)then
               f3=c7(j)
             else
               f3=c7(j)*H
             endif
         elseif(normal)then      !less precise but corresponds to current classification
             f3=c8(j)
         endif      !reverse or normal slip. Hangingwall can be on for normal too.
             if(amag.gt.6.0.and.H.lt.20.0)then
c the hanging wall calcs from above should still work. Erased those steps here.
             f4=c9(j)*fhw*cbhwfac*(20.0-H)*0.05      
c cbhwfac new july 2006, computed in main
               if(amag.lt.6.5)f4=f4*(amag-6.0)*2.0
             endif
c f6 = Shallow sediment thickness dependence:
c Null depth effect for 1<d<3. 
           f6=0.0
           if(d.lt.1.0)then
             f6=c11(j)*(d-1.0)
           elseif(d.gt.3.0)then
             f6=c12(j)*k3(j)*f6fac
           endif
           if(vsrk.lt.1.0)then
             csfac=cs*vsrk**cn
c csfac is period dependent. Pgar was previously computed.
             f5=c10(j)*alog(vsrk)
     +            +k2(j)*alog((pgar+csfac)/(pgar+cs))
c the below sigma calculations  these
c  will be needed in the mean spectrum. x of epsilon.
c
c additional alpha term CB eqn (17) Sept 1 2006, in sigma computation
c need spgasq=spga**2 & tpgasq=tpga**2. Use the sigma(1) & tau(1). 
c these are conveniently defined in a statement to save calculations.
            alpha=k2(j)*pgar*(1./(pgar+csfac)-1./(pgar+cs))
            alfsq=alpha*alpha 
c tau no dependency on soil nonlinearity in the CB EQ Spectra article, see. eqn (14) & eqn (16)
c sln_Ab sigma of pga at base of site profile. see "doc" Eq Spectra paper, p 13 midway thru. does not change
c from earlier. do not recompute.
c      	
      	sln_yb= sqrt(slny(j)**2 - slnAFsq)
c sln_yb is sigma for spectral period j at base of soil column. Campbell corr.
c Nov 30 2007
      	sigsq=sigsqu +alfsq*sln_Ab**2+2.*alpha*rhos(j)*sln_Ab*sln_yb
c nonlinear motion-dependent sigma, but no motion-dependent tau.
           sigspec(jp) = sqrt(tausq + sigsq)	
            else
             alpha=0.
             f5=(c10(j)+k2(j)*cn)*alog(vsrk)
             sigspec(jp) = sigt
           endif
           meanspec(jp)=f1+f2+f3+f4+f5+f6
        endif	!if (lmsp(jp) )
	enddo	!21 periods and their ground motions. 
	endif	!if(l_ms)
        return
      end subroutine getCampNGA0308

      subroutine getAB06(ip,ir,xmag0,dist0,gndout,sigma,sigmaf,v30)
c Atkinson and Boore BSSA 2006. A CEUS relation
c      input:
c ip = period index in the arrays that follow of requested period.
c ir=1 or 3 use BC model. 3 for 200bar
c ir=2 or 4 use hardrock model. 4 for 200bar.
c if stress value is greater than 140 bars, change the numerator of stressfac to this value.
c if stress value is less than 140 bars, there is a net reduction in gnd
c Stress is not currently an input variable, hardwired to 200 bars.
c modified from version written by Oliver Boyd. Steve Harmsen Nov 13 2006. A Frankel feb 13
c the stress-factor was corrected in a BSSA erratum, June 2007, p 1032. This repair was made
c to this code, June 11, 2007. Steve Harmsen.
c different sets of coeffs for hardrock (ir=2&4) and bc rock (ir<2). 
c Change Mar 17 2008: AB06 doc says to use
c the hardrock coeffs if Vs30 >= 2000. However, the Nehrp A begins at 1520 m/s or so, and A usually
c corresponds to hard rock. You will get the hard rock if Vs30>=2000 in input file. 
c 
c   near-source terms not used here.
c xmag0 = moment M
c dist0 = src-station Rcd (km)
c v30==site vs30 (m/s)
c Output:
c       gndout: a 3-component vector, component1 is central gnd. Others are not used
c       for CEUS PSHA in most cases.
c        sigma = model sigma,
c       sigmaf = sigma factor used in prob calcs
      parameter (np=26)
      parameter (sqrt2=1.414213562,stressfac=0.5146)      !stressfac =alog10(200./140.)/alog10(2.)
      parameter (gfac=6.8875526,sfac=2.3025851,tfac=-0.5108256)      !log(980),ln(10),
c  and ln(60/100), resp.
      parameter (fac70=1.8450980,fac140=2.1461280,facv1=-0.5108256,facv2=-0.9295360)      
c  log10(70),log10(140),ln(v1/v2),ln(v2/vref),resp
        parameter (vref = 760., v1 = 180., v2 = 300.)      !for siteamp calcs
      common/epistemic/l_gnd_ep,gnd_ep,ide,ime
      common/hardrock/hardrock
      common/ms/ia,jms,npnga,l_ms,lmsp,imsp,meanspec,sigspec
      real gnd_ep(3,3),gndout(3)
      logical l_gnd_ep,hardrock	!scalar apr 2011
      integer imsp(8,21)
      integer i,j,k,ia
      logical l_ms,lmsp(0:10,21)
      real, dimension (21) :: meanspec,sigspec
      real f0,f1,f2,R,M,bnl,S
c del,m1, and mh are arrays associated with variable stress drop model. Add feb16 2007
      real,dimension(np):: Frq,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,bln,b1,b2,del,m1,mh
c the frequencies according to AB2006. some interpolated to the cms standard set
      Frq = (/2.00e-01,2.50e-01,3.33e-01,4.00e-01,5.00e-01,6.66e-01,8.00e-01,1.00e+00,
     1       1.333e+00,1.59e+00,2.00e+00,2.52e+00,3.17e+00,3.99e+00,5.03e+00,6.33e+00,
     1       7.97e+00,1.00e+01,1.26e+01,1.59e+01,2.00e+01,2.52e+01,3.18e+01,4.00e+01,
     1       0.00e+00,-1.00e+00/)
c frequency - independent sigma
      sigma = 0.3*sfac
      sigmaf = 1./sqrt2/sigma
        if (ir.eq.2.or.ir.eq.4) then
c hr coefficients
        c1 = (/-5.41e+00,-5.79e+00,-6.0638,-6.17e+00,-6.18e+00,-5.9642,-5.72e+00,
     1        -5.27e+00,-4.4345,-3.92e+00,-3.22e+00,-2.44e+00,-1.72e+00,-1.12e+00,
     1        -6.15e-01,-1.46e-01,2.14e-01,4.80e-01,6.91e-01,9.11e-01,1.11e+00,1.26e+00,
     1        1.44e+00,1.52e+00,9.07e-01,-1.44e+00/)
        c2 = (/1.71e+00,1.92e+00,2.1038,2.21e+00,2.30e+00,2.34e+00,2.3353,2.26e+00,
     1        2.0959,2.13e+00,1.83e+00,1.65e+00,1.48e+00,1.34e+00,1.23e+00,1.12e+00,
     1        1.05e+00,1.02e+00,9.97e-01,9.80e-01,9.72e-01,9.68e-01,9.59e-01,9.60e-01,
     1        9.83e-01,9.91e-01/)
        c3 = (/-9.01e-02,-1.07e-01,-1.2438e-01,-1.35e-01,-1.44e-01,-1.5024E-01,-1.51e-01,
     1        -1.48e-01,-1.3857E-01,-1.31e-01,-1.20e-01,-1.08e-01,-9.74e-02,-8.72e-02,
     1        -7.89e-02,-7.14e-02,-6.66e-02,-6.40e-02,-6.28e-02,-6.21e-02,-6.20e-02,
     1        -6.23e-02,-6.28e-02,-6.35e-02,-6.60e-02,-5.85e-02/)
        c4 = (/-2.54e+00,-2.44e+00,-2.3572,-2.30e+00,-2.22e+00,-2.1458,-2.10e+00,
     1        -2.07e+00,-2.057,-2.05e+00,-2.02e+00,-2.05e+00,-2.08e+00,-2.08e+00,
     1        -2.09e+00,-2.12e+00,-2.15e+00,-2.20e+00,-2.26e+00,-2.36e+00,-2.47e+00,
     1        -2.58e+00,-2.71e+00,-2.81e+00,-2.70e+00,-2.70e+00/)
        c5 = (/2.27e-01,2.11e-01,1.8880e-01,1.90e-01,1.77e-01,1.66e-01,1.5611E-01,1.50e-01,
     1        1.3478E-01,1.47e-01,1.34e-01,1.36e-01,1.38e-01,1.35e-01,1.31e-01,1.30e-01,
     1        1.30e-01,1.27e-01,1.25e-01,1.26e-01,1.28e-01,1.32e-01,1.40e-01,1.46e-01,
     1        1.59e-01,2.16e-01/)
        c6 = (/-1.27e+00,-1.16e+00,-1.1854,-9.86e-01,-9.37e-01,-9.4350,-8.20e-01,
     1        -8.13e-01,-7.97e-01,-7.82e-01,-8.13e-01,-8.43e-01,-8.89e-01,-9.71e-01,
     1        -1.12e+00,-8.5411E-01,-1.61e+00,-2.01e+00,-2.49e+00,-2.97e+00,-3.39e+00,
     1        -3.64e+00,-3.73e+00,-3.65e+00,-2.80e+00,-2.44e+00/)
        c7 = (/1.16e-01,1.02e-01,1.0733E-01,7.86e-02,7.07e-02,6.05e-02,6.5303E-02,4.67e-02,
     1        4.9411E-02,4.35e-02,4.44e-02,4.48e-02,4.87e-02,5.63e-02,6.79e-02,8.31e-02,
     1        1.05e-01,1.33e-01,1.64e-01,1.91e-01,2.14e-01,2.28e-01,2.34e-01,2.36e-01,
     1        2.12e-01,2.66e-01/)
        c8 = (/9.79e-01,1.01e+00,8.5342E-01,9.68e-01,9.52e-01,9.21e-01,8.5611E-01,8.26e-01,
     1        7.75e-01,7.0046e-01,8.84e-01,7.39e-01,6.10e-01,6.14e-01,6.06e-01,5.62e-01,
     1        4.27e-01,3.37e-01,2.14e-01,1.07e-01,-1.39e-01,-3.51e-01,-5.43e-01,-6.54e-01,
     1        -3.01e-01,8.48e-02/)
        c9 = (/-1.77e-01,-1.82e-01,-1.734e-01,-1.77e-01,-1.77e-01,-1.773e-01,-1.66e-01,
     1        -1.62e-01,-1.5827e-01,-1.59e-01,-1.75e-01,-1.56e-01,-1.39e-01,-1.43e-01,
     1        -1.46e-01,-1.44e-01,-1.30e-01,-1.27e-01,-1.21e-01,-1.17e-01,-9.84e-02,
     1        -8.13e-02,-6.45e-02,-5.50e-02,-6.53e-02,-6.93e-02/)
        c10 = (/-1.76e-04,-2.01e-04,-2.4774E-04,-2.82e-04,-3.22e-04,-3.5816E-04,-4.33e-04,
     1        -4.86e-04,-5.9958e-04,-6.95e-04,-7.70e-04,-8.51e-04,-9.54e-04,-1.06e-03,
     1        -1.13e-03,-1.18e-03,-1.15e-03,-1.05e-03,-8.47e-04,-5.79e-04,-3.17e-04,
     1        -1.23e-04,-3.23e-05,-4.85e-05,-4.48e-04,-3.73e-04/)
        else
c bc coefficients from AB06. Frankel corrected these feb 13. SH
        c1 = (/-4.85e+00,-5.26e+00,-6.0638,-5.80e+00,-5.85e+00,-5.9642,-5.49e+00,
     1         -5.06e+00,-4.4345,-3.75e+00,-3.01e+00,-2.28e+00,-1.56e+00,-8.76e-01,
     1         -3.06e-01,1.19e-01,5.36e-01,7.82e-01,9.67e-01,1.11e+00,1.21e+00,1.26e+00,
     1         1.19e+00,1.05e+00,5.23e-01,-1.66e+00/)
        c2 = (/1.58e+00,1.79e+00,2.1038,2.13e+00,2.23e+00,2.29e+00,2.3353,2.23e+00,
     1        2.0959,2.12e+00, 1.80e+00,1.63e+00,1.46e+00,1.29e+00,1.16e+00,1.06e+00,
     1        9.65e-01,9.24e-01,9.03e-01,8.88e-01,8.83e-01,8.79e-01,8.88e-01,9.03e-01,
     1        9.69e-01,1.05e+00/)
        c3 = (/-8.07e-02,-9.79e-02,-1.2438E-01,-1.28e-01,-1.39e-01,-1.502e-01,-1.48e-01,
     1        -1.45e-01,-1.3857E-01,-1.29e-01,-1.18e-01,-1.05e-01,-9.31e-02,-8.19e-02,
     1        -7.21e-02,-6.47e-02,-5.84e-02,-5.56e-02,-5.48e-02,-5.39e-02,-5.44e-02,
     1        -5.52e-02,-5.64e-02,-5.77e-02,-6.20e-02,-6.04e-02/)
        c4 = (/-2.53e+00,-2.44e+00,-2.357e+00,-2.26e+00,-2.20e+00,-2.1458,-2.08e+00,
     1        -2.03e+00,-2.0576,-2.00e+00,-1.98e+00,-1.97e+00,-1.98e+00,-2.01e+00,
     1        -2.04e+00,-2.05e+00,-2.11e+00,-2.17e+00,-2.25e+00,-2.33e+00,-2.44e+00,
     1        -2.54e+00,-2.58e+00,-2.3572E+00,-2.44e+00,-2.50e+00/)
        c5 = (/2.22e-01,2.07e-01,1.888e-01,1.79e-01,1.69e-01,1.58e-01,1.5611e-01,1.41e-01,
     1        1.3478E-01,1.36e-01,1.27e-01,1.23e-01,1.21e-01,1.23e-01,1.22e-01,1.19e-01,
     1        1.21e-01,1.19e-01,1.22e-01,1.23e-01,1.30e-01,1.39e-01,1.45e-01,1.48e-01,
     1        1.47e-01,1.84e-01/)
        c6 = (/-1.43e+00,-1.31e+00,-1.1854,-1.12e+00,-1.04e+00,-9.435e-01,-9.00e-01,
     1        -8.74e-01,-8.5411e-01,-8.42e-01,-8.47e-01,-8.88e-01,-9.47e-01,-1.03e+00,
     1        -1.15e+00,-1.36e+00,-1.67e+00,-2.10e+00,-2.53e+00,-2.88e+00,-3.04e+00,
     1        -2.99e+00,-2.84e+00,-2.65e+00,-2.34e+00,-2.30e+00/)
        c7 = (/1.36e-01,1.21e-01,1.0733E-01,9.54e-02,8.00e-02,6.76e-02,6.5303e-02,5.41e-02,
     1        4.9411e-02,4.98e-02,4.70e-02,5.03e-02,5.58e-02,6.34e-02,7.38e-02,9.16e-02,
     1        1.16e-01,1.48e-01,1.78e-01,2.01e-01,2.13e-01,2.16e-01,2.12e-01,2.07e-01,
     1        1.91e-01,2.50e-01/)
        c8 = (/6.34e-01,7.34e-01,8.5342E-01,8.91e-01,8.67e-01,8.67e-01,8.5611e-01,7.92e-01,
     1        7.0046e-01,7.08e-01,6.67e-01,6.84e-01,6.50e-01,5.81e-01,5.08e-01,5.16e-01,
     1        3.43e-01,2.85e-01,1.00e-01,-3.19e-02,-2.10e-01,-3.91e-01,-4.37e-01,-4.08e-01,
     1        -8.70e-02,1.27e-01/)
        c9 = (/-1.41e-01,-1.56e-01,-1.7346E-01,-1.80e-01,-1.79e-01,-1.7734e-01,-1.72e-01,
     1        -1.70e-01,-1.5827E-01,-1.56e-01,-1.55e-01,-1.58e-01,-1.56e-01,-1.49e-01,
     1        -1.43e-01,-1.50e-01,-1.32e-01,-1.32e-01,-1.15e-01,-1.07e-01,-9.00e-02,
     1        -6.75e-02,-5.87e-02,-5.77e-02,-8.29e-02,-8.70e-02/)
        c10 = (/-1.61e-04,-1.96e-04,-2.4774E-04,-2.60e-04,-2.86e-04,-3.5816e-04,-4.07e-04,
     1        -4.89e-04,-5.9958e-04,-6.76e-04,-7.68e-04,-8.59e-04,-9.55e-04,-1.05e-03,
     1        -1.14e-03,-1.18e-03,-1.13e-03,-9.90e-04,-7.72e-04,-5.48e-04,-4.15e-04,
     1        -3.88e-04,-4.33e-04,-5.12e-04,-6.30e-04,-4.27e-04/)
      endif
c Soil amplification some adjustments for interpolated periods
c Soil amplification
      bln = (/-7.52e-01,-7.45e-01,-7.3909E-01,-7.35e-01,-7.30e-01,-7.2363e-01,-7.16e-01,
     1        -7.00e-01,-6.8513E-01,-6.70e-01,-6.00e-01,-5.00e-01,-4.45e-01,-3.90e-01,
     1        -3.06e-01,-2.80e-01,-2.60e-01,-2.50e-01,-2.32e-01,-2.49e-01,-2.86e-01,
     1        -3.14e-01,-3.22e-01,-3.30e-01,-3.61e-01,-6.00e-01/)
      b1 = (/-3.00e-01,-3.10e-01,-3.3402e-01,-3.52e-01,-3.75e-01,-3.8198e-01,-3.40e-01,
     1        -4.40e-01,-4.6865E-01,-4.80e-01,-4.95e-01,-5.08e-01,-5.13e-01,-5.18e-01,
     1        -5.21e-01,-5.28e-01,-5.60e-01,-5.95e-01,-6.37e-01,-6.42e-01,-6.43e-01,
     1        -6.09e-01,-6.18e-01,-6.24e-01,-6.41e-01,-4.95e-01/)
      b2 = (/0.00e+00,0.00e+00,0.00e+00,0.00e+00,0.00e+00,0.00e+00,0.00e+00,0.00e+00,
     1        -2.00e-03,-9.0567E-03,-6.00e-02,-9.50e-02,-1.30e-01,-1.60e-01,-1.85e-01,
     1        -1.85e-01,-1.40e-01,-1.32e-01,-1.17e-01,-1.05e-01,-1.05e-01,-1.05e-01,
     1        -1.08e-01,-1.15e-01,-1.44e-01,-6.00e-02/)
	del=(/0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,
     1 0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.11/)
     	m1=(/6.,5.75,5.454,5.25,5.,4.80,4.67,4.5,4.299,4.17,4.,3.65,3.3,2.9,2.5,1.85,1.15,0.5,
     1 0.34,0.17,0.,0.,0.,0.,0.5,2.0/)
       mh=(/8.5,8.37,8.226,8.12,8.,7.64,7.45,7.2,6.889,6.7,6.5,6.37,6.25,6.12,6.0,5.84,
     1 5.67,5.5,5.34,5.17,5.0,5.0,5.0,5.0,5.5,5.5/)
      if(ir.gt.2)then
       diff=max(xmag0-m1(ip),0.)
c sf2 is supposed to be eqn(6) of AB06 paper.
       sf2=stressfac*min( del(ip)+0.05, 0.05+del(ip)*diff/(mh(ip)-m1(ip)))
c       write(6,*)diff,sf2,ir,ip,iper,dist0,' diff sf2 ir ip iper dist0'
       else
       sf2=0.0
       endif
      M = xmag0
c R: I put a lower limit of 5 km SH Nov 2006. For near-surface faults singularity is possible
c There is some evidence of big motion above near-surface rupture: Mogul NV 2010 M5 PGA>1g. Top of flt 1km
c
      R = max(5.0,dist0)
      rfac=alog10(R)
      f0 = max(1.-rfac,0.)
      f1 = min(rfac,fac70)
      f2 = max(rfac-fac140,0.)
      if(v30.gt.0.) then
c compute pga on rock, save it for  mean spectrum computations. New Oct 2010.
        gndp = c1(25) + c2(25)*M + c3(25)*M*M + (c4(25)+c5(25)*M)*f1 +
     1        (c6(25)+c7(25)*M)*f2 + (c8(25)+c9(25)*M)*f0 + c10(25)*R + sf2
        gndp = 10**gndp
c apply stress factor before nonlinear adjustments, which occur in eqn (7) of ab paper.
c Fortran "log" is natural log. log(10.)=2.3025. Is this intended?
        if(v30.le.v1) then
          bnl = b1(ip);
        elseif(v30.le.v2) then
          bnl = (b1(ip) - b2(ip))*log(v30/v2)/facv1 + b1(ip);
        elseif(v30.le.vref) then
          bnl = b2(ip)*log(v30/vref)/facv2
        else
          bnl = 0.;
        endif
        if(ir.eq.2.or.ir.eq.4)then
         S=0.      	!hard rock no site term
        elseif(gndp.le.60.) then
          S = bln(ip)*log(v30/vref) + bnl*tfac
        else
        gpfac=log(gndp/100.)
          S = bln(ip)*log(v30/vref) + bnl*gpfac
        endif
c need to take alog10(exp(S)) according to eqns. 7a and 7b AB2006. p. 2200 bssa
c This correction does not affect rock at BC boundary, but does affect soil calcs.
      S = alog10(exp(S))		!new nov 26 2007.
      endif
      gnd = c1(ip) + c2(ip)*M + c3(ip)*M*M + (c4(ip)+c5(ip)*M)*f1 +
     1      (c6(ip)+c7(ip)*M)*f2 + (c8(ip)+c9(ip)*M)*f0 + c10(ip)*R +sf2 + S
      if (ip.lt.26) then
        gnd = gnd*sfac - gfac
      else
c pgv?
        gnd = gnd*sfac
      endif
          if(Frq(ip).eq.0.) then
c  limit pga median to 1.5 g; 5hz to 3 g. 2006.
           gnd=min(gnd,0.405)
          elseif(Frq(ip).gt.2.1.and.Frq(ip).lt.50.)then
           gnd=min(1.099,gnd)
          endif
       gndout(1)=gnd
c We don't plan to include extra gnd uncert for CEUS models but this is permitted in AB06 and others.
         if(l_gnd_ep)then
         gndout(2)= gnd+gnd_ep(ide,ime)
         gndout(3)= gnd-gnd_ep(ide,ime)
         endif
	if(.not.l_ms)return
c Play it again, Gail A, for the conditional mean spectrum
	do j=1,17	!dont go above 3s for CEUS.
	if(lmsp(ia,j)) then
c computable period, not the same as average CEUS set. Walt has a few more periods.
        sigspec(j)=sigma
       	k=imsp(ia,j)
c       	print *,ia,k,j,gnd,lmsp(ia,j),'ia k j gnd lmsp(ia,j) Gail'
c       	if(k.eq.0)print *,j,gnd,' Gail subroutine k is 0'
        if ( j .eq. jms) then
c use the available information. May have to add epsilon0*sigma_t.
c k_msab is ab06 index for input period
        meanspec(j)=gndout(1)

	else
c not yet computed period.
      if(ir.gt.2)then
       diff=max(xmag0-m1(k),0.)
c sf2 is supposed to be eqn(6) of AB06 paper.
       sf2=stressfac*min( del(k)+0.05, 0.05+del(k)*diff/(mh(k)-m1(k)))
c       write(6,*)diff,sf2,ir,ip,iper,dist0,' diff sf2 ir ip iper dist0'
       else
       sf2=0.0
       endif
c apply stress factor before nonlinear adjustments, which occur in eqn (7) of ab paper.
c Fortran "log" is natural log. log(10.)=2.3025. Is this intended?
        if(v30.le.v1) then
          bnl = b1(k);
        elseif(v30.le.v2) then
          bnl = (b1(k) - b2(k))*log(v30/v2)/facv1 + b1(k);
        elseif(v30.le.vref) then
          bnl = b2(k)*log(v30/vref)/facv2
        else
          bnl = 0.;
        endif
        if(ir.eq.2.or.ir.eq.4)then
         S=0.      	!hard rock no site term
        elseif(gndp.le.60.) then
          S = bln(k)*log(v30/vref) + bnl*tfac
        else
          S = bln(k)*log(v30/vref) + bnl*gpfac
        endif
c need to take alog10(exp(S)) according to eqns. 7a and 7b AB2006. p. 2200 bssa
c This correction does not affect rock at BC boundary, but does affect soil calcs.
      S = alog10(exp(S))		!new nov 26 2007.
      gnd = c1(k) + c2(k)*M + c3(k)*M*M + (c4(k)+c5(k)*M)*f1 +
     1      (c6(k)+c7(k)*M)*f2 + (c8(k)+c9(k)*M)*f0 + c10(k)*R +sf2 + S
        gnd = gnd*sfac - gfac
          if(Frq(k).eq.0.) then
c  limit pga median to 1.5 g; 5hz to 3 g. 2006.
           gnd=min(gnd,0.405)
          elseif(Frq(k).gt.2.1.and.Frq(k).lt.50.)then
           gnd=min(1.099,gnd)
          endif
	meanspec(j)=gnd
	endif	!already computed or not?
	endif	!computable period?
	enddo	!loop thru nga periods
      return
      end subroutine getAB06

      subroutine getTP05(ip,ir,xmag0,dist0,gndout,sigma,sigmaf)
c Added getTP05, Oliver Boyd
c ip = index of period in Pd array and other coeff arrays.
c for what range of vs30 is this one supposed to be valid? SH nov 13 2006
c ir seems to have a hard-rock, firm-rock feature
c clamp on median motion added dec 7 2007
c Update: compute mean spectrum when l_ms = .true.: add option Oct 28 2010
      parameter (np=16,sqrt2=1.414213562)
      common/epistemic/l_gnd_ep,gnd_ep,ide,ime
      common/ms/ia,jms,npnga,l_ms,lmsp,imsp,meanspec,sigspec
      common/ms2/icu_2_nga(7),k_ms,k_mss,k_mst
c k_mst is the period index in nga set of current period.
      logical l_ms,lmsp(0:10,21)
      integer imsp(8,21)
      real, dimension (21) :: meanspec,sigspec	!fill this if l_ms = .true.
      real gnd_ep(3,3),gndout(3)
      logical l_gnd_ep	!scalar apr 2011
c median limits are applied in main, not in subroutines.
      real f1,f2,f3,R,Rrup,M,cor
      real,dimension(np):: Pd,c1,c1h,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16
      Pd = (/0.00e+00, 0.04, 0.05,8.00e-02,1.00e-01,1.50e-01,2.00e-01,3.00e-01,
     1 0.40,0.50,
     1       7.50e-01,1.0, 1.50, 2.0, 3.0, 4.0/)
      c1h = (/1.14e+00,2.2217764,1.82e+00,6.83e-01,8.69e-01,2.38e+00,-5.48e-01,-5.13e-01,
     1 0.18295555,
     1       2.40e-01,-6.79e-01,-1.55e+00,-2.30e+00,-2.70e+00,-2.42e+00,-3.69e+00/)
c c1 below is based on a CEUS A->BC conversion from c1h where c1h Vs30 is ? and c1 is ?. 
c Use of earlier models of siteamp for ceus. So for all periods we use Fr. 1996 terms.
c c1 modified at 0.1, 0.3, 0.5, and 2.0 s for Frankel ceus amp. mar 19 2007.
c c1 checked for pga, 1hz and 5hz apr 17 2007. c1(0.4s) added June 30. cor c1(0.3) oct 13
c 2009 from K Campbell email.
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
c c8 and all other coeffs at 2.5 hz use cubic spline interpolations. See intTP05 code. 
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
      M = xmag0
	xmfac = (8.5 - M)**2.5
      Rrup = dist0
      if (M.lt.7.2) then
        sigma = c14(ip) + c15(ip)*M 
      else
        sigma = c16(ip)
      endif
      sigmaf = 1./sqrt2/sigma
      if (ir.lt.0) then
        f1 = c1h(ip) + c2(ip)*M + c3(ip)*xmfac
      else
        f1 = c1(ip) + c2(ip)*M + c3(ip)*xmfac
      endif
      rfac = log(Rrup + 4.5)
      f2 = c9(ip)*rfac
      if (Rrup.gt.70.) f2 = f2 + c10(ip)*log(Rrup/70.)
      if (Rrup.gt.130.) f2 = f2 + c11(ip)*log(Rrup/130.)
      cor = exp(c6(ip)*M + c7(ip)*xmfac)
      R = sqrt(Rrup*Rrup + c5(ip)*c5(ip)*cor*cor)
      f3 = (c4(ip) + c13(ip)*M)*log(R) + (c8(ip) + c12(ip)*M)*R
      gnd = f1 + f2 + f3
c---following is for clipping gnd motions: 1.5g PGA, 3.0g for T<0.5 s (2hz)
c this clamp was omitted until dec 7 2007. 
          if(pd(ip).lt.0.02) then
c 1.5 g is the PGA  limit (g). SH June 2006.
           gnd=min(gnd,0.405)
          elseif(pd(ip).lt.0.5)then
           gnd=min(1.099,gnd)
          endif
       gndout(1)=gnd
         if(l_gnd_ep)then
         gndout(2)= gnd+gnd_ep(ide,ime)
         gndout(3)= gnd-gnd_ep(ide,ime)
         endif
c      write(6,*) gnd,sigmaf,M,R,S,ip
	if(.not.l_ms)return
c Play it again, Tav&Pez, for the conditional mean spectrum
	do j=1,npnga
	if(lmsp(ia,j)) then
c computable period, not the same as average CEUS set. Walt has a few more periods.
	k=imsp(ia,j)
	if(k.eq.0)print *,'TP05 ',ia,j,lmsp(ia,j),imsp(ia,j),jms
        if ( j .eq. jms) then
c use the available information. May have to add epsilon0*sigma_t.
c k_mst is TP05 index for input period
        meanspec(j)=gndout(1)
        sigspec(j)=sigma
	else
      if (M.lt.7.2) then
        sigspec(j) = c14(k) + c15(k)*M 
      else
        sigspec(j) = c16(k)
      endif
      if (ir.lt.0) then
        f1 = c1h(k) + c2(k)*M + c3(k)*xmfac
      else
        f1 = c1(k) + c2(k)*M + c3(k)*xmfac
      endif
      f2 = c9(k)*rfac
      if (Rrup.gt.70.) f2 = f2 + c10(k)*log(Rrup/70.)
      if (Rrup.gt.130.) f2 = f2 + c11(k)*log(Rrup/130.)
      cor = exp(c6(k)*M + c7(k)*xmfac)
      R = sqrt(Rrup*Rrup + c5(k)*c5(k)*cor*cor)
      f3 = (c4(k) + c13(k)*M)*log(R) + (c8(k) + c12(k)*M)*R
      gnd = f1 + f2 + f3
c---following is for clipping gnd motions: 1.5g PGA, 3.0g for T<0.5 s (2hz)
c this clamp was omitted until dec 7 2007. 
          if(pd(k).lt.0.02) then
c 1.5 g is the PGA  limit (g). SH June 2006.
           gnd=min(gnd,0.405)
          elseif(pd(k).lt.0.5)then
           gnd=min(1.099,gnd)
          endif
          meanspec(j)=gnd
          endif	! k = k_mst?
          endif	!computable period
          enddo	!loop thru periods for CMS
      return
      end subroutine getTP05

      subroutine kanno(iper,ip,gndout,sigmaf,amag,rrup,vsfac)
c....................................................................
c  Kanno et al. regression relation, 2006 for shallow earthquakes
c  written by Yuehua Zeng, USGS. Mods Steve Harmsen Nov 7 2006.
c
c  input: per  : period
c         amag : magnitude
c         rrup : closest fault distance
c         vsfac   : log 10 of site S-velocity in m/s
c
c  output: gnd   : ground motion spectral values (ln) (g). to be consistent
c
c          sigmaf : 1/sigma/sqrt2 errors in ln. the sigma factor.
c....................................................................
      parameter (gfac=6.8875526,sfac=2.3025851,sqrt2=1.414213562)
c conversion factors gfac cm/s/s to g, sfac log10 to ln.
      common/epistemic/l_gnd_ep,gnd_ep,ide,ime
       real gnd_ep(3,3),gndout(3)
       logical l_gnd_ep	!scalar apr 2011

      real, dimension (37) :: T,a1,b1,c1,d1,e1,p,q
        real sigma,sigmaf,gnd,vsfac
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
      p= (/-0.32,-0.26,-0.24,-0.26,-0.29,-0.32,-0.35,-0.39,-0.43,-0.53,-0.61,
     + -0.68,-0.72,-0.75,-0.80,-0.85,-0.87,-0.89,-0.91,-0.92,-0.96,-0.98,
     + -0.97,-0.93,-0.92,-0.91,-0.88,-0.85,-0.83,-0.78,-0.76,-0.72,-0.68,
     + -0.66,-0.62,-0.60,-0.59/)
      q= (/0.80,0.65,0.60,0.64,0.72,0.78,0.84,0.94,1.04,1.28,1.47,1.65,1.74,
     + 1.82,1.96,2.09,2.13,2.18,2.25,2.30,2.41,2.46,2.44,2.32,2.30,2.26,
     + 2.20,2.12,2.06,1.92,1.88,1.80,1.70,1.64,1.54,1.50,1.46/)
c
      if(ip.eq.0)then
       gnd=0.56*amag-0.0031*rrup-alog10(rrup+0.0055*10**(0.5*amag))
     +        +0.26-0.55*vsfac+1.35
        sigma=0.37*sfac
        else
       gnd=a1(ip)*amag+b1(ip)*rrup-alog10(rrup+d1(ip)*10**(0.5*amag))
     +        +c1(ip)+p(ip)*vsfac+q(ip)
       sigma=e1(ip)*sfac
       endif
       gnd=sfac*gnd-gfac
       gndout(1)=gnd
         if(l_gnd_ep)then
         gndout(2)= gnd+gnd_ep(ide,ime)
         gndout(3)= gnd-gnd_ep(ide,ime)
         endif
       sigmaf=1.0/sigma/sqrt2
      return
      end subroutine kanno

        subroutine SomerIMW(ip,iprd, xmag,R_Rup,rjb,V_S30,gndout,sigmaf)
c Somerville et al prepared this model for USGS from finite-fault gm simulations.
c Coding by Stephen Harmsen. This model was designed for fault hazard in
c intermtn west. Should not be used in compressional regimes.
        integer mxnprd
        parameter (mxnprd=5)
      parameter (pi=3.14159265,sqrt2=1.414213562)
      parameter(Hsq = 42.25)      !H=6.5 in Somerville document
      common/mech/ss,rev,normal,obl
c Outputs gnd=ln(median) and sigmaf, two scalar quantities needed for Pex calcs.
c To DO: Find out if we want to include a site_amp feature with this subroutine
c Predictor variables, xmag = moment mag, R_Rup=nearest distance to the 
c fault plane (rupture surface), and rjb=joyner-boore dist. 
c Model requires no dip, no depth to top information. Hmm.
      common/epistemic/l_gnd_ep,gnd_ep,ide,ime
      real gnd_ep(3,3),gndout(3)
      logical l_gnd_ep	!scalar apr 2011

        real  xmag, Width, R_rup,  V_S30, rjb, hw,gnd
      logical ss,rev,normal,obl
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
      rc=sqrt(R_rup**2+Hsq)
      alogR=alog(rc)
      gnd=c1(iprd)+c2(iprd)*xmag+(c3(iprd)+c4(iprd)*xmag)*alogR
      gnd=gnd+c5(iprd)*R_rup+c6(iprd)*(8.5-xmag)**2
      sigma=sigma_t(iprd)
       gndout(1)=gnd
         if(l_gnd_ep)then
         gndout(2)= gnd+gnd_ep(ide,ime)
         gndout(3)= gnd-gnd_ep(ide,ime)
         endif
       sigmaf=1.0/sigma/sqrt2
c if strike slip or fw, do not include hanging wall effects.
      if(ss.or.rjb.gt.0.5.or.R_Rup.ge.20.)return
c Otherwise boost median with hanging wall term. may need to taper off edges      
      if(R_Rup.lt.5.)then
      hw=0.2*R_Rup
      elseif(R_Rup.lt.15.)then
      hw=1.0
      else
      hw=1.0-(R_Rup-15.0)/5.
      endif
      gnd=gnd+c7(iprd)*hw*(8.5-xmag)
       gndout(1)=gnd
         if(l_gnd_ep)then
         gndout(2)= gnd+gnd_ep(ide,ime)
         gndout(3)= gnd-gnd_ep(ide,ime)
         endif
      return
      end subroutine SomerIMW

      subroutine getSilva(iq,ir,xmag,dist,gndout,sig,sigmaf)
c Inputs: xmag = moment mag, dist = rjb (km), see Nov 1, 2002 doc page 4
c iper = period index in iatten(ia) and elsewhere.
c iq is index in pd array for current spectral period, iq shuld be in 1 to 11 range.
c ir is hardrock (-1) or BCrock indicator (+1).
c Silva (2002) table 5, p. 13. Single corner, constant stress drop, w/saturation.
c parts of this subroutine are from frankel hazFXv7 code. S Harmsen
c Added 2.5 and 25 hz July 1 2008 (for NRC projects). Add 20 hz, or 0.05 s. july 6
c Note: PGV and several other periods are available in Silva Table 5. 
      parameter (sqrt2=1.414213562,npmx=11)
      common/epistemic/l_gnd_ep,gnd_ep,ide,ime
        real gnd_ep(3,3),gndout(3),c
        logical l_gnd_ep	!scalar apr 2011
      common/ms/ia,jms,npnga,l_ms,lmsp,imsp,meanspec,sigspec
      common/ms2/icu_2_nga(7),k_ms,k_mss,k_mst
      logical l_ms,lmsp(0:10,21)
      integer imsp(8,21)
	real, dimension(21):: meanspec,sigspec
      real, dimension(npmx) :: c1,c1hr,c2,c3,c4,c5,c6,c7,c8,c9,c10,pd,sigma
	pd=(/0.,0.04,0.05,0.1,0.2,0.3,0.4,0.5,1.,2.,5./)
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
	sigma= (/.8471,0.8870,0.8753,0.8546,.8338,0.8428,0.8386,
     1 0.8484,.8785,1.0142,1.2253/)
        if(ir.ge.1)then
        c=c1(iq)
        else
        c=c1hr(iq)
        endif
        xmagfac=(xmag-6.0)**2
c formula (3) in Nov 1, 2002 doc
        gnd= c + c2(iq)*xmag+(c6(iq)+c7(iq)*xmag)*alog(dist+exp(c4(iq)))
     &  + c10(iq)*xmagfac  
c---following is for clipping gnd motions: 1.5g PGA, 3.0g for T<0.5 s (2hz)
c this clamp was omitted until dec 7 2007. 
          if(pd(iq).lt.0.02) then
c  the PGA  limit =1.5 g. SH June 2006.
           gnd=min(gnd,0.405)
          elseif(pd(iq).lt.0.5.and.pd(iq).gt. 0.02)then
c 2.5, 3 and 5 hz 10 Hz median limit 3.0 g
           gnd=min(1.099,gnd)
          endif
       gndout(1)=gnd
       if(l_gnd_ep)then
         gndout(2)= gnd+gnd_ep(ide,ime)
         gndout(3)= gnd-gnd_ep(ide,ime)
       endif
c--- return sigma and sigmaf for clipping 
      sig=sigma(iq)
      sigmaf= 1.0/(sig*sqrt2)
	if(.not.l_ms)return
c Play it again, Walt, for the conditional mean spectrum
	do j=1,npnga
	if(lmsp(ia,j)) then
c computable period, not the same as average CEUS set. Walt has a few more periods.
	k=imsp(ia,j)
        sigspec(j)=sigma(k)
        if ( k .eq. k_mss) then
c use the available information. May have to add epsilon0*sigma_t.
c k_mss is Silva index for input period
        meanspec(j)=gndout(1)
	else
        if(ir.ge.1)then
        c=c1(k)
        else
        c=c1hr(k)
        endif
c formula (3) in Nov 1, 2002 doc
        gnd= c + c2(k)*xmag+(c6(k)+c7(k)*xmag)*alog(dist+exp(c4(k)))
     &  + c10(k)*xmagfac  
c---following is for clipping gnd motions: 1.5g PGA, 3.0g for T<0.5 s (2hz)
c this clamp was omitted until dec 7 2007. 
          if(pd(k).lt.0.02) then
c  the PGA  limit =1.5 g. SH June 2006.
           gnd=min(gnd,0.405)
          elseif(pd(k).lt.0.5.and.pd(k).gt. 0.02)then
c 2.5, 3 and 5 hz 10 Hz median limit 3.0 g
           gnd=min(1.099,gnd)
          endif
          meanspec(j)=gnd
          endif	!k = k_mss?
	endif	!computable period for the Silva single-corner model.
	enddo	!nga periods
      return
      end subroutine getSilva



      subroutine resample(ift,npts,xlen,xaz,dip,depth0,nleny,
     + tlen,dlen,dlen2,npts1)
c this subroutine resamples fault trace to new 1km(?) discretization. It also
c determines downdip coordintes corresponding to those at top of fault.
c these downdip values will be used for buried ruptures with GR distribution.
c Inputs: ift = fault number
c      npts= number of points on discretized input fault
c      x(*,ift)=x -coord
c      y(*,ift)=y-coord (degrees)
c      xlen = segment length, computed in main
c      xaz = segment azimuth, computed in main.
c      dip = dip angle (radians) pi/2>=dip>0	!note units.
c       dip needs to be positive for proper function.
c      xxx width = fault width (not input, not needed here).
c      depth0 = depth of top of fault (km) (not needed here)
c      nleny = number of downdip tops (4 max) for computing fault contours, including top
c      tlen = flt length (km) already computed. Use this value
c      dlen = delta-length for horizontal sampling; probably 1 km
c      dlen2 = vertical distance between downdip contours; probably 2 km
c      width = fault width (km)
c Outputs:
c      npts1 = number of points on resampled fault's contour line
c      u(ix,iy,ift) = x-coord, resampled
c      v(ix,iy,ift) = y-coord, resampled. iy is depth index (1,2,3, maybe 4)
c      
      parameter (d2r=3.14159265/180.0,nfltmx=1000)
        real delta,depth0,dip,sinedip,cosdip,avaz,avbaz
        real, dimension(800) :: xaz, xlen
      real, dimension (800,nfltmx):: x,y
      real, dimension (990,4,nfltmx) :: u,v	!2nd dim is downdip 1=top, 2=down 2km,
       common/fault/x,y,u,v
c 3=down 4km. 4 = down 6 km (contour 4 first tried July 2007), 3rd dim fault index
      integer  npts,npts1
            nseg= npts - 1
      sinedip = sin(dip)
      cosdip= sqrt(1.-sinedip**2)
      if(abs(dip).gt.0.1)then
      ctgdip=cosdip/sinedip
      else
c Can code handle very shallow dipping faults? not with Plan A.
      ctgdip=3.0	!avoid sing
      endif
      n=npts
       call delaz(y(1,ift),x(1,ift),y(n,ift),x(n,ift),delta,avaz,avbaz)
       if(dip.gt.0.)then
       avdip=avaz+90.
       else
       avdip=avaz-90.
       endif
c       open(1,file='resamp.flt',status='unknown')
      nlenx=int((tlen+1.)/dlen)
      npts1=nlenx
c      write(6,,*)nlenx,nleny,avaz
      do 101 ix=1,nlenx
      delta= float(ix-1)*dlen
      do 500 iseg=1,nseg
      if(delta.lt.xlen(iseg)) go to 501
 500  continue
 501  continue
      if(iseg.ge.2) delta= delta-xlen(iseg-1)
      az= xaz(iseg)
      sx= x(iseg,ift)
      sy= y(iseg,ift)
c      write(6,*) "ix, iseg, az", ix, iseg, az
      call back(delta,az,sy,sx,dfy,dfx)
      u(ix,1,ift)=dfx
      v(ix,1,ift)=dfy
      if(dip.lt.0.) az2= az-90.
      if(dip.gt.0.) az2= az+90.
c---loop through increments iy downdip
      do 111 iy=2,nleny
      deltaz= (iy-1)*dlen2
      depth= depth0+ deltaz
c deltax for a given deltaz
      deltax= deltaz * ctgdip
c---find surface point above downdip portion of fault. We use an average dip
c rather than a local dip direction. Works better for many faults.
c
      if(dip.lt.1.57)then
      call back(deltax,avdip,dfy,dfx,dfy2,dfx2)
      u(ix,iy,ift)=dfx2
      v(ix,iy,ift)=dfy2
      else
c vertical dipping faults.
      u(ix,iy,ift)=u(ix,1,ift)
      v(ix,iy,ift)=v(ix,1,ift)
      endif
111      continue
101      continue
        u(npts1,1,ift)=x(n,ift)
        v(npts1,1,ift)=y(n,ift)      !same flt end point
      return
      end subroutine resample
      
      logical function LXYIN (X,Y,PX,PY,N)
c Is point (X,Y) inside the (unclosed) polygon (PX,PY)?
c See "Application of the winding-number algorithm...",
c  by Godkin and Pulli, BSSA, pp. 1845-1848, 1984.
c LXYIN= .true. if (X,Y) is inside or on polygon, .false. otherwise.
c Written by C. Mueller, USGS.
      dimension PX(N),PY(N)
      LXYIN= .true.
      KSUM= 0
      do 1 I=1,N-1
        K= KPSCR(PX(I)-X,PY(I)-Y,PX(I+1)-X,PY(I+1)-Y)
        if (K.eq.4) return
        KSUM= KSUM+K
1       continue
      K= KPSCR(PX(N)-X,PY(N)-Y,PX(1)-X,PY(1)-Y)
      if (K.eq.4) return
      KSUM= KSUM+K
      if (KSUM.eq.0) LXYIN= .false.
      return
      end function LXYIN

      integer function KPSCR (X1,Y1,X2,Y2)
c Compute the signed crossing number of the segment from (X1,Y1) to (X2,Y2).
c See "Application of the winding-number algorithm...",
c  by Godkin and Pulli, BSSA, pp. 1845-1848, 1984.
c KPSCR= +4 if segment passes through the origin
c        +2 if segment crosses -x axis from below
c        +1 if segment ends on -x axis from below or starts up from -x axis
c         0 if no crossing
c        -1 if segment ends on -x axis from above or starts down from -x axis
c        -2 if segment crosses -x axis from above
c Written by C. Mueller, USGS.
      KPSCR= 0
      if (Y1*Y2.gt.0.) return
      if (X1*Y2.eq.X2*Y1.and.X1*X2.le.0.) then
        KPSCR= 4
      elseif (Y1*Y2.lt.0.) then
        if (Y1.lt.0..and.X1*Y2.lt.X2*Y1) KPSCR= +2
        if (Y1.gt.0..and.X1*Y2.gt.X2*Y1) KPSCR= -2
      elseif (Y1.eq.0..and.X1.lt.0.) then
        if (Y2.lt.0.) KPSCR= -1
        if (Y2.gt.0.) KPSCR= +1
      elseif (Y2.eq.0..and.X2.lt.0.) then
        if (Y1.lt.0.) KPSCR= +1
        if (Y1.gt.0.) KPSCR= -1
      endif
      return
      end function KPSCR

       subroutine cluster_me(prob,wtscene,nscene,ngroup,j1,j2)
c this routine computes prob. of exceedance for clustered events grouped into ngroup groups
c from rate of exceedance for individual sources stored in prob_s in input
c Sources are combined, zero or one from jseg(1), one from jseg(2), and zero or one from jseg(3), 
c and for a variety of M and a given (constant) return time, 
c nsrc has to be 2 or 3 because subr is written for exceedance from one or more of 2 or 3 clustered events.
c We want this to be more general, nsrc = n clustered events
c inputs:
c      nscene = number of scenarios per group. Probably 4 or 8 for NMSZ. 
c      nlev = number of gm levels. A vector, i=1,...,nper
c      isite = index for site (1 to 1000). only one site for deag. isite=1.
c      prob_s = probability of ground motion exceedance from one event in a
c group setting.
c  j1 = minimum segment number, 1 or 2
c  j2 = maximum segment number, 2 or 3. (this needs work, if two segments,  their numbers must be consecutive)
c ia =  current GMM index
c
c There is 1 period, 1 ground motion levels, ngroup=1 to 5 groups
c This subroutine was written to solve the current model space for NMSZ or Wasatch-SLC only. 
      parameter ( npmx=1)  
	common/cluster/prob_s
      real, dimension(3,8,5) :: prob_s
c      integer, dimension(npmx) :: ngroup
      integer :: ngroup
      integer i_anom/0/      !keep tract of anomalous rates. hope this is zero
      real   prob(*)	!prob : store p_ex in each group,1,...,ngroup
c pfac might be used, from Gabe Toro email. (?)
      real*8 p,pfac,q(4),qq(4)
c qq() stores fraction of prob that is associated with src(dim1, segment). Not finished jul 13 2010.
       real wtscene(8,5)
c       real, dimension(3):: rbar,ebar,mbar,wbar
c prob_s: dim1= segment #, 1 to 3, dim2=ks=scenario
c convert for groups, for scenarios
       nseg_c=j2-j1+1
      ip=1		!1 spectral period.
      do igp=1,ngroup
       k=1		!1 gm level for deagg. Aug 2008
c ps stores sum of scenario rates
      ps=0.0
c      wtsc=0.
c      rbarc(igp)=0.
c      mbarc(igp)=0.
c      ebarc(igp)=0.
      do j=1,nscene
      p=0.0
      i=1
       do isrc=j1,j2	!nsrc=2 or 3
       q(i)=prob_s(isrc,j,igp)
c      if(q(i).gt.0)then
c these are the avg distance, mag ,epsilon averaged over GMPM uncert.
       p=p+q(i)
       i=i+1
       enddo	!isrc
      if(nseg_c.eq.3)then
      p= p  - q(1)*q(2) -q(1)*q(3) -q(2)*q(3)
      else 
      p= p - q(1)*q(2)
      endif
c above includes all cross terms for this limited model
	pf=wtscene(j,igp)*p
       ps = ps +pf
c prob stores the probability of exceedance from all scenarios in each group. 
       enddo	!j=1,nscene
       prob(igp)=ps
       enddo	!igp=1,ngroup
      return
      end subroutine cluster_me
      
      subroutine mindist(dist,azm,disb,azb,rx,stlat,stlon,solat,solon,ns,
     +                   dip,wid,ftop)
c.....................................................................
      parameter (d2r = 0.0174533)
c  input:
c         stlat - station latitude
c         stlon - station longitude
c         solat - latitude of fault segment corners
c         solon - longitude of fault segment corners
c         ns    - number of fault segment corners
c         dip   - fault dip angle
c         wid   - fault width
c         ftop  - depth of fault top 
c  output:
c         dist  - minimum distance to rutpure plane
c         azm   - azimuth for rupture distance
c         disb  - JB distance to rutpure plane
c         azm   - azimuth for JB distance
c         rx    - distance to the surface projection of top edge of fault
c                                              Yuehua Zeng, 2007
c.....................................................................
      dimension solat(500),solon(500)
c
      dp=dip*d2r
      cosdp=cos(dp)
      sindp=sin(dp)
      dist=1.e10
      disb=1.e10
      call delaz2(solat(1),solon(1),solat(ns),solon(ns),flen,str1)
      call delaz2(solat(1),solon(1),stlat,stlon,dista,az)
      sx=dista*cos(az-str1)
      y=dista*sin(az-str1)
      if(sx.le.0.0.or.sx.ge.flen)then; rx=y
      else; rx=sign(sqrt(dista*dista+flen*(flen-sx-sx)),y); endif
      do i=1,ns-1
         call delaz2(solat(i),solon(i),solat(i+1),solon(i+1),flen,str)
         call delaz2(solat(i),solon(i),stlat,stlon,dista,az)
         sx=dista*cos(az-str)
         if(sx.gt.flen)then
           sx=sx-flen
         elseif(sx.gt.0.0)then
           sx=0.0
         endif
         y=dista*sin(az-str)
         r=sqrt(sx*sx+y*y)
         if(sx.le.0.0.and.r.lt.abs(rx))rx=sign(r,y)
c
c  for JB distance
         sy=y
         if(sy.gt.wid*cosdp)then
           sy=sy-wid*cosdp
         elseif(sy.gt.0.0)then
           sy=0.0
         endif
         r=sqrt(sx*sx+sy*sy)
         if(r.lt.disb)then
           disb=r
           azb=az/d2r
         endif
c
c  for rupture distance
         sy=y*cosdp-ftop*sindp
         if(sy.gt.wid)then
           sy=sy-wid
         elseif(sy.gt.0.0)then
           sy=0.0
         endif
         sz=y*sindp+ftop*cosdp
         r=sqrt(sx*sx+sy*sy+sz*sz)
         if(r.lt.dist)then
           dist=r
           azm=az/d2r
         endif
      end do
c
      return
      end subroutine mindist
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
      end subroutine mindist1

      
      SUBROUTINE CB13_NGA_SPEC  (iper, Mw,Rrup,Rx,Rjb, Frv,Fnm,Ztor,Hhyp,W,Z25,Vs30,Dip,SJ,gnd,sigmaf)
c     +(Mw,Rrup,Rjb,Rx, Frv,Fnm,Ztor,Hhyp,W,Dip,Vs30,Z25,SJ, 
c Correction Aug 15 2013: initialize PI.
c Aug 20 2013. Put coeffs into statements instead of reading them in.
c No longer use CB13_NGA_SPEC_IN
c mods by  Harmsen Feb 25 2013. They added PGV index 23 this time.
c parallel compute of  PGA_rock with desired period to run for a given source. This is needed to get the A1100 term
c used with other periods. SH. Mod of Bozorgnia code which performs internal loop on period.
C.....Input parameters (from file CB13_NGA_infile.txt)
c      ip = global period index=1 not passed in
c      iper = local period index
C     Frv    = 1 for Reverse-faulting, 0 otherwise
C     Fnm    = 1 for Normal-faulting, 0 otherwise
C     Ztor   = Depth to top of coseismic rupture (km)
C     Hhyp   = Hypocentral depth (km)
C     W      = Fault width (km)
C     Dip    = Dip of fault rupture plane (degrees)
C     Vs30   = Average velocity in top 30-m (m/s)
C     Z25    = Depth to 2.5 km/s velocity horizon (km)
C     SJ     = 1 for sites in Japan; =0 otherwise
C     iSpec  = 0 for generating Sa(g) [Not at this point: 1 for Sv(cm/s); 2 for Sd(cm)]
c output
c	gnd = logged SA and sigmaf = 1/sigma/sqrt2
      parameter (nper=23,sqrt2=1.4142136, PI=3.1415927,d2r=0.0174533)
       real, dimension(3) ::gnd
       common/sdi/sdi,dy_sdi,fac_sde
      common/epistemic/l_gnd_ep,gnd_ep,ide,ime
      integer ide,ime,ip
	integer imsp(8,21),kmsp(0:10)
	logical lmsp(0:10,21),l_ms
             common/fix_sigma/fix_sigma,sigma_fx
      real, dimension(21) :: meanspec,sigspec
      common/ms/ia,jms,npnga,l_ms,lmsp,imsp,meanspec,sigspec
      common/Dipinf/dipang,cosDELTA,cdipsq,cyhwfac,cbhwfac
       common/cb13p/Per
       real :: fac_sde, sigmaf
      real, dimension(nper):: Phi,Tau,Per,c0,c1,c2low,c2,c3,c4,c5,c6,c7,c8,c9,c10,c10j,c10jlow,c11,
     + c11j,c12,c13low,c13hi,c14,c15,k1,k2,k3,a2,h1,h2,h3,h4,h5,h6,phi_lny,phi_low, phi_hi,
     + tau_lny,tau_lnyB,tau_low,tau_hi,phi_lnAF,rho,c15ca,c15j,c15_China,sigma_c
       real alpha,Mw,A1100,csoil,nsoil,Sigmatot,sigma_fx,phi_lnyB
       logical l_gnd_ep,fix_sigma,sdi
c If sdi is true, this subroutine will return inelastic spectral displ. (cm) instead
c of pSA. Tothong&Cornell approach
       real gnd_ep(3,3)
c T=.01,.02,.03,.05,.075,.1,.15,.2,.25,.3,0.4,0.5,.75,1,1.5,2,3,4,5,7.5,10,0,-1
c-----Soil model constants (not using the constant vector from Bozorgnia code)
	Per=(/0.01,0.02,0.03,0.05,0.075,0.1,0.15,0.2,0.25,0.3,0.4,
     + 0.5,0.75,1.,1.5,2.,3.,4.,5.,7.5,10.,0.,-1./)
c c0 updated for several spectral periods and for PGA Bozorgnia email aug 27, 2013.
     	c0=(/-4.365,-4.348,-4.024,-3.479,-3.29312,-3.66556,
     + -4.86602,-5.41069,-5.96223,-6.40274,-7.56611,-8.37896,-9.84117,
     + -11.01088,-12.46903,-12.96946,-13.30646,-14.01959,-14.55814,
     + -15.50934,-15.97482,-4.416,-2.89541/)
     	c1=(/0.9767,0.97602,0.93061,0.88708,0.9018,0.99317,1.26745,1.36587,
     + 1.45843,1.52845,1.73878,1.87232,2.02098,2.18019,2.26973,2.2711,
     + 2.14989,2.1324,2.11557,2.22333,2.13178,0.98408,1.51014/)
   	c2low=(/0.5333,0.54938,0.62834,0.67381,0.72577,0.69757,0.51048,0.4471,
     + 0.27438,0.19341,-0.02008,-0.1212,-0.04173,-0.06925,0.04678,0.14935,
     + 0.36819,0.72617,1.02702,0.16924,0.36739,0.53714,0.27/)
     	c2=(/-1.48461,-1.48771,-1.49384,-1.38762,-1.46913,-1.57184,-1.66866,
     + -1.74959,-1.71072,-1.77001,-1.59425,-1.57678,-1.75665,-1.70658,
     + -1.62116,-1.51208,-1.31456,-1.50567,-1.72132,-0.75648,-0.80033,
     + -1.49918,-1.29865/)
     	c3=(/-0.498937453,-0.500622655,-0.516949343,-0.614846203,-0.596140959,          	
     + -0.53615185,-0.489916175,-0.451168621,-0.40377,-0.32137,-0.42641,
     + -0.44027,-0.44323,-0.52717,-0.62968,-0.7684,-0.88968,-0.88483,
     + -0.87758,-1.0771,-1.28153,-0.496099731,-0.45259/)
     	c4=(/-2.77287,-2.77184,-2.78177,-2.79116,-2.74484,-2.63321,-2.45812,
     + -2.42082,-2.39172,-2.37647,-2.30344,-2.29568,-2.23162,-2.15751,
     + -2.06285,-2.1042,-2.05109,-1.98623,-2.02143,-2.17893,-2.24395,
     + -2.77308,-2.46623/)
     	c5=(/0.24794,0.24728,0.24569,0.23957,0.22728,0.20998,0.18271,0.18236,
     + 0.18902,0.19458,0.18548,0.18608,0.18622,0.16948,0.15776,0.15773,
     + 0.14786,0.13543,0.13954,0.17836,0.19421,0.24792,0.20353/)
    	c6=(/6.7526,6.50193,6.29064,6.31674,6.86079,7.29437,8.03121,8.38547,
     + 7.53447,6.99039,7.012,6.902,5.52167,5.64974,5.795,6.63167,6.75917,
     + 7.97765,8.53845,8.46752,6.56419,6.76761,5.83687/)
     	c7=0.0
     	c8=(/-0.21399,-0.20765,-0.21286,-0.24416,-0.26594,-0.22909,-0.21079,
     + -0.16256,-0.15032,-0.131,-0.15869,-0.15259,-0.0903,-0.105,-0.05765,
     + -0.02807,0.,0.,0.,0.,0.,-0.21192,-0.16787/)
     	c9=(/0.72005,0.72967,0.75901,0.8263,0.81493,0.83098,0.74885,0.76413,
     + 0.71599,0.73747,0.73848,0.71779,0.79532,0.55604,0.48038,0.40135,
     + 0.20613,0.105,0.,0.,0.,0.72036,0.30531/)
          c10=(/1.09423,1.14928,1.28982,1.44851,1.53508,1.61453,1.87724,2.06875,
     + 2.20472,2.3056,2.39843,2.35519,1.99492,1.4472,0.32996,-0.51429,
     + -0.84808,-0.79272,-0.74828,-0.66444,-0.57634,1.09034,1.71266/)
     	c10Jlow=(/2.19076,2.18901,2.16441,2.13849,2.44588,2.96906,3.54382,
     + 3.70687,3.34286,3.33392,3.54369,3.01604,2.61646,2.46961,2.10849,
     + 1.32674,0.60121,0.56816,0.35563,0.0751,-0.02688,2.18598,2.6016/)
     	c10J=(/1.41626,1.45343,1.47596,1.54867,1.77181,1.91583,2.16149,2.46523,
     + 2.7662,3.0105,3.20302,3.33327,3.05379,2.56169,1.45264,0.65727,0.36667,
     + 0.30608,0.26753,0.37356,0.29687,1.42048,2.45689/)
     	c11=(/-0.00697,-0.01669,-0.04215,-0.06628,-0.07944,-0.02935,0.06424,
     + 0.09684,0.14409,0.15969,0.14104,0.14743,0.17641,0.25934,0.28807,
     + 0.31124,0.34781,0.37465,0.33817,0.37541,0.35056,-0.00638,0.10601/)
     	c11J=(/-0.20736,-0.19937,-0.20208,-0.33892,-0.40355,-0.41622,-0.40719,
     + -0.31065,-0.17151,-0.08379,0.08468,0.23288,0.41099,0.47909,0.56579,
     + 0.5624,0.534,0.52227,0.47719,0.32092,0.1743,-0.20246,0.33242/)
     	c12=(/0.38951,0.38713,0.37769,0.29548,0.322,0.38448,0.41653,0.40419,
     + 0.46631,0.52831,0.53978,0.63753,0.77607,0.77071,0.7476,0.76284,
     + 0.68565,0.69094,0.67003,0.75653,0.62149,0.39293,0.58488/)
     	c13low=(/0.09813,0.10091,0.10948,0.12256,0.11646,0.0998,0.07595,0.05707,
     + 0.04374,0.03232,0.0209,0.00922,-0.00821,-0.0131,-0.01865,-0.02581,
     + -0.03106,-0.04129,-0.02814,-0.02054,0.00093,0.09766,0.05174/)
     	c13hi=(/0.0334,0.03272,0.03312,0.02695,0.02882,0.03253,0.03884,0.04373,
     + 0.04633,0.05084,0.04322,0.04053,0.042,0.04259,0.03798,0.02515,0.02356,
     + 0.0102,0.00335,0.00497,0.00986,0.03334,0.03267/)
     	c14=(/0.00755,0.00759,0.0079,0.00803,0.00811,0.00744,0.00716,0.00688,
     + 0.00556,0.00458,0.00401,0.00388,0.0042,0.00409,0.00424,0.00448,0.00345,
     + 0.00603,0.00805,0.0028,0.00458,0.00757,0.00613/)
     	c15=0.0
     	c15CA=(/-0.0055,-0.0055,-0.0057,-0.0063,-0.007,-0.0073,-0.0069,-0.006,
     + -0.0055,-0.0049,-0.0037,-0.0027,-0.0016,-0.0006,0.,0.,0.,0.,0.,0.,0.,-0.0055,
     + -0.0017/)
     	c15j=(/-0.009,-0.009,-0.0091,-0.01,-0.0107,-0.0107,-0.0099,-0.0091,
     + -0.0088,-0.0084,-0.0071,-0.0061,-0.0048,-0.0036,-0.0019,-0.0005,
     + 0.,0.,0.,0.,0.,-0.009,-0.0023/)
     	c15_China=(/-0.0019,-0.0019,-0.002,-0.0023,-0.0031,-0.0031,-0.0027,-0.0019,
     + -0.0019,-0.0018,-0.0009,-0.0002,0.,0.,0.,0.,0.,0.,0.,0.,0.,-0.0019,0./)
     	a2=(/0.168204,0.16608,0.166615,0.173208,0.198386,0.174173,0.197692,0.204389,
     + 0.185493,0.16375,0.159991,0.183814,0.215828,0.595819,0.595819,0.595819,
     + 0.595819,0.595819,0.595819,0.595819,0.595819,0.166756,0.595819/)
     	h1=(/0.242491585,0.244239479,0.246102927,0.251121153,0.260215395,0.258891885,
     + 0.253754887,0.236761836,0.205538668,0.209669285,0.225654325,0.216617007,
     + 0.153809642,0.117400827,0.117400827,0.117400827,0.117400827,0.117400827,
     + 0.117400827,0.117400827,0.117400827,0.241153212,0.117400827/)
     	h2=(/1.471226463,1.467008458,1.467306208,1.449483555,1.43491017,1.448920728,
     + 1.46101266,1.484246105,1.581051011,1.585576015,1.544360277,1.553834937,
     + 1.626464751,1.615567127,1.615567127,1.615567127,1.615567127,1.615567127,
     + 1.615567127,1.615567127,1.615567127,1.473962695,1.615567127/)
     	h3=(/-0.713718048,-0.711247937,-0.713409135,-0.700604707,-0.695125566,
     + -0.707812613,-0.714767546,-0.721007941,-0.786589679,-0.7952453,
     + -0.770014601, -0.770451944,-0.780274394,-0.732967953,-0.732967953,
     + -0.732967953,-0.732967953, -0.732967953,-0.732967953,-0.732967953,
     + -0.732967953,-0.715115906,-0.732967953/)
     	h4=1.0
     	h5=(/-0.336344,-0.339225,-0.338487,-0.338309,-0.347476,-0.391023,-0.449387,
     + -0.393051,-0.338954,-0.446928,-0.525278,-0.407316,-0.370885,-0.127976,
     + -0.127976,-0.127976,-0.127976,-0.127976,-0.127976,-0.127976,-0.127976,
     + -0.336826,-0.127976/)
     	h6=(/-0.26972,-0.262572,-0.258835,-0.262789,-0.218517,-0.200791,-0.0994103,
     + -0.198083,-0.210334,-0.120913,-0.0861837,-0.28051,-0.284764,-0.755608,
     + -0.755608,-0.755608,-0.755608,-0.755608,-0.755608,-0.755608,-0.755608,
     + -0.270212,-0.755608/)
     	k1=(/865.,865.,908.,1054.,1086.,1032.,878.,748.,654.,587.,503.,457.,410.,400.,400.,400.,
     + 400.,400.,400.,400.,400.,865.,400./)
     	k2=(/-1.186,-1.219,-1.273,-1.346,-1.471,-1.624,-1.931,-2.188,-2.381,-2.518,
     + -2.657,-2.669,-2.401,-1.955,-1.025,-0.299,0.,0.,0.,0.,0.,-1.186,-1.955/)
     	k3=(/1.839,1.84,1.841,1.843,1.845,1.847,1.852,1.856,1.861,1.865,1.874,1.883,
     + 1.906,1.929,1.974,2.019,2.11,2.2,2.291,2.517,2.744,1.839,1.929/)
c     	csoil=(/1.88,1.88,1.88,1.88,1.88,1.88,1.88,1.88,1.88,1.88,1.88,1.88,1.88,
c     	     + 1.88,1.88,1.88,1.88,1.88,1.88,1.88,1.88,1.88,1.88/)
c     	nsoil=(/1.18,1.18,1.18,1.18,1.18,1.18,1.18,1.18,1.18,1.18,1.18,1.18,1.18,
c     + 1.18,1.18,1.18,1.18,1.18,1.18,1.18,1.18,1.18,1.18/)
     	phi_low=(/0.7336,0.7375,0.7471,0.7768,0.7821,0.7691,0.7693,0.7609,0.7439,
     + 0.7265,0.6901,0.6632,0.6058,0.5785,0.5412,0.5286,0.5269,0.5212,0.5024,
     + 0.4568,0.4412,0.7335,0.6552/)
     	phi_hi=(/0.4915,0.4955,0.5034,0.5197,0.5349,0.5431,0.5427,0.5515,0.5448,
     + 0.5684,0.5931,0.6113,0.6326,0.6278,0.6032,0.5879,0.578,0.5592,0.551,
     + 0.5456,0.5432,0.4918,0.4944/)
     	tau_low=(/0.4041,0.4167,0.4458,0.5076,0.504,0.4449,0.3816,0.3392,0.3401,
     + 0.3399,0.3559,0.3792,0.4299,0.4695,0.4973,0.4985,0.4996,0.5427,0.5339,
     + 0.5228,0.4655,0.4086,0.3171/)
     	tau_hi=(/0.3247,0.3258,0.3437,0.3769,0.418,0.4261,0.3865,0.3381,0.316,
     + 0.2997,0.2635,0.2632,0.3264,0.3527,0.3989,0.4004,0.4172,0.3925,0.4209,
     + 0.4376,0.4379,0.3219,0.2969/)
     	phi_lnAF=(/0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,
     + 0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3/)
c sigma_c is used to get an aleatory sigma for the random H comp instead of mean H comp.
     	sigma_c=(/0.166,0.166,0.165,0.162,0.158,0.17,0.18,0.186,0.191,0.198,0.206,
     + 0.208,0.221,0.225,0.222,0.226,0.229,0.237,0.237,0.271,0.29,0.166,0.19/)
     	rho=(/1.0,0.998,0.986,0.938,0.887,0.87,0.876,0.87,0.85,0.819,0.743,0.684,0.562,
     + 0.467,0.364,0.298,0.234,0.202,0.184,0.176,0.154,1.0,0.684/)    
c-----Soil model constants (not using the constant vector from Bozorgnia code)
    
       nsoil = 1.18
       csoil = 1.88
	if(SJ.lt.1.0)then
	c15=c15ca	!use california Qmodel when SJ<1
	elseif(SJ.lt.2.)then
	c15=c15j
	else
	c15=c15_China
	endif
        iperflag=1
c Corr. Aug 15 2013: set iperflag = 1 on first period at entry. This calculates
c A1100. Once calculated it is saved for the other spectral periods to use.
C*****Hanging-wall term 
C     Jennifer Donahue's HW Model plus CB08 distance taper 
      R1= W * cos(Dip*PI/180.)
      R2= 62.*Mw - 350.
        if(iper.eq.1)iper=22    
	ip = 1
C*****Magnitude term
      IF (Mw .LE. 4.5) THEN
        F_mag = c0(iper) + c1(iper)*Mw
      ELSEIF (Mw .LE. 5.5) THEN
        F_mag = c0(iper) + c1(iper)*Mw + c2low(iper)*(Mw-4.5)
      ELSEIF (Mw .LE. 6.5) THEN
        F_mag = c0(iper) + c1(iper)*Mw + c2low(iper)*(Mw-4.5) + 
     &          c2(iper)*(Mw-5.5)
      ELSE
        F_mag = c0(iper) + c1(iper)*Mw + c2low(iper)*(Mw-4.5) + 
     &          c2(iper)*(Mw-5.5) + c3(iper)*(Mw-6.5)
      ENDIF
	if(iper.ne.22)then
      IF (Mw .LE. 4.5) THEN
        F_magr = c0(22) + c1(22)*Mw
      ELSEIF (Mw .LE. 5.5) THEN
        F_magr = c0(22) + c1(22)*Mw + c2low(22)*(Mw-4.5)
      ELSEIF (Mw .LE. 6.5) THEN
        F_magr = c0(22) + c1(22)*Mw + c2low(22)*(Mw-4.5) + 
     &          c2(22)*(Mw-5.5)
      ELSE
        F_magr = c0(22) + c1(22)*Mw + c2low(22)*(Mw-4.5) + 
     &          c2(22)*(Mw-5.5) + c3(22)*(Mw-6.5)
      ENDIF !Mw blah
C*****Distance term
      Rr = SQRT(Rrup**2 + c6(22)**2)
      F_disr = (c4(22) + c5(22)*Mw)*LOG(Rr)
C*****Style-of-fauting term
      f_flt_Fr = c7(22)*Frv + c8(22)*Fnm
      f1_Rxr= h1(22) + h2(22)*(Rx/R1) + h3(22)*((Rx/R1)**2)
      f2_Rxr= h4(22) + h5(22)*((Rx-R1)/(R2-R1)) + 
     &       h6(22)*((Rx-R1)/(R2-R1))**2
C.....f_HW_R
      IF (Rx.lt.0.0) THEN
        f_HW_Rxr= 0.0
      ELSEIF (Rx.lt.R1) THEN
        f_HW_Rxr= f1_Rxr 
      ELSE
        f_HW_Rxr= (max(f2_Rxr, 0.0))
      ENDIF
      ENDIF	!pga_Rock?
	      
C*****Distance term
      R = SQRT(Rrup**2 + c6(iper)**2)
      F_dis = (c4(iper) + c5(iper)*Mw)*LOG(R)

C*****Style-of-fauting term
      f_flt_F = c7(iper)*Frv + c8(iper)*Fnm

C.....Note: Magnitude limits and equation have been changed
      IF (Mw.LE.4.5) THEN
        f_flt_M=0.
      ELSEIF (Mw.LE.5.5) THEN
        f_flt_M= Mw-4.5 
      ELSE
        f_flt_M= 1.
      ENDIF

      F_flt= f_flt_F * f_flt_M


      f1_Rx= h1(iper) + h2(iper)*(Rx/R1) + h3(iper)*((Rx/R1)**2)
      f2_Rx= h4(iper) + h5(iper)*((Rx-R1)/(R2-R1)) + 
     &       h6(iper)*((Rx-R1)/(R2-R1))**2
	if(iper.ne.22)then
       F_fltr= f_flt_Fr * f_flt_M
	else
	F_fltr=F_flt	!pga no addnl calc.
	endif	
C.... CB08 distance taper
      IF (Rrup.eq.0.0) THEN
        f_HW_Rrup= 1.0
      ELSE 
        f_HW_Rrup= (Rrup - Rjb)/Rrup
      ENDIF
C
C.....f_HW_R
      IF (Rx.lt.0.0) THEN
        f_HW_Rx= 0.0
      ELSEIF (Rx.lt.R1) THEN
        f_HW_Rx= f1_Rx 
      ELSE
        f_HW_Rx= (max(f2_Rx, 0.0))
      ENDIF

C.....f_HW_M
C.....Note: Equation for f_HW_M has been changed
      IF (Mw.le.5.5) THEN
        f_HW_M=0.
      ELSEIF (Mw.le.6.5) THEN 
        f_HW_M= (Mw-5.5)*(1+a2(iper)*(Mw-6.5))
      ELSE
        f_HW_M= 1. + a2(iper)*(Mw-6.5)
      ENDIF

C.....f_HW_Z
      IF(Ztor.le.16.66) THEN
        f_HW_Z=1.0-0.06* Ztor
      ELSE
        f_HW_Z=0.0
      ENDIF

C.....f_HW_dip
      f_HW_dip= (90.0 - DIP)/45.0

      F_HW= c9(iper)* f_HW_Rx * f_HW_Rrup * f_HW_M * f_HW_Z * f_HW_Dip
	if(iper.ne.22)then
C.....f_HW_M
C.....Note: Equation for f_HW_M has been changed
      IF (Mw.le.5.5) THEN
        f_HW_Mr=0.
      ELSEIF (Mw.le.6.5) THEN 
        f_HW_Mr= (Mw-5.5)*(1+a2(22)*(Mw-6.5))
      ELSE
        f_HW_Mr= 1. + a2(22)*(Mw-6.5)
      ENDIF
      F_HWr= c9(22)* f_HW_Rxr * f_HW_Rrup * f_HW_Mr * f_HW_Z * f_HW_Dip
	else
	F_HWr=F_HW
	endif
	
C*****Hypo depth term
      IF(Hhyp.le.7.) THEN
        f_Hhyp_H=0.
      ELSEIF (Hhyp.le.20.) THEN
        f_Hhyp_H= Hhyp-7.
      ELSE
        f_Hhyp_H=13.0
      ENDIF

      IF (Mw.le.5.5) THEN
        F_Hhyp_M= c13low(iper)
        F_Hhyp_Mr= c13low(22)
      ELSEIF (Mw.le.6.5) THEN        
        F_Hhyp_M= (c13low(iper)+ (c13hi(iper) - c13low(iper))*(Mw-5.5)) 
        F_Hhyp_Mr= (c13low(22)+ (c13hi(22) - c13low(22))*(Mw-5.5)) 
      ELSE
        F_Hhyp_M= c13hi (iper)
        F_Hhyp_Mr= c13hi (22)
      ENDIF
      
      F_Hhyp= f_Hhyp_H * f_Hhyp_M  
      F_Hhypr=f_Hhyp_H * f_Hhyp_Mr
C*****Dip term
C.....Dip term has been changed
      IF (Mw.le.4.5) THEN
        F_Dip= c14(iper)* DIP
      ELSEIF (Mw.le.5.5) THEN 
        F_Dip= c14(iper)* (5.5 - Mw)* Dip
      ELSE
        F_Dip= 0.
      ENDIF

C*****Shallow sediment depth and 3-D basin term
      IF (Z25 .LE. 1.0) THEN
        F_sed = (c11(iper) + c11J(iper)*SJ)*(Z25 - 1.0)
      ELSEIF (Z25 .LE. 3.0) THEN
        F_sed = 0.0
      ELSE
        F_sed = c12(iper)*k3(iper)*(EXP(-0.75))*
     +(1.0 - EXP(-0.25*(Z25 - 3.0)))
      ENDIF

C*****Anelastic attenuatin term
      if(Rrup.gt.80.)then
      F_atn=c15(iper)*(Rrup-80.)
      else
      F_atn=0.0
      endif

c now do it again for rock...
      if(iper.ne.22)then
C.....Dip term has been changed
      IF (Mw.le.4.5) THEN
        F_Dipr= c14(22)* DIP
      ELSEIF (Mw.le.5.5) THEN 
        F_Dipr= c14(22)* (5.5 - Mw)* Dip
      ELSE
        F_Dipr= 0.
      ENDIF

C*****Shallow sediment depth and 3-D basin term
      IF (Z25 .LE. 1.0) THEN
        F_sedr = (c11(22) + c11J(22)*SJ)*(Z25 - 1.0)
      ELSEIF (Z25 .LE. 3.0) THEN
        F_sedr = 0.0
      ELSE
        F_sedr = c12(22)*k3(22)*(EXP(-0.75))*
     +(1.0 - EXP(-0.25*(Z25 - 3.0)))
      ENDIF

C*****Anelastic attenuation term
      if(Rrup.gt.80.)then
      F_atnr=c15(22)*(Rrup-80.)
      else
      F_atnr=0.0
      endif
      else
      F_Dipr=F_Dip; F_sedr=F_sed; F_atnr=F_atn
      endif
      

C*****For the first period (loop), computer A1100 *****************************

C........Shallow site conditions term for ROCK PGA (i.e., Vs30 = 1100 m/s)
C        Note csoil and nsoil are now arrays
         F_site_1100 = (c10(22) + k2(22)*nsoil)*LOG(1100.0/k1(22))

C........Rock PGA

         A1100 = EXP(F_magr + F_disr + F_fltr + F_HWr + 
     +               F_site_1100 + F_sedr + F_Hhypr + F_Dipr + F_atnr)
c        print *,Rrup,Mw,A1100

C*****Site term for other iper values: Note csoil and nsoil are now arrays 
       IF (Vs30 .LE. k1(iper)) THEN
         F_site = c10(iper)*LOG(Vs30/k1(iper))
     &             + k2(iper)*(LOG(A1100+csoil*
     &                ((Vs30/k1(iper))**nsoil)) 
     &             - LOG(A1100 + csoil))
       ELSE
         F_site = (c10(iper) + k2(iper)*nsoil)*LOG(Vs30/k1(iper))
       ENDIF

c*****Ground motion parameter, logged.

       gnd(1) = F_mag + F_dis + F_flt + F_HW + 
     &              F_site + F_sed + F_Hhyp + F_Dip + F_atn
C.....

C.....CALCULATE ALEATORY UNCERTAINTY
C     Note: This part has been changed

1000  IF (Vs30 .LT. k1(iper)) THEN
        alpha = 
     &    k2(iper)*A1100*(1.0/(A1100  
     &    +csoil*(Vs30/k1(iper))**nsoil) 
     &    -1.0/(A1100 + csoil))
      ELSE
        alpha = 0.0
      ENDIF

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
         phi_lny(22) =phi_low(22)
      elseif (Mw.lt.5.5) then
         phi_lny(iper) =phi_hi(iper) + 
     &    (phi_low(iper) - phi_hi(iper))*(5.5-Mw)
         phi_lny(22) =phi_hi(22) + 
     &    (phi_low(22) - phi_hi(22))*(5.5-Mw)
      else
         phi_lny(iper) =phi_hi(iper) 
         phi_lny(22) =phi_hi(22) 
      endif

      phi_lnyB = SQRT(phi_lny(iper)**2 - phi_lnAF(iper)**2)
c	print *,phi_lny(22),phi_lnAF(22)
      phi_lnPGAB = SQRT(phi_lny(22)**2 - phi_lnAF(22)**2)

      phi(iper) = SQRT(phi_lny(iper)**2 + 
     &           (alpha*phi_lnPGAB)**2 +
     &           2.0*alpha*rho(iper)*phi_lnyB*phi_lnPGAB)
c       print *,iper,phi_lny(iper),phi(iper),tau(iper),alpha,tau_lnyB(iper),phi_lnPGAB
      if(fix_sigma)then
      	Sigmatot=sigma_fx
       sigmaf=1./sqrt2/sigma_fx
      else      	
        Sigmatot = SQRT(phi(iper)**2 + Tau(iper)**2)
       sigmaf=1./sqrt2/Sigmatot
              endif
c       print *,gnd(1),sigmatot
       if(sdi)then
       sde=gnd(1)+fac_sde      !fac_sde is log(T**2/(4pisq))
       rhat = min(10.,exp(sde)/dy_sdi)      !10 is an upper bound for rhat.
       gnd(1) = sdi_ratio(per(iper),Mw,rhat,Sigmatot,sdisd) + sde
       sigmaf=1./sdisd/sqrt2      !use sdi for all gnd_ep branches
         endif      !if(sdi)
         if(l_gnd_ep)then
         gnd(2)= gnd(1)+gnd_ep(ide,ime)
         gnd(3)= gnd(1)-gnd_ep(ide,ime)
         endif
	if (l_ms)then
c Play it again, Ken Campbell, to compute the mean spectrum. New June 24 2013.
	do jp=1,npnga
c The below conditional says, compute if coeffs are available at the period with index jp. This
c will generally be true for the NGA-W relations but less so for older GMPEs with fewer periods.
c  
	jper=imsp(ia,jp)
        if ( jp .eq. jms)then
c use the available information. May have to add epsilon0*sigma_t.
        meanspec(jp)=gnd(1)
        sigspec(jp)=sigmatot
c        print *,exp(meanspec(jp)),sigspec(jp),Per(jper),'CB control'
	elseif (lmsp(ia,jp)) then
C*****Distance term
      R = SQRT(Rrup**2 + c6(jper)**2)
      F_dis = (c4(jper) + c5(jper)*Mw)*LOG(R)

C*****Style-of-fauting term
      f_flt_F = c7(jper)*Frv + c8(jper)*Fnm
c f_flt_M was computed above. it is independent of spectral period.
C.....Note: Magnitude limits and equation have been changed
      F_flt= f_flt_F * f_flt_M

C*****Magnitude term
      IF (Mw .LE. 4.5) THEN
        F_mag = c0(jper) + c1(jper)*Mw
      ELSEIF (Mw .LE. 5.5) THEN
        F_mag = c0(jper) + c1(jper)*Mw + c2low(jper)*(Mw-4.5)
      ELSEIF (Mw .LE. 6.5) THEN
        F_mag = c0(jper) + c1(jper)*Mw + c2low(jper)*(Mw-4.5) + 
     &          c2(jper)*(Mw-5.5)
      ELSE
        F_mag = c0(jper) + c1(jper)*Mw + c2low(jper)*(Mw-4.5) + 
     &          c2(jper)*(Mw-5.5) + c3(jper)*(Mw-6.5)
      ENDIF

      f1_Rx= h1(jper) + h2(jper)*(Rx/R1) + h3(jper)*((Rx/R1)**2)
      f2_Rx= h4(jper) + h5(jper)*((Rx-R1)/(R2-R1)) + 
     &       h6(jper)*((Rx-R1)/(R2-R1))**2
	if(jper.ne.22)then
       F_fltr= f_flt_Fr * f_flt_M
	else
	F_fltr=F_flt	!pga no addnl calc.
	endif	
C
C.....f_HW_R
      IF (Rx.lt.0.0) THEN
        f_HW_Rx= 0.0
      ELSEIF (Rx.lt.R1) THEN
        f_HW_Rx= f1_Rx 
      ELSE
        f_HW_Rx= (max(f2_Rx, 0.0))
      ENDIF

C.....f_HW_M
C.....Note: Equation for f_HW_M has been changed
      IF (Mw.le.5.5) THEN
        f_HW_M=0.
      ELSEIF (Mw.le.6.5) THEN 
        f_HW_M= (Mw-5.5)*(1+a2(jper)*(Mw-6.5))
      ELSE
        f_HW_M= 1. + a2(jper)*(Mw-6.5)
      ENDIF


      F_HW= c9(jper)* f_HW_Rx * f_HW_Rrup * f_HW_M * f_HW_Z * f_HW_Dip
C.....f_HW_M
C.....Note: Equation for f_HW_M has been changed
C*****Hypo depth term. Recompute only those factors that are frequency dependent.

      IF (Mw.le.5.5) THEN
        F_Hhyp_M= c13low(jper)
      ELSEIF (Mw.le.6.5) THEN        
        F_Hhyp_M= (c13low(jper)+ (c13hi(jper) - c13low(jper))*(Mw-5.5)) 
      ELSE
        F_Hhyp_M= c13hi (jper)
      ENDIF
      
      F_Hhyp= f_Hhyp_H * f_Hhyp_M  
C*****Dip term
C.....Dip term has been changed
      IF (Mw.le.4.5) THEN
        F_Dip= c14(jper)* DIP
      ELSEIF (Mw.le.5.5) THEN 
        F_Dip= c14(jper)* (5.5 - Mw)* Dip
      ELSE
        F_Dip= 0.
      ENDIF

C*****Shallow sediment depth and 3-D basin term
      IF (Z25 .LE. 1.0) THEN
        F_sed = (c11(jper) + c11J(jper)*SJ)*(Z25 - 1.0)
      ELSEIF (Z25 .LE. 3.0) THEN
        F_sed = 0.0
      ELSE
        F_sed = c12(jper)*k3(jper)*(EXP(-0.75))*
     +(1.0 - EXP(-0.25*(Z25 - 3.0)))
      ENDIF

C*****Anelastic attenuation term
      if(Rrup.gt.80.)then
      F_atn=c15(jper)*(Rrup-80.)
      else
      F_atn=0.0
      endif

C*****Site term for other iper values: Note csoil and nsoil are now arrays 
       IF (Vs30 .LE. k1(jper)) THEN
         F_site = c10(jper)*LOG(Vs30/k1(jper))
     &             + k2(jper)*(LOG(A1100+csoil*
     &                ((Vs30/k1(jper))**nsoil)) 
     &             - LOG(A1100 + csoil))
       ELSE
         F_site = (c10(jper) + k2(jper)*nsoil)*LOG(Vs30/k1(jper))
       ENDIF

c*****Ground motion parameter, logged.

       meanspec(jp) = F_mag + F_dis + F_flt + F_HW + 
     &              F_site + F_sed + F_Hhyp + F_Dip + F_atn
C.....
      if(fix_sigma)then
      	sigspec(jp)=sigma_fx
      else      	

C.....CALCULATE ALEATORY UNCERTAINTY
      IF (Vs30 .LT. k1(jper)) THEN
        alpha = 
     &    k2(jper)*A1100*(1.0/(A1100  
     &    +csoil*(Vs30/k1(jper))**nsoil) 
     &    -1.0/(A1100 + csoil))
      ELSE
        alpha = 0.0
      ENDIF

      If (Mw.le.4.5) then
         tau_lnyB(jper) =tau_low(jper)
      elseif (Mw.lt.5.5) then
         tau_lnyB(jper) =tau_hi(jper) + 
     &    (tau_low(jper) - tau_hi(jper))*(5.5-Mw)
      else
         tau_lnyB(jper) =tau_hi(jper) 
      endif
      tau(jper) = SQRT(tau_lnyB(jper)**2 +  
     &           (alpha * tau_lnPGAB)**2 +
     &           2.0*alpha*rho(jper)*tau_lnyB(jper)*tau_lnPGAB)

      If (Mw.le.4.5) then
         phi_lny(jper) =phi_low(jper)
      elseif (Mw.lt.5.5) then
         phi_lny(jper) =phi_hi(jper) + 
     &    (phi_low(jper) - phi_hi(jper))*(5.5-Mw)
      else
         phi_lny(jper) =phi_hi(jper) 
      endif

      phi_lnyB = SQRT(phi_lny(jper)**2 - phi_lnAF(jper)**2)
c the quantity phi_lnPGAB was computed earlier and is now re-used.
      phi(jper) = SQRT(phi_lny(jper)**2 + 
     &           (alpha*phi_lnPGAB)**2 +
     &           2.0*alpha*rho(jper)*phi_lnyB*phi_lnPGAB)
        sigspec(jp)= SQRT(phi(jper)**2 + Tau(jper)**2)
        endif
c        print *,exp(meanspec(jp)),sigspec(jp),Per(jper),' CB13'
        endif	!(computable?)
        enddo	!loop thru CMS periods
        endif	!compute CMS	
      RETURN
      END SUBROUTINE CB13_NGA_SPEC


c------------------------------------------------------------------------------
c      SUBROUTINE CB13_NGA_SPEC_IN removed.

	subroutine gksa13v2(L,ip,Mw,x,gndout,sigmaf,Vs,mec,Bdepth,Q)
c Revised Graizer and Kalkan model with continuous response variation with 
c	basin depth. Also PGA has been identified with 0.01s SA due to basin
c	effect. 
c Input: L = period index in below per array.
c	x = Rcd (km).
c	Mw = moment magnitude.
c Bdepth = basin depth (km). new parm. 2012. Geotech: depth to Vs=1.5 km/s
c       Q quality factor 157 for California according to GK (2013 rev)
c mec is sense-of-slip:
ccccc      Mec = 1 for strike slip    Normal Faults (3) are treated like strike slip
ccccc      Mec = 2 for thrust faults
ccccc      Mec = 4 combination of thrust and strike
c Output:
c gndout(j) = logged median motion (SA) (g).
c sigmaf = 1/sigma/sqrt2

      real sqrt2, Mw
      real, dimension(21) :: meanspec,sigspec
      integer imsp(8,21),kmsp(0:10)
      logical lmsp(0:10,21),l_ms
      real, dimension (3,3) :: gnd_ep
      real, dimension(3) :: gndout
      logical l_gnd_ep,fix_sigma
      parameter (nper=35,sqrt2=1.41421356)
      common/epistemic/l_gnd_ep,gnd_ep,ide,ime
      common/fix_sigma/fix_sigma,sigma_fx
      common/ms/ia,jms,npnga,l_ms,lmsp,imsp,meanspec,sigspec

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
C*********Coefficients file, apr 2013 ***************
         c1 =  0.140
         c2 = -6.250
         c3 =  0.370
         c4 =  2.237
         c5 = -7.542
         c6 = -0.125
         c7 =  1.190
         c8 = -6.150
c         c9 =  0.525
	c9 = 0.6	!V.G. updates of apr 8 2013
         bv = -0.240 
         Va = 484.5
         R1 = 100.0
         c11= 0.345	!corrected 5/22/2013
         D1 = 0.65
         sigpga = 0.550
c aleatory sigma computed rather than looked up from table.
         if (per(L).le.0.12) then
            Sigma(L)=0.0047*alog(per(L))+0.5522
          else
            Sigma(L)=0.0497*alog(per(L))+0.646
          endif
         if(fix_sigma)sigpga=sigma_fx
         sigmaf=1./sigpga/sqrt2


c********* Distance Dependence ********************

c********* Amplification Factor depending upon style of faulting **********
ccccc      Mec = 1 for strike slip    Normal Faults are treated as strike
ccccc      Mec = 2 for thrust faults
ccccc      Mec = 4 combination of thrust and strike

      IF(Mec.EQ.1.or. Mec.eq.3) THEN
          Frv = 1.0
       ELSE IF(Mec.EQ.2) THEN
          Frv = 1.28
       ELSEIF(Mec.EQ.4) THEN
          Frv = 1.14
      ENDIF
      A = (c1*atan(Mw+c2)+c3)*Frv
      A = A/1.12	!corrected denom. May 21 2013.
      Y1 = alog(A)

c********* Distance R0 Factor ********************
ccccc    Corner distance R0 depends upon magnitude

         R0 = c4 * Mw + c5

c********* Damping D0 Factor **************************
ccccc    Damping is magnitude dependent

         D0 = c6 * cos(c7*(Mw + c8)) + c9

c********* Basin Effect *******************************

c-------  Depth dependance ----------------------------

      Abdepth = 1.4 / sqrt((1.0-(1.5/(Bdepth+0.1))**2)**2

     &           + 1.96*(1.5/(Bdepth+0.1))**2)

c-------  Distance dependance -------------------------

      Abdist = 1. / sqrt((1.0-(40./(x+0.1))**2)**2

     &           + 1.96*(40./(x+0.1))**2)

c-------  Slope of SA at long-periods ----------------
      Slope = 1.763 - 0.25 * atan(1.4*(Bdepth-1.))
c*************** Calculating non-basin PGA *****************

c------- Vs30 site effect --------------------------
         Y1 = Y1 + bv * (alog(Vs/Va))
c-------- Core Filter and Anelastic ----------------

         x0 = x/R0
         x1 = sqrt(x/R1)
         Y = Y1 - 0.5 * alog((1-x0)**2 + 4*D0**2*x0)
     &       - (c11 * x/Q)
       expY=exp(Y)
ccccccc End non-basin PGA Calculation cccccccccccccccccccccccc


c------SA calculations ----------mod coeffs mar 29 2013 SH-----
          e1=-0.0012
c          e2=-0.40854
	e2 = -0.38
          e3= 0.0006
c          e4= 3.63
	e4 = 3.9	!V.G. updates of apr 8 2013
          a1= 0.01686
          a2= 1.2695
          a3= 0.0001
          Dsp=0.75
c          t1= 0.0022
          t1= 0.001
c          t2= 0.63
c          t2= 0.60
	t2 = 0.59
          t3=-0.0005
c          t4=-2.1
	t4 = -2.3	!V.G. updates of apr 8 2013
c          s1=0.001
          s1=0.00
          s2=0.077
          s3=0.3251

           Mu = e1*x+e2*Mw+e3*Vs+e4

          Amp = (a1*Mw+a2)*exp(a3*x)

          Si = s1*x-(s2*Mw+s3)

          Tspo = MAX(0.3,ABS(t1*x+t2*Mw+t3*Vs+t4))	!changed 3/29/2013
          Pern = (per(L)/Tspo)**Slope

          temp1 = (alog(per(L))+Mu)/Si
          temp2 = temp1**2
          SA1 = Amp*exp(-0.5*temp2)
          SA2 = 1./sqrt((1-Pern)**2 + 4.*Dsp**2
     &               *Pern)

          SA = SA1 + SA2
          SA1 = SA*expY
     &              * (1.+ABdist*ABdepth/1.3)
          SA = alog(SA1)
           gndout(1)=SA
         if(l_gnd_ep)then
         gndout(2)= SA+gnd_ep(ide,ime)
         gndout(3)= SA-gnd_ep(ide,ime)
         endif
           sigmaf=1./sigma(L)/sqrt2
	if (l_ms)then
c Play it again, Vladimir, to compute the mean spectrum. New June 24 2013.
	do jp=1,npnga
c The below conditional says, compute if coeffs are available at the period with index jp. This
c will generally be true for the NGA-W relations but less so for older GMPEs with fewer periods.
c  
	jper=imsp(ia,jp)
        if ( jp .eq. jms)then
c use the available information. Frequency dependence of mean and sigma are very limited in GK13.
        meanspec(jp)=gndout(1)
        sigspec(jp)=sigma(L)
	elseif (lmsp(ia,jp)) then
         if (per(jper).le.0.12) then
            sigspec(jp)=0.0047*alog(per(jper))+0.5522
          else
            sigspec(jp)=0.0497*alog(per(jper))+0.646
          endif
           Pern = (per(jper)/Tspo)**Slope

          temp1 = (alog(per(jper))+Mu)/Si
          temp2 = temp1**2
          SA1 = Amp*exp(-0.5*temp2)
          SA2 = 1./sqrt((1-Pern)**2 + 4.*Dsp**2
     &               *Pern)

          SA = SA1 + SA2
          SA1 = SA*expY	!expY contains siteamp effects. Linear.
     &              * (1.+ABdist*ABdepth/1.3)
          meanspec(jp) = alog(SA1)
          endif	!computable period?
          enddo	!loop thru periods
          endif	!want CMS?
          return
        END subroutine gksa13v2

c >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>      
      subroutine getIdriss2013(iper,ip,xmag,rrup,vs30,gndout,sigmaf)
c For pga and SA@many periods to 10s. updated to 2013 coeffs apr 11 2013
c ip is period index in calling program. 
c iper is period index in this subroutine. 
      parameter (pi=3.14159265,sqrt2=1.414213562,vref=760.,nper=22)
      common/epistemic/l_gnd_ep,gnd_ep,ide,ime
      real gnd_ep(3,3),gndout(3)
      logical l_gnd_ep
      common/mech/ss,rev,normal,obl
      real, dimension (nper):: a1, a2, a3, b1,b2, x,g, phi, Period
c 22 periods in getIdriss2013 NGA Dec 2012:
c----  This version assumes v30 in neighborhood of 760 m/sec (linear Vs30 dependency)
c----  uses ln coefficients
c Limits 2012:
c	5 <=M<=8.5
c	Vs30 > 450 m/s; for Vs30>1200, use 1200
c	Rrup <= 150 km (but we go to 200 km).
c
      real, dimension(21) :: meanspec,sigspec
	integer imsp(8,21),kmsp(0:10)
	logical lmsp(0:10,21),l_ms
      common/ms/ia,jms,npnga,l_ms,lmsp,imsp,meanspec,sigspec
      real sig,xmag,T,vs30,vscap
      logical ss,rev,normal,obl
        Period  = (/0.01,0.02,0.03,0.04,0.05,0.075,0.1,0.15,0.2,0.25,0.3,0.4,0.5,0.75,1.0,1.5,2.,3.,4.0,5.,7.5,10./)
       if(xmag .le. 6.75) then
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
                else
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
                endif
c T is constrained spectral period see Idriss EqSpectra Mar 2008 for the details. use aleatory sigma from the article.
c This sigma may be revised.
	T = max(period(iper),0.05)
	T = min(T,3.0)
	xmagc=max(5.0,min(xmag,7.5))
        sig = 1.18 + 0.035*alog(T) - 0.06 * xmagc       !see P Powers email jan 21 2014
C	sig = 1.28 + 0.05*alog(T) - 0.08 * xmagc
          sigmaf= 1./sig/sqrt2
          vscap=min(vs30,1200.)
c-- 
c 2nd line: extra mag scaling, anelastic attn scaling and site -term scaling
          gnd= a1(iper)+a2(iper)*xmag-(b1(iper)+b2(iper)*xmag)*alog(rrup+10.)
     & + a3(iper)*(8.5-xmag)**2+g(iper)*rrup+ x(iper)*alog(vscap)
c sense of slip sensitivity: oblique-reverse or reverse slip. Otherwise none.
          if(rev.or.obl)then
          gnd = gnd+ phi(iper)
          endif
        gndout(1)=gnd
         if(l_gnd_ep)then
         gndout(2)= gnd+gnd_ep(ide,ime)
         gndout(3)= gnd-gnd_ep(ide,ime)
         endif
	if (l_ms)then
c Play it again, IMIdriss, to compute the mean spectrum. New June 24 2013.
	do jp=1,npnga
c The below conditional says, compute if coeffs are available at the period with index jp. This
c will generally be true for the NGA-W relations but less so for older GMPEs with fewer periods.
c  
	jper=imsp(ia,jp)
        if ( jp .eq. jms)then
c use the available information. Frequency dependence of mean and sigma require the loop.
        meanspec(jp)=gndout(1)
        sigspec(jp)=sig
	elseif (lmsp(ia,jp)) then
	T = max(period(jper),0.05)
	T = min(T,3.0)
	sigspec(jp) = 1.28 + 0.05*alog(T) - 0.08 * xmag
c-- 
c 2nd line: extra mag scaling, anelastic attn scaling and site -term scaling
          gnd= a1(jper)+a2(jper)*xmag-(b1(jper)+b2(jper)*xmag)*alog(rrup+10.)
     & + a3(jper)*(8.5-xmag)**2+g(jper)*rrup+ x(jper)*alog(vscap)
c sense of slip sensitivity: oblique-reverse or reverse slip. Otherwise none.
          if(rev.or.obl)then
          gnd = gnd+ phi(jper)
          endif
          meanspec(jp) = gnd
c        print *,jper,Period(jper),exp(meanspec(jp)),sigspec(jp),'idriss'
          endif	!computable period
	enddo	!loop thru periods
	endif	!CMS computations requested?
        return
	end subroutine getIdriss2013

      
c-----------------------------------------------------------------------
c July 30 2013 version. CY2013
c
        subroutine CY2013_NGA(iprd, M, R_Rup, R_JB, R_x, V_S30,
     1                   F_Measured, F_Inferred, deltaZ1, DELTA, Z_TOR,
     1                   F_RV, F_NM, cDPP, gndout, tau, sigma_NL0, sigmaf)

        implicit none
        integer nprd
        real pi,d2r,sqrt2
        parameter (nprd=24,pi=3.14159265,d2r=17.45329252e-3,sqrt2=1.414213562)
c Predictor variables
c cDPP = source directivity parameter. Need guidance on what to use Mar 6 2013.
c	Without such guidance, set direct=false, meaning do not use the cDPP model.
c ip = global period index
c iprd = local period index corresponding to below coeff. vectors.
c Conditional Mean Spectrum: calculated if l_ms = .true. in the /ms/ common block.
c  Added CMS calculations june 24 2013. SH.
c    
      common/epistemic/l_gnd_ep,gnd_ep,ide,ime
      integer ide,ime,ip,ia,jms,npnga,jp,jper
      real, dimension(21) :: meanspec,sigspec
	integer imsp(8,21),kmsp(0:10)
	logical lmsp(0:10,21),l_ms
      common/ms/ia,jms,npnga,l_ms,lmsp,imsp,meanspec,sigspec
       common/fix_sigma/fix_sigma,sigma_fx
       common/sdi/sdi,dy_sdi,fac_sde
      real gnd_ep(3,3),gndout(3), sigmaf,sigma_fx
      logical l_gnd_ep,fix_sigma,direct/.false./,sdi
        real PERIOD, M, Width, R_rup, R_JB, R_x, V_S30, F_Measured,
     1       F_Inferred, Z1, DELTA, Z_TOR, F_RV, F_NM, deltaZ1, cDPP
	real fac_sde,dy_sdi,rhat,sdisd,sde,sdi_ratio
c Model cofficients
        real, dimension(nprd):: prd,
     1       c1, c1a, c1b,  c1c, c1d,c2,
     1       c3, cn,  cM,  c4,
     1       c4a,cRB, c5,  c6,
     1       cHM,c7, c7b, c8,  c8a, c8b,
     1       c9,  c9a, c9b, c11, c11b,
     1       cgamma1, cgamma2, cgamma3,
     1       phi1, phi2, phi3, phi4,
     1       phi5, phi6, phi7, phi8,
     1       tau1, tau2,
     1       sigma1, sigma2, sigma3
        real cc, gamma, cosDELTA, psa, psa_ref, NL0, tau, sigma_NL0,
     1       total_app,mZ_TOR,coshM,deltaZ_TOR
        real r1, r2, r3, r4, fw, hw, fd, a, b, c, rkdepth
        integer iprd, sa

c updated  coeffs on july 30 2013
      data prd     /
     1              0.0100, 0.0200, 0.0300, 0.0400, 0.0500,
     1              0.0750, 0.1000, 0.1200, 0.1500, 0.1700,
     1              0.2000, 0.2500, 0.3000, 0.4000, 0.5000,
     1              0.7500, 1.0000, 1.5000, 2.0000, 3.0000,
     1              4.0000, 5.0000, 7.5000,10.0000/
      data c1      /
     1             -1.5065, -1.4798, -1.2972, -1.1007, -0.9292,
     1             -0.6580, -0.5613, -0.5342, -0.5462, -0.5858,
     1             -0.6798, -0.8663, -1.0514, -1.3794, -1.6508,
     1             -2.1511, -2.5365, -3.0686, -3.4148, -3.9013,
     1             -4.2466, -4.5143, -5.0009, -5.3461/
      data c1a     /
     1             0.1650,  0.1650,  0.1650,  0.1650,  0.1650,
     1             0.1650,  0.1650,  0.1650,  0.1650,  0.1650,
     1             0.1650,  0.1650,  0.1650,  0.1650,  0.1650,
     1             0.1650,  0.1650,  0.1650,  0.1645,  0.1168,
     1             0.0732,  0.0484,  0.0220,  0.0124/
      data c1b     /
     1             -0.2550, -0.2550, -0.2550, -0.2550, -0.2550,
     1             -0.2540, -0.2530, -0.2520, -0.2500, -0.2480,
     1             -0.2449, -0.2382, -0.2313, -0.2146, -0.1972,
     1             -0.1620, -0.1400, -0.1184, -0.1100, -0.1040,
     1             -0.1020, -0.1010, -0.1010, -0.1000/
      data c1c     /
     1             -0.1650, -0.1650, -0.1650, -0.1650, -0.1650,
     1             -0.1650, -0.1650, -0.1650, -0.1650, -0.1650,
     1             -0.1650, -0.1650, -0.1650, -0.1650, -0.1650,
     1             -0.1650, -0.1650, -0.1650, -0.1645, -0.1168,
     1             -0.0732, -0.0484, -0.0220, -0.0124/
      data c1d     /
     1              0.2550,  0.2550,  0.2550,  0.2550,  0.2550,
     1              0.2540,  0.2530,  0.2520,  0.2500,  0.2480,
     1              0.2449,  0.2382,  0.2313,  0.2146,  0.1972,
     1              0.1620,  0.1400,  0.1184,  0.1100,  0.1040,
     1              0.1020,  0.1010,  0.1010,  0.1000/
      data c2      /
     1              1.06, 1.06, 1.06, 1.06, 1.06,
     1              1.06, 1.06, 1.06, 1.06, 1.06,
     1              1.06, 1.06, 1.06, 1.06, 1.06,
     1              1.06, 1.06, 1.06, 1.06, 1.06,
     1              1.06, 1.06, 1.06, 1.06/
      data cn      /
     1             16.0875, 15.7118, 15.8819, 16.4556, 17.6453,
     1             20.1772, 19.9992, 18.7106, 16.6246, 15.3709,
     1             13.7012, 11.2667,  9.1908,  6.5459,  5.2305,
     1              3.7896,  3.3024,  2.8498,  2.5417,  2.1488,
     1              1.8957,  1.7228,  1.5737,  1.5265/
      data cM      /
     1             4.9993,  4.9993,  4.9993,  4.9993,  4.9993,
     1             5.0031,  5.0172,  5.0315,  5.0547,  5.0704,
     1             5.0939,  5.1315,  5.1670,  5.2317,  5.2893,
     1             5.4109,  5.5106,  5.6705,  5.7981,  5.9983,
     1             6.1552,  6.2856,  6.5428,  6.7415/
      data c3      /
     1             1.9636,  1.9636,  1.9636,  1.9636,  1.9636,
     1             1.9636,  1.9636,  1.9795,  2.0362,  2.0823,
     1             2.1521,  2.2574,  2.3440,  2.4709,  2.5567,
     1             2.6812,  2.7474,  2.8161,  2.8514,  2.8875,
     1             2.9058,  2.9169,  2.9320,  2.9396/
      data c4      /
     1              -2.1, -2.1, -2.1, -2.1, -2.1,
     1              -2.1, -2.1, -2.1, -2.1, -2.1,
     1              -2.1, -2.1, -2.1, -2.1, -2.1,
     1              -2.1, -2.1, -2.1, -2.1, -2.1,
     1              -2.1, -2.1, -2.1, -2.1/
      data c4a     /
     1              -0.5, -0.5, -0.5, -0.5, -0.5,
     1              -0.5, -0.5, -0.5, -0.5, -0.5,
     1              -0.5, -0.5, -0.5, -0.5, -0.5,
     1              -0.5, -0.5, -0.5, -0.5, -0.5,
     1              -0.5, -0.5, -0.5, -0.5/
      data cRB     /
     1               50, 50, 50, 50, 50,
     1               50, 50, 50, 50, 50,
     1               50, 50, 50, 50, 50,
     1               50, 50, 50, 50, 50,
     1               50, 50, 50, 50/
      data c5      /
     1             6.4551, 6.4551, 6.4551, 6.4551, 6.4551,
     1             6.4551, 6.8305, 7.1333, 7.3621, 7.4365,
     1             7.4972, 7.5416, 7.5600, 7.5735, 7.5778,
     1             7.5808, 7.5814, 7.5817, 7.5818, 7.5818,
     1             7.5818, 7.5818, 7.5818, 7.5818/
      data cHM     /
     1             3.0956, 3.0963, 3.0974, 3.0988, 3.1011,
     1             3.1094, 3.2381, 3.3407, 3.4300, 3.4688,
     1             3.5146, 3.5746, 3.6232, 3.6945, 3.7401,
     1             3.7941, 3.8144, 3.8284, 3.8330, 3.8361,
     1             3.8369, 3.8376, 3.8380, 3.8380/
      data c6      /
     1             0.4908,  0.4925,  0.4992,  0.5037, .5048,
     1             0.5048,  0.5048,  0.5048,  0.5045, .5036,
     1             0.5016,  0.4971,  0.4919,  0.4807, .4707,
     1             0.4575,  0.4522,  0.4501,  0.4500, .4500,
     1             0.4500,  0.4500,  0.4500,  0.4500/
      data c7      /
     1             0.0352, 0.0352, 0.0352, 0.0352, 0.0352,
     1             0.0352, 0.0352, 0.0352, 0.0352, 0.0352,
     1             0.0352, 0.0352, 0.0352, 0.0352, 0.0352,
     1             0.0352, 0.0352, 0.0352, 0.0352, 0.0160,
     1             0.0062, 0.0029, 0.0007, 0.0003/
      data c7b     /
     1             0.0462,  0.0472,  0.0533,  0.0596,  0.0639,
     1             0.0630,  0.0532,  0.0452,  0.0345,  0.0283,
     1             0.0202,  0.0090, -0.0004, -0.0155, -0.0278,
     1            -0.0477, -0.0559, -0.0630, -0.0665, -0.0516,
     1            -0.0448, -0.0424, -0.0348, -0.0253/
      data c8      /
     1             0.2154,  0.2154,  0.2154,  0.2154,  0.2154,
     1             0.2154,  0.2154,  0.2154,  0.2154,  0.2154,
     1             0.2154,  0.2154,  0.2154,  0.2154,  0.2154,
     1             0.2154,  0.2154,  0.2154,  0.2154,  0.2154,
     1             0.2154,  0.2154,  0.2154,  0.2154/
      data c8a      /
     1             0.2695,  0.2695,  0.2695,  0.2695,  0.2695,
     1             0.2695,  0.2695,  0.2695,  0.2695,  0.2695,
     1             0.2695,  0.2695,  0.2695,  0.2695,  0.2695,
     1             0.2695,  0.2695,  0.2695,  0.2695,  0.2695,
     1             0.2695,  0.2695,  0.2695,  0.2695/
      data c8b     /
     1             0.4833,  1.2144,  1.6421,  1.9456,  2.1810,
     1             2.6087,  2.9122,  3.1045,  3.3399,  3.4719,
     1             3.6434,  3.8787,  4.0711,  4.3745,  4.6099,
     1             5.0376,  5.3411,  5.7688,  6.0723,  6.5000,
     1             6.8035,  7.0389,  7.4666,  7.7700/
      data c9      /
     1             0.9228,  0.9296,  0.9396,  0.9661,  0.9794,
     1             1.0260,  1.0177,  1.0008,  0.9801,  0.9652,
     1             0.9459,  0.9196,  0.8829,  0.8302,  0.7884,
     1             0.6754,  0.6196,  0.5101,  0.3917,  0.1244,
     1             0.0086,  0.0000,  0.0000,  0.0000/
      data c9a     /
     1             0.1202,  0.1217,  0.1194,  0.1166,  0.1176,
     1             0.1171,  0.1146,  0.1128,  0.1106,  0.1150,
     1             0.1208,  0.1208,  0.1175,  0.1060,  0.1061,
     1             0.1000,  0.1000,  0.1000,  0.1000,  0.1000,
     1             0.1000,  0.1000,  0.1000,  0.1000/
      data c9b     /
     1             6.8607,  6.8697,  6.9113,  7.0271,  7.0959,
     1             7.3298,  7.2588,  7.2372,  7.2109,  7.2491,
     1             7.2988,  7.3691,  6.8789,  6.5334,  6.5260,
     1             6.5000,  6.5000,  6.5000,  6.5000,  6.5000,
     1             6.5000,  6.5000,  6.5000,  6.5000/
      data c11     /
     1                0.0,     0.0,     0.0,     0.0,     0.0,
     1                0.0,     0.0,     0.0,     0.0,     0.0,
     1                0.0,     0.0,     0.0,     0.0,     0.0,
     1                0.0,     0.0,     0.0,     0.0,     0.0,
     1                0.0,     0.0,     0.0,     0.0/
      data c11b    /
     1            -0.4536, -0.4536, -0.4536, -0.4536, -0.4536,
     1            -0.4536, -0.4536, -0.4536, -0.4536, -0.4536,
     1            -0.4440, -0.3539, -0.2688, -0.1793, -0.1428,
     1            -0.1138, -0.1062, -0.1020, -0.1009, -0.1003,
     1            -0.1001, -0.1001, -0.1000, -0.1000/
      data cgamma1 /
     1            -0.007146, -0.007249, -0.007869, -0.008316, -0.008743,
     1            -0.009537, -0.009830, -0.009913, -0.009896, -0.009787,
     1            -0.009505, -0.008918, -0.008251, -0.007267, -0.006492,
     1            -0.005147, -0.004277, -0.002979, -0.002301, -0.001344,
     1            -0.001084, -0.001010, -0.000964, -0.000950/
      data cgamma2 /
     1            -0.006758, -0.006758, -0.006758, -0.006758, -0.006758,
     1            -0.006190, -0.005332, -0.004732, -0.003806, -0.003280,
     1            -0.002690, -0.002128, -0.001812, -0.001274, -0.001074,
     1            -0.001115, -0.001197, -0.001675, -0.002349, -0.003306,
     1            -0.003566, -0.003640, -0.003686, -0.003700/
      data cgamma3 /
     1             4.2542,  4.2386,  4.2519,  4.2960,  4.3578,
     1             4.5455,  4.7603,  4.8963,  5.0644,  5.1371,
     1             5.1880,  5.2164,  5.1954,  5.0899,  4.7854,
     1             4.3304,  4.1667,  4.0029,  3.8949,  3.7928,
     1             3.7443,  3.7090,  3.6632,  3.6230/
      data phi1    /
     1             -0.5210, -0.5055, -0.4368, -0.3752, -0.3469,
     1             -0.3747, -0.4440, -0.4895, -0.5477, -0.5922,
     1             -0.6693, -0.7766, -0.8501, -0.9431, -1.0044,
     1             -1.0602, -1.0941, -1.1142, -1.1154, -1.1081,
     1             -1.0603, -0.9872, -0.8274, -0.7053/
      data phi2    /
     1             -0.1417, -0.1364, -0.1403, -0.1591, -0.1862,
     1             -0.2538, -0.2943, -0.3077, -0.3113, -0.3062,
     1             -0.2927, -0.2662, -0.2405, -0.1975, -0.1633,
     1             -0.1028, -0.0699, -0.0425, -0.0302, -0.0129,
     1             -0.0016,  0.0000,  0.0000,  0.0000/
      data phi3    /
     1             -0.007010,-0.007279,-0.007354,-0.006977,-0.006467,
     1             -0.005734,-0.005604,-0.005696,-0.005845,-0.005959,
     1             -0.006141,-0.006439,-0.006704,-0.007125,-0.007435,
     1             -0.008120,-0.008444,-0.007707,-0.004792,-0.001828,
     1             -0.001523,-0.001440,-0.001369,-0.001361/
      data phi4    /
     1              0.102151, 0.108360, 0.119888, 0.133641, 0.148927,
     1              0.190596, 0.230662, 0.253169, 0.266468, 0.265060,
     1              0.255253, 0.231541, 0.207277, 0.165464, 0.133828,
     1              0.085153, 0.058595, 0.031787, 0.019716, 0.009643,
     1              0.005379, 0.003223, 0.001134, 0.000515/
      data phi5    /
     1              0.0000, 0.0000, 0.0000, 0.0000, 0.0000,
     1              0.0000, 0.0000, 0.0000, 0.0000, 0.0000,
     1              0.0000, 0.0000, 0.0010, 0.0040, 0.0100,
     1              0.0340, 0.0670, 0.1430, 0.2030, 0.2770,
     1              0.3090, 0.3210, 0.3290, 0.3300/
      data phi6    /
     1              300.00, 300.00, 300.00, 300.00, 300.00,
     1              300.00, 300.00, 300.00, 300.00, 300.00,
     1              300.00, 300.00, 300.00, 300.00, 300.00,
     1              300.00, 300.00, 300.00, 300.00, 300.00,
     1              300.00, 300.00, 300.00, 300.00/
      data tau1    /
     1               0.4000,  0.4026,  0.4063,  0.4095,  0.4124,
     1               0.4179,  0.4219,  0.4244,  0.4275,  0.4292,
     1               0.4313,  0.4341,  0.4363,  0.4396,  0.4419,
     1               0.4459,  0.4484,  0.4515,  0.4534,  0.4558,
     1               0.4574,  0.4584,  0.4601,  0.4612/
      data tau2    /
     1               0.2600,  0.2637,  0.2689,  0.2736,  0.2777,
     1               0.2855,  0.2913,  0.2949,  0.2993,  0.3017,
     1               0.3047,  0.3087,  0.3119,  0.3165,  0.3199,
     1               0.3255,  0.3291,  0.3335,  0.3363,  0.3398,
     1               0.3419,  0.3435,  0.3459,  0.3474/
      data sigma1  /
     1               0.4912,  0.4904,  0.4988,  0.5049,  0.5096,
     1               0.5179,  0.5236,  0.5270,  0.5308,  0.5328,
     1               0.5351,  0.5377,  0.5395,  0.5422,  0.5433,
     1               0.5294,  0.5105,  0.4783,  0.4681,  0.4617,
     1               0.4571,  0.4535,  0.4471,  0.4426/
      data sigma2  /
     1               0.3762,  0.3762,  0.3849,  0.3910,  0.3957,
     1               0.4043,  0.4104,  0.4143,  0.4191,  0.4217,
     1               0.4252,  0.4299,  0.4338,  0.4399,  0.4446,
     1               0.4533,  0.4594,  0.4680,  0.4681,  0.4617,
     1               0.4571,  0.4535,  0.4471,  0.4426/
      data sigma3  /
     1               0.8000,  0.8000,  0.8000,  0.8000,  0.8000,
     1               0.8000,  0.8000,  0.8000,  0.8000,  0.8000,
     1               0.8000,  0.7999,  0.7997,  0.7988,  0.7966,
     1               0.7792,  0.7504,  0.7136,  0.7035,  0.7006,
     1               0.7001,  0.7000,  0.7000,  0.7000/



	ip = 1 	!(only one period in deagg)
	fd=0.0	!forward directvity not computable without more knowledge
        cosDELTA = cos(DELTA*d2r)
c Center Z_TOR on the Z_TOR-M relation in Chiou and Youngs (2013)
        if (F_RV.EQ.1) then
          if (M .le. 5.849) then	!corrected from 5.869 May 16 2013
              mZ_TOR = 2.704*2.704
          else
              mZ_TOR = max(2.704-1.226*(M-5.849), 0.)
              mZ_TOR = mZ_TOR * mZ_TOR
          endif
        else
          if (M .le. 4.970) then
              mZ_TOR = 2.673*2.673
          else
              mZ_TOR = max(2.673-1.136*(M-4.970), 0.)
              mZ_TOR = mZ_TOR * mZ_TOR
          endif
        endif
        if (Z_TOR .EQ. -999) Z_TOR = mZ_TOR
        deltaZ_TOR = Z_TOR - mZ_TOR


c Magnitude scaling
        r1 = c1(iprd) + c2(iprd) * (M-6.0) +
     1       (c2(iprd)-c3(iprd))/cn(iprd) *
     1             log(1.0 + exp(cn(iprd)*(cM(iprd)-M)))

c Near-field magnitude and distance scaling
        cc = c5(iprd) * cosh(c6(iprd)*max(M-cHM(iprd),0.))
        r2 = c4(iprd) * log(R_Rup + cc)

c Far-field distance scaling
        gamma = cgamma1(iprd) +
     1          cgamma2(iprd)/cosh(max(M-cgamma3(iprd),0.))
        r3 = (c4a(iprd)-c4(iprd)) *
     1            log(sqrt(R_Rup*R_Rup+cRB(iprd)*cRB(iprd))) +
     1       R_Rup * gamma

c Scaling with other source variables (F_RV, F_NM, and Z_TOR)
        coshM = cosh(2.0*max(M-4.5,0.0))
        r4 = (c1a(iprd)+c1c(iprd)/coshM) * F_RV +
     1       (c1b(iprd)+c1d(iprd)/coshM) * F_NM +
     1       (c7(iprd) +c7b(iprd)/coshM) * deltaZ_TOR +
     1       (c11(iprd)+c11b(iprd)/coshM)* cosDELTA**2

c HW effect
        if (R_x .lt. 0) then
         hw = 0.0
        else
         hw = c9(iprd) * cosDELTA *
     1        (c9a(iprd)+(1-c9a(iprd)) *tanh(R_x/c9b(iprd))) *
     1        (1.0 - sqrt(R_JB**2+Z_TOR**2)/(R_Rup + 1.0))
        endif

c Directivity effect
        fd = c8(iprd) *
     1       max(1-max(R_Rup-40.0,0.0)/30.0, 0.0) *
     1       min(max(M-5.5,0.0)/0.8, 1.0) *
     1       exp(-c8a(iprd)*(M-c8b(iprd))**2) * cDPP


        psa_ref = r1+r2+r3+r4+hw+fd
c        write (*,'(7f10.4)') r1, r2, r3, r4, hw, fd, psa_ref

c Soil effect: linear response
        a = phi1(iprd) * min(log(V_S30/1130.), 0.)

c Soil effect: nonlinear response
        b = phi2(iprd) *
     1(exp(phi3(iprd)*(min(V_S30,1130.)-360.))-exp(phi3(iprd)*(1130.-360.)))

        c = phi4(iprd)

c Corrections to ln(Vs30) scaling
c
c
        rkdepth = phi5(iprd) * ( 1.0 - exp(-deltaZ1/phi6(iprd) ) ) 


c....... Polulation mean of ln(psa) (eta=0)
c keep the response logged.
c        psa = exp(psa_ref + (a + b * log((exp(psa_ref)+c)/c)) + rkdepth)
        psa = psa_ref + (a + b * log((exp(psa_ref)+c)/c)) + rkdepth
        psa_ref = exp(psa_ref)	! using in NL0 computation below.
	gndout(1)=psa
c....... Total variance of ln(psa) about the population mean:
c          The approximate method (Equation 21)

        NL0 = b * psa_ref/(psa_ref+c)
c newer version uses M=6.5 rather than M=7.0
        tau = tau1(iprd) +
     1           (tau2(iprd)-tau1(iprd))/1.5*(min(max(M,5.),6.5)-5.)

        sigma_NL0 = sigma1(iprd) +
     1           (sigma2(iprd)-sigma1(iprd))/1.5*(min(max(M,5.),6.5)-5.)
        sigma_NL0 = sigma_NL0 *
     1        sqrt(0.7*F_Measured+F_Inferred*sigma3(iprd)+(1.0+NL0)**2)

        total_app = sqrt((tau*(1.0+NL0))**2+sigma_NL0**2)
       if(sdi)then
       sde=gndout(1)+fac_sde	!fac_sde is log(T**2/(4pisq))
       rhat = min(10.,exp(sde)/dy_sdi)	!10 is an upper bound for rhat.
       gndout(1) = sdi_ratio(prd(iprd),M,rhat,total_app,sdisd) + sde
       sigmaf=1./sdisd/sqrt2	!use sdi for all gnd_ep branches
         else
	sigmaf=1./sqrt2/total_app
         endif	!if(sdi)
         if(l_gnd_ep)then
         gndout(2)= gndout(1)+gnd_ep(ide,ime)
         gndout(3)= gndout(1)-gnd_ep(ide,ime)
         endif
	if (l_ms)then
c Play it again, Brian Chiou, to compute the mean spectrum. New June 24 2013.
	do jp=1,npnga
c The below conditional says, compute if coeffs are available at the period with index jp. This
c will generally be true for the NGA-W relations but less so for older GMPEs with fewer periods.
c  
	jper=imsp(ia,jp)
        if ( jp .eq. jms)then
c use the available information. Frequency dependence of mean and sigma require the loop.
        meanspec(jp)=gndout(1)
        sigspec(jp)=total_app
	elseif (lmsp(ia,jp)) then

c Magnitude scaling
        r1 = c1(jper) + c2(jper) * (M-6.0) +
     1       (c2(jper)-c3(jper))/cn(jper) *
     1             log(1.0 + exp(cn(jper)*(cM(jper)-M)))

c Near-field magnitude and distance scaling
        cc = c5(jper) * cosh(c6(jper)*max(M-cHM(jper),0.))
        r2 = c4(jper) * log(R_Rup + cc)

c Far-field distance scaling
        gamma = cgamma1(jper) +
     1          cgamma2(jper)/cosh(max(M-cgamma3(jper),0.))
        r3 = (c4a(jper)-c4(jper)) *
     1            log(sqrt(R_Rup*R_Rup+cRB(jper)*cRB(jper))) +
     1       R_Rup * gamma

c Scaling with other source variables (F_RV, F_NM, and Z_TOR)
        coshM = cosh(2.0*max(M-4.5,0.0))
        r4 = (c1a(jper)+c1c(jper)/coshM) * F_RV +
     1       (c1b(jper)+c1d(jper)/coshM) * F_NM +
     1       (c7(jper) +c7b(jper)/coshM) * deltaZ_TOR +
     1       (c11(jper)+c11b(jper)/coshM)* cosDELTA**2

c HW effect
        if (R_x .lt. 0) then
         hw = 0.0
        else
          hw = c9(jper) * (cosDELTA) * (c9a(jper)+(1.-c9a(jper))
     1        *tanh(R_x/c9b(jper))) *
     1        (1.0 - sqrt(R_JB**2+Z_TOR**2)/(R_Rup + 1.0))
c the above is the only change to the fortran of CY13 in april. below is the March vers...
        endif

c Directivity effect
        fd = c8(jper) *
     1       max(1-max(R_Rup-40.0,0.0)/30.0, 0.0) *
     1       min(max(M-5.5,0.0)/0.8, 1.0) *
     1       exp(-c8a(jper)*(M-c8b(jper))**2) * cDPP


        psa_ref = r1+r2+r3+r4+hw+fd
c        write (*,'(7f10.4)') r1, r2, r3, r4, hw, fd, psa_ref

c Soil effect: linear response
        a = phi1(jper) * min(log(V_S30/1130), 0.0)

c Soil effect: nonlinear response
        b = phi2(jper) *
     1(exp(phi3(jper)*(min(V_S30,1130.)-360.))-exp(phi3(jper)*(1130.-360.)))

        c = phi4(jper)

c Corrections to ln(Vs30) scaling
c
c
        rkdepth = phi5(jper) * ( 1.0 - exp(-deltaZ1/phi6(jper) ) ) 


c....... Polulation mean of ln(psa) (eta=0)
c keep the response logged.
c        psa = exp(psa_ref + (a + b * log((exp(psa_ref)+c)/c)) + rkdepth)
        psa = psa_ref + (a + b * log((exp(psa_ref)+c)/c)) + rkdepth
        psa_ref = exp(psa_ref)	! using in NL0 computation below.
	meanspec(jp) =psa
        NL0 = b * psa_ref/(psa_ref+c)
c newer version uses M=6.5 rather than M=7.0
        tau = tau1(jper) +
     1           (tau2(jper)-tau1(jper))/2.25*(min(max(M,5.),6.5)-5.)
        sigma_NL0 = sigma1(jper) +
     1           (sigma2(jper)-sigma1(jper))/2.25*(min(max(M,5.),6.5)-5.)
        sigma_NL0 = sigma_NL0 *
     1        sqrt(0.7*F_Measured+F_Inferred*sigma3(jper)+(1.0+NL0)**2)

        sigspec(jp) = sqrt((tau*(1.0+NL0))**2+sigma_NL0**2)
        endif	!computable?
        enddo	!loop thru periods
        endif	!want CMS?
        return

        end subroutine CY2013_NGA

	subroutine bssa2013drv(indx_pga,indx_per,m,rjb,v30,z1,mech,iregion,lny,sigmaf)
	real sqrt2
		parameter (npermx=107,sqrt2=1.414213562)
c      real  c(3)
c input z1 depth to 1 km/s Vs in units m. From Chiou Z1cal
c this driver code runs the NGAW BSSA model for PGA and then for period with index indx_per
c the outputs are lny = logged SA, and sigmaf =1/sigma/sqrt2 
c ip is the global period index, used in SDI calcs for example. 
c Conditional Mean Spectrum: calculated if l_ms = .true. in the ms common block.
c    
      common/sdi/sdi,dy_sdi,fac_sde
      real e(0:6)
      
      real, dimension(npermx):: T,clin, vclin, vref,
     :     c1,c2,c3,phi2, phi3,e0,e1,e2,e3,e4,e5,e6,
     :     Mh,f1, f3, f4, f5, f6,f7,R1,R2, h,Dc3CATW,Dc3China,Dc3Italy,
     :     phi1, Mref,Rref,delta_c3,delta_phiR, delta_phiV,
     :     tau1, tau2
      real, dimension(3):: c
     
      logical sdi
      real m, logy_pred, rjb, z1,dy_sdi
      real lny, lnyt, sigmaft, gnd, sdisd,sig, rhat
        real :: fac_sde
     
      integer mech, iregion,ip
       integer ide,ime,ia,jms,npnga,jp,jper
      real, dimension(21) :: meanspec,sigspec
	integer imsp(8,21),kmsp(0:10)
	logical lmsp(0:10,21),l_ms
      common/ms/ia,jms,npnga,l_ms,lmsp,imsp,meanspec,sigspec


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
     :  phi, tau, sigmaf,
     :  yg, 
     :  ycgs,
     :  pi, twopi,
     :  gspread,
     :  weight

c updated coeffs. May 20 2013.     
	T=(/-1.,0.0,0.01,0.02,0.022,0.025,0.029,0.03,0.032,0.035,0.036,0.04,
     +0.042,0.044,0.045,0.046,0.048,0.05,0.055,0.06,0.065,0.067,0.07,0.075,
     +0.08,0.085,0.09,0.095,0.1,0.11,0.12,0.13,0.133,0.14,0.15,0.16,0.17,0.18,
     +0.19,0.2,0.22,0.24,0.25,0.26,0.28,0.29,0.3,0.32,0.34,0.35,0.36,0.38,0.4,
     +0.42,0.44,0.45,0.46,0.48,0.5,0.55,0.6,0.65,0.667,0.7,0.75,0.8,0.85,0.9,
     +0.95,1.0,1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,2.,2.2,2.4,2.5,2.6,2.8,3.0,3.2,
     +3.4,3.5,3.6,3.8,4.0,4.2,4.4,4.6,4.8,5.,5.5,6.,6.5,7.,7.5,8.,8.5,9.,9.5,10.0/)
	e0=(/5.037,0.4473,0.4534,0.48598,0.49866,0.52283,0.55949,0.56916,0.58802,
     +0.61636,0.62554,0.66281,0.68087,0.69882,0.70822,0.71779,0.73574,0.75436,
     +0.7996,0.84394,0.88655,0.9027,0.92652,0.96447,1.0003,1.034,1.0666,1.0981,
     +1.1268,1.1785,1.223,1.2596,1.2692,1.2883,1.3095,1.3235,1.3306,1.3327,1.3307,
     +1.3255,1.3091,1.2881,1.2766,1.2651,1.2429,1.2324,1.2217,1.2007,1.179,
     +1.1674,1.1558,1.1305,1.1046,1.0782,1.0515,1.0376,1.0234,0.99719,0.96991,
     +0.9048,0.84165,0.78181,0.76262,0.72513,0.66903,0.61346,0.55853,0.50296,
     +0.44701,0.3932,0.28484,0.1734,0.06152,-0.04575,-0.14954,-0.2486,-0.34145,
     +-0.42975,-0.51276,-0.58669,-0.72143,-0.8481,-0.90966,-0.96863,-1.0817,
     +-1.1898,-1.2914,-1.386,-1.4332,-1.4762,-1.5617,-1.6388,-1.7116,-1.7798,
     +-1.8469,-1.9063,-1.966,-2.1051,-2.2421,-2.3686,-2.4827,-2.5865,-2.6861,
     +-2.782,-2.8792,-2.9769,-3.0702/)

	e1=(/5.078,0.4856,0.4916,0.52359,0.53647,0.5613,0.59923,0.6092,0.62875,
     +0.65818,0.66772,0.70604,0.72443,0.74277,0.75232,0.76202,0.78015,0.79905,
     +0.8445,0.88884,0.93116,0.94711,0.97057,1.0077,1.0426,1.0755,1.1076,1.1385,
     +1.1669,1.2179,1.2621,1.2986,1.3082,1.327,1.3481,1.3615,1.3679,1.3689,
     +1.3656,1.359,1.3394,1.315,1.3017,1.2886,1.2635,1.2517,1.2401,1.2177,
     +1.1955,1.1836,1.172,1.1468,1.1214,1.0955,1.0697,1.0562,1.0426,1.0172,
     +0.99106,0.9283,0.86715,0.80876,0.78994,0.75302,0.69737,0.64196,0.58698,
     +0.53136,0.47541,0.4218,0.31374,0.20259,0.09106,-0.0157,-0.11866,-0.21672,
     +-0.3084,-0.39558,-0.47731,-0.55003,-0.6822,-0.8069,-0.86765,-0.92577,-1.0367,-1.142,
     +-1.2406,-1.3322,-1.3778,-1.4193,-1.5014,-1.5748,-1.6439,-1.7089,-1.7731,-1.8303,-1.8882,
     +-2.0232,-2.1563,-2.2785,-2.3881,-2.4874,-2.5829,-2.6752,-2.7687,-2.8634,-2.9537/)
	e2=(/4.849,0.2459,0.2519,0.29707,0.31347,0.34426,0.39146,0.40391,0.42788,0.46252,
     +0.47338,0.51532,0.53445,0.55282,0.56222,0.57166,0.58888,0.60652,0.6477,0.68562,0.71941,
     +0.73171,0.7494,0.77678,0.80161,0.82423,0.84591,0.86703,0.8871,0.92702,0.96616,1.0031,
     +1.0135,1.036,1.0648,1.0876,1.104,1.1149,1.1208,1.122,1.1133,1.0945,1.0828,1.071,1.0476,
     +1.0363,1.0246,1.0011,0.97677,0.9638,0.9512,0.9244,0.89765,0.87067,0.84355,0.82941,0.81509,
     +0.7886,0.7615,0.6984,0.63875,0.58231,0.56422,0.52878,0.47523,0.42173,0.36813,0.31376,
     +0.25919,0.207,0.10182,-0.006195,-0.11345,-0.2155,-0.3138,-0.40682,-0.49295,-0.57388,
     +-0.64899,-0.71466,-0.83003,-0.9326,-0.98228,-1.0313,-1.1301,-1.23,-1.3255,-1.415,-1.4599,
     +-1.5014,-1.5865,-1.6673,-1.7451,-1.8192,-1.8923,-1.9573,-2.0245,-2.1908,-2.3659,-2.5322,
     +-2.6818,-2.8176,-2.9438,-3.0597,-3.1713,-3.2785,-3.3776/)
	e3=(/5.033,0.4539,0.4599,0.48875,0.49973,0.51999,0.54995,0.55783,0.5733,0.59704,0.60496,
     +0.63828,0.65505,0.67225,0.68139,0.69076,0.70854,0.72726,0.7737,0.82067,0.86724,0.88526,0.91227,
     +0.9563,0.99818,1.0379,1.0762,1.1127,1.1454,1.203,1.2502,1.2869,1.2961,1.3137,1.3324,1.3437,1.3487,
     +1.3492,1.3463,1.3414,1.3281,1.3132,1.3052,1.2972,1.2815,1.2736,1.2653,1.2479,1.2286,1.2177,1.2066,
     +1.1816,1.1552,1.1276,1.0995,1.0847,1.0696,1.0415,1.012,0.9417,0.87351,0.80948,0.78916,0.74985,0.69173,
     +0.63519,0.57969,0.52361,0.46706,0.4124,0.30209,0.18866,0.07433,-0.03607,-0.1437,-0.24708,-0.34465,
     +-0.43818,-0.52682,-0.60658,-0.75402,-0.8941,-0.96187,-1.0266,-1.1495,-1.2664,-1.376,-1.4786,-1.5297,
     +-1.5764,-1.6685,-1.7516,-1.829,-1.9011,-1.9712,-2.0326,-2.0928,-2.2288,-2.3579,-2.477,-2.5854,-2.6854,
     +-2.7823,-2.8776,-2.9759,-3.076,-3.1726/)
	e4=(/1.073,1.431,1.421,1.4331,1.4336,1.4328,1.4279,1.4261,1.4227,1.4174,1.4158,1.409,1.4059,1.4033,
     +1.4021,1.4009,1.3991,1.3974,1.3947,1.3954,1.4004,1.4032,1.4082,1.4174,1.4261,1.4322,1.435,1.4339,1.4293,
     +1.411,1.3831,1.3497,1.3395,1.3162,1.2844,1.2541,1.2244,1.1941,1.1635,1.1349,1.0823,1.0366,1.0166,0.99932,
     +0.97282,0.96348,0.95676,0.95004,0.94956,0.95077,0.95278,0.95899,0.96766,0.97862,0.99144,0.99876,1.0064,
     +1.0215,1.0384,1.0833,1.1336,1.1861,1.2035,1.2375,1.2871,1.3341,1.378,1.4208,1.4623,1.5004,1.569,1.6282,
     +1.6794,1.7239,1.7622,1.7955,1.8259,1.8564,1.8868,1.9152,1.9681,2.017,2.0406,2.0628,2.1014,2.1323,2.1545,
     +2.1704,2.1775,2.1834,2.1938,2.204,2.2123,2.2181,2.223,2.2268,2.2299,2.2389,2.2377,2.215,2.172,2.1187,
     +2.0613,2.0084,1.9605,1.9189,1.8837/)
	e5=(/-0.1536,0.05053,0.04932,0.053388,0.054888,0.057529,0.060732,0.061444,0.062806,0.064559,0.065028,0.066183,
     +0.066438,0.066663,0.066774,0.066891,0.067127,0.067357,0.067797,0.068591,0.070127,0.070895,0.072075,
     +0.073549,0.073735,0.07194,0.068097,0.062327,0.055231,0.037389,0.016373,-0.005158,-0.011354,-0.024711,
     +-0.042065,-0.057593,-0.071861,-0.08564,-0.098884,-0.11096,-0.133,-0.15299,-0.16213,-0.17041,-0.18463,
     +-0.19057,-0.1959,-0.20454,-0.21134,-0.21446,-0.21716,-0.22214,-0.22608,-0.22924,-0.23166,-0.23263,
     +-0.2335,-0.23464,-0.23522,-0.23449,-0.23128,-0.22666,-0.22497,-0.22143,-0.21591,-0.21047,-0.20528,
     +-0.20011,-0.1949,-0.18983,-0.18001,-0.1709,-0.16233,-0.15413,-0.1467,-0.13997,-0.13361,-0.12686,
     +-0.11959,-0.11237,-0.098017,-0.083765,-0.076308,-0.068925,-0.055229,-0.04332,-0.03444,-0.027889,
     +-0.024997,-0.022575,-0.018362,-0.014642,-0.012248,-0.011459,-0.01176,-0.012879,-0.014855,-0.019502,
     +-0.026383,-0.039505,-0.05914,-0.081606,-0.10382,-0.12114,-0.13407,-0.14364,-0.15096/)
	e6=(/0.2252,-0.1662,-0.1659,-0.16561,-0.1652,-0.16499,-0.16632,-0.1669,-0.16813,-0.17015,-0.17083,
     +-0.17357,-0.17485,-0.17619,-0.17693,-0.17769,-0.1792,-0.18082,-0.1848,-0.18858,-0.19176,-0.19291,-0.19451,
     +-0.19665,-0.19816,-0.19902,-0.19929,-0.199,-0.19838,-0.19601,-0.19265,-0.18898,-0.18792,-0.18566,-0.18234,
     +-0.17853,-0.17421,-0.16939,-0.16404,-0.15852,-0.14704,-0.13445,-0.12784,-0.12115,-0.10714,-0.10011,
     +-0.092855,-0.078923,-0.065134,-0.057921,-0.05104,-0.036755,-0.023189,-0.010417,0.0011678,0.0065887,
     +0.011871,0.020767,0.029119,0.046932,0.062667,0.077997,0.083058,0.093185,0.10829,0.12256,0.13608,0.14983,
     +0.16432,0.17895,0.21042,0.2441,0.27799,0.30956,0.33896,0.36616,0.39065,0.41244,0.43151,0.44788,0.48024,
     +0.51873,0.53883,0.5581,0.59394,0.62694,0.65811,0.68755,0.70216,0.71523,0.74028,0.76303,0.78552,0.80792,
     +0.83126,0.8524,0.87314,0.91466,0.9487,0.97643,0.99757,1.0121,1.0232,1.0335,1.0453,1.0567,1.0651/)
	Mh=(/6.2,5.5,5.5,5.5,5.5,5.5,5.5,5.5,5.5,5.5,5.5,5.5,5.5,5.5,5.5,5.5,5.5,5.5,5.5,5.5,5.5,5.5,5.5,
     +5.5,5.5,5.51,5.52,5.53,5.54,5.57,5.62,5.66,5.67,5.7,5.74,5.78,5.82,5.85,5.89,5.92,5.97,6.03,6.05,6.07,
     +6.11,6.12,6.14,6.16,6.18,6.18,6.19,6.19,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,
     +6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,
     +6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2,6.2/)
	c1=(/-1.243,-1.134,-1.134,-1.1394,-1.1405,-1.1419,-1.1423,-1.1421,-1.1412,-1.1388,-1.1378,-1.1324,
     +-1.1292,-1.1259,-1.1242,-1.1224,-1.1192,-1.1159,-1.1082,-1.1009,-1.0942,-1.0918,-1.0884,-1.0831,-1.0785,
     +-1.0745,-1.0709,-1.0678,-1.0652,-1.0607,-1.0572,-1.0549,-1.0545,-1.0537,-1.0532,-1.0533,-1.0541,-1.0556,
     +-1.0579,-1.0607,-1.067,-1.0737,-1.0773,-1.0808,-1.0879,-1.0913,-1.0948,-1.1013,-1.1074,-1.1105,-1.1133,
     +-1.119,-1.1243,-1.1291,-1.1337,-1.1359,-1.1381,-1.142,-1.1459,-1.1543,-1.1615,-1.1676,-1.1694,-1.1728,
     +-1.1777,-1.1819,-1.1854,-1.1884,-1.1909,-1.193,-1.1966,-1.1996,-1.2018,-1.2039,-1.2063,-1.2086,-1.2106,
     +-1.2123,-1.2141,-1.2159,-1.219,-1.2202,-1.2201,-1.2198,-1.2189,-1.2179,-1.2169,-1.216,-1.2156,-1.2156,
     +-1.2158,-1.2162,-1.2165,-1.2169,-1.2175,-1.2182,-1.2189,-1.2204,-1.2232,-1.2299,-1.2408,-1.2543,-1.2688,
     +-1.2839,-1.2989,-1.313,-1.3253/)
	c2=(/0.1489,0.1917,0.1916,0.18962,0.18924,0.18875,0.18844,0.18842,0.1884,0.18839,0.18837,0.18816,
     + 0.18797,0.18775,0.18764,0.18752,0.1873,0.18709,0.18655,0.18582,0.18485,0.18442,0.18369,0.18225,0.18052,
     +0.17856,0.17643,0.1742,0.17203,0.1677,0.16352,0.15982,0.15882,0.15672,0.15401,0.15158,0.14948,0.14768,
     +0.14616,0.14489,0.14263,0.14035,0.13925,0.13818,0.13604,0.13499,0.13388,0.13179,0.12984,0.1289,0.12806,
     +0.12647,0.12512,0.12389,0.12278,0.12227,0.12177,0.12093,0.12015,0.11847,0.11671,0.11465,0.11394,0.11253,
     +0.11054,0.10873,0.10709,0.10548,0.10389,0.10248,0.10016,0.098482,0.097375,0.096743,0.096445,0.096338,
     +0.096254,0.096207,0.096255,0.096361,0.096497,0.096198,0.096106,0.096136,0.096667,0.097638,0.098649,
     +0.099553,0.099989,0.10043,0.10142,0.10218,0.10269,0.10304,0.10324,0.10337,0.10353,0.1046,0.1075,0.11231,
     +0.11853,0.12507,0.13146,0.13742,0.14294,0.14781,0.15183/)
	c3=(/-0.00344,-0.008088,-0.008088,-0.008074,-0.008095,-0.008153,-0.00829,-0.008336,-0.008445,-0.008642,
     +-0.008715,-0.00903,-0.009195,-0.00936,-0.009441,-0.009521,-0.009676,-0.009819,-0.01012,-0.01033,
     +-0.01048,-0.01052,-0.01056,-0.01058,-0.01056,-0.01051,-0.01042,-0.01032,-0.0102,-0.009964,-0.009722,
     +-0.009476,-0.009402,-0.009228,-0.008977,-0.008725,-0.008472,-0.008219,-0.007967,-0.007717,-0.007224,
     +-0.006747,-0.006517,-0.006293,-0.005866,-0.005666,-0.005475,-0.005122,-0.004808,-0.004663,-0.004527,
     +-0.004276,-0.004053,-0.003853,-0.003673,-0.00359,-0.00351,-0.00336,-0.00322,-0.002897,-0.00261,
     +-0.002356,-0.002276,-0.002131,-0.001931,-0.001754,-0.001597,-0.001456,-0.001328,-0.00121,-0.000994,
     +-0.000803,-0.000635,-0.00049,-0.000365,-0.000259,-0.000171,-0.000099,-0.000042,0.,0.,0.,0.,0.,0.,0.,-0.000023,
     +-0.00004,-0.000045,-0.000049,-0.000053,-0.000052,-0.000047,-0.000039,-0.000027,-0.000014,0.,0.,0.,0.,0.,0.,0.,
     +0.,0.,0.,0./)
        Mref=4.5
	Rref=1.0	!1 km reference distance.
	h =(/5.3,4.5,4.5,4.5,4.5,4.5,4.5,4.49,4.45,4.4,4.38,4.32,4.29,4.27,4.25,4.24,4.22,4.2,4.15,4.11,4.08,
     +4.07,4.06,4.04,4.02,4.03,4.07,4.1,4.13,4.19,4.24,4.29,4.3,4.34,4.39,4.44,4.49,4.53,4.57,4.61,4.68,4.75,
     +4.78,4.82,4.88,4.9,4.93,4.98,5.03,5.06,5.08,5.12,5.16,5.2,5.24,5.25,5.27,5.3,5.34,5.41,5.48,5.53,5.54,
     +5.56,5.6,5.63,5.66,5.69,5.72,5.74,5.82,5.92,6.01,6.1,6.18,6.26,6.33,6.4,6.48,6.54,6.66,6.73,6.77,6.81,
     +6.87,6.93,6.99,7.08,7.12,7.16,7.24,7.32,7.39,7.46,7.52,7.64,7.78,8.07,8.48,8.9,9.2,9.48,9.57,9.62,9.66,
     +9.66,9.66/)
	Dc3CATW=0.0
	Dc3China=(/0.00435,0.00286,0.00282,0.00278,0.00276,0.00275,0.00276,0.00276,0.00277,0.00278,0.00280,
     +0.00282,0.00285,0.00287,0.00290,0.00292,0.00294,0.00296,0.00296,0.00297,0.00297,0.00297,0.00296,0.00296,
     +0.00294,0.00293,0.00291,0.00290,0.00288,0.00286,0.00285,0.00283,0.00282,0.00280,0.00279,0.00276,0.00273,
     +0.00270,0.00266,0.00261,0.00256,0.00251,0.00244,0.00238,0.00231,0.00225,0.00220,0.00215,0.00212,0.00210,
     +0.00210,0.00210,0.00211,0.00213,0.00216,0.00220,0.00225,0.00230,0.00235,0.00240,0.00245,0.00251,0.00257,
     +0.00263,0.00269,0.00275,0.00280,0.00284,0.00288,0.00292,0.00295,0.00298,0.00301,0.00303,0.00304,0.00304,
     +0.00303,0.00300,0.00297,0.00292,0.00287,0.00281,0.00276,0.00271,0.00266,0.00262,0.00259,0.00258,0.00257,
     +0.00257,0.00259,0.00261,0.00262,0.00262,0.00262,0.00262,0.00260,0.00259,0.00258,0.00259,0.00260,0.00260,
     +0.00263,0.00267,0.00276,0.00289,0.00303/)
	Dc3Italy=(/-0.00033,-0.00255,-0.00244,-0.00234,-0.00229,-0.00225,-0.00221,-0.00217,-0.00212,-0.00210,
     +-0.00207,-0.00205,-0.00203,-0.00202,-0.00200,-0.00199,-0.00199,-0.00199,-0.00200,-0.00202,-0.00204,
     +-0.00208,-0.00211,-0.00216,-0.00221,-0.00227,-0.00233,-0.00238,-0.00244,-0.00249,-0.00254,-0.00258,
     +-0.00263,-0.00267,-0.00271,-0.00275,-0.00280,-0.00285,-0.00291,-0.00297,-0.00303,-0.00308,-0.00314,
     +-0.00319,-0.00324,-0.00327,-0.00330,-0.00330,-0.00330,-0.00329,-0.00327,-0.00324,-0.00321,-0.00318,
     +-0.00313,-0.00308,-0.00302,-0.00296,-0.00291,-0.00285,-0.00279,-0.00273,-0.00266,-0.00260,-0.00253,
     +-0.00246,-0.00238,-0.00229,-0.00220,-0.00209,-0.00198,-0.00186,-0.00175,-0.00163,-0.00152,-0.00141,
     +-0.00132,-0.00125,-0.00120,-0.00117,-0.00116,-0.00115,-0.00116,-0.00117,-0.00118,-0.00119,-0.00119,
     +-0.00119,-0.00117,-0.00115,-0.00112,-0.00108,-0.00102,-0.00095,-0.00084,-0.00072,-0.00057,-0.00041,
     +-0.00023,-0.00004,0.00017,0.00038,0.00072,0.00094,0.00113,0.00131,0.00149/)
c	clin=(/-0.8050,-0.5150,-0.5257,-0.5362,-0.5403,-0.5410,-0.5391,-0.5399,-0.5394,-0.5358,-0.5315,
c     +-0.5264,-0.5209,-0.5142,-0.5067,-0.4991,-0.4916,-0.4850,-0.4788,-0.4735,-0.4687,-0.4646,-0.4616,
c     +-0.4598,-0.4601,-0.4620,-0.4652,-0.4688,-0.4732,-0.4787,-0.4853,-0.4931,-0.5022,-0.5126,-0.5244,
c     +-0.5392,-0.5569,-0.5758,-0.5962,-0.6192,-0.6426,-0.6658,-0.6897,-0.7133,-0.7356,-0.7567,-0.7749,
c     +-0.7902,-0.8048,-0.8186,-0.8298,-0.8401,-0.8501,-0.8590,-0.8685,-0.8790,-0.8903,-0.9011,-0.9118,
c     +-0.9227,-0.9338,-0.9453,-0.9573,-0.9692,-0.9811,-0.9924,-1.0033,-1.0139,-1.0250,-1.0361,-1.0467,
c     +-1.0565,-1.0655,-1.0736,-1.0808,-1.0867,-1.0904,-1.0923,-1.0925,-1.0908,-1.0872,-1.0819,-1.0753,
c     +-1.0682,-1.0605,-1.0521,-1.0435,-1.0350,-1.0265,-1.0180,-1.0101,-1.0028,-0.9949,-0.9859,-0.9748,
c     +-0.9613,-0.9456,-0.9273,-0.9063,-0.8822,-0.8551,-0.8249,-0.7990,-0.7620,-0.7230,-0.6840,-0.6440/)
c	Vclin=(/950.00,925.00,930.00,967.50,964.23,961.65,959.61,959.71,956.83,955.39,954.35,953.91,954.10,
c     +955.15,957.18,960.17,963.44,967.06,970.75,973.97,976.38,977.78,978.02,977.23,974.98,972.16,969.48,966.90,
c     +964.90,963.89,964.03,965.34,967.71,970.89,974.53,977.78,979.37,979.38,978.42,975.61,971.31,965.97,960.05,
c     +954.24,948.77,943.90,940.75,939.61,939.66,940.74,943.02,945.83,949.18,952.96,957.31,962.25,967.61,972.54,
c     +977.09,981.13,984.26,986.32,987.12,986.52,984.70,981.17,976.97,972.90,969.79,967.51,965.94,965.20,965.38,
c     +966.44,968.24,969.94,971.24,971.65,970.45,966.44,959.61,950.34,939.03,926.85,914.07,900.07,885.63,871.15,
c     +856.21,840.97,826.47,812.92,799.72,787.55,776.05,765.55,756.97,735.74,728.14,726.30,728.24,731.96,735.81,
c     +739.50,743.07,746.55,750.00/)
c clin and Vclin updated July 2013. 
      clin=(/ -0.8400, -0.6000, -0.6037, -0.5739, -0.5668, -0.5552, -0.5385, -0.5341, -0.5253, -0.5119,
     + -0.5075, -0.4906, -0.4829, -0.4757, -0.4724, -0.4691, -0.4632, -0.4580, -0.4479, -0.4419,
     + -0.4395, -0.4395, -0.4404, -0.4441, -0.4502, -0.4581, -0.4673, -0.4772, -0.4872, -0.5063,
     + -0.5244, -0.5421, -0.5475, -0.5603, -0.5796, -0.6005, -0.6225, -0.6449, -0.6668, -0.6876,
     + -0.7243, -0.7565, -0.7718, -0.7870, -0.8161, -0.8295, -0.8417, -0.8618, -0.8773, -0.8838,
     + -0.8896, -0.9004, -0.9109, -0.9224, -0.9346, -0.9408, -0.9469, -0.9586, -0.9693, -0.9892,
     + -1.0012, -1.0078, -1.0093, -1.0117, -1.0154, -1.0210, -1.0282, -1.0360, -1.0436, -1.0500,
     + -1.0573, -1.0584, -1.0554, -1.0504, -1.0454, -1.0421, -1.0404, -1.0397, -1.0395, -1.0392,
     + -1.0368, -1.0323, -1.0294, -1.0262, -1.0190, -1.0112, -1.0032, -0.9951, -0.9910, -0.9868,
     + -0.9783, -0.9694, -0.9601, -0.9505, -0.9405, -0.9302, -0.9195, -0.8918, -0.8629, -0.8335,
     + -0.8046, -0.7766, -0.7503, -0.7254, -0.7016, -0.6785, -0.655800/)
  
      Vclin =(/ 1300.00, 1500.00, 1500.20, 1500.36, 1500.68, 1501.04, 1501.26, 1502.95, 1503.12, 1503.24,
     +   1503.32, 1503.35, 1503.34, 1503.13, 1502.84, 1502.47, 1502.01, 1501.42, 1500.71, 1499.83,
     +   1498.74, 1497.42, 1495.85, 1494.00, 1491.82, 1489.29, 1486.36, 1482.98, 1479.12, 1474.74,
     +   1469.75, 1464.09, 1457.76, 1450.71, 1442.85, 1434.22, 1424.85, 1414.77, 1403.99, 1392.61,
     +   1380.72, 1368.51, 1356.21, 1343.89, 1331.67, 1319.83, 1308.47, 1297.65, 1287.50, 1278.06,
     +   1269.19, 1260.74, 1252.66, 1244.80, 1237.03, 1229.23, 1221.16, 1212.74, 1203.91, 1194.59,
     +   1184.93, 1175.19, 1165.69, 1156.46, 1147.59, 1139.21, 1131.34, 1123.91, 1116.83, 1109.95,
     +   1103.07, 1096.04, 1088.67, 1080.77, 1072.39, 1061.77, 1049.29, 1036.42, 1023.14, 1009.49,
     +    995.52,  981.33,  966.94,  952.34,  937.52,  922.43,  908.79,  896.15,  883.16,  870.05,
     +    857.07,  844.48,  832.45,  821.18,  810.79,  801.41,  793.13,  785.73,  779.91,  775.60,
     +    772.68,  771.01,  760.81,  764.50,  768.07,  771.55,  775.00/)
	Vref=760.
	f1=0.0
	f3=0.1	!fill out with constant value
	f4=(/-0.1000,-0.1500,-0.1483,-0.1471,-0.1477,-0.1496,-0.1525,-0.1549,-0.1574,-0.1607,-0.1641,-0.1678,
     +-0.1715,-0.1760,-0.1810,-0.1862,-0.1915,-0.1963,-0.2014,-0.2066,-0.2120,-0.2176,-0.2232,-0.2287,-0.2337,
     +-0.2382,-0.2421,-0.2458,-0.2492,-0.2519,-0.2540,-0.2556,-0.2566,-0.2571,-0.2571,-0.2562,-0.2544,-0.2522,
     +-0.2497,-0.2466,-0.2432,-0.2396,-0.2357,-0.2315,-0.2274,-0.2232,-0.2191,-0.2152,-0.2112,-0.2070,-0.2033,
     +-0.1996,-0.1958,-0.1922,-0.1884,-0.1840,-0.1793,-0.1749,-0.1704,-0.1658,-0.1610,-0.1558,-0.1503,-0.1446,
     +-0.1387,-0.1325,-0.1262,-0.1197,-0.1126,-0.1052,-0.0977,-0.0902,-0.0827,-0.0753,-0.0679,-0.0604,-0.0534,
     +-0.0470,-0.0414,-0.0361,-0.0314,-0.0271,-0.0231,-0.0196,-0.0165,-0.0136,-0.0112,-0.0093,-0.0075,-0.0058,
     +-0.0044,-0.0032,-0.0023,-0.0016,-0.0010,-0.0006,-0.0003,-0.0001,0.0000,0.0000,0.0000,-0.0001,0.0001,
     +0.0001,0.0001,0.0001,0.0000/)
	f5=(/-0.00844,-0.00701,-0.00701,-0.00728,-0.00732,-0.00736,-0.00737,-0.00735,-0.00731,-0.00721,-0.00717,
     +-0.00698,-0.00687,-0.00677,-0.00672,-0.00667,-0.00656,-0.00647,-0.00625,-0.00607,-0.00593,-0.00588,
     +-0.00582,-0.00573,-0.00567,-0.00563,-0.00561,-0.00560,-0.00560,-0.00562,-0.00567,-0.00572,-0.00574,
     +-0.00578,-0.00585,-0.00591,-0.00597,-0.00602,-0.00608,-0.00614,-0.00626,-0.00638,-0.00644,-0.00650,
     +-0.00660,-0.00665,-0.00670,-0.00680,-0.00689,-0.00693,-0.00697,-0.00705,-0.00713,-0.00719,-0.00726,
     +-0.00729,-0.00732,-0.00738,-0.00744,-0.00758,-0.00773,-0.00787,-0.00792,-0.00800,-0.00812,-0.00822,
     +-0.00830,-0.00836,-0.00841,-0.00844,-0.00847,-0.00842,-0.00829,-0.00806,-0.00771,-0.00723,-0.00666,
     +-0.00603,-0.00540,-0.00479,-0.00378,-0.00302,-0.00272,-0.00246,-0.00208,-0.00183,-0.00167,-0.00158,
     +-0.00155,-0.00154,-0.00152,-0.00152,-0.00152,-0.00150,-0.00148,-0.00146,-0.00144,-0.00140,-0.00138,
     +-0.00137,-0.00137,-0.00137,-0.00137,-0.00137,-0.00137,-0.00136,-0.00136/)
	f6=(/-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,
     +-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,
     +-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,
     +0.006,0.026,0.055,0.092,0.140,0.195,0.252,0.309,0.367,0.425,0.481,0.536,0.588,0.638,0.689,0.736,0.780,
     +0.824,0.871,0.920,0.969,1.017,1.060,1.099,1.135,1.164,1.188,1.211,1.234,1.253,1.271,1.287,1.300,1.312,
     +1.323,1.329,1.345,1.350,1.349,1.342,1.329,1.308,1.282,1.252,1.218,1.183/)
	f7=(/-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,
     +-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,
     +-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,-9.9,
     +0.004,0.017,0.036,0.059,0.088,0.120,0.152,0.181,0.208,0.233,0.256,0.276,0.294,0.309,0.324,0.337,0.350,
     +0.364,0.382,0.404,0.427,0.451,0.474,0.495,0.516,0.534,0.551,0.570,0.589,0.609,0.629,0.652,0.674,0.697,
     +0.719,0.738,0.778,0.803,0.815,0.816,0.809,0.795,0.777,0.754,0.729,0.703/)
	R1=(/105.00,110.00,111.67,113.10,113.37,113.07,112.36,112.13,111.65,110.64,109.53,108.28,106.99,105.41,
     +103.61,101.70,99.76,97.93,96.03,94.10,92.08,90.01,87.97,85.99,84.23,82.74,81.54,80.46,79.59,79.05,
     +78.85,78.99,79.47,80.26,81.33,82.86,84.72,86.67,88.73,90.91,93.04,95.08,97.04,98.87,100.53,102.01,
     +103.15,104.00,104.70,105.26,105.61,105.87,106.02,106.03,105.92,105.79,105.69,105.59,105.54,105.61,
     +105.83,106.20,106.75,107.48,108.39,109.62,111.08,112.71,114.50,116.39,118.30,120.19,122.01,123.75,
     +125.38,126.90,128.14,129.11,129.86,130.37,130.67,130.81,130.81,130.72,130.57,130.36,130.13,129.90,
     +129.71,129.56,129.49,129.49,129.57,129.71,129.87,130.05,130.22,130.39,130.53,130.63,130.70,130.72,
     +130.87,130.71,130.50,130.26,130.00/)
	R2=(/272.00,270.00,270.00,270.00,270.00,270.00,270.00,270.00,270.00,270.00,270.00,270.00,270.00,
     +270.00,270.00,270.00,270.00,270.00,270.00,270.01,270.02,270.02,270.03,270.04,270.05,270.06,270.07,
     +270.08,270.09,270.11,270.13,270.15,270.15,270.16,270.16,270.16,270.14,270.11,270.06,270.00,269.83,
     +269.59,269.45,269.30,268.96,268.78,268.59,268.20,267.79,267.58,267.37,266.95,266.54,266.16,265.80,
     +265.64,265.48,265.21,265.00,264.74,264.83,265.20,265.38,265.78,266.51,267.32,268.14,268.90,269.55,
     +270.00,270.18,269.42,267.82,265.45,262.41,258.78,254.66,250.11,245.25,240.14,229.55,219.05,214.04,
     +209.32,201.08,195.00,191.61,190.73,191.11,191.98,195.01,199.45,204.93,211.09,217.56,223.99,230.00,
     +241.86,249.34,252.94,253.12,250.39,245.23,238.13,229.56,220.02,210.00/)
	delta_phiR=(/0.082,0.100,0.096,0.092,0.088,0.086,0.084,0.081,0.078,0.077,0.075,0.073,0.072,0.070,0.069,0.067,
     +0.065,0.063,0.062,0.061,0.061,0.061,0.062,0.064,0.067,0.072,0.076,0.082,0.087,0.093,0.099,0.104,0.110,
     +0.115,0.120,0.125,0.128,0.131,0.134,0.136,0.138,0.140,0.141,0.141,0.140,0.139,0.138,0.135,0.133,0.130,
     +0.128,0.125,0.122,0.120,0.117,0.115,0.113,0.111,0.109,0.108,0.106,0.105,0.103,0.102,0.100,0.099,0.099,
     +0.098,0.098,0.098,0.099,0.100,0.101,0.102,0.104,0.105,0.106,0.106,0.106,0.105,0.103,0.100,0.097,0.094,
     +0.091,0.088,0.084,0.081,0.078,0.075,0.072,0.070,0.068,0.066,0.064,0.063,0.061,0.060,0.059,0.059,0.059,
     +0.058,0.059,0.059,0.060,0.060,0.060/)
	delta_phiV=(/0.068,0.084,0.079,0.079,0.080,0.081,0.081,0.082,0.082,0.083,0.083,0.084,0.083,0.083,0.082,0.081,
     +0.079,0.077,0.075,0.073,0.070,0.067,0.064,0.062,0.060,0.058,0.057,0.057,0.057,0.059,0.061,0.063,0.066,
     +0.069,0.072,0.076,0.079,0.081,0.084,0.086,0.087,0.088,0.089,0.090,0.091,0.092,0.093,0.094,0.094,0.095,
     +0.095,0.095,0.095,0.094,0.093,0.092,0.091,0.089,0.088,0.086,0.085,0.083,0.082,0.081,0.080,0.079,0.079,
     +0.078,0.078,0.078,0.078,0.077,0.077,0.077,0.076,0.075,0.074,0.072,0.071,0.069,0.066,0.064,0.061,0.058,
     +0.056,0.053,0.050,0.047,0.045,0.042,0.039,0.036,0.034,0.033,0.032,0.032,0.032,0.031,0.031,0.032,0.033,
     +0.034,0.033,0.031,0.028,0.025,0.025/)
	V1=225.
	V2=300.
	phi1=(/0.644,0.695,0.698,0.702,0.707,0.711,0.716,0.721,0.726,0.730,0.734,0.738,0.742,0.745,0.748,
     +0.750,0.752,0.753,0.753,0.753,0.752,0.750,0.748,0.745,0.741,0.737,0.734,0.731,0.728,0.726,0.724,0.723,
     +0.722,0.721,0.720,0.720,0.718,0.717,0.714,0.711,0.708,0.703,0.698,0.693,0.687,0.681,0.675,0.670,0.664,
     +0.658,0.653,0.648,0.643,0.638,0.634,0.629,0.624,0.619,0.615,0.610,0.605,0.599,0.593,0.587,0.581,0.576,
     +0.570,0.564,0.558,0.553,0.548,0.543,0.539,0.535,0.532,0.529,0.527,0.526,0.526,0.526,0.527,0.528,0.530,
     +0.531,0.532,0.534,0.535,0.535,0.536,0.536,0.536,0.536,0.535,0.534,0.533,0.531,0.528,0.526,0.524,0.520,
     +0.515,0.512,0.510,0.509,0.509,0.509,0.510/)
	phi2=(/0.552,0.495,0.499,0.502,0.505,0.508,0.510,0.514,0.516,0.518,0.520,0.521,0.523,0.525,0.527,
     +0.529,0.530,0.532,0.534,0.536,0.538,0.540,0.541,0.542,0.543,0.543,0.542,0.542,0.541,0.540,0.539,0.538,
     +0.538,0.537,0.537,0.536,0.536,0.536,0.537,0.539,0.541,0.544,0.547,0.550,0.554,0.557,0.561,0.566,0.570,
     +0.573,0.576,0.578,0.580,0.583,0.585,0.589,0.592,0.595,0.599,0.603,0.607,0.611,0.615,0.619,0.622,0.624,
     +0.625,0.626,0.626,0.625,0.624,0.623,0.622,0.620,0.619,0.618,0.618,0.618,0.618,0.618,0.619,0.619,0.619,
     +0.620,0.619,0.619,0.618,0.618,0.617,0.616,0.616,0.616,0.616,0.617,0.619,0.621,0.622,0.624,0.625,0.634,
     +0.636,0.634,0.630,0.622,0.613,0.604,0.604/)
	tau1=(/0.401,0.398,0.402,0.409,0.418,0.427,0.436,0.445,0.454,0.462,0.470,0.478,0.484,0.490,0.496,
     +0.499,0.502,0.503,0.502,0.499,0.495,0.489,0.483,0.474,0.464,0.452,0.440,0.428,0.415,0.403,0.392,0.381,
     +0.371,0.362,0.354,0.349,0.346,0.344,0.343,0.344,0.345,0.347,0.350,0.353,0.357,0.360,0.363,0.366,0.369,
     +0.372,0.375,0.378,0.381,0.384,0.388,0.393,0.398,0.404,0.410,0.417,0.424,0.431,0.440,0.448,0.457,0.466,
     +0.475,0.483,0.491,0.498,0.505,0.511,0.516,0.521,0.525,0.528,0.530,0.531,0.532,0.532,0.533,0.533,0.534,
     +0.535,0.536,0.537,0.538,0.540,0.541,0.542,0.543,0.543,0.542,0.540,0.538,0.535,0.532,0.528,0.524,0.517,
     +0.514,0.511,0.507,0.503,0.498,0.492,0.487/)
	tau2=(/0.346,0.348,0.345,0.346,0.349,0.354,0.359,0.364,0.369,0.374,0.379,0.384,0.390,0.397,0.405,
     +0.412,0.419,0.426,0.434,0.441,0.448,0.455,0.461,0.466,0.468,0.468,0.466,0.464,0.458,0.451,0.441,0.430,
     +0.417,0.403,0.388,0.372,0.357,0.341,0.324,0.309,0.294,0.280,0.266,0.255,0.244,0.236,0.229,0.223,0.218,
     +0.215,0.212,0.210,0.210,0.210,0.211,0.213,0.216,0.219,0.224,0.229,0.235,0.243,0.250,0.258,0.266,0.274,
     +0.281,0.288,0.294,0.298,0.302,0.306,0.309,0.312,0.315,0.318,0.321,0.323,0.326,0.329,0.332,0.335,0.337,
     +0.340,0.342,0.344,0.345,0.346,0.347,0.348,0.349,0.349,0.349,0.347,0.345,0.341,0.335,0.329,0.321,0.312,
     +0.302,0.270,0.278,0.265,0.252,0.239,0.239/)

c Rjb_bar removed May 2013.
	ip = 1	!one period for deagg work.
c      twopi = 2.0 * pi
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
c       delta_c3 = dc3CATW	!Use CA-Taiwan version for now. Can add options for other regions. iregion=1
            r_pga4nl = sqrt(rjb**2+h(indx_pga)**2)
        call y_bssa13_no_site_amps( m, r_pga4nl, mech,  c, Mref(indx_pga), 
     :           Rref(indx_pga), dc3CATW(indx_pga),
     :           e, Mh(indx_pga), pga4nl) 
c       if(abs(m-7.).lt.0.05.and.ip.eq.2)print *,rjb,pga4nl,r_pga4nl/Rref(indx_pga),m,Mh(indx_pga),' pga4nl'    
c   pga4nl is logged in this code.
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
c Set v1, v2 to values in text below equation (4.13) ("pending further study")
            call bssa13_gm_sub4y(T(indx_per),m, r, rjb, v30, mech,  z1, pga4nl,c, Mref(indx_per), 
     :        Rref(indx_per), dc3CATW(indx_per),
     :        e, Mh(indx_per),
     :        clin(indx_per), vclin(indx_per), vref(indx_per),
     :        f1(indx_per), f3(indx_per), f4(indx_per),f5(indx_per),f6(indx_per),f7(indx_per),
     :        r1(indx_per), r2(indx_per),delta_phiR(indx_per), 
     :        v1, v2, delta_phiV(indx_per),
     :        phi1(indx_per), phi2(indx_per), 
     :        tau1(indx_per), tau2(indx_per),
     :        lny, sigmaf) 
c       if(abs(m-7.).lt.0.05.and.ip.eq.1)print *,rjb,exp(lny),r,' pgaw'   
       if(sdi)then
       sig=1./sigmaf/sqrt2
       sde=lny+fac_sde	!fac_sde is log(T**2/(4pisq))
       rhat = min(10.,exp(sde)/dy_sdi)	!10 is an upper bound for rhat.
       lny = sdi_ratio(T(indx_per),m,rhat,sig,sdisd) + sde
       sigmaf=1./sdisd/sqrt2	!use sdi for all gnd_ep branches
       endif
	if (l_ms)then
c Play it again, Dave Boore, to compute the mean spectrum. New June 24 2013.
	do jp=1,npnga
c The below conditional says, compute if coeffs are available at the period with index jp. This
c will generally be true for the NGA-W relations but less so for older GMPEs with fewer periods.
c  
	jper=imsp(ia,jp)
        if ( jp .eq. jms)then
c use the available information. Frequency dependence of mean and sigma require the loop.
        meanspec(jp)=lny
        sigspec(jp)=1./sigmaf/sqrt2
	elseif (lmsp(ia,jp)) then
            r = sqrt(rjb**2+h(jper)**2)
        c(1)=c1(jper)
        c(2)=c2(jper)
        c(3)=c3(jper)
        e(0)=e0(jper)
        e(1)=e1(jper)
        e(2)=e2(jper)
        e(3)=e3(jper)
        e(4)=e4(jper)
        e(5)=e5(jper)
        e(6)=e6(jper)
c        v1 = 225.
c        v2 = 300.	!from bssa13_gm_tmr.for
c Set v1, v2 to values in text below equation (4.13) ("pending further study")
            call bssa13_gm_sub4y(T(jper),m, r, rjb, v30, mech,  z1, pga4nl,c, Mref(jper), 
     :        Rref(jper), dc3CATW(jper),e, Mh(jper),
     :        clin(jper), vclin(jper), vref(jper),
     :        f1(jper), f3(jper), f4(jper),f5(jper),f6(jper),f7(jper),
     :        r1(jper), r2(jper),delta_phiR(jper), v1, v2, delta_phiV(jper),
     :        phi1(jper), phi2(jper), tau1(jper), tau2(jper),lnyt, sigmaft) 
        meanspec(jp)=lnyt
        sigspec(jp)=1./sigmaft/sqrt2
        endif	!computable period?
        enddo	!loop thru periods
        endif	!do you want CMS?
        return
        end subroutine bssa2013drv

       subroutine y_bssa13_no_site_amps(m, r, mech, c, mref, rref, delta_c3,e, mh, y)     
     
! NOTE: y in g, unless pgv!!!!  

! ncoeff_s1, ncoeff_s2 are not included as arguments because it is
! assumed that they are 3 and 7, respectively.

! Assume no site amp

! mech = 0, 1, 2, 3 for unspecified, SS, NS, RS, respectively

! Dates: 02/27/13 - Modified from y_ngaw2_no_site_amps
 
      IMPLICIT none
 	real, dimension(3):: c     
      real :: m, r, mref, rref, delta_c3, 
     :        e(0:6), mh, 
     :        alny, y, fpb, fp, fe, fs, fault_type_term, gspread     
     
      integer :: mech, iregion
      
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
         
      y = exp(fe + fp + fs) 
      return
      end subroutine y_bssa13_no_site_amps
! >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>      

c May 18 version bssa13_gm_sub4y.
! --------------------------------------------------------- bssa13_gm_sub4y
      subroutine bssa13_gm_sub4y(per, m, r, rjb, v30, mech,  z1,  pga4nl,c, amref, 
     :        rref, delta_c3,
     :        e, amh,
     :        clin, vclin, vref,
     :        f1, f3, f4, f5, f6,f7,
     :        r1, r2,delta_phiR, 
     :        v1, v2, delta_phiV,
     :        phi1, phi2, 
     :        tau1, tau2,
     :        alny, sigmaf)     
c Note output log(SA) not SA in this version. No need for SA in downstream calcs. 
c removed iregion: taken care of before arriving here.    
c z1 is depth to 1 km/s Vs. Units km (?). 
c Subroutine updated by SH. May 20 2013.
!Input arguments:

!          per, m, rjb, 
!          mech, v30, 
!          e, amh_gmpe, c_gmpe, amref_gmpe,
!          rref_gmpe, h_gmpe, 
!          v30ref, r1,r2
!          sigt_gmpe,
!          e_pga4nl, amh_pga4nl, c_pga4nl, amref_pga4nl,
!          rref_pga4nl, h_pga4nl,


!Output arguments:

!          alny, sigmaf,
!          


! Computes NGAW2 NGA motions for given input variables

! Note: For generality, include a magnitude-dependent anelastic
! term, although the coefficients are 0.0 for the 2007 BA NGA GMPEs

 
! Dates: 02/27/13 - Written by D.M. Boore, based on ngaw2_gm_sub4y
!updated april 2013
!        04/09/13 - Revise in light of the new report and coefficient table.
!                 - Sediment depth term in terms of delta_z1, which requires the relation
!                   between z1 and Vs30.  There are two relations in the report
!                   (equations (4.9a) and (4.9b)), one for Japan and one for California.
!                   I need to add an input argument to specify which relation to use, but for
!                   now, just skip the sediment term altogether (even if it is included, specifying
!                   Z1<0 will turn it off).
!                 - Return a large value of phi if Rjb> 300
      implicit none
      real :: sqrt2
      parameter (sqrt2=1.414213562)
      real, dimension(3) :: c
      real :: per,m, r, v30, z1, pga4nl, amref, rref, delta_c3,e(0:6), amh,
     :        clin, vclin, vref, phi3,  f1, f2, f3, f4, f5, f6,f7,phi1, phi2, 
     :         delta_phiR, rjb,r1,r2,
     :        delta_phiV, v1, v2,
     :        tau1, tau2,
     :        alny, fsb, fs, phiM, phiMR,
     :        phi, tau, sigmaf, sigma, delta_z1, f_delta_z1,   
     :        amp_lin, amp_nl, amp_total, bnl,
     :        fz1, mu1_vs30
     
      real :: y_xamp
     
      integer :: mech, iregion,irelation

!GET Y FOR GMPE, WITHOUT SITE AMPS:

      call y_bssa13_no_site_amps(
     :           m, r, mech, c, amref, 
     :           rref, delta_c3,
     :           e, amh,
     :           y_xamp)     
      
!Compute site amps

      if (v30 <= vclin) then
        amp_lin  =  (v30/vref)**clin
      else
        amp_lin  =  (vclin/vref)**clin
      end if
        
c modified f2 to eqn (3.11)        
      f2 = f4 * (exp(f5*(amin1(v30,760.0)-360.0)) -
     :             exp(f5*(760.0-360.0)           )   )
      
      bnl = f2
      
      amp_nl = exp(f1+f2*alog( (pga4nl+f3)/f3 ))

      amp_total = amp_lin * amp_nl
      
      fsb  = alog(amp_total)   !
      
c Dont reset z1 to -9.9 but do  hardwire delta_z1 = 0.0 in this version:
c      z1 = -9.9	!should not do this. communicates this to rest of pgm
      delta_z1 = 0.0
      irelation=1
c need to rework code with irelation some day. SH. Z1 is in units m here.
c        if (irelation == 1 .or. irelation == 2) then
c         delta_z1 = z1 - mu1_vs30(v30, irelation)   !is this step slowing down the works?
c        else
c          delta_z1 = 0.0
c        end if
c      end if
      if (per < 0.65) then
        f_delta_z1 = 0.0
      else
        if (delta_z1 > f7/f6) then
          f_delta_z1 = f7
        else
          f_delta_z1 = f6*delta_z1
        end if
      end if
      
       fs = fsb + f_delta_z1
c working in log(y) space. difference from BSSA source code.      
       alny =fs + alog(y_xamp)
      
!Compute phi, tau, and sigma   

!Compute phi, tau, and sigma   Updated. Apr 2013

      if (m <= 4.5) then
        tau = tau1
      else if (m >= 5.5) then
        tau = tau2
      else 
        tau = tau1+(tau2-tau1)*(m-4.5)
      end if
      
      if (m <= 4.5) then
        phiM = phi1
      else if (m >= 5.5) then
        phiM = phi2
      else 
        phiM = phi1+(phi2-phi1)*(m-4.5)
      end if
c changed below for May 18 version.      
      if (Rjb <= R1) then
        phiMR = phiM
      else if (Rjb > R2) then
        phiMR=phiM+delta_phiR
      else
        phiMR = phiM+delta_phiR*(alog(Rjb/R1)/alog(R2/R1))
      end if


      if (v30 <= v1) then
        phi = phiMR - delta_phiV
      else if (v30 >= v2) then
        phi = phiMR
      else
        phi = phiMR - delta_phiV*(alog(v2/v30)/alog(v2/v1))
      end if
      
       sigma = sqrt(phi**2 + tau**2)
     
      sigmaf = 1./sqrt2/sigma         
       return
      end subroutine bssa13_gm_sub4y
! --------------------------------------------------------- bssa13_gm_sub4y

c This code is checked by Sanaz Rezaeian based on AS 2008 Earthquake Spectra paper
c and modified based on AS 2009 errata (3/11/2013)
c   (look for SR for modifications)
c
c ------------------------------------------------------------------            
C *** Abrahamson and Silva (07/2007 - Model) Horizontal ************
c ------------------------------------------------------------------            
      subroutine AS_072007 (iper,mag, dip, Fn,Frv, width, rRup, rjb,R_x,
     1                     vs30, hwflag, lnSa, sigma1, depthtop,  vs30_class,
     3                     depthvs10 )
c ip = global period index, used in SDI calcs, for example.
c specT = spectral period (s).   iper = index in T array of specT  
c no interpolation. SH. Added option to compute inelastic spectral displacement
c using the method of Tothong and Cornell March 2013.
c Output: lnSA = logged median gm (g)
c		sigma1 =  SD(lnSA)
       common/sdi/sdi,dy_sdi,fac_sde
 	real, dimension (108):: period
 	real :: fac_sde
 	logical sdi
      real mag, dip, fType, aspectratio, rRup, rjb, vs30, pgaRock,
     1       srcSiteA, lnSa, sigma, tau, period1, sigma1, depthtop, width,
     2       depthvs10, lnSaTD, lnSa1, lnSa2, lnSaRock,dy_sdi
      integer hwflag,  vs30_class,ip
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

c     VS30 class is to distinguish between the sigma if the VS30 is measured
c     vs the VS30 being estimated from surface geology.
c         Vs30_class = 1 for measured 
c         Vs30_class = 0 for estimated
	return	!becaue arent supposed to be here
	specT = period(iper)
c     For now, convert ftype to an equivalent rake      
C     fType     Mechanism                      Rake
C     ------------------------------------------------------
C      -1       Normal                   -120 < Rake < -60.0
C     1, 0.5    Reverse and Rev/Obl        30 < Rake < 150.0
C     0,-0.5    Strike-Slip and NMl/Obl        Otherwise
C 
c      if ( fType .eq. 1.0 ) then
c        Frv = 1.0
c        Fn = 0.0
c      elseif ( fType .eq. 0.5 ) then
c        Frv = 1.0
c        Fn = 0.0
c      elseif ( fType .eq. -1.0 ) then
c        Frv = 0.0
c        Fn = 1.0
c      else
c        Frv = 0.0
c        Fn = 0.0
c      endif
	specT = per
C HW factors......
c     For now, convert hwflag to an equivalent srcSiteA      
      if (  hwflag .eq. 1 ) then
        srcSiteA = 90.
      else
        srcSiteA = 0.
      endif
      ip = 1	!only one period in deagg.
c     compute pga on rock
      period0 = 0.0
      pgaRock = 0.0
      vs30_rock = 1100.
      depthvs10rock = 0.006
      call AS_072007_model (iper, mag, dip, rake, width, rRup, rjb,R_x,
     1                     vs30_rock, pgaRock,  lnSa, sigma, tau,
     2                     period0, depthTop, Frv, Fn,  vs30_class,
     3                     depthvs10rock, hwflag )

      pgaRock = exp(lnSa)

c     Compute the spectral period for the constant displacement model
c     (Eq. 22)
      TD = 10**(-1.25+0.3*mag)
      if (specT .ge. TD) then
c         Compute Sa at TD spectral period for Vs30=1,100m/sec
          call AS_072007_model (iper, mag, dip, rake, width, rRup, rjb,R_x,
     1                     vs30_rock, pgaRock, lnSaTD, sigmaX, tauX, 
     2                     TD, depthtop, Frv, Fn,  vs30_class, 
     3                     depthvs10rock, hwflag )

          lnSaRock = lnSaTD + alog((TD*TD)/(specT*specT))

c         Compute Sa at spectral period for Vs30
          call AS_072007_model (iper, mag, dip, rake, width, rRup, rjb,R_x,
     1                     vs30, pgaRock,  lnSa1, sigma, tau, 
     2                     specT, depthtop, Frv, Fn,  vs30_class, 
     3                     depthvs10, hwflag )
c         Compute Sa at spectral period for Vs30=1,100m/sec
          call AS_072007_model (iper, mag, dip, rake, width, rRup, rjb,R_x,
     1                     vs30_rock, pgaRock,  lnSa2, sigmaX, tauX, 
     2                     specT, depthtop, Frv, Fn,  vs30_class, 
     3                     depthvs10rock, hwflag )
C         Compute soil amplification (i.e., 'lnSa1-lnSa2') and add to Constant displcaement rock spectrum
          lnSa = lnSaRock + (lnSa1-lnSa2)
 
      else
C         For cases where specT < TD compute regular ground motions. 
          call AS_072007_model (iper, mag, dip, rake, width, rRup, rjb,R_x,
     1                     vs30, pgaRock, lnSa, sigma, tau, 
     2                     specT, depthtop, Frv, Fn,  vs30_class, 
     3                     depthvs10, hwflag )
      endif

c     compute Sa (given the PGA rock value)
      sigma1 = sqrt( sigma**2 + tau**2 )
       if(sdi)then
       sde=lnSa+fac_sde	!fac_sde is log(T**2/(4pisq))
       rhat = min(10.,exp(sde)/dy_sdi)	!10 is an upper bound for rhat.
       lnSa = sdi_ratio(specT,mag,rhat,sigma1,sdisd) + sde
       sigma1=sdisd	!use sdi for all gnd_ep branches
       endif
c     Don't Convert units spectral acceleration to gal                                
c      lnSa = lnSa + 6.89                                                
      return
      end subroutine AS_072007 
c ----------------------------------------------------------------------

      subroutine AS_072007_model ( iper,mag, dip, rake, width, rRup, rjb,R_x,
     1                     vs30, pgaRock,  lnSa, sigma, tau, 
     2                     specT, depthtop, Frv, Fn,  vs30_class,
     3                     z10, hwflag )
      
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
c      real tauCorr, sigCorr
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

c		Updated coefficients according to AS08 paper by SR from matlab code
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
c		SR: this is different in paper, 826	
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
c	  Modified by SR to follow Eq. 13 of AS08 paper
      z0 = 2.
      z1 = 5.
      z2 = 10.	 
	  if (depthTop .lt. z2) then
	  	sum = sum + a16T*depthTop/10.0
	  else
		sum = sum + a16T
      endif

	 
C     Large Distance Model
c	  Modified by SR to follow Eq. 15 of AS08 paper
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
				

	real function sdi_ratio(per,M,rhat,sige,sdi)
	real M,rhat,td,dt,sde,sdi
c This function is not expected to be used initially but is here for future use. SH Mar 2013.
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
3	continue
c	print *,'b1,b2,b3,b4,b5,b6,a,b:'
c	print *,b1,b2,b3,b4,b5,b6,a,b
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

      function mu1_vs30(vs30, irelation)     

! irelation   relation
!       1     California
!       2     Japan


! Dates: 05/10/13 - Written by D.M. Boore 

      implicit none
      
      real :: ln_mu1, mu1_vs30, vs30 
     
      integer :: irelation
      
      if (irelation == 1) then 
      
        ln_mu1 = 
     :   (-7.15/4.0)*alog((vs30**4+570.94**4)/(1360.0**4+570.94**4))
        mu1_vs30 = exp(ln_mu1)
        
      else if (irelation == 2) then
      
        ln_mu1 = 
     :   (-5.23/2.0)*alog((vs30**2+412.39**2)/(1360.0**2+412.39**2))
        mu1_vs30 = exp(ln_mu1)      
      
      else
      
        ! No relation, return negative value
        mu1_vs30 = -9.9
      
      end if
      

      return
      
      end function mu1_vs30
! --------------------------------------------------------- mu1_vs30
      subroutine GailTable(i)
c the "i" index refers to which model's table is read in. This is a mod
c from the snippet Gail sent, which only allows one model.
c moved open to main. problems passing the string not resolved.
c Currently looking at 3 possible models, AB08, AB06', or Pz11
c Do not write to unit 94. All available periods are read in. 1st dimension (jf) is freq.
c
        parameter (gfac=6.8875526,sfac=2.3025851)	!to convert to base e
      common/gail1/xmag(20,3), gma(20,30,20,3), rlog(30,3), f(20,3),itype(3)
      common/gail2/nf(3), nd(3), nm(3)
      common/gnome/fname
      logical m7
      real a,b,c
      character*80 header,fname
      if(i.gt.3)stop 'please redimension the arrays in gail1 and gail2.'
      read(3,3)header
3     format(a)
      i2=max(1,index(fname,'.dat')-13)
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
c          a=gma(4,jd,jm,i)*sfac-gfac;b=gma(7,jd,jm,i)*sfac-gfac;c=gma(12,jd,jm,i)*sfac-gfac
c          if(m7)write(94,10)10**rlog(jd,i),exp(a),exp(b),exp(c)
10      format(f7.1,1p,3(1x,e11.5))
4000    continue
5000  continue
      close(3)
      return
      end subroutine GailTable

      real function amean11(amag,r,rjb,Vs30,jf,ka)
c Inputs: amag: Mw
c       r= distance (rjb or rcd, depending on ka)
c       Vs30 = top 30 m Vs. A or BC is expected.
c      ip = global period index not used.
c      jf = frequency index
c      ka = 1,2, or 3 depending on which table to use AB06 AB08 or P11
c     Gets ground motion value (ln PSA) from table
      real sfac,Vs30,r,rjb,amag
        parameter (gfac=6.8875526,sfac=2.3025851)	!to convert to base e
      common/gail1/xmag(20,3), gma(20,30,20,3), rlog(30,3), f(20,3), itype(3)
      common/gail2/nf(3), nd(3), nm(3)
      common/gail3/freq(13)
      real, dimension(13) :: bcfac
        real, dimension(20) :: avg
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
      fracf = (alog10 (freq(jf)) - alog10 (f(jfl,ka)) ) /
     *        (alog10 (f(jfu,ka)) - alog10 (f(jfl,ka)) )
c**   fracf gives interpolation fraction in frequency
15    continue
c     Find bounding jm values.
      jml = 0
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
      if(freq(jf).gt.2.1 .and. freq(jf) .lt.40.)then
c 3 g limit
      amean11=min(amean11,1.099)
      elseif(freq(jf).gt.90.)then
c 1.5 g limit PGA      
      amean11=min(amean11,0.405)
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
        sigPez11=ceus_sigma      !for special studies. Use a low sigma for all GMPE periods, magnitudes, etc.
      elseif(mag.le.7.0) then
      sigPez11=c12(ip)*mag+c13(ip)
      else
      sigPez11=fac*mag+c14(ip)
      endif
c the Pezeshk article is in base10 logarithm units. we work in natural log units.
      sigPez11=sigPez11*afac
      return
      end function sigPez11

c ------------------------------------------------------------------            

      subroutine ASK13_v11_model (iPer, mag, dip, FltWidth, ZTOR, Frv, Fn, rRup, rjb, Rx, Ry0, 
     1                     vs30, Sa1180, Z1,  z1_ref, hwflag, vs30_class, Region, 
     2                     lnSa, phi, tau)
c from Kamai email July 24 2013. z1_ref is input rather than computed, unless Japan.
c Steve Harmsen July 25, 2013. This version does not use the Ry0 distance metric.
c USES INFERRED VS30; 
c 7/26: CMS computations need to be reviewed. Hard rock results will be needed to compute the current
c  soil condition. Currently the required hard rock medians are saved in /ask/ (CMS only).
c
      implicit none
      integer MAXPER     
      parameter (MAXPER=23)
      real, dimension(21) :: meanspec,sigspec,psa_hr
	integer imsp(8,21),kmsp(0:10),jms,jper,jp,npnga
	logical lmsp(0:10,21),l_ms
      common/ms/ia,jms,npnga,l_ms,lmsp,imsp,meanspec,sigspec
       common/ask/psa_hr
      real c4(MAXPER), a1(MAXPER), a2(MAXPER), a3(MAXPER), a4(MAXPER), a5(MAXPER), a6(MAXPER)
      real a7(MAXPER), a8(MAXPER), a9(MAXPER), a10(MAXPER), a11(MAXPER)
      real a12(MAXPER), a13(MAXPER), a14(MAXPER), a15(MAXPER), a17(MAXPER)
      real a43(MAXPER), a44(MAXPER), a45(MAXPER), a46(MAXPER)  
      real a25(MAXPER), a28(MAXPER), a29(MAXPER), a31(MAXPER)
      real a36(MAXPER), a37(MAXPER), a38(MAXPER), a39(MAXPER)
      real a40(MAXPER), a41(MAXPER), a42(MAXPER), s5(MAXPER), s6(MAXPER)
      real s1_e(MAXPER), s2_e(MAXPER), s1_m(MAXPER), s2_m(MAXPER), s3(MAXPER), s4(MAXPER)
	 
      real period(MAXPER), b(MAXPER), vLin(MAXPER)
      real M1, M2, y1, y2, x1, x2, y1z, y2z, x1z, x2z
      real lnSa, Sa1180, rjb, rRup, Rx, Ry0, dip, mag, vs30
      real HW_taper1, HW_taper2, HW_taper3, HW_taper4, HW_taper5
      real damp_dSa1180, sigAmp, fltWidth, testv1
      real f1, f4, f5, f6, f7, f8, f10, f13, f_Reg
      real Ry1, ZTOR, Frv, Fn, SpecT
      real phiA_estimated, phiA_measured, phiA, phiB, tauA, tauB, phi, tau,phit, taut
      integer vs30_class, hwflag, iPer, Region, ia
      real n, c, Z1, zhat, c4_mag,tan20/0.3639702/
      real R, V1, Vs30Star, hw_a2, h1, h2, h3, R1, R2, z1_ref

      data period / 0.0, 0.02, 0.03, 0.05, 0.075, 0.1, 0.15, 0.2, 0.25, 
     1              0.3, 0.4, 0.5, 0.75, 1, 1.5, 2, 3, 4, 5, 6, 7.5, 10, -1.0/
c update Vlin at 0.05, 0.075, 0.10 s
      data Vlin/ 660,680,770,915,960,910,740,590,495,430,360,340,330,330,
     1			 330,330,330,330,330,330,330,330,330 /
      data b/ -1.47,-1.46,-1.39,-1.22,-1.15,-1.23,-1.59,-2.01,-2.41,-2.76,
     1         -3.28,-3.6,-3.8,-3.5,-2.4,-1,0,0,0,0,0,0,-2.02 /
      data c4/ 4.5,4.5,4.5,4.5,4.5,4.5,4.5,4.5,4.5,4.5,4.5,4.5,4.5,4.5,4.5,
     1     	4.5,4.5,4.5,4.5,4.5,4.5,4.5,4.5 /
c update a1 at 0.05, 0.075, 0.10 s
      data a1/ 0.587,0.598,0.602,0.707,0.973,1.169,1.442,1.637,1.701,1.712,
     1     1.662,1.571,1.299,1.043,0.665,0.329,-0.060,-0.299,-0.562,-0.875,-1.303,-1.928,5.975 /
      data a2/ -0.790,-0.790,-0.790,-0.790,-0.790,-0.790,-0.790,-0.790,-0.790,
     1      	-0.790,-0.790,-0.790,-0.790,-0.790,-0.790,-0.790,-0.790,-0.790,
     2       -0.765,-0.711,-0.634,-0.529,-0.919 /
      data a3/ 0.275,0.275,0.275,0.275,0.275,0.275,0.275,0.275,0.275,0.275,
     1        0.275,0.275,0.275,0.275,0.275,0.275,0.275,0.275,0.275,0.275,
     2        0.275,0.275,0.275 /
      data a4/ -0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,
     1		   -0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1 /
      data a5/ -0.41,-0.41,-0.41,-0.41,-0.41,-0.41,-0.41,-0.41,-0.41,-0.41,-0.41,
     1     	-0.41,-0.41,-0.41,-0.41,-0.41,-0.41,-0.41,-0.41,-0.41,-0.41,-0.41,-0.41 /
      data a6/ 2.154,2.146,2.157,2.085,2.029,2.041,2.121,2.224,2.312,2.338,2.469,
     1       	2.559,2.682,2.763,2.836,2.897,2.906,2.889,2.898,2.896,2.870,2.843,2.366 /
      data a7/ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 /
      data a8/ -0.015,-0.015,-0.015,-0.015,-0.015,-0.015,-0.022,-0.03,-0.038,-0.045,
     1        	-0.055,-0.065,-0.095,-0.11,-0.124,-0.138,-0.172,-0.197,-0.218,-0.235,
     2        	-0.255,-0.285,-0.094 /
      data a9/ 6.75,6.75,6.75,6.75,6.75,6.75,6.75,6.75,6.75,6.75,6.75,6.75,6.75,
     1 		   6.75,6.75,6.75,6.82,6.92,7,7.06,7.15,7.25,6.75 /
      data a10/ 1.735,1.718,1.615,1.358,1.258,1.310,1.660,2.220,2.770,3.250,
     1 		    3.990,4.450,4.750,4.300,2.650,0.550,-0.950,-0.950,-0.930,-0.910,
     2 			-0.875,-0.800,2.36 /
      data a11/ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 /
      data a12/ -0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,
     1 			-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1 /
      data a13/ 0.60,0.60,0.60,0.60,0.60,0.60,0.60,0.60,0.60,0.60,0.58,0.56,0.53,
     1 			0.50,0.42,0.35,0.20,0,0,0,0,0,0.25 /
      data a14/ -0.30,-0.30,-0.30,-0.30,-0.30,-0.30,-0.30,-0.30,-0.24,-0.19,
     1 		    -0.11,-0.04,0.07,0.15,0.27,0.35,0.46,0.54,0.61,0.65,0.72,0.80,0.22 /
      data a15/ 1.10,1.10,1.10,1.10,1.10,1.10,1.10,1.10,1.10,1.03,0.92,0.84,
     1 		    0.68,0.57,0.42,0.31,0.16,0.05,-0.04,-0.11,-0.19,-0.30,0.90 /
      data a17/ -0.0072,-0.0073,-0.0075,-0.0080,-0.0089,-0.0095,-0.0095,-0.0086,
     1        	-0.0074,-0.0064,-0.0043,-0.0032,-0.0025,-0.0025,-0.0022,-0.0019,-0.0015,
     2        	-0.0010,-0.0010,-0.0010,-0.0010,-0.0010,-0.0005 /
      data a43/ 0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10,
     1 	        0.14,0.165,0.22,0.26,0.34,0.41,0.51,0.55,0.55,0.42,0.28 /
      data a44/ 0.05,0.05,0.05,0.05,0.05,0.05,0.05,0.05,0.05,0.05,0.07,
     1 			0.10,0.14,0.165,0.21,0.25,0.30,0.32,0.32,0.32,0.29,0.22,0.15 /
      data a45/ 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.03,0.06,
     1 			0.10,0.14,0.165,0.20,0.22,0.23,0.23,0.22,0.20,0.17,0.14,0.09 /
      data a46/ -0.05,-0.05,-0.05,-0.05,-0.05,-0.05,-0.05,-0.03,0.00,0.03,
     1 			0.06,0.09,0.13,0.14,0.16,0.16,0.16,0.14,0.13,0.10,0.08,0.08,0.07 /
      data a25/ -0.0015,-0.0015,-0.0016,-0.0020,-0.0027,-0.0033,-0.0035,
     1         	  -0.0033,-0.0029,-0.0027,-0.0023,-0.0020,-0.0010,-0.0005,-0.0004,
     2         	  -0.0002,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,-0.0001 /
      data a28/ 0.0025,0.0024,0.0023,0.0027,0.0032,0.0036,0.0033,0.0027,
     1         	  0.0024,0.0020,0.0010,0.0008,0.0007,0.0007,0.0006,0.0003,0.0000,
     2         	  0.0000,0.0000,0.0000,0.0000,0.0000,0.0005 /
      data a29/ -0.0034,-0.0033,-0.0034,-0.0033,-0.0029,-0.0025,-0.0025,
     1         	  -0.0031,-0.0036,-0.0039,-0.0048,-0.0050,-0.0041,-0.0032,-0.0020,
     2         	  -0.0017,-0.0020,-0.0020,-0.0020,-0.0020,-0.0020,-0.0020,-0.0037 /
      data a31/ -0.1503,-0.1479,-0.1447,-0.1326,-0.1353,-0.1128,0.0383,
     1         	  0.0775,0.0741,0.2548,0.2136,0.1542,0.0787,0.0476,-0.0163,-0.1203,
     2         	  -0.2719,-0.2958,-0.2718,-0.2517,-0.1337,-0.0216,-0.1462 /
      data a36/ 0.2650,0.2550,0.2490,0.2020,0.1260,0.0220,-0.1360,-0.0780,
     1         	  0.0370,-0.0910,0.1290,0.3100,0.5050,0.3580,0.1310,0.1230,0.1090,
     2         	  0.1350,0.1890,0.2150,0.1660,0.0920,0.3770 /
      data a37/ 0.3370,0.3280,0.3200,0.2890,0.2750,0.2560,0.1620,0.2240,
     1         	  0.2480,0.2030,0.2320,0.2520,0.2080,0.2080,0.1080,0.0680,-0.0230,
     2         	  0.0280,0.0310,0.0240,-0.0610,-0.1590,0.2120 /
      data a38/ 0.1880,0.1840,0.1800,0.1670,0.1730,0.1890,0.1080,0.1150,
     1         	  0.1220,0.0960,0.1230,0.1340,0.1290,0.1520,0.1180,0.1190,0.0930,
     2         	  0.0840,0.0580,0.0650,0.0090,-0.0500,0.1570 /
      data a39/ 0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,
     1         	  0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,
     2         	  0.0000,0.0000,0.0000,0.0000,0.0000,0.0000 /
      data a40/ 0.0880,0.0880,0.0930,0.1330,0.1860,0.1600,0.0680,0.0480,
     1         	  0.0550,0.0730,0.1430,0.1600,0.1580,0.1450,0.1310,0.0830,0.0700,
     2         	  0.1010,0.0950,0.1330,0.1510,0.1240,0.0950 /
      data a41/ -0.1960,-0.1940,-0.1750,-0.0900,0.0900,0.0060,-0.1560,
     1         	  -0.2740,-0.2480,-0.2030,-0.1540,-0.1590,-0.1410,-0.1440,-0.1260,
     2         	  -0.0750,-0.0210,0.0720,0.2050,0.2850,0.3290,0.3010,-0.0380 /
      data a42/ 0.0440,0.0610,0.1620,0.4510,0.5060,0.3350,-0.0840,
     1         	  -0.1780,-0.1870,-0.1590,-0.0230,-0.0290,0.0610,0.0620,0.0370,
     2         	  -0.1430,-0.0280,-0.0970,0.0150,0.1040,0.2990,0.2430,0.0650 /

      data s1_e/ 0.754,0.760,0.781,0.810,0.810,0.810,0.801,0.789,0.770,0.740,
     1		   0.699,0.676,0.631,0.609,0.578,0.555,0.548,0.527,0.505,0.477,
     2		   0.457,0.429,0.662 /
      data s2_e/ 0.520,0.520,0.520,0.530,0.540,0.550,0.560,0.565,0.570,0.580,
     1		   0.590,0.600,0.615,0.630,0.640,0.650,0.640,0.630,0.630,0.630,
     2		   0.630,0.630,0.51 /
      data s3/ 0.47,0.47,0.47,0.47,0.47,0.47,0.47,0.47,0.47,0.47,0.47,0.47,
     1 		   0.47,0.47,0.47,0.47,0.47,0.47,0.47,0.47,0.47,0.47,0.38 /
      data s4/ 0.36,0.36,0.36,0.36,0.36,0.36,0.36,0.36,0.36,0.36,0.36,0.36,
     1 		   0.36,0.36,0.36,0.36,0.36,0.36,0.36,0.36,0.36,0.36,0.38 /
      data s1_m/ 0.741,0.747,0.769,0.798,0.798,0.795,0.773,0.753,0.729,
     1         0.693,0.644,0.616,0.566,0.541,0.506,0.48,0.472,0.447,0.425,
     2         0.395,0.378,0.359,0.66 /
      data s2_m/ 0.501,0.501,0.501,0.512,0.522,0.527,0.519,0.514,0.513,
     1         0.519,0.524,0.532,0.548,0.565,0.576,0.587,0.576,0.565,0.568,
     2         0.571,0.575,0.585,0.51 /
      data s5/ 0.540,0.5400,0.5500,0.5600,0.5700,0.5700,0.5800,0.5900,0.6100,
     1         0.6300,0.6600,0.6900,0.7300,0.7700,0.8000,0.8000,0.8000,0.7600,
     2         0.7200,0.7000,0.6700,0.6400,0.5800 /
      data s6/ 0.630,0.6300,0.6300,0.6500,0.6900,0.7000,0.7000,0.7000,0.7000,
     1         0.7000,0.7000,0.7000,0.6900,0.6800,0.6600,0.6200,0.5500,0.5200,
     2         0.5000,0.5000,0.5000,0.5000,0.5300 /

        
      n = 1.5

C     c is 2400 for PGV and 2.4 for all other periods
      if (period(iper) .eq. -1) then	
         c = 2400.0
      else
         c = 2.4
      endif

    
c	  magnitude dependent taper for C4. (eq. 4.4)
      if ( mag .ge. 5. ) then
        c4_mag = c4(iper)
      elseif ( mag .ge. 4.) then
        c4_mag = c4(iper) - (c4(iper)-1.)*(5. - mag)
      else
        c4_mag = 1.
      endif
		
c     Set distance (eq 4.3)
      R = sqrt(rRup**2 + c4_mag**2)
       	  
C     Base Model (eq 4.2)
      M1 = a9(iper)
      M2 = 5.0
      if ( mag .le. M2 ) then
        f1 = a1(iper) + a6(iper)*(Mag-M2) + a7(iper)*(Mag-M2)**2 + a4(iper)*(M2-M1) + a8(iper)*(8.5-M2)**2 +
     1                (a2(iper) + a3(iper)*(M2-M1)) * alog(R) + a17(iper)*rRup
      elseif ( mag .le. M1 ) then
        f1 = a1(iper) + a4(iper)*(Mag-M1) + a8(iper)*(8.5-Mag)**2 + (a2(iper)+ a3(iper)*(Mag-M1))*alog(R)+a17(iper)*rRup
      else
        f1 = a1(iper) + a5(iper)*(Mag-M1) + a8(iper)*(8.5-Mag)**2 + (a2(iper)+a3(iper)*(Mag-M1))*alog(R)+a17(iper)*rRup
      endif

c     style of faulting (eq 4.5 and 4.6) 
      if ( mag .lt. 4. ) then
        f7 = 0
        f8 = 0
      elseif ( mag .le. 5. ) then
        f7 = Frv * a11(iper) * (mag-4.)
        f8 = Fn * a12(iper) * (mag-4.)
      else 
        f7 = Frv * a11(iper)
        f8 = Fn * a12(iper)
      endif

c     ZTOR (eq 4.16)
      if (ZTOR .le. 20.) then 
        f6 = a15(iper) * ZTOR/20.0
      else
        f6 = a15(iper)
      endif    

c     Set VS30_star (eq 4.8 and 4.9)
      if ( period(iper) .ge. 3.0 ) then
        V1 = 800.
      elseif ( period(iper) .gt. 0.5 ) then
        V1 = exp( -0.35 * alog(period(iper)/0.5)  + alog(1500.) )
      else
        V1=1500.
      endif
      if ( vs30 .lt. v1 ) then
         vs30Star = vs30
      else
	vs30Star = v1
      endif		

c     Compute site amplification (Eq. 4.7)  
      if (vs30 .lt. vLin(iPer)) then
        f5 = a10(iper)*alog(vs30Star/vLin(iper)) - b(iper)*alog(c+Sa1180) 
     1              + b(iper)*alog(Sa1180+c*((vs30Star/vLin(iper))**(n)) )
      else
     	f5 = (a10(iper) + b(iper)*n) * alog(vs30Star/vLin(iper))
      endif

c     Set CA z1 reference (eq 4.18). This z1_ref was passed in (assuming constant Vs30 for all sites in map)
c For Variable Vs30, z1_ref should be precomputed for each site and may still be passed in.
c      if ( Region .ne. 10 ) then
c        z1_ref = exp ( -7.67/4. * alog( (Vs30**4 + 610.**4)/(1360.**4+610.**4) ) ) / 1000.
      if(Region .eq.10)then
c     Set Japan z1 reference (eq 4.19)
        z1_ref = exp ( -5.23/2. * alog( (Vs30**2 + 412.**2)/(1360.**2+412.**2) ) ) / 1000.
       endif
	  
C    if z1 is unknown, input z1<0 and then reference is used. (R.K.)
      if (z1 .lt. 0. ) then
		z1 = z1_ref
      endif
	  
	  
C     Soil Depth Model - Interpolate between mid Vs30 bins (eq 4.17)
      if ( vs30 .lt. 150. ) then 
        y1z = a43(iper) 
        y2z = a43(iper)
        x1z = 50. 
        x2z = 150.
      elseif ( vs30 .lt. 250. ) then
        y1z = a43(iper) 
        y2z = a44(iper)
        x1z = 150. 
        x2z = 250.
      elseif ( vs30 .lt. 400. ) then
        y1z = a44(iper) 
        y2z = a45(iper)
        x1z = 250. 
        x2z = 400.
      elseif ( vs30 .lt. 700. ) then
        y1z = a45(iper) 
        y2z = a46(iper)
        x1z = 400. 
        x2z = 700.
      else
        y1z = a46(iper) 
        y2z = a46(iper)
        x1z = 700. 
        x2z = 1000.
      endif        
	  
       f10 = (y1z + (y2z-y1z)/(x2z-x1z))*alog( (z1+0.01) /(z1_ref+0.01) )
	  
	  
c     Compute HW taper1 (eq 4.11) 
      if ( dip .lt. 30. ) then
        HW_taper1 = 60./ 45.
      else
        HW_taper1 = (90.-dip)/45.
      endif

c     Compute HW taper2 (eq. 4.12)
      hw_a2 = 0.2
      if( mag .gt. 6.5 ) then
        HW_taper2 = 1. + hw_a2 * (mag-6.5) 
      elseif ( mag .gt. 5.5 ) then
        HW_taper2 = 1. + HW_a2 * (mag-6.5) - (1-HW_a2)*(mag-6.5)**2
      else
        HW_taper2 = 0.
      endif

c     Compute HW taper 3 (eq. 4.13)
C	  April 11, correction by ronnie for HW_taper3 when Rx.gt.R2
      h1 = 0.25
      h2 = 1.5
      h3 = -0.75
      R1 = fltWidth * cos(dip*3.1415926/180.)
      R2 = 3.*R1
      if ( Rx .le. R1 ) then
        HW_taper3 = h1 + h2*(Rx/R1) + h3*(Rx/R1)**2
      elseif ( Rx . lt. R2 ) then
        HW_taper3 = 1. - (Rx-R1)/(R2-R1)
      else
        HW_taper3 = 0.
      endif 

c     Compute HW taper 4 (eq 4.14)
      if ( ZTOR .lt. 10. ) then
        HW_taper4 = 1. - (ZTOR**2) / 100.
      else
        HW_taper4 = 0.
      endif
      
C    Input Ry0 < 0 to use the 'no Ry0' version. if Ry0 is known and input is positive, uses Ry0 version. (R.K.)
      if (Ry0 .lt. 0 ) then
c     Compute HW taper 5 (eq. 4.15b)  **** No Ry0 version ***     
        if (Rjb .eq. 0. ) then
          HW_taper5 = 1. 
        elseif ( Rjb .lt. 30. ) then
          HW_taper5 = 1 - Rjb/30.
        else
          HW_taper5 = 0.
        endif
      else
C     Compute HW taper 5 (eq. 4.15a)  **** Ry0 version ***     
        Ry1 = Rx * tan20		!tan(20.*3.1415926/180.)
        if ( Ry0 .lt. Ry1 ) then
          HW_taper5 = 1.
        elseif ( Ry0-Ry1 .lt. 5. ) then
          HW_taper5 = 1. - (Ry0-Ry1) / 5.
        else
          HW_taper5 = 0.
        endif
      endif

c     Hanging wall Model (eq 4.10)
      if ( HWFlag .eq. 1 ) then
        f4 = a13(iper) * HW_taper1 * HW_taper2 * HW_taper3 * HW_taper4 * HW_taper5
      else
        f4 = 0.
      endif

C     Calcualte the Regional delta (for site response and anelastic attenuation) (R.K.)

C     Japan
      if ( Region .eq. 10 ) then
		
      if ( vs30 .lt. 150. ) then 
        y1 = a36(iper) 
        y2 = a36(iper)
        x1 = 50. 
        x2 = 150.
      elseif ( vs30 .lt. 250. ) then
        y1 = a36(iper) 
        y2 = a37(iper) 
        x1 = 150. 
        x2 = 250.
      elseif ( vs30 .lt. 350. ) then
        y1 = a37(iper) 
        y2 = a38(iper) 
        x1 = 250. 
        x2 = 350.
      elseif ( vs30 .lt. 450. ) then
        y1 = a38(iper) 
        y2 = a39(iper) 
        x1 = 350. 
        x2 = 450.
      elseif ( vs30 .lt. 600. ) then
        y1 = a39(iper) 
        y2 = a40(iper) 
        x1 = 450. 
        x2 = 600.
      elseif ( vs30 .lt. 850. ) then
        y1 = a40(iper) 
        y2 = a41(iper) 
        x1 = 600. 
        x2 = 850.
      elseif ( vs30 .lt. 1150. ) then
        y1 = a41(iper) 
        y2 = a42(iper) 
        x1 = 850. 
        x2 = 1150.
      else 
        y1 = a42(iper) 
        y2 = a42(iper) 
        x1 = 1150. 
        x2 = 3000.
      endif        
      
         f13 = y1 + (y2-y1)/(x2-x1) * (Vs30-x1)
      
	     f_Reg = f13 + a29(iper)*rRup
	  
C     Taiwan
      elseif (Region .eq. 3) then
        f_Reg = a31(iper)*alog(vs30Star/vLin(iper)) + a25(iper)*rRup
C     China
      elseif (Region .eq. 9) then
        f_Reg = a28(iper)*rRup
      else
        f_Reg = 0.0
      endif

	  
C     Set the Sigma Values
      
      if (region .ne. 10)  then
c     Compute within-event term, phiA, at the surface for linear site response (eq 7.1)
        if (mag .lt. 4.0) then
           phiA_estimated = s1_e(iper)
        elseif (mag .le. 6.0) then
           phiA_estimated = s1_e(iper) + ((s2_e(iper)-s1_e(iper))/2.0)*(mag-4.0)
        else
           phiA_estimated = s2_e(iper)
        endif

c     Compute within-event term, phiA, for known Vs30
        if (mag .lt. 4.0) then
           phiA_measured = s1_m(iper)
        elseif (mag .le. 6.0) then
           phiA_measured = s1_m(iper) + ((s2_m(iper)-s1_m(iper))/2.0)*(mag-4.0)
        else
           phiA_measured = s2_m(iper)
        endif
	  
	  
C     choose phiA by Vs30 class
        if (vs30_class .eq. 0 ) then
	     phiA = phiA_estimated
        elseif (vs30_class .eq. 1) then
		 phiA = phiA_measured
        else
	     stop 99
        endif

      else
	  

C calculate phi_A for Japan (eq. 7.3)
        if (Rrup .lt. 30) then
           phiA = s5(iper)        
        elseif (Rrup .le. 80) then
           phiA = s5(iper) + (s6(iper)-s5(iper))/50*(Rrup-30)
        else
           phiA = s6(iper)
        endif
      endif
	  
c     Compute between-event term, tau (eq. 7.2)
      if (mag .lt. 5.0) then
         tauA = s3(iper)
      elseif (mag .le. 7.0) then
         tauA = s3(iper) + ((s4(iper)-s3(iper))/2.0)*(mag-5.0)
      else
         tauA = s4(iper)
      endif
      tauB = tauA

c     Compute phiB, within-event term with site amp variablity removed (eq. 7.7)
      sigAmp = 0.4
      phiB = sqrt( phiA**2 - sigAmp**2)
      
c     Compute parital derivative of alog(soil amp) w.r.t. alog(Sa1180) (eq. 7.10)
      if ( vs30 .ge. vLin(iper)) then
        dAmp_dSa1180 = 0.
      else
        dAmp_dSa1180 = b(iper)*Sa1180 * ( -1. / (Sa1180+c) 
     1              + 1./ (Sa1180 + c*(vs30/vLin(iper))**(n)) )
      endif

C     Compute phi, with non-linear effects (eq. 7.8)
      phi = sqrt( phiB**2 * (1. + dAmp_dSa1180)**2 + sigAmp**2 )

C     Compute tau, with non-linear effects (eq. 7.9)
      tau = tauB * (1. + dAmp_dSa1180)
      
c     Compute median ground motion (eq. 4.1)
      lnSa = f1 + f4 + f5 + f6 + f7 + f8 + f10 +f_Reg 

      if(.not.l_ms)return
c Play it again, Norm Abrahamson, to compute the mean spectrum. New July 26 2013.
c	 hardrock medians available to apply with current vs30 condition. Dec 17 2013
	do jp=1,npnga
c The below conditional says, compute if coeffs are available at the period with index jp. This
c will generally be true for the NGA-W relations but less so for older GMPEs with fewer periods.
c  
	jper=imsp(ia,jp)
        if ( jp .eq. jms)then
c use the available information. Frequency dependence of mean and sigma require the loop.
        meanspec(jp)=lnSa
        sigspec(jp)=sqrt(phi**2+tau**2)
	elseif (lmsp(ia,jp)) then
	Sa1180=psa_hr(jp)	!available 12/17/2013.
c	  magnitude dependent taper for C4. (eq. 4.4)
      if ( mag .ge. 5. ) then
        c4_mag = c4(jper)
      elseif ( mag .ge. 4.) then
        c4_mag = c4(jper) - (c4(jper)-1.)*(5. - mag)
      else
        c4_mag = 1.
      endif
		
c     Set distance (eq 4.3)
      R = sqrt(rRup**2 + c4_mag**2)
       	  
C     Base Model (eq 4.2)
      M1 = a9(jper)
      M2 = 5.0
      if ( mag .le. M2 ) then
        f1 = a1(jper) + a6(jper)*(Mag-M2) + a7(jper)*(Mag-M2)**2 + a4(jper)*(M2-M1) + a8(jper)*(8.5-M2)**2 +
     1                (a2(jper) + a3(jper)*(M2-M1)) * alog(R) + a17(jper)*rRup
      elseif ( mag .le. M1 ) then
        f1 = a1(jper) + a4(jper)*(Mag-M1) + a8(jper)*(8.5-Mag)**2 + (a2(jper)+ a3(jper)*(Mag-M1))*alog(R)+a17(jper)*rRup
      else
        f1 = a1(jper) + a5(jper)*(Mag-M1) + a8(jper)*(8.5-Mag)**2 + (a2(jper)+a3(jper)*(Mag-M1))*alog(R)+a17(jper)*rRup
      endif

c     style of faulting (eq 4.5 and 4.6) 
      if ( mag .lt. 4. ) then
        f7 = 0
        f8 = 0
      elseif ( mag .le. 5. ) then
        f7 = Frv * a11(jper) * (mag-4.)
        f8 = Fn * a12(jper) * (mag-4.)
      else 
        f7 = Frv * a11(jper)
        f8 = Fn * a12(jper)
      endif

c     ZTOR (eq 4.16)
      if (ZTOR .le. 20.) then 
        f6 = a15(jper) * ZTOR/20.0
      else
        f6 = a15(jper)
      endif    

c     Set VS30_star (eq 4.8 and 4.9)
      if ( period(jper) .ge. 3.0 ) then
        V1 = 800.
      elseif ( period(jper) .gt. 0.5 ) then
        V1 = exp( -0.35 * alog(period(jper)/0.5)  + alog(1500.) )
      else
        V1=1500.
      endif
      if ( vs30 .lt. v1 ) then
         vs30Star = vs30
      else
	vs30Star = v1
      endif		

c     Compute site amplification (Eq. 4.7)  
      if (vs30 .lt. vLin(iPer)) then
        f5 = a10(jper)*alog(vs30Star/vLin(jper)) - b(jper)*alog(c+Sa1180) 
     1              + b(jper)*alog(Sa1180+c*((vs30Star/vLin(jper))**(n)) )
      else
     	f5 = (a10(jper) + b(jper)*n) * alog(vs30Star/vLin(jper))
      endif

c     Set CA z1 reference (eq 4.18). This z1_ref was passed in (assuming constant Vs30 for all sites in map)
c For Variable Vs30, z1_ref should be precomputed for each site and may still be passed in.
c      if ( Region .ne. 10 ) then
c        z1_ref = exp ( -7.67/4. * alog( (Vs30**4 + 610.**4)/(1360.**4+610.**4) ) ) / 1000.
      if(Region .eq.10)then
c     Set Japan z1 reference (eq 4.19)
        z1_ref = exp ( -5.23/2. * alog( (Vs30**2 + 412.**2)/(1360.**2+412.**2) ) ) / 1000.
       endif
	  
C    if z1 is unknown, input z1<0 and then reference is used. (R.K.)
      if (z1 .lt. 0. ) then
		z1 = z1_ref
      endif
	  
	  
C     Soil Depth Model - Interpolate between mid Vs30 bins (eq 4.17)
      if ( vs30 .lt. 150. ) then 
        y1z = a43(jper) 
        y2z = a43(jper)
        x1z = 50. 
        x2z = 150.
      elseif ( vs30 .lt. 250. ) then
        y1z = a43(jper) 
        y2z = a44(jper)
        x1z = 150. 
        x2z = 250.
      elseif ( vs30 .lt. 400. ) then
        y1z = a44(jper) 
        y2z = a45(jper)
        x1z = 250. 
        x2z = 400.
      elseif ( vs30 .lt. 700. ) then
        y1z = a45(jper) 
        y2z = a46(jper)
        x1z = 400. 
        x2z = 700.
      else
        y1z = a46(jper) 
        y2z = a46(jper)
        x1z = 700. 
        x2z = 1000.
      endif        
	  
       f10 = (y1z + (y2z-y1z)/(x2z-x1z))*alog( (z1+0.01) /(z1_ref+0.01) )
	  
	  
c     Compute HW taper1 (eq 4.11) 
      if ( dip .lt. 30. ) then
        HW_taper1 = 60./ 45.
      else
        HW_taper1 = (90.-dip)/45.
      endif

c     Compute HW taper2 (eq. 4.12)
      hw_a2 = 0.2
      if( mag .gt. 6.5 ) then
        HW_taper2 = 1. + hw_a2 * (mag-6.5) 
      elseif ( mag .gt. 5.5 ) then
        HW_taper2 = 1. + HW_a2 * (mag-6.5) - (1-HW_a2)*(mag-6.5)**2
      else
        HW_taper2 = 0.
      endif

c     Compute HW taper 3 (eq. 4.13)
C	  April 11, correction by ronnie for HW_taper3 when Rx.gt.R2
      h1 = 0.25
      h2 = 1.5
      h3 = -0.75
      R1 = fltWidth * cos(dip*3.1415926/180.)
      R2 = 3.*R1
      if ( Rx .le. R1 ) then
        HW_taper3 = h1 + h2*(Rx/R1) + h3*(Rx/R1)**2
      elseif ( Rx . lt. R2 ) then
        HW_taper3 = 1. - (Rx-R1)/(R2-R1)
      else
        HW_taper3 = 0.
      endif 

c     Compute HW taper 4 (eq 4.14)
      if ( ZTOR .lt. 10. ) then
        HW_taper4 = 1. - (ZTOR**2) / 100.
      else
        HW_taper4 = 0.
      endif
      
C    Input Ry0 < 0 to use the 'no Ry0' version. if Ry0 is known and input is positive, uses Ry0 version. (R.K.)
      if (Ry0 .lt. 0 ) then
c     Compute HW taper 5 (eq. 4.15b)  **** No Ry0 version ***     
        if (Rjb .eq. 0. ) then
          HW_taper5 = 1. 
        elseif ( Rjb .lt. 30. ) then
          HW_taper5 = 1 - Rjb/30.
        else
          HW_taper5 = 0.
        endif
      else
C     Compute HW taper 5 (eq. 4.15a)  **** Ry0 version ***     
        Ry1 = Rx * tan20		!tan(20.*3.1415926/180.)
        if ( Ry0 .lt. Ry1 ) then
          HW_taper5 = 1.
        elseif ( Ry0-Ry1 .lt. 5. ) then
          HW_taper5 = 1. - (Ry0-Ry1) / 5.
        else
          HW_taper5 = 0.
        endif
      endif

c     Hanging wall Model (eq 4.10)
      if ( HWFlag .eq. 1 ) then
        f4 = a13(jper) * HW_taper1 * HW_taper2 * HW_taper3 * HW_taper4 * HW_taper5
      else
        f4 = 0.
      endif

C     Calcualte the Regional delta (for site response and anelastic attenuation) (R.K.)

C     Japan
      if ( Region .eq. 10 ) then
		
      if ( vs30 .lt. 150. ) then 
        y1 = a36(jper) 
        y2 = a36(jper)
        x1 = 50. 
        x2 = 150.
      elseif ( vs30 .lt. 250. ) then
        y1 = a36(jper) 
        y2 = a37(jper) 
        x1 = 150. 
        x2 = 250.
      elseif ( vs30 .lt. 350. ) then
        y1 = a37(jper) 
        y2 = a38(jper) 
        x1 = 250. 
        x2 = 350.
      elseif ( vs30 .lt. 450. ) then
        y1 = a38(jper) 
        y2 = a39(jper) 
        x1 = 350. 
        x2 = 450.
      elseif ( vs30 .lt. 600. ) then
        y1 = a39(jper) 
        y2 = a40(jper) 
        x1 = 450. 
        x2 = 600.
      elseif ( vs30 .lt. 850. ) then
        y1 = a40(jper) 
        y2 = a41(jper) 
        x1 = 600. 
        x2 = 850.
      elseif ( vs30 .lt. 1150. ) then
        y1 = a41(jper) 
        y2 = a42(jper) 
        x1 = 850. 
        x2 = 1150.
      else 
        y1 = a42(jper) 
        y2 = a42(jper) 
        x1 = 1150. 
        x2 = 3000.
      endif        
      
         f13 = y1 + (y2-y1)/(x2-x1) * (Vs30-x1)
      
	     f_Reg = f13 + a29(jper)*rRup
	  
C     Taiwan
      elseif (Region .eq. 3) then
        f_Reg = a31(jper)*alog(vs30Star/vLin(jper)) + a25(jper)*rRup
C     China
      elseif (Region .eq. 9) then
        f_Reg = a28(jper)*rRup
      else
        f_Reg = 0.0
      endif

	  
C     Set the Sigma Values
      
      if (region .ne. 10)  then
c     Compute within-event term, phiA, at the surface for linear site response (eq 7.1)
        if (mag .lt. 4.0) then
           phiA_estimated = s1_e(jper)
        elseif (mag .le. 6.0) then
           phiA_estimated = s1_e(jper) + ((s2_e(jper)-s1_e(jper))/2.0)*(mag-4.0)
        else
           phiA_estimated = s2_e(jper)
        endif

c     Compute within-event term, phiA, for known Vs30
        if (mag .lt. 4.0) then
           phiA_measured = s1_m(jper)
        elseif (mag .le. 6.0) then
           phiA_measured = s1_m(jper) + ((s2_m(jper)-s1_m(jper))/2.0)*(mag-4.0)
        else
           phiA_measured = s2_m(jper)
        endif
	  
	  
C     choose phiA by Vs30 class
        if (vs30_class .eq. 0 ) then
	     phiA = phiA_estimated
        elseif (vs30_class .eq. 1) then
		 phiA = phiA_measured
        else
	     stop 99
        endif

      else
	  

C calculate phi_A for Japan (eq. 7.3)
        if (Rrup .lt. 30) then
           phiA = s5(jper)        
        elseif (Rrup .le. 80) then
           phiA = s5(jper) + (s6(jper)-s5(jper))/50*(Rrup-30)
        else
           phiA = s6(jper)
        endif
      endif
	  
c     Compute between-event term, tau (eq. 7.2)
      if (mag .lt. 5.0) then
         tauA = s3(jper)
      elseif (mag .le. 7.0) then
         tauA = s3(jper) + ((s4(jper)-s3(jper))/2.0)*(mag-5.0)
      else
         tauA = s4(jper)
      endif
      tauB = tauA

c     Compute phiB, within-event term with site amp variablity removed (eq. 7.7)
      sigAmp = 0.4
      phiB = sqrt( phiA**2 - sigAmp**2)
      
c     Compute parital derivative of alog(soil amp) w.r.t. alog(Sa1180) (eq. 7.10)
      if ( vs30 .ge. vLin(jper)) then
        dAmp_dSa1180 = 0.
      else
        dAmp_dSa1180 = b(jper)*Sa1180 * ( -1. / (Sa1180+c) 
     1              + 1./ (Sa1180 + c*(vs30/vLin(jper))**n ) )
      endif

C     Compute phi, with non-linear effects (eq. 7.8)
      phit = sqrt( phiB**2 * (1. + dAmp_dSa1180)**2 + sigAmp**2 )

C     Compute tau, with non-linear effects (eq. 7.9)
      taut = tauB * (1. + dAmp_dSa1180)
      sigspec(jp)= sqrt(taut**2+phit**2)
c     Compute median ground motion (eq. 4.1)
      meanspec(jp) = f1 + f4 + f5 + f6 + f7 + f8 + f10 +f_Reg 
      endif	!computable period?
      enddo	!cms periods
      end    subroutine ASK13_v11_model  			

