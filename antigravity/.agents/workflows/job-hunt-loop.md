---
description: Cycle complet job-hunt : check inbox → prospection → envois → relances → rapport
---

# /job-hunt-loop

1. Exécute `.agents/skills/job-hunt/prompts/loop.md` À LA LETTRE, contrôles d'amorçage compris :
   SECURITY.md, kill-switch `job-hunt.STOP` (racine du projet — s'il existe, ne fais RIEN),
   config, plafond dur, verrou tracker.
2. Phases dans l'ordre : check → prospect (si < 10 « À contacter ») → send (selon `mode_envoi`)
   → relances → rapport dans `memoire/job_hunt_log.md`.
3. En mode `revue` (défaut), le cycle prépare la file mais N'ENVOIE RIEN.
4. STOP immédiat + alerte si : spam block, captcha, bounce > 5 %, erreur Gmail.
