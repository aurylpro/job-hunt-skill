---
description: Envoie les candidatures en attente, avec confirmation et dans la limite du quota
---

# /job-hunt-send

1. Lis `.agents/skills/job-hunt/SECURITY.md` puis la section « WORKFLOW : /job-hunt-send » du skill.
2. En manuel, confirme TOUJOURS chaque envoi, quel que soit `mode_envoi`.
3. Respecte le quota restant `min(quota_jour, plafond_dur) - compteur_envois_du_jour`, l'écriture
   « Envoyée » AVANT l'envoi (idempotence), le CV joint uniquement si `Email vérifié = Vérifié`,
   et 30 s entre deux envois.
4. Récap final : envoyées + quota restant.
