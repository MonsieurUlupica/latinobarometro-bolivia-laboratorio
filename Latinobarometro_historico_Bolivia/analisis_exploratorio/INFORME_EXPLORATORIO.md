# Análisis exploratorio: opinión pública sobre personas LGBTIQ+ en Bolivia

**Estado:** preliminar y reproducible. No modifica el artículo ni sus archivos LaTeX.

## Resultado central

Las oleadas no sostienen una historia simple de “cada vez más tolerancia”. Lo más fértil es estudiar **fronteras de aceptación por ámbito**: una misma persona puede responder de modo distinto ante el reconocimiento de identidad de género, la parentalidad, la adopción, el matrimonio y la convivencia cotidiana. En 2023, el mayor acuerdo aparece en el reconocimiento del cambio de género en el documento de identidad (43,1% de respuestas válidas), y el menor en matrimonio igualitario (29,8%); ninguno alcanza mayoría. En 2024, 28,0% de quienes contestaron la batería menciona a homosexuales entre los grupos que no querría como vecinos. Ese rechazo es bastante más frecuente entre hombres.

La tesis de trabajo más defendible, todavía para discusión, sería: **la opinión pública boliviana hacia las personas LGBTIQ+ no se ordena en una única escala de tolerancia; combina cambios no lineales en el tiempo, desacuerdos entre ámbitos de derechos y una frontera de distancia social asociada con el género de quien responde y con actitudes excluyentes hacia otros grupos.** Es una tesis descriptiva y asociativa, no causal.

## Qué bases y qué mediciones hay

El inventario contiene 23 oleadas bolivianas de Latinobarómetro entre 1996 y 2024 (26.160 entrevistas acumuladas; no son personas seguidas en el tiempo). No hay archivo boliviano de 1995; el catálogo no tiene oleada en 1999, 2012, 2014, 2019, 2021 ni 2022. El barrido de cuestionarios y codebooks encontró indicadores directos en nueve oleadas, pero no constituyen una sola serie:

| Oleada(s) | Medición | Uso válido |
|---|---|---|
| 1998 y 2024 | No querer homosexuales como vecinos | Dos puntos de distancia social; la lista de grupos y la no respuesta no son idénticas. No presentarlo como una serie homogénea. |
| 2002, 2004 y 2008 | Justificabilidad moral de la homosexualidad, escala 1–10 | Comparación descriptiva de tres cortes; valores mayores indican más justificación. |
| 2006 | Razón percibida por la que no se trata a todos por igual | Saliencia de una respuesta entre varias; no mide discriminación experimentada. |
| 2008 | Grupo que se considera más discriminado, respuesta abierta recodificada | Reconocimiento/saliencia pública; tampoco mide experiencia propia. |
| 2010, 2015 y 2023 | Acuerdo con matrimonio entre personas del mismo sexo | La comparación temporal más útil, con redacción muy parecida y escala de cuatro categorías. Son cortes repetidos, no panel. |
| 2023 | Adopción, matrimonio, reconocimiento de cambio de género en documento y parentalidad | Permite comparar ámbitos dentro de las mismas personas. |

Las oleadas 1996, 1997, 2000–2001, 2003, 2005, 2007, 2009, 2011, 2013, 2016–2018 y 2020 sí aportan contexto general, pero no una pregunta directa comparable sobre estos temas en los cuestionarios revisados. Por eso el número total de bases descargadas no debe confundirse con el número de observaciones útiles para una tendencia LGBTIQ+.

## Hallazgos cuantitativos que sí merecen discusión

### 1. El matrimonio igualitario no sigue una trayectoria lineal

Entre las personas que dieron una respuesta sustantiva, el acuerdo (muy de acuerdo + de acuerdo) fue:

| Año | Acuerdo | Denominador válido | Sin respuesta al ítem |
|---:|---:|---:|---:|
| 2010 | 19,5% | 199/1.020 | 15,0% |
| 2015 | 15,3% | 165/1.078 | 10,2% |
| 2023 | 29,8% | 348/1.167 | 2,8% |

El descenso 2010–2015 es de 4,2 puntos porcentuales; el aumento 2015–2023, de 14,5 puntos. Las pruebas de diferencia de proporciones incluidas en los CSV son aproximaciones bajo muestreo aleatorio simple y dan diferencias nominales (ajustadas por tres comparaciones); **no** reemplazan errores estándar que incorporen todo el diseño de cada oleada. Si se usa N total como denominador, la fracción de la muestra que expresó acuerdo observado es 16,6%, 13,8% y 29,0%; esto no imputa la opinión de quienes no respondieron. La caída y el repunte no parecen ser solo un cambio de denominador, aunque deben cotejarse redacción, contexto de aplicación y diseño de cada ronda antes de afirmarlos como cambio poblacional.

### 2. En 2002–2008 aumenta la justificación moral, pero no se vuelve mayoritaria

En la escala de 1 (“nunca se justifica”) a 10 (“siempre se justifica”), las medias ponderadas son 2,38 (2002), 3,32 (2004) y 4,22 (2008); las medianas, 1, 3 y 5. El porcentaje ponderado que responde 6–10 aumenta de 12,2% a 18,6% y 28,7%. Sin embargo, en 2008 todavía 49,8% se ubica entre 1 y 4 y 21,5% en el punto medio 5. La lectura más prudente es un desplazamiento gradual hacia mayor justificación en esos tres cortes, no una aceptación consolidada ni una tendencia que pueda extenderse hasta 2024.

### 3. Los derechos no reciben el mismo nivel de acuerdo en 2023

| Enunciado | Acuerdo entre respuestas válidas | N válido | No respuesta |
|---|---:|---:|---:|
| Adopción por parejas del mismo sexo | 31,1% | 1.168 | 2,7% |
| Matrimonio entre personas del mismo sexo | 29,8% | 1.167 | 2,8% |
| Reconocimiento del cambio de género en documento de identidad | 43,1% | 1.143 | 4,8% |
| Parejas homosexuales pueden ser tan buenos padres como otras | 39,5% | 1.050 | 12,5% |

Las cuatro preguntas se hicieron a los mismos encuestados. En comparaciones pareadas, adopción y matrimonio son prácticamente iguales (diferencia de 1,0 punto; no distinguible en esta aproximación). El acuerdo con reconocimiento documental supera al de matrimonio en 12,8 puntos; la parentalidad lo supera en 8,2 puntos. Tras corrección Holm de las seis comparaciones, las diferencias grandes se mantienen; reconocimiento documental frente a parentalidad queda en el límite (4,1 puntos, p ajustada ≈ 0,047). La parentalidad tiene mucha más no respuesta que los otros ítems, así que conviene reportar siempre tanto el porcentaje válido (39,5%) como el porcentaje del total (34,6%) y no atribuir la falta de respuesta a una causa sin evidencia.

El resultado no es que “la sociedad apoya” estos derechos: **en todos los ítems el acuerdo queda por debajo de la mitad**. Lo que sí aparece es una jerarquía de aceptación: más acuerdo con reconocimiento documental y parentalidad que con matrimonio/adopción.

### 4. En 2024 la distancia social es considerable y tiene una brecha de género

La pregunta pide mencionar los grupos que no se quisiera tener de vecinos y permite respuestas múltiples. De 1.200 entrevistas, 174 (14,5%) marcaron “no sabe/no responde” para la batería; ninguna de esas 174 marcó además otro grupo. Entre las 1.026 respuestas sustantivas, 287 (28,0%; IC95% SRS aproximado 25,3–30,8) mencionaron a homosexuales. Con denominador de toda la muestra son 23,9%.

En la lista de ocho categorías sustantivas, homosexuales queda en segundo lugar (28,0%), después de “bebedores, drogadictos, alcohólicos” (82,1%) y por encima de inmigrantes/trabajadores extranjeros (19,8%). No debe construirse sin más un índice único con esa batería: las categorías no son equivalentes y el ítem de consumo de alcohol/drogas es extraordinariamente frecuente.

La diferencia por sexo es la asociación más clara en 2024: menciona rechazo 34,7% de los hombres (180/518 válidos) y 21,1% de las mujeres (107/508), brecha de 13,7 puntos. En el modelo logístico exploratorio, ajustado por edad, educación, práctica religiosa y conteo de otros grupos rechazados, las odds de las mujeres son 0,48 veces las de los hombres (IC95% SRS aprox. 0,36–0,64). La asociación con un patrón más amplio de exclusión también aparece: cada grupo adicional rechazado —contando seis grupos y excluyendo a homosexuales y el ítem de sustancias— se asocia con OR 1,38 (IC95% aprox. 1,20–1,59). Edad, educación y práctica religiosa no muestran aquí un gradiente claro.

Estas son asociaciones de corte transversal, no efectos de género ni explicaciones causales. La asociación se mantiene al probar errores estándar con `COMDIST` como conglomerado y `REG` como estrato geográfico: OR de mujeres 0,48 (IC95% aprox. 0,36–0,64), y OR por grupo adicional rechazado 1,38 (IC95% aprox. 1,21–1,57). Es una reconstrucción parcial, no el diseño oficial completo. La [ficha técnica oficial de 2024](https://www.latinobarometro.org/documents/LAT-2024/latinobarometro-2024-fichas-tecnicas.pdf) describe para Bolivia una muestra de 1.200 entrevistas, en cuatro etapas, probabilística en las primeras tres y con cuotas en la última; el microdato tiene WT=1 y no incluye todas las probabilidades ni detalles de etapas necesarios para una varianza plenamente design-based. La salida `modelo_diseno_parcial_2024.csv` documenta este análisis de sensibilidad.

### 5. La no respuesta merece analizarse, no ocultarse

En 2024 la no respuesta de la batería es 14,5%, pero cambia por educación: 30,0% entre personas analfabetas (27/90) y 6,8% entre quienes completaron educación superior (10/147). El rechazo válido observado varía menos entre esos grupos. Como sensibilidad, un ajuste por probabilidad de responder estimada con sexo, edad, educación y práctica religiosa da 27,9%, casi igual al 28,0% de casos válidos; por sexo da 34,7% frente a 21,0%. Esto reduce la preocupación por el estimado global **bajo el supuesto** de no respuesta ignorable dadas esas variables; no resuelve sesgo no observado y no equivale a ponderación del diseño.

### 6. Hay datos territoriales, pero no una conclusión geográfica firme

La base 2024 contiene las nueve regiones/departamentos, con tamaños muy distintos: 315 entrevistas en La Paz, 310 en Santa Cruz, 220 en Cochabamba y solo 20 en Pando. Entre respuestas válidas, la mención de rechazo oscila descriptivamente de 18,8% en Pando (3/16) a 36,6% en Beni (15/41); la prueba exploratoria global no detecta diferencia clara (χ²≈9,56; 8 gl; p≈0,297), una celda ya tiene frecuencia esperada menor que cinco. No escribir “hay diferencias territoriales” con esta evidencia; reportar el desglose con sus denominadores y tratarlo como exploración para una muestra mayor.

### 7. La discriminación contra personas homosexuales parece poco saliente en preguntas de mención única

En 2006, 14/1.161 respuestas sustantivas (1,2%) eligieron “por ser homosexual” como respuesta a una pregunta sobre por qué no se trata a todos por igual. En 2008, 11/1.056 (1,0%) identificaron a homosexuales como el grupo más discriminado; la respuesta modal fue indígenas (45,5%) y luego pobres (28,5%). Los instrumentos y las categorías no son idénticos, así que esto **no es una serie temporal**. Sí permite una hipótesis de baja saliencia pública de la discriminación por orientación sexual en esos contextos de mención espontánea/única. No es evidencia de que la discriminación vivida sea baja.

## Cómo tratar el resto de las fuentes del proyecto

El corpus de prensa y los registros de casos pueden fortalecer el artículo como **triangulación contextual**, pero no deben fusionarse con la encuesta como si compartieran unidad de análisis. El corpus conservador retiene 143 piezas 2016–2025, concentradas en Opinión (116; 81,1%), y no representa el volumen ni la agenda completa de todos los medios; sus ceros de recuperación no indican ausencia de publicaciones. Los 32 registros de casos del Observatorio/SISOBS describen casos documentados, no prevalencia poblacional. Son útiles para mostrar cómo se narran derechos, violencias, barreras y respuestas organizativas; no permiten afirmar que la cobertura causó las opiniones observadas. Véanse [el corpus reanalizado](../../06_Auditoria_Reconstruccion/ampliacion_panel_2016_2025/corpus_reanalizado_2016_2025.csv) y [los 32 registros institucionales](../../06_Auditoria_Reconstruccion/fuentes_institucionales/observatorio_32_casos_vida.csv).

Para el artículo, recomiendo que Latinobarómetro sea el núcleo cuantitativo y que prensa/casos entren solo como contexto cuidadosamente rotulado si el espacio alcanza. No fusioné aquí EMH o Censo: este informe cubre las oleadas Latinobarómetro descargadas, y la integración de otras bases requeriría demostrar que sus variables y unidades responden a la misma pregunta.

## Diseño y pregunta recomendados

**Título de trabajo:** *Más allá de una escala de tolerancia: aceptación de derechos y distancia social hacia personas LGBTIQ+ en Bolivia, 2002–2024*.

**Pregunta:** ¿La opinión sobre personas LGBTIQ+ se distribuye como una disposición general de aceptación o cambia según el derecho y la proximidad social, y qué características se asocian con el rechazo a tener vecinos homosexuales en 2024?

**Diseño:** análisis descriptivo-comparativo de cortes transversales repetidos, con una serie acotada de matrimonio (2010/2015/2023), otra de justificación moral (2002/2004/2008), comparaciones pareadas de derechos en 2023 y modelo asociativo exploratorio para distancia social en 2024. No llamarlo panel ni “longitudinal explicativo”. Si se usa “explicativo”, tendría que limitarse a explicación estadística no causal en la sección 2024.

## Límites que deben quedar en el artículo

- Los datos describen opiniones de población encuestada; no identifican cuántas personas LGBTIQ+ viven en Bolivia ni describen directamente sus experiencias.
- Los códigos de respuesta especial varían por archivo; el análisis considera respuestas válidas solo las categorías sustantivas del cuestionario y expone la no respuesta.
- Las comparaciones entre oleadas usan preguntas parecidas, no siempre idénticas. Se informan como cortes separados y no se integran en un “índice de tolerancia”.
- Los tests son exploratorios SRS y requieren verificación con el diseño muestral de cada ronda antes de reportarse como inferencia formal.
- No se estiman efectos causales de edad, sexo, religión, educación, prensa ni política.

Los cuestionarios y libros de códigos utilizados están archivados en [`documentacion/`](../documentacion/); para cotejar los ítems centrales, véanse el [cuestionario 2023](../documentacion/Cuestionario_2023_ES.pdf), el [cuestionario 2024](../documentacion/latinobarometro-2024-cuestionario-esp.pdf), y los codebooks de 2002, 2004, 2006 y 2008 en esa misma carpeta. Los datos y documentación oficiales de la oleada 2024 están en [Latinobarómetro 2024](https://www.latinobarometro.org/latinobarometro-2024).

## Archivos reproducibles

El script [analisis_exploratorio.R](analisis_exploratorio.R) vuelve a leer los CSV originales, aplica los recodes documentados y regenera los resultados en `resultados/`. Debe ejecutarse desde la carpeta raíz del proyecto con:

```bash
Rscript Latinobarometro_historico_Bolivia/analisis_exploratorio/analisis_exploratorio.R
```

Los archivos de resultados guardan los conteos, denominadores, intervalos exploratorios, pruebas y modelos; no se alteraron las bases originales.
