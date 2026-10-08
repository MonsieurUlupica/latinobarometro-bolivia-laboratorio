# Análisis exploratorio de Latinobarómetro — Bolivia

Este directorio contiene un análisis reproducible de las oleadas bolivianas de Latinobarómetro descargadas en la carpeta vecina. Las bases originales no se modifican y no se copian dentro de los resultados.

## Ejecución

Desde la raíz del proyecto:

```bash
Rscript Latinobarometro_historico_Bolivia/analisis_exploratorio/analisis_exploratorio.R
```

El script usa R base y, si está instalado, el paquete `survey` para una sensibilidad parcial con conglomerados/estratos; vuelve a generar los CSV en `resultados/`. Requiere que estén presentes las carpetas `datos_extraidos/` y `documentacion/`.

## Qué incluye

- `INFORME_EXPLORATORIO.md`: hallazgos, interpretación provisional, límites y tema de artículo recomendado.
- `analisis_exploratorio.R`: extracción y recodificación transparente de las mediciones relevantes.
- `resultados/`: tablas de oleadas, cruces, pruebas exploratorias, no respuesta, territorio, comparaciones pareadas de 2023 y modelos logísticos 2024.

El núcleo cuantitativo cubre matrimonio igualitario en 2010/2015/2023, justificación moral en 2002/2004/2008, actitudes sobre cuatro ámbitos de derechos en 2023 y distancia social en 1998/2024. Se conservan como mediciones separadas; no se construye un índice total de “tolerancia”. También se exploran dos preguntas de saliencia pública sobre discriminación (2006 y 2008), sin tratarlas como prevalencias de experiencia.

## Advertencias de interpretación

- Son cortes transversales repetidos, no un panel de las mismas personas.
- Los porcentajes distinguen respuestas válidas del total y muestran la no respuesta.
- Las ponderaciones de microdatos se aplican cuando el archivo tiene pesos variables; en las rondas con WT=1 no hay ponderación en el archivo.
- Los intervalos y p-valores de las comparaciones entre oleadas son aproximaciones bajo muestreo aleatorio simple. Para 2024 también se incluye una sensibilidad parcial con `COMDIST` como conglomerado y `REG` como estrato; no reconstruye las cuatro etapas ni las cuotas de la ficha técnica.
- Los modelos expresan asociaciones; no establecen causalidad.
- Los datos miden opiniones de población encuestada, no tamaño ni experiencias de la población LGBTIQ+.

## Fuentes

Los enunciados y códigos se contrastaron con cuestionarios y libros de códigos de las oleadas correspondientes en `../documentacion/`. La fuente oficial publica la [documentación y datos de Latinobarómetro 2024](https://www.latinobarometro.org/latinobarometro-2024); su ficha técnica está [aquí](https://www.latinobarometro.org/documents/LAT-2024/latinobarometro-2024-fichas-tecnicas.pdf).

No se distribuyen ni republican aquí los datos originales; este paquete contiene solo código y resultados derivados para trabajo académico.
