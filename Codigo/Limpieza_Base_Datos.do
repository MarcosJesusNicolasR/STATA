*===============================================================================
* 		Limpieza/Creacion de la Base de Datos
*===============================================================================

*============ DATOS (ENIGH 2020) ===============================================

*---> Limpieza de la Tabla Agro para obtener los hogares en el tratamiento

* Importamos la tabla AGRO del 2020
use "C:\Users\aega6\Documents\UNIVERSIDAD\8VO SEMESTRE\Analisis de Datos\Proyecto Final\Proyecto 1\BASE DE DATOS\conjunto_de_datos_enigh_ns_2020_csv\conjunto_de_datos_agro_enigh_2020_ns\conjunto_de_datos\conjunto_de_datos_agro_enigh_2020_ns.dta", clear

* Convertimos de string a numerico
destring nvo_prog1 nvo_prog2 nvo_prog3 prep_deriv, replace

* Ordenamos los datos para facilitar lectura
sort folioviv foliohog numren

* Generamos una variable que identifique si una persona en beneficiaria del programa Sembrando Vida
gen SemVid=1 if nvo_prog1==2001 | nvo_prog2==2001 | nvo_prog3==2001
replace SemVid=1 if nvo_prog1==2002 | nvo_prog2==2002 | nvo_prog3==2002
replace SemVid=0 if SemVid==.

* Generamos una variable que identifique si un hogar es beneficiario del programa Sembrando Vida (Un hogar es beneficiario si hay más de un integrante del hogar que es beneficiario del Programa).
bysort folioviv folioviv: egen num_bene_semvid=sum(SemVid)
gen tratamiento = (num_bene_semvid>0)

* Nos interesan las variables ventas_tri auto_tri nvo_apoyo, sin embargo, queremos esos datos a nivel hogar por lo que lo pasamos a nivel hogar.
rename ventas_tri ventas_tri_ind
rename auto_tri auto_tri_ind
rename nvo_apoyo nvo_apoyo_ind

* ventas_tri: Promedio trimestral de ventas por hogar
bysort folioviv foliohog: egen ventas_tri=sum(ventas_tri_ind)
* auto_tri: Promedio de autoconsumo trimestral por hogar 
bysort folioviv foliohog: egen auto_tri=sum(auto_tri_ind)
* nvo_apoyo: indica si un hogar cuenta con un nuevo apoyo gubernamental
bysort folioviv foliohog: egen num_nvo_apoyo=sum(nvo_apoyo_ind)
gen nvo_apoyo = (num_nvo_apoyo>0)
* prep_deriv: Algún integrante del hogar preparo tierras para el cultivo
rename prep_deriv prep_deriv_ind
bysort folioviv foliohog: egen prep_deriv=min(prep_deriv_ind)

* Mantenemos las variables que nos interesan
keep folioviv foliohog numren tratamiento ventas_tri auto_tri nvo_apoyo tipoact cose_cria prep_deriv

*---> Obtencion de los datos para la Alimentacion
* Unimos la tabla hogares
joinby folioviv foliohog using "C:\Users\aega6\Documents\UNIVERSIDAD\8VO SEMESTRE\Analisis de Datos\Proyecto Final\Proyecto 1\BASE DE DATOS\conjunto_de_datos_enigh_ns_2020_csv\conjunto_de_datos_hogares_enigh_2020_ns\conjunto_de_datos\conjunto_de_datos_hogares_enigh_2020_ns.dta", unmatched(none)

destring acc_alim1 acc_alim2 acc_alim3 acc_alim4 acc_alim5 acc_alim6, replace

* Sustituimos los valores no=2 por no=0 y quitamos valores que no sirven
foreach x in acc_alim1 acc_alim2 acc_alim3 acc_alim4 acc_alim5 acc_alim6{
	replace `x'=0 if `x'==2
}

* Generamos el Puntaje de privaciones en alimentacion
gen p_alim=acc_alim1 +acc_alim2 +acc_alim3+ acc_alim4+ acc_alim5+ acc_alim6

* Nos quedamos solo con las variables relevantes para el analisis
keep folioviv foliohog numren tratamiento ventas_tri auto_tri nvo_apoyo tipoact cose_cria prep_deriv p_alim acc_alim1 acc_alim2 acc_alim3 acc_alim4 acc_alim5 acc_alim6 telefono tv_paga conex_inte num_auto num_tosta num_micro num_refri num_estuf num_lavad tsalud1_h autocons

*---> Obtencion de los datos para la salud
* Unimos la tabla Poblacion
joinby folioviv foliohog numren using "C:\Users\aega6\Documents\UNIVERSIDAD\8VO SEMESTRE\Analisis de Datos\Proyecto Final\Proyecto 1\BASE DE DATOS\conjunto_de_datos_enigh_ns_2020_csv\conjunto_de_datos_poblacion_enigh_2020_ns\conjunto_de_datos\conjunto_de_datos_poblacion_enigh_2020_ns.dta", unmatched(none)

* La variable atemed cumple con el proposito buscado para la variable que marque la carencia de acceso a servicios de salud. Por lo que solo debemos renombrarla para facilitar nuetros fines así como reemplazar algunos valores
destring atemed, replace
replace atemed=0 if atemed==2
rename atemed acc_salud

* Quitamos todas la variables que no son de nuestro interes
keep folioviv foliohog numren tratamiento ventas_tri auto_tri nvo_apoyo tipoact cose_cria prep_deriv p_alim acc_alim1 acc_alim2 acc_alim3 acc_alim4 acc_alim5 acc_alim6 telefono tv_paga conex_inte num_auto num_tosta num_micro num_refri num_estuf num_lavad tsalud1_h autocons acc_salud

*---> Obtencion de los datos para los ingresos
* Unimos la tabla Concetradohogares
joinby folioviv foliohog using "C:\Users\aega6\Documents\UNIVER~1\8VOSEM~1\ANALIS~1\PROYEC~1\PROYEC~2\BASEDE~1\CONJUN~2\COCAF3~1\CONJUN~1\conjunto_de_datos_concentradohogar_enigh_2020_ns.dta", unmatched(none)

* Pongo el ingreso trimestral sin los apoyos gubernamentales
gen ing_sin_a=ing_cor-bene_gob


* Usamos la clasificacion  en clase baja, media y alta
gen c_hog=est_socio-4 if est_socio==1 | est_socio==2
replace c_hog = 0 if c_hog==.
replace c_hog = (-1)*c_hog


keep folioviv foliohog numren tratamiento ventas_tri auto_tri nvo_apoyo tipoact cose_cria prep_deriv p_alim acc_alim1 acc_alim2 acc_alim3 acc_alim4 acc_alim5 acc_alim6 factor telefono tv_paga conex_inte num_auto num_tosta num_micro num_refri num_estuf num_lavad tsalud1_h autocons acc_salud ing_sin_a est_socio sexo_jefe edad_jefe educa_jefe tot_integ ubica_geo c_hog tam_loc

*---> Generacion del Acceso a la salud por Hogar
sort folioviv foliohog numren
gen acc_salud_persona = (acc_salud == 1)
bysort folioviv foliohog: egen num_acc_salud = sum(acc_salud_persona)
gen acc_salud_hogar = (num_acc_salud < (tot_int/3))
drop acc_salud_persona num_acc_salud acc_salud

*---> Generamos la variable que mide la pobreza en cada hogar
gen acc_alim = (p_alim>2)
gen pob_mio=5*acc_alim+3*acc_salud_hogar+c_hog

*---> Generamos una variable que indique el estado
gen estado = floor(ubica_geo/1000)

* Ordenamos los datos para facilitar lectura
sort folioviv foliohog numren

*============ DATOS (CONEVAL Pobreza 2020) =====================================
*----> Unimos la tabla generada por Coneval.
* Esta tabla tiene la clasificacion de las personas pobres oficial. Además viene con una serie de variables que informan caracteristicas de hogares y personas que pueden ser de gran utilidad para realizar el analisis.

joinby folioviv foliohog numren using "C:\Users\aega6\Documents\UNIVERSIDAD\8VO SEMESTRE\Analisis de Datos\Proyecto Final\Proyecto 1\BASE DE DATOS\CONEVAL_Pobreza\Base final\pobreza_20.dta", unmatched(none)

* Clasificamos a los hogares pobres y en pobreza extrema. Si hay algún miembro del hogar que es pobre entonces el hogar es pobres

bysort folioviv foliohog: egen pobres_hog=sum(pobreza)
bysort folioviv foliohog: egen pobres_ext_hog=sum(pobreza_e)

gen pobreza_hog= (pobres_hog>0)
replace pobreza_hog=0 if pobreza_hog==.

gen pobreza_e_hog= (pobres_ext_hog>0)
replace pobreza_e_hog=0 if pobreza_e_hog==.


*----> Finalmente colapsamos los datos a nivel hogar. 
* Variables Obtenidas de la ENIGH
global X="acc_alim tratamiento ventas_tri auto_tri nvo_apoyo tipoact cose_cria prep_deriv p_alim acc_alim1 acc_alim2 acc_alim3 acc_alim4 acc_alim5 acc_alim6  factor telefono tv_paga conex_inte num_auto num_tosta num_micro num_refri num_estuf num_lavad tsalud1_h autocons acc_salud ing_sin_a est_socio sexo_jefe edad_jefe educa_jefe tot_integ tam_loc pob_mio c_hog ubica_geo estado"
* Varibles obtenidas por CONEVAL Pobreza
global Y="pea rururb ic_cv icv_pisos icv_muros icv_techos icv_hac ic_sbv isb_agua pobreza_hog pobreza_e_hog profun int_pob int_pobe int_vulcar int_caren niv_ed"

collapse (mean) $X $Y, by(folioviv foliohog)

* Ultimos retoques
drop if edad_jefe<=23 & edad_jefe>=96

* Adjuntamos las caracteristicas de la vivienda
joinby folioviv using "C:\Users\aega6\Documents\UNIVERSIDAD\8VO SEMESTRE\Analisis de Datos\Proyecto Final\Proyecto 1\BASE DE DATOS\conjunto_de_datos_enigh_ns_2020_csv\conjunto_de_datos_viviendas_enigh_2020_ns\conjunto_de_datos\conjunto_de_datos_viviendas_enigh_2020_ns.dta", unmatched(none)

*Convertimos todas los valores a numerico para que se puedan trabajar con los metodos

destring *, replace

*======= GENERACION DE VARIABLES UTILES PARA PUNTAJE DE PROPENSION =============

* Varibles para generar el puntaje de propension: Deben ser aquellas que afecten la participacion pero no el indice de pobreza.

* Generamos las variables dummy en caso de que un predictor sea categorico.
* tipo_adqui
drop if tipo_adqui==.
tabulate tipo_adqui, generate(dummy)
rename dummy1 tipo_adqui_hecha
rename dummy2 tipo_adqui_constru
rename dummy3 tipo_adqui_constru_el
rename dummy4 tipo_adqui_otro
* prep_deriv
tabulate prep_deriv, generate(dummy)
rename dummy1 prep_tie_si
drop dummy2
* cose_cria
replace cose_cria=1 if cose_cria<1.5
replace cose_cria=0 if cose_cria>=1.5
* escrituras
drop if escrituras==.
tabulate escrituras, generate(dummy)
rename dummy1 escri_due
rename dummy2 escri_otro
rename dummy3 escri_sin
rename dummy4 escri_ns
* Sur
gen norte=1 if estado==2 | estado==26 | estado==8 | estado==5 | estado==19 | estado==28 | estado==3 | estado==25 | estado==18 | estado==10 | estado==32 | estado==14 | estado==1 | estado==6 | estado==16 | estado==24
replace norte=0 if norte==.
gen sur=1 if norte==0
replace sur=0 if sur==.
* tam_loc_peq
tabulate tam_loc, generate(dummy)
rename dummy4 tam_loc_peq
drop dummy1 dummy2 dummy3


* Guardamos la base limpia
save "C:\Users\aega6\Documents\UNIVERSIDAD\8VO SEMESTRE\Analisis de Datos\Proyecto Final\Proyecto 1\BASE DE DATOS\conjunto_de_datos_enigh_ns_2020_csv\Base_enigh_2020_limpia.dta", replace






