#!/bin/bash
# Fusionne les permissions job-hunt dans ~/.claude/settings.json
# - ne supprime AUCUNE permission existante (union des listes)
# - fait une sauvegarde horodatée avant toute écriture
# - écriture atomique
#
# Usage : bash apply-permissions.sh [chemin_settings.template.json]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="${1:-$SCRIPT_DIR/settings.template.json}"
SETTINGS="$HOME/.claude/settings.json"

if [ ! -f "$TEMPLATE" ]; then
  echo "ERREUR : template introuvable : $TEMPLATE"
  exit 1
fi

mkdir -p "$HOME/.claude"

# Sauvegarde si le fichier existe déjà
if [ -f "$SETTINGS" ]; then
  BACKUP="$SETTINGS.backup.$(date +%Y%m%d-%H%M%S)"
  cp "$SETTINGS" "$BACKUP"
  echo "Sauvegarde : $BACKUP"
fi

python3 - "$TEMPLATE" "$SETTINGS" <<'PY'
import json, os, sys, tempfile

template_path, settings_path = sys.argv[1], sys.argv[2]

with open(template_path, encoding="utf-8") as f:
    template = json.load(f)

settings = {}
if os.path.exists(settings_path):
    try:
        with open(settings_path, encoding="utf-8") as f:
            settings = json.load(f)
    except json.JSONDecodeError:
        print("settings.json existant illisible — il a été sauvegardé, on repart d'une base propre.")
        settings = {}

perms = settings.setdefault("permissions", {})
tperms = template.get("permissions", {})

# defaultMode : on ne force que s'il n'est pas déjà défini par l'utilisateur
if "defaultMode" not in perms and "defaultMode" in tperms:
    perms["defaultMode"] = tperms["defaultMode"]

# Union ordonnée, sans doublon, pour allow et deny
for key in ("allow", "deny"):
    existing = perms.get(key, [])
    seen = set(existing)
    for rule in tperms.get(key, []):
        if rule not in seen:
            existing.append(rule)
            seen.add(rule)
    perms[key] = existing

# Écriture atomique
d = os.path.dirname(os.path.abspath(settings_path)) or "."
fd, tmp = tempfile.mkstemp(suffix=".json", dir=d)
os.close(fd)
with open(tmp, "w", encoding="utf-8") as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)
    f.write("\n")
os.replace(tmp, settings_path)

n_allow = len(perms.get("allow", []))
n_deny = len(perms.get("deny", []))
print(f"Permissions appliquées : {n_allow} autorisations, {n_deny} interdits.")
PY

echo ""
echo "Terminé. Relance Claude Code pour que les permissions prennent effet."
echo "Tu ne devrais plus avoir à valider les actions courantes de job-hunt."
