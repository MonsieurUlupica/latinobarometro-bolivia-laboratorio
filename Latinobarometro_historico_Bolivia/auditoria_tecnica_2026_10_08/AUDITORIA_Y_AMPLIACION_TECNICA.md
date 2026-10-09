# Auditoría del análisis y ampliación técnica del artículo

> Estado histórico de la primera auditoría. El cierre posterior actualiza cuatro cotejos muestrales, la etiqueta −5, el código principal y los diagnósticos. Consultar `../cierre_metodologico_2026_10_08/INFORME_CIERRE_METODOLOGICO.md` para pendientes vigentes. Las observaciones de este informe no se presentan como el estado final del laboratorio.

Fecha de revisión 8 de octubre de 2026.

## Alcance y estado

Se revisaron el código del análisis exhaustivo, sus 41 tablas CSV, el borrador y documentación oficial de muestreo. Se ejecutó una verificación independiente en R 4.5.0 y se generaron once tablas de auditoría. Las bases originales y las salidas anteriores permanecen intactas. Este informe distingue resultados recalculados, errores de clasificación de salidas y tareas que todavía requieren documentación. No certifica una auditoría científica cerrada de las 23 oleadas.

Actualización editorial del mismo día: el autor autorizó expresamente una versión de 20–22 páginas de cuerpo que excede las extensiones específicas por apartado. Los hallazgos auditados se incorporaron al archivo LaTeX abierto, compilado con 22 páginas de cuerpo, 14 cuadros y cuatro figuras. El detalle de paginación, tipografía y alcance se registra en `04_Hallazgos_y_Analisis/CONTROL_AJUSTE_CONVOCATORIA.md`. Los productos posibles y prioridades enumerados más abajo conservan su condición de agenda analítica; no se confunden con una certificación de cierre.

Los archivos derivados se encuentran en `resultados/`. El script `verificacion_independiente.R` reconstruye esta verificación desde los CSV nacionales originales y las salidas anteriores. Ejecutar desde la raíz del proyecto mediante `Rscript Latinobarometro_historico_Bolivia/auditoria_tecnica_2026_10_08/verificacion_independiente.R`.

## Hallazgos que deben preceder a la ampliación editorial

### Cobertura omitida en 2009

El libro de códigos oficial de 2009, archivado en `04_Hallazgos_y_Analisis/bibliografia_textos/descargas_abiertas/Latinobarometro_2009_Libro_Codigos_Oficial.pdf`, identifica P63WVSST como pregunta de justificabilidad de la homosexualidad. Su escala tiene extremos 1 y 10 y códigos especiales negativos. La base nacional contiene la variable. El análisis anterior no la incluyó en su lista de ítems. Por tanto, la cobertura de nueve oleadas y trece ítems no puede presentarse como inventario completo de las mediciones pertinentes.

El recálculo añade una décima oleada y un decimocuarto ítem. El conjunto de esas diez bases reúne 11.637 registros. Esto no significa haber terminado de buscar todos los ítems potenciales de las 23 bases. La comparabilidad del contexto de aplicación de 2009 requiere revisión adicional del cuestionario.

| Año | N original | N válido | No válido | Mediana | Respuestas 1–4 n (%) | Respuesta 5 n (%) | Respuestas 6–10 n (%) |
|---|---:|---:|---:|---:|---:|---:|---:|
| 2002 | 1.242 | 1.109 | 133 | 1 | 897 (80,9) | 63 (5,7) | 149 (13,4) |
| 2004 | 1.201 | 999 | 202 | 3 | 660 (66,1) | 138 (13,8) | 201 (20,1) |
| 2008 | 1.200 | 1.052 | 148 | 5 | 524 (49,8) | 226 (21,5) | 302 (28,7) |
| 2009 | 1.200 | 1.051 | 149 | 4 | 549 (52,2) | 262 (24,9) | 240 (22,8) |

Los porcentajes de esta tabla son no ponderados y usan respuestas válidas. La media codificada de 2009 es 4,106. La no respuesta/codificación no válida es 149/1.200, equivalente a 12,4%. Las respuestas 6–10 pasan descriptivamente de 28,7% en 2008 a 22,8% en 2009. Este dato impide resumir toda la secuencia disponible como aumento uniforme. No identifica una reversión poblacional causal. Deben cotejarse cobertura, selección y contexto antes de un contraste temporal ampliado. Los puntos de corte 1–4, 5 y 6–10 son resúmenes descriptivos, no umbrales validados de tolerancia.

### Conteos de los ítems anteriores

Los trece ítems del análisis anterior se recalcularon de forma independiente. Coinciden todos sus denominadores válidos y los diez numeradores de eventos definidos. Las tres preguntas morales no tienen un evento binario impuesto. Este control respalda sus conteos, no todos sus supuestos inferenciales ni la exhaustividad del corpus.

### Umbrales exportados como efectos de predictores

La tabla previa `modelos_ordinales_derechos_2023_coeficientes.csv` contiene 80 filas. Doce son umbrales del modelo ordinal, tres por ítem. El filtro `grepl("\\|", ..., fixed=TRUE)` busca una barra precedida literalmente por una barra invertida y no elimina los términos `4|3`, `3|2` y `2|1`.

Las doce filas no son odds ratios de covariables. Quedan separadas en `umbrales_ordinales_separados.csv`, conservando estimación y error estándar como parámetros de corte. Las 68 filas restantes, 17 coeficientes por modelo, quedan en `coeficientes_ordinales_sin_umbrales.csv`. Se recalculó Holm dentro de cada ítem exclusivamente sobre esas 17 pendientes. No se volvió a estimar el ajuste ordinal en esta verificación. Las 24 pruebas por bloques de predictores son otra familia y no dependen de este filtro.

### Identificadores y perfiles automáticos

La auditoría previa registró 1.080 filas con identificador repetido en 2000 al usar NUMINVES como alternativa de NUMENTRE. NUMINVES identifica el estudio/oleada, no una persona. Ese conteo no prueba duplicación de entrevistas. La salida nueva lo marca como identificador individual no verificado y conserva las filas. Los candidatos repetidos de NUMENTRE en 2002 y 2006 requieren cotejo documental y no autorizan borrar registros.

La salida automática de perfiles de las 23 muestras busca EDAD y luego REEDAD. En varias ediciones la edad está en variables S; REEDAD puede representar bandas, no años cumplidos. Tampoco es válido homologar S12 como sexo en todas las oleadas. Los cruces sustantivos tienen un mapa específico diferente. La tabla automática no debe publicarse como descripción demográfica armonizada. Hay que construir un diccionario por año que distinga edad exacta, intervalos, categoría especial y sexo registrado, sin calcular medianas de edad sobre códigos de intervalos.

### Comparación ordinal estricta de los derechos

La prueba Wilcoxon pareada anterior utiliza las diferencias entre códigos 1–4. Sus rangos dependen de esas distancias. Para una sensibilidad que utiliza exclusivamente el orden se añadió una prueba exacta de signos, contando qué ítem recibe más acuerdo en cada persona y excluyendo empates del contraste.

| Comparación A–B | Pares válidos | Más acuerdo en A | Más acuerdo en B | Empates | p de signos ajustada Holm |
|---|---:|---:|---:|---:|---:|
| Adopción–matrimonio | 1.150 | 155 | 144 | 851 | 0,563 |
| Adopción–reconocimiento | 1.124 | 159 | 352 | 613 | <0,001 |
| Adopción–parentalidad | 1.040 | 129 | 287 | 624 | <0,001 |
| Matrimonio–reconocimiento | 1.124 | 137 | 353 | 634 | <0,001 |
| Matrimonio–parentalidad | 1.041 | 126 | 292 | 623 | <0,001 |
| Reconocimiento–parentalidad | 1.022 | 242 | 198 | 582 | 0,080 |

Holm abarca seis contrastes de signos. Las cuatro brechas principales se mantienen bajo esta sensibilidad. Reconocimiento frente a parentalidad obtiene p bruta 0,040 y p ajustada 0,080. Su resultado anterior de McNemar binario ajustado 0,047 y Wilcoxon ajustado 0,028 no constituye robustez entre todos los métodos. Los contrastes describen objetos estadísticos distintos. La ausencia de significación tampoco demuestra equivalencia. Todas estas pruebas presuponen independencia entre participantes y carecen del ajuste al diseño oficial.

### Pruebas escasas y selección de modelos

La salida anterior reúne 61 cruces/pruebas principales, 59 pruebas de no respuesta, 24 pruebas por bloques ordinales y 24 multinomiales. Son registros de pruebas, no cantidades de tablas independientes. De los 61 cruces, nueve presentan mínimo esperado menor que cinco, 46 no presentan esa marca y seis son Kruskal–Wallis, para los cuales el diagnóstico de frecuencias esperadas no aplica.

El filtro previo utiliza Fisher solo para tablas 2×2 escasas. Las tablas mayores con celdas escasas siguen requiriendo agrupación teórica justificable o sensibilidad exacta/Monte Carlo. No deben convertirse en afirmaciones poblacionales mediante una p de Pearson aislada. Las familias de Holm deben acompañar cada resultado y no mezclarse entre coeficientes, predictores y resultados.

El contraste ordinal frente a multinomial obtiene p brutas 0,025 en adopción y 0,033 en parentalidad. Después de Holm sobre cuatro modelos no rechaza el supuesto en ninguna pregunta. La descripción técnica debe presentar ambas cifras, convergencia y grados de libertad. La falta de rechazo ajustado no demuestra pendientes proporcionales. Esta auditoría no vuelve a ajustar los modelos multinomiales ni valida su especificación completa.

## Muestreo original documentado

Se archivaron la ficha oficial consolidada 1995–2015 y la ficha de 2024. Se inspeccionó visualmente la fila boliviana de la consolidada, porque sus celdas combinadas no se asignan correctamente mediante una lectura lineal automática del PDF. La matriz nueva tiene 23 filas, 18 con descripción cotejada y cinco con cotejo país pendiente. Esta clasificación es más precisa que repetir una advertencia idéntica para todos los años.

| Ediciones | Selección publicada, resumida | Cobertura declarada en la consolidada |
|---|---|---|
| 1996 | Tres etapas probabilísticas | 32% |
| 1997 | Dos etapas probabilísticas y cuota final | 32% |
| 1998 | Dos etapas probabilísticas y cuota final | 35% |
| 2000 | Dos etapas probabilísticas y cuota final | 52% |
| 2001 | Tres etapas probabilísticas | 52% |
| 2002–2005 | Dos etapas probabilísticas y cuota final | 100% |
| 2006 | Etapas probabilísticas diferenciadas entre área urbana y rural y cuota final | 100% |
| 2007–2013 disponibles | Tres etapas probabilísticas y cuota final | 100% |
| 2015 | Estratificación y asignación proporcional, selección multietápica y cuota final | 100% |
| 2024 | Cuatro etapas totales, tres probabilísticas y una final por cuotas | 100% de población adulta |

Los porcentajes son declaraciones del documento oficial, no estimaciones nuevas de esta auditoría. No equivalen a tasas de respuesta ni demuestran ausencia de sesgo. La cobertura de 1998 no coincide con la de 2024. Esta diferencia se suma a los cambios de batería y a la no respuesta al limitar la comparación de distancia social. El 100% posterior describe cobertura declarada, no selección plenamente probabilística de cada entrevistado.

Para 2024, la ficha señala entrevistas cara a cara, empresa IPSOS CIESMORI, N=1.200 y campo del 27 de agosto al 22 de septiembre. La nota metodológica identifica población adulta de 18 años y más. La documentación publicada no permite deducir que COMDIST sea una unidad primaria de muestreo. Se mantiene como aproximación geográfica en las sensibilidades anteriores, sin llamarla reconstrucción oficial.

Persisten las discrepancias N=1.080 en microdato frente a 1.000 en ficha de 2000 y N=1.075 frente a 1.080 en 2001. No se alteran los registros. Para 2016, 2017, 2018, 2020 y 2023 todavía falta esta verificación país a país en la matriz nueva. La consulta web de 2023 no localizó una ficha de país en los enlaces visibles y no prueba que no exista. Los informes metodológicos de 2016 y 2020 excedieron el límite de recuperación del navegador y el de 2018 devolvió timeout. No se reconstruyen sus diseños por analogía.

Fuentes oficiales archivadas y consultadas:

- [Ficha técnica consolidada 1995–2015](https://www.latinobarometro.org/documents/LAT-2015/latinobarometro-fichas-tecnicas-1995-2015.pdf), página física 1, fila Bolivia.
- [Ficha técnica 2024](https://www.latinobarometro.org/documents/LAT-2024/latinobarometro-2024-fichas-tecnicas.pdf), páginas físicas 1–2.
- [Datos y documentación 2023](https://www.latinobarometro.org/latinobarometro-2023).

## Cuadros técnicos que la evidencia permite desarrollar

El catálogo siguiente contiene 20 productos tabulares posibles. Es una propuesta de organización basada en salidas reales. No afirma que ya se hayan diagramado veinte cuadros ni que todos deban entrar en el artículo. Varios se combinan para evitar duplicación; algunos requieren cerrar tareas antes de publicarse.

| N.º | Producto | Evidencia y condición de publicación |
|---:|---|---|
| 1 | Inventario y flujo de selección de 23 archivos | Filas, columnas, país, integridad; distinguir selección de bases y selección de personas |
| 2 | Diseño original por oleada | Matriz nueva de 23 años; cerrar cinco cotejos pendientes |
| 3 | Composición demográfica por oleada | Rehacer diccionario de sexo y edad; no usar perfil automático sin revisión |
| 4 | Cobertura de preguntas y constructos | Incorporar 2009 y verificar otras omisiones; ausencia localizada no equivale a inexistencia |
| 5 | Diccionario operativo de 14 preguntas | Enunciado, objeto, universo, escala, códigos, fuente y recodificación |
| 6 | Comparabilidad entre ediciones | Redacción, opciones, batería, universo y cobertura, no solo nombre de variable |
| 7 | Distribución moral completa por año | Diez categorías y códigos especiales, incluir 2009 |
| 8 | Ponderación y tamaño efectivo | Porcentaje crudo y ponderado, rangos de peso y Kish, sin confundirlo con efecto de diseño completo |
| 9 | Matrimonio en 2010, 2015 y 2023 | Cuatro categorías, N válido, no respuesta y contraste de redacción |
| 10 | Distancia social en 1998 y 2024 | Mención, no mención y exclusiones, con cobertura diferente explícita |
| 11 | Saliencia de discriminación en 2006 y 2008 | Distribución de las opciones completas; no medir experiencia vivida |
| 12 | Distribución ordinal de cuatro ámbitos en 2023 | Dieciséis celdas de respuesta, N por ítem y no respuesta |
| 13 | Seis comparaciones intrapersonales | Celdas discordantes, pares válidos, McNemar y signos, familias de Holm |
| 14 | Dieciséis perfiles conjuntos | Conteos sobre 1.009 casos completos y exclusión de 191 registros |
| 15 | Cruces por sexo y edad | Denominadores por grupo, escala original y celdas pequeñas; 1.514 filas de cruces previos disponibles |
| 16 | Resultados departamentales | 45 filas previas, tamaños por ítem, celdas pequeñas y alcance descriptivo |
| 17 | Cuatro modelos ordinales y sensibilidad multinomial | N completo, referencias, 68 pendientes separadas de 12 umbrales, convergencia y pruebas por bloques |
| 18 | Modelo logístico de 2024 | 859 casos, 241 eventos, 21 pendientes y ocho bloques; selección de casos y diagnósticos |
| 19 | No respuesta y escenarios extremos | Denominadores alternativos, 346 filas de perfiles previos, patrones por ítem y límites sin imputación |
| 20 | Robustez y resultados nulos | Cambios por prueba/ponderación, especificaciones parciales, corrección múltiple y afirmaciones que no se sostienen |

Una selección editorial de aproximadamente 12–14 cuadros puede combinar los productos 1–4, 5–6, 7–8, 10–11 y 17–18. La cifra final depende de la legibilidad con Times New Roman 12 y del espacio autorizado. No se reduce la letra para acomodar tablas.

## Figuras posibles

Se proponen siete figuras con funciones distintas. No son figuras nuevas ya producidas en esta auditoría.

1. Matriz de cobertura de las 23 oleadas por familia, con 2009 incluido y documentación pendiente distinguida.
2. Distribuciones morales apiladas en cuatro cortes, sin unir puntos como si hubiera medición anual.
3. Distribuciones ordinales de los cuatro ámbitos de 2023, con no respuesta visible y denominador común de 1.200.
4. Perfiles conjuntos de 2023 mediante gráfico de intersecciones, conservando N=1.009 y personas excluidas.
5. Brechas pareadas con tamaños y discordancias, sin reutilizar intervalos marginales como intervalos de diferencias.
6. Coeficientes focales de modelos con referencias e intervalos SRS/modelo, excluyendo umbrales.
7. No respuesta y límites extremos por ítem, claramente separados de intervalos de confianza.

No se recomiendan mapas coropléticos de aceptación departamental como estimación poblacional, una curva anual de tolerancia, ni duplicar cada cuadro en un gráfico. Un gráfico de perfiles y uno de distribución ordinal aportan más que múltiples barras del mismo porcentaje agregado.

## Detalle que debe llevar la redacción técnica

Participantes debe distinguir universo original, cobertura declarada, empresa y fechas de campo, etapas y cuota final, número de registros disponible, exclusiones por pregunta, exclusiones por modelo y tamaño analítico. Una ficha de muestreo publicada no equivale a disponer de todas las probabilidades para calcular varianzas.

Instrumentos debe transcribir cada pregunta desde la fuente, precisar si es una respuesta única o múltiple, diferenciar redacción resumida de literal y documentar códigos especiales. El código −5 de 2023 no está resuelto semánticamente por declararlo no válido; debe quedar como discrepancia entre microdato y libro de códigos. La recodificación binaria no reemplaza la distribución ordinal.

Análisis debe declarar estimando, denominador, peso utilizado, referencia de cada predictor, forma funcional, casos completos y familia de corrección. El coeficiente de ideología presupone una relación lineal con log-odds, las pruebas ordinales imponen sus propios supuestos y la sensibilidad geográfica parcial no es diseño oficial. Deben reportarse pruebas nulas y datos insuficientes, además de resultados significativos.

Resultados debe separar proporciones marginales de comparaciones pareadas. No puede derivarse una diferencia intrapersonal restando porcentajes calculados con dos denominadores distintos. Los límites extremos de no respuesta son escenarios de identificación parcial, no imputaciones ni intervalos de confianza. Cada conclusión necesita su numerador, denominador y límite.

## Extensión y decisión editorial pendiente

La convocatoria establece máximo global de 20–22 hojas sin resumen ni bibliografía. También indica introducción de hasta dos planas, método de hasta dos, resultados de tres a cuatro y conclusiones de una a dos. Los máximos específicos suman diez. Autoriza anexos de forma expresa en monografía; el apartado de artículo no contiene esa autorización.

No puede certificarse simultáneamente un cuerpo de veinte páginas y cumplimiento estricto de esos máximos por apartado. El autor escogió la versión extensa que excede las extensiones específicas y se implementó en el mismo archivo LaTeX. Esta decisión editorial no equivale a una dispensa emitida por la organización. No se ha dado por autorizada la admisión de anexos en artículo.

## Prioridades antes de ampliar el artículo

1. Cerrar los cinco cotejos de muestreo pendientes y contrastar fichas individuales cuando difieran de la consolidada.
2. Rehacer la cobertura temática con el documento de 2009 y revisar los cuestionarios no incluidos, sin basarse únicamente en nombres de variables.
3. Armonizar sexo y edad con documentos por año y recalcular los perfiles automáticos.
4. Corregir el exportador ordinal y su familia de ajuste en el script principal, conservando versión previa y umbrales separados.
5. Reestimar o revisar pruebas con celdas escasas y publicar la sensibilidad de signos añadida.
6. Revisar selección por casos completos y covariables no aplicables, además de no respuesta de cada resultado.
7. Elegir ubicación autorizada de las tablas técnicas y luego ampliar y compilar el mismo LaTeX, sin relleno editorial ni reducción tipográfica.

Esta auditoría tiene resultados nuevos y errores concretos identificados. No sustituye la investigación completa ni declara terminado el cierre inferencial.
