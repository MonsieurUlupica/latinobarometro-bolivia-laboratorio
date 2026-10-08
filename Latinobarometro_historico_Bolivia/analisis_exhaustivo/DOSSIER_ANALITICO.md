# Dossier analítico exhaustivo de Latinobarómetro Bolivia, 1996–2024

**Estado:** análisis reproducible de 23 cortes transversales repetidos. No se editó el artículo ni ningún archivo LaTeX. Las bases originales se preservaron.

## Alcance y regla de evidencia

Se procesaron 23 oleadas y 26160 registros. Son muestras transversales independientes, no seguimiento de las mismas personas. 
El archivo `matriz_cobertura_constructos.csv` identifica qué años midieron directamente opiniones sobre homosexualidad, derechos o distancia social. Las demás oleadas sirven para describir contenido general del instrumento y no se les atribuye una opinión LGBTIQ+ no preguntada.

La documentación disponible no permite reconstruir, para cada año, probabilidades individuales de selección, PSU, estratos y todas las etapas. Varias fichas describen cuotas en la última etapa. Por eso los conteos y proporciones observados son el resultado principal; intervalos y pruebas SRS aparecen como sensibilidad exploratoria, nunca como errores estándar plenamente design-based. La ponderación del CSV se presenta por separado y no sustituye diseño muestral.

## Auditoría de las 23 oleadas

N total en microdatos = 26,160. La coincidencia filas/columnas frente al inventario previo fue 23/23 en filas y 23/23 en columnas. 
Las salidas `auditoria_oleadas.csv`, `inventario_variables_todas_oleadas.csv` y `codigos_candidatos_especiales.csv` documentan estructura, valores perdidos, duplicados candidatos y códigos raros sin etiquetarlos automáticamente como no respuesta.

Aparecen dos filas con `NUMENTRE` repetido en 2002 y otras dos en 2006; no son filas idénticas. Se conservan sin deduplicación, ya que corregirlas requiere el archivo de origen o respuesta del custodio. En 1996 no se identificó `NUMENTRE` ni `NUMINVES` inequívoco. La auditoría de tamaños detectó una discrepancia mayor en 2000, cuyo CSV tiene 1.080 filas y código de país 68 en todas, frente a 1.000 casos en la ficha; en 2001 el CSV tiene 1.075 frente a 1.080 en la ficha. Se exponen en `auditoria_n_microdato_vs_documentacion.csv` y `registro_discrepancias.csv`, sin ajustar los conteos del archivo.
En 2000 no hay columna de ponderación en el CSV. Los pesos candidatos son constantes 1 en la mayoría de las oleadas y variables en 1998 y 2002–2005. La ficha 2016 indica que el ponderador no aplica y su WT constante vale 1.

La matriz `matriz_documentacion_local.csv` lista cuestionarios y libros de códigos encontrados en el proyecto. Hay cuestionario local para 22 de 23 oleadas y codebook local para 7. Para 2015 se usó el codebook oficial en línea, que deberá archivarse antes del cierre editorial; 2009 no tiene cuestionario ni codebook local identificado. Las brechas documentales no se rellenaron por analogía.

## Cobertura de mediciones directas

Hay nueve oleadas con una o más preguntas directas: 1998, 2002, 2004, 2006, 2008, 2010, 2015, 2023 y 2024. Las otras catorce no contienen una medición directa localizada en los cuestionarios disponibles. La matriz de cobertura separa las cinco familias de medición.

| Familia | Oleadas | Interpretación permitida |
|---|---|---|
| Distancia social | 1998, 2024 | Mención de homosexuales entre grupos no deseados como vecinos; las baterías no son idénticas |
| Justificación moral | 2002, 2004, 2008 | Escala ordinal 1–10, donde 1 nunca se justifica y 10 siempre se justifica |
| Saliencia de discriminación | 2006, 2008 | Selección única de una categoría; no mide experiencia propia ni incidencia |
| Matrimonio igualitario | 2010, 2015, 2023 | Escala de acuerdo de cuatro categorías; cortes separados |
| Cuatro ámbitos de derechos | 2023 | Adopción, matrimonio, reconocimiento documental y parentalidad, mismas personas |

Las otras oleadas no se imputaron ni usaron para crear una tendencia. La cobertura completa de variables, documentación y comparabilidad está en los CSV del dossier.

## Resultados descriptivos

### Matrimonio entre personas del mismo sexo

| Año | Acuerdo 1–2 (no ponderado) | Conteo / N válido | No respuesta | IC95 SRS de sensibilidad |
|---:|---:|---:|---:|---:|
| 2010 | 19.5% | 199 / 1020 | 15.0% | 17.2–22.1% |
| 2015 | 15.3% | 165 / 1078 | 10.2% | 13.3–17.6% |
| 2023 | 29.8% | 348 / 1167 | 2.8% | 27.3–32.5% |

Las tres oleadas comparten el ámbito y una escala de cuatro categorías, aunque la redacción de 2010 dice ‘matrimonio entre homosexuales’ y la de 2015/2023 ‘personas del mismo sexo’. La no respuesta también se codifica de forma distinta. La trayectoria descriptiva no es lineal. Los contrastes SRS entre años y su corrección Holm se publican en `comparaciones_matrimonio_sensibilidad_srs.csv`; no son inferencia de diseño ni seguimiento individual.

### Justificación moral de la homosexualidad

| Año | Media ponderada | Mediana | Respuestas 1–4 ponderadas | Punto 5 ponderado | Respuestas 6–10 ponderadas | N válido |
|---:|---:|---:|---:|---:|---:|---:|
| 2002 | 2.38 | 1 | 83.3% | 4.5% | 12.2% | 1109 |
| 2004 | 3.32 | 3 | 68.2% | 13.1% | 18.6% | 999 |
| 2008 | 4.22 | 5 | 49.8% | 21.5% | 28.7% | 1052 |

La escala mide justificabilidad moral percibida, no aprobación de derechos ni conducta. La comparación Kruskal–Wallis y pares Wilcoxon es una sensibilidad entre cortes independientes. Ver resultados `pruebas_serie_justificacion_sensibilidad.csv` y `comparaciones_pareadas_no_mismas_personas_justificacion.csv`.

### Diferencias entre cuatro ámbitos en 2023

| Variable | Acuerdo 1–2 (no ponderado) | Conteo / N válido | No respuesta | IC95 SRS de sensibilidad |
|---|---:|---:|---:|---:|
| P37CSN.A | 31.1% | 363 / 1168 | 2.7% | 28.5–33.8% |
| P37CSN.B | 29.8% | 348 / 1167 | 2.8% | 27.3–32.5% |
| P37CSN.F | 43.1% | 493 / 1143 | 4.8% | 40.3–46.0% |
| P37WVSCS.H | 39.5% | 415 / 1050 | 12.5% | 36.6–42.5% |

Los contrastes pareados (McNemar sobre acuerdo/desacuerdo y Wilcoxon sobre categorías ordinales) se basan en las mismas personas con respuesta válida en ambos ítems. Los seis contrastes, celdas discordantes y p ajustadas están en `comparaciones_pareadas_derechos_2023.csv`. Los perfiles binarios de respuesta conjunta de 16 combinaciones están en `perfiles_conjuntos_derechos_2023.csv`.

El diagnóstico exploratorio de dimensión común dio N completo=1009; alpha exploratorio=0.79; proporción del primer componente=61.9%. Usa las cuatro respuestas ordinales como números para un diagnóstico inicial y no es un CFA ordinal; no se crea un índice. Correlaciones y diagnóstico están en los archivos `correlaciones_spearman_derechos_2023.csv` y `diagnostico_dimension_comun_2023.csv`.

Entre los 1.009 casos que contestaron los cuatro ítems, 367 (36.4%) rechazaron los cuatro y 159 (15.8%) acordaron con los cuatro. Los 483 restantes (47.9%) combinaron acuerdo y desacuerdo según el derecho. La distribución de los 16 perfiles está en `perfiles_conjuntos_derechos_2023.csv`. Esta heterogeneidad dentro de la misma persona es incompatible con describir la respuesta como una única postura uniforme.

Los contrastes pareados muestran que el acuerdo con reconocimiento documental supera al de adopción en 11.6 puntos y al de matrimonio en 12.8 puntos; ambos contrastes McNemar mantienen p<0,001 tras Holm. Parentalidad también supera adopción y matrimonio, en 7.1 y 8.2 puntos, respectivamente. Matrimonio y adopción no muestran diferencia pareada clara. Estos contrastes cuantifican aceptación diferenciada por ámbito, bajo sensibilidad SRS.

### Distancia social y saliencia pública

En 1998, 426 de 794 respuestas válidas (53.7%; IC95 SRS 50.2–57.1%) mencionaron homosexuales como vecinos no deseados. En 2024, 287 de 1026 respuestas válidas (28.0%; IC95 SRS 25.3–30.8%) lo hicieron. La sensibilidad parcial con REG como estrato y COMDIST como conglomerado en 2024 da IC95 25.0–30.9%. El contraste entre 1998 y 2024 no se presenta como cambio temporal homogéneo porque la batería y el tratamiento de no respuesta difieren.

En 2006, 14 de 1161 respuestas sustantivas (1.2%; IC95 SRS 0.7–2.0%) eligieron la opción ‘por ser homosexual’ en una pregunta de respuesta única sobre trato desigual. En 2008, 11 de 1056 respuestas sustantivas (1.0%; IC95 SRS 0.6–1.9%) identificaron a homosexuales como el grupo más discriminado. Son constructos de saliencia diferentes y no estiman la frecuencia de discriminación vivida.

La tabla `distribucion_completa_respuestas.csv` presenta todas las categorías crudas, incluyendo códigos especiales, con conteos y porcentajes. Las categorías sustantivas incluyen IC95 Wilson bajo sensibilidad SRS; los códigos especiales quedan visibles y fuera de esos intervalos. Los resultados descriptivos territoriales están incluidos en los cruces; los códigos `REG` se etiquetan con el codebook oficial y se advierte sobre celdas pequeñas.

## Asociaciones, modelos y pruebas

`cruces_descriptivos_completos.csv` contiene tablas completas para sexo y edad en las oleadas con medición directa, más ideología, religión, práctica religiosa, ingreso subjetivo, clase, educación y territorio para 2023/2024 cuando esos campos están disponibles. `auditoria_covariables_cruces.csv` conserva el nombre y la regla de cada predictor. `pruebas_cruces_sensibilidad_srs.csv` registra estadístico, p, mínimo esperado y prueba utilizada. Los p-values se ajustan por Holm dentro de cada familia año-constructo. Para celdas esperadas pequeñas se marca la limitación o se usa Fisher en tablas 2×2.

El modelo logístico 2024 estima asociaciones entre mención de distancia social y sexo, edad, educación, práctica religiosa, ideología, ingreso/clase y conteo de otros grupos excluidos. El conteo se construye excluyendo el grupo objetivo y la categoría de sustancias/alcohol, para evitar parte-todo y la categoría de altísima prevalencia. Es un modelo no ponderado de casos completos, con intervalo Wald/modelo bajo supuestos SRS y no causal. Se compararon especificaciones lineales con splines naturales para edad e ideología; las p ajustadas de no linealidad son edad_decadas p Holm=0.676; ideologia p Holm=0.544. Coeficientes y diagnósticos están en `modelo_2024_coeficientes.csv`, `modelo_2024_pruebas_conjuntas.csv`, `modelo_2024_sensibilidad_no_linealidad.csv` y `modelo_2024_resumen.csv`.

### Modelos ordinales de derechos en 2023

Además del cruce dicotómico, se estimaron modelos ordinales logísticos para cada pregunta en los casos completos de sexo, edad, educación, práctica religiosa, ideología e ingreso (N entre 798 y 881). El orden del resultado va de desacuerdo fuerte a acuerdo fuerte. La prueba de odds proporcionales, contrastada con un modelo multinomial y ajustada por Holm para los cuatro ítems, no rechaza el supuesto en ninguno (p ajustadas: P37CSN.A p Holm=0.100; P37CSN.B p Holm=0.181; P37CSN.F p Holm=0.335; P37WVSCS.H p Holm=0.100). Esto no demuestra que el supuesto sea correcto. Como sensibilidad más flexible, las pruebas multinomiales ajustadas por Holm para 24 asociaciones identifican edad en adopción y sexo y edad en matrimonio (P37CSN.A/edad (p Holm=5.41e-04); P37CSN.B/sexo (p Holm=8.33e-04); P37CSN.B/edad (p Holm=2.43e-04)). No aparece una asociación ajustada estable para reconocimiento documental ni parentalidad; por eso las diferencias bivariadas de parentalidad por sexo/edad se interpretan como sugestivas, no robustas al ajuste. Los coeficientes, pruebas conjuntas, diagnósticos y tamaños completos están en `modelos_ordinales_derechos_2023_coeficientes.csv`, `modelos_ordinales_derechos_2023_pruebas_conjuntas.csv`, `modelos_multinomiales_derechos_2023_pruebas_conjuntas.csv`, `diagnosticos_proporcionalidad_odds_2023.csv` y `resumen_modelos_ordinales_derechos_2023.csv`. Todas son sensibilidades SRS sin diseño completo.

### Resultados interpretables de los cruces

En 2023, el acuerdo con matrimonio es 36.0% entre mujeres y 23.8% entre hombres; para la afirmación sobre parentalidad es 45.5% y 33.9%. Las pruebas SRS ajustadas por Holm identifican diferencias por sexo registrado en matrimonio (p ajustada <0,001) y parentalidad (p ajustada <0,01), no en todos los derechos. Por edad, las diferencias también se concentran en adopción (43.5% en 15–29 frente a 17.2% en 45–59), matrimonio (39.8% en 15–29 frente a 14.1% en 60+) y parentalidad (48.3% en 15–29 frente a 31.1% en 60+). Son asociaciones entre grupos de una muestra de cuotas; no efectos causales ni estimaciones design-completas.

En 2024, la mención de homosexuales como vecinos no deseados alcanza 34.7% entre hombres y 21.1% entre mujeres. El modelo ajustado estima para mujeres OR=0.50 (IC95 modelo 0.36–0.69), con p de Wald SRS=2.33e-05; la prueba conjunta del predictor da p Holm=1.39e-04. La relación persiste al ajustar covariables observadas. El resultado describe sexo registrado, no identidad de género.

El conteo de otros grupos rechazados se asocia positivamente con distancia social en el modelo 2024. Por cada grupo adicional, OR=1.26 (IC95 modelo 1.07–1.49); la prueba conjunta del predictor mantiene p Holm=3.59e-02. El patrón es compatible con una dimensión más amplia de exclusión social, sin establecer causalidad ni validar un índice.

Por departamento, en 2024 las proporciones descriptivas con n≥30 van de 22.0% en Cochabamba (n=182) a 36.6% en Beni (n=41). La prueba global de territorio no se sostiene tras Holm (p ajustada=1.000) y hay celdas pequeñas. En 2023 aparece una asociación territorial SRS con reconocimiento documental (p Holm=0.042), también sujeta a cuotas y a la reconstrucción incompleta del diseño. El contraste departamental queda como hallazgo descriptivo a validar, no como conclusión inferencial.

## No respuesta y sensibilidad

Para cada pregunta con resultado dicotómico se informa no respuesta y límites extremos del porcentaje objetivo sobre N total, asignando hipotéticamente todas las respuestas no válidas a no-evento o evento. Para las escalas ordinales de justificabilidad no se impone un punto de corte. `no_respuesta_y_limites_extremos.csv` muestra medias observadas y escenarios en que todas las respuestas faltantes equivaldrían al extremo 1 o al extremo 10. No se imputa opinión. `no_respuesta_por_perfil.csv` permite identificar perfiles con no respuesta diferencial. En 2023 los ítems de derechos tienen no respuesta distinta, especialmente parentalidad; por ello se muestran tanto denominadores por ítem como el tamaño completo de las comparaciones pareadas.

La no respuesta en parentalidad alcanza 150/1.200 (12,5%), frente a 2,7% en adopción, 2,8% en matrimonio y 4,8% en reconocimiento documental. En el ítem de parentalidad fue 9.7% entre hombres y 15.3% entre mujeres, y 7.8% en 15–29 frente a 17.3% en 45–59. Las diferencias por sexo y edad se mantienen en pruebas SRS con Holm dentro del ítem (p=0.024 y 0.007). Los porcentajes válidos de parentalidad podrían, por ello, no representar sin sesgo a quienes contestaron menos; no se imputa su posición.

La sensibilidad `sensibilidad_diseno_parcial_2023_2024.csv` usa `REG` como estrato y `COMDIST` como conglomerado si el paquete `survey` está disponible. No reconstruye selección por etapas ni cuotas, por lo que no debe citarse como intervalo oficial de diseño.

## Discrepancias verificadas y límites de afirmación

1. El microdato 2023 usa -5 en las cuatro preguntas de derechos donde cuestionario y codebook indican 0 para NS/NR. Se excluye -5 del denominador sustantivo y se preserva el código en los resultados crudos.
2. En 2023, la edad observada en la muestra boliviana va de 18 a 84 años, mientras la etiqueta agrupada REEDAD del codebook empieza en 16–25. No se atribuye la diferencia a errores de entrevista; se documenta para cotejar con la ficha país.
3. Los ponderadores candidatos varían solo en algunas bases. En 2000 no hay campo de peso; en 2016 WT=1 y la documentación indica que no aplica. No se asume que un campo llamado WT garantice la reconstrucción del diseño.
4. Las fichas de 2024 describen muestreo de cuatro etapas con cuotas en la última. Las cuotas restringen el alcance de la inferencia probabilística convencional.
5. La variable P46STM de 2006 y P68ST de 2008 pregunta qué se percibe públicamente, no si el encuestado o una persona LGBTIQ+ vivió discriminación.
6. No se infiere tamaño de población LGBTIQ+, prevalencia de violencia, experiencia directa, causa de actitudes ni efecto de medios de comunicación.

## Estado de cierre metodológico

La auditoría de integridad cubre las 23 bases disponibles y verifica filas y columnas contra el inventario; las familias de preguntas directas, sus códigos de respuesta y denominadores están trazados en el diccionario y archivos de cobertura. Se ejecutaron distribuciones, pruebas pareadas, cruces exhaustivos para los predictores preseleccionados, un barrido exploratorio con ajuste Holm, modelos ordinales/multinomiales para derechos 2023 y una logística para distancia social 2024. El código regenera tablas y figuras desde los CSV originales.

La investigación todavía no alcanza un cierre inferencial plenamente defendible. Hay 2000 y 2001 con tamaños de microdato distintos de sus fichas; no se deben tratar como poblaciones muestrales resueltas. Para ninguna oleada se reconstruyó con certeza todo el diseño oficial a partir de los archivos disponibles. El codebook 2015 aún debe archivarse localmente, 2009 carece de documentación local identificada y la medición común de derechos 2023 no cuenta con una CFA ordinal. En consecuencia, los modelos y pruebas se reportan como sensibilidades SRS, no como estimaciones de diseño oficial. Estas tareas pendientes se detallan en `registro_discrepancias.csv`, `matriz_documentacion_local.csv` y `auditoria_diseno_y_fuentes.csv`.

## Argumentos sostenibles para el artículo

- Los datos no justifican un índice general de ‘tolerancia’ para todas las oleadas. Sí justifican describir familias de preguntas separadas y mostrar perfiles de respuesta por ámbito en 2023.
- La aceptación de matrimonio presenta variación no lineal en los cortes 2010, 2015 y 2023. La afirmación debe limitarse a las respuestas observadas en esas muestras hasta resolver la incertidumbre de diseño.
- En 2023 puede evaluarse empíricamente si el acuerdo cambia según el derecho. Esta comparación dentro de personas es el núcleo menos intuitivo y más fuerte del conjunto.
- La baja selección de homosexualidad en respuestas únicas de saliencia (2006/2008) no demuestra baja discriminación; señala que el tema aparece con baja frecuencia relativa frente a otras categorías en esas preguntas.
- La distancia social en 2024 puede examinarse asociativamente por perfil y en relación con una pauta más amplia de rechazo, sin interpretación causal.

## Archivos de salida y reproducción

El dossier es regenerable desde los CSV originales. Todos los CSV resultantes están en `resultados/`, las figuras en `figuras/`, y la guía de ejecución en `README.md`. Ejecutar desde la raíz del proyecto:

```bash
Rscript Latinobarometro_historico_Bolivia/analisis_exhaustivo/analisis_exhaustivo.R
```

Las tablas que más conviene abrir para discutir son `resumen_indicadores_directos.csv`, `distribucion_completa_respuestas.csv`, `cruces_descriptivos_completos.csv`, `comparaciones_pareadas_derechos_2023.csv`, `perfiles_conjuntos_derechos_2023.csv`, `modelos_multinomiales_derechos_2023_pruebas_conjuntas.csv`, `modelo_2024_coeficientes.csv`, `auditoria_diseno_y_fuentes.csv`, `matriz_afirmaciones.csv` y `registro_discrepancias.csv`.
