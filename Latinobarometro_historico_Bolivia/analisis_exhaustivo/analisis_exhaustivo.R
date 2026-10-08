# Auditoría y análisis exhaustivo de las 23 oleadas bolivianas de Latinobarómetro.
# Ejecutar desde la raíz del proyecto. Las bases originales se leen, nunca se editan.

options(stringsAsFactors = FALSE, scipen = 999)
ROOT <- "Latinobarometro_historico_Bolivia"
if (!dir.exists(ROOT) && dir.exists("../datos_extraidos")) ROOT <- ".."
OUT <- file.path(ROOT, "analisis_exhaustivo")
RES <- file.path(OUT, "resultados")
FIG <- file.path(OUT, "figuras")
dir.create(RES, recursive = TRUE, showWarnings = FALSE)
dir.create(FIG, recursive = TRUE, showWarnings = FALSE)

write_csv <- function(x, name) {
  utils::write.csv(x, file.path(RES, name), row.names = FALSE, na = "", fileEncoding = "UTF-8")
}
find_col <- function(d, v, required = FALSE) {
  i <- match(tolower(v), tolower(names(d)))
  if (is.na(i) && required) stop("No encuentro variable ", v, ".")
  if (is.na(i)) return(NA_character_)
  names(d)[i]
}
as_num <- function(x) suppressWarnings(as.numeric(as.character(x)))
get_num <- function(d, v) {
  nm <- find_col(d, v)
  if (is.na(nm)) return(rep(NA_real_, nrow(d)))
  as_num(d[[nm]])
}
read_wave <- function(year) {
  f <- list.files(file.path(ROOT, "datos_extraidos", as.character(year)),
                  pattern = "\\.csv$", full.names = TRUE)
  if (length(f) != 1L) stop("Se esperaba un CSV para ", year, "; encontrados: ", length(f))
  lines <- readLines(f, encoding = "UTF-8", warn = FALSE)
  lines <- sub("^\\ufeff", "", lines)
  # Elimina solo el separador final que algunas exportaciones agregan a cada fila.
  lines <- sub(";$", "", lines)
  d <- utils::read.csv(text = paste(lines, collapse = "\n"), sep = ";",
                       dec = ".", check.names = FALSE, na.strings = c("", "NA"),
                       stringsAsFactors = FALSE)
  attr(d, "source_file") <- f
  d
}
wilson <- function(k, n, z = 1.959963984540054) {
  if (n <= 0) return(c(NA_real_, NA_real_))
  p <- k / n; den <- 1 + z^2 / n
  mid <- (p + z^2 / (2 * n)) / den
  half <- z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2)) / den
  c(max(0, mid - half), min(1, mid + half))
}
safe_weight <- function(d) {
  nm <- find_col(d, "pondera")
  if (is.na(nm)) nm <- find_col(d, "WT")
  if (is.na(nm)) return(list(name = "", value = rep(1, nrow(d)), documented = FALSE))
  w <- as_num(d[[nm]])
  if (any(!is.finite(w) | w <= 0, na.rm = TRUE) || all(is.na(w))) {
    return(list(name = nm, value = rep(1, nrow(d)), documented = FALSE))
  }
  list(name = nm, value = w, documented = TRUE)
}

YEARS <- sort(as.integer(list.files(file.path(ROOT, "datos_extraidos"), pattern = "^[0-9]{4}$")))
if (length(YEARS) != 23L) stop("El análisis esperaba 23 carpetas de oleadas y encontró ", length(YEARS))
DATA <- setNames(lapply(YEARS, read_wave), YEARS)
INV <- utils::read.csv(file.path(ROOT, "inventario_archivos.csv"), check.names = FALSE)

# Inventario de todos los campos y control de integridad de cada oleada.
var_rows <- list(); wave_rows <- list(); special_rows <- list(); iddup_rows <- list()
special_candidates <- c(-9:-1, 0, 8, 9, 96, 97, 98, 99, 999, 9999)
for (y in YEARS) {
  d <- DATA[[as.character(y)]]; rawfile <- attr(d, "source_file")
  inv_row <- INV[INV$anio == y, , drop = FALSE]
  idname <- find_col(d, "NUMENTRE")
  if (is.na(idname)) idname <- find_col(d, "NUMINVES")
  country_name <- find_col(d,"IDENPA")
  country_codes <- if(!is.na(country_name)) paste(sort(unique(as.character(d[[country_name]]))),collapse=" | ") else ""
  iddup <- if (is.na(idname)) NA_integer_ else sum(duplicated(d[[idname]]) | duplicated(d[[idname]], fromLast = TRUE))
  if (!is.na(idname) && iddup>0) {
    dup_idx<-which(duplicated(d[[idname]]) | duplicated(d[[idname]],fromLast=TRUE))
    context_names<-vapply(c("REG","CIUDAD","COMDIST","SEXO","EDAD","S7"),function(v)find_col(d,v),"")
    context_names<-context_names[nzchar(context_names)]
    context_values<-sapply(context_names,function(v)as.character(d[[v]][dup_idx]),simplify=TRUE)
    if(is.null(dim(context_values))) context_values<-matrix(context_values,ncol=length(context_names))
    context_string<-apply(context_values,1,function(r)paste(paste0(context_names,"=",r),collapse=" | "))
    iddup_rows[[length(iddup_rows)+1L]]<-data.frame(anio=y,fila_microdato=dup_idx,variable_id=idname,
      valor_id=as.character(d[[idname]][dup_idx]),contexto=context_string,
      duplicado_fila_completa=duplicated(d[dup_idx,,drop=FALSE]) | duplicated(d[dup_idx,,drop=FALSE],fromLast=TRUE),
      stringsAsFactors=FALSE)
  }
  exactdup <- sum(duplicated(d))
  w <- safe_weight(d); wv <- w$value[is.finite(w$value)]
  design_vars <- intersect(tolower(names(d)), c("reg", "px04", "region", "comdist", "psu", "estrato", "cluster"))
  wave_rows[[length(wave_rows) + 1L]] <- data.frame(
    anio = y, archivo = basename(rawfile), filas_leidas = nrow(d), columnas_leidas = ncol(d),
    filas_inventario = if (nrow(inv_row)) inv_row$n_registros[1] else NA,
    columnas_inventario = if (nrow(inv_row)) inv_row$n_variables[1] else NA,
    filas_coinciden = if (nrow(inv_row)) nrow(d) == inv_row$n_registros[1] else NA,
    columnas_coinciden = if (nrow(inv_row)) ncol(d) == inv_row$n_variables[1] else NA,
    variable_id_candidata = ifelse(is.na(idname), "", idname),
    variable_pais = ifelse(is.na(country_name),"",country_name), codigos_pais = country_codes,
    filas_en_id_duplicado = iddup, filas_duplicadas_exactas = exactdup,
    ponderador_candidato = w$name, ponderador_no_constante = if (length(wv)) length(unique(wv)) > 1 else FALSE,
    ponderador_min = if (length(wv)) min(wv) else NA_real_, ponderador_max = if (length(wv)) max(wv) else NA_real_,
    ponderador_n_unicos = if (length(wv)) length(unique(wv)) else 0L,
    campos_diseno_posibles = paste(design_vars, collapse = " | "),
    stringsAsFactors = FALSE
  )
  for (nm in names(d)) {
    x <- d[[nm]]; xn <- as_num(x); numeric_like <- sum(!is.na(x)) == sum(!is.na(xn))
    var_rows[[length(var_rows) + 1L]] <- data.frame(
      anio = y, variable = nm, clase_importada = paste(class(x), collapse = "/"),
      numeric_like = numeric_like, n_total = length(x), n_missing = sum(is.na(x)),
      pct_missing = 100 * mean(is.na(x)), n_unicos_observados = length(unique(x[!is.na(x)])),
      minimo = if (numeric_like && any(!is.na(xn))) min(xn, na.rm = TRUE) else NA_real_,
      maximo = if (numeric_like && any(!is.na(xn))) max(xn, na.rm = TRUE) else NA_real_,
      stringsAsFactors = FALSE
    )
    if (numeric_like) {
      tt <- table(xn, useNA = "no")
      vals <- suppressWarnings(as.numeric(names(tt)))
      keep <- vals %in% special_candidates
      if (any(keep)) special_rows[[length(special_rows) + 1L]] <- data.frame(
        anio = y, variable = nm, valor = vals[keep], n = as.integer(tt[keep]),
        pct_muestra = 100 * as.integer(tt[keep]) / nrow(d),
        marca = "código candidato; no equivale automáticamente a no respuesta",
        stringsAsFactors = FALSE
      )
    }
  }
}
wave_audit <- do.call(rbind, wave_rows)
var_inventory <- do.call(rbind, var_rows)
special_codes <- if (length(special_rows)) do.call(rbind, special_rows) else data.frame()
official_n <- c(`1996`=772,`1997`=796,`1998`=794,`2000`=1000,`2001`=1080,`2002`=1242,
                `2003`=1200,`2004`=1201,`2005`=1200,`2006`=1200,`2007`=1200,`2008`=1200,
                `2009`=1200,`2010`=1200,`2011`=1200,`2013`=1200,`2015`=1200,`2016`=1200,
                `2017`=1200,`2018`=1200,`2020`=1200,`2023`=1200,`2024`=1200)
wave_audit$n_oficial_documentado <- unname(official_n[as.character(wave_audit$anio)])
wave_audit$diferencia_microdato_menos_n_oficial <- wave_audit$filas_leidas-wave_audit$n_oficial_documentado
wave_audit$coincide_n_oficial <- wave_audit$filas_leidas==wave_audit$n_oficial_documentado
wave_audit$fuente_n_oficial <- rep("Documentación oficial de la oleada", nrow(wave_audit))
wave_audit$fuente_n_oficial[wave_audit$anio <= 2015] <- "Ficha técnica consolidada 1995–2015, fila Bolivia"
wave_audit$fuente_n_oficial[wave_audit$anio == 2000] <- "Ficha técnica 2000, Bolivia, p. 1"
wave_audit$fuente_n_oficial[wave_audit$anio == 2001] <- "Ficha técnica 2001, Bolivia, p. 1"
wave_audit$fuente_n_oficial[wave_audit$anio == 2023] <- "Fichero nacional oficial v2023.1; tamaño del microdato"
wave_audit$fuente_n_oficial[wave_audit$anio == 2024] <- "Ficha técnica 2024, Bolivia"
write_csv(wave_audit, "auditoria_oleadas.csv")
write_csv(wave_audit[,c("anio","filas_leidas","n_oficial_documentado","diferencia_microdato_menos_n_oficial","coincide_n_oficial","fuente_n_oficial")],"auditoria_n_microdato_vs_documentacion.csv")
write_csv(if(length(iddup_rows))do.call(rbind,iddup_rows) else data.frame(),"auditoria_ids_duplicados.csv")
write_csv(var_inventory, "inventario_variables_todas_oleadas.csv")
write_csv(special_codes, "codigos_candidatos_especiales.csv")

# Inventario documental local por año; la matriz distingue documento encontrado
# de verificación sustantiva de la pregunta.
docfiles <- list.files(file.path(ROOT, "documentacion"), full.names = TRUE)
doc_matrix <- do.call(rbind, lapply(YEARS, function(y) {
  these <- docfiles[grepl(as.character(y), basename(docfiles), fixed = TRUE)]
  q <- these[grepl("cuestionario|questionnaire", basename(these), ignore.case = TRUE)]
  cb <- these[grepl("libro.*c[oó]digo|codebook", basename(these), ignore.case = TRUE)]
  data.frame(anio = y, cuestionario_local = paste(basename(q), collapse = " | "),
             cuestionario_disponible = length(q) > 0,
             libro_codigos_local = paste(basename(cb), collapse = " | "),
             libro_codigos_disponible = length(cb) > 0,
             nota = if (y == 2015) "Cuestionario y codebook oficial consultados en línea; no están archivados en la carpeta local." else
               if (y == 2024) "El PDF local de resultados por país complementa el cuestionario." else "Inventario automático de archivos locales; revisar lista para materiales con nombres no anuales.",
             stringsAsFactors = FALSE)
}))
write_csv(doc_matrix, "matriz_documentacion_local.csv")

# Diccionario de mediciones directas. Las categorías no declaradas válidas se
# conservan en la distribución cruda y se excluyen solo del denominador analítico.
items <- data.frame(
  anio = c(1998,2002,2004,2006,2008,2008,2010,2015,2023,2023,2023,2023,2024),
  variable = c("NP63A","P52WVSC","P38STA","P46STM","P64WVSST","P68ST","P14N.G","P69ST.C",
               "P37CSN.A","P37CSN.B","P37CSN.F","P37WVSCS.H","P3NOIJ.3"),
  constructo = c("distancia_social","justificacion_moral","justificacion_moral","saliencia_discriminacion",
                 "justificacion_moral","saliencia_discriminacion","matrimonio","matrimonio",
                 "derechos_2023","derechos_2023","derechos_2023","derechos_2023","distancia_social"),
  enunciado = c("Menciona homosexuales entre vecinos no deseados",
                "Qué tan justificable es la homosexualidad",
                "Qué tan justificable es la homosexualidad",
                "Razones por las cuales no se trata a todos por igual",
                "Qué tan justificable es la homosexualidad",
                "Personas más discriminadas",
                "Grado de acuerdo con matrimonio entre personas del mismo sexo",
                "Grado de acuerdo con matrimonio entre personas del mismo sexo",
                "Acuerdo con adopción por parejas del mismo sexo",
                "Acuerdo con matrimonio entre personas del mismo sexo",
                "Acuerdo con reconocimiento del cambio de género en el documento de identidad",
                "Acuerdo con que las parejas homosexuales son tan buenos padres como otras parejas",
                "Menciona homosexuales entre vecinos no deseados"),
  codigos_sustantivos = c("0–1","1–10","1–10","1–15","1–10","1–20; 96; 97","1–4","1–4",
                          "1–4","1–4","1–4","1–4","0–1; con P3NOIJ.9=0"),
  codigo_objetivo = c("1","ninguno; escala ordinal","ninguno; escala ordinal","7","ninguno; escala ordinal","13","1–2","1–2",
                      "1–2","1–2","1–2","1–2","1"),
  fuente_local = c("Cuestionario_1998_ES.pdf, NP63A.Homosexuales; Libro_codigos_1998_ES.pdf",
                   "Libro_codigos_2002_ES.pdf, P52WVSC (pág. impresa 49)",
                   "Libro_codigos_2004_ES.pdf, P38STA (pág. impresa 29)",
                   "Libro_codigos_2006_ES.pdf, P46STM (pág. impresa 23)",
                   "Libro_codigos_2008_ES.pdf, P64WVSST (pág. impresa 41)",
                   "Libro_codigos_2008_ES.pdf, anexo PA505201 (pág. impresa 75)",
                   "Libro_codigos_2010_ES.pdf, P14N.G; Cuestionario_2010_ES.pdf",
                   "Libro de códigos oficial 2015, P69ST.C (pág. impresa 29), fuente oficial en línea",
                   "Libro_codigos_2023_ES.pdf, P37CSN.A (pág. impresa 156)",
                   "Libro_codigos_2023_ES.pdf, P37CSN.B (pág. impresa 157)",
                   "Libro_codigos_2023_ES.pdf, P37CSN.F (pág. impresa 161)",
                   "Libro_codigos_2023_ES.pdf, P37WVSCS.H (pág. impresa 163)",
                   "latinobarometro-2024-cuestionario-esp.pdf, P3NOIJ; resultados por país"),
  regla_no_respuesta = c("Sin código especial documentado en el ítem; conservar 0 y 1",
                         "-1 No sabe; -2 No contesta; -4 No preguntada; -5 Otras respuestas",
                         "-1 No sabe; -2 No contesta; -4 No preguntada; -5 Otras respuestas",
                         "-1 No sabe; -2 No contesta; -4 No preguntada",
                         "-1 No sabe; -2 No contesta; -4 No preguntada; -5 Otras respuestas",
                         "-1 No sabe; -2 No contesta; -4 No preguntada; 96 Otras; 97 Ningún grupo",
                         "-1 No sabe; -2 No contesta; -3 No aplicable; -4 No preguntada",
                         "-1 NS/NR; -3 No aplicable; -4 No preguntada",
                         "El cuestionario/codebook indican 0 NS/NR; el microdato usa -5 en vez de 0",
                         "El cuestionario/codebook indican 0 NS/NR; el microdato usa -5 en vez de 0",
                         "El cuestionario/codebook indican 0 NS/NR; el microdato usa -5 en vez de 0",
                         "El cuestionario/codebook indican 0 NS/NR; el microdato usa -5 en vez de 0",
                         "P3NOIJ.9=1 indica NS/NR; variable .3 codifica mención 0/1"),
  comparabilidad = c("No equiparar automáticamente con batería 2024; cambia batería/contexto",
                     "Serie común 2002/2004/2008; escala y extremos documentados iguales",
                     "Serie común 2002/2004/2008; escala y extremos documentados iguales",
                     "Mención única; saliencia percibida, no experiencia vivida",
                     "Serie común 2002/2004/2008; escala y extremos documentados iguales",
                     "Mención única; categorías de percepción pública",
                     "Mismo ámbito y escala que 2015/2023; redacción de 2010 dice ‘matrimonio entre homosexuales’, no idéntica",
                     "Mismo ámbito y escala que 2023; la redacción de 2010 difiere; documentación 2015 consultada en línea",
                     "Batería 2023; comparar dentro de personas solo con pares observados",
                     "Batería 2023 y medición repetida de matrimonio",
                     "Ámbito de identidad documental; no sinónimo de orientación sexual",
                     "Ámbito de parentalidad; no equivale a adopción",
                     "Medida de distancia social en batería múltiple; no fusionar con 1998 sin cautela"),
  stringsAsFactors = FALSE
)
write_csv(items, "diccionario_mediciones_directas.csv")

valid_codes <- function(item, x, d) {
  y <- item$anio; v <- item$variable; x <- as_num(x)
  if (y == 1998 && v == "NP63A") return(x %in% c(0,1))
  if (y %in% c(2002,2004,2008) && item$constructo == "justificacion_moral") return(x %in% 1:10)
  if (y == 2006) return(x %in% 1:15)
  if (y == 2008 && v == "P68ST") return(x %in% c(1:20,96,97))
  if (y %in% c(2010,2015,2023) && item$constructo %in% c("matrimonio","derechos_2023")) return(x %in% 1:4)
  if (y == 2024 && v == "P3NOIJ.3") return(x %in% c(0,1) & get_num(d,"P3NOIJ.9") == 0)
  rep(FALSE, length(x))
}
target_codes <- function(item) {
  if (item$constructo == "distancia_social") return(1)
  if (item$constructo == "saliencia_discriminacion") return(if (item$anio == 2006) 7 else 13)
  if (item$constructo %in% c("matrimonio","derechos_2023")) return(c(1,2))
  integer(0)
}
code_labels <- function(item, code) {
  y <- item$anio; v <- item$variable; z <- as.character(code)
  if (y == 1998 || y == 2024) return(ifelse(z == "1", "Mención", "No mención"))
  if (y == 2006) {
    lab <- c("1"="Joven","2"="Viejo","3"="Mujer","4"="Hombre","5"="Color de piel/raza",
             "6"="Inmigrante/extranjero","7"="Homosexual","8"="Religión","9"="Pobre",
             "10"="Discapacidad","11"="Educación","12"="Contactos","13"="No ser nadie",
             "14"="Se trata a todos por igual","15"="No se siente discriminado")
    return(unname(lab[z]))
  }
  if (y == 2008 && v == "P68ST") {
    lab <- c("1"="Negros","2"="Indígenas","3"="Blancos","4"="Mulatos","5"="Mestizos",
             "6"="Asiáticos","7"="Árabes","8"="Judíos","9"="Pobres","10"="Inmigrantes",
             "11"="Discapacitados","12"="Enfermos de Sida","13"="Homosexuales","14"="Mujeres",
             "15"="Viejos","16"="Jóvenes","17"="Analfabetos","18"="Grupos religiosos",
             "19"="Partidos políticos","20"="Grupos de interés","96"="Otras","97"="Ningún grupo")
    return(unname(lab[z]))
  }
  if (item$constructo == "justificacion_moral") return(ifelse(code == 1,"Nunca se justifica", ifelse(code == 10,"Siempre se justifica", as.character(code))))
  if (item$constructo %in% c("matrimonio","derechos_2023")) {
    lab <- c("1"="Muy de acuerdo","2"="De acuerdo","3"="En desacuerdo","4"="Muy en desacuerdo")
    return(unname(lab[z]))
  }
  as.character(code)
}

# Distribuciones completas, denominadores, no respuesta y sensibilidad SRS.
dist_rows <- list(); outcome_rows <- list(); nonresponse_rows <- list()
item_data <- list()
for (i in seq_len(nrow(items))) {
  it <- items[i, , drop = FALSE]; d <- DATA[[as.character(it$anio)]]
  actual_var <- find_col(d, it$variable)
  if (is.na(actual_var)) stop("Falta ítem directo ", it$variable, " en ", it$anio)
  x <- as_num(d[[actual_var]]); valid <- valid_codes(it, x, d)
  wt <- safe_weight(d); w <- wt$value
  raw <- sort(unique(x[!is.na(x)]))
  for (code in raw) {
    ncode <- sum(x == code, na.rm = TRUE)
    ncode_valid <- sum(valid & x == code, na.rm = TRUE)
    denom <- sum(valid)
    code_ci <- if(any(valid & x==code,na.rm=TRUE)) wilson(ncode_valid,denom) else c(NA_real_,NA_real_)
    w_total <- sum(w, na.rm=TRUE); w_code <- sum(w[x == code], na.rm=TRUE)
    w_valid <- sum(w[valid], na.rm=TRUE); w_vcode <- sum(w[valid & x == code], na.rm=TRUE)
    dist_rows[[length(dist_rows)+1L]] <- data.frame(
      anio=it$anio, variable=actual_var, constructo=it$constructo, codigo=code,
      etiqueta=code_labels(it,code), n=ncode, pct_total=100*ncode/nrow(d),
      n_en_denominador=ncode_valid, denominador_sustantivo=denom,
      pct_sobre_denominador=ifelse(ncode_valid>0,100*ncode_valid/denom,NA_real_),
      ic95_srs_sens_inf=100*code_ci[1],ic95_srs_sens_sup=100*code_ci[2],
      pct_ponderado_total=100*w_code/w_total,
      pct_ponderado_sustantivo=ifelse(any(valid & x==code),100*w_vcode/w_valid,NA_real_),
      stringsAsFactors=FALSE
    )
  }
  n <- sum(valid); target <- target_codes(it); has_target <- length(target)>0L
  k <- if(has_target) sum(valid & x %in% target) else NA_integer_
  pct <- if (has_target && n) 100*k/n else NA_real_
  ci <- if(has_target) wilson(k,n) else c(NA_real_,NA_real_)
  nmiss <- nrow(d)-n; raw_special <- sort(unique(x[!valid & !is.na(x)]))
  outcome_rows[[length(outcome_rows)+1L]] <- data.frame(
    anio=it$anio, variable=actual_var, constructo=it$constructo, enunciado=it$enunciado,
    n_total=nrow(d), n_valido=n, n_no_valido=nmiss, pct_no_valido=100*nmiss/nrow(d),
    conteo_objetivo=k, pct_objetivo_valido=pct,
    pct_objetivo_total=if(has_target) 100*k/nrow(d) else NA_real_,
    pct_objetivo_ponderado=if (has_target && sum(w[valid])>0) 100*sum(w[valid & x %in% target])/sum(w[valid]) else NA_real_,
    ic95_srs_sens_inf=100*ci[1], ic95_srs_sens_sup=100*ci[2],
    ponderador=wt$name, ponderador_varia=if (length(unique(w))>1) TRUE else FALSE,
    codigos_no_validos= paste(raw_special,collapse=" | "),
    stringsAsFactors=FALSE
  )
  nmiss <- nrow(d)-n
  ordinal_item <- it$constructo=="justificacion_moral"
  mean_valid <- if(ordinal_item && n) mean(x[valid]) else NA_real_
  mean_valid_w <- if(ordinal_item && sum(w[valid])>0) weighted.mean(x[valid],w[valid]) else NA_real_
  mean_low <- if(ordinal_item && nrow(d)>0) (sum(x[valid])+nmiss*1)/nrow(d) else NA_real_
  mean_high <- if(ordinal_item && nrow(d)>0) (sum(x[valid])+nmiss*10)/nrow(d) else NA_real_
  mean_low_w <- if(ordinal_item && sum(w)>0) (sum(x[valid]*w[valid])+sum(w[!valid],na.rm=TRUE)*1)/sum(w,na.rm=TRUE) else NA_real_
  mean_high_w <- if(ordinal_item && sum(w)>0) (sum(x[valid]*w[valid])+sum(w[!valid],na.rm=TRUE)*10)/sum(w,na.rm=TRUE) else NA_real_
  nr <- data.frame(anio=it$anio, variable=actual_var, constructo=it$constructo,
                   n_total=nrow(d), n_respuesta_sustantiva=n, n_no_respuesta=nmiss,
                   pct_no_respuesta=100*nmiss/nrow(d),
                   limite_inferior_objetivo_sobre_total=if(has_target)100*k/nrow(d) else NA_real_,
                   limite_superior_objetivo_si_toda_no_respuesta_fuera_objetivo=if(has_target)100*(k+nmiss)/nrow(d) else NA_real_,
                   media_ordinal_valida=mean_valid,media_ordinal_si_NR_1=mean_low,media_ordinal_si_NR_10=mean_high,
                   media_ordinal_ponderada_valida=mean_valid_w,media_ordinal_ponderada_si_NR_1=mean_low_w,
                   media_ordinal_ponderada_si_NR_10=mean_high_w,
                   stringsAsFactors=FALSE)
  nonresponse_rows[[length(nonresponse_rows)+1L]] <- nr
  item_data[[paste(it$anio,actual_var,sep="_")]] <- list(item=it,data=d,x=x,valid=valid,weight=w)
}
outcome_dist <- do.call(rbind,dist_rows)
outcome_summary <- do.call(rbind,outcome_rows)
nonresponse <- do.call(rbind,nonresponse_rows)
write_csv(outcome_dist,"distribucion_completa_respuestas.csv")
write_csv(outcome_summary,"resumen_indicadores_directos.csv")
write_csv(nonresponse,"no_respuesta_y_limites_extremos.csv")

# Cobertura constructo x oleada y perfiles de muestra.
constructs <- c("distancia_social","justificacion_moral","saliencia_discriminacion","matrimonio","derechos_2023")
coverage <- do.call(rbind,lapply(YEARS,function(y) {
  present <- items$anio==y
  data.frame(anio=y, tiene_medicion_directa=any(present),
             mediciones=paste(items$variable[present],collapse=" | "),
             constructos=paste(unique(items$constructo[present]),collapse=" | "),
             interpretacion=if(any(present)) "Medición directa; respetar familia y comparabilidad" else "Solo contexto general; no mide opinión LGBTIQ+",
             stringsAsFactors=FALSE)
}))
write_csv(coverage,"matriz_cobertura_constructos.csv")

profile_rows <- list()
for (y in YEARS) {
  d <- DATA[[as.character(y)]]
  age_nm <- find_col(d,"EDAD"); if (is.na(age_nm)) age_nm <- find_col(d,"REEDAD")
  sex_nm <- find_col(d,"SEXO"); if (is.na(sex_nm)) sex_nm <- find_col(d,"S12")
  if (is.na(sex_nm) && y <= 2004) sex_nm <- find_col(d,"S1")
  age <- if (!is.na(age_nm)) as_num(d[[age_nm]]) else rep(NA_real_,nrow(d))
  age <- age[is.finite(age) & age >= 15 & age <= 110]
  sex <- if (!is.na(sex_nm)) as_num(d[[sex_nm]]) else numeric()
  profile_rows[[length(profile_rows)+1L]] <- data.frame(
    anio=y,n=nrow(d),variable_edad=ifelse(is.na(age_nm),"",age_nm),
    edad_min_observada=if(length(age)) min(age) else NA_real_,
    edad_mediana=if(length(age)) median(age) else NA_real_,
    edad_max_observada=if(length(age)) max(age) else NA_real_,
    variable_sexo_candidata=ifelse(is.na(sex_nm),"",sex_nm),
    codigo_sexo_1_n=if(length(sex)) sum(sex==1,na.rm=TRUE) else NA_integer_,
    codigo_sexo_2_n=if(length(sex)) sum(sex==2,na.rm=TRUE) else NA_integer_,
    nota="Perfil mecánico de campos candidatos; no homologar sin revisar cuestionario/codebook.",
    stringsAsFactors=FALSE
  )
}
write_csv(do.call(rbind,profile_rows),"perfil_muestra_23_oleadas.csv")

# Contrastes repetidos, dentro de los límites del diseño.
marriage_series_rows <- list(); just_series_rows <- list()
for (construct in c("matrimonio","justificacion_moral")) {
  if (construct=="matrimonio") subitems <- items[items$constructo=="matrimonio" | (items$anio==2023 & items$variable=="P37CSN.B"),]
  else subitems <- items[items$constructo==construct,]
  for (i in seq_len(nrow(subitems))) {
    it <- subitems[i,]; key <- paste(it$anio,find_col(DATA[[as.character(it$anio)]],it$variable),sep="_")
    a <- item_data[[key]]; x <- a$x; ok <- a$valid
    if (construct=="justificacion_moral") {
      ww <- a$weight
      just_series_rows[[length(just_series_rows)+1L]] <- data.frame(
        anio=it$anio,n_valido=sum(ok),media=mean(x[ok]),mediana=median(x[ok]),
        pct_1a4=100*mean(x[ok]<=4),pct_5=100*mean(x[ok]==5),pct_6a10=100*mean(x[ok]>=6),
        media_ponderada=weighted.mean(x[ok],ww[ok]),pct_1a4_ponderado=100*sum(ww[ok & x<=4])/sum(ww[ok]),
        pct_5_ponderado=100*sum(ww[ok & x==5])/sum(ww[ok]),pct_6a10_ponderado=100*sum(ww[ok & x>=6])/sum(ww[ok]),
        kish_n=sum(ww[ok])^2/sum(ww[ok]^2),stringsAsFactors=FALSE)
    } else {
      k<-sum(ok & x %in% c(1,2)); n<-sum(ok); ci<-wilson(k,n)
      marriage_series_rows[[length(marriage_series_rows)+1L]] <- data.frame(
        anio=it$anio,n_valido=n,acuerdo_n=k,acuerdo_pct=100*k/n,desacuerdo_n=sum(ok & x %in% c(3,4)),
        pct_1=100*mean(x[ok]==1),pct_2=100*mean(x[ok]==2),pct_3=100*mean(x[ok]==3),pct_4=100*mean(x[ok]==4),
        acuerdo_pct_ponderado=100*sum(a$weight[ok & x %in% c(1,2)])/sum(a$weight[ok]),
        ic95_srs_sens_inf=100*ci[1],ic95_srs_sens_sup=100*ci[2],stringsAsFactors=FALSE)
    }
  }
}
write_csv(do.call(rbind,just_series_rows),"serie_justificacion_2002_2008.csv")
write_csv(do.call(rbind,marriage_series_rows),"serie_matrimonio_2010_2023.csv")

# Pruebas ordinales como sensibilidad SRS exploratoria, no como inferencia del diseño.
just_data <- lapply(c(2002,2004,2008),function(y){it<-items[items$anio==y & items$constructo=="justificacion_moral",];a<-item_data[[paste(y,find_col(DATA[[as.character(y)]],it$variable),sep="_")]];a$x[a$valid]})
names(just_data)<-c("2002","2004","2008")
kw<-stats::kruskal.test(just_data)
just_pairs<-combn(names(just_data),2,simplify=FALSE)
just_test<-do.call(rbind,lapply(just_pairs,function(p){
  a<-just_data[[p[1]]];b<-just_data[[p[2]]]; wt<-stats::wilcox.test(a,b,exact=FALSE,correct=FALSE)
  data.frame(anio_a=p[1],n_a=length(a),mediana_a=median(a),anio_b=p[2],n_b=length(b),mediana_b=median(b),
             diferencia_medias=mean(a)-mean(b),wilcoxon_p_srs=wt$p.value,stringsAsFactors=FALSE)
}))
just_test$p_holm<-p.adjust(just_test$wilcoxon_p_srs,method="holm")
write_csv(data.frame(prueba="Kruskal-Wallis SRS aproximada",n_total=sum(vapply(just_data,length,1L)),
                     estadistico=unname(kw$statistic),gl=unname(kw$parameter),p_srs=kw$p.value,
                     alcance="Contraste exploratorio entre cortes; no incorpora estratos/conglomerados/cuotas."),
          "pruebas_serie_justificacion_sensibilidad.csv")
write_csv(just_test,"comparaciones_pareadas_no_mismas_personas_justificacion.csv")

marriage <- do.call(rbind,lapply(c(2010,2015,2023),function(y){it<-if(y==2023)items[items$anio==2023 & items$variable=="P37CSN.B",] else items[items$anio==y & items$constructo=="matrimonio",];a<-item_data[[paste(y,find_col(DATA[[as.character(y)]],it$variable),sep="_")]];x<-a$x;ok<-a$valid;data.frame(year=y,x=x[ok])}))
mar_pair<-combn(c(2010,2015,2023),2,simplify=FALSE)
mar_test<-do.call(rbind,lapply(mar_pair,function(p){a<-marriage$x[marriage$year==p[1]];b<-marriage$x[marriage$year==p[2]];pa<-mean(a<=2);pb<-mean(b<=2);se<-sqrt(pa*(1-pa)/length(a)+pb*(1-pb)/length(b));z<-(pa-pb)/se;data.frame(anio_a=p[1],n_a=length(a),apoyo_a_pct=100*pa,anio_b=p[2],n_b=length(b),apoyo_b_pct=100*pb,diferencia_pp=100*(pa-pb),ic95_srs_sens_inf=100*(pa-pb-1.96*se),ic95_srs_sens_sup=100*(pa-pb+1.96*se),p_srs=2*pnorm(-abs(z)))}))
mar_test$p_holm<-p.adjust(mar_test$p_srs,method="holm")
write_csv(mar_test,"comparaciones_matrimonio_sensibilidad_srs.csv")

# Perfiles conjuntos y comparaciones pareadas de las cuatro preguntas 2023.
rights <- items[items$anio==2023 & items$constructo=="derechos_2023",]
rights_x <- sapply(rights$variable,function(v)get_num(DATA[["2023"]],v))
colnames(rights_x)<-rights$variable
complete_rights<-complete.cases(rights_x) & apply(rights_x,1,function(r)all(r%in%1:4))
support_matrix<-rights_x<=2
profile_binary<-paste0("ABFH_",apply(ifelse(support_matrix[complete_rights,,drop=FALSE],1,0),1,paste0,collapse=""))
profile_counts<-as.data.frame(table(profile_binary),stringsAsFactors=FALSE)
names(profile_counts)<-c("perfil_acuerdo_A_B_F_H", "n")
profile_counts$pct_complete_cases<-100*profile_counts$n/sum(profile_counts$n)
profile_counts$n_complete_cases<-sum(complete_rights)
profile_counts$interpretacion<-"Orden de columnas A adopción, B matrimonio, F reconocimiento documental, H parentalidad; 1 acuerdo, 0 desacuerdo"
write_csv(profile_counts,"perfiles_conjuntos_derechos_2023.csv")

pair_rows<-list(); pair_stats<-list(); pair_index<-combn(seq_len(ncol(rights_x)),2,simplify=FALSE)
for (ij in pair_index) {
  a<-rights_x[,ij[1]];b<-rights_x[,ij[2]];ok<-a%in%1:4 & b%in%1:4
  sa<-a[ok]<=2;sb<-b[ok]<=2;tab<-table(factor(sa,levels=c(FALSE,TRUE)),factor(sb,levels=c(FALSE,TRUE)))
  disc_a<-sum(sa & !sb);disc_b<-sum(!sa & sb);mm<-stats::mcnemar.test(tab,correct=TRUE)
  wx<-stats::wilcox.test(a[ok],b[ok],paired=TRUE,exact=FALSE,correct=FALSE)
  nm_a<-rights$variable[ij[1]];nm_b<-rights$variable[ij[2]]
  pair_rows[[length(pair_rows)+1L]]<-data.frame(variable_a=nm_a,variable_b=nm_b,
    n_pares=sum(ok),acuerdo_a_no_b=disc_a,acuerdo_b_no_a=disc_b,
    diferencia_acuerdo_pp=100*(mean(sa)-mean(sb)),mcnemar_p_srs=mm$p.value,
    diferencia_mediana_ordinal=median(a[ok])-median(b[ok]),wilcoxon_p_srs=wx$p.value,
    stringsAsFactors=FALSE)
}
rights_pairs<-do.call(rbind,pair_rows)
rights_pairs$p_holm_mcnemar<-p.adjust(rights_pairs$mcnemar_p_srs,method="holm")
rights_pairs$p_holm_wilcoxon<-p.adjust(rights_pairs$wilcoxon_p_srs,method="holm")
write_csv(rights_pairs,"comparaciones_pareadas_derechos_2023.csv")

rights_corr <- suppressWarnings(cor(rights_x[complete_rights,,drop=FALSE], method="spearman"))
rights_eig <- eigen(rights_corr, symmetric=TRUE)$values
rights_alpha <- 4/3*(1-sum(diag(cov(rights_x[complete_rights,,drop=FALSE],use="complete.obs")))/sum(cov(rights_x[complete_rights,,drop=FALSE],use="complete.obs")))
right_dim<-data.frame(n_complete=sum(complete_rights),alpha_cronbach_exploratorio=rights_alpha,
  eigen_1=rights_eig[1],eigen_2=rights_eig[2],varianza_componente_1_pct=100*rights_eig[1]/sum(rights_eig),
  interpretacion="Diagnóstico exploratorio sobre correlaciones/varianzas de ítems ordinales codificados 1–4; no sustituye CFA ordinal. No se calcula ni recomienda puntaje por defecto.")
write_csv(as.data.frame(as.table(rights_corr),stringsAsFactors=FALSE),"correlaciones_spearman_derechos_2023.csv")
write_csv(right_dim,"diagnostico_dimension_comun_2023.csv")

# Cruces guía. En todas las olas con resultados directos, sexo/edad solo se
# incluyen cuando hay un campo documentado; en 2023/24 se agregan covariables
# armonizables desde cuestionario/codebook.
covmap <- list(
  `1998`=c(sexo="S1",edad="S2"), `2002`=c(sexo="S1",edad="S2"),
  `2004`=c(sexo="S1",edad="S2"), `2006`=c(sexo="SEXO",edad="S7"),
  `2008`=c(sexo="S8",edad="S9"), `2010`=c(sexo="SEXO",edad="EDAD"),
  `2015`=c(sexo="S12",edad="S13"), `2023`=c(sexo="SEXO",edad="EDAD"),
  `2024`=c(sexo="SEXO",edad="EDAD")
)
extended23 <- c(sexo="SEXO",edad="EDAD",educacion="REEEDUC.1",ideologia="P16ST",religion="S1",practica="S1A",ingreso_subjetivo="S5",clase="S2",territorio="REG")
extended24 <- c(sexo="SEXO",edad="EDAD",educacion="REEDUC.1",ideologia="P16ST",religion="S1",practica="S1A",ingreso_subjetivo="S5",clase="S2",territorio="REG")

# Trazabilidad de predictores incluidos en cruces. La presencia de una variable
# no implica comparabilidad automática entre años.
covariate_rows <- list()
for (yr in names(covmap)) {
  m <- covmap[[yr]]
  for (pn in names(m)) covariate_rows[[length(covariate_rows)+1L]] <- data.frame(
    anio=as.integer(yr),predictor=pn,variable_microdato=unname(m[[pn]]),
    regla_analitica=if(pn=="sexo") "1=hombre, 2=mujer; otros códigos excluidos" else if(pn=="edad") "Edad exacta agrupada en bandas o categorías documentadas; ver código fuente" else "Sin recodificación adicional en cruces guía",
    stringsAsFactors=FALSE)
}
for (yr in c("2023","2024")) {
  m <- if(yr=="2023") extended23 else extended24
  for (pn in names(m)) if(nzchar(m[[pn]])) covariate_rows[[length(covariate_rows)+1L]] <- data.frame(
    anio=as.integer(yr),predictor=pn,variable_microdato=unname(m[[pn]]),
    regla_analitica=switch(pn,sexo="1=hombre, 2=mujer; otros códigos excluidos",edad="Edad exacta agrupada en 15–29, 30–44, 45–59 y 60+",educacion="Educación recodificada, categorías 1–7",ideologia="Escala 0–10; 0 es izquierda según codebook 2023",religion="Códigos de religión registrados; leer categorías del codebook y cautela por celdas escasas",practica="Categorías 1–4; especiales excluidos",ingreso_subjetivo="Categorías 1–4 de suficiencia subjetiva del ingreso",clase="Autoadscripción 1–5",territorio="REG=departamento; etiquetas según codebook oficial 2008", "Variable incluida en cruces guía"),
    stringsAsFactors=FALSE)
}
covariate_audit <- do.call(rbind,covariate_rows)
covariate_audit$documentacion_local <- vapply(covariate_audit$anio,function(y){
  rr<-doc_matrix[doc_matrix$anio==y,,drop=FALSE]
  paste(c(rr$cuestionario_local,rr$libro_codigos_local)[nzchar(c(rr$cuestionario_local,rr$libro_codigos_local))],collapse=" | ")
},"")
covariate_audit$nota_documental <- ifelse(covariate_audit$anio==2015 & covariate_audit$predictor=="edad",
  "S13 es edad exacta del cuestionario; agrupada para cruces. Codebook oficial consultado en línea, no archivado localmente.",
  ifelse(covariate_audit$anio==2023 & covariate_audit$predictor=="educacion",
    "REEEDUC.1: educación recodificada; variable verificada en codebook local.",
    "Consultar cuestionario/libro de códigos por año; la matriz documental separa documentos locales de consulta en línea."))
write_csv(covariate_audit,"auditoria_covariables_cruces.csv")

region_names <- c("68001"="Beni","68002"="Chuquisaca","68003"="Cochabamba","68004"="La Paz",
                  "68005"="Oruro","68006"="Pando","68007"="Potosí","68008"="Santa Cruz","68009"="Tarija")
education_names <- c("1"="Analfabeto","2"="Básica incompleta","3"="Básica completa",
                     "4"="Secundaria incompleta","5"="Secundaria completa",
                     "6"="Superior incompleta","7"="Superior completa")
cross_rows<-list(); test_cross<-list(); nonresp_cross<-list(); nonresp_tests<-list(); rate_rows<-list()
for (i in seq_len(nrow(items))) {
  it<-items[i,,drop=FALSE]; y<-it$anio; d<-DATA[[as.character(y)]]
  dat_item<-item_data[[paste(y,find_col(d,it$variable),sep="_")]]; x<-dat_item$x; valid<-dat_item$valid
  predmap<-covmap[[as.character(y)]]
  if (y==2023) predmap<-extended23
  if (y==2024) predmap<-extended24
  if (is.null(predmap)) next
  for (pn in names(predmap)) {
    vv<-predmap[[pn]]
    if (is.na(vv) || !nzchar(vv)) next
    actual<-find_col(d,vv); if (is.na(actual)) next
    p<-as_num(d[[actual]])
    # Recode only well-understood missing/special categories for documented covariates.
    if (pn=="sexo") p[!p%in%c(1,2)]<-NA
    if (pn=="edad") {
      # The 2015 and some older codebooks publish age bands rather than exact ages.
      # In 2015 S13 is exact age in completed years, not a four-level age band.
      if (y==2015) {
        p[!is.finite(p) | p<15 | p>110]<-NA
        p<-cut(p,breaks=c(14,29,44,59,120),labels=c("15–29","30–44","45–59","60+"),right=TRUE)
      }
      else if (length(na.omit(p)) && max(p,na.rm=TRUE)<=4) p<-factor(p,levels=1:4,labels=c("15-25","26-40","41-60","61+"))
      else if (all(na.omit(p)%in%c(15,26,41,61)) && length(na.omit(p))) p<-factor(p,levels=c(15,26,41,61),labels=c("15–25","26–40","41–60","61+"))
      else {
        p[!is.finite(p) | p<15 | p>110]<-NA
        p<-cut(p,breaks=c(14,29,44,59,120),labels=c("15–29","30–44","45–59","60+"),right=TRUE)
      }
    }
    if (pn=="ideologia") p[!p%in%0:10]<-NA
    if (pn=="religion") p[!(p%in%c(1:20,96,97))]<-NA
    if (pn=="practica") p[!(p%in%1:4)]<-NA
    if (pn=="ingreso_subjetivo") p[!(p%in%1:4)]<-NA
    if (pn=="clase") p[!(p%in%1:5)]<-NA
    if (pn=="educacion") p[!(p%in%1:7)]<-NA
    if (pn=="territorio") p[!(p%in%68001:68009)]<-NA
    if (pn=="edad") {
      if (is.factor(p)) p<-as.character(p)
    }
    outcome_binary <- if (it$constructo=="justificacion_moral") NA else as.integer(x %in% target_codes(it))
    # For ordinal morality, report full outcome distributions by predictor rather than impose a cutpoint.
    usable <- !is.na(p) & valid
    if (sum(usable)==0) next
    pp <- as.character(p[usable]); xx <- x[usable]
    pp_label <- pp
    if (pn=="sexo") pp_label <- ifelse(pp=="1","Hombre",ifelse(pp=="2","Mujer",pp))
    if (pn=="territorio") pp_label <- unname(region_names[pp])
    if (pn=="educacion") pp_label <- unname(education_names[pp])
    tab <- table(pp,xx)
    for (r in seq_len(nrow(tab))) for (cc in seq_len(ncol(tab))) {
      ncell<-tab[r,cc]; rown<-sum(tab[r,]);
      w<-dat_item$weight[usable]; wp<-sum(w[pp==rownames(tab)[r]],na.rm=TRUE)
      cross_rows[[length(cross_rows)+1L]]<-data.frame(
        anio=y,variable=dat_item$item$variable,constructo=it$constructo,predictor=pn,
        variable_predictor=actual,nivel_predictor=rownames(tab)[r],nivel_predictor_label=pp_label[match(rownames(tab)[r],pp)],respuesta=colnames(tab)[cc],
        n=ncell,n_fila=rown,pct_fila=ifelse(rown>0,100*ncell/rown,NA_real_),
        pct_fila_ponderado=ifelse(wp>0,100*sum(w[pp==rownames(tab)[r] & xx==as.numeric(colnames(tab)[cc])])/wp,NA_real_),
        n_total_cruce=sum(usable),stringsAsFactors=FALSE)
    }
    # SRS tests only, with expected-cell diagnostics; tests are adjusted by outcome family below.
    if (it$constructo!="justificacion_moral") {
      yb<-outcome_binary[usable]; tt<-table(pp,yb)
      group_levels<-unique(pp)
      for (g in group_levels) {
        useg<-pp==g; wg<-dat_item$weight[usable][useg]
        rate_rows[[length(rate_rows)+1L]]<-data.frame(anio=y,variable=dat_item$item$variable,constructo=it$constructo,
          predictor=pn,nivel_predictor=g,nivel_predictor_label=pp_label[match(g,pp)],n=sum(useg),
          evento_n=sum(yb[useg]==1),pct_evento=100*mean(yb[useg]==1),
          pct_evento_ponderado=100*sum(wg[yb[useg]==1])/sum(wg),stringsAsFactors=FALSE)
      }
      if (nrow(tt)>1 && ncol(tt)>1) {
        ch<-suppressWarnings(chisq.test(tt,correct=FALSE))
        minexp<-min(ch$expected)
        if (all(dim(tt)==c(2,2)) && minexp<5) {
          ppval<-fisher.test(tt)$p.value; method<-"Fisher exacta SRS (solo tablas 2x2)"
        } else {ppval<-ch$p.value; method<-"Chi-cuadrado Pearson SRS aproximada"}
        test_cross[[length(test_cross)+1L]]<-data.frame(anio=y,variable=dat_item$item$variable,constructo=it$constructo,
          predictor=pn,variable_predictor=actual,n=sum(tt),estadistico=unname(ch$statistic),gl=unname(ch$parameter),
          p_srs=ppval,minimo_esperado=minexp,diagnostico=ifelse(minexp<5,"Celdas escasas: interpretar solo como exploración","Sin celda esperada <5"),
          metodo=method,stringsAsFactors=FALSE)
      }
    } else if (it$constructo=="justificacion_moral" && length(unique(pp))>1) {
      kt<-suppressWarnings(kruskal.test(xx,as.factor(pp)))
      test_cross[[length(test_cross)+1L]]<-data.frame(anio=y,variable=dat_item$item$variable,constructo=it$constructo,
          predictor=pn,variable_predictor=actual,n=sum(usable),estadistico=unname(kt$statistic),gl=unname(kt$parameter),p_srs=kt$p.value,
          minimo_esperado=NA,diagnostico="Kruskal–Wallis sobre escala ordinal; sensibilidad SRS",metodo="Kruskal–Wallis SRS aproximada",stringsAsFactors=FALSE)
    }
    # No respuesta del ítem por predictor, distinta de la opinión negativa.
    nruse<-!is.na(p)
    nrflag<-as.integer(!valid)
    if (sum(nruse)>0) {
      nrt<-table(as.character(p[nruse]),nrflag[nruse])
      nrlabel<-rownames(nrt)
      if(pn=="sexo") nrlabel<-ifelse(nrlabel=="1","Hombre",ifelse(nrlabel=="2","Mujer",nrlabel))
      if(pn=="territorio") nrlabel<-unname(region_names[rownames(nrt)])
      if(pn=="educacion") nrlabel<-unname(education_names[rownames(nrt)])
      for (r in seq_len(nrow(nrt))) nonresp_cross[[length(nonresp_cross)+1L]]<-data.frame(
        anio=y,variable=dat_item$item$variable,predictor=pn,nivel_predictor=rownames(nrt)[r],nivel_predictor_label=nrlabel[r],
        n=sum(nrt[r,]),n_no_respuesta=if("1"%in%colnames(nrt))nrt[r,"1"] else 0,
        pct_no_respuesta=100*(if("1"%in%colnames(nrt))nrt[r,"1"] else 0)/sum(nrt[r,]),stringsAsFactors=FALSE)
      if (nrow(nrt)>1 && ncol(nrt)>1) {
        nch<-suppressWarnings(chisq.test(nrt,correct=FALSE)); nmin<-min(nch$expected)
        if(all(dim(nrt)==c(2,2)) && nmin<5){npv<-fisher.test(nrt)$p.value;nmethod<-"Fisher exacta SRS"}
        else {npv<-nch$p.value;nmethod<-"Chi-cuadrado SRS aproximada"}
        nonresp_tests[[length(nonresp_tests)+1L]]<-data.frame(anio=y,variable=dat_item$item$variable,predictor=pn,n=sum(nrt),
          estadistico=unname(nch$statistic),gl=unname(nch$parameter),p_srs=npv,minimo_esperado=nmin,metodo=nmethod,
          stringsAsFactors=FALSE)
      }
    }
  }
}
cross_out<-if(length(cross_rows))do.call(rbind,cross_rows) else data.frame()
test_out<-if(length(test_cross))do.call(rbind,test_cross) else data.frame()
if(nrow(test_out)) test_out$p_holm_familia<-ave(test_out$p_srs,interaction(test_out$anio,test_out$constructo,drop=TRUE),FUN=function(z)p.adjust(z,method="holm"))
nonresp_test_out<-if(length(nonresp_tests))do.call(rbind,nonresp_tests) else data.frame()
if(nrow(nonresp_test_out)) nonresp_test_out$p_holm_item<-ave(nonresp_test_out$p_srs,interaction(nonresp_test_out$anio,nonresp_test_out$variable,drop=TRUE),FUN=function(z)p.adjust(z,method="holm"))
write_csv(cross_out,"cruces_descriptivos_completos.csv")
write_csv(test_out,"pruebas_cruces_sensibilidad_srs.csv")
write_csv(if(length(nonresp_cross))do.call(rbind,nonresp_cross) else data.frame(),"no_respuesta_por_perfil.csv")
write_csv(nonresp_test_out,"pruebas_no_respuesta_sensibilidad_srs.csv")
write_csv(if(length(rate_rows))do.call(rbind,rate_rows) else data.frame(),"tasas_objetivo_por_perfil.csv")

# Desglose territorial para las dos oleadas con batería directa; REG codifica
# departamentos (codebook oficial; los tamaños pequeños quedan advertidos).
territory_rows<-list()
for (y in c(2023,2024)) {
  d<-DATA[[as.character(y)]]; reg<-get_num(d,"REG")
  subset_items<-if(y==2023)items[items$anio==2023 & items$constructo=="derechos_2023",] else items[items$anio==2024 & items$constructo=="distancia_social",]
  for(i in seq_len(nrow(subset_items))) {
    it<-subset_items[i,]; x<-get_num(d,it$variable); valid<-valid_codes(it,x,d); event<-valid & x%in%target_codes(it)
    for(code in sort(unique(reg))) {
      use<-reg==code; denom<-sum(use & valid); k<-sum(use & event); ci<-wilson(k,denom)
      territory_rows[[length(territory_rows)+1L]]<-data.frame(anio=y,departamento=unname(region_names[as.character(code)]),
        codigo_REG=code,variable=it$variable,n_muestra=sum(use),n_valido=denom,n_no_valido=sum(use & !valid),
        evento_n=k,pct_evento=ifelse(denom>0,100*k/denom,NA_real_),pct_total=100*k/sum(use),
        ic95_srs_sens_inf=100*ci[1],ic95_srs_sens_sup=100*ci[2],
        advertencia=ifelse(sum(use)<30,"N departamental <30; descriptivo inestable","Descriptivo; no ajusta diseño muestral"),stringsAsFactors=FALSE)
    }
  }
}
write_csv(do.call(rbind,territory_rows),"desglose_territorial_2023_2024.csv")

# Modelos exploratorios recientes para hipótesis teóricas explícitas.
# 2024 logística binaria: rechazo vecinal mencionado (1) vs no mencionado (0).
d24<-DATA[["2024"]]; y24<-get_num(d24,"P3NOIJ.3"); responded24<-get_num(d24,"P3NOIJ.9")==0
sex24<-get_num(d24,"SEXO"); age24<-get_num(d24,"EDAD"); edu24<-get_num(d24,"REEDUC.1")
ideol24<-get_num(d24,"P16ST"); practice24<-get_num(d24,"S1A"); class24<-get_num(d24,"S2"); income24<-get_num(d24,"S5")
othercols<-c("P3NOIJ.1","P3NOIJ.2","P3NOIJ.4","P3NOIJ.6","P3NOIJ.7","P3NOIJ.8")
othermat<-sapply(othercols,function(v)get_num(d24,v)); count_exclusion<-rowSums(othermat==1,na.rm=TRUE)
model24<-data.frame(y=y24,sexo=factor(sex24,levels=c(1,2),labels=c("Hombre","Mujer")),
  edad_decadas=age24/10,educacion=factor(edu24),practica=factor(ifelse(practice24==-3,5,practice24),levels=c(1,2,3,4,5),labels=c("Muy practicante","Practicante","No muy practicante","No practicante","No aplica")),
  ideologia=ifelse(ideol24%in%0:10,ideol24,NA),clase=factor(ifelse(class24%in%1:5,class24,NA)),
  ingreso_subjetivo=factor(ifelse(income24%in%1:4,income24,NA)),otros_grupos_rechazados=count_exclusion,
  response=responded24)
model_complete<-complete.cases(model24[,c("y","sexo","edad_decadas","educacion","practica","ideologia","clase","ingreso_subjetivo","otros_grupos_rechazados")]) & model24$response
model_summary<-data.frame(n_muestra=sum(model_complete),eventos=sum(model24$y[model_complete]==1),
  tasa_eventos=mean(model24$y[model_complete]),n_bateria_respondida=sum(responded24),n_no_respuesta=sum(!responded24),
  enfoque="Logística binaria no ponderada, casos completos; asociación/modelo exploratorio SRS, no inferencia de diseño ni causal.",
  stringsAsFactors=FALSE)
write_csv(model_summary,"modelo_2024_resumen.csv")
model_coefs<-data.frame()
nonlinearity_rows<-list()
if (sum(model_complete)>100 && length(unique(model24$y[model_complete]))==2) {
  m24<-stats::glm(y~sexo+edad_decadas+educacion+practica+ideologia+clase+ingreso_subjetivo+otros_grupos_rechazados,
                  data=model24[model_complete,],family=binomial())
  sm<-summary(m24)$coefficients
  model_coefs<-data.frame(termino=rownames(sm),beta=sm[,1],se_modelo=sm[,2],z=sm[,3],p_srs=sm[,4],
    OR=exp(sm[,1]),OR_ic95_inf=exp(sm[,1]-1.96*sm[,2]),OR_ic95_sup=exp(sm[,1]+1.96*sm[,2]),
    n=sum(model_complete),eventos=sum(model24$y[model_complete]==1),
    stringsAsFactors=FALSE,row.names=NULL)
  model_coefs$p_holm<-NA_real_
  keep_terms<-model_coefs$termino!="(Intercept)"
  model_coefs$p_holm[keep_terms]<-p.adjust(model_coefs$p_srs[keep_terms],method="holm")
  model_summary$convergio<-m24$converged; model_summary$AIC<-AIC(m24)
  model_summary$brier<-mean((model24$y[model_complete]-fitted(m24))^2)
  model_summary$nota_conteo<-"Conteo excluye homosexuales y sustancias/alcohol; seis grupos restantes; asociación de propensión de exclusión, no índice validado."
  write_csv(model_summary,"modelo_2024_resumen.csv")
  joint_terms<-c("sexo","edad_decadas","educacion","practica","ideologia","clase","ingreso_subjetivo","otros_grupos_rechazados")
  joint_tests<-do.call(rbind,lapply(joint_terms,function(term){
    reduced<-stats::update(m24,as.formula(paste(".~.-",term)))
    comp<-anova(reduced,m24,test="LRT")
    data.frame(predictor=term,gl=comp$Df[2],chi2_LR=comp$Deviance[2],p_LR_srs=comp$`Pr(>Chi)`[2],
      n=sum(model_complete),evento_n=sum(model24$y[model_complete]==1),stringsAsFactors=FALSE)
  }))
  joint_tests$p_holm_predictor<-p.adjust(joint_tests$p_LR_srs,method="holm")
  write_csv(joint_tests,"modelo_2024_pruebas_conjuntas.csv")
  for(term in c("edad_decadas","ideologia")) {
    flexible_formula<-if(term=="edad_decadas") stats::as.formula(". ~ . - edad_decadas + splines::ns(edad_decadas, df=3)") else stats::as.formula(". ~ . - ideologia + splines::ns(ideologia, df=3)")
    flexible<-try(stats::update(m24,flexible_formula),silent=TRUE)
    if(inherits(flexible,"try-error")) next
    lrflex<-max(0,2*(as.numeric(logLik(flexible))-as.numeric(logLik(m24))))
    dfflex<-max(0,attr(logLik(flexible),"df")-attr(logLik(m24),"df"))
    nonlinearity_rows[[length(nonlinearity_rows)+1L]]<-data.frame(variable=term,n=sum(model_complete),gl=dfflex,chi2_LR=lrflex,
      p_LR_srs=if(dfflex>0)pchisq(lrflex,dfflex,lower.tail=FALSE) else NA_real_,AIC_lineal=AIC(m24),AIC_flexible=AIC(flexible),
      stringsAsFactors=FALSE)
  }
}
write_csv(model_coefs,"modelo_2024_coeficientes.csv")
nonlinearity_tests<-if(length(nonlinearity_rows))do.call(rbind,nonlinearity_rows) else data.frame()
if(nrow(nonlinearity_tests)) nonlinearity_tests$p_holm_2_pruebas<-p.adjust(nonlinearity_tests$p_LR_srs,method="holm")
write_csv(nonlinearity_tests,"modelo_2024_sensibilidad_no_linealidad.csv")

# Modelos ordinales de sensibilidad para los cuatro derechos de 2023. La escala
# queda ordenada desde desacuerdo fuerte (4) hasta acuerdo fuerte (1), de modo
# que OR>1 representa mayores odds de ubicarse hacia más acuerdo.
ordinal_coef_rows<-list(); ordinal_joint_rows<-list(); multinom_joint_rows<-list(); ordinal_diag_rows<-list(); ordinal_summary_rows<-list()
if(requireNamespace("MASS",quietly=TRUE) && requireNamespace("nnet",quietly=TRUE)) {
  d23<-DATA[["2023"]]
  ord_data<-data.frame(
    sexo=factor(get_num(d23,"SEXO"),levels=c(1,2),labels=c("Hombre","Mujer")),
    edad=factor(cut(get_num(d23,"EDAD"),breaks=c(14,29,44,59,120),labels=c("15–29","30–44","45–59","60+"),right=TRUE)),
    educacion=factor(ifelse(get_num(d23,"REEEDUC.1")%in%1:7,get_num(d23,"REEEDUC.1"),NA),levels=1:7),
    practica=factor(ifelse(get_num(d23,"S1A")%in%1:4,get_num(d23,"S1A"),NA),levels=1:4),
    ideologia=ifelse(get_num(d23,"P16ST")%in%0:10,get_num(d23,"P16ST"),NA),
    ingreso=factor(ifelse(get_num(d23,"S5")%in%1:4,get_num(d23,"S5"),NA),levels=1:4),
    stringsAsFactors=FALSE)
  ord_terms<-c("sexo","edad","educacion","practica","ideologia","ingreso")
  ord_formula<-stats::as.formula(paste("respuesta ~",paste(ord_terms,collapse="+")))
  for(v in rights$variable) {
    yy<-get_num(d23,v)
    ord_data$respuesta<-ordered(yy,levels=c(4,3,2,1))
    use<-complete.cases(ord_data[,c("respuesta",ord_terms)])
    md<-ord_data[use,,drop=FALSE]
    if(sum(use)<300 || length(unique(md$respuesta))<4) {
      ordinal_summary_rows[[length(ordinal_summary_rows)+1L]]<-data.frame(variable=v,n=sum(use),categorias=length(unique(md$respuesta)),logLik=NA_real_,AIC=NA_real_,convergio=FALSE,estado="No estimado: tamaño o categorías insuficientes",stringsAsFactors=FALSE)
      next
    }
    mpo<-try(MASS::polr(ord_formula,data=md,method="logistic",Hess=TRUE,model=TRUE),silent=TRUE)
    if(inherits(mpo,"try-error")) {
      ordinal_summary_rows[[length(ordinal_summary_rows)+1L]]<-data.frame(variable=v,n=sum(use),categorias=length(unique(md$respuesta)),logLik=NA_real_,AIC=NA_real_,convergio=FALSE,estado="Falló polr; no se reportan coeficientes",stringsAsFactors=FALSE)
      next
    }
    smpo<-summary(mpo)$coefficients
    slope_rows<-rownames(smpo)[!grepl("\\|",rownames(smpo),fixed=TRUE)]
    smpo<-smpo[slope_rows,,drop=FALSE]
    coef_df<-data.frame(variable=v,termino=rownames(smpo),beta=smpo[,1],se_modelo=smpo[,2],z=smpo[,3],p_srs=2*pnorm(abs(smpo[,3]),lower.tail=FALSE),
      OR=exp(smpo[,1]),OR_ic95_inf=exp(smpo[,1]-1.96*smpo[,2]),OR_ic95_sup=exp(smpo[,1]+1.96*smpo[,2]),n=sum(use),
      orden_respuesta="4 desacuerdo fuerte → 3 desacuerdo → 2 acuerdo → 1 acuerdo fuerte",stringsAsFactors=FALSE,row.names=NULL)
    coef_df$p_holm_coef<-p.adjust(coef_df$p_srs,method="holm")
    ordinal_coef_rows[[length(ordinal_coef_rows)+1L]]<-coef_df
    llfull<-as.numeric(logLik(mpo));df_full<-attr(logLik(mpo),"df")
    for(term in ord_terms) {
      mred<-try(stats::update(mpo,stats::as.formula(paste(". ~ . -",term))),silent=TRUE)
      if(inherits(mred,"try-error")) next
      l_red<-as.numeric(logLik(mred));df_red<-attr(logLik(mred),"df")
      lr<-max(0,2*(llfull-l_red));dfdiff<-max(0,df_full-df_red)
      ordinal_joint_rows[[length(ordinal_joint_rows)+1L]]<-data.frame(variable=v,predictor=term,n=sum(use),gl=dfdiff,chi2_LR=lr,p_LR_srs=if(dfdiff>0)pchisq(lr,dfdiff,lower.tail=FALSE) else NA_real_,stringsAsFactors=FALSE)
    }
    mnom<-try(nnet::multinom(ord_formula,data=md,trace=FALSE,maxit=1000),silent=TRUE)
    po_stat<-po_df<-po_p<-NA_real_
    if(!inherits(mnom,"try-error")) {
      llnom<-as.numeric(logLik(mnom));df_nom<-attr(logLik(mnom),"df")
      po_stat<-2*(llnom-llfull);po_df<-df_nom-df_full
      if(is.finite(po_stat) && po_stat>=0 && is.finite(po_df) && po_df>0) po_p<-pchisq(po_stat,po_df,lower.tail=FALSE)
      if(mnom$convergence==0) for(term in ord_terms) {
        mnom_red<-try(stats::update(mnom,stats::as.formula(paste(". ~ . -",term))),silent=TRUE)
        if(inherits(mnom_red,"try-error")) next
        nom_lr<-max(0,2*(as.numeric(logLik(mnom))-as.numeric(logLik(mnom_red))))
        nom_df<-max(0,attr(logLik(mnom),"df")-attr(logLik(mnom_red),"df"))
        multinom_joint_rows[[length(multinom_joint_rows)+1L]]<-data.frame(variable=v,predictor=term,n=sum(use),gl=nom_df,chi2_LR=nom_lr,
          p_LR_srs=if(nom_df>0)pchisq(nom_lr,nom_df,lower.tail=FALSE) else NA_real_,convergio=TRUE,stringsAsFactors=FALSE)
      }
    }
    ordinal_diag_rows[[length(ordinal_diag_rows)+1L]]<-data.frame(variable=v,n=sum(use),logLik_PO=llfull,logLik_multinomial=if(!inherits(mnom,"try-error"))as.numeric(logLik(mnom)) else NA_real_,
      LR_relajacion_PO=po_stat,gl_relajacion_PO=po_df,p_relajacion_PO_srs=po_p,
      convergio_multinomial=if(!inherits(mnom,"try-error"))mnom$convergence==0 else FALSE,
      diagnostico=if(is.na(po_p))"No se pudo contrastar el supuesto" else if(po_p<.05)"Se rechaza proporcionalidad de odds bajo prueba aproximada; interpretar polr con cautela" else "No se rechaza proporcionalidad de odds bajo prueba aproximada; no prueba que sea cierta",
      stringsAsFactors=FALSE)
    ordinal_summary_rows[[length(ordinal_summary_rows)+1L]]<-data.frame(variable=v,n=sum(use),categorias=length(unique(md$respuesta)),logLik=llfull,AIC=AIC(mpo),convergio=TRUE,
      estado="Estimado como sensibilidad SRS; sin ponderación ni diseño completo",stringsAsFactors=FALSE)
  }
}
ordinal_coef<-if(length(ordinal_coef_rows))do.call(rbind,ordinal_coef_rows) else data.frame()
ordinal_joint<-if(length(ordinal_joint_rows))do.call(rbind,ordinal_joint_rows) else data.frame()
multinom_joint<-if(length(multinom_joint_rows))do.call(rbind,multinom_joint_rows) else data.frame()
ordinal_diag<-if(length(ordinal_diag_rows))do.call(rbind,ordinal_diag_rows) else data.frame()
ordinal_summary<-if(length(ordinal_summary_rows))do.call(rbind,ordinal_summary_rows) else data.frame()
if(nrow(ordinal_joint)) ordinal_joint$p_holm_24_testes<-p.adjust(ordinal_joint$p_LR_srs,method="holm")
if(nrow(multinom_joint)) multinom_joint$p_holm_24_testes<-p.adjust(multinom_joint$p_LR_srs,method="holm")
if(nrow(ordinal_diag)) {
  ordinal_diag$p_relajacion_PO_holm_4_modelos<-p.adjust(ordinal_diag$p_relajacion_PO_srs,method="holm")
  ordinal_diag$diagnostico<-ifelse(is.na(ordinal_diag$p_relajacion_PO_holm_4_modelos),"No se pudo contrastar el supuesto",
    ifelse(ordinal_diag$p_relajacion_PO_holm_4_modelos<.05,"Se rechaza proporcionalidad de odds después de Holm; interpretar polr con cautela",
      "No se rechaza proporcionalidad de odds después de Holm; no prueba que sea cierta"))
}
write_csv(ordinal_coef,"modelos_ordinales_derechos_2023_coeficientes.csv")
write_csv(ordinal_joint,"modelos_ordinales_derechos_2023_pruebas_conjuntas.csv")
write_csv(multinom_joint,"modelos_multinomiales_derechos_2023_pruebas_conjuntas.csv")
write_csv(ordinal_diag,"diagnosticos_proporcionalidad_odds_2023.csv")
write_csv(ordinal_summary,"resumen_modelos_ordinales_derechos_2023.csv")

# Sensibilidad parcial de conglomeración/estratificación si está disponible.
design_sens<-data.frame()
if (requireNamespace("survey",quietly=TRUE)) {
  options(survey.lonely.psu="adjust")
  for (y in c(2023,2024)) {
    d<-DATA[[as.character(y)]]; reg<-get_num(d,"REG"); psu<-get_num(d,"COMDIST"); wt<-safe_weight(d)$value
    if (all(is.finite(reg)) && all(is.finite(psu))) {
      des<-try(survey::svydesign(ids=~psu,strata=~reg,weights=~wt,data=data.frame(reg=reg,psu=psu,wt=wt),nest=TRUE),silent=TRUE)
      if (!inherits(des,"try-error")) {
        if (y==2023) {
          for (v in rights$variable) {
            yy<-get_num(d,v); use<-yy%in%1:4; design<-survey::svydesign(ids=~psu,strata=~reg,weights=~wt,data=data.frame(reg=reg[use],psu=psu[use],wt=wt[use],out=as.numeric(yy[use]<=2)),nest=TRUE)
            est<-try(survey::svymean(~out,design),silent=TRUE)
            if(!inherits(est,"try-error")){se<-survey::SE(est)[1];p<-coef(est)[1];design_sens<-rbind(design_sens,data.frame(anio=y,variable=v,n=sum(use),n_psu=length(unique(psu[use])),n_strata=length(unique(reg[use])),pct=100*p,ic95_inf=100*(p-1.96*se),ic95_sup=100*(p+1.96*se),tipo="Sensibilidad parcial con PSU=COMDIST y estrato=REG; no incorpora etapas/cuotas."))}
          }
        } else {
          yy<-get_num(d,"P3NOIJ.3"); use<-yy%in%c(0,1) & get_num(d,"P3NOIJ.9")==0
          design<-survey::svydesign(ids=~psu,strata=~reg,weights=~wt,data=data.frame(reg=reg[use],psu=psu[use],wt=wt[use],out=yy[use]),nest=TRUE)
          est<-try(survey::svymean(~out,design),silent=TRUE)
          if(!inherits(est,"try-error")){se<-survey::SE(est)[1];p<-coef(est)[1];design_sens<-rbind(design_sens,data.frame(anio=y,variable="P3NOIJ.3",n=sum(use),n_psu=length(unique(psu[use])),n_strata=length(unique(reg[use])),pct=100*p,ic95_inf=100*(p-1.96*se),ic95_sup=100*(p+1.96*se),tipo="Sensibilidad parcial con PSU=COMDIST y estrato=REG; no incorpora etapas/cuotas."))}
        }
      }
    }
  }
}
write_csv(design_sens,"sensibilidad_diseno_parcial_2023_2024.csv")

# Auditoría explícita de discrepancias y cobertura del diseño.
issues<-data.frame(
  anio=c(1996,2000,2002,2006,2016,2023,2023,2024),
  tipo=c("ID", "ponderador", "ID", "ID", "ponderador", "no respuesta", "edad/universo", "diseño"),
  observacion=c("No se encontró NUMENTRE ni NUMINVES inequívoco; no deduplicar por heurística.",
    "No aparece columna WT/pondera en el CSV boliviano; no crear peso.",
    "NUMENTRE se repite en dos filas; conservar ambas hasta comprobar si el identificador es único en el marco.",
    "NUMENTRE se repite en dos filas; conservar ambas hasta comprobar si el identificador es único en el marco.",
    "WT es constante 1; ficha metodológica 2016 indica que el ponderador no aplica.",
    "Cuestionario/codebook usan 0 para NS/NR en cuatro ítems; en el CSV aparecen -5 y no 0.",
    "EDAD observada en Bolivia va de 18 a 84; REEDAD etiqueta 16–25 en el codebook. El universo local parece adulto, verificar ficha país.",
    "La ficha técnica indica cuatro etapas y cuota en la última; microdato no permite reconstruir todas las probabilidades ni etapas."),
  severidad=c("revisar", "documentar", "revisar", "revisar", "documentar", "alta", "media", "alta"),
  accion=c("Auditar campos alternativos; ningún registro se eliminó.","Reportar conteos; no ponderar.","Retener todos los registros; cotejar documentación del identificador.","Retener todos los registros; cotejar documentación del identificador.","No afecta porcentajes porque el peso es constante.","Analizar solo 1–4 como respuestas; reportar -5 como código especial observado y conservarlo en distribución cruda.","No interpretar la etiqueta de grupo como evidencia de entrevistas a menores; la edad efectiva mínima de microdato es 18.","Intervalos y pruebas SRS se publican solo como sensibilidad; no llamar diseño-completos."),
  stringsAsFactors=FALSE)
issues<-rbind(issues,data.frame(
  anio=c(2000,2001,2015,2024),tipo=c("N microdato vs ficha","N microdato vs ficha","recodificación de edad","no respuesta en batería"),
  observacion=c("El CSV boliviano contiene 1.080 filas y todas tienen IDENPA=68; la ficha técnica oficial 2000 reporta 1.000 casos para Bolivia.",
    "El CSV boliviano contiene 1.075 filas; la ficha técnica oficial 2001 reporta 1.080 casos para Bolivia.",
    "S13 registra edad cumplida en años en el cuestionario. Para los cruces se agrupa en bandas 15–29, 30–44, 45–59 y 60+; no se interpreta como código categórico.",
    "P3NOIJ.9 identifica NS/NR. En esos registros P3NOIJ.3 aparece como 0, por lo que el valor .3 aislado no distingue no mención sustantiva de no respuesta; el análisis excluye los casos con .9 distinto de 0."),
  severidad=c("alta","media","resuelto en recodificación","alta"),
  accion=c("Mantener 1.080 filas para conteo descriptivo del archivo; no sustituir por el N de ficha. Verificar versión/extracción con Latinobarómetro antes de cualquier estimación que dependa del marco.",
    "Mantener 1.075 filas para conteo descriptivo del archivo; documentar la diferencia de cinco casos frente a ficha oficial.",
    "Usar cortes derivados de edad exacta y conservar S13 como fuente. La recodificación se declara en cruces y código.",
    "Para toda tabla de distancia social 2024 usar P3NOIJ.9=0 como criterio de respuesta válida y reportar por separado 174 NS/NR."),
  stringsAsFactors=FALSE))
write_csv(issues,"registro_discrepancias.csv")

design_source <- rep("Ficha técnica consolidada oficial 1995–2015 (cotejar ficha específica del país)",length(YEARS))
design_source[YEARS==2016] <- "Informe metodológico oficial 2016"
design_source[YEARS==2000] <- "Ficha técnica individual oficial 2000"
design_source[YEARS==2001] <- "Ficha técnica individual oficial 2001"
design_source[YEARS==2002] <- "Ficha técnica oficial 2002"
design_source[YEARS==2010] <- "Informe metodológico oficial 2010"
design_source[YEARS==2013] <- "Informe metodológico oficial 2013"
design_source[YEARS==2017] <- "Página oficial de datos 2017; ficha país pendiente de cotejo"
design_source[YEARS==2018] <- "Informe metodológico oficial 2018"
design_source[YEARS==2020] <- "Informe metodológico oficial 2020"
design_source[YEARS==2023] <- "Página/documentación oficial 2023; ficha boliviana independiente no localizada localmente"
design_source[YEARS==2024] <- "Ficha técnica oficial 2024"
design_link <- rep("https://www.latinobarometro.org/documents/LAT-2015/latinobarometro-fichas-tecnicas-1995-2015.pdf",length(YEARS))
design_link[YEARS==2016] <- "https://www.latinobarometro.org/documents/LAT-2016/informemetodologico-latinobarometro-2016.pdf"
design_link[YEARS==2000] <- "https://www.latinobarometro.org/documents/LAT-2000/fichatecnica-latinobarometro-2000.pdf"
design_link[YEARS==2001] <- "https://www.latinobarometro.org/documents/LAT-2001/fichatecnica-latinobarometro-2001.pdf"
design_link[YEARS==2002] <- "https://www.latinobarometro.org/documents/LAT-2002/fichatecnica-latinobarometro-2002.pdf"
design_link[YEARS==2010] <- "https://www.latinobarometro.org/documents/LAT-2010/informemetodologico-latinobarometro-2010.pdf"
design_link[YEARS==2013] <- "https://www.latinobarometro.org/documents/LAT-2013/informemetodologico-latinobarometro-2013.pdf"
design_link[YEARS==2017] <- "https://www.latinobarometro.org/latinobarometro-2017"
design_link[YEARS==2018] <- "https://www.latinobarometro.org/documents/LAT-2018/informemetodologico-latinobarometro-2018.pdf"
design_link[YEARS==2020] <- "https://www.latinobarometro.org/documents/LAT-2020/latinobarometro-2020-metodologico.pdf"
design_link[YEARS==2023] <- "https://latinobarometro.org/latinobarometro-2023"
design_link[YEARS==2024] <- "https://www.latinobarometro.org/documents/LAT-2024/latinobarometro-2024-fichas-tecnicas.pdf"
design_matrix<-data.frame(anio=YEARS,fuente_muestral=design_source,link=design_link,
  microdato_peso=wave_audit$ponderador_candidato[match(YEARS,wave_audit$anio)],
  peso_varia=wave_audit$ponderador_no_constante[match(YEARS,wave_audit$anio)],
  variables_geograficas=wave_audit$campos_diseno_posibles[match(YEARS,wave_audit$anio)],
  estado_inferencia="No se identifican simultáneamente probabilidades de selección, etapas, PSU y estratos completos para reproducir varianza oficial desde el CSV; intervalos SRS solo sensibilidad.",
  stringsAsFactors=FALSE)
design_matrix$observacion_diseno <- "Verificar ficha país específica; el campo WT por sí solo no reconstruye diseño ni varianza."
design_matrix$observacion_diseno[design_matrix$anio==2013] <- "Ficha refiere estratificación y varias etapas con cuotas finales; falta reconstrucción completa desde microdato."
design_matrix$observacion_diseno[design_matrix$anio==2000] <- "Ficha Bolivia: hogares probabilísticos con cuotas por sexo y edad en selección del entrevistado; n ficha=1.000, microdato=1.080; 52% representatividad indicada."
design_matrix$observacion_diseno[design_matrix$anio==2001] <- "Ficha Bolivia: muestra probabilística trietápica; n ficha=1.080, microdato=1.075; representatividad indicada=52%."
design_matrix$observacion_diseno[design_matrix$anio==2002] <- "Ficha Bolivia: muestreo trietápico con cuotas finales; microdato N coincide con ficha. No hay información completa de PSU/estratos en archivo para varianza."
design_matrix$observacion_diseno[design_matrix$anio==2010] <- "Ficha metodológica: Bolivia n=1.200, selección probabilística en etapas iniciales y cuota final; WT constante 1 en archivo."
design_matrix$observacion_diseno[design_matrix$anio==2013] <- "Ficha refiere estratificación por departamento y selección polietápica con cuotas finales; no reconstruye varianza completa desde el CSV."
design_matrix$observacion_diseno[design_matrix$anio==2016] <- "La ficha oficial indica que el ponderador no aplica; WT constante 1."
design_matrix$observacion_diseno[design_matrix$anio==2020] <- "Informe describe diseño estratificado y cuatro etapas, con cuota en etapa final; no hay variables suficientes para varianza completa."
design_matrix$observacion_diseno[design_matrix$anio==2023] <- "Documentación de microdato y ficha país insuficiente para reconstruir diseño; WT=1."
design_matrix$observacion_diseno[design_matrix$anio==2024] <- "Bolivia n=1.200; cuatro etapas, probabilidad en primeras tres y cuota final según ficha 2024; no es diseño probabilístico completo."
write_csv(design_matrix,"auditoria_diseno_y_fuentes.csv")

# Figuras principales (porcentajes observados, sin bandas de confianza de diseño).
png(file.path(FIG,"tamano_muestras_oleada.png"),width=1200,height=650,res=130)
barplot(wave_audit$filas_leidas,names.arg=wave_audit$anio,las=2,col="#3C7892",border=NA,
        main="Entrevistas por oleada boliviana",ylab="Registros del microdato",cex.names=.75)
dev.off()
png(file.path(FIG,"matrimonio_serie.png"),width=1000,height=650,res=130)
ms<-read.csv(file.path(RES,"serie_matrimonio_2010_2023.csv")); plot(ms$anio,ms$acuerdo_pct,type="b",pch=19,lwd=2,col="#8A3F62",xaxt="n",ylim=c(0,100),
  main="Acuerdo con matrimonio entre personas del mismo sexo",xlab="Oleada",ylab="Porcentaje de respuestas válidas")
axis(1,at=ms$anio,labels=ms$anio); grid(); dev.off()
png(file.path(FIG,"derechos_2023.png"),width=1100,height=700,res=130)
rs<-outcome_summary[outcome_summary$anio==2023,]; lab<-c("Adopción","Matrimonio","Reconocimiento documental","Parentalidad")
barplot(rs$pct_objetivo_valido,names.arg=lab,las=2,col="#4E8578",border=NA,ylim=c(0,100),
  main="Acuerdo por ámbito de derecho, 2023",ylab="Porcentaje de respuestas válidas")
abline(h=50,lty=2,col="grey40"); dev.off()
png(file.path(FIG,"justificacion_ordinal.png"),width=1400,height=700,res=130)
jd<-do.call(rbind,lapply(c(2002,2004,2008),function(y){it<-items[items$anio==y & items$constructo=="justificacion_moral",];a<-item_data[[paste(y,find_col(DATA[[as.character(y)]],it$variable),sep="_")]];x<-a$x[a$valid];prop.table(table(factor(x,levels=1:10)))}))
oldpar<-par(mar=c(5,4,4,10),xpd=NA); just_cols<-grDevices::hcl.colors(10,"YlOrRd",rev=TRUE)
barplot(t(as.matrix(jd))*100,beside=FALSE,col=just_cols,
  names.arg=c("2002","2004","2008"),
  main="Distribución ordinal de justificación moral",ylab="Porcentaje válido")
legend("topright",inset=c(-.23,0),legend=paste("Respuesta",1:10),fill=just_cols,cex=.72,bty="n")
par(oldpar)
dev.off()

# Dossier analítico regenerado con resultados y límites visibles.
fmt <- function(x,d=1) ifelse(is.na(x),"NA",formatC(x,format="f",digits=d,big.mark=","))
pick <- function(y,construct) outcome_summary[outcome_summary$anio==y & outcome_summary$constructo==construct,,drop=FALSE]
mar_rows<-rbind(outcome_summary[outcome_summary$constructo=="matrimonio",],
                outcome_summary[outcome_summary$anio==2023 & outcome_summary$variable=="P37CSN.B",])
just_rows<-do.call(rbind,lapply(c(2002,2004,2008),function(y) {
  ss<-read.csv(file.path(RES,"serie_justificacion_2002_2008.csv"));ss[ss$anio==y,]
}))
rights_rows<-outcome_summary[outcome_summary$anio==2023 & outcome_summary$constructo=="derechos_2023",]
neighbor24<-outcome_summary[outcome_summary$anio==2024,]
neighbor98<-outcome_summary[outcome_summary$anio==1998,]
salience06<-outcome_summary[outcome_summary$anio==2006,]
salience08<-outcome_summary[outcome_summary$anio==2008 & tolower(outcome_summary$variable)=="p68st",]
rate_output<-read.csv(file.path(RES,"tasas_objetivo_por_perfil.csv"),check.names=FALSE)
test_output<-read.csv(file.path(RES,"pruebas_cruces_sensibilidad_srs.csv"),check.names=FALSE)
nr_output<-read.csv(file.path(RES,"no_respuesta_por_perfil.csv"),check.names=FALSE)
nr_test_output<-read.csv(file.path(RES,"pruebas_no_respuesta_sensibilidad_srs.csv"),check.names=FALSE)
joint_output<-read.csv(file.path(RES,"modelo_2024_pruebas_conjuntas.csv"),check.names=FALSE)
profiles_output<-read.csv(file.path(RES,"perfiles_conjuntos_derechos_2023.csv"),check.names=FALSE)
get_rate<-function(y,v,predictor,label){z<-rate_output[rate_output$anio==y & rate_output$variable==v & rate_output$predictor==predictor & rate_output$nivel_predictor_label==label,,drop=FALSE];if(nrow(z))z$pct_evento[1] else NA_real_}
get_padj<-function(y,v,predictor){z<-test_output[test_output$anio==y & test_output$variable==v & test_output$predictor==predictor,,drop=FALSE];if(nrow(z))z$p_holm_familia[1] else NA_real_}
get_joint_p<-function(predictor){z<-joint_output[joint_output$predictor==predictor,,drop=FALSE];if(nrow(z))z$p_holm_predictor[1] else NA_real_}
profile0<-profiles_output[profiles_output$perfil_acuerdo_A_B_F_H=="ABFH_0000",,drop=FALSE]
profile4<-profiles_output[profiles_output$perfil_acuerdo_A_B_F_H=="ABFH_1111",,drop=FALSE]
profile_mixed_n<-sum(profiles_output$n[!profiles_output$perfil_acuerdo_A_B_F_H%in%c("ABFH_0000","ABFH_1111")])
profile_mixed_pct<-100*profile_mixed_n/profiles_output$n_complete_cases[1]
male24<-get_rate(2024,"P3NOIJ.3","sexo","Hombre");female24<-get_rate(2024,"P3NOIJ.3","sexo","Mujer")
sex24coef<-model_coefs[model_coefs$termino=="sexoMujer",,drop=FALSE]
others24coef<-model_coefs[model_coefs$termino=="otros_grupos_rechazados",,drop=FALSE]
geo24_rates<-rate_output[rate_output$anio==2024 & rate_output$variable=="P3NOIJ.3" & rate_output$predictor=="territorio" & rate_output$n>=30,,drop=FALSE]
geo24_min<-geo24_rates[which.min(geo24_rates$pct_evento),,drop=FALSE]
geo24_max<-geo24_rates[which.max(geo24_rates$pct_evento),,drop=FALSE]
parent_nr_sex<-nr_output[nr_output$anio==2023 & nr_output$variable=="P37WVSCS.H" & nr_output$predictor=="sexo",,drop=FALSE]
parent_nr_age<-nr_output[nr_output$anio==2023 & nr_output$variable=="P37WVSCS.H" & nr_output$predictor=="edad",,drop=FALSE]
parent_m_nr<-parent_nr_sex[parent_nr_sex$nivel_predictor_label=="Hombre",,drop=FALSE]
parent_w_nr<-parent_nr_sex[parent_nr_sex$nivel_predictor_label=="Mujer",,drop=FALSE]
parent_age_15<-parent_nr_age[parent_nr_age$nivel_predictor_label=="15–29",,drop=FALSE]
parent_age_45<-parent_nr_age[parent_nr_age$nivel_predictor_label=="45–59",,drop=FALSE]
parent_nr_sex_test<-nr_test_output[nr_test_output$anio==2023 & nr_test_output$variable=="P37WVSCS.H" & nr_test_output$predictor=="sexo",,drop=FALSE]
parent_nr_age_test<-nr_test_output[nr_test_output$anio==2023 & nr_test_output$variable=="P37WVSCS.H" & nr_test_output$predictor=="edad",,drop=FALSE]
geo23_test<-test_output[test_output$anio==2023 & test_output$variable=="P37CSN.F" & test_output$predictor=="territorio",,drop=FALSE]
geo24_test<-test_output[test_output$anio==2024 & test_output$variable=="P3NOIJ.3" & test_output$predictor=="territorio",,drop=FALSE]
sex23_mar_m<-get_rate(2023,"P37CSN.B","sexo","Hombre");sex23_mar_w<-get_rate(2023,"P37CSN.B","sexo","Mujer")
sex23_parent_m<-get_rate(2023,"P37WVSCS.H","sexo","Hombre");sex23_parent_w<-get_rate(2023,"P37WVSCS.H","sexo","Mujer")
age23_adopt_y<-get_rate(2023,"P37CSN.A","edad","15–29");age23_adopt_old<-get_rate(2023,"P37CSN.A","edad","45–59")
age23_mar_y<-get_rate(2023,"P37CSN.B","edad","15–29");age23_mar_old<-get_rate(2023,"P37CSN.B","edad","60+")
age23_parent_y<-get_rate(2023,"P37WVSCS.H","edad","15–29");age23_parent_old<-get_rate(2023,"P37WVSCS.H","edad","60+")
docs_q_n<-sum(doc_matrix$cuestionario_disponible);docs_cb_n<-sum(doc_matrix$libro_codigos_disponible)
dimtxt<-paste0("N completo=",right_dim$n_complete,"; alpha exploratorio=",fmt(right_dim$alpha_cronbach_exploratorio,2),
  "; proporción del primer componente=",fmt(right_dim$varianza_componente_1_pct,1),"%.")
ordinal_sig<-multinom_joint[multinom_joint$p_holm_24_testes<.05,,drop=FALSE]
ordinal_sig_text<-if(nrow(ordinal_sig))paste(paste0(ordinal_sig$variable,"/",ordinal_sig$predictor," (p Holm=",formatC(ordinal_sig$p_holm_24_testes,format="e",digits=2),")"),collapse="; ") else "ningún predictor"
ordinal_po_text<-if(nrow(ordinal_diag))paste(paste0(ordinal_diag$variable," p Holm=",fmt(ordinal_diag$p_relajacion_PO_holm_4_modelos,3)),collapse="; ") else "diagnóstico no generado"
nonlinearity_text<-if(nrow(nonlinearity_tests))paste(paste0(nonlinearity_tests$variable," p Holm=",fmt(nonlinearity_tests$p_holm_2_pruebas,3)),collapse="; ") else "no generado"
claims <- data.frame(
  afirmacion=c(
    "En 2023 la aprobación observada varía según el ámbito del derecho.",
    "La opinión individual en 2023 no se reduce a aprobación o rechazo uniforme de los cuatro derechos.",
    "La distribución de justificabilidad moral se desplaza hacia respuestas más permisivas entre 2002 y 2008.",
    "En 2024 la distancia social observada difiere por sexo registrado y mantiene asociación ajustada.",
    "En 2024 la distancia social se asocia con rechazo de otros grupos, incluso en el modelo ajustado.",
    "El departamento ofrece diferencias claras y estables en todas las medidas directas.",
    "El índice único de tolerancia para las 23 oleadas está validado.",
    "Los tamaños de microdato de 2000 y 2001 coinciden con las fichas técnicas."),
  estado_evidencia=c("respaldada descriptivamente; contraste pareado SRS de sensibilidad",
    "respaldada para casos completos; no implica perfiles latentes estables",
    "respaldada descriptivamente; pruebas entre cortes bajo SRS",
    "respaldada como asociación observada/modelada; inferencia de diseño incompleta",
    "respaldada como asociación modelada; no causal",
    "no resuelta como patrón general; señal puntual en 2023 y no en 2024",
    "no; diagnóstico exploratorio insuficiente para validación ordinal",
    "contradicha por auditoría de archivo frente a ficha"),
  resultado=c(
    paste0("Matrimonio ",fmt(pick(2023,"derechos_2023")$pct_objetivo_valido[pick(2023,"derechos_2023")$variable=="P37CSN.B"]),"%; reconocimiento documental ",fmt(pick(2023,"derechos_2023")$pct_objetivo_valido[pick(2023,"derechos_2023")$variable=="P37CSN.F"]),"%; parentalidad ",fmt(pick(2023,"derechos_2023")$pct_objetivo_valido[pick(2023,"derechos_2023")$variable=="P37WVSCS.H"]),"%; adopción ",fmt(pick(2023,"derechos_2023")$pct_objetivo_valido[pick(2023,"derechos_2023")$variable=="P37CSN.A"]),"%"),
    paste0("1.009 completos; ",fmt(profile0$pct_complete_cases),"% rechazo en los cuatro, ",fmt(profile4$pct_complete_cases),"% acuerdo en los cuatro, ",fmt(profile_mixed_pct),"% mixtos"),
    paste0("Proporción ponderada 1–4: ",fmt(just_rows$pct_1a4_ponderado[just_rows$anio==2002]),"% en 2002 y ",fmt(just_rows$pct_1a4_ponderado[just_rows$anio==2008]),"% en 2008; medias ponderadas ",fmt(just_rows$media_ponderada[just_rows$anio==2002],2)," y ",fmt(just_rows$media_ponderada[just_rows$anio==2008],2)),
    paste0("Hombres ",fmt(male24),"%, mujeres ",fmt(female24),"%; OR mujeres/hombres ",fmt(sex24coef$OR,2)," (IC95 modelo ",fmt(sex24coef$OR_ic95_inf,2),"–",fmt(sex24coef$OR_ic95_sup,2),")"),
    paste0("Por grupo adicional rechazado, OR ",fmt(others24coef$OR,2)," (IC95 modelo ",fmt(others24coef$OR_ic95_inf,2),"–",fmt(others24coef$OR_ic95_sup,2),")"),
    paste0("2023 reconocimiento documental por territorio p Holm SRS=",fmt(geo23_test$p_holm_familia,3),"; 2024 distancia social p Holm SRS=",fmt(geo24_test$p_holm_familia,3)),
    paste0("Alpha exploratorio=",fmt(right_dim$alpha_cronbach_exploratorio,2)," y primer componente=",fmt(right_dim$varianza_componente_1_pct,1),"%; no se ajustó CFA ordinal"),
    "2000: microdato 1.080 frente a ficha 1.000. 2001: microdato 1.075 frente a ficha 1.080."),
  fuente_resultados=c("resumen_indicadores_directos.csv; comparaciones_pareadas_derechos_2023.csv",
    "perfiles_conjuntos_derechos_2023.csv",
    "serie_justificacion_2002_2008.csv; pruebas_serie_justificacion_sensibilidad.csv",
    "tasas_objetivo_por_perfil.csv; modelo_2024_coeficientes.csv; modelo_2024_pruebas_conjuntas.csv",
    "modelo_2024_coeficientes.csv; modelo_2024_pruebas_conjuntas.csv",
    "tasas_objetivo_por_perfil.csv; pruebas_cruces_sensibilidad_srs.csv",
    "diagnostico_dimension_comun_2023.csv",
    "auditoria_n_microdato_vs_documentacion.csv; registro_discrepancias.csv"),
  denominador=c("N válido 1.050–1.168 según ítem; pares válidos por comparación",
    "1.009 casos completos de 1.200 entrevistados",
    "N válido 1.109 en 2002, 999 en 2004 y 1.052 en 2008",
    paste0("1.026 válidos en 2024; modelo con ",model_summary$n_muestra," casos completos"),
    paste0(model_summary$n_muestra," casos completos; ",model_summary$eventos," eventos"),
    "Departamentos con tamaños desiguales y celdas pequeñas; cifras específicas por celda",
    "1.009 respuestas completas a los cuatro ítems",
    "23 microdatos nacionales frente a fichas técnicas consultadas"),
  incertidumbre=c("Contrastes pareados p SRS con Holm; sin varianza oficial completa",
    "Describe quienes contestaron los cuatro; 191 casos no completos",
    "Kruskal–Wallis y Wilcoxon entre muestras independientes, sensibilidad SRS",
    "Modelo no ponderado con IC Wald; diseño completo no disponible",
    "Modelo no ponderado; conteo de rechazos exploratorio",
    "Cuotas y falta de parámetros completos del diseño",
    "Correlaciones de Spearman y alpha/PCA sobre codificación ordinal; sin CFA ordinal",
    "Las fichas no permiten conciliar versión/extracción del microdato"),
  limite_interpretativo=c("No estimar una tendencia homogénea ni una actitud general",
    "La no respuesta de parentalidad es diferencial por sexo/edad",
    "No son trayectorias de las mismas personas ni efectos causales",
    "Asociación con sexo registrado no equivale a explicación causal",
    "No validar un índice ni atribuir causalidad",
    "No afirmar diferencias poblacionales departamentales concluyentes",
    "No construir puntuación resumen de tolerancia",
    "No sustituir N del archivo por N de ficha; solicitar aclaración al custodio"),
  stringsAsFactors=FALSE)
claims<-rbind(claims,data.frame(
  afirmacion="Las asociaciones sociodemográficas con derechos 2023 mantienen diferencias cuando se modelan las cuatro categorías ordinales.",
  estado_evidencia="respaldada para edad en adopción y para sexo/edad en matrimonio; no uniforme entre derechos",
  resultado=paste0(ordinal_sig_text,". Con modelo ordinal de odds proporcionales, se comparan las mismas familias de predictores; diagnóstico Holm de odds proporcionales: ",ordinal_po_text,"."),
  fuente_resultados="modelos_multinomiales_derechos_2023_pruebas_conjuntas.csv; diagnosticos_proporcionalidad_odds_2023.csv; resumen_modelos_ordinales_derechos_2023.csv",
  denominador="Casos completos por ítem, N=798–881",
  incertidumbre="Pruebas SRS de razón de verosimilitud, ajuste Holm en 24 pruebas",
  limite_interpretativo="Modelos no ponderados y sin diseño completo; asociaciones no causales; parentesco/identidad documental sin asociación ajustada concluyente",
  stringsAsFactors=FALSE))
write_csv(claims,"matriz_afirmaciones.csv")
report<-c(
"# Dossier analítico exhaustivo de Latinobarómetro Bolivia, 1996–2024",
"",
"**Estado:** análisis reproducible de 23 cortes transversales repetidos. No se editó el artículo ni ningún archivo LaTeX. Las bases originales se preservaron.",
"",
"## Alcance y regla de evidencia",
"",
paste0("Se procesaron ",length(YEARS)," oleadas y ",sum(wave_audit$filas_leidas)," registros. Son muestras transversales independientes, no seguimiento de las mismas personas. "),
"El archivo `matriz_cobertura_constructos.csv` identifica qué años midieron directamente opiniones sobre homosexualidad, derechos o distancia social. Las demás oleadas sirven para describir contenido general del instrumento y no se les atribuye una opinión LGBTIQ+ no preguntada.",
"",
"La documentación disponible no permite reconstruir, para cada año, probabilidades individuales de selección, PSU, estratos y todas las etapas. Varias fichas describen cuotas en la última etapa. Por eso los conteos y proporciones observados son el resultado principal; intervalos y pruebas SRS aparecen como sensibilidad exploratoria, nunca como errores estándar plenamente design-based. La ponderación del CSV se presenta por separado y no sustituye diseño muestral.",
"",
"## Auditoría de las 23 oleadas",
"",
paste0("N total en microdatos = ",format(sum(wave_audit$filas_leidas),big.mark=","),". La coincidencia filas/columnas frente al inventario previo fue ",sum(wave_audit$filas_coinciden,na.rm=TRUE),"/23 en filas y ",sum(wave_audit$columnas_coinciden,na.rm=TRUE),"/23 en columnas. "),
"Las salidas `auditoria_oleadas.csv`, `inventario_variables_todas_oleadas.csv` y `codigos_candidatos_especiales.csv` documentan estructura, valores perdidos, duplicados candidatos y códigos raros sin etiquetarlos automáticamente como no respuesta.",
"",
"Aparecen dos filas con `NUMENTRE` repetido en 2002 y otras dos en 2006; no son filas idénticas. Se conservan sin deduplicación, ya que corregirlas requiere el archivo de origen o respuesta del custodio. En 1996 no se identificó `NUMENTRE` ni `NUMINVES` inequívoco. La auditoría de tamaños detectó una discrepancia mayor en 2000, cuyo CSV tiene 1.080 filas y código de país 68 en todas, frente a 1.000 casos en la ficha; en 2001 el CSV tiene 1.075 frente a 1.080 en la ficha. Se exponen en `auditoria_n_microdato_vs_documentacion.csv` y `registro_discrepancias.csv`, sin ajustar los conteos del archivo.",
"En 2000 no hay columna de ponderación en el CSV. Los pesos candidatos son constantes 1 en la mayoría de las oleadas y variables en 1998 y 2002–2005. La ficha 2016 indica que el ponderador no aplica y su WT constante vale 1.",
"",
paste0("La matriz `matriz_documentacion_local.csv` lista cuestionarios y libros de códigos encontrados en el proyecto. Hay cuestionario local para ",docs_q_n," de 23 oleadas y codebook local para ",docs_cb_n,". Para 2015 se usó el codebook oficial en línea, que deberá archivarse antes del cierre editorial; 2009 no tiene cuestionario ni codebook local identificado. Las brechas documentales no se rellenaron por analogía."),
"",
"## Cobertura de mediciones directas",
"",
"Hay nueve oleadas con una o más preguntas directas: 1998, 2002, 2004, 2006, 2008, 2010, 2015, 2023 y 2024. Las otras catorce no contienen una medición directa localizada en los cuestionarios disponibles. La matriz de cobertura separa las cinco familias de medición.",
"",
"| Familia | Oleadas | Interpretación permitida |",
"|---|---|---|",
"| Distancia social | 1998, 2024 | Mención de homosexuales entre grupos no deseados como vecinos; las baterías no son idénticas |",
"| Justificación moral | 2002, 2004, 2008 | Escala ordinal 1–10, donde 1 nunca se justifica y 10 siempre se justifica |",
"| Saliencia de discriminación | 2006, 2008 | Selección única de una categoría; no mide experiencia propia ni incidencia |",
"| Matrimonio igualitario | 2010, 2015, 2023 | Escala de acuerdo de cuatro categorías; cortes separados |",
"| Cuatro ámbitos de derechos | 2023 | Adopción, matrimonio, reconocimiento documental y parentalidad, mismas personas |",
"",
"Las otras oleadas no se imputaron ni usaron para crear una tendencia. La cobertura completa de variables, documentación y comparabilidad está en los CSV del dossier.",
"",
"## Resultados descriptivos",
"",
"### Matrimonio entre personas del mismo sexo",
"",
"| Año | Acuerdo 1–2 (no ponderado) | Conteo / N válido | No respuesta | IC95 SRS de sensibilidad |",
"|---:|---:|---:|---:|---:|",
vapply(seq_len(nrow(mar_rows)),function(i)paste0("| ",mar_rows$anio[i]," | ",fmt(mar_rows$pct_objetivo_valido[i]),"% | ",mar_rows$conteo_objetivo[i]," / ",mar_rows$n_valido[i]," | ",fmt(mar_rows$pct_no_valido[i]),"% | ",fmt(mar_rows$ic95_srs_sens_inf[i]),"–",fmt(mar_rows$ic95_srs_sens_sup[i]),"% |"),""),
"",
"Las tres oleadas comparten el ámbito y una escala de cuatro categorías, aunque la redacción de 2010 dice ‘matrimonio entre homosexuales’ y la de 2015/2023 ‘personas del mismo sexo’. La no respuesta también se codifica de forma distinta. La trayectoria descriptiva no es lineal. Los contrastes SRS entre años y su corrección Holm se publican en `comparaciones_matrimonio_sensibilidad_srs.csv`; no son inferencia de diseño ni seguimiento individual.",
"",
"### Justificación moral de la homosexualidad",
"",
"| Año | Media ponderada | Mediana | Respuestas 1–4 ponderadas | Punto 5 ponderado | Respuestas 6–10 ponderadas | N válido |",
"|---:|---:|---:|---:|---:|---:|---:|",
vapply(seq_len(nrow(just_rows)),function(i)paste0("| ",just_rows$anio[i]," | ",fmt(just_rows$media_ponderada[i],2)," | ",just_rows$mediana[i]," | ",fmt(just_rows$pct_1a4_ponderado[i]),"% | ",fmt(just_rows$pct_5_ponderado[i]),"% | ",fmt(just_rows$pct_6a10_ponderado[i]),"% | ",just_rows$n_valido[i]," |"),""),
"",
"La escala mide justificabilidad moral percibida, no aprobación de derechos ni conducta. La comparación Kruskal–Wallis y pares Wilcoxon es una sensibilidad entre cortes independientes. Ver resultados `pruebas_serie_justificacion_sensibilidad.csv` y `comparaciones_pareadas_no_mismas_personas_justificacion.csv`.",
"",
"### Diferencias entre cuatro ámbitos en 2023",
"",
"| Variable | Acuerdo 1–2 (no ponderado) | Conteo / N válido | No respuesta | IC95 SRS de sensibilidad |",
"|---|---:|---:|---:|---:|",
vapply(seq_len(nrow(rights_rows)),function(i)paste0("| ",rights_rows$variable[i]," | ",fmt(rights_rows$pct_objetivo_valido[i]),"% | ",rights_rows$conteo_objetivo[i]," / ",rights_rows$n_valido[i]," | ",fmt(rights_rows$pct_no_valido[i]),"% | ",fmt(rights_rows$ic95_srs_sens_inf[i]),"–",fmt(rights_rows$ic95_srs_sens_sup[i]),"% |"),""),
"",
"Los contrastes pareados (McNemar sobre acuerdo/desacuerdo y Wilcoxon sobre categorías ordinales) se basan en las mismas personas con respuesta válida en ambos ítems. Los seis contrastes, celdas discordantes y p ajustadas están en `comparaciones_pareadas_derechos_2023.csv`. Los perfiles binarios de respuesta conjunta de 16 combinaciones están en `perfiles_conjuntos_derechos_2023.csv`.",
"",
paste0("El diagnóstico exploratorio de dimensión común dio ",dimtxt," Usa las cuatro respuestas ordinales como números para un diagnóstico inicial y no es un CFA ordinal; no se crea un índice. Correlaciones y diagnóstico están en los archivos `correlaciones_spearman_derechos_2023.csv` y `diagnostico_dimension_comun_2023.csv`.") ,
"",
paste0("Entre los 1.009 casos que contestaron los cuatro ítems, ",profile0$n," (",fmt(profile0$pct_complete_cases),"%) rechazaron los cuatro y ",profile4$n," (",fmt(profile4$pct_complete_cases),"%) acordaron con los cuatro. Los ",profile_mixed_n," restantes (",fmt(profile_mixed_pct),"%) combinaron acuerdo y desacuerdo según el derecho. La distribución de los 16 perfiles está en `perfiles_conjuntos_derechos_2023.csv`. Esta heterogeneidad dentro de la misma persona es incompatible con describir la respuesta como una única postura uniforme."),
"",
paste0("Los contrastes pareados muestran que el acuerdo con reconocimiento documental supera al de adopción en ",fmt(abs(rights_pairs$diferencia_acuerdo_pp[rights_pairs$variable_a=="P37CSN.A" & rights_pairs$variable_b=="P37CSN.F"]))," puntos y al de matrimonio en ",fmt(abs(rights_pairs$diferencia_acuerdo_pp[rights_pairs$variable_a=="P37CSN.B" & rights_pairs$variable_b=="P37CSN.F"]))," puntos; ambos contrastes McNemar mantienen p<0,001 tras Holm. Parentalidad también supera adopción y matrimonio, en ",fmt(abs(rights_pairs$diferencia_acuerdo_pp[rights_pairs$variable_a=="P37CSN.A" & rights_pairs$variable_b=="P37WVSCS.H"]))," y ",fmt(abs(rights_pairs$diferencia_acuerdo_pp[rights_pairs$variable_a=="P37CSN.B" & rights_pairs$variable_b=="P37WVSCS.H"]))," puntos, respectivamente. Matrimonio y adopción no muestran diferencia pareada clara. Estos contrastes cuantifican aceptación diferenciada por ámbito, bajo sensibilidad SRS."),
"",
"### Distancia social y saliencia pública",
"",
paste0("En 1998, ",neighbor98$conteo_objetivo," de ",neighbor98$n_valido," respuestas válidas (",fmt(neighbor98$pct_objetivo_valido),"%; IC95 SRS ",fmt(neighbor98$ic95_srs_sens_inf),"–",fmt(neighbor98$ic95_srs_sens_sup),"%) mencionaron homosexuales como vecinos no deseados. En 2024, ",neighbor24$conteo_objetivo," de ",neighbor24$n_valido," respuestas válidas (",fmt(neighbor24$pct_objetivo_valido),"%; IC95 SRS ",fmt(neighbor24$ic95_srs_sens_inf),"–",fmt(neighbor24$ic95_srs_sens_sup),"%) lo hicieron. La sensibilidad parcial con REG como estrato y COMDIST como conglomerado en 2024 da IC95 ",fmt(design_sens$ic95_inf[design_sens$anio==2024]),"–",fmt(design_sens$ic95_sup[design_sens$anio==2024]),"%. El contraste entre 1998 y 2024 no se presenta como cambio temporal homogéneo porque la batería y el tratamiento de no respuesta difieren."),
"",
paste0("En 2006, ",salience06$conteo_objetivo," de ",salience06$n_valido," respuestas sustantivas (",fmt(salience06$pct_objetivo_valido),"%; IC95 SRS ",fmt(salience06$ic95_srs_sens_inf),"–",fmt(salience06$ic95_srs_sens_sup),"%) eligieron la opción ‘por ser homosexual’ en una pregunta de respuesta única sobre trato desigual. En 2008, ",salience08$conteo_objetivo," de ",salience08$n_valido," respuestas sustantivas (",fmt(salience08$pct_objetivo_valido),"%; IC95 SRS ",fmt(salience08$ic95_srs_sens_inf),"–",fmt(salience08$ic95_srs_sens_sup),"%) identificaron a homosexuales como el grupo más discriminado. Son constructos de saliencia diferentes y no estiman la frecuencia de discriminación vivida."),
"",
"La tabla `distribucion_completa_respuestas.csv` presenta todas las categorías crudas, incluyendo códigos especiales, con conteos y porcentajes. Las categorías sustantivas incluyen IC95 Wilson bajo sensibilidad SRS; los códigos especiales quedan visibles y fuera de esos intervalos. Los resultados descriptivos territoriales están incluidos en los cruces; los códigos `REG` se etiquetan con el codebook oficial y se advierte sobre celdas pequeñas.",
"",
"## Asociaciones, modelos y pruebas",
"",
"`cruces_descriptivos_completos.csv` contiene tablas completas para sexo y edad en las oleadas con medición directa, más ideología, religión, práctica religiosa, ingreso subjetivo, clase, educación y territorio para 2023/2024 cuando esos campos están disponibles. `auditoria_covariables_cruces.csv` conserva el nombre y la regla de cada predictor. `pruebas_cruces_sensibilidad_srs.csv` registra estadístico, p, mínimo esperado y prueba utilizada. Los p-values se ajustan por Holm dentro de cada familia año-constructo. Para celdas esperadas pequeñas se marca la limitación o se usa Fisher en tablas 2×2.",
"",
paste0("El modelo logístico 2024 estima asociaciones entre mención de distancia social y sexo, edad, educación, práctica religiosa, ideología, ingreso/clase y conteo de otros grupos excluidos. El conteo se construye excluyendo el grupo objetivo y la categoría de sustancias/alcohol, para evitar parte-todo y la categoría de altísima prevalencia. Es un modelo no ponderado de casos completos, con intervalo Wald/modelo bajo supuestos SRS y no causal. Se compararon especificaciones lineales con splines naturales para edad e ideología; las p ajustadas de no linealidad son ",nonlinearity_text,". Coeficientes y diagnósticos están en `modelo_2024_coeficientes.csv`, `modelo_2024_pruebas_conjuntas.csv`, `modelo_2024_sensibilidad_no_linealidad.csv` y `modelo_2024_resumen.csv`."),
"",
"### Modelos ordinales de derechos en 2023",
"",
paste0("Además del cruce dicotómico, se estimaron modelos ordinales logísticos para cada pregunta en los casos completos de sexo, edad, educación, práctica religiosa, ideología e ingreso (N entre ",min(ordinal_summary$n)," y ",max(ordinal_summary$n),"). El orden del resultado va de desacuerdo fuerte a acuerdo fuerte. La prueba de odds proporcionales, contrastada con un modelo multinomial y ajustada por Holm para los cuatro ítems, no rechaza el supuesto en ninguno (p ajustadas: ",ordinal_po_text,"). Esto no demuestra que el supuesto sea correcto. Como sensibilidad más flexible, las pruebas multinomiales ajustadas por Holm para 24 asociaciones identifican edad en adopción y sexo y edad en matrimonio (",ordinal_sig_text,"). No aparece una asociación ajustada estable para reconocimiento documental ni parentalidad; por eso las diferencias bivariadas de parentalidad por sexo/edad se interpretan como sugestivas, no robustas al ajuste. Los coeficientes, pruebas conjuntas, diagnósticos y tamaños completos están en `modelos_ordinales_derechos_2023_coeficientes.csv`, `modelos_ordinales_derechos_2023_pruebas_conjuntas.csv`, `modelos_multinomiales_derechos_2023_pruebas_conjuntas.csv`, `diagnosticos_proporcionalidad_odds_2023.csv` y `resumen_modelos_ordinales_derechos_2023.csv`. Todas son sensibilidades SRS sin diseño completo."),
"",
"### Resultados interpretables de los cruces",
"",
paste0("En 2023, el acuerdo con matrimonio es ",fmt(sex23_mar_w),"% entre mujeres y ",fmt(sex23_mar_m),"% entre hombres; para la afirmación sobre parentalidad es ",fmt(sex23_parent_w),"% y ",fmt(sex23_parent_m),"%. Las pruebas SRS ajustadas por Holm identifican diferencias por sexo registrado en matrimonio (p ajustada <0,001) y parentalidad (p ajustada <0,01), no en todos los derechos. Por edad, las diferencias también se concentran en adopción (",fmt(age23_adopt_y),"% en 15–29 frente a ",fmt(age23_adopt_old),"% en 45–59), matrimonio (",fmt(age23_mar_y),"% en 15–29 frente a ",fmt(age23_mar_old),"% en 60+) y parentalidad (",fmt(age23_parent_y),"% en 15–29 frente a ",fmt(age23_parent_old),"% en 60+). Son asociaciones entre grupos de una muestra de cuotas; no efectos causales ni estimaciones design-completas."),
"",
paste0("En 2024, la mención de homosexuales como vecinos no deseados alcanza ",fmt(male24),"% entre hombres y ",fmt(female24),"% entre mujeres. El modelo ajustado estima para mujeres OR=",fmt(sex24coef$OR,2)," (IC95 modelo ",fmt(sex24coef$OR_ic95_inf,2),"–",fmt(sex24coef$OR_ic95_sup,2),"), con p de Wald SRS=",formatC(sex24coef$p_srs,format="e",digits=2),"; la prueba conjunta del predictor da p Holm=",formatC(get_joint_p("sexo"),format="e",digits=2),". La relación persiste al ajustar covariables observadas. El resultado describe sexo registrado, no identidad de género."),
"",
paste0("El conteo de otros grupos rechazados se asocia positivamente con distancia social en el modelo 2024. Por cada grupo adicional, OR=",fmt(others24coef$OR,2)," (IC95 modelo ",fmt(others24coef$OR_ic95_inf,2),"–",fmt(others24coef$OR_ic95_sup,2),"); la prueba conjunta del predictor mantiene p Holm=",formatC(get_joint_p("otros_grupos_rechazados"),format="e",digits=2),". El patrón es compatible con una dimensión más amplia de exclusión social, sin establecer causalidad ni validar un índice."),
"",
paste0("Por departamento, en 2024 las proporciones descriptivas con n≥30 van de ",fmt(geo24_min$pct_evento),"% en ",geo24_min$nivel_predictor_label," (n=",geo24_min$n,") a ",fmt(geo24_max$pct_evento),"% en ",geo24_max$nivel_predictor_label," (n=",geo24_max$n,"). La prueba global de territorio no se sostiene tras Holm (p ajustada=",fmt(geo24_test$p_holm_familia,3),") y hay celdas pequeñas. En 2023 aparece una asociación territorial SRS con reconocimiento documental (p Holm=",fmt(geo23_test$p_holm_familia,3),"), también sujeta a cuotas y a la reconstrucción incompleta del diseño. El contraste departamental queda como hallazgo descriptivo a validar, no como conclusión inferencial."),
"",
"## No respuesta y sensibilidad",
"",
"Para cada pregunta con resultado dicotómico se informa no respuesta y límites extremos del porcentaje objetivo sobre N total, asignando hipotéticamente todas las respuestas no válidas a no-evento o evento. Para las escalas ordinales de justificabilidad no se impone un punto de corte. `no_respuesta_y_limites_extremos.csv` muestra medias observadas y escenarios en que todas las respuestas faltantes equivaldrían al extremo 1 o al extremo 10. No se imputa opinión. `no_respuesta_por_perfil.csv` permite identificar perfiles con no respuesta diferencial. En 2023 los ítems de derechos tienen no respuesta distinta, especialmente parentalidad; por ello se muestran tanto denominadores por ítem como el tamaño completo de las comparaciones pareadas.",
"",
paste0("La no respuesta en parentalidad alcanza 150/1.200 (12,5%), frente a 2,7% en adopción, 2,8% en matrimonio y 4,8% en reconocimiento documental. En el ítem de parentalidad fue ",fmt(parent_m_nr$pct_no_respuesta),"% entre hombres y ",fmt(parent_w_nr$pct_no_respuesta),"% entre mujeres, y ",fmt(parent_age_15$pct_no_respuesta),"% en 15–29 frente a ",fmt(parent_age_45$pct_no_respuesta),"% en 45–59. Las diferencias por sexo y edad se mantienen en pruebas SRS con Holm dentro del ítem (p=",fmt(parent_nr_sex_test$p_holm_item,3)," y ",fmt(parent_nr_age_test$p_holm_item,3),"). Los porcentajes válidos de parentalidad podrían, por ello, no representar sin sesgo a quienes contestaron menos; no se imputa su posición."),
"",
"La sensibilidad `sensibilidad_diseno_parcial_2023_2024.csv` usa `REG` como estrato y `COMDIST` como conglomerado si el paquete `survey` está disponible. No reconstruye selección por etapas ni cuotas, por lo que no debe citarse como intervalo oficial de diseño.",
"",
"## Discrepancias verificadas y límites de afirmación",
"",
"1. El microdato 2023 usa -5 en las cuatro preguntas de derechos donde cuestionario y codebook indican 0 para NS/NR. Se excluye -5 del denominador sustantivo y se preserva el código en los resultados crudos.",
"2. En 2023, la edad observada en la muestra boliviana va de 18 a 84 años, mientras la etiqueta agrupada REEDAD del codebook empieza en 16–25. No se atribuye la diferencia a errores de entrevista; se documenta para cotejar con la ficha país.",
"3. Los ponderadores candidatos varían solo en algunas bases. En 2000 no hay campo de peso; en 2016 WT=1 y la documentación indica que no aplica. No se asume que un campo llamado WT garantice la reconstrucción del diseño.",
"4. Las fichas de 2024 describen muestreo de cuatro etapas con cuotas en la última. Las cuotas restringen el alcance de la inferencia probabilística convencional.",
"5. La variable P46STM de 2006 y P68ST de 2008 pregunta qué se percibe públicamente, no si el encuestado o una persona LGBTIQ+ vivió discriminación.",
"6. No se infiere tamaño de población LGBTIQ+, prevalencia de violencia, experiencia directa, causa de actitudes ni efecto de medios de comunicación.",
"",
"## Estado de cierre metodológico",
"",
"La auditoría de integridad cubre las 23 bases disponibles y verifica filas y columnas contra el inventario; las familias de preguntas directas, sus códigos de respuesta y denominadores están trazados en el diccionario y archivos de cobertura. Se ejecutaron distribuciones, pruebas pareadas, cruces exhaustivos para los predictores preseleccionados, un barrido exploratorio con ajuste Holm, modelos ordinales/multinomiales para derechos 2023 y una logística para distancia social 2024. El código regenera tablas y figuras desde los CSV originales.",
"",
"La investigación todavía no alcanza un cierre inferencial plenamente defendible. Hay 2000 y 2001 con tamaños de microdato distintos de sus fichas; no se deben tratar como poblaciones muestrales resueltas. Para ninguna oleada se reconstruyó con certeza todo el diseño oficial a partir de los archivos disponibles. El codebook 2015 aún debe archivarse localmente, 2009 carece de documentación local identificada y la medición común de derechos 2023 no cuenta con una CFA ordinal. En consecuencia, los modelos y pruebas se reportan como sensibilidades SRS, no como estimaciones de diseño oficial. Estas tareas pendientes se detallan en `registro_discrepancias.csv`, `matriz_documentacion_local.csv` y `auditoria_diseno_y_fuentes.csv`.",
"",
"## Argumentos sostenibles para el artículo",
"",
"- Los datos no justifican un índice general de ‘tolerancia’ para todas las oleadas. Sí justifican describir familias de preguntas separadas y mostrar perfiles de respuesta por ámbito en 2023.",
"- La aceptación de matrimonio presenta variación no lineal en los cortes 2010, 2015 y 2023. La afirmación debe limitarse a las respuestas observadas en esas muestras hasta resolver la incertidumbre de diseño.",
"- En 2023 puede evaluarse empíricamente si el acuerdo cambia según el derecho. Esta comparación dentro de personas es el núcleo menos intuitivo y más fuerte del conjunto.",
"- La baja selección de homosexualidad en respuestas únicas de saliencia (2006/2008) no demuestra baja discriminación; señala que el tema aparece con baja frecuencia relativa frente a otras categorías en esas preguntas.",
"- La distancia social en 2024 puede examinarse asociativamente por perfil y en relación con una pauta más amplia de rechazo, sin interpretación causal.",
"",
"## Archivos de salida y reproducción",
"",
"El dossier es regenerable desde los CSV originales. Todos los CSV resultantes están en `resultados/`, las figuras en `figuras/`, y la guía de ejecución en `README.md`. Ejecutar desde la raíz del proyecto:",
"",
"```bash",
"Rscript Latinobarometro_historico_Bolivia/analisis_exhaustivo/analisis_exhaustivo.R",
"```",
"",
"Las tablas que más conviene abrir para discutir son `resumen_indicadores_directos.csv`, `distribucion_completa_respuestas.csv`, `cruces_descriptivos_completos.csv`, `comparaciones_pareadas_derechos_2023.csv`, `perfiles_conjuntos_derechos_2023.csv`, `modelos_multinomiales_derechos_2023_pruebas_conjuntas.csv`, `modelo_2024_coeficientes.csv`, `auditoria_diseno_y_fuentes.csv`, `matriz_afirmaciones.csv` y `registro_discrepancias.csv`."
)
writeLines(report,file.path(OUT,"DOSSIER_ANALITICO.md"),useBytes=TRUE)

message("Análisis terminado. Resultados en: ", normalizePath(OUT))
