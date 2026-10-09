# Ejecución y alcance del cierre

Informe principal: `INFORME_CIERRE_METODOLOGICO.md`. Los CSV de `resultados` son agregados, no microdatos.

Desde la raíz del proyecto, con R 4.5.0 y MASS, nnet, survey y haven:

```sh
Rscript Latinobarometro_historico_Bolivia/cierre_metodologico_2026_10_08/cerrar_pendientes.R
Rscript Latinobarometro_historico_Bolivia/auditoria_tecnica_2026_10_08/verificacion_independiente.R
Rscript Latinobarometro_historico_Bolivia/cierre_metodologico_2026_10_08/verificar_reproduccion.R
```

La primera orden regenera también el análisis principal. La última exige una carpeta `reconstruccion_limpia` inexistente para no confundir resultados anteriores con nuevos; si ya existe, conservarla y elegir otra ruta en el script. La prueba no borra archivos.

Entradas adicionales locales no redistribuidas: SPSS oficial agregado 2023, archivo `Latinobarometro_2023_Esp_Spss_v1_0.sav`, en `documentacion`; descargar el ZIP enlazado en el informe. También se requieren los 23 CSV nacionales en `datos_extraidos/AAAA`. Las etiquetas se leen con `user_na=TRUE`.

La matriz muestral histórica está en `auditoria_tecnica_2026_10_08/resultados/matriz_muestreo_23_oleadas_cotejo_18.csv`; sirve como base de transcripción. El cierre genera la matriz actualizada con 22 cotejos de descripción/cobertura y uno parcial. La actualización documental es una transcripción verificable con localizadores, no una reconstrucción automática de probabilidades.

`estado_previo`, `documentacion`, `reconstruccion_limpia` y `sesion_R.txt` se conservan localmente; no se publican originales de terceros ni rutas personales. Los seis controles no certifican cierre universal: la ficha específica 2023, probabilidades de selección y homologación de otras covariables quedan explícitamente pendientes.
