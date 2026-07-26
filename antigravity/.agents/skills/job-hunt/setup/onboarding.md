# Onboarding — Guide pas à pas (version Antigravity)

## Principe

L'onboarding est séquentiel. L'agent pose UNE question à la fois, attend la réponse, puis passe à
l'étape suivante. Aucune étape n'est sautée. Si une étape échoue, l'agent debug avant de continuer.

**Reprenable.** Au lancement, l'agent vérifie ce qui est déjà fait (fichiers `memoire/`, config,
tracker) et reprend où ça s'est arrêté, sans reposer une question déjà répondue. Utile car
l'installation du MCP Gmail (étape 2) peut demander de redémarrer Antigravity : au retour,
l'utilisateur relance `/job-hunt-setup` et l'agent enchaîne à l'étape suivante en une ligne
(« On reprend : il reste X, Y, Z. »).

## Étape 0 — Prérequis (en premier, obligatoire)

Avant toute question, vérifie l'environnement de l'utilisateur. Ne suppose rien d'installé.
Applique `setup/prerequisites.md` : détecte l'OS, teste Node.js / npx / Python / Git, guide
l'installation de ce qui manque selon l'OS, fais **rouvrir le terminal + Antigravity** après
installation (PATH), puis re-teste. On ne continue que quand tout est vert.

Présente le résultat simplement : « Vérif PC : Node ✅ Python ✅ — on continue » ou « Il manque
Node.js, installe-le avec [commande], rouvre le terminal, et redis-moi « c'est bon ». »

## Étape 1 — Profil

**Question exacte :**
> « Quel type de poste tu cherches ? Dis-moi en une phrase : le type (alternance / stage / CDI / CDD), le secteur, et la zone géographique si tu as une préférence. »

**Traitement :**
- Parse la réponse → extrait : `type_contrat`, `secteur`, `zone_geo`, `duree` (si mentionnée)
- Sauvegarde dans `memoire/job_hunt_profile.md` :
  ```
  # Profil de recherche d'emploi

  Type : [alternance/stage/CDI/CDD]
  Secteur : [secteur]
  Zone géo : [zone ou "France entière"]
  Durée : [durée ou "non spécifiée"]
  ```

## Étape 1 bis — Niveau d'autonomie d'Antigravity

À faire AVANT le reste : ça évite des dizaines de validations pendant tout le setup et les cycles.
Lis `setup/autonomie.md`.

**Ce que dit l'agent :**
> « Pour que je puisse travailler sans te demander une validation à chaque étape, on règle
>  Antigravity une bonne fois : politique de revue + une courte liste de commandes autorisées
>  (Python, npx…) + quelques interdits de sécurité. Ça se fait dans les paramètres, je te guide
>  clic par clic. On le fait maintenant, ou tu préfères tout valider à la main (mode prudent) ? »

**Traitement si l'utilisateur accepte :**
- Guide-le dans les paramètres d'Antigravity selon `setup/autonomie.md` (politique de revue,
  listes d'autorisation/interdiction du terminal). La désactivation des outils Gmail de
  suppression se fera à l'étape 2, une fois le serveur MCP installé.
- Confirme en une ligne, puis continue le setup (pas de redémarrage nécessaire pour ces réglages).

**Traitement si mode prudent :**
- OK, mais préviens en une ligne : « Chaque cycle te demandera pas mal de validations. Tu pourras
  changer d'avis à tout moment dans les paramètres. »

## Étape 2 — Adresse Gmail dédiée + installation MCP

### 2a — Recommander une adresse dédiée (AVANT de demander laquelle)

**Ce que dit l'agent (avant toute question sur l'adresse) :**
> « Conseil : crée une adresse Gmail **dédiée à tes candidatures**, séparée de ton perso. Idéalement
>  ton **prénom.nom@gmail.com** (ou prenom.nom + un chiffre si pris) — propre, pro et facile à lire
>  pour un recruteur. Évite les vieilles adresses du style ptitchat_2008. Tu as déjà une adresse
>  propre, ou tu veux en créer une maintenant ? »

- Si l'utilisateur doit en créer une → guide-le : https://accounts.google.com/signup, format
  `prenom.nom`, puis reviens ici.
- Note l'adresse retenue dans `memoire/job_hunt_config.md` (`gmail_address`).
- Pourquoi : délivrabilité (une adresse claire passe mieux), image pro, et séparation nette entre
  recherche d'emploi et vie privée.

### 2b — Installation du serveur MCP Gmail

> « On connecte cette adresse à Antigravity. »

Puis lis et suis le fichier `setup/gmail-setup.md` pas à pas : auth Google (`npx ... auth`),
ajout du bloc `gmail` dans `mcp_config.json` (via … → MCP Servers → Manage MCP Servers →
View raw config), Refresh/redémarrage, puis **désactivation des outils de suppression définitive**
dans le panneau du serveur `gmail`.

**Vérification :**
- Utilise le MCP Gmail pour lire le dernier email reçu
- Si ça marche → « Gmail connecté. »
- Si erreur → debug (vérifie le JSON de config, relance l'auth, variante Windows `cmd /c npx`)

## Étape 3 — Documents

**Question exacte :**
> « Donne-moi le chemin du dossier contenant tes documents de candidature : CV, un exemple de mail que tu envoies, et ta lettre de motivation. »

**Traitement :**
1. Liste les fichiers du dossier fourni
2. Identifie automatiquement : CV (pdf), mail (pdf/txt/md), lettre de motivation (pdf/docx)
3. Lis chaque document
4. Extrais et sauvegarde dans `memoire/job_hunt_style.md` :
   ```
   # Style d'écriture et templates de l'utilisateur

   ## Registre
   [vouvoiement/tutoiement]

   ## Ton
   [formel / semi-formel / direct]

   ## Structure mail type
   [structure extraite]

   ## Structure LM type
   [structure extraite]

   ## Compétences clés (extraites du CV)
   - [compétence 1]
   - [compétence 2]
   - ...

   ## Formation
   [niveau + diplôme + école]

   ## Expériences pertinentes
   - [expérience 1]
   - [expérience 2]
   ```
5. Confirme : « J'ai analysé tes documents. [Résumé 1 ligne du profil extrait]. »

## Étape 3 bis — Cadrage de la cible (1 confirmation)

Maintenant que le CV est lu, l'agent **propose** une cible concrète (il déduit, il n'interroge pas) :
intitulés de poste à viser chez l'employeur, type de contact à privilégier (le responsable
opérationnel du service, pas le standard / RH générique), type de structures, zone/rayon, exclusions.

**Présentation compacte + une seule question :**
> « Voilà ce que je vais viser :
>  • Postes : [intitulés]
>  • Structures : [types]
>  • Zone : [zone]
>  Je corrige quelque chose, ou je lance la recherche sur cette base ? »

**Traitement :**
- À la validation (ou correction), sauvegarde la cible dans `memoire/job_hunt_target.md`.
- Cette cible est le socle de toute la prospection : `prompts/prospect.md` refuse de tourner sans elle.
- Objectif : contacter les bonnes personnes dès le départ, pas un envoi à l'aveugle.

## Étape 4 — Quota

**Question exacte :**
> « Combien de candidatures par jour ? (recommandé : 15-25 pour rester sous les radars anti-spam) »

**Traitement :**
- Si > 50 → avertis : « Au-delà de 50/jour, Gmail risque de bloquer ton compte. Je recommande 25 max. »
- Rappelle le plafond dur : `min(quota, 40)`/jour les 30 premiers jours (cf. SECURITY.md §4)
- Sauvegarde dans `memoire/job_hunt_config.md`

## Étape 4 bis — Mode d'envoi

**Question exacte :**
> « Niveau d'autonomie pour l'envoi ? 1) Revue (tu valides tout — recommandé) · 2) Semi-auto (auto sur adresses vérifiées) · 3) Autonomie complète »

**Traitement :**
- Sauvegarde `mode_envoi` (`revue` / `semi-auto` / `autonomie`) dans `memoire/job_hunt_config.md`
- Si choix 3 → avertis en une ligne : « Risque : adresses devinées → bounces → spam → suspension du compte. »

## Étape 5 — État actuel

**Question exacte :**
> « Tu as déjà contacté des employeurs ? Si oui, donne le fichier de suivi (Excel ou liste). Sinon tape "non". »

**Traitement si oui :**
1. Lis le fichier fourni (Excel, CSV, ou texte)
2. Mappe les colonnes sur la structure du tracker
3. Importe les contacts avec leurs statuts existants
4. Confirme : « X contacts importés dont Y déjà envoyés. »

**Traitement si non :**
- Continue à l'étape suivante

## Étape 6 — Créer le tracker

1. Génère le tracker avec le script (ne l'écris pas à la main) :
   ```bash
   python3 templates/create_tracker.py "<dossier>/suivi_candidatures.xlsx"
   ```
   Colonnes : #, Entreprise, Nom, Prénom, Poste, Email, **Email vérifié**, LinkedIn,
   Date envoi (ISO), Statut, Relance 1, Relance 2, Commentaires. 3 onglets (Suivi, Ne pas contacter, Stats).
2. Si import fait en étape 5 → ajoute les lignes via openpyxl + `safe_save` (écriture atomique),
   en renseignant `Email vérifié` = `Vérifié`/`Deviné` selon la source.
3. Sauvegarde `tracker_path` (et `cv_path`) dans `memoire/job_hunt_config.md`.
4. Confirme : « Tracker créé : [chemin du fichier] »

## Étape 7 — Rythme des cycles

**Ce que dit l'agent :**
> « Antigravity ne se lance pas tout seul à heure fixe (pas de planificateur intégré). Pour faire
>  tourner la machine : tape `/job-hunt-loop` 1 à 2 fois par jour — je vérifie ta boîte mail,
>  je prospecte, j'envoie selon ton quota et je relance, tout seul dans le même cycle.
>  Matin + fin d'après-midi, c'est l'idéal. Ça marche pour toi ? »

**Traitement :**
- Initialise dans `memoire/job_hunt_config.md` : `date_debut` = aujourd'hui (ISO),
  `compteur_envois_du_jour` = 0.
- Rappelle : en mode `revue`, le cycle prépare la file mais rien ne part sans validation.

## Message final

> « Setup terminé. Ton profil est enregistré, Gmail connecté, tracker créé. Lance /job-hunt-loop 1-2 fois par jour, et /job-hunt-status à tout moment pour voir où tu en es. »
