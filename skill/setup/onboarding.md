# Onboarding — Guide pas à pas

## Principe

L'onboarding est séquentiel. L'agent pose UNE question à la fois, attend la réponse, puis passe à
l'étape suivante. Aucune étape n'est sautée. Si une étape échoue, l'agent debug avant de continuer.

**Reprenable.** Au lancement, l'agent vérifie ce qui est déjà fait (mémoire, config, tracker) et
reprend où ça s'est arrêté, sans reposer une question déjà répondue. Utile car l'étape autorisations
(1 bis) impose de relancer Claude Code : au retour, l'utilisateur retape `/job-hunt setup` et l'agent
enchaîne à l'étape suivante en une ligne (« On reprend : il reste X, Y, Z. »).

## Étape 0 — Prérequis (en premier, obligatoire)

Avant toute question, vérifie l'environnement de l'utilisateur. Ne suppose rien d'installé.
Applique `setup/prerequisites.md` : détecte l'OS, teste Node.js / npx / Python / Git, guide
l'installation de ce qui manque selon l'OS, fais **rouvrir le terminal + Claude Code** après
installation (PATH), puis re-teste. On ne continue que quand tout est vert.

Présente le résultat simplement : « Vérif PC : Node ✅ Python ✅ — on continue » ou « Il manque
Node.js, installe-le avec [commande], rouvre le terminal, et redis-moi « c'est bon ». »

## Étape 1 — Profil

**Question exacte :**
> « Quel type de poste tu cherches ? Dis-moi en une phrase : le type (alternance / stage / CDI / CDD), le secteur, et la zone géographique si tu as une préférence. »

**Traitement :**
- Parse la réponse → extrait : `type_contrat`, `secteur`, `zone_geo`, `duree` (si mentionnée)
- Sauvegarde dans `job_hunt_profile.md` :
  ```
  ---
  name: job-hunt-profile
  description: "Profil de recherche d'emploi de l'utilisateur"
  metadata:
    type: project
  ---
  Type : [alternance/stage/CDI/CDD]
  Secteur : [secteur]
  Zone géo : [zone ou "France entière"]
  Durée : [durée ou "non spécifiée"]
  ```

## Étape 1 bis — Mode d'autorisation (mains-libres / prudent)

À faire AVANT le reste : ça évite des dizaines de validations pendant tout le setup et c'est
indispensable pour que la boucle autonome tourne sans personne devant l'écran. Lis `setup/permissions.md`.

**Question exacte :**
> « Pour que je puisse travailler (et tourner en autonomie toutes les 5h sans te bloquer), je
>  peux pré-autoriser **une seule fois** une liste précise d'actions (lire/écrire des fichiers,
>  Python, Gmail, recherche web). Tu ne revalideras plus rien ensuite.
>  1) Mains-libres (recommandé) · 2) Prudent (tu valides chaque action) »

**Traitement si 1 (mains-libres) :**
- Explique en une phrase que c'est une liste *limitée* (pas un "tout autoriser") qui sert aussi
  de garde-fou, et qu'une sauvegarde est faite.
- Applique : `bash setup/apply-permissions.sh setup/settings.template.json`
- Dis : « Permissions posées + sauvegarde faite. **Relance Claude Code**, puis retape /job-hunt setup
  pour continuer. » (le redémarrage active les permissions)

**Traitement si 2 (prudent) :**
- Si l'utilisateur veut quand même la boucle autonome → préviens : « En mode prudent, la boucle se
  bloquera en ton absence sur les validations. Le mode mains-libres est nécessaire pour l'autonomie. »

## Étape 2 — Adresse Gmail dédiée + installation MCP

### 2a — Recommander une adresse dédiée (AVANT de demander laquelle)

**Ce que dit l'agent (avant toute question sur l'adresse) :**
> « Conseil : crée une adresse Gmail **dédiée à tes candidatures**, séparée de ton perso. Idéalement
>  ton **prénom.nom@gmail.com** (ou prenom.nom + un chiffre si pris) — propre, pro et facile à lire
>  pour un recruteur. Évite les vieilles adresses du style ptitchat_2008. Tu as déjà une adresse
>  propre, ou tu veux en créer une maintenant ? »

- Si l'utilisateur doit en créer une → guide-le : https://accounts.google.com/signup, format
  `prenom.nom`, puis reviens ici.
- Note l'adresse retenue dans `job_hunt_config.md` (`gmail_address`).
- Pourquoi : délivrabilité (une adresse claire passe mieux), image pro, et séparation nette entre
  recherche d'emploi et vie privée.

### 2b — Installation du connecteur

> « On connecte cette adresse à Claude Code. »

Puis lis et suis le fichier `setup/gmail-setup.md` pas à pas (auth Google + `claude mcp add`).

**Vérification :**
- Utilise le Gmail MCP pour lire le dernier email reçu
- Si ça marche → « Gmail connecté. »
- Si erreur → debug (vérifie la config, relance l'auth)

## Étape 3 — Documents

**Question exacte :**
> « Donne-moi le chemin du dossier contenant tes documents de candidature : CV, un exemple de mail que tu envoies, et ta lettre de motivation. »

**Traitement :**
1. Liste les fichiers du dossier fourni
2. Identifie automatiquement : CV (pdf), mail (pdf/txt/md), lettre de motivation (pdf/docx)
3. Lis chaque document
4. Extrais et sauvegarde dans `job_hunt_style.md` :
   ```
   ---
   name: job-hunt-style
   description: "Style d'écriture et templates de l'utilisateur pour les candidatures"
   metadata:
     type: project
   ---
   
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
- À la validation (ou correction), sauvegarde la cible dans `job_hunt_target.md`.
- Cette cible est le socle de toute la prospection : `prompts/prospect.md` refuse de tourner sans elle.
- Objectif : contacter les bonnes personnes dès le départ, pas un envoi à l'aveugle.

## Étape 4 — Quota

**Question exacte :**
> « Combien de candidatures par jour ? (recommandé : 15-25 pour rester sous les radars anti-spam) »

**Traitement :**
- Si > 50 → avertis : « Au-delà de 50/jour, Gmail risque de bloquer ton compte. Je recommande 25 max. »
- Rappelle le plafond dur : `min(quota, 40)`/jour les 30 premiers jours (cf. SECURITY.md §4)
- Sauvegarde dans `job_hunt_config.md`

## Étape 4 bis — Mode d'envoi

**Question exacte :**
> « Niveau d'autonomie pour l'envoi ? 1) Revue (tu valides tout — recommandé) · 2) Semi-auto (auto sur adresses vérifiées) · 3) Autonomie complète »

**Traitement :**
- Sauvegarde `mode_envoi` (`revue` / `semi-auto` / `autonomie`) dans `job_hunt_config.md`
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
3. Sauvegarde `tracker_path` (et `cv_path`) dans `job_hunt_config.md`.
4. Confirme : « Tracker créé : [chemin du fichier] »

## Étape 7 — Activer la boucle

**Ce que dit l'agent :**
> « Je peux tourner en autonomie toutes les 5h pour : chercher des contacts, envoyer tes candidatures, vérifier les réponses et relancer. Tu veux activer ça ? (o/n) »

**Si oui :**
- Crée un scheduled task avec le prompt de `prompts/loop.md`
- Fréquence : toutes les 5h
- Confirme : « Boucle activée. Prochain cycle dans 5h. »

**Si non :**
- Confirme : « OK, tout est en mode manuel. Utilise /job-hunt send pour envoyer. »

## Message final

> « Setup terminé. Ton profil est enregistré, Gmail connecté, tracker créé. Tape /job-hunt status à tout moment pour voir où tu en es. »
