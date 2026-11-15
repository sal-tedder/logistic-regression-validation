
# Project 01: Logistic Regression Validation
# Step 5: Visualize conversion rates and uncertainty

library(ggplot2)

data <- read.csv("data/synthetic_conversions.csv")

# Summarize group outcomes
groups <- aggregate(
  converted ~ treatment,
  data = data,
  FUN = function(x) c(successes = sum(x), n = length(x))
)

results <- data.frame(
  treatment = groups$treatment,
  successes = groups$converted[, "successes"],
  n = groups$converted[, "n"]
)

results$rate <- results$successes / results$n

# Calculate 95% Wilson score confidence intervals
z <- qnorm(0.975)

denominator <- 1 + z^2 / results$n

center <- (
  results$rate + z^2 / (2 * results$n)
) / denominator

half_width <- (
  z / denominator *
    sqrt(
      results$rate * (1 - results$rate) / results$n +
        z^2 / (4 * results$n^2)
    )
)

results$lower <- center - half_width
results$upper <- center + half_width

results$group <- factor(
  results$treatment,
  levels = c(0, 1),
  labels = c("Control", "Treatment")
)


# Professional conversion-rate visualization

# Format labels
results$rate_label <- sprintf("%.1f%%", 100 * results$rate)

# Create publication-style figure
plot <- ggplot(
  results,
  aes(x = rate, y = group, color = group)
) +
  geom_errorbar(
    aes(xmin = lower, xmax = upper),
    orientation = "y",
    width = 0.13,
    linewidth = 1.1
  ) +
  geom_point(size = 4.5) +
  geom_text(
    aes(label = rate_label),
    nudge_y = 0.24,
    color = "#172033",
    fontface = "bold",
    size = 4.5,
    show.legend = FALSE
  ) +
  scale_color_manual(
    values = c(
      "Control" = "#64748B",
      "Treatment" = "#2563EB"
    ),
    guide = "none"
  ) +
  scale_x_continuous(
    labels = function(x) sprintf("%.0f%%", 100 * x),
    breaks = seq(0, 0.20, 0.05),
    limits = c(0, 0.20),
    expand = expansion(mult = c(0.01, 0.02))
  ) +
  scale_y_discrete(limits = c("Treatment", "Control")) +
  labs(
    title = "Conversion Rates by Experiment Group",
    subtitle = "Observed conversion rates with 95% Wilson confidence intervals",
    x = "Conversion rate",
    y = NULL,
    caption = paste(
      "Synthetic randomized A/B experiment |",
      "n = 1,000 per group"
    )
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 17,
      color = "#172033",
      margin = margin(b = 8)
    ),
    plot.subtitle = element_text(
      size = 11,
      color = "#64748B",
      margin = margin(b = 18)
    ),
    axis.text.y = element_text(
      size = 12,
      face = "bold",
      color = "#172033"
    ),
    axis.text.x = element_text(color = "#64748B"),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_line(
      color = "#E5E7EB",
      linewidth = 0.4
    ),
    plot.caption = element_text(
      color = "#64748B",
      size = 9,
      hjust = 0,
      margin = margin(t = 16)
    ),
    plot.margin = margin(20, 24, 20, 20)
  )

print(plot)

# Export for GitHub
dir.create("figures", showWarnings = FALSE)

ggsave(
  filename = "figures/conversion_rates.png",
  plot = plot,
  width = 9,
  height = 4.5,
  dpi = 300,
  bg = "white"
)
