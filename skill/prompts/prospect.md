# Prompt — Prospection de contacts

## Contexte

Tu cherches des contacts pertinents selon la **cible validée** par l'utilisateur.

## PRÉ-REQUIS — cible validée obligatoire

Avant toute recherche, lis `job_hunt_target.md` (intitulés de poste à viser, type de contact,
type de structures, zone, exclusions).

- Si la cible **n'existe pas ou n'a pas été validée** → NE PROSPECTE PAS. Déclenche d'abord le
  cadrage (étape 3 bis du setup) : propose une cible et fais-la valider, puis seulement prospecte.
- En boucle autonome, si pas de cible validée → ne fais rien et signale-le à l'utilisateur.

C'est ce qui garantit qu'on contacte les bonnes personnes, pas un envoi à l'aveugle.

## Instructions

### Stratégie de recherche

1. **Recherche par entreprise** : utilise WebSearch pour trouver les structures correspondant à la
   cible (type + zone). Exclus celles de la liste « Ne pas contacter » et des exclusions de la cible.
2. **Recherche par contact** : pour chaque structure, cherche la personne clé définie dans la cible :
   - Le responsable opérationnel du service visé (celui qui encadrerait le poste)
   - Pas le standard ni le service communication ni une RH générique (sauf si la cible le précise)
   - Privilégie les intitulés listés dans `job_hunt_target.md`
3. **Obtention de l'email** : par ordre de préférence :
   - Email **publié** sur le site officiel / annuaire / page contact → marque `Vérifié`
   - Email **construit** par pattern (prenom.nom@domaine, p.nom@domaine) → marque `Deviné`
   - Note toujours l'URL LinkedIn si trouvée

### Statut de l'email (colonne « Email vérifié »)

| Valeur | Quand | Conséquence |
|---|---|---|
| `Vérifié` | Email trouvé publié sur une source officielle, ou domaine MX valide confirmé | Peut être envoyé en mode auto, CV joint autorisé |
| `Deviné` | Email construit par pattern, non confirmé | NE PART PAS en mode auto — attend confirmation (voir SECURITY.md §3-4) |
| `Invalide` | A bouncé en « adresse invalide » | Ne plus envoyer |

Vérification minimale d'un email deviné avant de le marquer `Vérifié` : le domaine doit exister
et accepter le mail (présence d'enregistrement MX). En cas de doute, laisse `Deviné`.

### Données à collecter par contact

| Champ | Obligatoire | Source |
|---|---|---|
| Entreprise | Oui | WebSearch |
| Nom | Oui | WebSearch / LinkedIn |
| Prénom | Oui | WebSearch / LinkedIn |
| Poste | Oui | WebSearch / LinkedIn |
| Email | Oui | Site (Vérifié) ou pattern (Deviné) |
| Email vérifié | Oui | `Vérifié` / `Deviné` |
| LinkedIn | Non | WebSearch |

### Anti-doublons & liste noire

- Avant d'ajouter un contact, vérifie qu'il n'existe pas déjà dans le tracker (match sur Nom + Entreprise).
- Vérifie l'onglet **« Ne pas contacter »** : si l'entreprise ou le domaine y figure, n'ajoute pas le contact.

### Données personnelles (RGPD)

Les contacts collectés sont des données personnelles de tiers. Elles restent dans le tracker local,
ne sont jamais publiées ni envoyées à un service externe. Usage strictement limité à la candidature.

### Volume par cycle

- En mode manuel : cherche 10-20 contacts par recherche
- En mode boucle autonome : complète jusqu'à avoir 10 contacts "À contacter" dans le tracker

### Format de sortie

Affiche un tableau des contacts trouvés :

```
| # | Entreprise | Contact | Poste | Email | LinkedIn |
|---|---|---|---|---|---|
| 1 | ... | ... | ... | ... | ... |
```

Puis : « X contacts ajoutés au tracker. »
