# Guide d'installation — Gmail MCP (Claude Code)

## Ce que c'est

Le Gmail MCP permet à Claude Code de lire, envoyer et gérer les emails Gmail.
Sans lui, l'agent ne peut pas envoyer de candidatures.

## Pré-requis — À VÉRIFIER AVANT de lancer quoi que ce soit

Node.js (avec npx) est indispensable ici. **Teste-le d'abord** :

```
node --version
npx --version
```

Si l'une renvoie « not recognized » (Windows) ou « command not found » (Mac/Linux) → Node.js
n'est pas installé (ou le terminal n'a pas été rouvert après installation). NE LANCE PAS la
commande `npx ...auth` tant que ce n'est pas réglé — elle échouera avec « npx is not recognized ».

Va d'abord régler ça via `setup/prerequisites.md` :
- **Windows** : `winget install OpenJS.NodeJS.LTS` (ou installeur LTS https://nodejs.org)
- **macOS** : `brew install node` (ou https://nodejs.org)
- Puis **fermer et rouvrir le terminal + Claude Code**, et re-tester `node --version`.

Quand `node --version` et `npx --version` répondent un numéro → continue ci-dessous.

## Installation — serveur recommandé

On utilise le serveur open-source **GongRzhe/Gmail-MCP-Server**
(npm : `@gongrzhe/server-gmail-autoauth-mcp`), qui gère l'auth OAuth Google automatiquement.
Repo : https://github.com/GongRzhe/Gmail-MCP-Server

> Important : vérifie toujours le dépôt/paquet avant installation. Si le nom du paquet a changé,
> cherche « Gmail MCP server » et choisis un dépôt actif et reconnu. N'invente jamais une URL.

### Étape 1 — Authentification Google (une fois)

```bash
npx @gongrzhe/server-gmail-autoauth-mcp auth
```

Une fenêtre Google s'ouvre. L'utilisateur se connecte et **accepte les permissions Gmail**.
Le token est stocké localement (`~/.gmail-mcp/`). L'agent ne voit jamais le mot de passe.

### Étape 2 — Enregistrer le MCP dans Claude Code

Claude Code n'utilise PAS `claude_desktop_config.json`. Utilise la commande dédiée :

```bash
claude mcp add gmail -- npx -y @gongrzhe/server-gmail-autoauth-mcp
```

Pour l'enregistrer au niveau utilisateur (disponible dans tous les projets) :

```bash
claude mcp add --scope user gmail -- npx -y @gongrzhe/server-gmail-autoauth-mcp
```

Puis vérifie :

```bash
claude mcp list
```

`gmail` doit apparaître avec le statut connecté.

## Vérification fonctionnelle

1. Charge les outils Gmail : `ToolSearch("gmail")`
2. Lis le dernier email : `mcp__gmail__search_emails` avec la query `newer_than:1d`
3. Si ça répond → Gmail est connecté. Confirme « Gmail connecté. »
4. Si erreur → voir Troubleshooting.

## Troubleshooting

| Erreur | Solution |
|---|---|
| `gmail` absent de `claude mcp list` | Relance `claude mcp add ...`, puis relance la session Claude Code |
| "Authentication required" | Relance `npx @gongrzhe/server-gmail-autoauth-mcp auth` |
| "Insufficient permissions" | Refais l'auth en acceptant TOUTES les permissions Gmail |
| "Token expired" | Supprime `~/.gmail-mcp/credentials.json` et relance l'auth |
| Outils `mcp__gmail__*` introuvables | Relance Claude Code après l'ajout du MCP |

## Périmètre d'accès

L'agent utilise Gmail uniquement pour :
- Envoyer les candidatures et relances
- Lire les réponses et les bounces liés aux candidatures
- Mettre à la corbeille (jamais supprimer en dur) les mails système (MAILER-DAEMON)

Il ne lit, ne déplace, ni ne supprime aucun email personnel sans rapport avec les candidatures.
Voir `SECURITY.md` pour les règles complètes.
