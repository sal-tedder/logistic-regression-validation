
# Project 01: Logistic Regression Validation
# Step 1: Generate reproducible synthetic A/B test data

set.seed(2026)

# Experiment design
n_per_group <- 1000
p_control <- 0.10
p_treatment <- 0.15

# Assign treatment groups
treatment <- rep(c(0, 1), each = n_per_group)

# Generate binary conversion outcomes
converted <- c(
  rbinom(n_per_group, size = 1, prob = p_control),
  rbinom(n_per_group, size = 1, prob = p_treatment)
)

# Assemble dataset
data <- data.frame(
  visitor_id = seq_len(2 * n_per_group),
  treatment = treatment,
  converted = converted
)

# Inspect the dataset
head(data)

# Verify group sizes and conversion counts
table(data$treatment, data$converted)

# Calculate observed conversion rates
aggregate(converted ~ treatment, data, mean)

# Save reproducible dataset
dir.create("data", showWarnings = FALSE)
write.csv(data, "data/synthetic_conversions.csv",
          row.names = FALSE)




