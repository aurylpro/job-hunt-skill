---
description: Recherche de nouveaux contacts employeurs selon la cible validée
---

# /job-hunt-prospect

1. Lis `.agents/skills/job-hunt/SECURITY.md` puis la section « WORKFLOW : /job-hunt-prospect » du skill.
2. PRÉ-REQUIS : la cible validée `memoire/job_hunt_target.md` doit exister — sinon, déclenche
   d'abord le cadrage (étape 3 bis du setup). Ne prospecte jamais sans cible validée.
3. Applique `.agents/skills/job-hunt/prompts/prospect.md` : recherche web des structures puis des
   contacts opérationnels, email `Vérifié` ou `Deviné`, anti-doublons, liste noire.
4. Ajoute au tracker (statut « À contacter ») et affiche le récap en tableau.
