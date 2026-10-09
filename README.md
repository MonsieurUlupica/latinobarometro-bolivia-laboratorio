# Laboratorio de Latinobarómetro Bolivia

Autor: Jean Paolo Porcel Inquillo. Estado: versión de trabajo del 8 de octubre de 2026.

Repositorio público: https://github.com/MonsieurUlupica/latinobarometro-bolivia-laboratorio

El laboratorio documenta el análisis secundario de 23 bases bolivianas de 1996–2024. El artículo utiliza catorce mediciones en diez oleadas. El código exploratorio, el análisis exhaustivo, la verificación independiente y el cierre metodológico son etapas distintas. El código principal ya incorpora 2009 y exporta pendientes y umbrales por separado. El estado vigente se documenta en [el informe de cierre](Latinobarometro_historico_Bolivia/cierre_metodologico_2026_10_08/INFORME_CIERRE_METODOLOGICO.md); los informes previos conservan observaciones históricas, no una lista actual de pendientes.

## Contenido público

- Código R de las tres etapas y documentación propia.
- Diccionarios, matrices de comparabilidad, resultados agregados, modelos y sensibilidades.
- Inventario de archivos y huellas SHA-256 para verificar las entradas originales.
- Registro de discrepancias y pendientes metodológicos.

No se publican microdatos, registros armonizados por persona, filas de auditoría de identificadores, artículos completos, cuestionarios ni libros de códigos de terceros. El manuscrito del concurso tampoco se publica en esta versión.

## Obtener las entradas

Latinobarómetro permite uso académico y prohíbe redistribuir sus bases. Descargar los archivos desde [el catálogo oficial](https://www.latinobarometro.org/agregados), respetando sus condiciones. Crear `Latinobarometro_historico_Bolivia/datos_extraidos/AAAA/` con exactamente un CSV boliviano por año. Mantener los CSV originales con separador punto y coma. El inventario y `huellas_entradas.json` identifican los archivos utilizados.

Las carpetas corresponden a 1996, 1997, 1998, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2013, 2015, 2016, 2017, 2018, 2020, 2023 y 2024. Esta lista describe el corpus descargado, no una serie anual completa ni 23 mediciones equivalentes.

Consultar cuestionarios, libros de códigos y fichas oficiales para respaldar las recodificaciones. El análisis exhaustivo contiene rutas locales esperadas para la documentación; sin esos documentos, algunas comprobaciones de disponibilidad no reproducirán el expediente local. Las huellas permiten comprobar entradas, no garantizan por sí solas corrección científica.

## Ejecución

Desde la raíz del repositorio, con R y los paquetes `MASS`, `nnet`, `survey` y `haven` para el cotejo SPSS:

```sh
Rscript Latinobarometro_historico_Bolivia/analisis_exploratorio/analisis_exploratorio.R
Rscript Latinobarometro_historico_Bolivia/analisis_exhaustivo/analisis_exhaustivo.R
Rscript Latinobarometro_historico_Bolivia/auditoria_tecnica_2026_10_08/verificacion_independiente.R
Rscript Latinobarometro_historico_Bolivia/cierre_metodologico_2026_10_08/cerrar_pendientes.R
```

El script exploratorio es una etapa histórica, no un requisito del análisis exhaustivo. La verificación independiente lee las salidas del análisis exhaustivo y debe ejecutarse después. El cierre regenera también el código principal y requiere adicionalmente el SPSS agregado oficial 2023, no redistribuido; su enlace y ruta local están en el README de esa etapa. Trabajar en una copia para preservar salidas anteriores. `verificar_reproduccion.R` regeneró 43 CSV idénticos en un directorio nuevo, usando las mismas entradas locales; no equivale a un clon con entradas redescargadas.

Los porcentajes describen respuestas observadas. Las pruebas e intervalos SRS son sensibilidades bajo supuestos simplificados; `REG` y `COMDIST` no reconstruyen el diseño oficial. No se estima población LGBTIQ+, cambio individual ni efectos causales.

## Citar el laboratorio

Porcel Inquillo, J. P. (2026). *Laboratorio de opinión pública sobre diversidad sexual y de género en Bolivia con Latinobarómetro 1996–2024* [Código y resultados agregados]. Recuperado de https://github.com/MonsieurUlupica/latinobarometro-bolivia-laboratorio

Para fijar una versión, añadir la URL del commit publicado. No se ha asignado DOI. El repositorio no reemplaza la cita de los datos ni la documentación de Corporación Latinobarómetro.

## Estado del cotejo y del análisis

- Descripción y cobertura muestral cotejadas para 22 de 23 ediciones. En 2023 se verificaron universo y modalidad; falta ficha boliviana detallada. «18 de 23» era cotejo documental, no cantidad de bases recuperadas.
- Resuelto −5 de 2023 mediante etiquetas SPSS y coincidencia de 1.200 registros en diez campos frente al CSV.
- Homologados sexo registrado y edad exacta de las diez muestras sustantivas. Otras covariables históricas requieren armonización específica.
- Ejecutados Monte Carlo condicional en tablas mayores escasas y diagnósticos de selección por casos completos, con sensibilidad a no aplicable en práctica religiosa.
- Contexto de 2009 revisado en cuestionario inglés y libro español; falta cuestionario español para identidad literal. Se documenta un ítem vecinal adicional como hallazgo complementario, no como serie homogénea.

## Lo que continúa abierto

Reconstrucción integral de unidades y probabilidades originales y tasas de respuesta; ficha boliviana detallada 2023; discrepancias de N de 2000/2001; cotejo literal español 2009; homologación de educación y demás covariables históricas. La solicitud técnica al productor está preparada, no enviada. Estos asuntos no se confunden con las tareas efectivamente ejecutadas.

## Derechos y alcance

Los datos pertenecen a sus productores. Este repositorio no autoriza redistribuir datos ni textos de terceros. No se asigna por defecto una licencia abierta al trabajo original; su licencia deberá ser definida por el autor. El paquete público cubre el laboratorio Latinobarómetro, no los expedientes de prensa, SISOBS, EMH o Censo.
