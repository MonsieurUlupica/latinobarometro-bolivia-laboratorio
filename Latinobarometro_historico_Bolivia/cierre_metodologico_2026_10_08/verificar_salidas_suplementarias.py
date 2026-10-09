"""Comparar agregados recalculados con código publicado en el clon de prueba.

Ejecutar completar_cotejos.R y diagnostico_factorial.R dentro del clon antes.
No publica ni compara filas individuales; no sustituye validación científica.
"""
from pathlib import Path
import csv
import hashlib
import subprocess

here = Path(__file__).resolve().parent
clone = here / "clon_verificacion"
relative = Path("Latinobarometro_historico_Bolivia/cierre_metodologico_2026_10_08/resultados")
names = [
    "diccionario_covariables_historicas_50.csv",
    "perfil_covariables_historicas_homologadas.csv",
    "codigos_covariables_historicas_crudos.csv",
    "etiquetas_covariables_csvtext_2024.csv",
    "cruces_covariables_historicas.csv", "pruebas_covariables_historicas.csv",
    "cotejo_unidades_2018_2020.csv", "catalogo_UPM_cotejado_2018_2020.csv",
    "sensibilidad_todas_pendientes_bloques.csv", "diagnosticos_numericos_modelos.csv",
    "celdas_observadas_modelos.csv", "diagnostico_influencia_logistica_2024.csv",
    "factor_ordinal_2023_ajuste.csv", "factor_ordinal_2023_parametros.csv",
    "correlaciones_policoricas_2023.csv", "residuos_factor_ordinal_2023.csv",
    "factor_ordinal_2023_controles.csv",
]
head = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=clone, text=True).strip()
rows = []
for name in names:
    reference = here / "resultados" / name
    actual = clone / relative / name
    refhash = hashlib.sha256(reference.read_bytes()).hexdigest()
    newhash = hashlib.sha256(actual.read_bytes()).hexdigest()
    rows.append(dict(archivo=name, identico=refhash == newhash,
                     sha256_referencia=refhash, sha256_clon=newhash, commit_codigo=head))
with (here / "resultados/reproduccion_suplementaria_clon.csv").open("w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=list(rows[0]))
    writer.writeheader()
    writer.writerows(rows)
print(f"Salidas suplementarias idénticas: {sum(r['identico'] for r in rows)}/{len(rows)}")
assert all(r["identico"] for r in rows), "Investigar diferencias antes de afirmar reproducibilidad"
