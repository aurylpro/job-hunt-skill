#!/bin/bash
# Job Hunt Skill — Installer
# Usage : curl -sL https://raw.githubusercontent.com/aurylpro/job-hunt-skill/main/install.sh | bash

set -e

SKILL_DIR="$HOME/.claude/skills/job-hunt"
REPO_URL="https://github.com/aurylpro/job-hunt-skill.git"
TMP_DIR=$(mktemp -d)

echo "=== Job Hunt Skill — Installation ==="
echo ""

# Vérifier que Claude Code est installé
if ! command -v claude &> /dev/null; then
    echo "Erreur : Claude Code n'est pas installé."
    echo "Installe-le depuis : https://claude.ai/code"
    exit 1
fi

# Vérifier Node.js
if ! command -v node &> /dev/null; then
    echo "Attention : Node.js n'est pas installé (requis pour Gmail MCP)."
    echo "Installe-le depuis : https://nodejs.org"
    echo "L'agent te guidera au setup."
fi

# Vérifier Python
if ! command -v python3 &> /dev/null; then
    echo "Attention : Python 3 n'est pas installé (requis pour le tracker Excel)."
    echo "Installe-le depuis : https://python.org"
fi

# Créer le dossier skills s'il n'existe pas
mkdir -p "$HOME/.claude/skills"

# Cloner ou mettre à jour
if [ -d "$SKILL_DIR" ]; then
    echo "Mise à jour du skill existant..."
    rm -rf "$SKILL_DIR"
fi

echo "Téléchargement du skill..."
git clone --quiet "$REPO_URL" "$TMP_DIR"

# Copier le dossier skill
cp -r "$TMP_DIR/skill" "$SKILL_DIR"

# Nettoyage
rm -rf "$TMP_DIR"

echo ""
echo "Installation terminée."
echo ""
echo "Pour commencer :"
echo "  1. Ouvre Claude Code dans ton dossier de travail"
echo "  2. Tape : /job-hunt setup"
echo "  3. L'agent te guide pour tout configurer"
echo "     (dont les autorisations en une fois : tu valides une seule fois,"
echo "      puis plus jamais — idéal pour la boucle autonome)"
echo ""
echo "Commandes disponibles :"
echo "  /job-hunt setup     — Configuration A-Z"
echo "  /job-hunt send      — Envoyer des candidatures"
echo "  /job-hunt status    — Voir tes stats"
echo "  /job-hunt relance   — Relancer les contacts"
echo ""
echo "=== Bonne recherche ! ==="
