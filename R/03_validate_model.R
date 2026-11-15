
# ============================================================
# Project 01: Logistic Regression Validation
# Step 3: Independent Analytical Validation
#
# Purpose:
# Independently calculate logistic regression coefficients,
# standard errors, Wald statistics, p-values, and confidence
# intervals, then validate them against R's glm() output.
#
# Dataset: Synthetic randomized A/B experiment
# ============================================================


# ------------------------------------------------------------
# 1. Load data and verify structure
# ------------------------------------------------------------

data <- read.csv("data/synthetic_conversions.csv")

# Verify required columns
stopifnot(
  all(c("treatment", "converted") %in% names(data))
)

# Verify binary coding and absence of missing values
stopifnot(
  !anyNA(data[, c("treatment", "converted")]),
  all(data$treatment %in% c(0, 1)),
  all(data$converted %in% c(0, 1))
)


# ------------------------------------------------------------
# 2. Fit logistic regression with strict convergence
# ------------------------------------------------------------

model <- glm(
  converted ~ treatment,
  data = data,
  family = binomial(link = "logit"),
  control = glm.control(
    epsilon = 1e-12,
    maxit = 100
  )
)

# Verify numerical convergence
stopifnot(isTRUE(model$converged))

cat("Model converged successfully.\n")
cat("IRLS iterations:", model$iter, "\n\n")


# ------------------------------------------------------------
# 3. Extract observed contingency-table counts
# ------------------------------------------------------------

counts <- table(
  factor(data$treatment, levels = c(0, 1)),
  factor(data$converted, levels = c(0, 1))
)

a <- unname(counts["1", "1"])  # Treatment conversions
b <- unname(counts["1", "0"])  # Treatment non-conversions
c <- unname(counts["0", "1"])  # Control conversions
d <- unname(counts["0", "0"])  # Control non-conversions

# Analytical formulas require positive cell counts
stopifnot(all(c(a, b, c, d) > 0))

cat("Observed contingency table:\n")
print(counts)
cat("\n")


# ------------------------------------------------------------
# 4. Calculate coefficients analytically
# ------------------------------------------------------------

# Intercept: control-group log-odds
beta_0 <- log(c / d)

# Treatment: difference in group log-odds
beta_1 <- log(a / b) - log(c / d)

analytical_coef <- c(
  "(Intercept)" = beta_0,
  "treatment" = beta_1
)


# ------------------------------------------------------------
# 5. Calculate analytical standard errors
# ------------------------------------------------------------

# Intercept variance
var_0 <- 1 / c + 1 / d

# Treatment coefficient variance
var_1 <- 1 / a + 1 / b + 1 / c + 1 / d

analytical_se <- c(
  "(Intercept)" = sqrt(var_0),
  "treatment" = sqrt(var_1)
)


# ------------------------------------------------------------
# 6. Calculate Wald z-statistics and p-values
# ------------------------------------------------------------

z_values <- analytical_coef / analytical_se

# Two-sided Wald tests
p_values <- 2 * pnorm(
  -abs(z_values)
)


# ------------------------------------------------------------
# 7. Calculate 95% Wald confidence intervals
# ------------------------------------------------------------

alpha <- 0.05

z_critical <- qnorm(1 - alpha / 2)

ci_lower <- analytical_coef -
  z_critical * analytical_se

ci_upper <- analytical_coef +
  z_critical * analytical_se


# ------------------------------------------------------------
# 8. Compare analytical estimates against glm()
# ------------------------------------------------------------

glm_summary <- summary(model)$coefficients

validation <- data.frame(
  term = names(analytical_coef),
  
  analytical_estimate = unname(analytical_coef),
  glm_estimate = unname(coef(model)),
  
  analytical_se = unname(analytical_se),
  glm_se = unname(glm_summary[, "Std. Error"]),
  
  analytical_z = unname(z_values),
  glm_z = unname(glm_summary[, "z value"]),
  
  analytical_p = unname(p_values),
  glm_p = unname(glm_summary[, "Pr(>|z|)"])
)

cat("Analytical vs. glm validation:\n")
print(validation, digits = 10)
cat("\n")


# ------------------------------------------------------------
# 9. Quantify numerical differences
# ------------------------------------------------------------

differences <- data.frame(
  term = names(analytical_coef),
  
  coefficient_difference = abs(
    unname(analytical_coef) -
      unname(coef(model))
  ),
  
  se_difference = abs(
    unname(analytical_se) -
      unname(glm_summary[, "Std. Error"])
  ),
  
  z_difference = abs(
    unname(z_values) -
      unname(glm_summary[, "z value"])
  ),
  
  p_difference = abs(
    unname(p_values) -
      unname(glm_summary[, "Pr(>|z|)"])
  )
)

cat("Absolute numerical differences:\n")
print(differences, digits = 10)
cat("\n")


# ------------------------------------------------------------
# 10. Automated numerical validation
# ------------------------------------------------------------

tolerance <- 1e-6

stopifnot(
  isTRUE(all.equal(
    unname(analytical_coef),
    unname(coef(model)),
    tolerance = tolerance
  )),
  
  isTRUE(all.equal(
    unname(analytical_se),
    unname(glm_summary[, "Std. Error"]),
    tolerance = tolerance
  )),
  
  isTRUE(all.equal(
    unname(z_values),
    unname(glm_summary[, "z value"]),
    tolerance = tolerance
  )),
  
  isTRUE(all.equal(
    unname(p_values),
    unname(glm_summary[, "Pr(>|z|)"]),
    tolerance = tolerance
  ))
)

cat("All numerical validation checks passed.\n\n")


# ------------------------------------------------------------
# 11. Calculate treatment odds ratio and confidence interval
# ------------------------------------------------------------

odds_ratio <- exp(beta_1)

or_ci_lower <- exp(ci_lower["treatment"])
or_ci_upper <- exp(ci_upper["treatment"])

cat("Treatment odds ratio:",
    round(odds_ratio, 6), "\n")

cat("95% Wald confidence interval:",
    round(or_ci_lower, 6), "to",
    round(or_ci_upper, 6), "\n\n")


# ------------------------------------------------------------
# 12. Calculate observed conversion rates
# ------------------------------------------------------------

control_rate <- c / (c + d)
treatment_rate <- a / (a + b)

absolute_effect <- treatment_rate - control_rate

relative_effect <- (
  treatment_rate / control_rate - 1
)

cat("Control conversion rate:",
    sprintf("%.2f%%", 100 * control_rate), "\n")

cat("Treatment conversion rate:",
    sprintf("%.2f%%", 100 * treatment_rate), "\n")

cat("Absolute conversion-rate difference:",
    sprintf("%.2f percentage points",
            100 * absolute_effect), "\n")

cat("Relative conversion-rate increase:",
    sprintf("%.2f%%", 100 * relative_effect), "\n\n")


# ------------------------------------------------------------
# 13. Final validation summary
# ------------------------------------------------------------

cat("========================================\n")
cat("LOGISTIC REGRESSION VALIDATION COMPLETE\n")
cat("========================================\n")

cat("Model convergence: PASSED\n")
cat("Coefficient validation: PASSED\n")
cat("Standard error validation: PASSED\n")
cat("Wald statistic validation: PASSED\n")
cat("P-value validation: PASSED\n")
cat("========================================\n")
