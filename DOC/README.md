
XOPT v.1.2.0
Airfoil Optimization Tool  

Supervisori :	Prof. Umberto Iemma 	
		Dott. Ing. Lorenzo Burghignoli
		Dott. Ing. Francesco Centracchio

Autore	: 	Simone Saracino, studente laureando 

Facoltà: Ingegneria 
Dipartimento: Ingegneria Meccanica e Industriale
Università: ROMA TRE

{book version = first draft (7.2014), revision ? , 
latex-source-code = - ,
doxygen doc = - ,
language = italiano}

----------------------------------------------------------------------------------------------------------------------------
# SOMMARIO
L'economia delle risorse di calcolo e la necessità di ottimizzare le velocità di esecuzione dei processi di analisi rappresentano requisiti indispensabili di un progetto in aeronautica così come in altri contesti simili nell'industria: la velocità di ricerca e di selezione di configurazioni idonee al problema si traduce in un
 
		- rapido avanzamento del progetto ;
		- guadagno di risorse che potranno essere redistribuite efficacemente
		  nella fase di definizione e di dettaglio del modello ;

In questo contesto certamente le strategie evolutive mostrano ottime potenzialità rispetto alle tecniche tradizionali , soprattutto stupisce la capacità di affrontare e di risolvere problemi complessi (..)

	(Algoritmi Genetici, breve discussione)
 
#XOPT-Descrizione SINTETICA - Struttura & Funzionamento
Il programma 'XOPT' (nella versione v.1.2014.Octave) utilizza un algoritmo genetico semplice per massimizzare l'efficienza aerodinamica di un profilo alare subsonico. 

Il file 'XOPT.m' , compilato dall'utente, comunica ad XOPT i parametri
necessari alla configurazione dell'algoritmo di calcolo :
	
	Struttura 
	
	Set-up --> 'XOPT.m'
		- configurazione iniziale del profilo ;
		- condizioni al contorno ;
		- parametri di configurazione dell'algoritmo genetico ;
	
	Processing --> 'genetic.m' (ulteriori dettagli nella sezione : "Controllo funzioni e variabili")
		- Codifica binaria delle informazioni contenute nel cromosoma dell'individuo 			'encode.m','b10to2.m','bin2Gray';
		- Generazione randomica di una nuova generazione di profili 
		- Decodifica --> 'decode.m'
		- Calcolo fitness --> 'Run.m'
					- generazione della geometria dell'individuo decodificato --> 'CST_2D_airfoil.m' ;
					- analisi del profilo --> 'XFoil.m' --> fitness (1*);
		- Verifica della variabile d'arresto del genetico ;

	Post-Processing --> 'battle.m' 

(1*): L'algoritmo genetico minimizza la funzione di fitness ottenuta come combinazione dell'inverso della funzione obiettivo
(l'efficienza aerodinamica) e di funzioni di penalità 'Fp(i)' (moltiplicate per i rispettivi coefficienti p(i)).

	Nota

	1- Le funzioni di penalità si attivano automaticamente ad ogni violazione della condizione i-esima ;

	2- La versione attuale del programma gestisce funzioni di penalità costanti , la possibilità d'inserire funzioni di 		penalità arbitrarie sarà disponibile nella prossima versione.
	L'utente potrà comunque intervenire modificando i valori di Fp(i) e di p(i) attraverso lo script 'Run.m' SENZA 		ALTERARE il NUMERO di funzioni (e/o il numero di coeff. p) : tutte le funzioni di penalità definite dall'utente , 		sebbene siano comunicate ad 'XFoil.m'(in cui viene 'costruita' la funzione di fitness sulla base dei dati di output 		di XFOIL), non possono essere utilizzate, in tal caso l'utente è costretto a modificare 'XFoil.m'.

	3- I coeff. di penalità dipendono dal problema, si riportano pertanto  
	
		- si effettui una campagna di test utilizzando le impostazioni di default ;
		- si analizzino i valori di fitness contenuti nei file 'Gen*.dat' ;
		(- si valuti l'evoluzione del diagramma di convergenza dei test ;)
		-  si modifichino i valori di p ( si può intervenire direttamente anche sui valori di Fp) ;

	Schema 
		fObj = E = Cl/Cd --> max    ==   fObj^(-1) = E^(-1) = Cd/Cl --> min ;
		fitness = Cd/Cl + p(i)*Fp(i) ;   

	Legenda
	
	fObj : funzione obiettivo ; 
	E : efficienza aerodinamica del profilo alare;
	Cl : coeff. di portanza ... ;
	Cd : coeff. di resistenza ... ;
	Fp(i) : funzione di penalità i-esima ;
		-Fp(1) = penalizza i profili con spessore superiore ad un valore prefissato (Tkmax) ;
		-Fp(2) = penalizza i profili aerodinamicamente e/o geometricamente non validi ;
		-Fp(3) = penalizza i profili che non raggiungono la convergenza nel massimo numero di iterazioni
			in XFOIL ; (2*)
		-Fp(4) = penalizzano i profili con fitness negativa ; (3*)	

	p(i) : coeff. di penalità i-esima ;  

(2*): La routine di analisi viscosa di XFOIL risolve un sistema di equazioni algebriche non lineari utilizzando un metodo iterativo full-Newton ed è possibile che l'algoritmo iterativo non raggiunga la convergenza nel numero prefissato d'iterazioni.
L'utente può dunque intervenire e modificare il parametro 'max_iter_xfoil' nel file di configurazione; si consiglia di non utilizzare valori troppo grandi (il valore di default è 50) che potrebbero compromettere la velocità di esecuzione e richiedere un impiego notevole di risorse computazionali.

(3*): la funzione di fitness non può assumere valori negativi (..)

#	Sistema Operativo 
		Lubuntu	12.04
		Supporto valido per sistemi Unix
#	Software utilizzati 
	-	Octave v. 3.6.2 --> 3.8.1 (! warning) : definizione variabili, esecuzione subroutines, gestione output, 		visualizzazione dati ; 
	-	XFOIL v. 6.97 : analisi dei profili alari ;
	-	Gnuplot 4.6 patchlevel 0 --> patchlevel 4 (! warning) 
		[La visualizzazione interna dei dati è in aggiornamento
		Si utilizzi lo script 'plot.sh' in '../SourceCode']

#	Competenze minime
	-	gestione elementare della shell di bash
	-	esecuzione di Octave 

#	Esecuzione
1-	Accedi al file di configurazione 'XOPT.m'
2-	Inizializza le variabili (! Leggi attentamente le definizioni)
3-	Entra in Octave da shell
4-	Esegui XOPT
	
	-	Leggi la nota a riga 207 in 'XOPT.m' : in questo caso per avviare il programma è sufficiente premere 			'invio' fino al raggiungimento del warning.
		Visualizzato il warning si preme ancora 'invio' e il programma entra in esecuzione (! in presenza di altri 			messaggi di warning si ripete la suddetta procedura) ;
	-	per eventuali problemi di accesso ai file (es. ' sh: 1: ./SourceCode/mvData.sh: Permission denied ') è
		necessario eseguire il codice da super utente, puoi controllare e modificare i permessi in alternativa;
	- 	accertarti che gli script di bash (*.sh) siano eseguibili :
		digita 'ls -l ~/.../XOPT/SourceCode/ | grep .sh' e controlla la presenza della lettera 'x' nelle stringhe 			come da esempio : -rwxr-xr-x ...nomeScript.sh; in caso contrario da 'root' digita 'chmod +x nomeScript.sh'
		eventualmente specificando il percorso del file (es. 'chmod +x ~/.../XOPT/SourceCode/nomeScript.sh'). 

# Controllo funzioni e variabili
Entra nella cartella '~/.../XOPT/SourceCode' 
     1-	In 'goptions.m' è possibile controllare  le definizioni dei parametri che governano l'algoritmo genetico.
     2-	In 'genetic.m' è possibile controllare la struttura dell'algoritmo : 
	      -	lettura dei dati d'ingresso ; 
	      -	esecuzione del ciclo di ottimizzazione ;
		      -	generazione randomica di una  popolazione binaria di individui (! il genetico opera sulle 				informazioni contenute nel genotipo di ciascun individuo) ;
		      -	decodifica : genotipo (variabili binarie) --> fenotipo(variabili reali)
		      -	valutazione della fitness --> 'Run.m'
			      -	generazione del profilo --> 'CST_2D_airfoil.m': generazione di un profilo alare
				specificando  , nelle variabili di configurazione del profilo, le coordinate di punti 					appartenenti all'intradosso e all'estradosso ( è stata sviluppata e validata una seconda 					variante del 'CST' in grado di generare un profilo assegnando una distribuzione di spessori 					e specificando le coordinate di punti della linea media ).
			      -	analisi del profilo --> 'XFoil.m'
			      -	calcolo della fitness 
		      - valutazione  del parametro che  arresta l'algoritmo : le modalità d'arresto sono specificate nel 				preambolo dello script 'genetic.m' e si può selezionare ed impostare in 'goptions.m' ).
	      -	valutazione della configurazione ottima
	      -	visualizzazione statistiche e risultati : l'attuale versione di 'XOPT' consente la visualizzazione dei 			coefficienti di pressione Cp attraverso l'impiego dello script 'plot.sh' che l'utente potrà richiamare da 			linea di comando. 
		
# Output
XOPT mostra i risultati e le statistiche del processo e genera cartelle di dati che possono essere analizzati dall'utente
per uno studio più dettagliato.
L'automatizzazione nella gestione dei risultati , la visualizzazione delle distribuzioni di pressione , la rappresentazione dei diagrammi polari e l'analisi di convergenza dell'algoritmo saranno disponibili nella versione aggiornata.
['battle.m' è una bozza recente del lavoro]

# Osservazioni

# 'plot.sh' --> '~/.../XOPT/SourceCode/plot.sh'
# Warning : si segnala un problema nella generazione di file di dati e immagini utilizzando la VERSIONE 4.6 PATCHLEVEL 4 di Gnuplot; 
# Descrizione : 'plot.sh' permette di visualizzare e confrontare le distribuzioni di pressione di 2 profili a confronto
# Regola di chiamata : ~/.../XOPT/SourceCode/plot.sh $1 $2 $3 $4 $5 $6 $7
# Input
$1 : plot_flag ( 0 = no file immagine , 1 = file immagine --> "$gen1°$k1°$gen2°$k2°.pdf" ) ;
$2 : numero generazione 1° profilo ;
$3 : numero individuo  ... ;
$4 : valore minimo di Cp riportato sull'asse omonimo ;
$5 : valore massimo ... ;
$6 : numero generazione profilo ottimo ; (! dalle statistiche mostrate a schermo a fine processo si ricava la generazione di 						    appartenenza del profilo ottimo, dal valore fbest si ricava il numero 						    dell'individuo migliore )
$7 : numero individuo ... ;

# 'TestData.sh' --> '~/.../XOPT/SourceCode/TestData.sh'
# Descrizione : 'TestData.sh' permette di creare una cartella di dati TEST$1 in cui vengono copiati tutti i dati prodotti durante l'esecuzione del processo.
# La cartella TEST$1 viene protetta da scrittura ( riga 15 in TestData.sh: chmod -r ./TEST$1 ) in questo modo è possibile evitare una cancellazione erronea dei dati (! controllare i permessi dei file, eventualmente eseguire da root)
# Regola di chiamata : ~/.../XOPT/SourceCode/TestData.sh $1
# Input
$1 : nome/data del Test 

# 'cleaner.sh' --> '~/.../XOPT/SourceCode/cleaner.sh'
# Descrizione : 'cleaner.sh' permette di eliminare i dati prodotti da XOPT (! controllare i permessi dei file, eventualmente eseguire da root) 
# Regola di chiamata : ~/.../XOPT/SourceCode/cleaner.sh

# Conclusioni-proposte
L'applicazione delle strategie evolutive nella progettazione di profili alari ha evidenziato la capacità degli algoritmi genetici nel risolvere problemi di natura complessa.
Tuttavia, l'assenza di un criterio generale che possa consentire al progettista di selezionare i parametri e gli operatori più adatti al problema , rappresenta un ostacolo.
Di fatto l'algoritmo deve essere costruito ad-hoc e ciò significa effettuare test, raccogliere confrontare ed analizzare i dati ottenuti, individuare i parametri 'dominanti' che dirigono l'evoluzione del processo di calcolo. 
L'impiego degli algoritmi genetici , nel campo aeronautico, come valido strumento di supporto , nella fase di valutazione delle caratteristiche di un modello e di selezione dello stesso, non possa prescindere dalla necessità di realizzare un supporto 'intelligente' nelle operazioni di set-up del codice a vantaggio di una maggiore 'portabilità' e di una maggiore efficienza.
Una maggiore portabilità fornirebbe flessibilità e capacità di adattamento del codice ad una classe più grande di applicazioni e non solo ad uno specifico problema.
D'altra parte la semplificazione e contemporaneamente, l'automatizzazione della procedura di configurazione , garantirebbero una maggiore efficienza.
Si deve riformulare il problema di partenza nel nuovo : identificare la migliore configurazione dell'algoritmo utilizzando le strategie evolutive.
Si tratta di un problema di 'Programmazione Genetica' in cui l'obiettivo è quello di  adattare le idee di base degli algoritmi genetici all'evoluzione della struttura del codice schematizzato come una sequenza di 'blocchi' variabili (gli operatori genetici, le variabili,...) ... 
Per ulteriori informazioni si rimanda al sito 'http://www.genetic-programming.org/'.

# Aggiornamenti in corso
1) Analisi di convergenza.
2) Subroutine per interpolare ed ottimizzare un profilo esistente definito per punti :
	-	il programma legge le coordinate 
	-	si stabiliscono 'n'  punti da interpolare
	-	si interpola utilizzando un polinomio di ordine m = n-1
	-	si risolve un sistema lineare algebrico di ordine n
	-	si ricavano i coeff. di scala (indicate con w) delle n componenti di forma (componenti del polinomio di Bernstein di ordine m  
	-	si costruisce il vettore di configurazione del profilo interpolato
	-	si esegue il genetico
3) Miglioramento nella visualizzazione dei dati (..)
4) A.M.V : Airfoil Morphing Visualisation --> visualizzazione in tempo reale della trasformazione del profilo durante l'esecuzione 
del genetico.

# Evoluzione --> XOPT v.2

	(-) compatibilità con Matlab ;
	 -  nuovi operatori genetici ;
	 -  modalità di ricerca IBRIDA ;
	 -  implementazione di un modello B.E.M 3D ; 
	 -  ottimizzazione di superfici alari 3D 

 # Riferimenti Bibliografici 
1) Kulfan, B. M., Bussoletti, J. E. Fundamental Parametric Geometry Representations for Aircraft Component Shapes :
'http://www.smtp.brendakulfan.com/docs/CST1.pdf' ;
2) Mark Drela, Harold Youngren . Documentazione XFoil -XFOIL 6.9 User Primer :
'http://web.mit.edu/drela/Public/web/xfoil/xfoil_doc.txt' ;
3) Mark Drela. XFOIL : An Analysis and Design System for Low Reynolds Number Airfoils :
'http://web.mit.edu/drela/Public/papers/xfoil_sv.pdf' ;
4) Mark Drela. Viscous-Inviscid Analysis of Transonic and Low Reynolds Number Airfoils :
'https://engineering.purdue.edu/~aerodyn/AAE416/Spring%202010/HANDOUTS/AIAA-9789-427.pdf' ;
5) John H. Holland. Adaptation in Natural and Artificial Systems ;
6) David E. Goldberg. Genetic Algorithms in Search, Optimization, and Machine Learning ; 
7) Zheng Wang.  Airfoil Geometry Design for Minimum Drag :
'http://people.bath.ac.uk/zw215/Purdue_AAE550_Final_Project_ZW.pdf' ;
8) Thomas Williams, Colin Kelley. Gnuplot 4.6 : ' http://www.gnuplot.info/docs_4.6/gnuplot.pdf' ;
9) John W. Eaton. GNU Octave : ' https://www.gnu.org/software/octave/doc/interpreter/'.
	

