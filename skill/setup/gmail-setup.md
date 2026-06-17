# Guide d'installation — Gmail MCP (Claude Code)

## Ce que c'est

Le Gmail MCP permet à Claude Code de lire, envoyer et gérer les emails Gmail.
Sans lui, l'agent ne peut pas envoyer de candidatures.

## Pré-requis

- Un compte Gmail
- Node.js >= 18 (vérifie avec `node --version`)
- npm (vérifie avec `npm --version`)

Si Node.js n'est pas installé, dis à l'utilisateur :
> « Node.js n'est pas installé. Installe-le depuis https://nodejs.org (version LTS), puis relance /job-hunt setup. »

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
