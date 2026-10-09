# Cotejos finales desde originales intactos. Salidas agregadas, sin identificadores personales.
# Ejecutar desde la raíz del proyecto. R + MASS, nnet, survey. No requiere nuevos datos.
source("Latinobarometro_historico_Bolivia/analisis_exhaustivo/analisis_exhaustivo.R")
FINAL <- file.path(ROOT,"cierre_metodologico_2026_10_08")
FR <- file.path(FINAL,"resultados")
put <- function(x,f) write.csv(x,file.path(FR,f),row.names=FALSE,na="",fileEncoding="UTF-8")

# Las etiquetas de un código de religión cambian entre ediciones. Se retienen
# originales y solo se agrupan anclas explícitas: católica, ninguna y otras.
maps <- list(
 `1998`=c(educacion="S14A",practica="SP81",religion="SP80",ideologia="SP52",ingreso="SP83"),
 `2002`=c(educacion="REEDUC1",practica="P66ST",religion="P65ST",ideologia="P64ST",ingreso="P67ST"),
 `2004`=c(educacion="REEDUC1",practica="P91ST",religion="P90ST",ideologia="P87ST",ingreso="P89ST"),
 `2006`=c(educacion="REEDUC1",practica="S3",religion="S2",ideologia="P47ST",ingreso="S1"),
 `2008`=c(educacion="REEDUC1",practica="S6",religion="S5",ideologia="P56ST",ingreso="S2"),
 `2009`=c(educacion="REEDUC1",practica="S8",religion="S7",ideologia="P69ST",ingreso="S2"),
 `2010`=c(educacion="REEDUC1",practica="S10",religion="S9",ideologia="P60ST",ingreso="S4"),
 `2015`=c(educacion="REEDUC_1",practica="S16.A",religion="S16",ideologia="P27ST",ingreso="S4"),
 `2023`=c(educacion="REEEDUC.1",practica="S1A",religion="S1",ideologia="P16ST",ingreso="S5"),
 `2024`=c(educacion="REEDUC.1",practica="S1A",religion="S1",ideologia="P16ST",ingreso="S5"))
rules <- c(educacion="1-7; tres grupos: 1-3 básica o inferior, 4-5 secundaria/técnica, 6-7 superior",
 practica="1-4; -3 no aplicable separado; demás especiales excluidos",
 religion="1 católica; ninguna=15 en 1998/2002 y 97 desde 2004; otras positivas sustantivas separadas de negativos",
 ideologia="0-10; ninguna=-6 hasta 2015 y 97 en 2023/2024, separada del punto medio; 1998 no presenta ceros",
 ingreso="1-4: alcanza/ahorra, justo, dificultades, grandes dificultades")
dict<-dist<-rawdist<-histcross<-histtest<-list()
qfiles<-c(`1998`="Cuestionario_1998_ES.pdf",`2002`="Cuestionario_2002_ES.pdf",`2004`="Cuestionario_2004_ES.pdf",`2006`="Cuestionario_2006_ES.pdf",`2008`="latinobarometro-2008-cuestionario-esp.pdf",`2010`="Cuestionario_2010_ES.pdf",`2015`="Cuestionario_2015_ES.pdf",`2023`="Cuestionario_2023_ES.pdf",`2024`="latinobarometro-2024-cuestionario-esp.pdf")
sourcecache<-list()
for(y in names(maps)) {
 path<-if(y=="2009")file.path(FINAL,"documentacion","Cuestionario_2009_EN.pdf") else file.path(ROOT,"documentacion",qfiles[[y]])
 stopifnot(file.exists(path))
 lines<-system2("pdftotext",c("-layout",shQuote(path),"-"),stdout=TRUE)
 sourcecache[[y]]<-list(path=path,pages=strsplit(paste(lines,collapse="\n"),"\f")[[1]])
}
for(y in names(maps)) for(p in names(maps[[y]])) {
 v<-maps[[y]][[p]];d<-DATA[[y]];x<-get_num(d,v);stopifnot(!is.na(find_col(d,v)))
 z<-switch(p,educacion=ifelse(x%in%1:7,as.character(cut(x,c(0,3,5,7),labels=c("Básica o inferior","Secundaria/técnica","Superior"))),NA),
  practica=ifelse(x%in%1:4,paste0("Nivel ",x),ifelse(x== -3,"No aplicable",NA)),
  religion=ifelse(x>0 & x<=97,ifelse(x==1,"Católica",ifelse(x==if(y%in%c("1998","2002"))15 else 97,"Ninguna","Otras categorías sustantivas")),NA),
  ideologia=ifelse(x%in%0:10,as.character(x),ifelse(x==if(as.integer(y)>=2023)97 else -6,"Ninguna",NA)),
  ingreso=ifelse(x%in%1:4,paste0("Nivel ",x),NA))
 doc<-if(y=="2009")"Cuestionario inglés Q69 y S2/S7/S8; libro de códigos español" else if(y=="1998")"Cuestionario español SP52/SP80/SP81/SP83/S14A; libro de códigos" else if(y=="2024")"Cuestionario español 2024 y libro nacional" else paste("Cuestionario y libro de códigos español",y)
 token<-if(p=="educacion")if(y=="1998")"S14" else "RESUMEN EDUCA|EDUCATION SUMMARY" else if(y=="2009"&&p=="ideologia")"Q69ST" else if(y=="2023"||y=="2024")switch(p,practica="S1[.]A|S1A",religion="S1[.]",ideologia="P16ST",ingreso="S5[.]") else if(y=="2015"&&p=="practica")"S16[.]A" else v
 physical<-which(vapply(sourcecache[[y]]$pages,function(z)grepl(token,z,ignore.case=TRUE),FALSE))
 dict[[length(dict)+1]]<-data.frame(anio=y,predictor=p,variable=find_col(d,v),regla=rules[[p]],respaldo=doc,
  archivo_cuestionario=sourcecache[[y]]$path,paginas_fisicas_localizador=paste(physical,collapse=";"),
  comparabilidad=if(p=="religion")"Solo anclas agrupadas; otras religiones no se equiparan por código" else if(p=="practica")"Autodefinición ordinal; conservar cambios de filtro y no aplicable" else "Categorías cotejadas; no equivalencia del diseño entre años")
 tt<-table(z,useNA="no");nn<-sum(tt)
 dist[[length(dist)+1]]<-data.frame(anio=y,predictor=p,categoria=names(tt),n=as.integer(tt),n_valido=nn,n_original=nrow(d),no_clasificado=sum(is.na(z)),pct=100*as.integer(tt)/nn)
 rt<-table(x,useNA="ifany");rawdist[[length(rawdist)+1]]<-data.frame(anio=y,predictor=p,variable=v,codigo=names(rt),n=as.integer(rt),n_original=nrow(d))
 # Cruces adicionales de los ítems del corpus: distribución del resultado según
 # categorías homologadas. Ideología se agrupa sin convertir 'ninguna' en centro.
 g<-if(p=="ideologia")ifelse(x%in%0:10,as.character(cut(x,c(-1,3,6,10),labels=c("0-3","4-6","7-10"))),ifelse(x==if(as.integer(y)>=2023)97 else -6,"Ninguna",NA)) else z
 for(i in which(items$anio==as.integer(y))) {
  it<-items[i,];ry<-get_num(d,it$variable);ok<-valid_codes(it,ry,d);event<-ry%in%target_codes(it)
  for(cat in sort(unique(g[!is.na(g)]))) {
   u<-!is.na(g)&g==cat&ok;n<-sum(u);k<-sum(event[u],na.rm=TRUE)
   histcross[[length(histcross)+1]]<-data.frame(anio=y,variable=it$variable,predictor=p,categoria=cat,n_valido=n,eventos=if(it$constructo=="justificacion_moral")NA else k,pct_evento=if(it$constructo=="justificacion_moral"||n==0)NA else 100*k/n,mediana_codigo=if(n)median(ry[u]) else NA)
  }
  # Familia de cinco predictores por ítem; moral conserva la respuesta ordinal.
  use<-ok & !is.na(g)
  if(length(unique(g[use]))<2) next
  if(it$constructo=="justificacion_moral") {t<-kruskal.test(ry[use]~factor(g[use]));method<-"Kruskal-Wallis";minex<-NA}
  else {tab<-table(factor(g[use]),event[use]);if(ncol(tab)<2)next;ex<-suppressWarnings(chisq.test(tab,correct=FALSE));minex<-min(ex$expected)
   set.seed(20261008+i);t<-if(minex<5) if(all(dim(tab)==2))fisher.test(tab) else chisq.test(tab,simulate.p.value=TRUE,B=200000) else ex
   method<-if(minex<5)if(all(dim(tab)==2))"Fisher" else "Pearson Monte Carlo 200000" else "Pearson"}
  histtest[[length(histtest)+1]]<-data.frame(anio=y,variable=it$variable,predictor=p,n=sum(use),metodo=method,min_esperado=minex,p=t$p.value)
 }
}
dictionary<-do.call(rbind,dict)
# Educación recodificada no figura como pregunta independiente en 2023/2024.
# Su respaldo es el libro de códigos y la exportación oficial con etiquetas.
book23<-file.path(ROOT,"documentacion","Libro_codigos_2023_ES.pdf")
bp<-strsplit(paste(system2("pdftotext",c("-layout",shQuote(book23),"-"),stdout=TRUE),collapse="\n"),"\f")[[1]]
i<-dictionary$anio==2023 & dictionary$predictor=="educacion"
dictionary$archivo_cuestionario[i]<-book23
dictionary$paginas_fisicas_localizador[i]<-paste(which(vapply(bp,function(x)grepl("REEEDUC[.]1[.]",x),FALSE)),collapse=";")
dictionary$respaldo[i]<-"Libro de códigos español, REEEDUC.1; corroborado en etiquetas SPSS oficiales"
zip24<-file.path(ROOT,"documentacion","latinobarometro-2024-bolivia-csvtext-esp-v1.zip")
member<-unzip(zip24,list=TRUE)$Name[1]
labels24<-read.csv(unz(zip24,member),sep=";",check.names=FALSE,stringsAsFactors=FALSE)
idcol<-grep("^NUMENTRE ",names(labels24),value=TRUE);stopifnot(length(idcol)==1)
align<-match(get_num(DATA[["2024"]],"NUMENTRE"),labels24[[idcol]])
stopifnot(!anyNA(align),!anyDuplicated(align))
labelsout<-list()
for(p in names(maps[["2024"]])) {
 v<-maps[["2024"]][[p]];col<-grep(paste0("^",gsub(".","[.]",v,fixed=TRUE)," "),names(labels24),value=TRUE)
 stopifnot(length(col)==1)
 code<-get_num(DATA[["2024"]],v);label<-labels24[[col]][align]
 tt<-as.data.frame(table(code,label),stringsAsFactors=FALSE);tt<-tt[tt$Freq>0,]
 labelsout[[p]]<-data.frame(predictor=p,variable=v,codigo=tt$code,etiqueta=tt$label,n=tt$Freq)
}
put(do.call(rbind,labelsout),"etiquetas_covariables_csvtext_2024.csv")
i<-dictionary$anio==2024 & dictionary$predictor=="educacion"
dictionary$archivo_cuestionario[i]<-zip24
dictionary$paginas_fisicas_localizador[i]<-"Sin páginas: columna REEDUC.1 del CSVText oficial, alineada por NUMENTRE"
dictionary$respaldo[i]<-"Exportación oficial etiquetada CSVText 2024; 1200 registros alineados"
put(dictionary,"diccionario_covariables_historicas_50.csv")
put(do.call(rbind,dist),"perfil_covariables_historicas_homologadas.csv")
put(do.call(rbind,rawdist),"codigos_covariables_historicas_crudos.csv")
put(do.call(rbind,histcross),"cruces_covariables_historicas.csv")
ht<-do.call(rbind,histtest);ht$p_holm_por_item<-ave(ht$p,paste(ht$anio,ht$variable),FUN=function(z)p.adjust(z,"holm"))
ht$alcance<-"Exploratorio bajo independencia; no comparación causal ni varianza oficial"
put(ht,"pruebas_covariables_historicas.csv")

# Los informes contienen dos listados distintos: plan con cédulas y catálogo UPM.
# Cotejar ambos evita dar por idénticas listas que pueden discrepar.
geo<-geo_codes<-list()
for(y in c(2018,2020)) {
 alltxt<-readLines(file.path(FINAL,"documentacion",paste0("Metodologico_",y,".txt")),warn=FALSE)
 pages<-strsplit(paste(alltxt,collapse="\n"),"\f")[[1]]
 # Secciones bolivianas, no el primer listado de Argentina u otro país.
 txt<-strsplit(paste(pages[if(y==2018)25:55 else 16:55],collapse="\n"),"\n")[[1]]
 b<-grep("6[.] Códigos de Unidad Muestral Primaria",txt)[1]
 end<-grep("^ *7[.]|^ *VII|7[.]1",txt)[grep("^ *7[.]|^ *VII|7[.]1",txt)>b][1]
 if(is.na(end))end<-b+800
 seg<-txt[(b+1):(end-1)]
 rows<-grep("^ *[1-9][0-9]{2} +",seg,value=TRUE)
 code<-as.integer(sub("^ *([0-9]+).*","\\1",rows));keep<-!duplicated(code)
 code<-code[keep];labs<-trimws(sub("^ *[0-9]+ +","",rows[keep]))
 d<-DATA[[as.character(y)]];v<-find_col(d,"COMDIST")
 codes_data<-if(!is.na(v))sort(unique(get_num(d,v))) else numeric()
 nper<-if(!is.na(v))table(get_num(d,v)) else integer()
 for(j in seq_along(code))geo_codes[[length(geo_codes)+1]]<-data.frame(anio=y,codigo_UPM=code[j],etiqueta_documental=labs[j],presente_COMDIST=if(is.na(v))NA else code[j]%in%codes_data,n_microdato=if(as.character(code[j])%in%names(nper))as.integer(nper[as.character(code[j])]) else NA)
 # Cédulas del plan: cinco por punto, a partir de patrones de la tabla 6.4.
 a<-grep("6[.]4 Listado de la muestra",txt)[1];aend<-grep("6[.]5|6[.]6|7[.]1",txt);aend<-aend[aend>a][1]
 plan<-txt[(a+1):(aend-1)]
 ranges<-grep(" +5 +[0-9]+ +- +[0-9]+ +",plan,value=TRUE)
 coords<-regmatches(ranges,regexec(" +5 +([0-9]+) +- +([0-9]+) +",ranges))
 lo<-as.integer(vapply(coords,function(z)z[2],""));hi<-as.integer(vapply(coords,function(z)z[3],""))
 ni<-if(!is.na(v))vapply(split(get_num(d,"CIUDAD"),get_num(d,v)),function(z)length(unique(z)),0L) else integer()
 regok<-if(!is.na(v))all(floor(get_num(d,v)/100)==get_num(d,"REG")-68000) else NA
 geo[[length(geo)+1]]<-data.frame(anio=y,n_microdato=nrow(d),campo_COMDIST=if(is.na(v))"Ausente" else v,n_codigos_catalogo=length(code),n_codigos_base=length(codes_data),
  conjuntos_coinciden=if(is.na(v))NA else setequal(code,codes_data),todos_cinco=if(is.na(v))NA else all(nper==5),cada_codigo_una_ciudad=if(is.na(v))NA else all(ni==1),prefijo_corresponde_REG=regok,
  n_filas_plan=length(ranges),n_cedulas_plan=length(unique(unlist(Map(seq,lo,hi)))),
  alcance=if(is.na(v))"Listado documental cotejado; campo de punto no publicado en este CSV" else "Correspondencia de códigos de punto verificada; no probabilidades por etapa ni estrato urbano/rural reconstruidos")
}
stopifnot(all(vapply(geo,function(z)z$n_codigos_catalogo==240 && z$n_filas_plan==240 && z$n_cedulas_plan==1200,FALSE)))
put(do.call(rbind,geo),"cotejo_unidades_2018_2020.csv")
put(do.call(rbind,geo_codes),"catalogo_UPM_cotejado_2018_2020.csv")

# Sensibilidad por eliminación de bloques: compara cambios de composición y
# especificación para todas las pendientes, no solo sexo y edad.
sens<-diagn<-cells<-list()
ord_extract<-function(fit,y,v,spec,n){
 b<-coef(fit);se<-sqrt(diag(vcov(fit)))[names(b)]
 data.frame(anio=y,variable=v,especificacion=spec,n=n,termino=names(b),beta=unname(b),se=unname(se),OR=exp(unname(b)),ic95_inf=exp(b-1.96*se),ic95_sup=exp(b+1.96*se),row.names=NULL)
}
for(v in rights$variable) {
 md<-ord_data;md$respuesta<-ordered(get_num(DATA[["2023"]],v),levels=c(4,3,2,1))
 cc<-complete.cases(md[,c("respuesta",ord_terms)]);fit<-MASS::polr(ord_formula,data=md[cc,],Hess=TRUE)
 eig<-eigen(fit$Hessian,symmetric=TRUE,only.values=TRUE)$values
 rowdiag<-data.frame(anio=2023,variable=v,n=sum(cc),convergencia=fit$convergence,hessiana_min=min(eig),condicion_hessiana=max(eig)/min(eig),n_parametros=nrow(fit$Hessian),se_finito=all(is.finite(sqrt(diag(vcov(fit))))))
 rowdiag$tipo<-"Ordinal; escala original de parámetros; condición sensible a unidades";diagn[[length(diagn)+1]]<-rowdiag
 for(term in ord_terms) {
  tab<-table(md$respuesta[cc],md[[term]][cc]);if(term=="ideologia")next
  cells[[length(cells)+1]]<-data.frame(anio=2023,variable=v,predictor=term,n_celdas=length(tab),celdas_cero=sum(tab==0),celdas_menor5=sum(tab<5),min_conteo=min(tab))
 }
 for(drop in ord_terms) for(sample in c("mismos_casos","ampliados")) {
  terms<-setdiff(ord_terms,drop);f<-reformulate(terms,"respuesta");use<-if(sample=="mismos_casos")cc else complete.cases(md[,c("respuesta",terms)])
  ft<-MASS::polr(f,data=md[use,],Hess=TRUE)
  sens[[length(sens)+1]]<-ord_extract(ft,2023,v,paste("sin",drop,sample),sum(use))
 }
}
t24<-c("sexo","edad_decadas","educacion","practica","ideologia","clase","ingreso_subjetivo","otros_grupos_rechazados")
fullf<-reformulate(t24,"y");fullfit<-glm(fullf,data=model24[model_complete,],family=binomial())
X<-model.matrix(fullfit);pr<-fitted(fullfit);co<-cooks.distance(fullfit)
diagn[[length(diagn)+1]]<-data.frame(anio=2024,variable="P3NOIJ.3",n=sum(model_complete),convergencia=as.integer(!fullfit$converged),hessiana_min=NA,condicion_hessiana=kappa(crossprod(X,X*as.numeric(pr*(1-pr)))),n_parametros=ncol(X),se_finito=all(is.finite(coef(summary(fullfit))[,2])),tipo="Logística; información observada")
infl<-data.frame(n=sum(model_complete),rango_matriz=qr(X)$rank,columnas=ncol(X),prob_min=min(pr),prob_max=max(pr),max_Cook=max(co),max_leverage=max(hatvalues(fullfit)),n_Cook_mayor_4_n=sum(co>4/length(co)),fraccion_bajo001=mean(pr<.01),fraccion_sobre099=mean(pr>.99))
put(infl,"diagnostico_influencia_logistica_2024.csv")
for(term in c("sexo","educacion","practica","clase","ingreso_subjetivo")){tab<-table(model24$y[model_complete],model24[[term]][model_complete]);cells[[length(cells)+1]]<-data.frame(anio=2024,variable="P3NOIJ.3",predictor=term,n_celdas=length(tab),celdas_cero=sum(tab==0),celdas_menor5=sum(tab<5),min_conteo=min(tab))}
for(drop in t24)for(sample in c("mismos_casos","ampliados")){
 terms<-setdiff(t24,drop);use<-if(sample=="mismos_casos")model_complete else model24$response & complete.cases(model24[,c("y",terms)])
 ft<-glm(reformulate(terms,"y"),data=model24[use,],family=binomial())
 sens[[length(sens)+1]]<-ord_extract(ft,2024,"P3NOIJ.3",paste("sin",drop,sample),sum(use))
}
md<-model24[model_complete,];use<-seq_len(nrow(md))!=which.max(co)
ft<-glm(fullf,data=md[use,],family=binomial())
sens[[length(sens)+1]]<-ord_extract(ft,2024,"P3NOIJ.3","sin_un_caso_maxima_influencia",sum(use))
put(do.call(rbind,sens),"sensibilidad_todas_pendientes_bloques.csv")
put(do.call(rbind,diagn),"diagnosticos_numericos_modelos.csv")
put(do.call(rbind,cells),"celdas_observadas_modelos.csv")
stopifnot(length(dict)==50,length(geo)==2,nrow(do.call(rbind,diagn))==5)
cat("Cotejos terminados: 50 mapeos,",nrow(ht),"contrastes adicionales y",length(sens),"ajustes de sensibilidad.\n")
