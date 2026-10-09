# Diagnóstico ordinal de un factor; no construcción automática de un índice.
# Requiere lavaan. Permite biblioteca propia mediante R_LIBS_USER.
if(!requireNamespace("lavaan",quietly=TRUE))stop("Instalar lavaan desde CRAN")
source("Latinobarometro_historico_Bolivia/analisis_exhaustivo/analisis_exhaustivo.R")
FR<-file.path(ROOT,"cierre_metodologico_2026_10_08","resultados")
put<-function(x,f)write.csv(x,file.path(FR,f),row.names=FALSE,na="",fileEncoding="UTF-8")
d<-as.data.frame(lapply(rights$variable,function(v){x<-get_num(DATA[["2023"]],v);ifelse(x%in%1:4,5-x,NA)}))
names(d)<-c("adopcion","matrimonio","documento","parentalidad")
cc<-complete.cases(d);d<-d[cc,]
stopifnot(nrow(d)==1009)
fit<-lavaan::cfa("factor =~ adopcion + matrimonio + documento + parentalidad",data=d,ordered=names(d),estimator="WLSMV",std.lv=TRUE)
fm<-lavaan::fitMeasures(fit,c("chisq.scaled","df.scaled","pvalue.scaled","cfi.scaled","tli.scaled","rmsea.scaled","rmsea.ci.lower.scaled","rmsea.ci.upper.scaled","srmr"))
put(data.frame(medida=names(fm),valor=as.numeric(fm),n=nrow(d),estimador="WLSMV; ordinal, casos completos, no ajustado al diseño"),"factor_ordinal_2023_ajuste.csv")
put(lavaan::standardizedSolution(fit),"factor_ordinal_2023_parametros.csv")
cor<-lavaan::lavInspect(fit,"sampstat")$cov
res<-lavaan::lavResiduals(fit)$cov
put(data.frame(item=rownames(cor),cor,check.names=FALSE),"correlaciones_policoricas_2023.csv")
put(data.frame(item=rownames(res),res,check.names=FALSE),"residuos_factor_ordinal_2023.csv")
put(data.frame(n=nrow(d),convergencia=lavaan::lavInspect(fit,"converged"),post_check=lavaan::lavInspect(fit,"post.check"),version_lavaan=as.character(packageVersion("lavaan"))),"factor_ordinal_2023_controles.csv")
cat("Diagnóstico factorial ejecutado\n");print(fm)
