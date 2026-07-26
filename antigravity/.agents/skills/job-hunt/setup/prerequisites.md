# Étape 0 — Vérification des prérequis (cross-plateforme)

Objectif : ne JAMAIS supposer qu'un outil est installé. L'agent vérifie chaque prérequis, et s'il
manque, il guide l'installation pas à pas selon l'OS, puis re-vérifie avant de continuer.
C'est la cause n°1 de blocage pour les débutants (ex. « npx n'est pas reconnu » = Node absent).

## 0.1 — Détecter l'OS

Détermine l'OS de l'utilisateur (Windows / macOS / Linux). Depuis Antigravity tu peux le déduire de
l'environnement. En cas de doute, demande en une phrase : « Tu es sur Windows ou Mac ? »

L'adaptation principale :
- **Windows** : terminal = PowerShell ; installeurs via `winget` ou `.msi`/`.exe`.
- **macOS** : terminal = zsh/bash ; installeurs via `brew` ou `.pkg`.
- **Linux** : gestionnaire de paquets (`apt`, `dnf`…) ou paquets officiels.

## 0.2 — Vérifier chaque prérequis

Lance ces commandes une par une et interprète le résultat. Une commande qui renvoie un numéro de
version = OK. Une erreur « not recognized / command not found » = à installer.

| Outil | Commande de test | Nécessaire pour |
|---|---|---|
| Node.js | `node --version` | Gmail MCP (npx) |
| npm/npx | `npx --version` | Installer/lancer le MCP Gmail |
| Python | `python --version` **ou** `python3 --version` | Tracker Excel |
| Git | `git --version` | (déjà utilisé si install via git) |

> Sur Windows, Python peut s'appeler `python` (pas `python3`). Teste les deux.
> Sur macOS/Linux, c'est généralement `python3`.

## 0.3 — Installer ce qui manque

### Node.js (le plus souvent en cause)

**Windows :**
```powershell
winget install OpenJS.NodeJS.LTS
```
Ou télécharger l'installeur LTS sur https://nodejs.org et l'exécuter (options par défaut).

**macOS :**
```bash
brew install node
```
Ou installeur LTS depuis https://nodejs.org.

**Linux (Debian/Ubuntu) :**
```bash
sudo apt update && sudo apt install -y nodejs npm
```

### Python

**Windows :**
```powershell
winget install Python.Python.3.12
```
Ou https://python.org (cocher « Add Python to PATH » pendant l'installation).

**macOS :**
```bash
brew install python3
```

**Linux :** `sudo apt install -y python3 python3-pip`

## 0.4 — RÈGLE CRITIQUE : rouvrir le terminal après installation

Après toute installation d'outil, le PATH n'est PAS rafraîchi dans la fenêtre en cours.
**Dis explicitement à l'utilisateur de FERMER et ROUVRIR le terminal et Antigravity**, sinon
`node`/`npx`/`python` resteront « introuvables » même bien installés. C'est le piège classique.

Puis re-teste (`node --version`, etc.) avant de continuer. Ne passe à l'étape suivante que quand
tous les prérequis nécessaires répondent un numéro de version.

## 0.5 — Récapitulatif intuitif pour l'utilisateur

Présente le résultat simplement, par ex. :

> « Vérif rapide de ton PC :
>  • Node.js ✅  • Python ✅  • Git ✅
>  Tout est prêt, on continue. »

ou, si manque :

> « Il manque Node.js (nécessaire pour Gmail). Installe-le : `winget install OpenJS.NodeJS.LTS`,
>  puis **ferme et rouvre** ce terminal et Antigravity, et redis-moi « c'est bon ». »

Une seule chose demandée à la fois. Pas de jargon.
