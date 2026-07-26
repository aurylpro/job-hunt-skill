---
description: Génère et envoie les relances dues (J+14 / J+28), annule si réponse reçue
---

# /job-hunt-relance

1. Lis `.agents/skills/job-hunt/SECURITY.md` puis `.agents/skills/job-hunt/prompts/relance.md`.
2. Filtre le tracker : « Envoyée » sans réponse. J+14 → relance 1 ; J+28 → relance 2 ;
   J+42 → clôture « Sans réponse ».
3. Avant chaque relance : vérifie qu'aucune réponse n'est arrivée et que le mail n'a pas bouncé.
4. En manuel, affiche chaque relance et demande confirmation avant envoi. Mets le tracker à jour.
