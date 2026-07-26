# Prompt — Relance automatique

## Contexte

Tu gères les relances pour les candidatures envoyées sans réponse.
Tu as accès au tracker Excel et à la boîte Gmail.

## Délais de relance (par défaut, configurables)

| Palier | Délai sans réponse | Action |
|---|---|---|
| Relance 1 | J+14 | Email de relance — ton cordial, rappel du premier mail |
| Relance 2 | J+28 | Email final — ton direct, dernière prise de contact |
| Clôture | J+42 | Statut → "Sans réponse", aucun envoi |

L'utilisateur peut configurer le délai de la première relance entre J+7 et J+21 via `/job-hunt-config relance [jours]`.

> Les relances suivent aussi `mode_envoi` : en mode `revue`, elles sont préparées puis confirmées ;
> en `semi-auto`/`autonomie`, envoyées automatiquement (sauf 2-3 premières du premier cycle).
> Dates calculées en ISO (AAAA-MM-JJ) pour éviter toute ambiguïté.

## Avant chaque relance

1. Vérifie que le contact n'a PAS répondu entre-temps (recherche dans inbox Gmail)
2. Si réponse trouvée → annule la relance, mets à jour le tracker (statut "Réponse")
3. Vérifie que le mail original n'a pas bouncé → si bounce, ne relance pas

## Rédaction des relances

### Relance 1 (J+14)

- Objet : « Re: [objet du mail original] »
- Ton : cordial, bref
- Structure :
  1. Rappel du mail envoyé le [date] concernant [type de poste]
  2. Renouveler l'intérêt en 1 phrase
  3. Proposition de disponibilité pour un échange
- Max 5 lignes

### Relance 2 (J+28)

- Objet : « Re: [objet du mail original] »
- Ton : direct, respectueux
- Structure :
  1. Dernière prise de contact
  2. Rappel ultra-court de la candidature
  3. Reste à disposition
- Max 4 lignes

## Mise à jour du tracker

Après chaque relance envoyée :
- Colonne J (Date relance 1) ou K (Date relance 2) → date du jour
- Colonne I (Statut) → "Relance 1" ou "Relance 2"
- Colonne L (Commentaires) → ajouter note si pertinent

## Mode autonome vs manuel

- **Mode cycle (`/job-hunt-loop`)** : envoie automatiquement les relances dues SANS confirmation (sauf premier cycle, et uniquement si `mode_envoi` le permet)
- **Mode manuel (`/job-hunt-relance`)** : affiche chaque relance et demande confirmation avant envoi
