# Laboratorio de Latinobarómetro Bolivia

Autor: Jean Paolo Porcel Inquillo. Estado: versión de trabajo del 8 de octubre de 2026.

Repositorio público: https://github.com/MonsieurUlupica/latinobarometro-bolivia-laboratorio

El laboratorio documenta el análisis secundario de 23 bases bolivianas de 1996–2024. El artículo utiliza catorce mediciones en diez oleadas. El código exploratorio, el análisis exhaustivo y la verificación independiente son etapas distintas. La verificación incorpora 2009 y corrige la interpretación de identificadores y umbrales. Las salidas anteriores se conservan para trazabilidad, no deben tratarse como resultados finales intercambiables.

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

Desde la raíz del repositorio, con R y los paquetes `MASS`, `nnet` y `survey`:

```sh
Rscript Latinobarometro_historico_Bolivia/analisis_exploratorio/analisis_exploratorio.R
Rscript Latinobarometro_historico_Bolivia/analisis_exhaustivo/analisis_exhaustivo.R
Rscript Latinobarometro_historico_Bolivia/auditoria_tecnica_2026_10_08/verificacion_independiente.R
```

El script exploratorio es una etapa histórica, no un requisito del análisis exhaustivo. La verificación independiente lee las salidas del análisis exhaustivo y debe ejecutarse después. Estas ejecuciones regeneran salidas en el equipo del lector. Trabajar en una copia si se desean preservar las salidas publicadas. No se ha realizado aún una prueba de reconstrucción desde un clon limpio con todas las entradas descargadas nuevamente.

Los porcentajes describen respuestas observadas. Las pruebas e intervalos SRS son sensibilidades bajo supuestos simplificados; `REG` y `COMDIST` no reconstruyen el diseño oficial. No se estima población LGBTIQ+, cambio individual ni efectos causales.

## Citar el laboratorio

Porcel Inquillo, J. P. (2026). *Laboratorio de opinión pública sobre diversidad sexual y de género en Bolivia con Latinobarómetro 1996–2024* [Código y resultados agregados]. Recuperado de https://github.com/MonsieurUlupica/latinobarometro-bolivia-laboratorio

Para fijar una versión, añadir la URL del commit publicado. No se ha asignado DOI. El repositorio no reemplaza la cita de los datos ni la documentación de Corporación Latinobarómetro.

## Pendientes que no se consideran resueltos

1. Cotejo muestral país por país de 2016, 2017, 2018, 2020 y 2023; prioridad sustantiva en 2023.
2. Reconstrucción de estratos, conglomerados, cuotas y probabilidades originales; documentación de selección y tasas de respuesta.
3. Caracterización sociodemográfica homologada de las diez muestras sustantivas. El perfil mecánico de 23 oleadas no sustituye ese cotejo.
4. Significado documental del código −5 de 2023 y contexto completo del ítem moral de 2009.
5. Diagnósticos adicionales de celdas escasas y selección por casos completos.

## Derechos y alcance

Los datos pertenecen a sus productores. Este repositorio no autoriza redistribuir datos ni textos de terceros. No se asigna por defecto una licencia abierta al trabajo original; su licencia deberá ser definida por el autor. El paquete público cubre el laboratorio Latinobarómetro, no los expedientes de prensa, SISOBS, EMH o Censo.
