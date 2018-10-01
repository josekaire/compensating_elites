/*Do file for: Compensating elites: How international demands for economic liberalization can lead to more repressive autocracies. ISQ, Forthcoming. José Kaire. September 15, 2018. www.josekaire.com*/

*****************
**  Data setup **
*****************
clear /* Clear the stata session*/

*Load data
use"https://github.com/josekaire/compensating_elites/raw/master/Compensating%20elites%20data%20(published).dta" /*This donwloads the data but you can save the data locally and open that instead. See website*/

*Create the format for subsequent graphs. 
global format1 recast(line)plotopts(lcolor(black))   recastci(rline) ciopts(lcolor(black) lpattern(dash)) ///
		xtitle(Selecotrate's collective action capacity)  /// 
		ylabel(, labsize(medsmall) glcolor(gs15)) ///
		graphregion(color(white)) plotregion(color(none)) title("") 
		
global format2 vertical mcolor(black) ciopts(lcolor(black)) legend(off) ///
xlabel(.84 "Selectorate with low collective action" 1.167 "Selectorate with high collective action", ///
 glcolor(gs15)) graphregion(color(white)) plotregion(color(none))

**************
**  Analyses **
***************

*				*					*
* Effect of w (collective action) 	*
*				*					*
global controls ib1.regimem  s_ifimem   s_odf2   s_oillog s_gdp s_prioconflict s_year2  /*Creates list of indepenent variables*/

*Human rights scores (Model 1)
xtreg s_hrs c.s_elc##c.qregime c.s_ai $controls , mle
	estimates store m1
	quietly margins, dydx(s_elc) at(qregime=(.2 (.1) 1 )) 
	marginsplot, name(gm2, replace)  ytitle("Effect of economic liberalization on physical integrity")  $format1 
	
*CSO limitations (Model 3)
xtreg s_v2 c.s_elc##c.qregime c.s_ai $controls , mle
	estimates store m2
		margins, dydx(s_elc) at(qregime=(.2 (.1) 1 )) 
		marginsplot, name(gm4, replace) ytitle("Effect of economic liberalization on CSO limitaitons")  $format1 

*Produce Figure 3 of the manuscript 
graph combine gm2 gm4, graphregion(color(white)) xsize(6) name(combined, replace) 

*				*					*
* Effect of d (costs of losing power)*
*				*					*
global xlist2  c.s_elc##c.qregime##c.s_ai $controls /*IVs for models 2 and 4*/

*Human right scores 
xtreg  s_hrs $xlist2 , mle
	estimates store m3
	margins, dydx(s_elc) at(qregime=(.1) s_ai=(.162)) post 
	estimates store o1

quietly xtreg s_hrs $xlist2 , mle
	margins, dydx(s_elc) at(qregime=(.9) s_ai=(.162)) post  
	estimates store o2

coefplot o1 o2, $format2 name(lowd, replace) title(Low international costs of losing office, color(black))  

*With d
quietly xtreg s_hrs  $xlist2 , mle
margins, dydx(s_elc) at(qregime=(.1) s_ai=(.27)) post 
estimates store o3

quietly xtreg s_hrs  $xlist2 , mle
margins, dydx(s_elc) at(qregime=(.9) s_ai=(.27)) post 
estimates store o4

coefplot o3 o4, $format2 name(highd, replace)  title(High international costs of losing office, color(black)) 

graph combine lowd highd, name(hrs, replace) ycommon graphregion(color(white)) xsize(6)
******
*Limitions on CSOs

xtreg  s_v2 $xlist2 , mle
	estimates store m4
	margins, dydx(s_elc) at(qregime=(.1) s_ai=(.162)) post 
	estimates store o1

quietly xtreg s_v2 $xlist2 , mle
	margins, dydx(s_elc) at(qregime=(.9) s_ai=(.162)) post  
	estimates store o2

coefplot o1 o2, $format2 name(lowd, replace) title(Low international costs of losing office, color(black))  

*With d
quietly xtreg s_v2  $xlist2 , mle
margins, dydx(s_elc) at(qregime=(.2) s_ai=(.27)) post 
estimates store o3

quietly xtreg s_v2  $xlist2 , mle
margins, dydx(s_elc) at(qregime=(.9) s_ai=(.27)) post
estimates store o4

coefplot o3 o4, $format2 name(highd, replace)  title(High international costs of losing office, color(black)) 

graph combine lowd highd, name(csor, replace) ycommon graphregion(color(white)) xsize(6)


*Create Figure 4 of manusciprt
graph combine hrs csor, graphregion(color(white)) xsize(6) c(1)

*Create text file with Table 2 at the specifided location 
estout m1 m3 m2 m4 using "C:\Users\JoseK\OneDrive\Documentos\Research\Repression\table1.txt",  ///
r label  cells(b(star fmt(2))& se(par fmt(2))) s(N  aic)

*****************

****Appendix*****
*Hypothesis 1:
	*Quadratic ELC 
	xtreg s_hrs s_elc c.s_elc#c.s_elc##c.qregime s_ai $controls , mle
		estimates store hrs_quad
		quietly margins, dydx(s_elc) at(qregime=(.2 (.1) 1 )) 
		marginsplot, name(a1, replace)  ytitle("Effect of economic liberalization on physical integrity")  $format1 
	xtreg s_v2 s_elc c.s_elc#c.s_elc##c.qregime s_ai $controls , mle
			estimates store cso_quad
			margins, dydx(s_elc) at(qregime=(.2 (.1) 1 )) 
			marginsplot, name(a2, replace) ytitle("Effect of economic liberalization on CSO limitaitons")  $format1 
	graph combine a1 a2, graphregion(color(white)) xsize(6) name(combined, replace) 
	*Lagged ELC
	/*sort ccode year
	by ccode: gen s_elc_lag = s_elc[_n-1] if year==year[_n-1]+1 */
	xtreg s_hrs c.s_elc_lag##c.qregime c.s_ai $controls , mle
	estimates store hrs_lagged
	xtreg s_v2 c.s_elc_lag##c.qregime c.s_ai $controls , mle
	estimates store cso_lagged
	*Fixed effects 
	xtreg s_hrs c.s_elc##c.qregime c.s_ai $controls ,  fe
	estimates store hrs_fixed
	xtreg s_v2 c.s_elc##c.qregime c.s_ai $controls ,  fe
	estimates store cso_fixed

estout hrs_quad hrs_lagged hrs_fixed cso_quad cso_lagged cso_fixed  using "C:\Users\JoseK\OneDrive\Documentos\Research\Repression\tableA1.txt",  ///
r label  cells(b(star fmt(2))& se(par fmt(2))) s(N  aic)
*Hypothesis 2:
	*Lagged ELC
	xtreg  s_hrs c.s_elc_lag##c.qregime##c.s_ai  $controls, mle
	estimates store h2_hrs_lag
	xtreg  s_v2 c.s_elc_lag##c.qregime##c.s_ai  $controls, mle
	estimates store h2_cso_lag
	*Fixed effects 
	xtreg  s_hrs c.s_elc##c.qregime##c.s_ai  $controls, fe
	estimates store h2_hrs_fixed
	xtreg  s_v2 c.s_elc##c.qregime##c.s_ai  $controls, fe
	estimates store h2_cso_fixed 
estout  h2_hrs_lag h2_hrs_fixed h2_cso_lag h2_cso_fixed   using "C:\Users\JoseK\OneDrive\Documentos\Research\Repression\tableA2.txt",  ///
r label  cells(b(star fmt(2))& se(par fmt(2))) s(N  aic)


global xlist2  c.s_elc_lag##c.qregime##c.s_ai $controls

*Human right scores 
xtreg  s_hrs $xlist2 , mle
	estimates store m3
	margins, dydx(s_elc) at(qregime=(.1) s_ai=(.162)) post 
	estimates store o1

quietly xtreg s_hrs $xlist2 , mle
	margins, dydx(s_elc) at(qregime=(.9) s_ai=(.162)) post  
	estimates store o2

coefplot o1 o2, $format2 name(lowd, replace) title(Low international costs of losing office, color(black))  

*With d
quietly xtreg s_hrs  $xlist2 , mle
margins, dydx(s_elc) at(qregime=(.1) s_ai=(.27)) post 
estimates store o3

quietly xtreg s_hrs  $xlist2 , mle
margins, dydx(s_elc) at(qregime=(.9) s_ai=(.27)) post 
estimates store o4

coefplot o3 o4, $format2 name(highd, replace)  title(High international costs of losing office, color(black)) 

graph combine lowd highd, name(hrs, replace) ycommon graphregion(color(white)) xsize(6)
******
*Limitions on CSOs

xtreg  s_v2 $xlist2 , mle
	estimates store m4
	margins, dydx(s_elc) at(qregime=(.1) s_ai=(.162)) post 
	estimates store o1

quietly xtreg s_v2 $xlist2 , mle
	margins, dydx(s_elc) at(qregime=(.9) s_ai=(.162)) post  
	estimates store o2

coefplot o1 o2, $format2 name(lowd, replace) title(Low international costs of losing office, color(black))  

*With d
quietly xtreg s_v2  $xlist2 , mle
margins, dydx(s_elc) at(qregime=(.2) s_ai=(.27)) post 
estimates store o3

quietly xtreg s_v2  $xlist2 , mle
margins, dydx(s_elc) at(qregime=(.9) s_ai=(.27)) post
estimates store o4

coefplot o3 o4, $format2 name(highd, replace)  title(High international costs of losing office, color(black)) 

graph combine lowd highd, name(csor, replace) ycommon graphregion(color(white)) xsize(6)



graph combine hrs csor, graphregion(color(white)) xsize(6) c(1)
*******************End of do file*********************
	



