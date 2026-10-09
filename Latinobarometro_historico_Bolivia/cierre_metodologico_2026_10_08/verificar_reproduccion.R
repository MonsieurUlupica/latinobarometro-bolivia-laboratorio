# Regeneración en un directorio vacío de salidas, con las mismas entradas locales.
# No equivale a redescargar entradas ni a probar un clon remoto sin documentos.
root<-"Latinobarometro_historico_Bolivia"
close<-file.path(root,"cierre_metodologico_2026_10_08")
fresh<-file.path(close,"reconstruccion_limpia")
if(dir.exists(fresh)) stop("Ya existe la carpeta de prueba; preservar ese resultado o elegir una nueva carpeta")
dir.create(fresh,recursive=TRUE)
status<-system2(file.path(R.home("bin"),"Rscript"),file.path(root,"analisis_exhaustivo/analisis_exhaustivo.R"),
 env=paste0("LB_OUTPUT_DIR=",fresh))
stopifnot(status==0)
ref<-file.path(root,"analisis_exhaustivo/resultados")
files<-list.files(ref,pattern="csv$",full.names=TRUE)
checks<-do.call(rbind,lapply(files,function(f){
 other<-file.path(fresh,"resultados",basename(f))
 data.frame(archivo=basename(f),existe=file.exists(other),
  md5_referencia=unname(tools::md5sum(f)),md5_regenerado=unname(tools::md5sum(other)))
}))
checks$identico<-checks$existe & checks$md5_referencia==checks$md5_regenerado
write.csv(checks,file.path(close,"resultados/reproduccion_csv_directorio_nuevo.csv"),row.names=FALSE)
stopifnot(all(checks$identico))
cat("CSV idénticos:",sum(checks$identico),"/",nrow(checks),"\n")
