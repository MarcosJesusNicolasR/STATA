*===============================================================================
* 		Exploracion de los datos
*===============================================================================

*---> Cargamos la base de datos
use "C:\Users\aega6\Documents\UNIVERSIDAD\8VO SEMESTRE\Analisis de Datos\Proyecto Final\Proyecto 1\BASE DE DATOS\conjunto_de_datos_enigh_ns_2020_csv\Base_enigh_2020_limpia.dta", clear 

* Ordenamos los datos
sort folioviv foliohog

*-> Tratados vs Controles
* Grafica de Barras
graph hbar (count), over(tratamiento) blabel(bar) title(Total) subtitle(Tratados Controles) scheme(s2color)

graph bar, over(pobreza_hog, relabel(1 "No pobres" 2 "Pobres")) over(tratamiento, relabel(1 "Controles" 2 "Tratados")) asyvars stack blabel(total) title(Pobreza por Hogares) subtitle(Tratados y Controles) scheme(meta)

graph box pob_mio, over(tratamiento, relabel(1 "No pobres" 2 "Pobres")) title(Pobreza) subtitle(Tratados vs Controles) scheme(meta)


graph bar, over(pobreza_e_hog, relabel(1 "No pobres" 2 "E. Pobres")) over(tratamiento, relabel(1 "Controles" 2 "Tratados")) asyvars stack blabel(total) title(Pobreza Extrema por Hogares) subtitle(Tratados y Controles) scheme(meta)

graph bar, over(pobreza_e_hog, relabel(1 "No pobres" 2 "E. Pobres")) over(tratamiento, relabel(1 "Controles" 2 "Tratados")) asyvars stack blabel(total) title(Pobreza Extrema por Hogares) subtitle(Tratados y Controles) scheme(meta)



* Distribuciones

*===============================================================================
* 		Estimacion del Impacto con Emparejamiento por puntaje de propension
*===============================================================================
*---> Cargamos la base de datos
use "C:\Users\aega6\Documents\UNIVERSIDAD\8VO SEMESTRE\Analisis de Datos\Proyecto Final\Proyecto 1\BASE DE DATOS\conjunto_de_datos_enigh_ns_2020_csv\Base_enigh_2020_limpia.dta", clear

gen educa_jefe_2=edad_jefe*edad_jefe
gen inter=rururb*prep_tie_si*cose_cria
gen escri=escri_due*escri_otro*escri_sin
gen inter2=tot_integ*tam_loc

*---> Varibles para formar el puntaje de propension
global V_1="cose_cria sexo_jefe niv_ed tot_integ escri_due inter tipo_adqui_constru tam_loc_peq tsalud1_h autocons acc_alim ing_sin_a est_socio"


global V_2="cose_cria sexo_jefe niv_ed tot_integ escri_due inter tipo_adqui_constru tam_loc_peq tsalud1_h autocons acc_alim" 

*---> Calculamos el puntaje de propension
probit tratamiento $V_1

* Para estimar los efectos marginales se emplea el comando "mfx" , esto indica cuánto cambia la probabilidad de haber reccibido el tratamiento al cambiar en uno la variable x.
*mfx

drop pscore
* Calculamos los puntajes
predict pscore


*---> Generamos una grafica para visualizar la distribucion del puntaje de propension
twoway (kdensity pscore if tratamiento==0, lwidth(meidum) lpattern(solid) lcolor(red)) (kdensity pscore if tratamiento==1, lwidth(meidum) lpattern(dash) lcolor(blue)), legend(order(1 "Control" 2 "Tratamiento")) ytitle(Densidad) xtitle(Probabilidad estimada)

twoway (hist pscore if tratamiento==0, lwidth(meidum) lpattern(solid) lcolor(red)) (hist pscore if tratamiento==1, lwidth(meidum) lpattern(dash) lcolor(blue)), legend(order(1 "Control" 2 "Tratamiento")) ytitle(Densidad) xtitle(Probabilidad estimada)


drop pscore

*---> Para restringirnos al soporte común
sum pscore if tratamiento==1
local min_t=r(min)
local max_t=r(max)
sum pscore if tratamiento==0
local min_c=r(min)
local max_c=r(max)
keep if (pscore>=`min_t' & pscore <= `max_c')

*-> Obtenemos el impacto
* Emparejando por k-vecinos más cercanos
psmatch2 tratamiento, outcome(pobreza_hog) pscore(pscore) neighbor(2) caliper(.1)

bootstrap r(att) : psmatch2 tratamiento , pscore(pscore) outcome(pobreza_hog) neighbor(5) caliper(.1) common

*===============================================================================
drop ps block
pscore tratamiento $V_2, pscore(ps) blockid(block) comsup level(0.1) 

*twoway (kdensity ps if tratamiento==0, lwidth(meidum) lpattern(solid) lcolor(red)) (kdensity ps if tratamiento==1, lwidth(meidum) lpattern(dash) lcolor(blue)), legend(order(1 "Control" 2 "Tratamiento")) ytitle(Densidad) xtitle(Probabilidad estimada)

attnd pobreza_hog tratamiento , pscore(ps) comsup

attr pobreza tratamiento , pscore(ps) blockid(block) comsup

attk pobreza tratamiento , pscore(ps) comsup boostrap reps(50)

*reg ventas_tri tratamiento
*	outreg2 using "C:\Users\aega6\Documents\UNIVERSIDAD\8VO SEMESTRE\Analisis de Datos\Proyecto Final\Proyecto 1\Tablas\comp_trat_cont.xls", replace excel ctitle(D_ventas_tri)
	
reg ventas_tri tratamiento if _support==1
	outreg2 using "C:\Users\aega6\Documents\UNIVERSIDAD\8VO SEMESTRE\Analisis de Datos\Proyecto Final\Proyecto 1\Tablas\comp_trat_cont_w.xlsx", replace excel ctitle(D_ventas_tri)

foreach var in acc_alim auto_tri tipoact p_alim acc_alim1 acc_alim2 acc_alim3 acc_alim4 acc_alim5 acc_alim6 telefono tv_paga conex_inte num_auto num_tosta num_micro num_refri num_estuf num_lavad acc_salud ing_sin_a est_socio pea ic_cv icv_pisos icv_muros icv_techos icv_hac ic_sbv isb_agua profun int_pob int_pobe int_vulcar int_caren niv_ed{
	*reg `var' tratamiento
	*outreg2 using "C:\Users\aega6\Documents\UNIVERSIDAD\8VO SEMESTRE\Analisis de Datos\Proyecto Final\Proyecto 1\Tablas\comp_trat_cont.xls", append excel ctitle(D_`var')
	reg `var' tratamiento if _support==1
	outreg2 using "C:\Users\aega6\Documents\UNIVERSIDAD\8VO SEMESTRE\Analisis de Datos\Proyecto Final\Proyecto 1\Tablas\comp_trat_cont_w.xlsx", append excel ctitle(D_`var')
}
