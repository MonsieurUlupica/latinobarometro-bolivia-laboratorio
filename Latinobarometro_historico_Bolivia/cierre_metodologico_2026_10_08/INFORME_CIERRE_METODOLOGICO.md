# Cierre de tareas analíticas y cotejo documental

Versión del 8 de octubre de 2026. Esta actualización sustituye el listado de pendientes del primer paquete público; no elimina sus registros históricos. Las bases originales permanecen intactas. Los resultados principales describen respuestas observadas; los contrastes y modelos conservan su alcance de sensibilidad bajo independencia.

## Qué significaba «18 de 23»

Estaban presentes los 23 archivos nacionales, con 26.160 filas. La cifra 18 contaba ediciones cuyo resumen de selección y cobertura había sido cotejado, no bases descargadas ni análisis ejecutados. Se recuperaron y revisaron los materiales de 2016, 2017, 2018 y 2020. El cotejo de descripción y cobertura alcanza ahora **22 de 23 ediciones**. No significa reconstrucción integral de sus diseños ni verificación de todos los detalles de cada cuestionario.

La matriz actualizada es `resultados/matriz_muestreo_23_oleadas_actualizada.csv`. La matriz anterior conserva el nombre `matriz_muestreo_23_oleadas_cotejo_18.csv` y sirve como estado histórico.

| Tarea inicial | Resultado de esta actualización | Alcance restante |
|---|---|---|
| Cotejo de cinco ediciones recientes | Cerrados descripción y cobertura de 2016, 2017, 2018 y 2020; 2023 parcialmente documentado | Ficha detallada boliviana de 2023 |
| Reconstruir diseño | Documentadas etapas, estratificación y cuotas publicadas; detalles específicos nuevos de 2018/2020 | Correspondencia con unidades del microdato, probabilidades de inclusión y varianza oficial; no se certifica reconstrucción integral |
| Caracterizar diez muestras | Homologados sexo registrado y edad exacta; distribuciones, rangos, cuartiles y faltantes | Educación, religión y demás predictores históricos requieren cotejo y armonización propia |
| Resolver −5 de 2023 | Resuelto mediante etiquetas y cotejo registro a registro de SPSS y CSV | Ninguno respecto del significado observado de −5 en los cuatro ítems |
| Contexto de 2009 | Revisado cuestionario inglés, tarjeta, escala, ubicación y libro de códigos español | Texto literal del cuestionario español aplicado |
| Celdas escasas | Recalculadas tablas mayores mediante Monte Carlo condicional, 200.000 replicaciones | El procedimiento no corrige diseño ni selección |
| Casos completos | Diagnósticos de pérdida, patrones y modelos de selección/ajuste ejecutados | Sesgo por variables no observadas no identificable mediante esta comparación |

## Documentación recuperada y revisada

- [Ficha 2016](https://www.latinobarometro.org/documents/LAT-2016/fichastecnicas-latinobarometro-2016.pdf), página física 1, fila Bolivia. IPSOS Bolivia, 1.200 entrevistas, cobertura declarada 100%, diseño modificado estratificado proporcional y multietápico con cuota final. Es una ficha resumen; no contiene todas las probabilidades de selección.
- [Informe 2017](https://www.latinobarometro.org/documents/LAT-2017/informe-latinobarometro-2017.pdf), página física 66, fila Bolivia. IPSOS Apoyo Opinión y Mercado S.A., 1.200 entrevistas, cobertura declarada 100%, etapas y cuota final resumidas.
- [Informe metodológico 2018](https://www.latinobarometro.org/documents/LAT-2018/informemetodologico-latinobarometro-2018.pdf), apartado boliviano desde página física 25. Universo de 18 años y más, 1.200 casos, estratos departamento × urbano/rural, cuatro etapas, cuotas finales de sexo, edad y educación. Campo del 23 de junio al 19 de julio. Excluye personas que no hablan castellano. Declara muestra autoponderada y ponderación no aplicable.
- [Informe metodológico 2020](https://www.latinobarometro.org/documents/LAT-2020/latinobarometro-2020-metodologico.pdf), apartado boliviano, páginas físicas 16–17 y campo desde 27. Universo adulto, 1.200 casos, estratos y etapas descritos; campo del 26 de octubre al 17 de noviembre, entrevistas en castellano. No se aplica a Bolivia el procedimiento online que aparece en el apartado argentino del mismo documento.
- [Libro de códigos 2015](https://www.latinobarometro.org/documents/LAT-2015/latinobarometro-2015-libro-de-codigos-v20190707.pdf), página física 30, P69ST.C. Confirma las cuatro categorías de matrimonio y códigos especiales. Recuperación PDF verificada, no solo una respuesta HTTP exitosa.
- [Cuestionario inglés 2009](https://www.latinobarometro.org/documents/LAT-2009/latinobarometro-2009-eng.pdf), página física 5, Q63WVSST. Tarjeta 18, 1 «never justified», 10 «always justified», una respuesta. No se identifica un salto que restrinja ese ítem en la página revisada. El cuestionario usa 98/00 para desconocimiento/no contestación; el libro de códigos y la exportación recodifican especiales negativos. La equivalencia literal con el cuestionario español no queda demostrada por la versión inglesa. El enlace español anunciado devolvió 404.
- [SPSS agregado oficial 2023](https://www.latinobarometro.org/documents/LAT-2023/latinobarometro-2023-spss-v1-0.zip). Se seleccionaron los 1.200 registros IDENPA=68, alineados por NUMENTRE. No se publica ese archivo de terceros.
- [Catálogo boliviano 2023](https://www.latinobarometro.org/ws/web/country-documents/2/LAT-2023/4167). La respuesta archivada del 8 de octubre tiene `samplingHtml` vacío y ofrece datos y resultados nacionales. Esto evidencia una recuperación incompleta de la ficha, no que el diseño no exista. El informe general permite confirmar universo adulto y modalidad presencial; su ventana 20 de febrero–30 de marzo corresponde a diez países, no a fechas bolivianas exactas.

La descripción geográfica de 2018/2020 dice nueve departamentos y enumera ocho en un párrafo, omitiendo Potosí; el listado de estratos sí incluye los nueve. Se conserva esa inconsistencia textual y no se transforma en una exclusión territorial inferida.

### Diseño y margen publicado

En 2018/2020 se especifica selección de localidades proporcional al tamaño, zonas y hogares, con persona seleccionada finalmente por cuotas. Los informes contienen listados de puntos; su disponibilidad abre una posibilidad de cotejar unidades, no demuestra que COMDIST sea la unidad primaria ni recupera probabilidades individuales. La estratificación departamento × urbano/rural tampoco equivale a usar REG solo como estrato.

El ±2,8% publicado se calcula expresamente bajo muestreo aleatorio simple y máxima varianza. No es un efecto de diseño estimado. La cobertura declarada 100% no es tasa de respuesta y debe leerse con las exclusiones lingüísticas explícitas. Promedios de contactos o rechazos no permiten calcular una tasa de respuesta estándar sin denominadores y disposición de todos los contactos.

## Código −5 y reproducibilidad de 2023

Las cuatro variables P37CSN.A, P37CSN.B, P37CSN.F y P37WVSCS.H tienen etiqueta SPSS **−5 = No sabe / No contesta**. Se cotejaron también SEXO, EDAD, REEEDUC.1, S1A, P16ST y S5. Resultado: 1.200 coincidencias y cero discrepancias por cada uno de los diez campos, 12.000 celdas verificadas.

Se utilizó `haven::read_sav(user_na=TRUE)` para conservar códigos declarados perdidos. Con la opción predeterminada, haven transforma esos especiales en NA. Esa conversión no es una discrepancia del archivo original. La discrepancia 0 frente a −5 corresponde al cuestionario/libro y la exportación; su significado queda respaldado por el archivo etiquetado del productor. Se mantiene −5 en las distribuciones y se excluye de 1–4.

El cotejo de páginas detectó una corrección bibliográfica adicional. Los números 156, 157, 161 y 163 de 2023 son posiciones de campos, no páginas. Las páginas físicas correctas son 24, 25, 25 y 26. También se corrigieron localizadores de los libros 2002/2004/2006/2008/2015 en el diccionario y manuscrito.

## Composición homologada de las diez muestras

| Año | N | Hombres | Mujeres | N con edad válida | Mediana | Rango observado |
|---:|---:|---:|---:|---:|---:|---|
| 1998 | 794 | 380 | 414 | 792 | 34 | 18–85 |
| 2002 | 1.242 | 623 | 619 | 1.242 | 35 | 18–90 |
| 2004 | 1.201 | 600 | 601 | 1.201 | 36 | 18–83 |
| 2006 | 1.200 | 600 | 600 | 1.200 | 36 | 18–87 |
| 2008 | 1.200 | 600 | 600 | 1.200 | 35 | 18–88 |
| 2009 | 1.200 | 600 | 600 | 1.200 | 35 | 18–87 |
| 2010 | 1.200 | 600 | 600 | 1.200 | 37 | 18–87 |
| 2015 | 1.200 | 600 | 600 | 1.200 | 37 | 18–98 |
| 2023 | 1.200 | 600 | 600 | 1.200 | 36 | 18–84 |
| 2024 | 1.200 | 600 | 600 | 1.200 | 35 | 18–88 |

Los diez campos cotejados son edades exactas, no intervalos interpretados como años. En 1998 hay dos códigos no válidos; no se rellenan. Las siete composiciones 600/600 describen los archivos y son compatibles con cuotas documentadas en varias ediciones; por sí solas no reconstruyen el muestreo. Sexo registrado no mide identidad de género. Cuartiles, bandas y campos de origen están en las tablas del expediente.

## Celdas escasas

El código principal ahora genera 63 pruebas de asociación y 61 de no respuesta. Hay ocho Kruskal–Wallis por sexo/edad moral y nueve cruces categóricos con alguna frecuencia esperada menor que cinco. Las tablas mayores escasas utilizan Pearson con Monte Carlo condicional, 200.000 replicaciones, semilla 20261008; las 2×2 escasas utilizarían Fisher.

En los 61 contrastes previamente disponibles no cambió ninguna clasificación Holm al umbral 0,05. La asociación entre saliencia de 2008 y edad pasó de p Holm 0,033 a 0,036. Su p bruta simulada fue 0,0180, con error Monte Carlo aproximado 0,00030. La solución numérica atiende la escasez; no reconstruye varianza de encuesta ni demuestra asociación poblacional.

Los dos cruces nuevos de 2009 completan sexo y edad. El contraste global histórico Kruskal–Wallis y sus pares entre años continúan referidos a 2002/2004/2008; no se atribuyen retrospectivamente a los cuatro cortes.

## Selección por casos completos

| Resultado | Respuestas válidas | Incluidos en modelo | Excluidos por covariables | Evento en incluidos | Evento en excluidos |
|---|---:|---:|---:|---|---|
| Adopción 2023 | 1.168 | 881 | 287 | 273/881, 31,0% | 90/287, 31,4% |
| Matrimonio 2023 | 1.167 | 874 | 293 | 253/874, 28,9% | 95/293, 32,4% |
| Documento 2023 | 1.143 | 868 | 275 | 369/868, 42,5% | 124/275, 45,1% |
| Parentalidad 2023 | 1.050 | 798 | 252 | 309/798, 38,7% | 106/252, 42,1% |
| Mención vecinal 2024 | 1.026 | 859 | 167 | 241/859, 28,1% | 46/167, 27,5% |

En adopción, entre respuestas válidas se excluyen por regla de práctica religiosa 129 registros, por ideología 161 y por ingreso 20. Son pérdidas superpuestas: sumarlas no da el número de personas excluidas. Sexo, edad y educación no producen faltantes en esa muestra. Los patrones de combinación están publicados sin identificadores.

La pérdida no se agota en esos modelos. De los 191 registros sin cuatro respuestas válidas, 119 son mujeres (62,3%) y la mediana de edad es 41 años; en los 1.009 perfiles completos hay 481 mujeres (47,7%) y mediana de 35. Las combinaciones de opinión describen a quienes contestaron los cuatro ítems. No se imputaron perfiles a los excluidos.

### Separar selección y ajuste

Se estimaron tres especificaciones por resultado: sexo/edad con respuestas válidas, sexo/edad en la submuestra del modelo completo y modelo completo. En 2024 las OR mujer/hombre fueron 0,497, 0,509 y 0,502. La asociación observada varió poco ante esta restricción específica. Ese parecido no prueba ausencia de selección no observada.

En matrimonio 2023 las OR ordinales fueron 1,77, 1,82 y 1,84. En documento fueron 1,26, 1,21 y 1,26. No se compararon AIC entre modelos con personas distintas ni se interpretaron estas variaciones como un efecto causal.

### No aplicable en práctica religiosa

La especificación principal de 2023 excluye códigos fuera de 1–4. Una sensibilidad conserva −3, «No aplicable», como categoría distinta, sin adjudicarle creencia o religiosidad. Los tamaños aumentan a 986, 980, 972 y 892, respectivamente, agregando 104–106 casos respecto de los modelos principales.

La OR mujer/hombre matrimonial pasa de 1,84 a 1,92; la documental, de 1,26 a 1,36. El intervalo Wald individual de documento deja de incluir uno en esa sensibilidad. No se promociona ese resultado a hallazgo robusto: dichos intervalos individuales no están ajustados simultáneamente y cambia la especificación. La interpretación de un resultado nulo debe mencionar esa dependencia.

## Corrección del código y hallazgo adicional

El código principal incorpora 2009 y exporta **68 pendientes ordinales** por separado de **12 umbrales**. La auditoría independiente evita añadir 2009 dos veces si ya está integrado. Los umbrales no se presentan como OR de predictores.

La revisión del cuestionario inglés descubrió además P64ST.A en 2009, Q64, tarjeta 19, «Gay» en la batería de vecinos no deseados. En el microdato hay 450 menciones y 750 no menciones, 37,5% sobre 1.200 registros. El libro español respalda la codificación 0/1 y especiales, aunque el rótulo conjunto presenta un componente incompleto. Se registra como **hallazgo complementario**, fuera de los 14 ítems principales. La revisión literal española y el contexto de batería deben completarse antes de construir una serie vecinal homogénea con 1998/2024. Ignorar este hallazgo produciría una falsa impresión de cobertura exhaustiva.

## Verificación de ejecución

`cerrar_pendientes.R` vuelve a ejecutar el análisis principal y produce las tablas adicionales. Sus seis controles verifican 23 archivos, 14 ítems únicos, diez oleadas sustantivas, coincidencia CSV–SPSS, 68 pendientes y 12 umbrales. La versión histórica de salidas está preservada localmente en `estado_previo`, fuera del paquete público.

`verificar_reproduccion.R` regeneró el código principal en una carpeta nueva: **43 de 43 CSV idénticos por huella MD5** frente a la referencia. La prueba utiliza las mismas entradas locales; no equivale a redescargar las bases ni a certificar un clon sin documentación. Su resultado se conserva en `resultados/reproduccion_csv_directorio_nuevo.csv`. Se comprobaron las huellas SHA-256 del paquete inicial: **23 de 23 originales intactos**.

## Qué sigue abierto y a quién corresponde

**Trabajo del laboratorio todavía ampliable.** Homologar educación y otros predictores históricos mediante sus textos y categorías; cotejar puntos de selección listados en informes contra campos del microdato donde sea posible; completar el texto español de 2009; ampliar sensibilidades de modelos más allá de sexo/edad. Se trata de tareas identificadas, no de información declarada inexistente.

**Información que debe confirmar el productor.** Diseño boliviano detallado 2023; significado y correspondencia de identificadores de unidades por etapa; probabilidades/pesos de inclusión y correcciones que procedan; disposición de contactos para tasas de respuesta; discrepancias de N en 2000/2001. No se enviaron consultas ni se atribuyó una respuesta institucional no obtenida. La solicitud técnica preparada en este expediente especifica los campos necesarios.

**Límites del objeto observado.** Los cortes repetidos no permiten seguir individuos, estimar orientación/identidad no preguntadas ni interpretar opiniones como experiencias de violencia. Son propiedades del objeto y de las preguntas. La descripción de respuestas por ítem, su comparación intrapersonal y los diagnósticos ejecutados siguen siendo resultados positivos del estudio.
