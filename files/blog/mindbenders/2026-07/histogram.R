library(tidyverse)
library(ggh4x)

counts <- tibble(
  x = 1:6,
  y = c(6, 930, 10800, 23400, 10800, 720),
)

counts |>
  mutate(y = y / (6**6)) |>
  ggplot(aes(x = x, y = y)) +
  geom_bar(stat = "identity") +
  scale_x_continuous(name = "Number Distinct", breaks = 1:6) +
  scale_y_continuous(name = "Probability") +
  theme_bw()
ggsave("histogram.png", dpi = 300)
