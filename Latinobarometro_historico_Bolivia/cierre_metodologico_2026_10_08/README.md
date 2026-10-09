# Ejecución y alcance del cierre

Estado vigente: `CIERRE_VERIFICADO.md`. `INFORME_CIERRE_METODOLOGICO.md` conserva la etapa anterior. Los CSV de `resultados` son agregados, no microdatos.

Desde la raíz del proyecto, con R 4.5.0 y MASS, nnet, survey y haven:

```sh
Rscript Latinobarometro_historico_Bolivia/cierre_metodologico_2026_10_08/cerrar_pendientes.R
Rscript Latinobarometro_historico_Bolivia/auditoria_tecnica_2026_10_08/verificacion_independiente.R
Rscript Latinobarometro_historico_Bolivia/cierre_metodologico_2026_10_08/verificar_reproduccion.R
Rscript Latinobarometro_historico_Bolivia/cierre_metodologico_2026_10_08/completar_cotejos.R
Rscript Latinobarometro_historico_Bolivia/cierre_metodologico_2026_10_08/diagnostico_factorial.R
```

La primera orden regenera también el análisis principal. La última exige una carpeta `reconstruccion_limpia` inexistente para no confundir resultados anteriores con nuevos; si ya existe, conservarla y elegir otra ruta en el script. La prueba no borra archivos.

Entradas adicionales locales no redistribuidas: SPSS oficial agregado 2023, archivo `Latinobarometro_2023_Esp_Spss_v1_0.sav`, en `documentacion`; descargar el ZIP enlazado en el informe. También se requieren los 23 CSV nacionales en `datos_extraidos/AAAA`. Las etiquetas se leen con `user_na=TRUE`.

La matriz muestral histórica está en `auditoria_tecnica_2026_10_08/resultados/matriz_muestreo_23_oleadas_cotejo_18.csv`; sirve como base de transcripción. El cierre genera la matriz actualizada con 22 cotejos de descripción/cobertura y uno parcial. La actualización documental es una transcripción verificable con localizadores, no una reconstrucción automática de probabilidades.

Para el diagnóstico factorial instalar `lavaan` (versión ejecutada 0.7-3). `completar_cotejos.R` requiere `pdftotext` en PATH, los cuestionarios nacionales archivados, el libro 2023, los PDF y TXT de los informes metodológicos 2018/2020 y el ZIP CSVText oficial 2024 en las rutas indicadas por el código. Son entradas del productor, no redistribuidas.

`verificar_redescarga.py` requiere Python, curl, Rscript y un clon separado en `clon_verificacion`. El ensayo ejecutado redescargó 23 CSV y reprodujo 43 salidas principales; aporta documentación desde el expediente local y compara la identidad del código principal. No es una comprobación automática de todos los análisis suplementarios. Ejecutar desde una copia; las descargas en caché se reutilizan.

`estado_previo`, `documentacion`, `reconstruccion_limpia`, `clon_verificacion` y `sesion_R.txt` se conservan localmente; no se publican originales de terceros ni rutas personales. La homologación adicional y los diagnósticos enumerados están ejecutados. La ficha específica 2023 y las probabilidades originales requieren confirmación del productor, conforme al informe vigente.
