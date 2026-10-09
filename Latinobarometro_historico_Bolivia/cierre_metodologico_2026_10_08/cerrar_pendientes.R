# Ejecutar desde la raíz del proyecto. Originales de solo lectura; salidas agregadas.
# Requiere MASS, nnet, survey y haven. No reconstruye probabilidades no publicadas.
source("Latinobarometro_historico_Bolivia/analisis_exhaustivo/analisis_exhaustivo.R")
CLOSE <- file.path(ROOT,"cierre_metodologico_2026_10_08")
CRES <- file.path(CLOSE,"resultados")
dir.create(CRES,recursive=TRUE,showWarnings=FALSE)
save_close <- function(d,f) write.csv(d,file.path(CRES,f),row.names=FALSE,na="",fileEncoding="UTF-8")

# Correspondencia independiente de etiquetas y registros en la versión SPSS oficial.
if(!requireNamespace("haven",quietly=TRUE)) stop("Instalar haven para cotejar etiquetas SPSS")
sav <- haven::read_sav(file.path(CLOSE,"documentacion","Latinobarometro_2023_Esp_Spss_v1_0.sav"),user_na=TRUE)
bol <- sav[as.numeric(sav$IDENPA)==68,]
csv <- DATA[["2023"]]
stopifnot(nrow(bol)==1200,nrow(csv)==1200,!anyDuplicated(bol$NUMENTRE),!anyDuplicated(csv$NUMENTRE))
ix <- match(as.numeric(csv$NUMENTRE),as.numeric(bol$NUMENTRE))
stopifnot(!anyNA(ix))
bol <- bol[ix,]
vv <- c(rights$variable,"SEXO","EDAD","REEEDUC.1","S1A","P16ST","S5")
agreement <- do.call(rbind,lapply(vv,function(v){
 a<-get_num(csv,v);b<-as.numeric(bol[[find_col(bol,v,required=TRUE)]])
 eq<-(is.na(a)&is.na(b))|(!is.na(a)&!is.na(b)&a==b)
 data.frame(variable=v,n=length(a),coincidencias=sum(eq),discrepancias=sum(!eq))
}))
save_close(agreement,"cotejo_csv_spss_2023.csv")
print(agreement)
stopifnot(all(agreement$discrepancias==0))
labels <- do.call(rbind,lapply(vv,function(v){
 z<-attr(bol[[find_col(bol,v,required=TRUE)]],"labels")
 data.frame(variable=v,codigo=as.numeric(z),etiqueta=names(z))
}))
save_close(labels,"etiquetas_spss_2023.csv")
stopifnot(all(labels$etiqueta[labels$variable%in%rights$variable & labels$codigo== -5]=="No sabe / No contesta"))

# Edad exacta y sexo registrado: diez muestras sustantivas. La educación histórica
# no se homologa por analogía; este cierre documenta las dos medidas cotejadas.
profiles<-bands<-list()
for(y in names(covmap)) {
 d<-DATA[[y]];m<-covmap[[y]];s<-get_num(d,m[["sexo"]]);a<-get_num(d,m[["edad"]])
 a[!is.finite(a)|a<15|a>110]<-NA
 profiles[[y]]<-data.frame(anio=as.integer(y),n=nrow(d),variable_sexo=m[["sexo"]],variable_edad=m[["edad"]],
  hombres=sum(s==1,na.rm=TRUE),mujeres=sum(s==2,na.rm=TRUE),sexo_no_valido=sum(!s%in%1:2),
  n_edad=sum(!is.na(a)),edad_no_valida=sum(is.na(a)),edad_min=min(a,na.rm=TRUE),edad_max=max(a,na.rm=TRUE),
  mediana=median(a,na.rm=TRUE),q1=unname(quantile(a,.25,na.rm=TRUE)),q3=unname(quantile(a,.75,na.rm=TRUE)),
  nivel_medicion="Edad exacta en años; sexo 1 hombre / 2 mujer; no mide identidad de género")
 g<-cut(a,c(14,29,44,59,110),labels=c("15–29","30–44","45–59","60+"))
 tt<-table(g)
 bands[[y]]<-data.frame(anio=as.integer(y),banda=names(tt),n=as.integer(tt),denominador=sum(tt),pct=100*as.integer(tt)/sum(tt))
}
save_close(do.call(rbind,profiles),"perfil_homologado_sexo_edad_10_oleadas.csv")
save_close(do.call(rbind,bands),"bandas_edad_10_oleadas.csv")
trace<-data.frame(anio=as.integer(names(covmap)),pregunta_sexo=c("S1","S1","S1","S6 / SEXO","S8","S5","S7 / SEXO","S12","SEXO","SEXO"),
 pregunta_edad=c("S2","S2","S2","S7","S9","S6","S8 / EDAD","S13","EDAD","EDAD"),
 respaldo=c(rep("Cuestionario español de la oleada",5),"Cuestionario inglés 2009, preguntas S5/S6","Cuestionario y libro de códigos 2010","Cuestionario español 2015","Cuestionario y SPSS oficial 2023","Cuestionario español 2024"),
 alcance="Comparabilidad de edad exacta y sexo registrado; no certifica educación, religión o selección equivalentes")
save_close(trace,"trazabilidad_perfil_10_oleadas.csv")

# Transcripción de las fichas nuevas: las descripciones no equivalen a pesos de
# inclusión recuperados. Se conserva 2023 como cotejo parcial, no como ausencia.
sampling<-read.csv(file.path(ROOT,"auditoria_tecnica_2026_10_08/resultados/matriz_muestreo_23_oleadas_cotejo_18.csv"))
for(y in c(2016,2017,2018,2020)) {
 i<-which(sampling$anio==y)
 sampling$n_ficha[i]<-1200;sampling$cobertura_declarada_pct[i]<-100
 sampling$seleccion_documentada[i]<-if(y%in%c(2016,2017)) "Estratificado proporcional, multietápico, cuota final; ficha resumen" else "Departamento × urbano/rural; cuatro etapas: localidad PPT, zona, hogar, persona por cuotas de sexo/edad/educación"
 sampling$empresa[i]<-if(y==2017) "IPSOS Apoyo Opinión y Mercado S.A." else if(y==2016) "IPSOS Bolivia" else "Ipsos (informe metodológico boliviano)"
 sampling$fuente[i]<-switch(as.character(y),`2016`="documentacion/Fichas_tecnicas_2016.pdf",`2017`="cierre_metodologico_2026_10_08/documentacion/Informe_2017.pdf",`2018`="cierre_metodologico_2026_10_08/documentacion/Metodologico_2018.pdf",`2020`="cierre_metodologico_2026_10_08/documentacion/Metodologico_2020.pdf")
 sampling$pagina_fisica[i]<-switch(as.character(y),`2016`=1,`2017`=66,`2018`=25,`2020`=16)
 sampling$estado[i]<-"Descripción país y cobertura cotejadas; no varianza reconstruida"
 sampling$diferencia_microdato_menos_ficha[i]<-0
 if(y%in%c(2018,2020)) sampling$universo_documentado[i]<-"18 años y más; urbano/rural; entrevista en castellano; excluye a quienes no lo hablan"
 if(y==2018) sampling$fecha_campo[i]<-"23 junio–19 julio 2018"
 if(y==2020) sampling$fecha_campo[i]<-"26 octubre–17 noviembre 2020"
}
i<-which(sampling$anio==2023)
sampling$universo_documentado[i]<-"18 años y más; cara a cara; informe general 2023"
sampling$fecha_campo[i]<-"20 febrero–30 marzo: ventana compartida por diez países; no fechas Bolivia específicas"
sampling$fuente[i]<-"Informe general 2023 p.3; catálogo país /ws/web/country-documents/2/LAT-2023/4167"
sampling$estado[i]<-"Cotejo parcial; sección samplingHtml vacía en respuesta oficial del 8 octubre 2026"
sampling$limite[i]<-"No se recuperó ficha boliviana detallada; no atribuir selección o cobertura de otra oleada. Se requiere productor para confirmar documentación adicional."
sampling$cotejo_descripcion_cobertura<-sampling$anio!=2023
save_close(sampling,"matriz_muestreo_23_oleadas_actualizada.csv")

# Hallazgo documental adicional, separado del corpus principal de 14 ítems.
x09<-get_num(DATA[["2009"]],"P64ST.A")
save_close(data.frame(anio=2009,variable="P64ST.A",enunciado_ingles="Gay; groups would not like to have as neighbors; Q64, card 19",n_archivo=length(x09),menciones=sum(x09==1),cero_no_mencion=sum(x09==0),
 pct_sobre_archivo=100*mean(x09==1),estado="Hallazgo complementario; código 0/1 corroborado por codebook, texto literal español aún no recuperado; no añadir como serie homogénea con 1998/2024"),"hallazgo_complementario_vecinos_2009.csv")

# Selección por casos completos: separar no respuesta del resultado de faltantes
# en predictores. Las pérdidas por predictor se superponen y no deben sumarse.
retention<-missing<-patterns<-sensitivity<-thresholds<-list()
put_retention<-function(y,v,response,complete,event) {
 for(label in c("respuesta_valida","casos_completos","validos_excluidos")) {
  use<-switch(label,respuesta_valida=response,casos_completos=complete,validos_excluidos=response & !complete)
  retention[[length(retention)+1L]]<<-data.frame(anio=y,variable=v,grupo=label,n=sum(use),
   eventos=sum(event[use],na.rm=TRUE),pct_evento=if(sum(use))100*mean(event[use]) else NA)
 }
}
put_missing<-function(y,v,md,response,terms) {
 for(term in terms) missing[[length(missing)+1L]]<<-data.frame(anio=y,variable=v,predictor=term,
  n_respuesta_valida=sum(response),n_faltante_entre_validos=sum(response & is.na(md[[term]])))
 mm<-is.na(md[,terms,drop=FALSE])[response,,drop=FALSE]
 pat<-apply(mm,1,function(x)paste(terms[x],collapse=" + "))
 pat[pat==""]<-"Ninguno"
 tt<-table(pat)
 patterns[[length(patterns)+1L]]<<-data.frame(anio=y,variable=v,patron=names(tt),n=as.integer(tt))
}
extract_fit<-function(fit,y,v,spec,n){
 sm<-coef(summary(fit));keep<-grepl("^sexo|^edad",rownames(sm))
 z<-sm[keep,,drop=FALSE]
 data.frame(anio=y,variable=v,especificacion=spec,termino=rownames(z),n=n,
  beta=z[,1],se=z[,2],OR=exp(z[,1]),ic95_inf=exp(z[,1]-1.96*z[,2]),ic95_sup=exp(z[,1]+1.96*z[,2]),
  alcance="Sensibilidad de modelo no ponderado; no inferencia de diseño ni corrección del sesgo de selección",row.names=NULL)
}
for(v in rights$variable) {
 md<-ord_data
 md$respuesta<-ordered(get_num(csv,v),levels=c(4,3,2,1))
 response<-!is.na(md$respuesta);cc<-complete.cases(md[,c("respuesta",ord_terms)])
 event<-get_num(csv,v)%in%1:2
 put_retention(2023,v,response,cc,event);put_missing(2023,v,md,response,ord_terms)
 for(spec in c("sexo_edad_validos","sexo_edad_misma_submuestra","modelo_completo")) {
  use<-if(spec=="sexo_edad_validos") complete.cases(md[,c("respuesta","sexo","edad")]) else cc
  f<-if(spec=="modelo_completo") ord_formula else respuesta~sexo+edad
  fit<-MASS::polr(f,data=md[use,],method="logistic",Hess=TRUE)
  sensitivity[[length(sensitivity)+1L]]<-extract_fit(fit,2023,v,spec,sum(use))
  if(spec=="modelo_completo") {
   z<-coef(summary(fit));z<-z[grepl("|",rownames(z),fixed=TRUE),,drop=FALSE]
   thresholds[[length(thresholds)+1L]]<-data.frame(variable=v,termino=rownames(z),beta=z[,1],se=z[,2],n=sum(use),row.names=NULL)
  }
 }
 # Mantener no aplicable (-3) como categoría distinta, sin asignar religiosidad.
 nap<-get_num(csv,"S1A")== -3
 md$practica<-factor(ifelse(nap,5,as.numeric(as.character(md$practica))),levels=1:5)
 use<-complete.cases(md[,c("respuesta",ord_terms)])
 fit<-MASS::polr(ord_formula,data=md[use,],method="logistic",Hess=TRUE)
 sensitivity[[length(sensitivity)+1L]]<-extract_fit(fit,2023,v,"no_aplica_practica_separada",sum(use))
}
t24<-c("sexo","edad_decadas","educacion","practica","ideologia","clase","ingreso_subjetivo","otros_grupos_rechazados")
put_retention(2024,"P3NOIJ.3",responded24,model_complete,y24==1)
put_missing(2024,"P3NOIJ.3",model24,responded24,t24)
for(spec in c("sexo_edad_validos","sexo_edad_misma_submuestra","modelo_completo")) {
 use<-if(spec=="sexo_edad_validos") responded24 & complete.cases(model24[,c("sexo","edad_decadas")]) else model_complete
 f<-if(spec=="modelo_completo") as.formula(paste("y ~",paste(t24,collapse="+"))) else y~sexo+edad_decadas
 fit<-glm(f,data=model24[use,],family=binomial())
 sensitivity[[length(sensitivity)+1L]]<-extract_fit(fit,2024,"P3NOIJ.3",spec,sum(use))
}
save_close(do.call(rbind,retention),"seleccion_casos_completos_resultado.csv")
save_close(do.call(rbind,missing),"perdidas_por_covariable.csv")
save_close(do.call(rbind,patterns),"patrones_faltantes_predictores.csv")
save_close(do.call(rbind,sensitivity),"modelos_seleccion_y_ajuste_sensibilidad.csv")
save_close(do.call(rbind,thresholds),"umbrales_ordinales_verificados.csv")
# Perfiles conjuntos: describir composición del grupo excluido, sin imputar sus
# respuestas a los cuatro ítems ni asignarle un perfil de opinión no observado.
joint<-do.call(rbind,lapply(c(TRUE,FALSE),function(inc) {
 use<-complete_rights==inc;age<-get_num(csv,"EDAD");sex<-get_num(csv,"SEXO")
 data.frame(grupo=if(inc)"Cuatro respuestas válidas" else "Al menos una no válida",n=sum(use),hombres=sum(use & sex==1),mujeres=sum(use & sex==2),
  edad_mediana=median(age[use]),edad_q1=unname(quantile(age[use],.25)),edad_q3=unname(quantile(age[use],.75)))
}))
save_close(joint,"seleccion_perfiles_conjuntos_2023.csv")

# Cambio de pruebas bajo celdas escasas y corrección familiar Holm.
baseline<-file.path(CRES,"linea_base_pruebas_61.csv")
if(!file.exists(baseline)) {
 original<-file.path(CLOSE,"estado_previo","resultados","pruebas_cruces_sensibilidad_srs.csv")
 if(!file.exists(original)) stop("Falta línea base de pruebas agregadas; obtenerla del paquete publicado")
 stopifnot(file.copy(original,baseline,overwrite=FALSE))
}
old<-read.csv(baseline)
new<-read.csv(file.path(RES,"pruebas_cruces_sensibilidad_srs.csv"))
cmp<-merge(old,new,by=c("anio","variable","predictor"),suffixes=c("_previo","_actual"))
cmp$cambio_decision_Holm_005<-(cmp$p_holm_familia_previo<.05)!=(cmp$p_holm_familia_actual<.05)
cmp$error_MC_aproximado<-ifelse(grepl("Monte Carlo",cmp$metodo_actual),sqrt(cmp$p_srs_actual*(1-cmp$p_srs_actual)/MC_B),NA)
save_close(cmp,"cotejo_pruebas_antes_despues.csv")
checks<-data.frame(control=c("23 oleadas leídas","14 ítems únicos","10 oleadas sustantivas","CSV-SPSS diez variables sin discrepancias","68 pendientes ordinales sin umbrales","12 umbrales separados"),
 cumple=c(length(DATA)==23,nrow(items)==14&&!anyDuplicated(items[,c("anio","variable")]),length(unique(items$anio))==10,
 all(agreement$discrepancias==0),nrow(ordinal_coef)==68&&!any(grepl("|",ordinal_coef$termino,fixed=TRUE)),sum(vapply(thresholds,nrow,0L))==12))
stopifnot(all(checks$cumple))
save_close(checks,"controles_automaticos.csv")
writeLines(capture.output(sessionInfo()),file.path(CLOSE,"sesion_R.txt"))
cat("Cierre analítico ejecutado; controles:",sum(checks$cumple),"/",nrow(checks),"\n")
