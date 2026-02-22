# educational-gradient-divorce-italy
Progetto per corso universitario 2025. Analisi empirica dell'evoluzione del gradiente d'istruzione nel rischio di rottura della prima unione in Italia. Studio basato su modelli logit a tempo discreto (Event History Analysis) utilizzando i dati dell'indagine ISTAT "Famiglie e Soggetti Sociali" (FSS 2016).

# Istruzione e divorzio: stabilità o cambiamento?

Questo progetto analizza la relazione tra il livello di istruzione e il rischio di rottura della prima unione (matrimonio o convivenza) in Italia. Attraverso un approccio di **Event History Analysis (EHA) a tempo discreto**, lo studio mira a ricostruire l'evoluzione del "gradiente d'istruzione", verificando se le coorti più giovani stiano seguendo i pattern di inversione osservati in altri paesi occidentali.

## 📌 Obiettivi dello studio
* Analizzare se il gradiente d'istruzione alla separazione è rimasto stabile o si è invertito nelle coorti più recenti.
* Valutare le differenze di genere (effetto reddito vs effetto indipendenza).
* Esaminare l'impatto della tipologia di unione (convivenza vs matrimonio) sulla stabilità del legame.

## 📊 Metodologia e Dati
* **Dataset:** Indagine ISTAT *Famiglie e Soggetti Sociali (FSS) 2016*.
* **Campione analitico:** 17.786 individui (96,74% della popolazione a rischio).
* **Modello Statistico:** Modello Logit a tempo discreto con specificazione *piecewise* della baseline temporale.
* **Variabile Time-Varying:** Il livello di istruzione è trattato come dinamico per evitare problemi di causalità inversa.

## 📈 Risultati Principali
1. **Inversione del Gradiente:** Nelle coorti meno recenti (fino al 1980) il gradiente è positivo (chi è più istruito rischia di più). Nelle coorti nate dal 2001, emerge una tendenza all'inversione: i laureati mostrano una stabilità superiore rispetto a chi ha solo la licenza media.
2. **Effetto Background:** L'istruzione dei genitori spiega gran parte della relazione iniziale; controllando per il background familiare, l'effetto dell'istruzione individuale si riduce.
3. **Differenze di Genere:** Gli uomini mostrano segnali di inversione del gradiente già dalla coorte 1981-1990, mentre per le donne il cambiamento è evidente solo nella generazione più recente.
4. **Convivenze vs Matrimoni:** Le convivenze presentano un rischio di rottura significativamente più alto (OR ≈ 11.14) rispetto ai matrimoni, indipendentemente dal titolo di studio.

## 📂 Struttura della Repository
* `/data`: (Nota: i dati grezzi ISTAT FSS non sono inclusi per motivi di licenza).
* `/scripts`: Contiene lo script Stata (`.do`) per la pulizia dei dati, la costruzione delle variabili e la stima dei modelli.
* `/report`: Report finale in formato Docx.
* `/presentation`: Slide della presentazione dei risultati.

## 🛠 Requisiti software
* **Stata** (versione 14 o superiore consigliata per l'esecuzione del codice `.do`).

## 👥 Autori
* **Luca Solito** - Corso di laurea in Statistica e Data Science 
* **Lapo Bettarini** - Corso di laurea in Statistica e Data Science 
