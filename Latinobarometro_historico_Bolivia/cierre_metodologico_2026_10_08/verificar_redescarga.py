"""Verifica un clon separado con 23 CSV redescargados; no redistribuye originales.

Antes de ejecutar: clonar el repositorio en cierre_metodologico_2026_10_08/clon_verificacion.
La documentación de terceros se aporta desde el expediente local; no se afirma
redescarga independiente de esos documentos. Requiere curl y Rscript en PATH.
"""
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
import csv
import hashlib
import io
import json
import shutil
import subprocess
import zipfile

here = Path(__file__).resolve().parent
project = here.parent.parent
clone = here / "clon_verificacion"
assert (clone / ".git").exists(), "Primero crear el clon de verificación"
root = "Latinobarometro_historico_Bolivia"
with (project / root / "inventario_archivos.csv").open() as f:
    inventory = list(csv.DictReader(f))

def download(row):
    y = row["anio"]
    url = f"https://www.latinobarometro.org/documents/LAT-{y}/latinobarometro-{y}-bolivia-csv-esp-v1.zip"
    arc = clone / root / "datos_originales" / f"redescarga_{y}.zip"
    arc.parent.mkdir(parents=True, exist_ok=True)
    if not arc.exists() or not zipfile.is_zipfile(arc):
        cp = subprocess.run(["curl", "--silent", "--show-error", "--location", "--fail", "--retry", "2", "--max-time", "60", url, "-o", str(arc)], capture_output=True, text=True)
        if cp.returncode:
            return {"anio": y, "url": url, "estado": "error_descarga", "detalle": cp.stderr.strip(), "sha256_coincide": False}
    with zipfile.ZipFile(arc) as z:
        names = [n for n in z.namelist() if n.lower().endswith(".csv")]
        assert len(names) == 1, (y, names)
        content = z.read(names[0])
    refs = list((project / root / "datos_extraidos" / y).glob("*.csv"))
    assert len(refs) == 1, (y, refs)
    ref = refs[0]
    target = clone / root / "datos_extraidos" / y / ref.name
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(content)
    actual = hashlib.sha256(content).hexdigest()
    expected = hashlib.sha256(ref.read_bytes()).hexdigest()
    print(y, actual == expected, flush=True)
    return {"anio": y, "url": url, "estado": "descargado", "detalle": "CSV del ZIP oficial", "sha256_coincide": actual == expected, "sha256_actual": actual, "sha256_referencia": expected}

with ThreadPoolExecutor(max_workers=4) as pool:
    checks = list(pool.map(download, inventory))
out = here / "resultados"
fields = ["anio", "url", "estado", "detalle", "sha256_coincide", "sha256_actual", "sha256_referencia"]
with (out / "verificacion_redescarga_23.csv").open("w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=fields)
    writer.writeheader()
    writer.writerows(checks)
assert all(c["sha256_coincide"] for c in checks), "Revisar entradas distintas o descargas fallidas antes de ejecutar"

# Aporte explícito de documentación local, conservando todos los textos fuera
# de la publicación. Solo las entradas CSV son redescargadas en esta prueba.
for relative in [Path(root)/"documentacion", Path(root)/"cierre_metodologico_2026_10_08"/"documentacion"]:
    target = clone / relative
    target.mkdir(parents=True, exist_ok=True)
    for src in (project / relative).glob("*.pdf"):
        shutil.copy2(src, target / src.name)
extra = Path("04_Hallazgos_y_Analisis/bibliografia_textos/descargas_abiertas/Latinobarometro_2009_Libro_Codigos_Oficial.pdf")
(clone / extra).parent.mkdir(parents=True, exist_ok=True)
shutil.copy2(project / extra, clone / extra)
script = Path(root)/"analisis_exhaustivo"/"analisis_exhaustivo.R"
assert (clone / script).read_bytes() == (project / script).read_bytes(), "El código clonado difiere de la referencia local"
subprocess.run(["Rscript", str(script)], cwd=clone, check=True)
outputs = []
for ref in sorted((project / root / "analisis_exhaustivo/resultados").glob("*.csv")):
    regenerated = clone / root / "analisis_exhaustivo/resultados" / ref.name
    actual = hashlib.sha256(regenerated.read_bytes()).hexdigest()
    expected = hashlib.sha256(ref.read_bytes()).hexdigest()
    outputs.append({"archivo": ref.name, "identico": actual == expected, "sha256_actual": actual, "sha256_referencia": expected})
with (out / "reproduccion_clon_redescarga.csv").open("w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=list(outputs[0]))
    writer.writeheader()
    writer.writerows(outputs)
print(json.dumps({"entradas_identicas": sum(c["sha256_coincide"] for c in checks), "salidas_identicas": sum(c["identico"] for c in outputs), "salidas_comparadas": len(outputs)}))
assert all(c["identico"] for c in outputs), "Investigar discrepancias de salidas"
