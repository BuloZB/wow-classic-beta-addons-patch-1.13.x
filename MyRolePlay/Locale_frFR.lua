if(GetLocale() ~= "frFR") then -- French localisation support added by Katorie with translations from Wakmagic (Mystra) and Solanya.
	return
end

-- Always initialise enGB, as it's the default
local L = mrp.L

-- Default locale-dependent options

L["option_HeightUnit"] = 0 -- 0 = centimetres, 1 = metres, 2 = feet/inches
L["option_WeightUnit"] = 0 -- 0 = kilograms, 1 = pounds, 2 = stone/pounds

-- The title of the profile editor tab
L["tabtitle"] = "MyRolePlay"
L["tabtitleshort"] = "MRP" -- Hunters in vanilla don't have enough tab space due to the readdition of the Pet/Skills/Honour tabs.

-- Appears below MyRolePlay in the options panel, describes what the addon does
L["mrp_addon_notes"] = GetAddOnMetadata( "MyRolePlay", "Notes" )

-- Field formats
L["mo_format"] = [[“%s”]]
L["ni_format"] = [[“%s”]]
L["nh_format"] = "%s"
L["rs_format"] = "%s"
-- Height
L["opt_displayheight_header"] = "Afficher la taille en..."
L["cm_format"] = "%dcm"
L["cm_format_name"] = "Centimètres (170cm)"
L["m_format"] = "%.2fm"
L["m_format_name"] = "Mètres (1.70m)"
L["ftin_format"] = [[%d'%d"]]
L["ftin_format_name"] = [[Pieds & pouces (5'6")]]
-- Weight
L["opt_displayweight_header"] = "Afficher le poids en..."
L["kg_format"] = "%dkg"
L["kg_format_name"] = "Kilogrammes (60kg)"
L["lb_format"] = "%dlb"
L["lb_format_name"] = "Livres (132lb)"
L["stlb_format"] = "%dst %dlb"
L["stlb_format_name"] = "Stone & Livres (9st 6lb)"
-- Description / History Font Size
L["opt_defontsize_header"] = "Taille de police pour description et histoire"

-- Tooltip style names
L["ttstyle_0_name"] = "|cffc0c0c0Défaut|r"
L["ttstyle_1_name"] = "De base"
L["ttstyle_2_name"] = "Augmentée"
L["ttstyle_3_name"] = "Compacte"

-- Preset roleplaying styles
L["FR0"] = "(Style non défini)"
L["FR0t"] = "Pas encore défini"
L["FR0d"] = [[Choisissez votre style de joueur en RP.]]
L["FR1"] = "Joueur RP normal"
L["FR1t"] = "Normal"
L["FR1d"] = [[Votre style de RP est conventionnel.

Vous êtes généralement en RP, mais participez
occasionnellement en communication HRP
(par exemple, dans des donjons, ou bien quand les
mécaniques du jeu l'exigent). ]]
L["FR2"] = "Joueur RP relax"
L["FR2t"] = "Relax"
L["FR2d"] = [[Votre style de RP est détendu.

Vous êtes souvent en RP, mais vous communiquez
HRP quand cela est plus facile pour vous. ]]
L["FR3"] = "Joueur RP à plein temps"
L["FR3t"] = "À plein temps"
L["FR3d"] = [[Votre style de RP est à plein temps.

Vous êtes presque toujours en RP, et
souhaitez l'immersion totale quand c'est possible. ]]
L["FR4"] = "Joueur RP débutant"
L["FR4t"] = "Débutant"
L["FR4d"] = [[Votre style de RP est celui d'un débutant.

Vous êtes nouveau au jeu de rôle, ou bien vous vous
habituez toujours à votre personnage ou au monde
de World of Warcraft.

Les autres joueurs seront priés de vous pardonner
certaines erreurs. ]]
L["FRc"] = "(Personnalisé)"
L["FRct"] = "Personnalisé"
L["FRcd"] = [[Définissez votre propre style de RP si vous ne le trouvez pas ci-dessus.]]


-- Preset character statuses
L["FC0"] = "(Statut non défini)"
L["FC0t"] = "Pas encore défini"
L["FC0d"] = [[Indiquez votre statut de RP actuel.]]
L["FC1"] = "Hors du personnage"
L["FC1t"] = "Hors du personnage (HRP)"
L["FC1d"] = [[Vous êtes actuellement hors du personnage, préférant jouer le
jeu plutôt que votre personnage RP.

Tout ce que vous faites lorsque ce statut est affiché ne sera pas
considéré partie de l'histoire de votre personnage.

Notez bien qu'aucun dialogue hors du personnage ou non RP ne devrait prendre
place dans les canaux /dire, /emote ou /cri.]]
L["FC2"] = "Dans le personnage"
L["FC2t"] = "Dans le personnage (RP)"
L["FC2d"] = [[Vous êtes actuellement dans votre personnage. Vous parlez et vous
agissez tel que votre personnage le ferait normalement.

Vos actions en personnage engendreront des conséquences appropriées pour
votre personnage. D'autres personnages RP peuvent interagir avec le vôtre.]]
L["FC3"] = "À la recherche de contact"
L["FC3t"] = "À la recherche de contact (LFC)"
L["FC3d"] = [[Vous êtes actuellement dans votre personnage. Vous parlez et vous
agissez tel que votre personnage le ferait normalement.

Vos actions en personnage engendreront des conséquences appropriées pour
votre personnage. D'autres personnages RP sont invités et encouragés
à interagir avec le vôtre.]]
L["FC4"] = "Narrateur/narratrice"
L["FC4t"] = "Narrateur/narratrice"
L["FC4d"] = [[Vous êtes actuellement dans votre personnage. Vous parlez et vous
agissez tel que votre personnage le ferait normalement.

Vous menez actuellement une histoire RP à laquelle d'autres personnages RP
peuvent choisir de participer.]]
L["FCc"] = "(Personnalisé)"
L["FCct"] = "Statut personnalisé"
L["FCcd"] = [[Définissez un statut personnalisé pour votre personnage, si
votre statut désiré n'apparait pas ci-dessus.]]

-- Preset relationship statuses
L["RS0"] = "Inconnu"
L["RS0t"] = "Aucun statut défini"
L["RS0d"] = [[Choisissez le statut de relation de votre personnage, si vous le désirez.

Vous pouvez aussi choisir cet option si vous ne souhaitez pas indiquer votre statut
de relation.]]
L["RS1"] = "Célibataire"
L["RS1t"] = "Célibataire"
L["RS1d"] = [[Votre personnage est célibataire.]]
L["RS2"] = "En couple"
L["RS2t"] = "En couple"
L["RS2d"] = [[Votre personnage est en couple,
mais non marié(e).]]
L["RS3"] = "Marié(e)"
L["RS3t"] = "Marié(e)"
L["RS3d"] = [[Votre personnage est marié(e).]]
L["RS4"] = "Divorcé(e)"
L["RS4t"] = "Divorcé(e)"
L["RS4d"] = [[Votre personnage est divorcé(e), d'un mariage précédent.]]
L["RS5"] = "Veuf/veuve"
L["RS5t"] = "Veuf/veuve"
L["RS5d"] = [[Votre personnage était marié(e) mais leur partenaire est décédé(e).]]

-- Tooltip stuff
L["level"] = "Niveau"

-- Field names and tooltip descriptions for the profile editor
L["NA"] = "Nom"
L["efNA"] = [[Le nom de votre personnage, tel que vous le souhaitez affiché.

Vous pouvez y inclure un nom de famille,
ou bien le changer comme vous voulez.]]
--
L["NI"] = "Surnom"
L["efNI"] = [[Le surnom de votre personnage, s'il en possède un.

Ce pourrait être un nom par lequel vous êtes connu, par exemple.]]
--
L["NT"] = "Titre"
L["efNT"] = [[Le titre de votre personnage. Ceci apparaîtra en-dessous
de leur nom.

Souvent une brève description de leurs accomplissements.]]
--
L["NH"] = "Maison"
L["efNH"] = [[Le nom de la maison de votre personnage, si applicable;
seules certaines races en auront un.]]
--
L["RS"] = "Statut de relation"
L["efRS"] = [[Le statut de relation de votre personnage.

En choisissant "En couple" ou "Marié(e)", votre infobulle
affichera un coeur visible à tous.]]
--
L["AE"] = "Yeux"
L["efAE"] = [[La couleur des yeux de votre personnage.]]
--
L["RA"] = "Race"
L["efRA"] = [[La race de votre personnage (si elle diffère du celle en jeu).

|cffff5533Attention:|r veuillez noter que jouer une race
rare ou exotique n'est pas recommandé pour les joueurs RP
novices. Il peut être difficile de jouer ces races de
manière convainquante dans le contexte de World of Warcraft.

(Tout le monde ne peut ou ne devrait pas être un demi-elfe !)

Prenez donc une attention particulière avec ce champ.

Laissez ce champ vide afin de garder votre race tel qu'elle apparait
par défaut dans le jeu.]]
--
L["RC"] = "Classe"
L["efRC"] = [[La classe de votre personnage (si elle diffère de celle en jeu).

|cffff5533Attention:|r prenez garde avec ce champ. Évitez d'utiliser
des noms de classes particulièrement prolixes qui ont peu de sens
dans le contexte du jeu.

Laissez ceci vide afin de garder votre classe telle qu'elle apparaît
par défaut dans le jeu.]]
--
L["AH"] = "Taille"
L["efAH"] = [[La taille de votre personnage.

Indiquez soit:
 · une taille précise:
     (inscrivez un nombre en centimètres sans unité, par ex. 175)
 · une description courte (grand, court, moyen…)]]
--
L["AW"] = "Poids"
L["efAW"] = [[Combien votre personnage paraît peser.

Indiquez soit:
 · un poids précis
     (inscrivez un nombre de kilogrammes sans unité, par ex. 60.5)
 · une description courte (mince, lourd, dans la norme…)]]
--
L["AG"] = "Âge"
L["efAG"] = [[Quel âge a votre personnage.

Indiquez soit:
 · un âge précis
    (en années, sans unité, par ex. 45)
 · une description courte (jeune, ancien, de moyen âge…)

Notez bien que si vous indiquez un nombre d'années précis
pour leur âge, certaines races vieillissent différemment.
(par ex. un elfe de la nuit de 300 ans est à peine un adulte…)]]
--
L["CU"] = "Actuellement (RP)"
L["efCU"] = [[Si quelqu'un remarquait votre personnage
en ce moment, quelle serait la première chose qu'ils
apercevraient ?

Est-ce que votre personnage est content ? Triste ? Méfiant ?
Tenez-vous quelque chose ? Êtes-vous couvert de sang ?
Est-ce que vous magasinez, ou êtes autrement préoccupés ?

Ce champ pourra afficher de quelques mots à quelques lignes
sur votre infobulle. Soyez clair et bref !]]
--
L["CO"] = "Autres informations (HRP)"
L["COabb"] = "HRP"
L["efCO"] = [[Indiquez ici des informations pertinentes à
vous en tant que joueur, ou quelque chose qui ne concerne pas
votre personnage RP.]]
--
L["PE"] = "Coup d'œil"
L["efPE"] = [[Ces champs sont des informations BRÈVES et CONCISES
au sujet de votre personnage.

Vous pouvez en ajouter jusqu'à cinq, et y ajouter une icône.
Veuillez limiter votre texte à plus ou moins un paragraphe.]]
--
L["DE"] = "Description"
L["efDE"] = [[Décrivez l'apparence de votre personnage, tel
que quelqu'un les regardant les verrait.

Considérez la manière avec laquelle un roman ou une
fiction interactive les décriraient.

|cffff5533Évitez|r de:
 · décrire l'histoire de votre personnage; ceci a sa place
   dans la section Histoire
 · préciser comment d'autres personnages réagiraient face à
   votre personnage (il vaut mieux laisser le contrôle des
   autres personnages à leurs joueurs respectifs)
 · inclure quelque chose qui n'est pas lié à l'apparence de
   votre personnage
 · inclure quelque chose qui enfreint les règles
   ou les conditions d'usage du serveur

Notez bien que SEULES les descriptions sur l'apparence
ont leur place ici.]]
--
L["PS"] = "Traits de personnalité"
L["PSsubheader"] = "Cliquez pour définir vos traits de personnalité."
L["efPS"] = [[Les traits qui décrivent la personnalité de votre personnage.

Les barres indiquent comment le trait est en ligne avec votre personnalité.

|cffff5533Astuce :|r La plupart des personnages n'auront pas une forte tendance dans tous leurs traits.]]
--
L["HH"] = "Résidence"
L["efHH"] = [[Le lieu où réside actuellement votre personnage.]]
--
L["HB"] = "Lieu de naissance"
L["efHB"] = [[Où est né votre personnage.]]
--
L["MO"] = "Devise"
L["efMO"] = [[Soit:

 · la devise de votre personnage
 · leur perspective sur la vie
 · une phrase que votre personnage répète souvent
   que vous considérez propre à lui.]]
--
L["HI"] = "Histoire"
L["efHI"] = [[Vous pouvez, si vous le désirez, décrire
ici un peu de l'histoire ou du contexte de votre personnage.

Plutôt qu'une biographie complète, considérez limiter cette
information seulement à des choses connues par le grand public
à propos de votre personnage (peut-être des rumeurs).
Plusieus joueurs préfèrent découvrir l'histoire d'un
personnage par l'interaction avec ce dernier.

Donnez leur un avant-goût, plutôt que la tarte entière !]]
--
L["FR"] = "Style de RP"
L["efFR"] = [[Votre style de RP préféré pour ce personnage.]]
--
L["FC"] = "Statut de RP"
L["efFC"] = [[Si vous êtes actuellement RP ou HRP,
si vous cherchez un contact, ou si vous êtes narrateur.]]

-- Editor
L["editor_clicktoedit"] = "|cff4466eeCliquez|r |cffffffffpour modifier|r"
L["editor_icon_button"] = "Icône"
L["editor_icon_button_tt_active"] = "Votre icône :"
L["editor_icon_button_tt_inactive"] = "Sélectionnez une icône pour votre profil."
L["editor_music_button"] = "Musique"
L["editor_music_button_tt_active"] = "Votre musique : "
L["editor_music_button_tt_inactive"] = "Sélectionnez un thème musical pour votre profil."
L["editor_newprofile_button"] = "Créer un nouveau profil"
L["editor_newprofile_popup"] = "Donnez un nom à votre nouveau profil : "
L["editor_renameprofile_button"] = "Renommer ce profil"
L["editor_renameprofile_popup"] = "Donnez un nouveau nom à ce profil : "
L["editor_deleteprofile_button"] = "Effacer ce profil"
L["editor_deleteprofile_button_default"] = "Effacez tous vos profils, les retournant au profil par défaut"
L["editor_deleteprofile_popup"] = "Êtes-vous certain de vouloir effacer ce profil, détruisant toute l'information qu'il contient ?"
L["editor_deleteallprofiles_popup"] = "Êtes-vous certain de vouloir effacer TOUTE l'information dans vos profils MRP, et de retourner entièrement au profil par défaut ? Vous ne pourrez pas changer d'avis après."
L["editor_settings_button"] = "Modifier les réglages de MRP"
L["editor_glance_headers"] = "Titre / Détails"
L["editor_glanceclear_button"] = "Effacer ce coup d'oeil et son icône"
L["editor_inherited_label"] = "Hérité du défaut"
L["editor_namecolour_button"] = "Colorer le nom"
L["editor_namecolour_button_tt"] = "Changez la couleur de votre nom."
L["editor_eyecolour_button"] = "Colorer les yeux"
L["editor_eyecolour_button_tt"] = "Changez la couleur de vos yeux."
L["editor_restorecolour_button"] = "Retour au défaut"
L["editor_restorecolour_button_tt"] = "Retournez la couleur à celle du profil par défaut."
L["editor_inherit_button"] = "Hérité"
L["editor_inherit_button_tt"] = "Annuler les changements, et reprendre le profil par défaut"
L["editor_insertcolour_button"] = "Couleur"
L["editor_insertcolour_tt_title"] = "Insérer un code de couleur"
L["editor_insertcolour_tt_1"] = "Choisissez une couleur avec la palette. En cliquant «Okay», un code de couleur sera inséré à la position de votre curseur dans le champ. Mettez le texte désiré entre les balises pour lui donner cette couleur."
L["editor_insertcolour_tt_2"] = "Par exemple:\n{col:ff0000}Katorie a des sabots.{/col}"
L["editor_insertlink_button"] = "Hyperlien"
L["editor_insertlink_tt_title"] = "Insérer un hyperlien vers un site web dans votre profil"
L["editor_insertlink_tt_1"] = "Insérez un lien modèle avec ce bouton, et puis remplacez «your.url.here» avec l'URL de votre choix. Par la suite, remplacez «Your text here» avec ce que vous souhaitez comme texte pour votre lien."
L["editor_insertlink_tt_2"] = "Par exemple:\n{link*http://tinyurl.com/katorie*l'art de Kat}"
L["editor_inserticon_button"] = "Icône"
L["editor_inserticon_tt_title"] = "Insérer une icône"
L["editor_inserticon_tt_1"] = "Choisissez une icône avec l'outil. Une balise contenant le code pour l'icône apparaîtra dans l'éditeur à la position de votre curseur, tandis que l'icône elle-même sera visible dans votre profil. Vous pouvez la prévisionner en affichant votre propre profil."
L["editor_insertheader_button"] = "En-tête"
L["editor_insertheader_tt_title"] = "Insérer un en-tête."
L["editor_insertheader_tt_1"] = "Sélectionnez une grandeur et un alignement pour l'en-tête avec le menu, et puis placez votre texte entre les balises."
L["editor_insertheader_tt_2"] = "Par exemple:\n{h1:c}Mon texte d'en-tête{/h1}"
L["editor_insertparagraph_button"] = "Paragraphe"
L["editor_insertparagraph_tt_title"] = "Insérer un paragraphe aligné."
L["editor_insertparagraph_tt_1"] = "Sélectionnez l'alignement désiré auprès du menu, et puis placez votre texte entre les balises."
L["editor_insertparagraph_tt_2"] = "Par exemple:\n{p:c}Mon texte en paragraphe{/p}"
L["editor_insertimage_button"] = "Image"
L["editor_insertimage_tt_title"] = "Insérer une image."
L["editor_insertimage_tt_1"] = "Insérez une image avec l'outil d'images. Un lien contenant une référence à l'image sélectionné apparaîtra dans l'éditeur de profil là où se trouve votre curseur. L'image elle-même apparaîtra dans votre profil. (Vous pouvez voir un aperçu en cliquant le bouton marqué «Aperçu»)"

L["editor_formattingtools_header"] = "Outils de mise en forme : Insérer..."
L["editor_previewprofile_button"] = "Aperçu"
L["editor_previewprofile_tt_1"] = "Prévisualisez les changements à votre profil."
L["editor_previewprofile_tt_2"] = "Ceci affichera un aperçu de votre profil, incluant la mise en forme de toutes les couleurs, icônes et hyperliens, afin que vous puissiez voir comment les autres joueurs le verront."
L["editor_returntoeditor_button"] = "Retour"
L["editor_returntoeditor_tt_1"] = "Les changements ne seront pas définitifs avant d'avoir sauvegardé."
L["editor_addpersonalitytrait"] = "Ajouter un trait"
L["editor_customtrait"] = "Ajouter un trait personnalisé"
L["editor_deletetrait"] = "Effacer un trait."
L["editor_mrptab_tt"] = "Modifier vos profils de RP"

-- Editor icon / music / image selector
L["editor_search"] = "Recherche"
L["editor_matches"] = " corresp."
L["editor_play"] = "Jouer"
L["editor_stop"] = "Arrêter"
L["editor_clearicon"] = "Effacer l'icône"
L["editor_clearmusic"] = "Effacer"

L["save_button"] = "Sauvegarder"
L["save_button_tt"] = "Sauvegardez les changements que vous avez effectués à votre profil"
L["cancel_button"] = "Annuler"
L["cancel_button_tt"] = "Annulez les changements que vous avez effectués et retournez à l'état précédent"

-- Personality traits
L["lefttrait1"] = "Chaotique"
L["righttrait1"] = "Légitime"

L["lefttrait2"] = "Chaste"
L["righttrait2"] = "Luscif"

L["lefttrait3"] = "Indulgent"
L["righttrait3"] = "Vindicatif"

L["lefttrait4"] = "Altruiste"
L["righttrait4"] = "Égoïste"

L["lefttrait5"] = "Véridique"
L["righttrait5"] = "Trompeur"

L["lefttrait6"] = "Doux"
L["righttrait6"] = "Brutal"

L["lefttrait7"] = "Supersticieux"
L["righttrait7"] = "Rationnel"

L["lefttrait8"] = "Rénégat"
L["righttrait8"] = "Parangon"

L["lefttrait9"] = "Prudent"
L["righttrait9"] = "Impulsif"

L["lefttrait10"] = "Ascétique"
L["righttrait10"] = "Bon vivant"

L["lefttrait11"] = "Valeureux"
L["righttrait11"] = "Vif"

-- Browser
L["browser_playmusic_button"] = "Jouer le thème musical : "
L["browser_notesnone_button"] = "Ajouter une remarque sur ce profil"
L["browser_notespresent_button"] = "Remarques pour ce profil : "
L["browser_loading_nonewdata"] = "Aucune information additionnelle reçue."
L["browser_loading_inprogress"] = "|cFFFFFF00Chargement du profil:"
L["browser_loading_complete"] = "|cFF33FF11Profil chargé avec succès."
L["browser_loading_error"] = "|cFFFF0000Erreur dans le chargement du profil."
L["browser_tab1"] = "Apparence"
L["browser_tab1_tt"] = "Descriptions de l'apparence du personnage."
L["browser_tab2"] = "Personnalité"
L["browser_tab2_tt"] = "Traits de personnalité du personnage."
L["browser_tab3"] = "Biographie"
L["browser_tab3_tt"] = "Biographie et informations historiques."

-- Command usage

L["commandusage"] = [[Usage: |cff99ffff/mrp|r |cffaaaa00<commande>|r
Les commandes sont les suivantes:
    |cff99ffffshow|r - Afficher le profil RP du personnage ciblé, si possible
    |cff99ffffshow|r |cffaaaa00<nom de personnage>|r - Afficher le profil RP de quelqu'un
    |cff99ffffbrowser reset|r - Réinitialiser la taille et la position du navigateur de profil
    |cff99ffffprofile|r |cffaaaa00<nom de profil>|r - Changer pour le profil indiqué
    |cff99ffffedit|r - Afficher l'éditeur de profil
    |cff99ffffoptions|r - Afficher le panneau d'options
    |cff99ffffbutton on|r/|cff99ffffoff|r - Afficher ou cacher un bouton « MRP » près de votre cible, afin d'ouvrir leur profil RP
    |cff99ffffbutton reset|r - Réinitialiser le bouton MRP à sa position par défaut
    |cff99fffftooltip on|r/|cff99ffffoff|r - Indiquer si MRP devrait afficher ou non des infobulles améliorées, incluant des informations sur le profil
    |cff99ffffenable|r/|cff99ffffdisable|r - Activer ou désactiver complètement MyRolePlay
    |cff99ffffversion|r - Afficher la version de votre installation de MRP]]

-- Options Panel

L["opt_basicfunctionality_header"] = "Fonctionnalités de base"
L["opt_rpnamesinchat_header"] = "Afficher les noms RP..."
L["opt_enable"] = "Activer"
L["opt_enable_tt"] = [[Activer ou désactiver complètement MyRolePlay]]
L["opt_tooltipdesign_header"] = "Réglages de l'infobulle"
L["opt_maxtooltiplines_header"] = "# de lignes dans l'infobulle"
L["opt_tooltipstyle_header"] = "Style de l'infobulle : "
L["opt_headercolour_label"] = "    Couleur de l'en-tête"
L["opt_headercolour_popup"] = "|cffFFDD33MyRolePlay\n|cffFFFFFFVous devez réinitialiser votre interface après avoir changé la couleur de l'en-tête afin que vos changements prennent effet."
L["opt_tt"] = "Infobulles améliorées"
L["opt_tt_tt"] = [[Améliorez vos infobulles avec des informations RP.

Ceci peut être très utile, mais vous pouvez le désactiver si vous n'aimez
pas le style, ou bien si cela cause des problèmes avec vos autres add-ons
qui modifient eux-mêmes les infobulles de joueurs.]]
L["opt_mrpbutton"] = "Afficher le bouton MRP"
L["opt_mrpbutton_tt"]= [[Affiche un bouton marqué «MRP» près du cadre de votre cible
s'ils ont un add-on compatible (MRP, XRP, TRP).

Clic-gauche ouvre leur profil RP.
Clic-droit verrouille ou déverrouille le bouton MRP, permettant de le deplacer sur votre écran.]]
--
L["opt_allowcolours"] = "Utiliser la couleur"
L["opt_allowcolours_tt"]= [[Ceci permet à MyRolePlay d'afficher des couleurs personnalisées
dans les profils et infobulles.

Quand ceci est désactivé, MRP agira comme il le faisait anciennement, laissant tout texte
coloré en blanc.]]
--
L["opt_tooltipclasscolours"] = "Couleur de la classe dans l'infobulle"
L["opt_tooltipclasscolours_tt"]= [[Activer les couleurs de classes dans l'infobulle.

Désactiver les couleurs de classes dans l'infobulle.]]
--
L["opt_showglancepreview"] = "Aperçu de coups d'œil"
L["opt_showglancepreview_tt"]= [[Affiche l'aperçu des coups d'œil quand vous ciblez un autre joueur.]]
--
L["opt_showintooltip_header"] = "Afficher dans l'infobulle..."
--
L["opt_classnames"] = "Classes personnalisées"
L["opt_classnames_tt"]= [[Quand ceci est activé, MRP affichera les classes personnalisées par les joueurs
au lieu des classes par défaut.

Désactivez-le pour retourner aux classes telles que définies par le jeu.]]
--
L["opt_showooc"] = "Info HRP"
L["opt_showooc_tt"]= [[Ceci affiche le contenu du champ d'information HRP sur l'infobulle.

Notez bien que ceci agrandira l'infobulle significativement. Désactivez cette option pour le cacher.]]
--
L["opt_showtarget"] = "Cible du joueur"
L["opt_showtarget_tt"]= [[Ceci affichera la cible du joueur à qui appartient l'infobulle dans ce dernier.]]
--
L["opt_hidettinencounters"] = "Cacher l'infobulle en combat"
L["opt_hidettinencounters_tt"]= [[Ceci cachera les améliorations de l'infobulle fournies
par MRP lorsque vous êtes en combat.

L'infobulle retournera donc à l'apparence par défaut définie par le jeu.]]
--
L["opt_showiconintt"] = "Icônes personnalisées"
L["opt_showiconintt_tt"]= [[Ceci affichera l'icône sélectionnée par le joueur dans son infobulle.]]
--
L["opt_autoplaymusic"] = "Lecture automatique de la musique de profil"
L["opt_autoplaymusic_tt"]= [[Si le joueur a choisi un thème musical pour son profil,
ceci le fera jouer automatiquement quand vous ouvrez le profil en question.]]
--
L["opt_showversion"] = "Info sur la version d'add-on"
L["opt_showversion_tt"]= [[Ceci affichera les add-ons RP en usage par le joueur dans l'infobulle.]]
--
L["opt_showguildnames"] = "Info et rang de guilde"
L["opt_showguildnames_tt"]= [[Ceci affichera le nom de la guilde du joueur, ainsi que son rang dans celle-ci.]]
--
L["opt_maxlinesslider"] = "Nombre de lignes dans l'infobulle"
L["opt_maxlinesslider_tt"]= [[Indiquez le nombre de lignes à montrer dans les sections Actuellement (RP) et HRP.]]
--
L["opt_rpchatnamesay"] = "|cffffffff/dire|r"
L["opt_rpchatnamesay_tt"]= [[Ceci affichera les noms RP en /dire, quand connus et disponibles.

Notez bien que cette option peut occasionnellement vous empêcher de cibler un joueur en utilisant le clic-droit sur leur nom dans le canal de discussion. Si cela se produit, tentez de désactiver et de réactiver l'option, ou faites un /rl.]]
L["opt_rpchatnamewhisper"] = "|cffff80ff/chuchote|r"
L["opt_rpchatnamewhisper_tt"]= [[Ceci affichera les noms RP en /chuchote, quand connus et disponibles.

Notez bien que cette option peut occasionnellement vous prévenir de cibler un joueur en utilisant le clic-droit sur leur nom dans le canal de discussion. Si cela se produit, tentez de désactiver et de réactiver l'option, ou faites un /rl.]]
--
L["opt_rpchatnameemote"] = "|cffff8040/emote|r"
L["opt_rpchatnameemote_tt"]= [[Ceci affichera les noms RP en /emote, quand connus et disponibles.

Notez bien que cette option peut occasionnellement vous prévenir de cibler un joueur en utilisant le clic-droit sur leur nom dans le canal de discussion. Si cela se produit, tentez de désactiver et de réactiver l'option, ou faites un /rl.]]
--
L["opt_rpchatnameyell"] = "|cffff4040/cri|r"
L["opt_rpchatnameyell_tt"]= [[Ceci affichera les noms RP en /cri, quand connus et disponibles.

Notez bien que cette option peut occasionnellement vous prévenir de cibler un joueur en utilisant le clic-droit sur leur nom dans le canal de discussion. Si cela se produit, tentez de désactiver et de réactiver l'option, ou faites un /rl.]]
--
L["opt_rpchatnameparty"] = "|cffaaaaff/groupe|r"
L["opt_rpchatnameparty_tt"]= [[Ceci affichera les noms RP en /groupe, quand connus et disponibles.

Notez bien que cette option peut occasionnellement vous prévenir de cibler un joueur en utilisant le clic-droit sur leur nom dans le canal de discussion. Si cela se produit, tentez de désactiver et de réactiver l'option, ou faites un /rl.]]
--
L["opt_rpchatnameraid"] = "|cffff7f00/raid|r"
L["opt_rpchatnameraid_tt"]= [[Ceci affichera les noms RP en /raid, quand connus et disponibles.

Notez bien que cette option peut occasionnellement vous prévenir de cibler un joueur en utilisant le clic-droit sur leur nom dans le canal de discussion. Si cela se produit, tentez de désactiver et de réactiver l'option, ou faites un /rl.]]

--
L["opt_disp_header"] = "Apparence du profil"
L["opt_biog"] = "Afficher la section de biographie"
L["opt_biog_tt"] = [[Indiquez si vous souhaitez voir la section de biographie dans le profil.

Activez-le si vous préférez avoir davantage d'informations.
Désactivez-le si vous préférez découvrir l'histoire des personnages à travers l'interaction.]]
--
L["opt_traits"] = "Afficher la section de la personnalité"
L["opt_traits_tt"] = [[Afficher ou non la section de personnalité dans le navigateur de profil.]]
--
L["opt_glanceposition_header"] = "Afficher les aperçus à..."
L["glance_position_right"] = "Droit"
L["glance_position_left"] = "Gauche"
--
L["opt_ahunit"] = "Unité de la taille…"
L["opt_awunit"] = "Unité du poids…"
--
L["opt_ac_header"] = "Changer de profil automatiquement quand…"
--
L["opt_formac"] = "Vous changez de forme"

L["opt_formac_tt"] = [[Changez de profil automatiquement quand vous changez de forme.
]]
L["opt_formac_tt_disabled"] = L["opt_formac_tt"] .. [[
(Ce personnage n'a aucune forme spéciale disponible, donc cette option ne fera rien.)]]
L["opt_formac_tt_enabled1"] = L["opt_formac_tt"] .. [[

Nommez le profil exactement comme la forme, comme ci-suit:—
]]
L["opt_formac_tt_suffix"] = [[  (|cffff9090n'incluez pas|r les guillemets; les noms de profil sont |cffff9090sensibles à la casse|r!)

Changer pour votre forme originale changera aussi à votre profil original.

Pour les profils non-Défaut, utilisez «|cffffff00nom-de-profil:forme|r» : (par ex.)
· Sélectionnez «|cffffff00Tuxedo|r» -> changez en worgen -> MRP tentera d'appliquer le profil «|cffffff00Tuxedo:Worgen|r»
]]

L["opt_formac_tt_worgensuffix"] = [[

|cffffa0a0Notez bien : |rMalheureusement, la détection entre les formes d'humain et de worgen n'est pas parfaite (grâce à Blizzard).
Utilisez |cff80c0c0Sombre course|r, |cff80c0c0Ventre à terre|r, ou bien |cff80c0c0entrez en combat|r afin de tenter de le réparer.]]

L["opt_formac_tt_worgen"] = L["opt_formac_tt_enabled1"] .. [[
· Soit |cffffff00worgen|r ou |cffffff00humain|r;
   (choisissez celui que vous considérez non-défaut - vous n'en avez besoin que d'un)
]] .. L["opt_formac_tt_suffix"] .. L["opt_formac_tt_worgensuffix"]

L["opt_formac_tt_worgendruid"] = L["opt_formac_tt_enabled1"] .. [[
· Soit |cffffff00worgen|r ou |cffffff00humain|r;
   (…celui dont vous considérez non-défaut - vous n'en avez besoin que d'un)
· |cffffff00Chat|r;
· |cffffff00Ours|r;
· |cffffff00Voyage|r (ou |cffffff00Guépard|r);
· |cffffff00Vol|r (ou |cffffff00Oiseau|r);
· |cffffff00Aquatique|r” (ou |cffffff00Phoque|r ou |cffffff00Lion de mer|r);
· |cffffff00Sélénien|r” (ou |cffffff00Chouettide|r) (quand possible); et,
· |cffffff00Arbre|r” (quand possible).
]] .. L["opt_formac_tt_suffix"] .. L["opt_formac_tt_worgensuffix"]

L["opt_formac_tt_druid"] = L["opt_formac_tt_enabled1"] .. [[
· |cffffff00Chat|r;
· |cffffff00Ours|r;
· |cffffff00Voyage|r (ou |cffffff00Guépard|r);
· |cffffff00Vol|r (or |cffffff00Oiseau|r);
· |cffffff00Aquatique|r” (or |cffffff00Phoque|r or |cffffff00Lion de mer|r);
· |cffffff00Sélénien|r” (or |cffffff00Chouettide|r) (quand possible); et,
· |cffffff00Arbre|r” (quand possible).
]] .. L["opt_formac_tt_suffix"]

L["opt_formac_tt_shaman"] = L["opt_formac_tt_enabled1"] .. [[
· |cffffff00Loup fantôme|r (ou bien |cffffff00Loup|r).
]] .. L["opt_formac_tt_suffix"]

L["opt_formac_tt_priest"] = L["opt_formac_tt_enabled1"] .. [[
· |cffffff00Ombre|r.
]] .. L["opt_formac_tt_suffix"]

L["opt_formac_tt_worgenpriest"] = L["opt_formac_tt_enabled1"] .. [[
· Soit |cffffff00worgen|r ou |cffffff00humain|r;
   (…celui dont vous considérez non-défaut - vous n'en avez besoin que d'un); et,
· |cffffff00Ombre|r.
(Notez que vous voudriez peut-être avoir |cffffff00Ombre:Humain|r et/ou |cffffff00Ombre:Worgen|r
            (ou bien du sens opposé), puisque vous pouvez être en forme d'ombre
            ET un humain ou worgen en même temps...)
]] .. L["opt_formac_tt_suffix"] .. L["opt_formac_tt_worgensuffix"]

L["opt_formac_tt_warlock"] = L["opt_formac_tt_enabled1"] .. [[
· “|cffffff00Démon|r” (si approprié pour votre spécialisation).
]] .. L["opt_formac_tt_suffix"]

L["opt_formac_tt_worgenwarlock"] = L["opt_formac_tt_enabled1"] .. [[
· Soit “|cffffff00Worgen|r” ou “|cffffff00Human|r”;
   (…celui dont vous considérez non-défaut - vous n'en avez besoin que d'un); et,
· “|cffffff00Démon|r” (si approprié pour votre spécialisation).
]] .. L["opt_formac_tt_suffix"] .. L["opt_formac_tt_worgensuffix"]
--
L["opt_equipac"] = "Vous changez d'équipement |cffff9090(beta)|r"
L["opt_equipac_tt"] = [[Ceci changera votre profil quand vous changez d'équipement.

Nommez le profil par l'équipement que vous désirez (|cffff9090sensible à la casse|r).

Très utile pour changer votre description quand vous changez votre tenue de RP.]]

-- Races - overrides for RaceEn, second return from UnitRace(), to localise them
L["NightElf"] = "Elfe de la nuit"
L["Scourge"] = "Mort-vivant"
L["VoidElf"] = "Elfe du vide"
L["LightforgedDraenei"] = "Draeneï sancteforge"
L["BloodElf"] = "Elfe de sang"
L["HighmountainTauren"] = "Tauren de Haut-Roc"
L["DarkIronDwarf"] = "Nain sombrefer"
L["MagharOrc"] = "Orc mag'har"
L["Draenei"] = "Draeneï"
L["Nightborne"] = "Sacrenuit"
L["Human"] = "Humain"
L["Orc"] = "Orc"
L["Dwarf"] = "Nain"
L["Gnome"] = "Gnome"
L["Worgen"] = "Worgen"
L["Tauren"] = "Tauren"
L["Troll"] = "Troll"
L["Goblin"] = "Gobelin"
L["Pandaren"] = "Pandaren"
L["KulTiran"] = "Humain de Kul Tiras"
L["ZandalariTroll"] = "Troll zandalari"
L["MAGE"] = "Mage"
L["WARRIOR"] = "Guerrier"
L["PALADIN"] = "Paladin"
L["HUNTER"] = "Chasseur"
L["ROGUE"] = "Voleur"
L["PRIEST"] = "Prêtre"
L["DEATHKNIGHT"] = "Chevalier de la mort"
L["DEMONHUNTER"] = "Chasseur de démons"
L["SHAMAN"] = "Chaman"
L["WARLOCK"] = "Démoniste"
L["MONK"] = "Moine"
L["DRUID"] = "Druide"

-- All other strings for enGB are as hardcoded
