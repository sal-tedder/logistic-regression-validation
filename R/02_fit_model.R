# Project 01: Logistic Regression Validation
# Step 2: Fit and interpret the logistic regression model

# Load the saved dataset
data <- read.csv("data/synthetic_conversions.csv")

# Fit binomial logistic regression
model <- glm(
  converted ~ treatment,
  data = data,
  family = binomial(link = "logit")
)

# Display model results
summary(model)

# Extract estimated coefficients
coef(model)

# Convert log-odds coefficients to odds ratios
exp(coef(model))

# Calculate fitted conversion probabilities
predict(
  model,
  newdata = data.frame(treatment = c(0, 1)),
  type = "response"
)

##################################


# Analytical coefficient validation

beta_0 <- log(97 / 903)

beta_1 <- log(149 / 851) - log(97 / 903)

odds_ratio <- exp(beta_1)

c(
  intercept = beta_0,
  treatment = beta_1,
  odds_ratio = odds_ratio
)

# Compare analytical coefficients to glm()
all.equal(
  unname(coef(model)),
  c(beta_0, beta_1)
)