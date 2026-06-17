"""
Création / écriture sûre du tracker Excel pour job-hunt.

Usage :
    python3 create_tracker.py [chemin_de_sortie]

Fonctions importantes pour l'agent :
    - create_tracker(path)   : crée un tracker vierge (refuse d'écraser un fichier existant)
    - safe_save(wb, path)    : écriture atomique (temp + rename), détecte les verrous Excel

Colonnes (ligne 1 = en-têtes, données à partir de la ligne 2) :
    A #  | B Entreprise | C Nom | D Prénom | E Poste | F Email | G Email vérifié
    H LinkedIn | I Date envoi | J Statut | K Relance 1 | L Relance 2 | M Commentaires

Dates : format ISO AAAA-MM-JJ (non ambigu).
"""
import sys
import os
import tempfile
from datetime import datetime

try:
    from openpyxl import Workbook, load_workbook
    from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
    from openpyxl.utils import get_column_letter
    from openpyxl.worksheet.datavalidation import DataValidation
except ImportError:
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "openpyxl", "-q"])
    from openpyxl import Workbook, load_workbook
    from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
    from openpyxl.utils import get_column_letter
    from openpyxl.worksheet.datavalidation import DataValidation


HEADERS = [
    ("#", 5),
    ("Entreprise", 28),
    ("Nom", 14),
    ("Prénom", 14),
    ("Poste", 24),
    ("Email", 30),
    ("Email vérifié", 13),   # "Vérifié" / "Deviné" / "Invalide"
    ("LinkedIn", 32),
    ("Date envoi", 12),       # ISO AAAA-MM-JJ
    ("Statut", 16),
    ("Relance 1", 12),
    ("Relance 2", 12),
    ("Commentaires", 40),
]

STATUTS = (
    "À contacter,En attente confirmation,Envoyée,Bounce,Bounce définitif,"
    "Réponse,Relance 1,Relance 2,Sans réponse,Entretien,Refus,Accepté,Ne pas contacter"
)
VERIF = '"Vérifié,Deviné,Invalide"'


def _is_locked(path):
    """Détecte un verrou Excel (fichier ~$ ou impossible d'ouvrir en écriture)."""
    if not os.path.exists(path):
        return False
    lock_sibling = os.path.join(os.path.dirname(path), "~$" + os.path.basename(path))
    if os.path.exists(lock_sibling):
        return True
    try:
        with open(path, "a"):
            return False
    except (PermissionError, OSError):
        return True


def safe_save(wb, path):
    """Écriture atomique : écrit dans un fichier temporaire puis remplace l'original.
    Évite la corruption si le process est interrompu en plein écriture.
    Lève RuntimeError si le fichier est verrouillé (ouvert dans Excel)."""
    if _is_locked(path):
        raise RuntimeError(
            f"Le fichier '{path}' est ouvert dans Excel (verrouillé). "
            "Ferme-le avant d'écrire pour éviter toute corruption."
        )
    d = os.path.dirname(os.path.abspath(path)) or "."
    fd, tmp = tempfile.mkstemp(suffix=".xlsx", dir=d)
    os.close(fd)
    try:
        wb.save(tmp)
        os.replace(tmp, path)  # atomique sur le même volume
    finally:
        if os.path.exists(tmp):
            os.remove(tmp)


def create_tracker(output_path=None, overwrite=False):
    if output_path is None:
        output_path = os.path.join(os.getcwd(), "suivi_candidatures.xlsx")

    if os.path.exists(output_path) and not overwrite:
        raise FileExistsError(
            f"'{output_path}' existe déjà. N'écrase pas un tracker existant "
            "(risque de perte de données). Importe-le plutôt."
        )

    wb = Workbook()
    ws = wb.active
    ws.title = "Suivi Candidatures"

    header_font = Font(bold=True, color="FFFFFF", size=11)
    header_fill = PatternFill(start_color="4F46E5", end_color="4F46E5", fill_type="solid")
    header_align = Alignment(horizontal="center", vertical="center", wrap_text=True)
    thin = Side(style="thin", color="D1D5DB")
    border = Border(left=thin, right=thin, top=thin, bottom=thin)

    for col_idx, (name, width) in enumerate(HEADERS, 1):
        cell = ws.cell(row=1, column=col_idx, value=name)
        cell.font = header_font
        cell.fill = header_fill
        cell.alignment = header_align
        cell.border = border
        ws.column_dimensions[get_column_letter(col_idx)].width = width

    # Validation statut (col J = 10)
    dv_statut = DataValidation(type="list", formula1=f'"{STATUTS}"', allow_blank=True)
    dv_statut.promptTitle = "Statut"
    dv_statut.prompt = "Choisis un statut"
    ws.add_data_validation(dv_statut)
    dv_statut.add("J2:J2000")

    # Validation email vérifié (col G = 7)
    dv_verif = DataValidation(type="list", formula1=VERIF, allow_blank=True)
    ws.add_data_validation(dv_verif)
    dv_verif.add("G2:G2000")

    ws.auto_filter.ref = "A1:M1"
    ws.freeze_panes = "A2"
    ws.sheet_properties.tabColor = "4F46E5"

    # Onglet liste noire (entreprises/domaines à ne jamais contacter)
    bl = wb.create_sheet("Ne pas contacter")
    bl["A1"] = "Entreprise / Domaine"
    bl["B1"] = "Raison"
    for c in ("A1", "B1"):
        bl[c].font = header_font
        bl[c].fill = header_fill
    bl.column_dimensions["A"].width = 32
    bl.column_dimensions["B"].width = 40

    # Onglet stats
    st = wb.create_sheet("Stats")
    st["A1"] = "Statistiques"
    st["A1"].font = Font(bold=True, size=14)
    rows = [
        ("Total contacts", '=COUNTA(\'Suivi Candidatures\'!B2:B2000)'),
        ("Envoyées", '=COUNTIF(\'Suivi Candidatures\'!J2:J2000,"Envoyée")'),
        ("Réponses", '=COUNTIF(\'Suivi Candidatures\'!J2:J2000,"Réponse")'),
        ("Bounces", '=COUNTIF(\'Suivi Candidatures\'!J2:J2000,"Bounce")+COUNTIF(\'Suivi Candidatures\'!J2:J2000,"Bounce définitif")'),
        ("Relances faites", '=COUNTIF(\'Suivi Candidatures\'!J2:J2000,"Relance 1")+COUNTIF(\'Suivi Candidatures\'!J2:J2000,"Relance 2")'),
        ("Entretiens", '=COUNTIF(\'Suivi Candidatures\'!J2:J2000,"Entretien")'),
        ("Sans réponse", '=COUNTIF(\'Suivi Candidatures\'!J2:J2000,"Sans réponse")'),
        ("Taux de réponse %", '=IFERROR(ROUND(B3/B2*100,1),0)'),
    ]
    for i, (label, formula) in enumerate(rows, start=2):
        st[f"A{i}"] = label
        st[f"A{i}"].font = Font(bold=True)
        st[f"B{i}"] = formula
    st.column_dimensions["A"].width = 20
    st.column_dimensions["B"].width = 14
    st[f"A{len(rows)+3}"] = f"Créé le {datetime.now().strftime('%Y-%m-%d %H:%M')} — job-hunt skill"
    st[f"A{len(rows)+3}"].font = Font(italic=True, color="888888")

    safe_save(wb, output_path)
    print(f"Tracker créé : {output_path}")
    return output_path


if __name__ == "__main__":
    path = sys.argv[1] if len(sys.argv) > 1 else None
    try:
        create_tracker(path)
    except FileExistsError as e:
        print(f"ERREUR : {e}")
        sys.exit(1)
