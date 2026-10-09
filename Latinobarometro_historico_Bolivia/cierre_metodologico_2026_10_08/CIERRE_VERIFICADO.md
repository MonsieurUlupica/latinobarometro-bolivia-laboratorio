# Cierre verificado de los pendientes identificados

8 de octubre de 2026. Este informe actualiza el estado de `INFORME_CIERRE_METODOLOGICO.md` y de los README anteriores. Cierra las tareas de análisis enumeradas, bajo las reglas y comprobaciones aquí especificadas. No certifica agotamiento de toda investigación posible, equivalencia de diseños ni inferencia causal. Los originales permanecen intactos.

## Matriz de resolución

| Pendiente identificado | Trabajo efectivamente ejecutado | Información externa restante |
|---|---|---|
| Fichas de 2016, 2017, 2018, 2020 y 2023 | Recuperación y cotejo de los cuatro primeros; descripción/cobertura de 22 de 23 ediciones; universo, modalidad y ventana regional de 2023 cotejados | Ficha detallada boliviana 2023; empresa, cuotas, etapas y fechas nacionales exactas |
| Campos de unidades, etapas y estratos | Catálogo y plan de 240 puntos/1.200 cédulas cotejados en 2018 y 2020. COMDIST ausente en CSV 2018. En 2020: 240 códigos exactos, cinco entrevistas por código, una CIUDAD por punto y prefijo coherente con REG | Definición institucional de unidad por etapa, probabilidades, cuotas y varianza; correspondencia completa para otros años y estratos urbano/rurales |
| Caracterizar las diez muestras | Sexo y edad exacta; 50 correspondencias adicionales de educación, práctica, religión, ideología e ingreso; distribuciones crudas y homologadas, faltantes y denominadores | No se exige al productor nuestra homologación: ya se realizó. La comparabilidad poblacional de diseños sigue condicionada por información muestral |
| Código −5 de 2023 | SPSS oficial etiqueta NS/NR; 12.000 celdas de diez campos, 1.200 entrevistas, coinciden con CSV | Ninguno para el significado constatado en esos campos |
| Ítem moral y batería vecinal 2009 | Libro español, cuestionario inglés y catálogo IHSN contrastados; ítem moral incorporado; ítem vecinal complementario descrito | Cuestionario español aplicado íntegro: enlace oficial español revisado devuelve 404; el rótulo truncado de IHSN no sustituye el texto completo |
| Escasez y casos completos | Pruebas exactas/simuladas; composición incluida/excluida, modelos de selección, sensibilidad a no aplicable y 65 ajustes de retiro de bloques/influencia | Sesgo por información no observada no identificable con estos diagnósticos |
| Factor común de cuatro ítems | Modelo ordinal de un factor WLSMV ejecutado sobre 1.009 casos; cargas, ajuste, umbrales, residuos y correlaciones publicados | No se afirma validación general ni invariancia; no es tarea pendiente de cálculo |
| Reproducibilidad | 23 CSV redescargados del productor, SHA-256 idénticos; código de clon público regeneró 43/43 CSV principales idénticos | Los PDF documentales se aportaron desde el archivo local; no se afirma redescarga independiente de todos ellos |

## Homologación y barrido histórico

Diez oleadas: 1998, 2002, 2004, 2006, 2008, 2009, 2010, 2015, 2023 y 2024. El diccionario contiene 50 correspondencias con campo, regla y fuente/localizador. Los códigos originales se conservan en otra tabla. Las categorías no se equiparan solamente por compartir número.

- Educación: siete niveles; agrupaciones 1–3, 4–5, 6–7 para descripción. En 2023 la educación recodificada se localiza en libro de códigos y SPSS; en 2024 en CSVText oficial alineado por NUMENTRE, con etiquetas exportadas.
- Religión: anclas católica/ninguna/otras, sin fingir igualdad de denominaciones específicas. Ninguna=15 en 1998/2002 y 97 desde 2004.
- Práctica: cuatro autodefiniciones; no aplicable separado. Los filtros del cuestionario pueden variar y deben acompañar cualquier comparación. No se interpreta como frecuencia de asistencia medida homogéneamente.
- Ideología: 0–10; ninguna separada, no centro. En el CSV usa −6 hasta 2015 y 97 en 2023/2024; el cotejo SPSS/CSVText confirma las etiquetas recientes. Grupos 0–3/4–6/7–10 son cortes analíticos.
- Ingreso: suficiencia subjetiva en cuatro posiciones, no monto ni pobreza monetaria.

Se ejecutaron 70 pruebas adicionales, cinco predictores por cada uno de los catorce ítems. Moral conserva sus diez categorías en Kruskal–Wallis. Para otros resultados se usa el evento binario documentado. Fisher y Pearson Monte Carlo condicional (200.000 replicaciones) atienden tablas escasas. Holm se aplica a cinco pruebas por ítem; no se mezcla esa familia con la corrección de los análisis anteriores. Son sensibilidades exploratorias bajo independencia.

Resultado: 17 pruebas con p Holm <0,05 y 53 restantes. Se conservan todas, incluidos los nulos. Distribución de las 17: educación/religión/ideología en moral de 2004, 2008 y 2009; educación/ingreso en matrimonio 2010; educación/ingreso en adopción 2023; educación/religión en matrimonio 2023; religión en parentalidad 2023 y distancia vecinal 2024. No son efectos ajustados ni prueba de continuidad histórica. La tabla completa incluye denominadores y categorías; no se selecciona una categoría favorable después del contraste global.

Archivos: `diccionario_covariables_historicas_50.csv`, `perfil_covariables_historicas_homologadas.csv`, `codigos_covariables_historicas_crudos.csv`, `etiquetas_covariables_csvtext_2024.csv`, `cruces_covariables_historicas.csv`, `pruebas_covariables_historicas.csv`.

## Reconstrucción geográfica verificable

Los informes oficiales contienen descripción de etapas, un catálogo denominado UPM y un plan de cédulas. Se cotejaron secciones bolivianas, no catálogos de otros países. Localizadores físicos: informe 2018, pp. 25–55; informe 2020, pp. 16–55.

En ambos hay 240 códigos y 1.200 cédulas planificadas. En 2018 no está publicado COMDIST en el CSV analizado. En 2020 el conjunto COMDIST coincide con los 240 códigos documentales; cada uno tiene cinco registros y una CIUDAD, y su prefijo corresponde al departamento REG. Esta comprobación identifica códigos de puntos, no probabilidades de selección ni todas las etapas de varianza. La localidad seleccionada inicialmente y el punto catalogado no se declaran intercambiables. REG solo no reconstruye departamento × urbano/rural.

Se conserva una inconsistencia del informe 2018: el plan y el catálogo asignan nombres diferentes a algunos puntos de Beni (106–109); no se corrigen por intuición. Por ejemplo, el plan asigna 106–107 a Riberalta, mientras el catálogo los asigna a Galilea. Como COMDIST está ausente, no se atribuyen esas denominaciones a registros individuales. Requiere aclaración documental si se pretende reconstruir la selección exacta.

Archivos: `cotejo_unidades_2018_2020.csv`, `catalogo_UPM_cotejado_2018_2020.csv`. No se extrapola esta correspondencia a 2023/2024.

## Modelos, celdas e influencia

Los cuatro ordinales de 2023 y la logística de 2024 convergieron con errores estándar finitos. Las matrices Hessianas ordinales fueron positivas definidas. La matriz del modelo logístico tuvo rango 22/22. Las celdas observadas de factores se publican; niveles educativos presentan celdas pequeñas. Los diagnósticos numéricos no certifican buena precisión, ausencia de sesgo ni separación imposible. Los números de condición dependen de escalas de predictores y no se interpretan con un umbral universal.

Se ajustaron 65 modelos adicionales: 48 ordinales (cuatro resultados × seis bloques retirados × dos reglas de muestra), 16 logísticos (ocho bloques × dos reglas) y uno sin la observación de máxima influencia. Todos los coeficientes se exportan. La primera regla conserva los casos del modelo principal; la segunda amplía a casos disponibles al quitar el predictor. Así se distingue perturbación de especificación de perturbación de composición. No es selección automática de un modelo final.

Rangos de OR de mujer frente a hombre en los retiros: adopción 1,300–1,424; matrimonio 1,753–1,975; reconocimiento documental 1,219–1,330; parentalidad 1,528–1,689; mención vecinal 0,481–0,514. Son rangos de estimaciones, no intervalos. Logística: probabilidades 0,089–0,700; Cook máximo 0,0104; apalancamiento máximo 0,0987. Quitar el caso de mayor Cook da OR sexo=0,507, IC95% de modelo 0,368–0,698. No se suprimen todos los casos que exceden reglas heurísticas.

Corrección editorial del cierre anterior: incorporar no aplicable de práctica añade **94–106** registros según ítem, no 104–106; parentalidad aumenta de 798 a 892.

Archivos: `sensibilidad_todas_pendientes_bloques.csv`, `diagnosticos_numericos_modelos.csv`, `celdas_observadas_modelos.csv`, `diagnostico_influencia_logistica_2024.csv`; se mantienen las tablas anteriores de selección y no respuesta.

## Diagnóstico factorial ordinal

lavaan 0.7-3, WLSMV, ítems ordenados y N=1.009 casos completos. Orientación mayor=más acuerdo. Convergencia y post-check positivos. Cargas estandarizadas: adopción 0,858; matrimonio 0,889; documento 0,518; parentalidad 0,706. χ² escalado=19,628, gl=2, p=0,00005469; CFI escalado=0,996; TLI escalado=0,989; RMSEA escalado=0,094, IC 0,059–0,133; SRMR=0,021.

Los índices no autorizan una conclusión binaria de validación. Hay covariación común considerable y ajuste menos favorable en otros criterios, con solo dos grados de libertad. Se conservan ámbitos y perfiles por razones de objeto e interpretación. No se afirma que un índice sea necesariamente imposible. El modelo no está ajustado al diseño ni prueba invariancia, validez de contenido o equivalencia entre derechos.

Archivos: `factor_ordinal_2023_ajuste.csv`, `factor_ordinal_2023_parametros.csv`, `correlaciones_policoricas_2023.csv`, `residuos_factor_ordinal_2023.csv`, `factor_ordinal_2023_controles.csv`.

## Reproducción y condiciones

Se creó un clon del repositorio público y se redescargaron los 23 ZIP nacionales CSV. Sus CSV fueron idénticos byte por byte a las entradas originales. Con el código principal del clon se regeneraron 43 CSV agregados: 43 idénticos. La documentación PDF fue aportada desde el archivo local, condición explícita del ensayo. Los nuevos análisis tienen código ejecutado y sus salidas; la prueba independiente de 43 salidas corresponde al núcleo principal, no a una certificación independiente de cada nuevo diagnóstico.

Archivos: `verificacion_redescarga_23.csv`, `reproduccion_clon_redescarga.csv`. Se publican código y agregados, no datos, textos de terceros, documentación individual ni el manuscrito. La solicitud técnica al productor está preparada y **no enviada**.

## Qué no puede resolverse mediante más cálculo sobre estos archivos

Ficha detallada 2023, correspondencia integral unidades/etapas/probabilidades/cuotas, denominadores y disposición de contactos para tasas estándar, cuestionario español íntegro de 2009, explicación de N de 2000/2001 y unicidad de NUMENTRE en 2002/2006. Se detallan como necesidades documentales del productor en notas del manuscrito. No se afirma que no existan. Las capacidades causales, trayectorias individuales, identificación de población LGBTIQ+ y sesgo no observado tampoco aparecen por aumentar el número de pruebas.
