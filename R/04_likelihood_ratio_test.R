
# Project 01: Logistic Regression Validation
# Step 4: Likelihood-ratio test

data <- read.csv("data/synthetic_conversions.csv")

# Fit full model
full_model <- glm(
  converted ~ treatment,
  data = data,
  family = binomial(link = "logit"),
  control = glm.control(epsilon = 1e-12, maxit = 100)
)

# Fit null model (intercept only)
null_model <- glm(
  converted ~ 1,
  data = data,
  family = binomial(link = "logit"),
  control = glm.control(epsilon = 1e-12, maxit = 100)
)

# Extract maximized log-likelihoods
ll_full <- as.numeric(logLik(full_model))
ll_null <- as.numeric(logLik(null_model))

# Calculate likelihood-ratio statistic
lr_stat <- 2 * (ll_full - ll_null)

# Degrees of freedom
df <- length(coef(full_model)) -
  length(coef(null_model))

# Calculate p-value
lr_p <- pchisq(lr_stat, df = df, lower.tail = FALSE)

# Display results
cat("Likelihood-ratio statistic:", lr_stat, "\n")
cat("Degrees of freedom:", df, "\n")
cat("LRT p-value:", lr_p, "\n")

# Independently compare against R's deviance test
anova(null_model, full_model, test = "Chisq")
