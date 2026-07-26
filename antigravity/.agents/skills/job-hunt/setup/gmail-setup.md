# Guide d'installation — Gmail MCP (Google Antigravity)

## Ce que c'est

Le serveur MCP Gmail permet à l'agent Antigravity de lire, envoyer et gérer les emails Gmail.
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
- Puis **fermer et rouvrir le terminal + Antigravity**, et re-tester `node --version`.

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

> Si la commande demande un fichier `gcp-oauth.keys.json` : suis le README du dépôt
> GongRzhe/Gmail-MCP-Server (création d'identifiants OAuth dans Google Cloud Console,
> puis placer le fichier dans `~/.gmail-mcp/`) avant de relancer l'auth.

### Étape 2 — Enregistrer le MCP dans Antigravity

Antigravity utilise un fichier `mcp_config.json` (pas de commande CLI type `claude mcp add`).
Deux façons d'y accéder — la première est la plus fiable car elle ouvre le bon fichier :

**Via l'interface (recommandé) :**
1. Ouvre Antigravity
2. Dans le panneau Agent (à droite), clique sur le menu « … » (options supplémentaires)
3. Clique sur **MCP Servers** → **Manage MCP Servers**
4. Clique sur **View raw config** → le fichier `mcp_config.json` s'ouvre

**Ou directement sur le disque :**
- **Windows** : `C:\Users\<TON_NOM>\.gemini\antigravity\mcp_config.json`
- **macOS / Linux** : `~/.gemini/antigravity/mcp_config.json`

> Selon la version d'Antigravity, le fichier peut aussi être à `~/.gemini/config/mcp_config.json`
> (config partagée Antigravity 2.0 / IDE / CLI). Le bouton « View raw config » ouvre toujours
> le bon fichier — c'est la référence en cas de doute.

Ajoute le bloc `gmail` dans l'objet `mcpServers` (voir `mcp_config.json` fourni à la racine
du dossier `antigravity/`) :

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

**Sur Windows**, si le serveur ne démarre pas avec `npx` directement, utilise cette variante :

```json
{
  "mcpServers": {
    "gmail": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@gongrzhe/server-gmail-autoauth-mcp"]
    }
  }
}
```

Sauvegarde le fichier, puis retourne dans **Manage MCP Servers** et clique sur **Refresh**
(ou redémarre Antigravity). Le serveur `gmail` doit apparaître avec sa liste d'outils.

### Étape 3 — Désactiver les outils de suppression définitive (sécurité)

Dans **Manage MCP Servers**, ouvre le serveur `gmail` et **désactive les outils de suppression
définitive** s'ils sont listés (typiquement `delete_email`, `batch_delete_emails`, `delete_label`).
Le skill n'en a jamais besoin : le nettoyage se fait par corbeille et labels (récupérables).
C'est l'équivalent Antigravity de la liste `deny` de la version Claude Code.

## Vérification fonctionnelle

1. Dans le panneau Agent, demande : « Lis le dernier email reçu sur Gmail »
2. L'agent doit utiliser un outil du serveur `gmail` (recherche avec la query `newer_than:1d`)
3. Si ça répond → Gmail est connecté. Confirme « Gmail connecté. »
4. Si erreur → voir Troubleshooting.

## Troubleshooting

| Erreur | Solution |
|---|---|
| `gmail` absent du panneau MCP Servers | Vérifie le JSON (virgules !), sauvegarde, clique Refresh, ou redémarre Antigravity |
| Serveur listé mais aucun outil | Sur Windows, essaie la variante `cmd /c npx` ci-dessus |
| "Authentication required" | Relance `npx @gongrzhe/server-gmail-autoauth-mcp auth` |
| "Insufficient permissions" | Refais l'auth en acceptant TOUTES les permissions Gmail |
| "Token expired" | Supprime `~/.gmail-mcp/credentials.json` et relance l'auth |
| Le voyant du serveur reste orange/gris | Selon les versions, l'indicateur tarde à passer au vert ; teste quand même un outil |

## Périmètre d'accès

L'agent utilise Gmail uniquement pour :
- Envoyer les candidatures et relances
- Lire les réponses et les bounces liés aux candidatures
- Mettre à la corbeille (jamais supprimer en dur) les mails système (MAILER-DAEMON)

Il ne lit, ne déplace, ni ne supprime aucun email personnel sans rapport avec les candidatures.
Voir `SECURITY.md` pour les règles complètes.
