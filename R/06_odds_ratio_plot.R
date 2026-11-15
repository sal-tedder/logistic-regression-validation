
# Project 01: Logistic Regression Validation
# Step 6: Visualize treatment odds ratio

library(ggplot2)

data <- read.csv("data/synthetic_conversions.csv")

model <- glm(
  converted ~ treatment,
  data = data,
  family = binomial(link = "logit"),
  control = glm.control(epsilon = 1e-12, maxit = 100)
)

# Extract treatment coefficient and standard error
beta <- coef(model)["treatment"]
se <- summary(model)$coefficients["treatment", "Std. Error"]

# Construct odds ratio and Wald CI
z <- qnorm(0.975)

or <- exp(beta)
lower <- exp(beta - z * se)
upper <- exp(beta + z * se)

results <- data.frame(
  term = "Treatment vs. Control",
  odds_ratio = unname(or),
  lower = unname(lower),
  upper = unname(upper)
)

# Create plot
plot_or <- ggplot(
  results,
  aes(x = odds_ratio, y = term)
) +
  geom_vline(
    xintercept = 1,
    linetype = "dashed",
    color = "#94A3B8",
    linewidth = 0.7
  ) +
  geom_errorbar(
    aes(xmin = lower, xmax = upper),
    orientation = "y",
    width = 0.12,
    color = "#2563EB",
    linewidth = 1.1
  ) +
  geom_point(
    size = 4.5,
    color = "#2563EB"
  ) +
  annotate(
    "text",
    x = unname(or),
    y = 1.25,
    label = sprintf("OR = %.2f", or),
    fontface = "bold",
    color = "#172033",
    size = 4.5
  ) +
  scale_x_continuous(
    breaks = seq(0.5, 2.5, 0.5),
    limits = c(0.5, 2.5)
  ) +
  labs(
    title = "Estimated Treatment Effect on Conversion Odds",
    subtitle = "Logistic regression estimate with 95% Wald confidence interval",
    x = "Odds ratio",
    y = NULL,
    caption = "Dashed line indicates no treatment effect (OR = 1)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 17,
      color = "#172033"
    ),
    plot.subtitle = element_text(
      color = "#64748B",
      margin = margin(b = 16)
    ),
    axis.text = element_text(
      color = "#64748B"
    ),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    plot.caption = element_text(
      color = "#64748B",
      hjust = 0
    ),
    plot.margin = margin(20, 24, 20, 20)
  )

print(plot_or)

dir.create("figures", showWarnings = FALSE)

ggsave(
  "figures/odds_ratio.png",
  plot = plot_or,
  width = 9,
  height = 3,
  dpi = 300,
  bg = "white"
)
