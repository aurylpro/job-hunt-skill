# Template — Structure email de candidature

## Structure standard

```
Objet : [Type de poste] — Candidature [Prénom Nom]

Bonjour [Civilité] [Nom],

[ACCROCHE — 1 phrase max — mentionne l'entreprise ou le service + pourquoi tu contactes cette personne]

[PROPOSITION DE VALEUR — 2-3 phrases — ce que tu apportes, formation, compétence clé, expérience pertinente]

[DEMANDE — 1 phrase — ce que tu souhaites : un échange, un entretien, une orientation]

[FORMULE — 1 ligne — cordialement / bien à vous / etc.]

[SIGNATURE]
[Prénom Nom]
[Téléphone]
```

## Règles

- L'objet ne dépasse JAMAIS 60 caractères
- Le mail complet tient dans un écran (max 8 lignes de corps)
- Pas de pièce jointe mentionnée dans le corps sauf si CV effectivement joint
- Le ton s'aligne sur le style de l'utilisateur (extrait lors du setup)
- Chaque mail est unique — l'accroche change selon le contact

## Template relance 1

```
Objet : Re: [Objet du mail original]

Bonjour [Civilité] [Nom],

Je me permets de revenir vers vous suite à mon mail du [date]. Je suis toujours très intéressé(e) par [type de poste] au sein de [entreprise/service].

Seriez-vous disponible pour un bref échange ?

[SIGNATURE]
```

## Template relance 2

```
Objet : Re: [Objet du mail original]

Bonjour [Civilité] [Nom],

Dernière prise de contact concernant ma candidature en [type de poste]. Je reste à votre disposition si une opportunité se présente.

[SIGNATURE]
```

## Tracker Excel — Structure des colonnes

| Colonne | Lettre | Largeur | Format |
|---|---|---|---|
| Numéro | A | 5 | Entier auto |
| Entreprise | B | 30 | Texte |
| Nom | C | 15 | Texte |
| Prénom | D | 15 | Texte |
| Poste du contact | E | 25 | Texte |
| Email | F | 30 | Texte |
| LinkedIn | G | 35 | URL |
| Date d'envoi | H | 12 | Date JJ/MM/YYYY |
| Statut | I | 15 | Liste : À contacter / Envoyée / Bounce / Réponse / Relance 1 / Relance 2 / Sans réponse / Entretien / Refus / Accepté |
| Date relance 1 | J | 12 | Date JJ/MM/YYYY |
| Date relance 2 | K | 12 | Date JJ/MM/YYYY |
| Commentaires | L | 40 | Texte libre |
