# Setup Workflow — Guide d'initialisation (Agent-Agnostic)

> Routine standard pour initialiser le profil de recherche d'emploi.
> Exécutable par n'importe quel LLM via un simple prompt d'entrée.
> Pas de dépendance à un slash command ou un agent spécifique.

---

## COMMENT LANCER LE SETUP

L'utilisateur peut déclencher cette routine de plusieurs manières :
- Claude Code : `/job-hunt setup`
- Gemini CLI / autre agent MCP : « Lance le setup de recherche d'emploi » ou « Configure mon profil de candidature »
- Tout prompt contenant : « setup », « configurer », « commencer ma recherche d'emploi »

## PRINCIPE

Le setup est **séquentiel** : une question à la fois, attendre la réponse, puis passer à la suite.
Le setup est **reprenable** : au lancement, vérifier ce qui est déjà configuré et reprendre là où ça s'est arrêté.

---

## ÉTAPE 1 — Intention (1 question)

**Pose exactement cette question :**

> « Quel type de poste tu cherches ? En une phrase : le type (alternance / stage / CDI / CDD), le secteur, et la zone géographique si tu as une préférence. »

**Traitement :**
- Extrais : type de contrat, secteur, zone géo, durée (si mentionnée)
- Sauvegarde dans un fichier de profil (`job_hunt_profile.md`) ou en mémoire de l'agent

---

## ÉTAPE 2 — Connexion Gmail (MCP)

### 2a — Recommander une adresse dédiée

> « Conseil : utilise une adresse Gmail dédiée à tes candidatures, séparée de ton perso. Idéalement prénom.nom@gmail.com — propre et pro. Tu as déjà une adresse propre, ou tu veux en créer une ? »

- Si besoin d'en créer une → guide vers https://accounts.google.com/signup
- Note l'adresse choisie dans la config

### 2b — Configurer le serveur MCP Gmail

La configuration dépend de l'agent utilisé :

**Pour Claude Code :**
```bash
npx @gongrzhe/server-gmail-autoauth-mcp auth
claude mcp add gmail -- npx -y @gongrzhe/server-gmail-autoauth-mcp
```

**Pour Gemini CLI / agent MCP standard :**
Utilise le fichier template `config/mcp_gmail_template.json` et adapte-le au format de configuration de ton agent. Voir le README pour les instructions détaillées.

**Vérification :** tente de lire le dernier email reçu via les outils MCP Gmail. Si ça répond → « Gmail connecté. »

---

## ÉTAPE 3 — Documents (1 question)

> « Donne-moi le chemin du dossier contenant tes documents de candidature : CV, un exemple de mail que tu envoies, et ta lettre de motivation. »

**Traitement :**
1. Lis chaque document fourni
2. Extrais :
   - Le style d'écriture (tutoiement/vouvoiement, ton, registre)
   - Le niveau d'études, la formation, les compétences clés
   - La structure du mail type et de la lettre de motivation
3. Sauvegarde une synthèse dans `job_hunt_style.md`
4. Confirme : « J'ai analysé tes documents. [Résumé 1 ligne]. »

---

## ÉTAPE 3 bis — Cadrage de la cible (1 confirmation)

Maintenant que le CV est lu, **propose** une cible concrète (déduis, ne pose pas 5 questions) :

> « Voilà ce que je vais viser :
>  - Postes : [intitulés déduits du profil]
>  - Structures : [types d'entreprises/organisations]
>  - Zone : [zone géographique]
>  Je corrige quelque chose, ou je lance la recherche sur cette base ? »

- À la validation → sauvegarde dans `job_hunt_target.md`
- **La prospection ne démarre jamais sans cette cible validée.**

---

## ÉTAPE 4 — Quota journalier (1 question)

> « Combien de candidatures par jour ? (recommandé : 15-25 pour rester sous les radars anti-spam) »

- Si > 50 → avertis du risque de blocage Gmail
- Rappelle le plafond dur : max 40/jour les 30 premiers jours
- Sauvegarde le quota

---

## ÉTAPE 4 bis — Mode d'envoi (1 question)

> « Niveau d'autonomie pour l'envoi ?
>  1) Revue — je valide chaque envoi (recommandé)
>  2) Semi-auto — envoi auto des adresses vérifiées, je valide les devinées
>  3) Autonomie complète — tout en auto (risque de spam si adresses devinées) »

- Sauvegarde `mode_envoi` dans la config
- Si choix 3 → avertis en une ligne du risque

---

## ÉTAPE 5 — État actuel (1 question, optionnelle)

> « Tu as déjà contacté des employeurs ? Si oui, donne le fichier de suivi (Excel ou liste). Sinon tape "non". »

- Si oui : importe les données existantes dans le tracker
- Si non : continue

---

## ÉTAPE 6 — Créer le tracker Excel

Génère le tracker avec le script fourni :

```bash
python3 templates/create_tracker.py "<chemin>/suivi_candidatures.xlsx"
```

Le script crée 3 onglets (Suivi Candidatures, Ne pas contacter, Stats) avec écriture atomique.

Colonnes du suivi (dates ISO AAAA-MM-JJ) :

| Col | Contenu |
|---|---|
| A | # |
| B | Entreprise |
| C | Nom |
| D | Prénom |
| E | Poste |
| F | Email |
| G | Email vérifié (`Vérifié` / `Deviné` / `Invalide`) |
| H | LinkedIn |
| I | Date d'envoi |
| J | Statut |
| K | Date relance 1 |
| L | Date relance 2 |
| M | Commentaires |

---

## ÉTAPE 7 — Activation de la boucle autonome (optionnel)

> « Je peux tourner en autonomie toutes les 5h pour : chercher des contacts, envoyer tes candidatures, vérifier les réponses et relancer. Tu veux activer ça ? (o/n) »

**Si oui :**
- Configure un mécanisme de répétition selon l'agent :
  - Claude Code : scheduled task avec le prompt de `skill/prompts/loop.md`
  - Gemini CLI / autre : l'utilisateur configure un cron ou relance manuellement
- Confirme : « Boucle activée. »

**Si non :**
- Confirme : « OK, tout est en mode manuel. »

---

## MESSAGE FINAL

> « Setup terminé. Profil enregistré, Gmail connecté, tracker créé, mode = [mode_envoi].
> Pour voir tes stats : demande le "status". Pour suspendre : demande "pause". »

---

## FICHIERS DE CONFIGURATION PRODUITS

| Fichier | Contenu |
|---|---|
| `job_hunt_profile.md` | Type de contrat, secteur, zone géo |
| `job_hunt_target.md` | Cible validée : intitulés, structures, zone, exclusions |
| `job_hunt_config.md` | Quota, mode_envoi, délais, chemin tracker, adresse Gmail |
| `job_hunt_style.md` | Style d'écriture, compétences, formation (extrait des documents) |
| `suivi_candidatures.xlsx` | Tracker Excel avec 3 onglets |
