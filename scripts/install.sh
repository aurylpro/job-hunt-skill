#!/bin/bash
# Job Hunt Skill — Installeur multi-agent (Claude Code, Gemini CLI, MCP standard)
# Usage : curl -sL https://raw.githubusercontent.com/aurylpro/job-hunt-skill/main/scripts/install.sh | bash
#    ou : git clone ... && bash scripts/install.sh

set -e

REPO_URL="https://github.com/aurylpro/job-hunt-skill.git"
INSTALL_DIR="$HOME/.job-hunt-skill"

echo "============================================"
echo "  Job Hunt Skill — Installation"
echo "============================================"
echo ""

# --- Détection de l'environnement ---

detect_agent() {
  if command -v claude &> /dev/null; then
    echo "claude"
  elif command -v gemini &> /dev/null; then
    echo "gemini"
  else
    echo "unknown"
  fi
}

AGENT=$(detect_agent)

# --- Vérification des prérequis ---

echo "[1/4] Vérification des prérequis..."
echo ""

MISSING=""

if command -v node &> /dev/null; then
  echo "  Node.js : $(node --version) ✓"
else
  echo "  Node.js : MANQUANT (requis pour le serveur MCP Gmail)"
  MISSING="$MISSING node"
fi

if command -v python3 &> /dev/null; then
  echo "  Python 3 : $(python3 --version 2>&1) ✓"
elif command -v python &> /dev/null; then
  echo "  Python : $(python --version 2>&1) ✓"
else
  echo "  Python : MANQUANT (requis pour le tracker Excel)"
  MISSING="$MISSING python"
fi

if command -v git &> /dev/null; then
  echo "  Git : $(git --version) ✓"
else
  echo "  Git : MANQUANT"
  MISSING="$MISSING git"
fi

echo ""

if [ -n "$MISSING" ]; then
  echo "⚠  Prérequis manquants :$MISSING"
  echo "  L'agent te guidera pour les installer au lancement du setup."
  echo ""
fi

# --- Clone ou mise à jour ---

echo "[2/4] Téléchargement du skill..."

if [ -d "$INSTALL_DIR" ]; then
  echo "  Mise à jour du dépôt existant..."
  cd "$INSTALL_DIR" && git pull --quiet origin main 2>/dev/null || {
    echo "  Pull échoué, re-téléchargement..."
    rm -rf "$INSTALL_DIR"
    git clone --quiet "$REPO_URL" "$INSTALL_DIR"
  }
else
  git clone --quiet "$REPO_URL" "$INSTALL_DIR"
fi

echo "  Installé dans : $INSTALL_DIR"
echo ""

# --- Installation spécifique à l'agent ---

echo "[3/4] Configuration de l'agent..."
echo ""

SYSTEM_PROMPT_PATH="$INSTALL_DIR/prompts/system_prompt.md"

case "$AGENT" in
  claude)
    echo "  Agent détecté : Claude Code"
    echo ""

    SKILL_DIR="$HOME/.claude/skills/job-hunt"
    mkdir -p "$HOME/.claude/skills"

    if [ -d "$SKILL_DIR" ]; then
      rm -rf "$SKILL_DIR"
    fi
    cp -r "$INSTALL_DIR/skill" "$SKILL_DIR"

    echo "  Skill Claude Code installé dans : $SKILL_DIR"
    echo ""
    echo "  Pour commencer :"
    echo "    1. Ouvre Claude Code"
    echo "    2. Tape : /job-hunt setup"
    echo ""
    ;;

  gemini)
    echo "  Agent détecté : Gemini CLI"
    echo ""
    echo "  Pour configurer Gemini CLI avec ce skill :"
    echo ""
    echo "  1. Injecte le system prompt au lancement :"
    echo "     gemini --system-prompt \"$SYSTEM_PROMPT_PATH\""
    echo ""
    echo "  2. Configure le serveur MCP Gmail dans ~/.gemini/settings.json :"
    echo '     {'
    echo '       "mcpServers": {'
    echo '         "gmail": {'
    echo '           "command": "npx",'
    echo '           "args": ["-y", "@gongrzhe/server-gmail-autoauth-mcp"]'
    echo '         }'
    echo '       }'
    echo '     }'
    echo ""
    echo "  3. Authentifie Gmail (une fois) :"
    echo "     npx @gongrzhe/server-gmail-autoauth-mcp auth"
    echo ""
    echo "  4. Lance le setup :"
    echo "     « Lance le setup de recherche d'emploi »"
    echo ""
    ;;

  *)
    echo "  Aucun agent CLI détecté (ni Claude Code, ni Gemini CLI)."
    echo ""
    echo "  Pour utiliser ce skill avec un agent compatible MCP :"
    echo ""
    echo "  1. System prompt (persona de l'agent) :"
    echo "     $SYSTEM_PROMPT_PATH"
    echo ""
    echo "  2. Template de configuration MCP Gmail :"
    echo "     $INSTALL_DIR/config/mcp_gmail_template.json"
    echo ""
    echo "  3. Workflow de setup :"
    echo "     $INSTALL_DIR/prompts/setup_workflow.md"
    echo ""
    echo "  Consulte le README pour les instructions détaillées."
    echo ""
    ;;
esac

# --- Instructions Gmail ---

echo "[4/4] Configuration Gmail..."
echo ""
echo "  Pour connecter Gmail, tu auras besoin de :"
echo "  • Un compte Gmail (idéalement dédié : prenom.nom@gmail.com)"
echo "  • Node.js installé (pour le serveur MCP Gmail)"
echo ""
echo "  Authentification (une fois) :"
echo "    npx @gongrzhe/server-gmail-autoauth-mcp auth"
echo ""
echo "  Si tu utilises un serveur MCP Gmail nécessitant des identifiants OAuth :"
echo "    1. Crée un projet sur https://console.cloud.google.com"
echo "    2. Active l'API Gmail"
echo "    3. Crée des identifiants OAuth 2.0 (Desktop app)"
echo "    4. Place credentials.json dans ~/.gmail-mcp/"
echo ""
echo "  Détails complets : $INSTALL_DIR/config/mcp_gmail_template.json"
echo ""

# --- Récapitulatif ---

echo "============================================"
echo "  Installation terminée !"
echo "============================================"
echo ""
echo "  Fichiers clés :"
echo "  • System prompt : $SYSTEM_PROMPT_PATH"
echo "  • Setup workflow : $INSTALL_DIR/prompts/setup_workflow.md"
echo "  • Config MCP Gmail : $INSTALL_DIR/config/mcp_gmail_template.json"
echo "  • Tracker (script) : $INSTALL_DIR/skill/templates/create_tracker.py"
echo ""
echo "  Bonne recherche !"
echo ""
