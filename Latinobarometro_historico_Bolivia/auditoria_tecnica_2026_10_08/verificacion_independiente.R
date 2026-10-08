# Auditoría independiente. No modifica bases, salidas anteriores ni artículo.
# Ejecutar desde la raíz del proyecto con Rscript.
options(stringsAsFactors=FALSE, scipen=999)
root <- "Latinobarometro_historico_Bolivia"
old <- file.path(root,"analisis_exhaustivo/resultados")
out <- file.path(root,"auditoria_tecnica_2026_10_08/resultados")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
save_table <- function(d,name) write.csv(d,file.path(out,name),row.names=FALSE,na="",fileEncoding="UTF-8")
read_wave <- function(y) {
  f <- list.files(file.path(root,"datos_extraidos",y),pattern="\\.csv$",full.names=TRUE)
  stopifnot(length(f)==1)
  z <- readLines(f,encoding="UTF-8",warn=FALSE)
  z <- sub("^\\ufeff","",z)
  z <- sub(";$","",z)
  read.csv(text=paste(z,collapse="\n"),sep=";",check.names=FALSE,na.strings=c("","NA"))
}
get <- function(d,v) {
  i <- match(tolower(v),tolower(names(d)))
  if(is.na(i)) return(rep(NA_real_,nrow(d)))
  suppressWarnings(as.numeric(d[[i]]))
}
files <- list.files(old,pattern="csv$",full.names=TRUE)
inventory <- do.call(rbind,lapply(files,function(f) {
  d<-read.csv(f,check.names=FALSE)
  data.frame(archivo=basename(f),filas=nrow(d),columnas=ncol(d),md5=unname(tools::md5sum(f)))
}))
save_table(inventory,"inventario_salidas_previas.csv")
items <- read.csv(file.path(old,"diccionario_mediciones_directas.csv"))
extra <- items[items$anio==2008 & items$constructo=="justificacion_moral",]
extra$anio <- 2009
extra$variable <- "P63WVSST"
extra$fuente_local <- "04_Hallazgos_y_Analisis/bibliografia_textos/descargas_abiertas/Latinobarometro_2009_Libro_Codigos_Oficial.pdf; P63WVSST"
extra$comparabilidad <- "Mismos extremos 1–10 en el libro de códigos; contexto y universo requieren cotejo antes de inferencia temporal homogénea"
items <- rbind(items,extra)
items <- items[order(items$anio),]
save_table(items,"diccionario_mediciones_ampliado_2009.csv")
data <- setNames(lapply(sort(unique(items$anio)),read_wave),sort(unique(items$anio)))
check_rows <- list(); full_rows <- list()
previous <- read.csv(file.path(old,"resumen_indicadores_directos.csv"))
for(i in seq_len(nrow(items))) {
  it<-items[i,]; d<-data[[as.character(it$anio)]]; x<-get(d,it$variable)
  if(it$constructo=="justificacion_moral") ok<-x %in% 1:10
  else if(it$constructo %in% c("matrimonio","derechos_2023")) ok<-x %in% 1:4
  else if(it$constructo=="distancia_social") ok<-x %in% c(0,1)
  else if(it$anio==2006) ok<-x %in% 1:15
  else ok<-x %in% c(1:20,96,97)
  if(it$anio==2024) ok<-ok & get(d,"P3NOIJ.9") %in% 0
  target<-if(it$constructo=="distancia_social") 1 else if(it$constructo=="saliencia_discriminacion") {
    if(it$anio==2006) 7 else 13
  } else if(it$constructo %in% c("matrimonio","derechos_2023")) 1:2 else numeric()
  k<-if(length(target))sum(ok & x %in% target) else NA_integer_
  prior<-previous[previous$anio==it$anio & tolower(previous$variable)==tolower(it$variable),]
  check_rows[[i]]<-data.frame(anio=it$anio,variable=it$variable,n_total=nrow(d),n_valido=sum(ok),
    n_no_valido=sum(!ok),evento_n=k,pct_evento=if(length(target))100*k/sum(ok) else NA_real_,
    coincide_n_previo=if(nrow(prior))sum(ok)==prior$n_valido else NA,
    coincide_evento_previo=if(nrow(prior) && length(target))k==prior$conteo_objetivo else NA)
  for(code in sort(unique(x[!is.na(x)]))) {
    full_rows[[length(full_rows)+1L]]<-data.frame(anio=it$anio,variable=it$variable,codigo=code,
      n_crudo=sum(x==code,na.rm=TRUE),n_valido_categoria=sum(ok & x==code,na.rm=TRUE),
      denominador_valido=sum(ok),pct_valido=100*sum(ok & x==code,na.rm=TRUE)/sum(ok),
      advertencia=if(it$anio==2024)"Clasificación válida depende también de P3NOIJ.9" else "No respuesta y códigos especiales separados")
  }
}
save_table(do.call(rbind,check_rows),"verificacion_denominadores_y_eventos.csv")
save_table(do.call(rbind,full_rows),"distribuciones_recalculadas_14_items.csv")
morality <- do.call(rbind,lapply(c(2002,2004,2008,2009),function(y) {
  it<-items[items$anio==y & items$constructo=="justificacion_moral",]; d<-data[[as.character(y)]]
  x<-get(d,it$variable); ok<-x %in% 1:10; w<-get(d,"WT")
  stopifnot(all(is.finite(w)),all(w>0))
  data.frame(anio=y,n_total=nrow(d),n_valido=sum(ok),n_no_valido=sum(!ok),
    media=mean(x[ok]),mediana=median(x[ok]),n_1a4=sum(x[ok]<=4),n_5=sum(x[ok]==5),n_6a10=sum(x[ok]>=6),
    pct_1a4=100*mean(x[ok]<=4),pct_5=100*mean(x[ok]==5),pct_6a10=100*mean(x[ok]>=6),
    media_ponderada=weighted.mean(x[ok],w[ok]),n_kish=sum(w[ok])^2/sum(w[ok]^2),
    alcance="Distribución observada; no supone identidad de cobertura poblacional entre años")
}))
save_table(morality,"justificabilidad_2002_2004_2008_2009.csv")
# Los umbrales de polr son parámetros de corte, no OR de covariables.
coef<-read.csv(file.path(old,"modelos_ordinales_derechos_2023_coeficientes.csv"))
threshold<-grepl("|",coef$termino,fixed=TRUE)
cuts<-coef[threshold,c("variable","termino","beta","se_modelo","n")]
save_table(cuts,"umbrales_ordinales_separados.csv")
slopes<-coef[!threshold,]
slopes$p_holm_coef<-ave(slopes$p_srs,slopes$variable,FUN=function(z)p.adjust(z,"holm"))
save_table(slopes,"coeficientes_ordinales_sin_umbrales.csv")
# Sensibilidad pareada que usa exclusivamente el orden, no distancias 1–4.
d23<-data[["2023"]]
vars<-items$variable[items$anio==2023]
pairs<-combn(vars,2,simplify=FALSE)
pair_rows<-lapply(pairs,function(p) {
  a<-get(d23,p[1]); b<-get(d23,p[2]); ok<-a %in% 1:4 & b %in% 1:4
  positive<-sum(a[ok]<b[ok]); negative<-sum(a[ok]>b[ok]); ties<-sum(a[ok]==b[ok])
  pv<-if(positive+negative)binom.test(positive,positive+negative,p=.5)$p.value else 1
  data.frame(variable_a=p[1],variable_b=p[2],n_pares=sum(ok),mas_acuerdo_a=positive,
    mas_acuerdo_b=negative,empates=ties,n_no_empates=positive+negative,p_signos_srs=pv,
    alcance="Prueba exacta de signos como sensibilidad de independencia; sin ajuste al diseño oficial")
})
signs<-do.call(rbind,pair_rows); signs$p_holm_6<-p.adjust(signs$p_signos_srs,"holm")
save_table(signs,"pares_prueba_signos_ordinales_2023.csv")
tests<-read.csv(file.path(old,"pruebas_cruces_sensibilidad_srs.csv"))
counts<-do.call(rbind,lapply(sort(unique(tests$anio)),function(y) {
  z<-tests[tests$anio==y,]
  data.frame(anio=y,n_pruebas=nrow(z),n_p_holm_menor_005=sum(z$p_holm_familia<.05),
    n_minimo_esperado_menor_5=sum(z$minimo_esperado<5,na.rm=TRUE),
    n_diagnostico_esperado_no_aplica=sum(is.na(z$minimo_esperado)))
}))
save_table(counts,"conteo_pruebas_y_celdas_escasas.csv")
ids<-read.csv(file.path(old,"auditoria_oleadas.csv"))
ids$id_individual_verificado<-tolower(ids$variable_id_candidata)=="numentre"
ids$nota_id<-ifelse(ids$id_individual_verificado,
  "Candidato de entrevista; alcance de unicidad debe verificarse en documentación",
  "Sin identificador individual verificado; NUMINVES no es identificador de persona")
ids$filas_en_id_duplicado[!ids$id_individual_verificado]<-NA
save_table(ids,"auditoria_integridad_sin_confundir_NUMINVES.csv")
years<-ids$anio
sampling<-data.frame(anio=years,n_microdato=ids$filas_leidas,
  n_ficha=NA_integer_,empresa="",seleccion_documentada="",cobertura_declarada_pct=NA_real_,
  universo_documentado="No transcrito en la ficha consolidada",fecha_campo="",
  fuente="",pagina_fisica=NA_integer_,estado="Pendiente de cotejo país específico",
  limite="La descripción publicada no aporta todas las probabilidades de selección ni prueba que COMDIST sea la UPM",stringsAsFactors=FALSE)
for(y in years[years<=2015]) {
  i<-match(y,years)
  sampling$fuente[i]<-"documentacion/fichas_tecnicas_1995_2015.pdf"
  sampling$pagina_fisica[i]<-1
  sampling$estado[i]<-"Descripción y cobertura cotejadas visualmente en fila Bolivia; no reconstrucción íntegra de varianza"
  sampling$n_ficha[i]<-c(`1996`=772,`1997`=796,`1998`=794,`2000`=1000,`2001`=1080,`2002`=1242,`2003`=1200,`2004`=1201,
     `2005`=1200,`2006`=1200,`2007`=1200,`2008`=1200,`2009`=1200,`2010`=1200,`2011`=1200,`2013`=1200,`2015`=1200)[as.character(y)]
  sampling$empresa[i]<-if(y==1996)"Encuestas y Estudios" else if(y %in% c(1997,1998,2001,2003,2004,2005))"Equipos MORI Consultores" else if(y %in% c(2000,2002,2006,2007))"Apoyo, Opinión y Mercado" else "IPSOS Apoyo, opinión y mercado S.A."
  sampling$cobertura_declarada_pct[i]<-if(y %in% c(1996,1997))32 else if(y==1998)35 else if(y %in% c(2000,2001))52 else 100
  sampling$seleccion_documentada[i]<-if(y %in% c(1996,2001))"La ficha describe selección probabilística en tres etapas" else
    if(y %in% c(1997,1998,2000,2002,2003,2004,2005))"Dos etapas probabilísticas y selección final mediante cuotas" else
    if(y==2006)"Selección probabilística con tres etapas urbanas y cuatro rurales; cuota en etapa final" else
    if(y==2015)"Estratos con asignación proporcional a población; selección multietápica y cuota final" else
    "Tres etapas probabilísticas y selección final por cuotas"
}
i<-match(2024,years)
sampling$n_ficha[i]<-1200; sampling$empresa[i]<-"IPSOS CIESMORI"
sampling$seleccion_documentada[i]<-"Cuatro etapas totales: tres probabilísticas y una final por cuotas"
sampling$cobertura_declarada_pct[i]<-100; sampling$universo_documentado[i]<-"Población adulta de 18 años y más"
sampling$fecha_campo[i]<-"27 agosto–22 septiembre 2024"
sampling$fuente[i]<-"documentacion/fichas_tecnicas_2024.pdf"
sampling$pagina_fisica[i]<-1
sampling$estado[i]<-"Descripción país cotejada; nota de edad en página física 2; no reconstrucción íntegra de varianza"
sampling$diferencia_microdato_menos_ficha<-sampling$n_microdato-sampling$n_ficha
save_table(sampling,"matriz_muestreo_23_oleadas_cotejo_18.csv")
sessionInfo()
cat("Verificación independiente finalizada. Salidas:",out,"\n")
