# Job Hunt Skill — version Google Antigravity

Portage du skill job-hunt de Claude Code vers **Google Antigravity**. Toute la logique métier
(personnalisation des candidatures, critères de prospection, ton des messages, règles de
sécurité, quotas Gmail) est identique à la version Claude Code — seul « l'emballage » change.

## 1. Où placer chaque fichier

Antigravity travaille dans un **dossier de projet** (le dossier que tu ouvres dans Antigravity).
Crée un dossier dédié, par exemple `Documents/recherche-emploi/`, puis copie dedans le contenu
de ce dossier `antigravity/` :

| Fichier / dossier | Où le mettre | À quoi ça sert |
|---|---|---|
| `AGENTS.md` | **Racine** de ton dossier de projet | Instructions permanentes de l'agent (lu automatiquement par Antigravity) |
| `.agents/rules/job-hunt-securite.md` | `.agents/rules/` dans ton projet | Règles de sécurité toujours actives (anti-injection, quotas, corbeille) |
| `.agents/skills/job-hunt/` | `.agents/skills/` dans ton projet | Le skill complet : SKILL.md, prompts, setup, templates |
| `.agents/workflows/*.md` | `.agents/workflows/` dans ton projet | Les commandes `/job-hunt-...` (tapées dans le panneau Agent) |
| `mcp_config.json` | **PAS dans le projet** — voir section 3 | Connexion au serveur MCP Gmail |

En clair : tout le dossier `.agents/` et le fichier `AGENTS.md` vont **tels quels** à la racine
de ton dossier de projet. La copie la plus simple :

```bash
# macOS / Linux (adapte les chemins)
cp -r antigravity/.agents antigravity/AGENTS.md ~/Documents/recherche-emploi/
```

Sous Windows : copie-colle les mêmes éléments dans l'Explorateur (active « Afficher les éléments
masqués » pour voir le dossier `.agents`).

> Note : Antigravity lit `.agents/` (et garde une compatibilité avec l'ancien nom `.agent/`).
> Si tu veux le skill disponible dans **tous** tes projets, tu peux aussi mettre le contenu de
> `.agents/skills/` dans `~/.gemini/antigravity/skills/` — mais pour débuter, le dossier de
> projet suffit.

Deux choses se créent ensuite toutes seules à l'usage : le dossier `memoire/` (profil, cible,
config, log de l'agent) et le fichier `job-hunt.STOP` (kill-switch, créé par `/job-hunt-pause`).

## 2. Démarrage

1. Ouvre ton dossier de projet dans Antigravity
2. Dans le panneau Agent, tape `/job-hunt-setup`
3. L'agent te guide pas à pas (prérequis PC, profil, autonomie, Gmail, documents, quota, tracker)

Les commandes disponibles sont les mêmes qu'avant, avec un tiret au lieu de l'espace :
`/job-hunt setup` devient **`/job-hunt-setup`**, `/job-hunt send` devient **`/job-hunt-send`**, etc.

## 3. Connexion MCP Gmail

Le même serveur Gmail que la version Claude Code fonctionne avec Antigravity
(**GongRzhe/Gmail-MCP-Server**). Deux étapes :

### a) Authentification Google (une seule fois, dans un terminal)

```bash
npx @gongrzhe/server-gmail-autoauth-mcp auth
```

Une fenêtre Google s'ouvre : connecte-toi avec ton adresse de candidatures et accepte les
permissions Gmail. (Si la commande réclame un fichier `gcp-oauth.keys.json`, suis le README du
dépôt https://github.com/GongRzhe/Gmail-MCP-Server pour le créer, puis relance.)

### b) Déclarer le serveur dans Antigravity

Dans Antigravity : panneau Agent → menu **…** → **MCP Servers** → **Manage MCP Servers** →
**View raw config**. Le fichier `mcp_config.json` s'ouvre. Ajoute le bloc `gmail` (contenu du
fichier `mcp_config.json` fourni ici) :

```json
{
  "mcpServers": {
    "gmail": {
      "command": "npx",
      "args": ["-y", "@gongrzhe/server-gmail-autoauth-mcp"]
    }
  }
}
```

⚠️ Si le fichier contient déjà d'autres serveurs, ajoute seulement l'entrée `"gmail": {...}`
dans l'objet `mcpServers` existant (attention aux virgules), ne remplace pas tout le fichier.

Emplacement du fichier si tu préfères l'ouvrir à la main :
- **Windows** : `C:\Users\<TON_NOM>\.gemini\antigravity\mcp_config.json`
- **macOS / Linux** : `~/.gemini/antigravity/mcp_config.json`
- Selon la version d'Antigravity, il peut être à `~/.gemini/config/mcp_config.json` — le bouton
  « View raw config » ouvre toujours le bon.

Sauvegarde, puis clique **Refresh** dans « Manage MCP Servers » (ou redémarre Antigravity).
Le serveur `gmail` apparaît avec ses outils.

**Sur Windows**, si le serveur ne démarre pas, remplace le bloc par :

```json
"gmail": {
  "command": "cmd",
  "args": ["/c", "npx", "-y", "@gongrzhe/server-gmail-autoauth-mcp"]
}
```

### c) Sécurité : désactiver la suppression définitive

Toujours dans **Manage MCP Servers**, ouvre le serveur `gmail` et **désactive** les outils
`delete_email`, `batch_delete_emails` et `delete_label` s'ils apparaissent. Le skill n'en a
jamais besoin (nettoyage = corbeille + labels, toujours récupérable).

Test final : demande à l'agent « Lis le dernier email reçu sur Gmail ». S'il répond → c'est branché.

## 4. Ce qui change par rapport à la version Claude Code

| Claude Code | Antigravity | Détail |
|---|---|---|
| `SKILL.md` dans `~/.claude/skills/job-hunt/` | `SKILL.md` dans `.agents/skills/job-hunt/` du projet | Même format (nom + description + instructions) |
| Commandes `/job-hunt setup` (espace) | Workflows `/job-hunt-setup` (tiret) | Un fichier par commande dans `.agents/workflows/` |
| `claude mcp add gmail -- npx ...` | Bloc `gmail` dans `mcp_config.json` | Voir section 3 |
| Permissions dans `~/.claude/settings.json` (`apply-permissions.sh`) | Réglages dans l'interface d'Antigravity | Voir `setup/autonomie.md` du skill |
| Mémoire dans `~/.claude/projects/.../memory/` | Dossier `memoire/` à la racine du projet | Mêmes fichiers, lisibles et modifiables à la main |
| Kill-switch `~/.claude/job-hunt.STOP` | Fichier `job-hunt.STOP` à la racine du projet | Créé/supprimé par `/job-hunt-pause` et `/job-hunt-resume` |
| Règles permanentes dans le SKILL.md | `AGENTS.md` + `.agents/rules/` | Sécurité et personnalité toujours chargées |

## 5. Ce qui n'est PAS directement transposable (et les alternatives)

### a) La boucle autonome « toutes les 5h » — la différence principale

Claude Code peut se réveiller tout seul (tâches planifiées). **Antigravity n'a pas de
planificateur intégré** : il n'exécute rien quand tu n'as pas lancé de session.

**Alternative retenue** : le workflow **`/job-hunt-loop`** fait exactement un cycle complet de
l'ancienne boucle (vérif inbox → prospection → envois → relances → rapport). Tape-le **1 à 2
fois par jour** (matin + fin d'après-midi) : à quota égal, le résultat est le même — les envois
sont juste groupés au lieu d'être étalés. Toutes les protections restent actives (quota, plafond
40/jour, 30 s entre envois, stop si bounce > 5 %, kill-switch).

Option avancée (si tu veux vraiment du planifié) : garder la version Claude Code en parallèle
uniquement pour la boucle, ou explorer Gemini CLI en mode script + planificateur du système —
mais c'est du bricolage de développeur, pas nécessaire pour que le skill fonctionne.

### b) Le fichier de permissions (`settings.template.json` + `apply-permissions.sh`)

Ces deux fichiers n'ont **pas d'équivalent fichier** dans Antigravity : les autorisations se
règlent dans l'interface. **Alternative** : `setup/autonomie.md` (dans le skill) reproduit la
même philosophie — liste blanche courte (Python, npx, fichiers du projet), liste noire
(`rm -rf`, `curl`, `wget`, `ssh`…), et désactivation des outils Gmail de suppression dans le
panneau MCP. L'étape 1 bis du setup te guide clic par clic.

### c) Le blocage « dur » de la suppression d'emails

Claude Code bloquait `delete_email` au niveau système (liste `deny`). Dans Antigravity,
l'équivalent est la **désactivation des outils** dans le panneau MCP (section 3c) — à faire une
fois. En complément, l'interdiction est répétée dans `AGENTS.md`, dans la règle
`job-hunt-securite.md` (toujours active) et dans `SECURITY.md`.

### d) Le nom des outils dans les instructions

Les noms techniques `mcp__gmail__...`, `WebSearch`, `ToolSearch` étaient propres à Claude Code.
Les instructions parlent maintenant « d'outils du serveur MCP Gmail » et de « recherche web » —
l'agent d'Antigravity choisit tout seul le bon outil. Aucun impact sur le comportement.

### e) L'installation par `install.sh`

Le script d'installation du dépôt visait `~/.claude/skills/`. Pour Antigravity, l'installation
est la copie décrite en section 1 — pas de script nécessaire.

## 6. Ce qui ne change pas (logique métier, à l'identique)

- Le setup guidé en étapes, une question à la fois, reprenable
- Le cadrage de la cible validée avant toute prospection (`job_hunt_target.md`)
- Les critères de recherche des contacts : responsable opérationnel du service (pas les RH
  génériques), email publié = `Vérifié` / construit par pattern = `Deviné`, anti-doublons,
  liste noire, RGPD
- La personnalisation des candidatures : style extrait de TES documents, un mail unique par
  contact, jamais de faits inventés, LM d'une page max
- Le ton des messages et les templates (`templates/email.md` inchangé)
- Les relances J+14 / J+28 / clôture J+42, configurables
- La gestion des bounces par type et le nettoyage « corbeille jamais suppression »
- Les modes d'envoi `revue` / `semi-auto` / `autonomie` et tous les garde-fous Gmail
- Le tracker Excel (même script `create_tracker.py`, mêmes colonnes, écriture atomique)
