library(dplyr)
library(tidyverse)

num_flips <- 1e4
flips <- rbinom(num_flips, 1, 1 / 2)

marginal_points <- integer(num_flips)
point_prev <- FALSE
for (n in 2:num_flips) {
  point <- !point_prev && flips[n - 1] == 1 && flips[n] == 1
  if (point) {
    marginal_points[n] <- 1
  }
  point_prev <- point
}

data.frame(
  flip = seq(1, num_flips),
  ratio = cumsum(marginal_points) / seq(1, num_flips)
) %>%
  ggplot(aes(x = flip, y = ratio)) +
  geom_line() +
  scale_x_continuous(trans = "sqrt") +
  theme_bw() +
  geom_abline(slope = 0, intercept = 1 / 6, color = "blue", linetype = "dashed")

ggsave("points_timeline.jpg")
