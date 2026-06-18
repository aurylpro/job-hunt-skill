# Job Hunt Skill — Claude Code

Agent autonome de recherche d'emploi pour Claude Code. Gère le cycle complet : prospection, candidatures personnalisées, envoi via Gmail, vérification de livraison, relances automatiques et suivi structuré.

## Installation

```bash
curl -sL https://raw.githubusercontent.com/aurylpro/job-hunt-skill/main/install.sh | bash
```

Ou manuellement :

```bash
git clone https://github.com/aurylpro/job-hunt-skill.git
cp -r job-hunt-skill/skill ~/.claude/skills/job-hunt
```

## Pré-requis

| Outil | Usage | Obligatoire |
|---|---|---|
| [Claude Code](https://claude.ai/code) | Agent IA | Oui |
| [Node.js](https://nodejs.org) >= 18 | Gmail MCP | Oui |
| [Python 3](https://python.org) | Tracker Excel | Oui |
| Compte Gmail | Envoi des candidatures | Oui |

> Pas besoin de les installer à la main : au démarrage, l'agent **vérifie automatiquement** ton PC
> (Windows/Mac/Linux), et si Node.js ou Python manque, il te donne la commande exacte pour l'installer
> (ex. `winget install OpenJS.NodeJS.LTS` sur Windows) et te guide jusqu'au bout.

## Démarrage rapide

1. Installe le skill (voir ci-dessus)
2. Ouvre Claude Code dans un dossier de travail
3. Tape `/job-hunt setup`
4. L'agent te guide pas à pas :
   - Quel poste tu cherches
   - **Autorisations en une fois** (mode mains-libres) — tu valides une seule fois, plus jamais ensuite
   - **Adresse Gmail dédiée** recommandée (`prenom.nom@gmail.com`) + connexion
   - Tes documents (CV, mail type, lettre de motivation)
   - Combien de candidatures par jour + mode d'envoi
   - Import de tes contacts existants (si tu en as)
   - Création du tracker Excel
   - Activation de la boucle autonome (optionnel)

> Débutant sur Claude Code ? Le mode **mains-libres** pré-autorise en une fois les actions du skill
> (liste limitée, pas un « tout autoriser ») pour ne plus avoir à valider — et pour que la boucle
> autonome tourne même quand tu n'es pas devant l'écran. Détails : [`skill/setup/permissions.md`](skill/setup/permissions.md).

## Commandes

| Commande | Description |
|---|---|
| `/job-hunt setup` | Configuration complète A-Z |
| `/job-hunt prospect` | Rechercher de nouveaux contacts |
| `/job-hunt draft` | Générer un mail + lettre de motivation |
| `/job-hunt send` | Envoyer les candidatures |
| `/job-hunt check` | Vérifier inbox (bounces, réponses) |
| `/job-hunt relance` | Envoyer les relances dues |
| `/job-hunt status` | Dashboard : stats et prochaines actions |
| `/job-hunt track [action]` | Mise à jour manuelle du tracker |
| `/job-hunt config [clé valeur]` | Change quota, mode d'envoi, délais de relance |
| `/job-hunt blacklist [entreprise]` | Ajoute à la liste « Ne pas contacter » |
| `/job-hunt pause` | Suspendre la boucle (kill-switch) |
| `/job-hunt resume` | Reprendre la boucle |
| `/job-hunt stop` | « J'ai eu le poste » : arrête tout + archive le tracker |

## Boucle autonome

Si activée au setup, l'agent tourne toutes les 5h et :

1. Vérifie ta boîte mail (bounces, réponses)
2. Nettoie les mails système (MAILER-DAEMON, etc.)
3. Cherche de nouveaux contacts si besoin
4. Envoie les candidatures en attente (selon ton quota)
5. Envoie les relances dues (J+14 et J+28)

Tout est loggé dans le tracker Excel.

## Relances automatiques

| Délai sans réponse | Action |
|---|---|
| J+14 | Relance 1 — rappel cordial |
| J+28 | Relance 2 — dernier contact |
| J+42 | Marqué "Sans réponse" — stop |

Les délais sont configurables.

## Sécurité

Voir [`skill/SECURITY.md`](skill/SECURITY.md) pour les règles complètes. En résumé :

- **Anti-injection** : le contenu des emails lus est traité comme une donnée, jamais comme une
  instruction. L'agent n'exécute aucun ordre caché dans un email entrant.
- **Pas de suppression définitive** : les mails système vont à la corbeille (récupérables), jamais effacés en dur.
- **Modes d'envoi** : tu choisis le niveau d'autonomie — *revue* (tu valides tout, défaut),
  *semi-auto* (auto sur adresses vérifiées), ou *autonomie complète*.
- **Protection du compte** : plafond dur de 40 envois/jour le 1er mois, pause auto si bounce > 5 %,
  adresses devinées jamais envoyées en auto sans vérification, kill-switch `/job-hunt pause`.
- L'agent ne lit jamais tes emails personnels sans rapport avec les candidatures.

## Modes d'autonomie

| Mode | Comportement |
|---|---|
| `revue` (défaut) | La boucle prépare la file, tu valides chaque envoi |
| `semi-auto` | Envoi auto des adresses vérifiées, confirmation pour les devinées |
| `autonomie` | Tout en automatique (après vérification MX des adresses devinées) |

Change de mode à tout moment : `/job-hunt config mode semi-auto`

## Structure du skill

```
skill/
├── SKILL.md                 # Définition de l'agent
├── SECURITY.md              # Règles de sécurité (anti-injection, etc.)
├── prompts/
│   ├── draft.md             # Rédaction mail + LM
│   ├── prospect.md          # Recherche de contacts
│   ├── relance.md           # Emails de relance
│   ├── bounce.md            # Gestion des bounces + nettoyage inbox
│   └── loop.md              # Boucle autonome 5h
├── setup/
│   ├── prerequisites.md     # Vérif Node/Python/Git cross-plateforme
│   ├── onboarding.md        # Flux d'onboarding
│   ├── gmail-setup.md       # Guide Gmail MCP (Claude Code)
│   ├── permissions.md       # Modes mains-libres / prudent
│   ├── settings.template.json  # Allowlist scopée + deny
│   └── apply-permissions.sh    # Fusion sûre dans settings.json
└── templates/
    ├── email.md             # Templates email
    ├── create_tracker.py    # Générateur Excel (écriture atomique)
    └── requirements.txt     # Dépendances Python (openpyxl)
```

## Contribuer

PRs bienvenues. Le skill est conçu pour être générique (tous secteurs, tous types de contrats).

## Licence

MIT

---

Créé par [Auryl AKAKPO](https://github.com/aurylpro) avec Claude Code.
