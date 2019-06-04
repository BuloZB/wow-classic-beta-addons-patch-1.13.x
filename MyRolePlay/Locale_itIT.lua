--if GetLocale() ~= "itIT" then return end

if true then return end -- This isn't updated and hasn't been for a long time. I'll need to find someone Italian who can update this. For now, we default them to English.

local L = mrp.L

-- Default locale-dependent options
L["option_HeightUnit"] = 1 -- 0 = centimetres, 1 = metres, 2 = feet/inches
L["option_WeightUnit"] = 0 -- 0 = kilograms, 1 = pounds, 2 = stone/pounds

-- The title of the profile editor tab
L["tabtitle"] = "Profilo"

-- Appears below MyRolePlay in the options panel, describes what the addon does
L["mrp_addon_notes"] = GetAddOnMetadata( "MyRolePlay", "Notes" )

-- Field formats
L["mo_format"] = [[“%s”]]
L["ni_format"] = [[“%s”]]
L["nh_format"] = "%s"
-- Height
L["cm_format"] = "%dcm"
L["cm_format_name"] = "Centimetri (170cm.)"
L["m_format"] = "%.2fm"
L["m_format_name"] = "Metri (1.70m.)"
L["ftin_format"] = [[%d'%d"]]
L["ftin_format_name"] = [[Piedi e Pollici (5'6")]]
-- Weight
L["kg_format"] = "%dkg"
L["kg_format_name"] = "Chilogrammi (60kg.)"
L["lb_format"] = "%dlb"
L["lb_format_name"] = "Libbre (132lb.)"
L["stlb_format"] = "%dst %dlb"
L["stlb_format_name"] = "'Stones e Pounds' (9st. 6lb.)"------------------------------------

-- Tooltip style names
L["ttstyle_0_name"] = "|cffc0c0c0Versione Blizzard (nessuna aggiunta)|r"
L["ttstyle_1_name"] = "Leggero"
L["ttstyle_2_name"] = "Avanzato"
L["ttstyle_3_name"] = "Avanzato |cff90c0c0(senza Ranghi di Gilda)|r"
L["ttstyle_4_name"] = "Compatto"
L["ttstyle_5_name"] = "Compatto |cff90c0c0(senza Ranghi di Gilda)|r"
L["ttstyle_6_name"] = "'Flag-style'"-----------------------------------------------------

-- Preset roleplaying styles
L["FR0"] = "(Stile non impostato)"
L["FR0t"] = "Ancora non impostato"
L["FR0d"] = [[Per favore scegli il tuo stile di gioco di ruolo.]]
L["FR1"] = "Giocatore di ruolo ordinario"
L["FR1t"] = "Normale"
L["FR1d"] = [[Il tuo stile di gioco di ruolo è quello convenzionale.

Di solito giochi interpretando il tuo PG,
ma fai delle eccezioni (per esempio durante una spedizione
o quando lo richiedono le meccaniche di gioco).]]

L["FR2"] = "Giocatore di ruolo casuale"
L["FR2t"] = "Casuale"
L["FR2d"] = [[Il tuo stile di gioco di ruolo è quello casuale.

Interpreti spesso il tuo PG, ma altrettanto spesso vai OOC (Out of Character, ossia 'Fuori dal Personaggio'),
soprattutto per praticità di comunicazione.]]

L["FR3"] = "Giocatore di ruolo 'a tempo pieno'"
L["FR3t"] = "'A tempo pieno'"
L["FR3d"] = [[Il tuo stile di gioco di ruolo è quello cosidetto 'a tempo pieno'.

Sei praticamente sempre IC ('In Character', ossia 'Nel Personaggio'), cercando, quando possibile,
la massima immedesimazione e interpretazione.]]

L["FR4"] = "Giocatore di ruolo principiante"
L["FR4t"] = "Principiante"
L["FR4d"] = [[Il tuo stile di gioco di ruolo è quello del principiante.

Ti avvicini per la prima volta al gioco di ruolo o stai ancora cercando una 'strada' per questo PG
o hai ancora bisogno di tempo per immergerti nell'ambientazione di World of Warcraft®.

Gli altri giocatori sono invitati a perdonare eventuali
tuoi errori.]]

L["FRc"] = "(Personalizzato)"
L["FRct"] = "Personalizzato"
L["FRcd"] = [[Definisci il tuo stile di gioco di ruolo, qualora non rientrasse in nessuno
di quelli sopra descritti.]]

-- Preset character statuses
L["FC0"] = "(Stato non impostato)"
L["FC0t"] = "Non ancora impostato"
L["FC0d"] = [[Per favore, seleziona il tuo stato corrente.]]
L["FC1"] = "'Fuori dal Personaggio'"
L["FC1t"] = "'Fuori dal Personaggio' (OOC)"
L["FC1d"] = [[Sei al momento 'Fuori dal Personaggio', non sei dunque intento a interpretare il tuo PG.

Qualunque cosa tu faccia mentre sei in questo stato non sarà considerata come letteralmente fatta dal tuo PG
(in termini di gioco di ruolo).

Per favore, ricorda che nessun dialogo 'fuori dal personaggio' o che non abbia uno stile 'fantasy'
dovrebbe svolgersi in /pa, /e o /ur.]]
L["FC2"] = "'Nel Personaggio'"
L["FC2t"] = "'Nel Personaggio' (IC)"
L["FC2d"] = [[Sei al momento 'Nel Personaggio': parli e reagisci come farebbe 'realmente' il tuo PG.

Le azioni svolte 'Nel Personaggio' hanno sempre delle conseguenze sul piano del gioco di ruolo.
Gli altri personaggi porebbero dunque interagire con il tuo.]]

L["FC3"] = "Cerchi un Contatto"
L["FC3t"] = "Cerchi un Contatto (LFC)"
L["FC3d"] = [[Sei al momento 'Nel Personaggio': parli e reagisci come farebbe 'realmente' il tuo PG.

Le azioni svolte mentre si è 'Nel Personaggio' hanno sempre delle conseguenze sul piano del gioco di ruolo.
Inoltre, sei indicato come LFC (Looking For Contact, ossia In Cerca di Contatti) e sei
alla ricerca di un'occasione per fare gioco di ruolo: gli altri personaggi sono invitati a interagire con il tuo.]]

L["FC4"] = "Narratore"
L["FC4t"] = "Narratore"
L["FC4d"] = [[Sei al momento 'Nel Personaggio': parli e reagisci come farebbe 'realmente' il tuo PG.

Inoltre, stai al momento conducendo una storia alla quale
gli altri personaggi possono scegliere di partecipare.]]

L["FCc"] = "(Personalizzato)"
L["FCct"] = "Personalizzato"
L["FCcd"] = [[Definisci lo stato del tuo personaggio, qualora non rientrasse in nessuno
di quelli sopra descritti.]]

-- Field names and tooltip descriptions for the profile editor
L["NA"] = "Nome"
L["efNA"] = [[Il nome del tuo personaggio, come desideri sia visualizzato.

Qui puoi cambiare il nome del tuo PG o volendo inserirne un secondo.]]
--
L["NI"] = "Soprannome"
L["efNI"] = [[Il soprannome del tuo personaggio, se ne ha uno.

Per esempio, il nome con cui è comunemente conosciuto tra i suoi amici.]]
--
L["NT"] = "Titolo"
L["efNT"] = [[Il titolo del tuo personaggio; verrà visualizzato al di sotto del nome.

Spesso è una descrizione a riga singola o una sinossi.]]
--
L["NH"] = "Casato"
L["efNH"] = [[Il nome del casato del tuo personaggio, ammesso che ne abbia uno;
soltanto poche razze ne possiedono.]]
--
L["AE"] = "Occhi"
L["efAE"] = [[Il colore degli occhi del tuo personaggio, come appropriato.]]
--
L["RA"] = "Razza"
L["efRA"] = [[La razza del tuo personaggio (qualora fosse diversa da come appaia in gioco).

|cffff5533Attenzione:|r giocare razze rare o esotiche non è raccomandabile per i principianti:
potrebbe infatti essere molto complicato interpretare alcune razze dell'ambientazione di World of Warcraft®
(non tutti possono, o dovrebbero, essere mezzelfi!).

Si prega di applicare estrema cautela in questo campo.

Non indicare nulla se desideri che la tua razza sia quella che appare in gioco.]]
--
L["AH"] = "Altezza"
L["efAH"] = [[Quanto alto/a (o basso/a) è il tuo personaggio.

Inserire un'altezza precisa (inserisci un numero in centimetri, esempio 175 per indicare un metro e settantacinque)
oppure una breve descrizione (per esempio: alto, basso, di altezza media.)]]
--
L["AW"] = "Peso"
L["efAW"] = [[Quanto sembra che pesi il tuo personaggio.

Inserire un peso preciso (inserisci un numero in chilogrammi, esempio 60,5 per indicare sessanta chili e mezzo)
oppure una breve descrizione esplicativa (per esempio: snello, massiccio, grasso).]]
--
L["AG"] = "Età"
L["efAG"] = [[Quanto è vecchio/a il tuo personaggio.

Inserire un'età specifica in anni (per esempio 45 per indicare quarantacinque anni)
oppure una breve descrizione (per esempio: giovane, vecchio, di mezza età).

Se inserisci un'età specifica in anni, ricorda che le razze hanno modi completamente diversi
di computare il tempo (per esempio, un Elfo della Notte di 300 anni è considerato appena un adulto…).]]
--
L["CU"] = "Situazione Attuale"
L["efCU"] = [[Se qualcuno si soffermasse a osservare il tuo personaggio proprio adesso, cosa noterebbe subito?
Il tuo personaggio è felice o triste? Forse è soltanto stanco? Magari è sospettoso?
Impugna qualcosa? Oppure è ricoperto di sangue? Forse è intento a fare compere? O è preoccupato?

Questo campo è volutamente destinato a essere molto breve: tienine conto!]]
--
L["DE"] = "Descrizione"
L["efDE"] = [[Descrivi l'aspetto del tuo personaggio, come lo vede chi osserva il tuo PG.

Immagina come il tuo personaggio possa essere descritto in un racconto d'avventura o magari in un libro 'fantasy'.

Per favore, |cffff5533evita|r:
di enfatizzare la storia del tuo personaggio (se vuoi, inseriscila piuttosto nel campo 'Storia');
di dare indicazioni su come si comportano gli altri personaggi (è meglio lasciare tali decisioni ai rispettivi giocatori);
tutto ciò che non si riferisca all'aspetto esteriore del tuo personaggio;
tutto ciò che possa violare le regole o le politiche di gioco del reame.
 
Ricorda che qui va inserita SOLTANTO la descrizione fisica.]]
--
L["HH"] = "Residenza"
L["efHH"] = [[Il luogo dove al momento vive il tuo personaggio, ammesso che ne abbia uno.]]
--
L["HB"] = "Luogo di Nascita"
L["efHB"] = [[Dov'è nato il tuo personaggio.]]
--
L["MO"] = "Motto"
L["efMO"] = [[Il motto del personaggio, ossia come riassumerebbe la sua visione della vita, oppure
qualcosa che altri dicono spesso di lui/lei e che possa riassumere il suo carattere.]]
--
L["HI"] = "Storia"
L["efHI"] = [[Puoi, se desideri, sottolinerare qualcosa della storia e/o dei trascorsi del tuo personaggio.

Piuttosto che compilare una biografia completa, i giocatori dovrebbero limitare le informazioni fornite
a quelle che si pensa siano di pubblico dominio (magari delle dicerie), dal momento che molti giocatori
preferiscono scoprire questi dettagli interagendo con te.

Prova a dar loro un assaggio, piuttosto che tutta la torta!]]
--
L["FR"] = "Stile di Gioco di Ruolo"
L["efFR"] = [[Il tuo stile di gioco di ruolo preferito per questo personaggio.]]
--
L["FC"] = "Stato del Personaggio"
L["efFC"] = [[Se stai attualmente interpretando o meno il tuo personaggio,
se sei alla ricerca di contatti o se al momento sei un narratore.]]

-- Command usage
L["commandusage"] = [[Utilizzo: |cff99ffff/mrp|r |cffaaaa00<comando>|r
I comandi sono i seguenti:
    |cff99ffffshow|r - Mostra il profilo GdR del bersaglio, quando possibile.
    |cff99ffffshow|r |cffaaaa00<charactername>|r - Mostra il profilo GdR di qualcuno/a, quando possibile.
    |cff99ffffbrowser reset|r - Ripristina la dimensione e la posizione iniziali del navigatore del profilo.
    |cff99ffffprofile|r |cffaaaa00<profile name>|r - Passa a un altro profilo (a seconda del nome).
    |cff99ffffedit|r - Mostra il pannello di modifica del profilo.
    |cff99ffffoptions|r - Mostra il pannello delle opzioni.
    |cff99ffffbutton on|r/|cff99ffffoff|r - Mostra/nasconde un pulsante MRP del bersaglio, per navigare sul suo profilo GdR.
    |cff99ffffbutton reset|r - Ripristina la posizione inziale del pulsante MRP del bersaglio.
    |cff99fffftooltip on|r/|cff99ffffoff|r - Abilita o disabilita i suggerimenti MRP avanzati per i giocatori, tra cui informazioni sui profili.
    |cff99ffffenable|r/|cff99ffffdisable|r - Attiva o disattiva completamente MyRolePlay.
    |cff99ffffversion|r - Mostra le informazioni sulla versione in uso.]]

-- Options Panel
L["opt_enable"] = "Attiva"
L["opt_enable_tt"] = [[Attiva o disattiva completamente MyRolePlay.]]
L["opt_tt"] = "Suggerimenti Avanzati"
L["opt_tt_tt"] = [[Suggerimenti avanzati per il giocatore con informazioni di GdR.

Può essere molto utile, ma puoi disabilitarlo se non ti piace lo stile
o se interferisce con eventuali AddOns che modificano i suggerimenti per il giocatore.]]
L["opt_mrpbutton"] = "Mostra il pulsante MRP"
L["opt_mrpbutton_tt"]= [[Mostra un pulsante MRP accanto al bersaglio quando selezioni giocatori con AddOns compatibili.

Cliccaci col tasto sinistro per navigare sul profilo del personaggio.
Cliccaci col tasto destro per bloccare/sbloccare il pulsante e trascinarlo da un'altra parte.]]
--
L["opt_rpchatname"] = "Mostra i nomi GdR in /pa, /e e /ur"
L["opt_rpchatname_tt"]= [[Mostra i nomi GdR nelle finestre dei canali di chat per i canali GdR, quando conosciuti e disponibili.]]
--
L["opt_disp_header"] = "Pannello del Profilo"
L["opt_biog"] = "Mostra le informazioni biografiche"
L["opt_biog_tt"] = [[Mostra o nasconde l'etichetta Biografia nel navigatore del profilo.

Attivala se desideri maggiori informazioni.
Disattivala se preferisci scoprire le informazioni biografiche dei personaggi attraverso l'interazione con essi.]]
L["opt_ahunit"] = "Mostra l'altezza in…"
L["opt_awunit"] = "Mostra il peso in…"
--
L["opt_ac_header"] = "Cambia automaticamente il profilo in…"
--
L["opt_formac"] = "Mutaforma"

L["opt_formac_tt"] = [[Passa automaticamente a un altro profilo quando cambi forma.
]]
L["opt_formac_tt_disabled"] = L["opt_formac_tt"] .. [[
Questo personaggio non ha cambi di forma disponibili, quindi al momento questa funzione è disattivata.]]
L["opt_formac_tt_enabled1"] = L["opt_formac_tt"] .. [[
Indica l'esatto nome del profilo dopo il nome della forma, come segue:
]]
L["opt_formac_tt_suffix"] = [[|cffff9090Non|r includere parentesi; fare inoltre attenzione tra |cffff9090maiuscole|r e |cffff9090minuscole|r!

Tornare alla tua forma originale riporta anche il tuo profilo a quello originale.

Per profili personalizzati, utilizza “|cffffff00NomedelProfilo:Forma|r”: per esempio,
attiva il profilo “|cffffff00Tuxedo|r” quando ti trasformi in Worgen -> “|cffffff00Tuxedo:Worgen|r”
(le spese di riparazione dei vestiti non sono incluse! Results May Vary™).
]]

L["opt_formac_tt_worgensuffix"] = [[

|cffffa0a0Nota: |rahimè, la distinzione tra Umano/a e Worgen è imprecisa (a causa di una svista della Blizzard).
Utilizza |cff80c0c0Scatto Oscuro|r, |cff80c0c0Corsa Animalesca|r oppure |cff80c0c0ingaggia un combattimento|r per tentare di correggerla.]]

L["opt_formac_tt_worgen"] = L["opt_formac_tt_enabled1"] .. [[
Scegli “|cffffff00Worgen|r” o “|cffffff00Umano/a|r”;
(seleziona quale forma tu senti non sia quella "base"; scegline soltanto una).
]] .. L["opt_formac_tt_suffix"] .. L["opt_formac_tt_worgensuffix"]

L["opt_formac_tt_worgendruid"] = L["opt_formac_tt_enabled1"] .. [[
Scegli “|cffffff00Worgen|r” o “|cffffff00Umano/a|r”;
 (seleziona quale forma tu senti non sia quella "base"; scegline soltanto una).
“|cffffff00Felino|r”;
“|cffffff00Orso|r”;
“|cffffff00Viaggio|r” (o “|cffffff00Ghepardo|r”);
“|cffffff00Volante|r” (o “|cffffff00Corvo|r”);
“|cffffff00Acquatica|r” (o “|cffffff00Leone Marino|r”);
“|cffffff00Lunagufo|r” (se appropriato); e
“|cffffff00Albero|r” (se appropriato).
]] .. L["opt_formac_tt_suffix"] .. L["opt_formac_tt_worgensuffix"]

L["opt_formac_tt_druid"] = L["opt_formac_tt_enabled1"] .. [[
“|cffffff00Felino|r”;
“|cffffff00Orso|r”;
“|cffffff00Viaggio|r” (o “|cffffff00Ghepardo|r”);
“|cffffff00Volante|r” (o “|cffffff00Corvo|r”);
“|cffffff00Acquatica|r” (o “|cffffff00Leone Marino|r”);
“|cffffff00Lunagufo|r” (se appropriato); e
“|cffffff00Albero|r” (se appropriato).
]] .. L["opt_formac_tt_suffix"]

L["opt_formac_tt_shaman"] = L["opt_formac_tt_enabled1"] .. [[
“|cffffff00Lupo Fantasma|r” (o soltanto “|cffffff00Lupo|r”).
]] .. L["opt_formac_tt_suffix"]

L["opt_formac_tt_priest"] = L["opt_formac_tt_enabled1"] .. [[
“|cffffff00Ombra|r”.
]] .. L["opt_formac_tt_suffix"]

L["opt_formac_tt_worgenpriest"] = L["opt_formac_tt_enabled1"] .. [[
Scegli “|cffffff00Worgen|r” o “|cffffff00Umano/a|r”;
(seleziona quale forma tu senti non sia quella "base"; scegline soltanto una) e
“|cffffff00Ombra|r”.
(Nota: potresti anche volere indicare “|cffffff00Ombra:Umano/a|r” e/o “|cffffff00Ombra:Worgen|r”
(oppure altri modi), dal momento che puoi essere in forma d'ombra
E in forma di Umano/a o di Worgen nello stesso tempo…)
]] .. L["opt_formac_tt_suffix"] .. L["opt_formac_tt_worgensuffix"]

L["opt_formac_tt_warlock"] = L["opt_formac_tt_enabled1"] .. [[
“|cffffff00Demone|r” (se appropriato per la tua specializzazione).
]] .. L["opt_formac_tt_suffix"]

L["opt_formac_tt_worgenwarlock"] = L["opt_formac_tt_enabled1"] .. [[
Scegli “|cffffff00Worgen|r” o “|cffffff00Umano/a|r”;
(seleziona quale forma tu senti non sia quella "base"; scegline soltanto una) e
“|cffffff00Demone|r” (se appropriato per la tua specializzazione).
]] .. L["opt_formac_tt_suffix"] .. L["opt_formac_tt_worgensuffix"]
--
L["opt_equipac"] = "Cambia il set d'equipaggiamento"
L["opt_equipac_tt"] = [[Passa automaticamente a un altro profilo quando cambi set d'equipaggiamento.

Indica il nome del profilo dopo il nome del set d'equipaggiamento; fare inoltre attenzione tra |cffff9090maiuscole|r e |cffff9090minuscole|r!

Utile per cambiare descrizione a seconda dell'abbigliamento GdR.

Funziona con il gestore dell'equipaggiamento della Blizzard, ItemRack e Outfitter.]]

-- Races - overrides for RaceEn, second return from UnitRace(), to localise them
L["NightElf"] = "Elfo/a della Notte"
L["Scourge"] = "Reietto/a"