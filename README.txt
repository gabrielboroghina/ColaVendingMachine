----------------------------------------- Vending Machine -----------------------------------------
Gabriel Boroghina & Mihaela Catrina

Proiectul este format din urmatoarele module:
    * top - modulul top level

    * clk_divider - modulul folosit pentru reducerea frecventei ceasului de la 100MHz la ~760Hz
(pentru a putea scrie pe toate cele 8 afisaje cu 7 segmente).

    * vending_machine - modulul care descrie starile si tranzitiile FSM-ului (FSM-ul este 
reprezentat in fisierul FSM.png).
    Obs: In starile SMALL, BIG, sCARD si bCARD sunt implementate timere (folosind un counter
wait_counter) pentru a forta automatul sa ramana in aceste stari pentru o mica perioada de timp,
astfel incat sa se poate observa pe display trecerea prin aceste stari.

    * display_7seg - primeste un numar intreg pe 10 biti si un cod de stare si le afiseaza pe
display-ul 7-segmente.
    Cele 8 display-uri sunt baleiate continuu folosind un counter pe 3 biti (care este incrementat
la fiecare front crescator de ceas). In functie de valoarea curenta a acestuia se alege display-ul
ce va fi activat (prin setarea anodului corespunzator pe 0).
    Catozii vor fi aprinsi folosind modulul bcd_to_cathodes pentru fiecare dintre cele 8 afisaje.

    * bin_to_bcd_10 - efectueaza conversia unui numar intreg (reprezentat in binar) in formatul
BCD (binary-coded digit), pentru a putea fi afisat apoi pe display-ul 7-segmente.
    Este utilizat algoritmul de conversie asincrona binar paralel - bcd paralel (utilizand celule
elementare de conversie).
    Fiecare cifra a numarului (din reprezentarea zecimala) va fi scrisa pe 4 biti, obtinandu-se 
un BCD. Cele 10 BCD-uri obtinute vor fi apoi folosite de modului bcd_to_cathodes pentru a
determina catozii ca trebuie aprinsi.

    * modului bcd_to_cathodes realizeaza o mapare intre un BCD sau un cod al unei stari si 
o combinatie corespunzatoare de catozi aprinsi.
---------------------------------------------------------------------------------------------------

Functionalitate

    Pentru introducerea tipului de cola (mica/mare) si a diferitelor sume de bani s-au folosit
push buttons. 
    
    Automatul va astepta in starea INIT pana cand se apasa unul dintre butoanele pentru selectarea
tipului de cola. Apoi se va verifica metoda de plata, setata anterior prin intermediul unui switch.
Automatul se va afla dupa acest pas intr-una dintre starile sCARD (small card), sCASH (small cash),
bCARD (big card) sau bCASH (big cash).
    
    In cazul platii cu cardul, se va elibera direct cola (aprindere led corespunzator pentru
cola mica sau mare), iar automatul va trece (si va ramane) in starea DONE.
   
    Daca s-a ales plata cash, automatul va cicla in starea sCASH/bCASH, asteptand introducerea
de bani prin apasari repetate ale butoanelor asignate celor 3 tipuri de sume definite (1, 5 si 10).
    Obs: Pentru ca la o apasare de buton sa se adune o singura data suma introdusa la counter (nu
la fiecare front crescator de ceas, cum s-ar intampla in mod normal daca apasarea este mai lunga),
se va retine starea anterioara a butoanelor (apasat/neapasat la frontul anterior de ceas), iar 
modificarea counterului se va realiza numai la trecerea butonului din starea neapasat in starea 
apasat.
   
    Dupa introducerea unei sume mai mari sau egale cu costul sticlei de cola (mica - 7, mare - 20), 
se trece in starea sREADY/bREADY, in care se elibereaza cola (aprindere led) si se afiseaza restul 
pe display, apoi se trece in starea DONE.
    Calcularea restului se face adunand la counter costul sticlei de cola in complement fata de 2
(realizand astfel scaderea din counter a costului sticlei).