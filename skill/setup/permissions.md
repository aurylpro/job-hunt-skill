# Autorisations — mode « mains-libres » vs « prudent »

## Le problème

Par défaut, Claude Code demande une validation à chaque action sensible (lancer une commande,
envoyer un email, écrire un fichier). Pour un usage ponctuel c'est bien. Mais pour job-hunt :

- La **boucle autonome tourne toutes les 5h, souvent sans personne devant l'écran** : si chaque
  action attend une validation, la boucle reste bloquée et rien ne se fait.
- Un débutant qui vient d'installer Claude Code va voir des dizaines de demandes et s'y perdre.

## La solution : une autorisation unique et scopée

Au setup, l'agent propose deux modes :

### Mode mains-libres (recommandé pour la boucle autonome)

L'agent applique **une fois** une liste blanche précise dans `~/.claude/settings.json` :
il autorise exactement les actions dont job-hunt a besoin (lire/écrire des fichiers, lancer Python
pour le tracker, chercher sur le web, utiliser Gmail, planifier la boucle). L'utilisateur **valide
une seule fois**, puis n'a plus jamais à autoriser ces actions courantes.

**Ce n'est PAS le mode « tout autoriser » (`bypassPermissions`).** La liste est limitée. C'est
volontaire : elle sert aussi de **barrière de sécurité**. Même si un email piégé tentait de
détourner l'agent (cf. SECURITY.md), il ne pourrait faire que ce qui est sur la liste — pas
supprimer des fichiers, pas exfiltrer de données.

En plus, une liste d'**interdits** (`deny`) bloque au niveau du système, quoi qu'il arrive :
- suppression **définitive** d'emails (`delete_email`, `batch_delete_emails`) → seul le passage
  à la corbeille est permis
- outils réseau bruts (`curl`, `wget`, `ssh`, `scp`) → pas d'exfiltration possible
- `rm -rf` et fork-bombs

### Mode prudent

Rien n'est pré-autorisé. L'utilisateur reste devant l'écran et valide chaque action.
À réserver à ceux qui veulent tout contrôler et n'utilisent pas la boucle autonome.

> Si l'utilisateur veut la boucle autonome (5h) mais choisit le mode prudent, préviens-le :
> la boucle se bloquera sur les validations en son absence. Le mode mains-libres est nécessaire
> pour une vraie autonomie.

## Comment l'agent applique le mode mains-libres

```bash
bash setup/apply-permissions.sh setup/settings.template.json
```

Le script :
- **sauvegarde** `~/.claude/settings.json` avant toute modification (fichier `.backup.<date>`)
- **fusionne** sans rien supprimer des permissions existantes (union)
- n'écrase pas un `defaultMode` déjà choisi par l'utilisateur
- écrit de façon atomique

Puis l'agent indique : « Relance Claude Code pour activer les permissions. »

## Revenir en arrière

- Restaurer le backup : `cp ~/.claude/settings.json.backup.<date> ~/.claude/settings.json`
- Ou éditer `~/.claude/settings.json` et retirer les entrées `allow` de job-hunt.

## Contenu exact autorisé

Voir `setup/settings.template.json`. En clair, l'agent peut : lire/écrire des fichiers, lancer
Python (tracker), installer/configurer le MCP Gmail, chercher sur le web, envoyer/trier/étiqueter
des emails et planifier la boucle. Il ne peut pas supprimer définitivement d'emails ni utiliser
d'outils réseau bruts.
