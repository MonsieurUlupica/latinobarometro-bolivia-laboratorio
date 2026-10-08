# Análisis exhaustivo de Latinobarómetro Bolivia, 1996–2024

Este directorio contiene una auditoría reproducible y resultados derivados de las 23 bases nacionales disponibles. Las bases originales permanecen intactas. El análisis trata cada oleada como un corte transversal independiente y conserva separadas las familias de preguntas sobre distancia social, justificabilidad moral, saliencia de discriminación, matrimonio y derechos.

## Ejecución

Desde la raíz del proyecto, ejecutar:

```bash
Rscript Latinobarometro_historico_Bolivia/analisis_exhaustivo/analisis_exhaustivo.R
```

El script usa R base. El paquete `survey` es opcional y permite generar intervalos de sensibilidad parcial para 2023 y 2024 con `REG` y `COMDIST`. Esa aproximación no reconstruye todas las etapas ni cuotas del diseño oficial. Si `survey` no está instalado, las demás tablas y figuras se generan igualmente y la tabla de sensibilidad queda vacía.

## Archivos principales

- `DOSSIER_ANALITICO.md` presenta métodos, hallazgos, resultados por pregunta, cruces, modelo, no respuesta y límites de interpretación.
- `resultados/matriz_cobertura_constructos.csv` identifica las oleadas con preguntas directas y las familias de medición.
- `resultados/diccionario_mediciones_directas.csv` registra variables, enunciados, códigos sustantivos, reglas de no respuesta y comparabilidad.
- `resultados/auditoria_oleadas.csv` y `resultados/inventario_variables_todas_oleadas.csv` documentan filas, columnas, variables, duplicados, códigos candidatos y ponderadores.
- `resultados/auditoria_n_microdato_vs_documentacion.csv` contrasta los tamaños de microdato con los tamaños publicados en documentación oficial.
- `resultados/auditoria_diseno_y_fuentes.csv` reúne fuentes metodológicas y límites para estimar varianza.
- `resultados/auditoria_covariables_cruces.csv` conserva la trazabilidad de los predictores usados en las tablas de asociación.
- `resultados/distribucion_completa_respuestas.csv`, `resumen_indicadores_directos.csv` y `no_respuesta_y_limites_extremos.csv` presentan distribuciones, denominadores, intervalos de sensibilidad y análisis extremo de no respuesta.
- `resultados/cruces_descriptivos_completos.csv`, `tasas_objetivo_por_perfil.csv` y `pruebas_cruces_sensibilidad_srs.csv` contienen los cruces observados y sus pruebas SRS exploratorias, incluidos resultados nulos.
- `resultados/comparaciones_pareadas_derechos_2023.csv` y `perfiles_conjuntos_derechos_2023.csv` comparan respuestas de las mismas personas a los cuatro ámbitos de derechos.
- `resultados/modelo_2024_coeficientes.csv`, `modelo_2024_pruebas_conjuntas.csv` y `modelo_2024_resumen.csv` contienen el modelo logístico exploratorio de distancia social.
- `resultados/modelo_2024_sensibilidad_no_linealidad.csv` contrasta el supuesto lineal para edad e ideología frente a splines naturales.
- `resultados/resumen_modelos_ordinales_derechos_2023.csv`, `modelos_ordinales_derechos_2023_coeficientes.csv`, `modelos_ordinales_derechos_2023_pruebas_conjuntas.csv`, `modelos_multinomiales_derechos_2023_pruebas_conjuntas.csv` y `diagnosticos_proporcionalidad_odds_2023.csv` comparan modelos ordinales y multinomiales, con ajuste Holm y diagnóstico del supuesto de odds proporcionales.
- `resultados/matriz_afirmaciones.csv` vincula cada afirmación potencial con resultado, denominador, incertidumbre, tabla fuente y límite interpretativo.
- `resultados/registro_discrepancias.csv` y `auditoria_ids_duplicados.csv` hacen visibles los problemas de datos que requieren seguimiento.
- `figuras/` contiene cuatro gráficos regenerables desde las mismas bases.

## Reglas de lectura

Los porcentajes válidos describen el microdato disponible. Los intervalos Wilson y las pruebas etiquetadas SRS son sensibilidades bajo muestreo aleatorio simple, no inferencia de diseño. Las ponderaciones disponibles se reportan por separado y no sustituyen estratos, conglomerados, etapas o probabilidades de selección. Las cifras territoriales son descriptivas y las celdas pequeñas deben tratarse con cautela.

Las preguntas ordinales se conservan como distribuciones por categoría. No se combina toda la serie en un índice de tolerancia. La batería de derechos 2023 sí permite describir perfiles conjuntos y contrastes pareados. El diagnóstico de dimensionalidad es exploratorio, trata categorías ordinales como números y no reemplaza una CFA ordinal.

Los modelos ordinales 2023 ordenan la respuesta desde desacuerdo fuerte hasta acuerdo fuerte y usan casos completos para sexo, edad, educación, práctica religiosa, ideología e ingreso subjetivo. Los modelos multinomiales irrestrictos funcionan como sensibilidad cuando no es razonable imponer odds proporcionales. Sus pruebas e intervalos siguen siendo aproximaciones SRS, no estimaciones con diseño oficial.

En 2024 la respuesta `P3NOIJ.3` solo se considera válida cuando `P3NOIJ.9=0`. Los valores `P3NOIJ.3=0` de registros marcados como NS/NR no significan una respuesta sustantiva de no mención. En 2023 se conserva el código `-5` observado en los microdatos para NS/NR de los cuatro ítems, aunque cuestionario y codebook indican `0`.

La ficha técnica y el microdato no coinciden en el tamaño de 2000 ni de 2001. El análisis no altera filas para forzar la coincidencia. Debe aclararse con Latinobarómetro antes de una estimación cuyo marco dependa de esas bases. El codebook 2015 fue consultado en línea y debe archivarse localmente para que el expediente documental quede completo.

El dossier no modifica ni reemplaza el artículo, los archivos LaTeX, el análisis de prensa, SISOBS, EMH o Censo.

## Referencias metodológicas oficiales consultadas

- Fichas técnicas 1995–2015: <https://www.latinobarometro.org/documents/LAT-2015/latinobarometro-fichas-tecnicas-1995-2015.pdf>
- Ficha técnica 2000: <https://www.latinobarometro.org/documents/LAT-2000/fichatecnica-latinobarometro-2000.pdf>
- Ficha técnica 2001: <https://www.latinobarometro.org/documents/LAT-2001/fichatecnica-latinobarometro-2001.pdf>
- Informe metodológico 2016: <https://www.latinobarometro.org/documents/LAT-2016/informemetodologico-latinobarometro-2016.pdf>
- Informe metodológico 2018: <https://www.latinobarometro.org/documents/LAT-2018/informemetodologico-latinobarometro-2018.pdf>
- Informe metodológico 2020: <https://www.latinobarometro.org/documents/LAT-2020/latinobarometro-2020-metodologico.pdf>
- Ficha técnica 2024: <https://www.latinobarometro.org/documents/LAT-2024/latinobarometro-2024-fichas-tecnicas.pdf>
