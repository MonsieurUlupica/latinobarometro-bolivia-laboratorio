# Exploratory, reproducible analysis of Bolivia Latinobarometro waves.
# Run from the research project root:
#   Rscript Latinobarometro_historico_Bolivia/analisis_exploratorio/analisis_exploratorio.R
# Raw survey files are read in place and never modified.

options(stringsAsFactors = FALSE, scipen = 999)

ROOT <- "Latinobarometro_historico_Bolivia"
OUT <- file.path(ROOT, "analisis_exploratorio", "resultados")
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)

csv_for <- function(year) {
  files <- list.files(file.path(ROOT, "datos_extraidos", as.character(year)),
                      pattern = "\\.csv$", full.names = TRUE)
  if (length(files) != 1L) stop("Expected exactly one CSV for ", year)
  # Several official country CSVs have a dangling final semicolon on every data
  # row (but not in the header); remove only that empty terminal field so R
  # doesn't mistake the first data field for row names.
  lines <- readLines(files, encoding = "UTF-8")
  lines <- sub("^\\ufeff", "", lines)
  lines <- sub(";$", "", lines)
  read.csv(text = paste(lines, collapse = "\n"), sep = ";", dec = ".",
           check.names = FALSE, na.strings = c("", "NA"))
}

column <- function(d, name) {
  i <- match(tolower(name), tolower(names(d)))
  if (is.na(i)) stop("Missing column: ", name, "; available: ", paste(names(d), collapse = ", "))
  suppressWarnings(as.numeric(as.character(d[[i]])))
}

weight_for <- function(d) {
  wname <- if ("pondera" %in% tolower(names(d))) "pondera" else "wt"
  w <- column(d, wname)
  if (any(!is.finite(w) | w <= 0)) stop("Invalid weights in ", wname)
  w
}

wilson <- function(k, n, z = 1.959963984540054) {
  if (n == 0) return(c(NA_real_, NA_real_))
  p <- k / n
  den <- 1 + z^2 / n
  mid <- (p + z^2 / (2 * n)) / den
  half <- z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2)) / den
  c(max(0, mid - half), min(1, mid + half))
}

row_for_binary <- function(indicator, year, item, x, w, valid, positive,
                           denominator_note = "válidos") {
  n_all <- length(x)
  k_all <- sum(valid & positive, na.rm = TRUE)
  n_valid <- sum(valid, na.rm = TRUE)
  w_valid <- sum(w[valid], na.rm = TRUE)
  w_pos <- sum(w[valid & positive], na.rm = TRUE)
  ci <- wilson(k_all, n_valid)
  data.frame(
    indicador = indicator, anio = year, item = item,
    n_total = n_all, n_valido = n_valid, no_respuesta_pct = 100 * (n_all - n_valid) / n_all,
    positivos_n = k_all, positivos_pct_validos = 100 * k_all / n_valid,
    positivos_pct_total = 100 * k_all / n_all,
    pct_ponderado_validos = 100 * w_pos / w_valid,
    ic95_srs_inf = 100 * ci[1], ic95_srs_sup = 100 * ci[2],
    nota_denominador = denominator_note,
    stringsAsFactors = FALSE
  )
}

valid_scale <- function(x) x %in% 1:4
support <- function(x) x %in% 1:2

# 1) Historically repeated direct indicators. Never pool different constructs.
series <- list(
  list(year = 1998, var = "np63a", label = "No quisiera tener homosexuales como vecinos", kind = "neighbor"),
  list(year = 2002, var = "p52wvsc", label = "Justificación moral de la homosexualidad (1 nunca–10 siempre)", kind = "justification"),
  list(year = 2004, var = "p38sta", label = "Justificación moral de la homosexualidad (1 nunca–10 siempre)", kind = "justification"),
  list(year = 2008, var = "p64wvsst", label = "Justificación moral de la homosexualidad (1 nunca–10 siempre)", kind = "justification"),
  list(year = 2010, var = "p14n.g", label = "Acuerdo con matrimonio entre personas del mismo sexo", kind = "marriage"),
  list(year = 2015, var = "p69st.c", label = "Acuerdo con matrimonio entre personas del mismo sexo", kind = "marriage"),
  list(year = 2023, var = "p37csn.b", label = "Acuerdo con matrimonio entre personas del mismo sexo", kind = "marriage"),
  list(year = 2024, var = "p3noij.3", label = "Menciona homosexuales como vecinos no deseados", kind = "neighbor")
)

# Three repeated cross-sections use the same four-point agree/disagree scale
# for same-sex marriage (2010, 2015, 2023). Pairwise tests are approximate SRS.
marriage_waves <- list(
  `2010` = "p14n.g", `2015` = "p69st.c", `2023` = "p37csn.b"
)
marriage_data <- lapply(names(marriage_waves), function(y) {
  d <- csv_for(as.integer(y)); x <- column(d, marriage_waves[[y]])
  valid <- valid_scale(x)
  list(year = as.integer(y), n = sum(valid), yes = sum(support(x[valid])),
       p = mean(support(x[valid])))
})
names(marriage_data) <- names(marriage_waves)
marriage_pairs <- combn(names(marriage_data), 2, simplify = FALSE)
marriage_tests <- do.call(rbind, lapply(marriage_pairs, function(yy) {
  a <- marriage_data[[yy[1]]]; b <- marriage_data[[yy[2]]]
  diff <- a$p - b$p
  se <- sqrt(a$p * (1 - a$p) / a$n + b$p * (1 - b$p) / b$n)
  z <- diff / se
  data.frame(
    anio_a = a$year, n_a = a$n, apoyo_a_pct = 100 * a$p,
    anio_b = b$year, n_b = b$n, apoyo_b_pct = 100 * b$p,
    diferencia_pp_a_menos_b = 100 * diff,
    ic95_inf_pp = 100 * (diff - 1.96 * se), ic95_sup_pp = 100 * (diff + 1.96 * se),
    z_srs_aprox = z, p_srs_aprox = 2 * pnorm(-abs(z))
  )
}))
marriage_tests$p_holm_3 <- p.adjust(marriage_tests$p_srs_aprox, method = "holm")

indicator_rows <- list()
justification_rows <- list()
for (s in series) {
  d <- csv_for(s$year)
  x <- column(d, s$var)
  w <- weight_for(d)
  if (s$kind == "neighbor") {
    if (s$year == 1998) {
      valid <- x %in% 0:1
      pos <- x == 1
      indicator_rows[[length(indicator_rows) + 1L]] <- row_for_binary(
        "distancia_social", s$year, s$label, x, w, valid, pos,
        "respondieron menciona/no menciona"
      )
    } else {
      no_answer <- column(d, "p3noij.9") == 1
      valid <- x %in% 0:1 & !no_answer
      pos <- x == 1
      indicator_rows[[length(indicator_rows) + 1L]] <- row_for_binary(
        "distancia_social", s$year, s$label, x, w, valid, pos,
        "respondieron a la batería; además se reporta % sobre N total"
      )
    }
  } else if (s$kind == "marriage") {
    valid <- valid_scale(x)
    indicator_rows[[length(indicator_rows) + 1L]] <- row_for_binary(
      "matrimonio_igualitario", s$year, s$label, x, w, valid, support(x),
      "acuerdo = muy de acuerdo/de acuerdo; válido = categorías 1–4"
    )
  } else if (s$kind == "justification") {
    valid <- x %in% 1:10
    wv <- w[valid]
    xv <- x[valid]
    justification_rows[[length(justification_rows) + 1L]] <- data.frame(
      anio = s$year, item = s$label, n_total = length(x), n_valido = sum(valid),
      no_respuesta_pct = 100 * mean(!valid), media_ponderada = weighted.mean(xv, wv),
      mediana = median(xv), pct_1a4_ponderado = 100 * sum(wv[xv <= 4]) / sum(wv),
      pct_5_ponderado = 100 * sum(wv[xv == 5]) / sum(wv),
      pct_6a10_ponderado = 100 * sum(wv[xv >= 6]) / sum(wv),
      n_kish_aprox = sum(wv)^2 / sum(wv^2), stringsAsFactors = FALSE
    )
  }
}

# 2) All four directly relevant 2023 attitudes; same respondents, distinct policy domains.
d23 <- csv_for(2023)
vars23 <- c(adopcion = "p37csn.a", matrimonio = "p37csn.b",
            reconocimiento_genero = "p37csn.f", parentalidad = "p37wsvcs.h")
# Accommodate the exact stem printed in the CSV (WVSCS, not WSVCS).
if (!any(tolower(names(d23)) == vars23["parentalidad"])) vars23["parentalidad"] <- "p37wvscs.h"
items23 <- list(
  adopcion = "Acuerdo con adopción por parejas del mismo sexo",
  matrimonio = "Acuerdo con matrimonio entre personas del mismo sexo",
  reconocimiento_genero = "Acuerdo con reconocimiento del cambio de género en documento de identidad",
  parentalidad = "Acuerdo con que parejas homosexuales pueden ser tan buenos padres como otras"
)
for (nm in names(vars23)) {
  x <- column(d23, vars23[[nm]])
  w <- weight_for(d23)
  valid <- valid_scale(x)
  indicator_rows[[length(indicator_rows) + 1L]] <- row_for_binary(
    "opinion_derechos_2023", 2023, items23[[nm]], x, w, valid, support(x),
    "acuerdo = muy de acuerdo/de acuerdo; válido = categorías 1–4"
  )
}

# Matched-pairs comparisons (same people): support v. opposition among respondents
# who answered both questions. Holm correction applied across the six comparisons.
mcnemar_pair <- function(a_name, b_name) {
  a <- column(d23, vars23[[a_name]])
  b <- column(d23, vars23[[b_name]])
  valid <- valid_scale(a) & valid_scale(b)
  sa <- support(a[valid]); sb <- support(b[valid])
  discord_a_only <- sum(sa & !sb)
  discord_b_only <- sum(!sa & sb)
  stat <- if ((discord_a_only + discord_b_only) == 0) 0 else
    max(abs(discord_a_only - discord_b_only) - 1, 0)^2 / (discord_a_only + discord_b_only)
  p <- pchisq(stat, df = 1, lower.tail = FALSE)
  data.frame(
    item_a = items23[[a_name]], item_b = items23[[b_name]],
    n_pares_validos = sum(valid), apoyo_a_no_b = discord_a_only,
    apoyo_b_no_a = discord_b_only,
    diferencia_apoyo_pp = 100 * (mean(sa) - mean(sb)),
    mcnemar_chi2_cc = stat, p_srs_aprox = p
  )
}
pair_names <- combn(names(vars23), 2, simplify = FALSE)
paired <- do.call(rbind, lapply(pair_names, function(z) mcnemar_pair(z[1], z[2])))
paired$p_holm_6 <- p.adjust(paired$p_srs_aprox, method = "holm")

# 3) 2024 peer-group ranking and social-exclusion count, excluding homosexuals
# from the count to avoid a part-whole association.
d24 <- csv_for(2024)
homo24 <- column(d24, "p3noij.3")
noanswer24 <- column(d24, "p3noij.9") == 1
valid24 <- homo24 %in% 0:1 & !noanswer24
groups24 <- c("p3noij.1", "p3noij.2", "p3noij.3", "p3noij.4",
              "p3noij.5", "p3noij.6", "p3noij.7", "p3noij.8")
group_labels <- c("Raza/etnia distinta", "Inmigrantes/trabajadores extranjeros",
                  "Homosexuales", "Religión distinta", "Bebedores/drogadictos/alcohólicos",
                  "Parejas no casadas que viven juntas", "Idioma distinto", "Jóvenes")
rank_rows <- lapply(seq_along(groups24), function(i) {
  x <- column(d24, groups24[i])
  k <- sum(x[valid24] == 1)
  n <- sum(valid24)
  ci <- wilson(k, n)
  data.frame(grupo = group_labels[i], n_valido = n, menciona_n = k,
             menciona_pct_validos = 100 * k / n,
             menciona_pct_total = 100 * sum(x == 1) / nrow(d24),
             ic95_srs_inf = 100 * ci[1], ic95_srs_sup = 100 * ci[2])
})
ranking24 <- do.call(rbind, rank_rows)
ranking24 <- ranking24[order(-ranking24$menciona_pct_validos), ]

other_groups <- groups24[c(1, 2, 4, 5, 6, 7, 8)]
other_groups_wo_substance <- groups24[c(1, 2, 4, 6, 7, 8)]
get_count <- function(cols) {
  mm <- sapply(cols, function(v) column(d24, v))
  if (is.null(dim(mm))) mm <- matrix(mm, ncol = 1L)
  rowSums(mm == 1, na.rm = TRUE)
}
excl_count <- get_count(other_groups)
excl_count_sensitivity <- get_count(other_groups_wo_substance)
count_rows <- do.call(rbind, lapply(c(0, 1), function(y) {
  use <- valid24 & homo24 == y
  data.frame(
    homosexual_rejection = ifelse(y == 1, "Menciona homosexual", "No menciona homosexual"),
    n = sum(use), media_otros_grupos_0a7 = mean(excl_count[use]),
    mediana_otros_grupos_0a7 = median(excl_count[use]),
    media_sin_sustancias_0a6 = mean(excl_count_sensitivity[use]),
    mediana_sin_sustancias_0a6 = median(excl_count_sensitivity[use])
  )
}))
wilcox_full <- wilcox.test(excl_count[valid24 & homo24 == 1],
                           excl_count[valid24 & homo24 == 0], exact = FALSE)
wilcox_sens <- wilcox.test(excl_count_sensitivity[valid24 & homo24 == 1],
                           excl_count_sensitivity[valid24 & homo24 == 0], exact = FALSE)
count_tests <- data.frame(
  comparison = c("Conteo de otros 7 grupos (sin homosexuales)",
                 "Sensibilidad: conteo sin bebedores/drogadictos/alcohólicos"),
  wilcoxon_stat = c(unname(wilcox_full$statistic), unname(wilcox_sens$statistic)),
  p_srs_aprox = c(wilcox_full$p.value, wilcox_sens$p.value)
)
count_tests$p_holm_2 <- p.adjust(count_tests$p_srs_aprox, method = "holm")

# 4) 2024 demographic profiles. Percentages are among people answering the
# neighbor battery; denominators and Wilson intervals are exported explicitly.
sex <- column(d24, "sexo")
agecat <- column(d24, "reedad")
education <- column(d24, "reeduc.1")
practice <- column(d24, "s1a")

label_sex <- factor(sex, levels = c(1, 2), labels = c("Hombre", "Mujer"))
label_age <- factor(agecat, levels = 1:4, labels = c("16–25", "26–40", "41–60", "61+"))
label_education <- factor(education, levels = 1:7,
  labels = c("Analfabeto", "Básica incompleta", "Básica completa",
             "Secundaria/técnica incompleta", "Secundaria/técnica completa",
             "Superior incompleta", "Superior completa"))
label_practice <- factor(practice, levels = c(1, 2, 3, 4, -3, 9),
  labels = c("Muy practicante", "Practicante", "No muy practicante",
             "No practicante", "No aplica", "No aplica"))
profile_vars <- list(sexo = label_sex, edad = label_age,
                     educacion = label_education, practica_religiosa = label_practice)
profile_rows <- list(); profile_tests <- list()
for (nm in names(profile_vars)) {
  g <- profile_vars[[nm]]
  usable <- valid24 & !is.na(g)
  lev <- levels(droplevels(g[usable]))
  for (lv in lev) {
    use <- usable & g == lv
    k <- sum(use & homo24 == 1)
    n <- sum(use)
    ci <- wilson(k, n)
    profile_rows[[length(profile_rows) + 1L]] <- data.frame(
      variable = nm, categoria = lv, n_validos = n, rechazo_n = k,
      rechazo_pct = 100 * k / n, ic95_srs_inf = 100 * ci[1], ic95_srs_sup = 100 * ci[2]
    )
  }
  tab <- table(g[usable], factor(homo24[usable], levels = c(0, 1)))
  chi <- suppressWarnings(chisq.test(tab, correct = FALSE))
  profile_tests[[length(profile_tests) + 1L]] <- data.frame(
    variable = nm, chi2 = unname(chi$statistic), gl = unname(chi$parameter),
    p_srs_aprox = chi$p.value, min_esperado = min(chi$expected)
  )
}
profiles <- do.call(rbind, profile_rows)
profile_tests <- do.call(rbind, profile_tests)
profile_tests$p_holm_4 <- p.adjust(profile_tests$p_srs_aprox, method = "holm")

# Audit the 2024 battery nonresponse and geographic spread.
nr24 <- noanswer24
nonresponse_rows <- list(); nonresponse_tests <- list()
for (nm in names(profile_vars)) {
  g <- profile_vars[[nm]]
  usable <- !is.na(g)
  for (lv in levels(droplevels(g[usable]))) {
    use <- usable & g == lv
    k <- sum(use & nr24); n <- sum(use); ci <- wilson(k, n)
    nonresponse_rows[[length(nonresponse_rows) + 1L]] <- data.frame(
      variable = nm, categoria = lv, n_total = n, no_responde_n = k,
      no_responde_pct = 100 * k / n,
      ic95_srs_inf = 100 * ci[1], ic95_srs_sup = 100 * ci[2]
    )
  }
  tab <- table(g[usable], factor(nr24[usable], levels = c(FALSE, TRUE)))
  chi <- suppressWarnings(chisq.test(tab, correct = FALSE))
  nonresponse_tests[[length(nonresponse_tests) + 1L]] <- data.frame(
    variable = nm, chi2 = unname(chi$statistic), gl = unname(chi$parameter),
    p_srs_aprox = chi$p.value, min_esperado = min(chi$expected)
  )
}
nonresponse_profiles <- do.call(rbind, nonresponse_rows)
nonresponse_tests <- do.call(rbind, nonresponse_tests)
nonresponse_tests$p_holm_4 <- p.adjust(nonresponse_tests$p_srs_aprox, method = "holm")

# Translate regional codes from the official CSVText file, joined by interview ID.
text_zip <- file.path(ROOT, "documentacion", "latinobarometro-2024-bolivia-csvtext-esp-v1.zip")
text_member <- "Latinobarometro_2024_Bolivia_CsvText_esp_v1.csv"
txt_lines <- readLines(unz(text_zip, text_member), encoding = "UTF-8")
txt_lines <- sub("^\\ufeff", "", txt_lines)
txt_lines <- sub(";$", "", txt_lines)
txt24 <- read.csv(text = paste(txt_lines, collapse = "\n"), sep = ";",
                  check.names = FALSE, na.strings = c("", "NA"))
id_col <- match("NUMENTRE Número de Entrevista", names(txt24))
region_col <- match("REG Región/ Provincia", names(txt24))
if (is.na(id_col) || is.na(region_col)) stop("2024 CSVText region labels unavailable")
txt_id <- as.integer(as.numeric(as.character(txt24[[id_col]])))
label_by_id <- setNames(as.character(txt24[[region_col]]), txt_id)
id24 <- as.integer(column(d24, "numentre"))
region24 <- unname(label_by_id[as.character(id24)])
region_levels <- unique(region24[!is.na(region24)])
region_rows <- lapply(region_levels, function(lv) {
  use <- valid24 & region24 == lv
  k <- sum(use & homo24 == 1); n <- sum(use); ci <- wilson(k, n)
  data.frame(region = lv, n_total = sum(region24 == lv, na.rm = TRUE),
             no_respuesta_n = sum(region24 == lv & nr24, na.rm = TRUE),
             n_validos = n, rechazo_n = k,
             rechazo_pct = 100 * k / n, ic95_srs_inf = 100 * ci[1],
             ic95_srs_sup = 100 * ci[2])
})
regions24 <- do.call(rbind, region_rows)
region_tab <- table(factor(region24[valid24], levels = region_levels),
                    factor(homo24[valid24], levels = c(0, 1)))
region_chi <- suppressWarnings(chisq.test(region_tab, correct = FALSE))
region_test <- data.frame(chi2 = unname(region_chi$statistic), gl = unname(region_chi$parameter),
                          p_srs_aprox = region_chi$p.value,
                          min_esperado = min(region_chi$expected),
                          nota = "Descriptivo: celdas pequeñas; diseño muestral no reconstruido")

# Sensitivity to item nonresponse under a missing-at-random assumption conditional
# on sex, age, education and religious practice. These are adjustment weights for
# item response only, not the survey's design weights.
practice_response <- as.character(label_practice)
practice_response[is.na(practice_response)] <- "Sin dato práctica"
response_data <- data.frame(
  answered = as.integer(!nr24), sex = label_sex, age = label_age,
  education = label_education, practice = factor(practice_response)
)
response_fit <- glm(answered ~ sex + age + education + practice,
                    data = response_data, family = binomial())
response_probability <- predict(response_fit, type = "response")
ipw_response <- 1 / response_probability[valid24]
ipw_response <- ipw_response / mean(ipw_response)
overall_ipw <- weighted.mean(homo24[valid24], ipw_response)
ipw_ess <- sum(ipw_response)^2 / sum(ipw_response^2)
response_sensitivity <- data.frame(
  estimacion = c("Muestra completa: menciones/N total", "Casos válidos: completos", "IPW de no respuesta: MAR por sexo/edad/educación/práctica"),
  pct_rechazo = c(100 * sum(homo24 == 1) / length(homo24),
                  100 * mean(homo24[valid24]), 100 * overall_ipw),
  n_base = c(length(homo24), sum(valid24), sum(valid24)),
  n_efectivo_ipw = c(NA, NA, ipw_ess),
  peso_ipw_min = c(NA, NA, min(ipw_response)),
  peso_ipw_max = c(NA, NA, max(ipw_response))
)
sex_ipw <- do.call(rbind, lapply(levels(label_sex), function(lv) {
  use_all <- label_sex[valid24] == lv
  data.frame(sexo = lv, n_validos = sum(use_all),
             rechazo_pct_ipw = 100 * weighted.mean(homo24[valid24][use_all], ipw_response[use_all]))
}))

# Exploratory multivariable model: unweighted, complete-case, SRS standard errors.
# Education contrast is completion of secondary or above vs less; religious
# practice retains a distinct non-applicable category, not silently merged.
practice_model <- rep(NA_character_, nrow(d24))
practice_model[practice %in% c(1, 2)] <- "Regular practice"
practice_model[practice %in% c(3, 4)] <- "Low/no practice"
practice_model[practice %in% c(-3, 9)] <- "No aplica"
education_model <- ifelse(education %in% 5:7, "Secondary complete or higher",
                          ifelse(education %in% 1:4, "Below secondary completion", NA))
model_data <- data.frame(
  reject = as.integer(homo24 == 1),
  age_group = label_age,
  woman = factor(sex, levels = c(1, 2), labels = c("Hombre", "Mujer")),
  education = factor(education_model, levels = c("Below secondary completion", "Secondary complete or higher")),
  practice = factor(practice_model, levels = c("Regular practice", "Low/no practice", "No aplica"))
)
model_ok <- valid24 & complete.cases(model_data)
fit <- glm(reject ~ age_group + woman + education + practice,
           data = model_data[model_ok, ], family = binomial())
cf <- summary(fit)$coefficients
model_out <- data.frame(
  term = rownames(cf), beta_logit = cf[, 1], se_srs = cf[, 2],
  odds_ratio = exp(cf[, 1]), or_ic95_inf = exp(cf[, 1] - 1.96 * cf[, 2]),
  or_ic95_sup = exp(cf[, 1] + 1.96 * cf[, 2]), p_srs_aprox = cf[, 4],
  n_modelo = sum(model_ok), stringsAsFactors = FALSE
)
model_data2 <- model_data[model_ok, ]
model_data2$other_exclusions_0_6 <- excl_count_sensitivity[model_ok]
fit_specific <- glm(reject ~ age_group + woman + education + practice + other_exclusions_0_6,
                    data = model_data2, family = binomial())
cf2 <- summary(fit_specific)$coefficients
model_specific <- data.frame(
  term = rownames(cf2), beta_logit = cf2[, 1], se_srs = cf2[, 2],
  odds_ratio = exp(cf2[, 1]), or_ic95_inf = exp(cf2[, 1] - 1.96 * cf2[, 2]),
  or_ic95_sup = exp(cf2[, 1] + 1.96 * cf2[, 2]), p_srs_aprox = cf2[, 4],
  n_modelo = sum(model_ok), stringsAsFactors = FALSE
)

# Partial design-based sensitivity: COMDIST is the sampled sector/municipality/
# district field; REG is used as a geographic stratum. This does not reconstruct
# all four stages or the final quotas, so keep it labeled as approximate.
model_design <- data.frame()
if (requireNamespace("survey", quietly = TRUE)) {
  design_data <- model_data[model_ok, ]
  design_data$reject <- model_data$reject[model_ok]
  design_data$other_exclusions_0_6 <- excl_count_sensitivity[model_ok]
  design_data$COMDIST <- column(d24[model_ok, ], "COMDIST")
  design_data$REG <- column(d24[model_ok, ], "REG")
  design_data$WT <- column(d24[model_ok, ], "WT")
  design_partial <- survey::svydesign(ids = ~COMDIST, strata = ~REG, weights = ~WT,
                                      data = design_data, nest = TRUE)
  fit_design <- survey::svyglm(
    reject ~ age_group + woman + education + practice + other_exclusions_0_6,
    design = design_partial, family = quasibinomial()
  )
  design_cf <- summary(fit_design)$coefficients
  design_ci <- suppressMessages(confint(fit_design))
  model_design <- data.frame(
    term = rownames(design_cf), beta_logit = design_cf[, 1], se_cluster_strata = design_cf[, 2],
    df_design = fit_design$df.residual, p_design_aprox = design_cf[, 4],
    odds_ratio = exp(design_cf[, 1]), or_ic95_inf = exp(design_ci[, 1]),
    or_ic95_sup = exp(design_ci[, 2]), n_modelo = sum(model_ok),
    diseno = "Sensibilidad parcial: PSU=COMDIST, estrato=REG; no reconstruye cuotas/etapas",
    stringsAsFactors = FALSE
  )
}

# 5) 2006 item is a forced, single response about perceived reasons for unequal
# treatment; it is not a prevalence measure of LGBTI+ people's lived experience.
d06 <- csv_for(2006)
p46 <- column(d06, "p46stm")
discrimination06 <- data.frame(
  anio = 2006, pregunta = "Razones por las cuales no se trata a todos por igual",
  categoria_homosexual = 7, n_total = length(p46), n_menciona = sum(p46 == 7),
  pct_total = 100 * mean(p46 == 7),
  advertencia = "Respuesta única de percepción; no mide prevalencia de discriminación vivida"
)

# 2008: open response recoded to the group believed to be most discriminated.
# This is public salience/recognition, not the respondent's own experience.
d08 <- csv_for(2008)
p68 <- column(d08, "p68st")
valid_p68 <- p68 %in% c(1:20, 96, 97)
labels_p68 <- c(
  "Personas negras", "Indígenas", "Personas blancas", "Mulatos", "Mestizos",
  "Chinos/japoneses/asiáticos", "Árabes", "Judíos", "Pobres", "Inmigrantes",
  "Personas con discapacidad", "Personas con VIH/SIDA", "Homosexuales", "Mujeres",
  "Personas mayores", "Jóvenes", "Analfabetos/sin educación", "Grupos religiosos",
  "Grupos/partidos políticos", "Movimientos/grupos de interés", "Otras", "Ninguno"
)
codes_p68 <- c(1:20, 96, 97)
salience_rows <- lapply(seq_along(codes_p68), function(i) {
  code <- codes_p68[i]
  n <- sum(p68 == code, na.rm = TRUE)
  data.frame(codigo = code, categoria = labels_p68[i], n = n,
             pct_respuestas_validas = 100 * n / sum(valid_p68),
             pct_muestra_total = 100 * n / length(p68))
})
salience08 <- do.call(rbind, salience_rows)
salience08 <- salience08[order(-salience08$n), ]
salience08$orden <- seq_len(nrow(salience08))

# Save outputs.
write.csv(do.call(rbind, indicator_rows), file.path(OUT, "indicadores_por_oleada.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(marriage_tests, file.path(OUT, "comparaciones_matrimonio_2010_2023.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(do.call(rbind, justification_rows), file.path(OUT, "justificacion_moral_2002_2008.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(paired, file.path(OUT, "comparaciones_pareadas_2023.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(ranking24, file.path(OUT, "jerarquia_rechazo_grupos_2024.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(count_rows, file.path(OUT, "conteo_exclusion_2024.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(count_tests, file.path(OUT, "pruebas_conteo_exclusion_2024.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(profiles, file.path(OUT, "perfiles_demograficos_2024.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(profile_tests, file.path(OUT, "pruebas_perfiles_2024.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(nonresponse_profiles, file.path(OUT, "no_respuesta_perfiles_2024.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(nonresponse_tests, file.path(OUT, "pruebas_no_respuesta_2024.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(regions24, file.path(OUT, "perfiles_territoriales_2024.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(region_test, file.path(OUT, "prueba_territorial_2024.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(response_sensitivity, file.path(OUT, "sensibilidad_no_respuesta_2024.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(sex_ipw, file.path(OUT, "sensibilidad_no_respuesta_por_sexo_2024.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(model_out, file.path(OUT, "modelo_logistico_2024.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(model_specific, file.path(OUT, "modelo_especificidad_2024.csv"), row.names = FALSE, fileEncoding = "UTF-8")
if (nrow(model_design) > 0) write.csv(model_design, file.path(OUT, "modelo_diseno_parcial_2024.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(discrimination06, file.path(OUT, "item_discriminacion_percibida_2006.csv"), row.names = FALSE, fileEncoding = "UTF-8")
write.csv(salience08, file.path(OUT, "saliencia_discriminacion_2008.csv"), row.names = FALSE, fileEncoding = "UTF-8")

cat("OK: resultados escritos en ", OUT, "\n", sep = "")
cat("N válido 2024 (batería vecindad): ", sum(valid24), " de ", length(valid24), "\n", sep = "")
cat("N completo modelo 2024: ", sum(model_ok), "\n", sep = "")
