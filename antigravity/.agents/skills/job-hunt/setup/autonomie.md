# Autonomie — régler Antigravity pour job-hunt (remplace `permissions.md` de Claude Code)

## Le problème (le même qu'avant)

Par défaut, un agent demande une validation à chaque action sensible (lancer une commande,
envoyer un email, écrire un fichier). Pour un usage ponctuel c'est bien. Mais pour job-hunt,
un cycle complet (`/job-hunt-loop`) enchaîne des dizaines d'actions : si chacune attend une
validation, le cycle devient pénible.

## Ce qui change par rapport à Claude Code

La version Claude Code écrivait une liste blanche/noire dans `~/.claude/settings.json`
(via `apply-permissions.sh`). **Antigravity n'a pas ce fichier** : l'autonomie se règle dans
**l'interface**, en trois endroits. L'agent guide l'utilisateur clic par clic — il ne modifie
aucun fichier de configuration lui-même.

### 1. Politique de revue de l'agent

Dans les paramètres d'Antigravity (icône engrenage, section Agent / permissions), choisis le
niveau de supervision de l'agent. Recommandation job-hunt : le mode intermédiaire où **l'agent
décide** quand demander une revue (et non « tout exécuter sans demander »). Les envois d'emails
restent de toute façon protégés par le `mode_envoi` du skill (revue / semi-auto / autonomie),
qui est indépendant de ce réglage.

### 2. Auto-exécution des commandes terminal (liste blanche / liste noire)

Toujours dans les paramètres (cherche « terminal » ou « auto execution ») :

- **Liste d'autorisation (allow list)** — commandes que l'agent peut lancer sans demander.
  Pour job-hunt, ajoute uniquement :
  - `python3` et `python` (génération/mise à jour du tracker Excel)
  - `pip install` / `pip3 install` (dépendance openpyxl)
  - `npx` (serveur MCP Gmail)
  - `mkdir`, `ls`, `test`, `touch`, `cp` (fichiers du projet, kill-switch, archive du tracker)
- **Liste d'interdiction (deny list)** — bloquées quoi qu'il arrive. Ajoute :
  - `rm -rf` et `rm -fr`
  - `curl`, `wget`, `ssh`, `scp` (pas d'exfiltration possible via outils réseau bruts)

Ce n'est PAS un « tout autoriser » : la liste est volontairement limitée. Elle sert aussi de
**barrière de sécurité** — même si un email piégé tentait de détourner l'agent (cf. SECURITY.md),
il ne pourrait faire que ce qui est autorisé.

### 3. Outils MCP Gmail — désactiver la suppression définitive

Dans **… → MCP Servers → Manage MCP Servers → gmail**, désactive les outils de suppression
définitive (`delete_email`, `batch_delete_emails`, `delete_label`). Le skill n'utilise que la
corbeille et les labels (récupérables). C'est l'équivalent de la liste `deny` MCP de la version
Claude Code : bloqué au niveau du système, pas seulement par les instructions.

## Mode prudent

Si l'utilisateur préfère tout valider : ne rien mettre en liste d'autorisation et choisir la
politique de revue la plus stricte. Tout fonctionne, mais chaque cycle demandera beaucoup de
validations manuelles. À réserver à ceux qui veulent tout contrôler.

## Revenir en arrière

Tout se défait au même endroit : retirer les entrées des listes d'autorisation/interdiction dans
les paramètres, et réactiver les outils MCP si besoin. Aucun fichier n'a été modifié.

## Important — ce que ce réglage ne couvre PAS

Quel que soit le niveau d'autonomie d'Antigravity, les règles du skill restent en vigueur :
- l'envoi d'emails suit `mode_envoi` (revue par défaut : rien ne part sans validation) ;
- jamais de suppression définitive d'emails ;
- plafond `min(quota, 40)`/jour le premier mois, 30 s entre envois, stop si bounce > 5 %.
Voir `SECURITY.md`.
