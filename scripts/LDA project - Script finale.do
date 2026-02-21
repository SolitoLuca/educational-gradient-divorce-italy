
cd "C:\Users\Lapo\Desktop\Longitudinal data analysis\MINI-PROJECT\Dataset"
use FSS_2016_detailed.dta, clear
 
count // Il dataset contiene 24753 osservazioni (individui)

* Rimosse le osservazioni relative con anno di inizio della prima convivenza e anno del primo matrimonio entrambi missing:
drop if aicpm1 == . & cpman1 == . & anmat1 == . // 6369 osservazioni rimosse (25,74%)

count // 18384 osservazioni rimaste

********************************************************************* 

* Variabile anno di inizio convivenza
gen ANCON1 = aicpm1
replace ANCON1 = cpman1 if ANCON1 == . & cpman1 != .

* Variabile anno di separazione da matrimonio
gen ANSEP = ansep1 
replace ANSEP = anleg1 if ANSEP == . & anleg1 != .
replace ANSEP = andiv1 if ANSEP == . & andiv1 != .
// Aggrego in ordine di priorità temporale: separazione di fatto (ansep1) --> separazione legale (anleg1) --> divorzio (andiv1)

********************************************************************* 

* Variabile tipologia della prima unione: convivenza vs matrimonio
gen PRIMA_UNIONE = . 

replace PRIMA_UNIONE = 0 if ANCON1 < anmat1 & ANCON1 != . & anmat1 != .
// Se l'anno di inizio della prima convivenza è precedente all'anno del primo matrimonio, la prima unione è una convivenza
replace PRIMA_UNIONE = 1 if ANCON1 >= anmat1 & ANCON1 != . & anmat1 != .
// Se l'anno di inizio della prima convivenza coincide o è successivo all'anno del primo matrimonio, la prima unione è un matrimonio

fre stciv if qmatri == . // 848 individui mai sposati
fre ANCON1 if qmatri == .
replace PRIMA_UNIONE = 0 if qmatri == . & ANCON1 != .
// Se l'individuo non si è mai sposato/a e l'anno di inizio della prima convivenza non è missing, la prima unione è una convivenza

replace PRIMA_UNIONE = 1 if (qmatri == 1 | qmatri == 2) & convpm == 1  & cpmpr1 == 1 
// Se l'individuo si è sposato/a almeno una volta, non ha convissuto con partner che poi non ha sposato e non ha convissuto con il futuro coniuge prima del primo matrimonio, la prima unione è un matrimonio

replace PRIMA_UNIONE = 1 if PRIMA_UNIONE == . & ANCON1 == . & (qmatri == 1 | qmatri == 2)
// Se PRIMA_UNIONE è missing, l'anno di inizio della prima convivenza è missing ma l'individuo si è sposato/a almeno una volta, si considera come prima unione il matrimonio

list ANCON1 anmat1 afcpm1 ANSEP qmatri if PRIMA_UNIONE == .

replace PRIMA_UNIONE = 0 if PRIMA_UNIONE == . 
// Se l'individuo si è sposato/a ma l'anno del primo matrimonio è missing mentre quello di inizio della prima convivenza è disponibile, si considera come prima unione la convivenza

replace PRIMA_UNIONE = 0 if PRIMA_UNIONE == . & ANCON1 != .
replace PRIMA_UNIONE = 1 if PRIMA_UNIONE == . & anmat1 != .

label variable PRIMA_UNIONE "Tipologia prima unione"
label define PRIMA_UNIONE 0 "Convivenza" 1 "Matrimonio"
label values PRIMA_UNIONE PRIMA_UNIONE

********************************************************************* 

* Variabile separazione da prima unione: non separato/a vs separato/a
gen SEP = .

replace SEP = 0 if PRIMA_UNIONE == 1 & qmatri == 1 & (stciv == 2 | stciv == 6)
// Se la prima unione è un matrimonio, l'individuo non si è risposato/a e lo stato civile attuale è coniugato o vedovo, l'individuo non si è separato/a (dal matrimonio)
replace SEP = 1 if PRIMA_UNIONE == 1 & qmatri == 2 | (stciv > 2 & stciv < 6)
// Se la prima unione è un matrimonio, l'individuo si è risposato/a o lo stato civile attuale è separato (di fatto o legalmente) o divorziato, l'individuo si è separato/a (dal matrimonio)

replace SEP = 0 if PRIMA_UNIONE == 0 & afcpm1 == . & qmatri == .
// Se la prima unione è una convivenza, l'anno di fine della prima convivenza è missing e l'individuo non si mai sposato/a, l'individuo non si è separato/a (dalla convivenza)

replace SEP = 0 if PRIMA_UNIONE == 0 & afcpm1 > anmat1 & afcpm1 != . & anmat1 != .
// Se la prima unione è una convivenza e l'anno di fine della convivenza è successivo all'anno del primo matrimonio, l'individuo non si è separato/a (dalla convivenza) --> censura a destra
replace SEP = 1 if PRIMA_UNIONE == 0 & afcpm1 < anmat1 & afcpm1 != . & anmat1 != .
// Se la prima unione è una convivenza e l'anno di fine della convivenza è precedente all'anno del primo matrimonio, l'individuo si è separato/a (dalla convivenza) 

replace SEP = 0 if PRIMA_UNIONE == 0 & afcpm1 == . & anmat1 != .
// Se la prima unione è una convivenza, l'anno di fine della prima convivenza è missing mentre l'anno del primo matrimonio è disponibile, l'individuo non si è separato/a (dalla convivenza) --> censura a destra
replace SEP = 1 if PRIMA_UNIONE == 0 & afcpm1 != . & anmat1 == .
// Se la prima unione è una convivenza, l'anno di fine della prima convivenza è disponibile mentre l'anno del primo matrimonio è missing, l'individuo si è separato/a (dalla convivenza) 

fre SEP
list cpman1 afcpm1 anmat1 anved1 qmatri stciv if SEP == .
drop if SEP == . // 1 osservazione rimossa

label variable SEP "Separazione da prima unione"
label define SEP 0 "Non separato/a" 1 "Separato/a"
label values SEP SEP

fre ANSEP if PRIMA_UNIONE == 1 & SEP == 1 
list anmat1 afcpm1 if ANSEP == . & PRIMA_UNIONE == 1 & SEP == 1 

replace ANSEP = afcpm1 if ANSEP == . & PRIMA_UNIONE == 1 & SEP == 1 & anmat1 < afcpm1
// Se la prima unione è un matrimonio, l'individuo si è separato/a ma l'anno della separazione è missing, l'anno di fine della prima unione viene imputato con l'anno di fine della prima convivenza (che è successivo all'anno del primo matrimonio)

drop if PRIMA_UNIONE == 0 & SEP == 1 & afcpm1 == . // 7 osservazioni rimosse
drop if PRIMA_UNIONE == 1 & SEP == 1  & ANSEP == . // 424 osservazioni rimosse
// Se l'individuo si è separato/a (dalla convivenza o dal matrimonio) ma l'anno della separazione è missing, l'osservazione viene rimossa

********************************************************************* 

* Variabile durata della prima unione
gen DUR_UNIONE = .

replace DUR_UNIONE = 2016 - anmat1 if PRIMA_UNIONE == 1 & SEP == 0 & stciv == 2 
// Durata della prima unione per gli individui la cui prima unione è un matrimonio, non separati e attualmente coniugati

replace DUR_UNIONE = anved1 - anmat1 if PRIMA_UNIONE == 1 & SEP == 0 & stciv == 6 
// Durata della prima unione per gli individui la cui prima unione è un matrimonio, non separati e attualmente vedovi

replace DUR_UNIONE = ANSEP - anmat1 if PRIMA_UNIONE == 1 & SEP == 1 
// Durata della prima unione per gli individui la cui prima unione è un matrimonio e si sono separati

replace DUR_UNIONE = anmat1 - ANCON1 if PRIMA_UNIONE == 0 & SEP == 0 & qmatri != .
// Durata della prima unione per gli individui la cui prima unione è una convivenza, non si separati durante la convivenza e poi si sono sposati 

replace DUR_UNIONE = 2016 - ANCON1 if PRIMA_UNIONE == 0 & SEP == 0 & qmatri == . 
// Durata della prima unione per gli individui la cui prima unione è una convivenza, non si sono separati durante la convivenza e non si sono sposati

replace DUR_UNIONE = afcpm1 - ANCON1 if PRIMA_UNIONE == 0 & SEP == 1 
// Durata della prima unione per gli individui la cui prima unione è una convivenza e si sono separati durante la convivenza

label variable DUR_UNIONE "Durata della prima unione"

drop if PRIMA_UNIONE == 1 & qmatri == 1 & stciv == 6 & anved1 == .
// Se la prima unione è un matrimonio, l'individuo si è sposato/a una sola volta, è attualmente vedovo/a ma l'anno della prima vedovanza è missing, l'osservazione viene rimossa (8 osservazioni)

drop if DUR_UNIONE == 0 // Non è possibile stimare il rischio per gli inidividui la cui unione si forma e si scioglie nello stesso anno

count // 17786 osservazioni nel campione analitico
di 17786/24753 // Mantenute il 71,85% delle osservazioni del campione iniziale
di 17786/18384 // Mantenute il 96,74% delle osservazioni della popolazione a rischio 

*********************************************************************

* Variabile id:
gen id = _n

fre tint // Variabile titolo di istruzione 
* Ricodifica della variabile time-constant titolo di istruzione in tre categorie:
gen ISTRUZ = .
replace ISTRUZ = 0 if tint > 8
replace ISTRUZ = 1 if tint > 6 & tint < 9
replace ISTRUZ = 2 if tint < 7
label define ISTRUZ 0 "Licenza media o inferiore" 1 "Diploma" 2 "Laurea" 
label value ISTRUZ ISTRUZ
label variable ISTRUZ "Titolo di studio (3 categorie)"

* Variabile dummy time-constant che ndica se un individuo ha conseguito il titolo di studio entro la fine della sua prima unione:
gen TITOLO_RAGGIUNTO = .
replace TITOLO_RAGGIUNTO = 1 if tintanno == .
replace TITOLO_RAGGIUNTO = 0 if PRIMA_UNIONE == 0 & tintanno != . & tintanno > (ANCON1 + DUR_UNIONE)
replace TITOLO_RAGGIUNTO = 0 if PRIMA_UNIONE == 1 & tintanno != . & tintanno > (anmat1 + DUR_UNIONE)
replace TITOLO_RAGGIUNTO = 1 if PRIMA_UNIONE == 0 & tintanno != . & tintanno <= (ANCON1 + DUR_UNIONE)
replace TITOLO_RAGGIUNTO = 1 if PRIMA_UNIONE == 1 & tintanno != . & tintanno <= (anmat1 + DUR_UNIONE)
label define TITOLO_RAGGIUNTO 0 "Titolo non raggiunto" 1 "Titolo raggiunto"
label value TITOLO_RAGGIUNTO TITOLO_RAGGIUNTO
label variable TITOLO_RAGGIUNTO "Raggiungimento del titolo entro la fine della prima unione"

* Variabile time-constant anno di inizio della prima unione:
gen ANNO_PRIMA_UNIONE = .
replace ANNO_PRIMA_UNIONE = ANCON1 if PRIMA_UNIONE == 0
replace ANNO_PRIMA_UNIONE = anmat1 if PRIMA_UNIONE == 1
label variable ANNO_PRIMA_UNIONE "Anno di inizio della prima unione"

* Variabile time-constant coorte della prima unione:
gen COORTE = .
replace COORTE = 0 if ANNO_PRIMA_UNIONE < 1971
replace COORTE = 1 if ANNO_PRIMA_UNIONE > 1970 & ANNO_PRIMA_UNIONE < 1981
replace COORTE = 2 if ANNO_PRIMA_UNIONE > 1980 & ANNO_PRIMA_UNIONE < 1991
replace COORTE = 3 if ANNO_PRIMA_UNIONE > 1990 & ANNO_PRIMA_UNIONE < 2001
replace COORTE = 4 if ANNO_PRIMA_UNIONE > 2000
label define COORTE 0 "Fino al 1970" 1 "1971-1980" 2 "1981-1990" 3 "1991-2000" 4 "Dal 2001 in poi"
label values COORTE COORTE
label variable COORTE "Coorte della prima unione"

* Variabile time-constant sesso:
fre sesso
gen SESSO = 0 if sesso == 1
replace SESSO = 1 if sesso == 2
label define SESSO 0 "Maschio" 1 "Femmina"
label values SESSO SESSO
label variable SESSO "Sesso"

* Variabile time-constant anno di inizio del primo lavoro:
gen ANNO_PRIMO_LAVORO = 100000 if lavman == 1 
replace ANNO_PRIMO_LAVORO = anini1 if ANNO_PRIMO_LAVORO == .
replace ANNO_PRIMO_LAVORO = anini2 if ANNO_PRIMO_LAVORO == .
replace ANNO_PRIMO_LAVORO = anini3 if ANNO_PRIMO_LAVORO == .
replace ANNO_PRIMO_LAVORO = anini4 if ANNO_PRIMO_LAVORO == .
replace ANNO_PRIMO_LAVORO = anini5 if ANNO_PRIMO_LAVORO == .
replace ANNO_PRIMO_LAVORO = anini6 if ANNO_PRIMO_LAVORO == .
replace ANNO_PRIMO_LAVORO = anini7 if ANNO_PRIMO_LAVORO == .
replace ANNO_PRIMO_LAVORO = anini8 if ANNO_PRIMO_LAVORO == .
replace ANNO_PRIMO_LAVORO = anini9 if ANNO_PRIMO_LAVORO == .
replace ANNO_PRIMO_LAVORO = anini10 if ANNO_PRIMO_LAVORO == .
replace ANNO_PRIMO_LAVORO = anini11 if ANNO_PRIMO_LAVORO == .
replace ANNO_PRIMO_LAVORO = lavoran if ANNO_PRIMO_LAVORO == .
// Se l'anno del primo lavoro è missing viene imputato con anini2–anini11 (in ordine) e, se tutti mancanti, con lavoran come ultima alternativa
replace ANNO_PRIMO_LAVORO = 200000 if ANNO_PRIMO_LAVORO == . 
label define ANNO_PRIMO_LAVORO 100000 "Mai lavorato" 200000 "Non si ricorda"
label value ANNO_PRIMO_LAVORO ANNO_PRIMO_LAVORO
label variable ANNO_PRIMO_LAVORO "Anno del primo lavoro"

* Variabile time-constant ripartizione territoriale
fre rip
gen RIP = 0 if rip >= 1 & rip < 4
replace RIP = 1 if rip == 4 | rip == 5
label define RIP 0 "Nord-Centro" 1 "Sud-Isole"
label values RIP RIP
lab variable RIP "Ripartizione territoriale"

* Variabile time-constant titolo d'istruzione più alto tra i genitori
gen ISTRUZ_GEN = min(titmad, titpad)
recode ISTRUZ_GEN (9/12 = 0 "Licenza media o inferiore") (7/8 = 1 "Diploma") (1/6 = 2 "Laurea"), gen(GEN_ISTRUZ)
replace GEN_ISTRUZ = . if GEN_ISTRUZ == 13
lab variable GEN_ISTRUZ "Titolo d'istruzione più alto tra i genitori dell'intervistato (3 categorie)"

keep id PRIMA_UNIONE SEP DUR_UNIONE ISTRUZ COORTE SESSO RIP GEN_ISTRUZ ANCON1 afcpm1 anmat1 ANSEP tintanno ANNO_PRIMO_LAVORO TITOLO_RAGGIUNTO

**********************************************************************

/*
stset DUR_UNIONE if TITOLO_RAGGIUNTO == 1, fail(SEP) id(id) origin(time -1) exit(time 40)
sts graph, by (ISTRUZ) ylabel(0.70(0.05)1) legend(position(6)) xtitle("Durata della prima unione in anni") title ("Funzione di sopravvivenza")
sts graph, by(ISTRUZ) hazard title ("Funzione di rischio") // Non proporzionalità
sts graph, by(COORTE) hazard 
sts graph, by(SESSO) hazard 
sts graph, by(PRIMA_UNIONE) hazard 

stset DUR_UNIONE if TITOLO_RAGGIUNTO == 1 & SESSO == 0, fail(SEP) id(id) origin(time -1) exit(time 40)
sts graph, by (ISTRUZ) ylabel(0.70(0.05)1) legend(position(6)) xtitle("Durata della prima unione in anni") title ("Funzione di sopravvivenza: Uomini")

stset DUR_UNIONE if TITOLO_RAGGIUNTO == 1 & SESSO == 1, fail(SEP) id(id) origin (time -1) exit(time 40)
sts graph, by (ISTRUZ) ylabel(0.70(0.05)1) legend(position(6)) xtitle("Durata della prima unione in anni") title ("Funzione di sopravvivenza: Donne")

stset DUR_UNIONE if TITOLO_RAGGIUNTO == 1 & PRIMA_UNIONE == 0, fail(SEP) id(id) origin(time -1) exit(time 40)
sts graph, by (ISTRUZ) legend(position(6)) xtitle("Durata della prima unione in anni") title ("Funzione di sopravvivenza: Convivenze")

stset DUR_UNIONE if TITOLO_RAGGIUNTO == 1 & PRIMA_UNIONE == 1, fail(SEP) id(id) origin (time -1) exit(time 40)
sts graph, by (ISTRUZ) ylabel(0.70(0.05)1) legend(position(6)) xtitle("Durata della prima unione in anni") title ("Funzione di sopravvivenza: Matrimoni")
*/

**********************************************************************

replace DUR_UNIONE = 40 if DUR_UNIONE > 40

* Preparazione dei dati per EHA a tempo discreto:
expand DUR_UNIONE
by id, sort: gen ANNO = _n  

gen EVENTO = 0 if SEP == 0
replace EVENTO = 0 if PRIMA_UNIONE == 0 & SEP == 1 & (ANCON1 + ANNO) < afcpm1
replace EVENTO = 1 if PRIMA_UNIONE == 0 & SEP == 1 & (ANCON1 + ANNO) == afcpm1
replace EVENTO = 0 if PRIMA_UNIONE == 1 & SEP == 1 & (anmat1 + ANNO) < ANSEP
replace EVENTO = 1 if PRIMA_UNIONE == 1 & SEP == 1 & (anmat1 + ANNO) == ANSEP

* Variabile time-varying livello di istruzione: 
gen LIVELLO_ISTRUZ = .
replace LIVELLO_ISTRUZ = 0 if tintanno == . | ISTRUZ == 0
replace LIVELLO_ISTRUZ = ISTRUZ if PRIMA_UNIONE == 0 & tintanno != . & tintanno <= (ANCON1 + ANNO)
replace LIVELLO_ISTRUZ = ISTRUZ if PRIMA_UNIONE == 1 & tintanno != . & tintanno <= (anmat1 + ANNO)
replace LIVELLO_ISTRUZ = ISTRUZ - 1 if PRIMA_UNIONE == 0 & tintanno != . & tintanno > (ANCON1 + ANNO) & ISTRUZ > 0
replace LIVELLO_ISTRUZ = ISTRUZ - 1 if PRIMA_UNIONE == 1 & tintanno != . & tintanno > (anmat1 + ANNO) & ISTRUZ > 0
label values LIVELLO_ISTRUZ ISTRUZ

* Variabile time-varying primo lavoro: 
gen PRIMO_LAVORO = .
replace PRIMO_LAVORO = 0 if PRIMA_UNIONE == 0 & ANNO_PRIMO_LAVORO > (ANCON1 + ANNO)
replace PRIMO_LAVORO = 1 if PRIMA_UNIONE == 0 & ANNO_PRIMO_LAVORO <= (ANCON1 + ANNO)
replace PRIMO_LAVORO = 0 if PRIMA_UNIONE == 1 & ANNO_PRIMO_LAVORO > (anmat1 + ANNO)
replace PRIMO_LAVORO = 1 if PRIMA_UNIONE == 1 & ANNO_PRIMO_LAVORO <= (anmat1 + ANNO)
label define PRIMO_LAVORO 0 "Non ha iniziato a lavorare" 1 "Ha iniziato a lavorare" 
label values PRIMO_LAVORO PRIMO_LAVORO

**********************************************************************

/*
logit EVENTO i.ANNO, or cluster(id)
predict hazard0
*/

* Intervalli per il modello piecewise:
gen PERIODO = .
replace PERIODO = 1 if 1 <= ANNO & ANNO < 3
replace PERIODO = 2 if 3 <= ANNO & ANNO < 8
replace PERIODO = 3 if 8 <= ANNO & ANNO < 16
replace PERIODO = 4 if 16 <= ANNO & ANNO < 20
replace PERIODO = 5 if 20 <= ANNO & ANNO < 26
replace PERIODO = 6 if ANNO >= 26
label define PERIODO 1 "1-2 anni" 2 "3-7 anni" 3 "8-15 anni" 4 "16-19 anni" 5 "20-25 anni" 6 ">25 anni"
label values PERIODO PERIODO

/*
logit EVENTO i.PERIODO, or cluster(id)
predict hazard0_PERIODO 

line hazard0 hazard0_PERIODO ANNO if ANNO != 0, c(J J) sort l1title("Baseline hazard") legend(order(1 "ANNO" 2 "PERIODO"))
*/

**********************************************************************

* Valutazione dell'assunzione di proporzionalità di LIVELLO_ISTRUZ tramite l'interazione tra LIVELLO_ISTRUZ e il tempo (durata dell'unione):

logit EVENTO ib2.LIVELLO_ISTRUZ##i.PERIODO, or cluster(id)
// Categoria di riferimento per LIVELLO_ISTRUZ: Laurea (LIVELLO_ISTRUZ = 2)
// Categoria di riferimento per PERIODO: 1-2 anni (PERIODO = 1)
// Termini di interazione significativi per PERIODO = 5 (20-25 anni)

testparm i.LIVELLO_ISTRUZ#i.PERIODO // Assunzione di proporzionalità non valida

**********************************************************************

* Per il momento, viene assunta l'ipotesi di proporzionalità di LIVELLO_ISTRUZ nel tempo:

* Solo LIVELLO_ISTRUZ (Categoria di riferimento: Laurea):
logit EVENTO ib2.LIVELLO_ISTRUZ ib1.PERIODO, or cluster(id)

* + COORTE (Categoria di riferimento: Dal 2001 in poi):
logit EVENTO ib2.LIVELLO_ISTRUZ ib4.COORTE ib1.PERIODO, or cluster(id)

* + SESSO (Categoria di riferimento: Femmina):
logit EVENTO ib2.LIVELLO_ISTRUZ ib4.COORTE ib1.SESSO ib1.PERIODO, or cluster(id)

* + PRIMA_UNIONE (Categoria di riferimento: Matrimonio):
logit EVENTO ib2.LIVELLO_ISTRUZ ib4.COORTE ib1.SESSO ib1.PRIMA_UNIONE ib1.PERIODO, or cluster(id)

* + RIP (Categoria di riferimento: Nord-Centro):
logit EVENTO ib2.LIVELLO_ISTRUZ ib4.COORTE ib1.SESSO ib1.PRIMA_UNIONE i.RIP ib1.PERIODO, or cluster(id)

* + PRIMO_LAVORO (Categoria di riferimento: Ha iniziato a lavorare)
logit EVENTO ib2.LIVELLO_ISTRUZ ib4.COORTE ib1.SESSO ib1.PRIMA_UNIONE i.RIP ib1.PRIMO_LAVORO ib1.PERIODO, or cluster(id)

* + GEN_ISTRUZ (Categoria di riferimento: Laurea)
logit EVENTO ib2.LIVELLO_ISTRUZ ib4.COORTE ib1.SESSO ib1.PRIMA_UNIONE i.RIP ib1.PRIMO_LAVORO ib2.GEN_ISTRUZ ib1.PERIODO, or cluster(id) 
* La differenza tra individui laureati e coloro con licenza media o inferiore non risulta più significativa. Questo suggerisce che l'associazione osservata in precedenza potrebbe essere spiegata, in parte, dall'istruzione dei genitori.

**********************************************************************

* Confronto tra differenti specificazioni baseline:

logit EVENTO ib2.LIVELLO_ISTRUZ ib4.COORTE ib1.SESSO ib1.PRIMA_UNIONE i.RIP ib1.PRIMO_LAVORO ib2.GEN_ISTRUZ i.ANNO, or cluster(id)
estimates store MODELLO_1

logit EVENTO ib2.LIVELLO_ISTRUZ ib4.COORTE ib1.SESSO ib1.PRIMA_UNIONE i.RIP ib1.PRIMO_LAVORO ib2.GEN_ISTRUZ i.PERIODO, or cluster(id)
estimates store MODELLO_2

logit EVENTO ib2.LIVELLO_ISTRUZ ib4.COORTE ib1.SESSO ib1.PRIMA_UNIONE i.RIP ib1.PRIMO_LAVORO ib2.GEN_ISTRUZ c.ANNO, or cluster(id)
estimates store MODELLO_3

logit EVENTO ib2.LIVELLO_ISTRUZ ib4.COORTE ib1.SESSO ib1.PRIMA_UNIONE i.RIP ib1.PRIMO_LAVORO ib2.GEN_ISTRUZ c.ANNO##c.ANNO, or cluster(id)
estimates store MODELLO_4

logit EVENTO ib2.LIVELLO_ISTRUZ ib4.COORTE ib1.SESSO ib1.PRIMA_UNIONE i.RIP ib1.PRIMO_LAVORO ib2.GEN_ISTRUZ c.ANNO##c.ANNO##c.ANNO, or cluster(id)
estimates store MODELLO_5

est tab MODELLO_1 MODELLO_2 MODELLO_3 MODELLO_4 MODELLO_5, b(%4.2f) keep(ib2.LIVELLO_ISTRUZ)

estimates stats MODELLO_1 MODELLO_2 MODELLO_3 MODELLO_4 MODELLO_5
// Criterio BIC: Modello_2 è il migliore

**********************************************************************

logit EVENTO ib2.LIVELLO_ISTRUZ##i.PERIODO ib4.COORTE ib1.SESSO ib1.PRIMA_UNIONE i.RIP ib1.PRIMO_LAVORO ib2.GEN_ISTRUZ, or cluster(id) 
* Effetti di interazione non più significativi

testparm i.LIVELLO_ISTRUZ#i.PERIODO
* Non c'è evidenza di non proporzionalità per l'effetto di LIVELLO_ISTRUZ nel tempo -> assunzione di proporzionalità valida

**********************************************************************

* Per valutare come il gradiente d'istruzione varia tra le diverse coorti, è stato stimato un modello logit con interazione tra LIVELLO_ISTRUZ e COORTE, controllando per sesso, tipologia dell'unione, ripartizione geografica e ingresso nel mercato del lavoro:
logit EVENTO ib2.LIVELLO_ISTRUZ##ib4.COORTE ib1.SESSO ib1.PRIMA_UNIONE i.RIP ib1.PRIMO_LAVORO ib1.PERIODO, or cluster(id)
estimates store Modello_noGENISTRUZ
quietly margins COORTE#LIVELLO_ISTRUZ, at(PERIODO=(1(1)6)) ///
   saving(PROB_STIMATE_noGEN_ISTRUZ, replace)
   
 * Con istruzione dei genitori:
logit EVENTO ib2.LIVELLO_ISTRUZ##ib4.COORTE ib1.SESSO ib1.PRIMA_UNIONE i.RIP ib1.PRIMO_LAVORO ib2.GEN_ISTRUZ ib1.PERIODO, or cluster(id)
estimates store Modello_Aggregato
quietly margins COORTE#LIVELLO_ISTRUZ, at(PERIODO=(1(1)6)) ///
   saving(PROB_STIMATE, replace)
   
logit EVENTO ib2.LIVELLO_ISTRUZ#ib4.COORTE ib1.SESSO ib1.PRIMA_UNIONE i.RIP ib1.PRIMO_LAVORO ib2.GEN_ISTRUZ ib1.PERIODO, or cluster(id)

* Modello per gli uomini:
logit EVENTO ib2.LIVELLO_ISTRUZ##ib4.COORTE ib1.PRIMA_UNIONE i.RIP ib1.PRIMO_LAVORO ib2.GEN_ISTRUZ ib1.PERIODO if SESSO == 0, or cluster(id)
estimates store MODELLO_Uomini
quietly margins COORTE#LIVELLO_ISTRUZ, at(PERIODO=(1(1)6)) ///
   saving(PROB_STIMATE_Uomini, replace)
 
* Modello per le donne:
logit EVENTO ib2.LIVELLO_ISTRUZ##ib4.COORTE ib1.PRIMA_UNIONE i.RIP ib1.PRIMO_LAVORO ib2.GEN_ISTRUZ ib1.PERIODO if SESSO == 1, or cluster(id)
estimates store MODELLO_Donne
quietly margins COORTE#LIVELLO_ISTRUZ, at(PERIODO=(1(1)6)) ///
   saving(PROB_STIMATE_Donne, replace) 
 
* Modello per le convivenze:
logit EVENTO ib2.LIVELLO_ISTRUZ##ib4.COORTE ib1.SESSO i.RIP ib1.PRIMO_LAVORO ib2.GEN_ISTRUZ ib1.PERIODO if PRIMA_UNIONE == 0, or cluster(id)
estimates store MODELLO_Convivenze
quietly margins COORTE#LIVELLO_ISTRUZ, at(PERIODO=(1(1)6)) ///
   saving(PROB_STIMATE_Convivenze, replace)
   
* Modello per le convivenze:
logit EVENTO ib2.LIVELLO_ISTRUZ##ib4.COORTE ib1.SESSO i.RIP ib1.PRIMO_LAVORO ib2.GEN_ISTRUZ ib1.PERIODO if PRIMA_UNIONE == 1, or cluster(id)
estimates store MODELLO_Matrimoni
quietly margins COORTE#LIVELLO_ISTRUZ, at(PERIODO=(1(1)6)) ///
   saving(PROB_STIMATE_Matrimoni, replace)
 
**********************************************************************

preserve 

use PROB_STIMATE, clear

rename _at8 PERIODO
rename _m1 COORTE
rename _m2 LIVELLO_ISTRUZ
rename _margin HAZARD
	
twoway ///
    (line HAZARD PERIODO if LIVELLO_ISTRUZ == 0) ///
    (line HAZARD PERIODO if LIVELLO_ISTRUZ == 1) ///
    (line HAZARD PERIODO if LIVELLO_ISTRUZ == 2), ///
    by(COORTE, cols(2) note("") legend(pos(6))) ///
    legend(order(1 "Licenza media o inferiore" ///
                 2 "Diploma" ///
                 3 "Laurea") ///
           position(12) ring(0) rows(1) ///
		   size(small) region(lstyle(dashed))) ///
    xtitle("Durata della prima unione", size(small)) ///
    xlabel(1 "1-2 anni" 2 "3-7 anni" 3 "8-15 anni" ///
           4 "16-19 anni" 5 "20-25 anni" 6 ">25 anni", ///
           labsize(vsmall)) ///
    ytitle("Probabilità di rottura dell'unione", size(small)) ///
    ylabel(, labsize(vsmall)) ///
	name(prob_rottura, replace) nodraw

sort COORTE LIVELLO_ISTRUZ PERIODO
by COORTE LIVELLO_ISTRUZ: gen PROB_SOPRAV = 1 - HAZARD if _n == 1
by COORTE LIVELLO_ISTRUZ: replace PROB_SOPRAV = PROB_SOPRAV[_n-1] * (1 - HAZARD) if _n > 1

twoway ///
    (line PROB_SOPRAV PERIODO if LIVELLO_ISTRUZ == 0) ///
    (line PROB_SOPRAV PERIODO if LIVELLO_ISTRUZ == 1) ///
    (line PROB_SOPRAV PERIODO if LIVELLO_ISTRUZ == 2), ///
    by(COORTE, cols(2) note("") legend(pos(6))) ///
    legend(order(1 "Licenza media o inferiore" ///
                 2 "Diploma" ///
                 3 "Laurea") ///
           position(12) ring(0) rows(1) ///
		   size(small) region(lstyle(dashed))) ///
    xtitle("Durata della prima unione", size(small)) ///
    xlabel(1 "1-2 anni" 2 "3-7 anni" 3 "8-15 anni" ///
           4 "16-19 anni" 5 "20-25 anni" 6 ">25 anni", ///
           labsize(vsmall)) ///
    ytitle("Probabilità di sopravvivenza dell'unione", size(small)) ///
    ylabel(, labsize(vsmall)) ///
	name(funz_sopravvivenza, replace) nodraw
	
restore 

graph display funz_sopravvivenza

**********************************************************************

preserve 

use PROB_STIMATE_Uomini, clear
rename _at7 PERIODO
rename _m1 COORTE
rename _m2 LIVELLO_ISTRUZ
rename _margin HAZARD
	
twoway ///
    (line HAZARD PERIODO if LIVELLO_ISTRUZ == 0) ///
    (line HAZARD PERIODO if LIVELLO_ISTRUZ == 1) ///
    (line HAZARD PERIODO if LIVELLO_ISTRUZ == 2), ///
    by(COORTE, cols(2) note("") legend(pos(6))) ///
    legend(order(1 "Licenza media o inferiore" ///
                 2 "Diploma" ///
                 3 "Laurea") ///
           position(12) ring(0) rows(1) ///
		   size(small) region(lstyle(dashed))) ///
    xtitle("Durata della prima unione", size(small)) ///
    xlabel(1 "1-2 anni" 2 "3-7 anni" 3 "8-15 anni" ///
           4 "16-19 anni" 5 "20-25 anni" 6 ">25 anni", ///
           labsize(vsmall)) ///
    ytitle("Probabilità di rottura dell'unione", size(small)) ///
    ylabel(, labsize(vsmall)) ///
	name(prob_rottura_uomini, replace) nodraw

sort COORTE LIVELLO_ISTRUZ PERIODO
by COORTE LIVELLO_ISTRUZ: gen PROB_SOPRAV = 1 - HAZARD if _n == 1
by COORTE LIVELLO_ISTRUZ: replace PROB_SOPRAV = PROB_SOPRAV[_n-1] * (1 - HAZARD) if _n > 1

twoway ///
    (line PROB_SOPRAV PERIODO if LIVELLO_ISTRUZ == 0) ///
    (line PROB_SOPRAV PERIODO if LIVELLO_ISTRUZ == 1) ///
    (line PROB_SOPRAV PERIODO if LIVELLO_ISTRUZ == 2), ///
    by(COORTE, cols(2) note("") legend(pos(6))) ///
    legend(order(1 "Licenza media o inferiore" ///
                 2 "Diploma" ///
                 3 "Laurea") ///
           position(12) ring(0) rows(1) ///
		   size(small) region(lstyle(dashed))) ///
    xtitle("Durata della prima unione", size(small)) ///
    xlabel(1 "1-2 anni" 2 "3-7 anni" 3 "8-15 anni" ///
           4 "16-19 anni" 5 "20-25 anni" 6 ">25 anni", ///
           labsize(vsmall)) ///
    ytitle("Probabilità di sopravvivenza dell'unione", size(small)) ///
    ylabel(, labsize(vsmall)) ///
	name(funz_sopravvivenza_uomini, replace) nodraw
	
restore 

graph display funz_sopravvivenza_uomini

**********************************************************************

preserve 

use PROB_STIMATE_Donne, clear
rename _at7 PERIODO
rename _m1 COORTE
rename _m2 LIVELLO_ISTRUZ
rename _margin HAZARD
	
twoway ///
    (line HAZARD PERIODO if LIVELLO_ISTRUZ == 0) ///
    (line HAZARD PERIODO if LIVELLO_ISTRUZ == 1) ///
    (line HAZARD PERIODO if LIVELLO_ISTRUZ == 2), ///
    by(COORTE, cols(2) note("") legend(pos(6))) ///
    legend(order(1 "Licenza media o inferiore" ///
                 2 "Diploma" ///
                 3 "Laurea") ///
           position(12) ring(0) rows(1) ///
		   size(small) region(lstyle(dashed))) ///
    xtitle("Durata della prima unione", size(small)) ///
    xlabel(1 "1-2 anni" 2 "3-7 anni" 3 "8-15 anni" ///
           4 "16-19 anni" 5 "20-25 anni" 6 ">25 anni", ///
           labsize(vsmall)) ///
    ytitle("Probabilità di rottura dell'unione", size(small)) ///
    ylabel(, labsize(vsmall)) ///
	name(prob_rottura_donne, replace) nodraw

sort COORTE LIVELLO_ISTRUZ PERIODO
by COORTE LIVELLO_ISTRUZ: gen PROB_SOPRAV = 1 - HAZARD if _n == 1
by COORTE LIVELLO_ISTRUZ: replace PROB_SOPRAV = PROB_SOPRAV[_n-1] * (1 - HAZARD) if _n > 1

twoway ///
    (line PROB_SOPRAV PERIODO if LIVELLO_ISTRUZ == 0) ///
    (line PROB_SOPRAV PERIODO if LIVELLO_ISTRUZ == 1) ///
    (line PROB_SOPRAV PERIODO if LIVELLO_ISTRUZ == 2), ///
    by(COORTE, cols(2) note("") legend(pos(6))) ///
    legend(order(1 "Licenza media o inferiore" ///
                 2 "Diploma" ///
                 3 "Laurea") ///
           position(12) ring(0) rows(1) ///
		   size(small) region(lstyle(dashed))) ///
    xtitle("Durata della prima unione", size(small)) ///
    xlabel(1 "1-2 anni" 2 "3-7 anni" 3 "8-15 anni" ///
           4 "16-19 anni" 5 "20-25 anni" 6 ">25 anni", ///
           labsize(vsmall)) ///
    ytitle("Probabilità di sopravvivenza dell'unione", size(small)) ///
    ylabel(, labsize(vsmall)) ///
	name(funz_sopravvivenza_donne, replace) nodraw
	
restore 

graph display funz_sopravvivenza_donne

**********************************************************************

preserve 

use PROB_STIMATE_Convivenze, clear
rename _at7 PERIODO
rename _m1 COORTE
rename _m2 LIVELLO_ISTRUZ
rename _margin HAZARD
	
twoway ///
    (line HAZARD PERIODO if LIVELLO_ISTRUZ == 0) ///
    (line HAZARD PERIODO if LIVELLO_ISTRUZ == 1) ///
    (line HAZARD PERIODO if LIVELLO_ISTRUZ == 2), ///
    by(COORTE, cols(2) note("") legend(pos(6))) ///
    legend(order(1 "Licenza media o inferiore" ///
                 2 "Diploma" ///
                 3 "Laurea") ///
           position(12) ring(0) rows(1) ///
		   size(small) region(lstyle(dashed))) ///
    xtitle("Durata della prima unione", size(small)) ///
    xlabel(1 "1-2 anni" 2 "3-7 anni" 3 "8-15 anni" ///
           4 "16-19 anni" 5 "20-25 anni" 6 ">25 anni", ///
           labsize(vsmall)) ///
    ytitle("Probabilità di rottura dell'unione", size(small)) ///
    ylabel(, labsize(vsmall)) ///
	name(prob_rottura_convivenze, replace) nodraw

sort COORTE LIVELLO_ISTRUZ PERIODO
by COORTE LIVELLO_ISTRUZ: gen PROB_SOPRAV = 1 - HAZARD if _n == 1
by COORTE LIVELLO_ISTRUZ: replace PROB_SOPRAV = PROB_SOPRAV[_n-1] * (1 - HAZARD) if _n > 1

twoway ///
    (line PROB_SOPRAV PERIODO if LIVELLO_ISTRUZ == 0) ///
    (line PROB_SOPRAV PERIODO if LIVELLO_ISTRUZ == 1) ///
    (line PROB_SOPRAV PERIODO if LIVELLO_ISTRUZ == 2), ///
    by(COORTE, cols(2) note("") legend(pos(6))) ///
    legend(order(1 "Licenza media o inferiore" ///
                 2 "Diploma" ///
                 3 "Laurea") ///
           position(12) ring(0) rows(1) ///
		   size(small) region(lstyle(dashed))) ///
    xtitle("Durata della prima unione", size(small)) ///
    xlabel(1 "1-2 anni" 2 "3-7 anni" 3 "8-15 anni" ///
           4 "16-19 anni" 5 "20-25 anni" 6 ">25 anni", ///
           labsize(vsmall)) ///
    ytitle("Probabilità di sopravvivenza dell'unione", size(small)) ///
    ylabel(, labsize(vsmall)) ///
	name(funz_sopravvivenza_convivenze, replace) nodraw
	
restore 

graph display funz_sopravvivenza_convivenze

**********************************************************************

preserve 

use PROB_STIMATE_Matrimoni, clear
rename _at7 PERIODO
rename _m1 COORTE
rename _m2 LIVELLO_ISTRUZ
rename _margin HAZARD
	
twoway ///
    (line HAZARD PERIODO if LIVELLO_ISTRUZ == 0) ///
    (line HAZARD PERIODO if LIVELLO_ISTRUZ == 1) ///
    (line HAZARD PERIODO if LIVELLO_ISTRUZ == 2), ///
    by(COORTE, cols(2) note("") legend(pos(6))) ///
    legend(order(1 "Licenza media o inferiore" ///
                 2 "Diploma" ///
                 3 "Laurea") ///
           position(12) ring(0) rows(1) ///
		   size(small) region(lstyle(dashed))) ///
    xtitle("Durata della prima unione", size(small)) ///
    xlabel(1 "1-2 anni" 2 "3-7 anni" 3 "8-15 anni" ///
           4 "16-19 anni" 5 "20-25 anni" 6 ">25 anni", ///
           labsize(vsmall)) ///
    ytitle("Probabilità di rottura dell'unione", size(small)) ///
    ylabel(, labsize(vsmall)) ///
	name(prob_rottura_matrimoni, replace) nodraw

sort COORTE LIVELLO_ISTRUZ PERIODO
by COORTE LIVELLO_ISTRUZ: gen PROB_SOPRAV = 1 - HAZARD if _n == 1
by COORTE LIVELLO_ISTRUZ: replace PROB_SOPRAV = PROB_SOPRAV[_n-1] * (1 - HAZARD) if _n > 1

twoway ///
    (line PROB_SOPRAV PERIODO if LIVELLO_ISTRUZ == 0) ///
    (line PROB_SOPRAV PERIODO if LIVELLO_ISTRUZ == 1) ///
    (line PROB_SOPRAV PERIODO if LIVELLO_ISTRUZ == 2), ///
    by(COORTE, cols(2) note("") legend(pos(6))) ///
    legend(order(1 "Licenza media o inferiore" ///
                 2 "Diploma" ///
                 3 "Laurea") ///
           position(12) ring(0) rows(1) ///
		   size(small) region(lstyle(dashed))) ///
    xtitle("Durata della prima unione", size(small)) ///
    xlabel(1 "1-2 anni" 2 "3-7 anni" 3 "8-15 anni" ///
           4 "16-19 anni" 5 "20-25 anni" 6 ">25 anni", ///
           labsize(vsmall)) ///
    ytitle("Probabilità di sopravvivenza dell'unione", size(small)) ///
    ylabel(, labsize(vsmall)) ///
	name(funz_sopravvivenza_matrimoni, replace) nodraw
	
restore 

graph display funz_sopravvivenza_matrimoni

**********************************************************************

