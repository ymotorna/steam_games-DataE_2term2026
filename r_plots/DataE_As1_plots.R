library(tidyverse)
library(patchwork)


# visualization 1: boxplot for price distribution across platform groups --------
# load data
data_price_platform <- read_csv("C:\\Users\\Motorna\\window_func.csv")

data_price_platform %>% head()


# calculate quartiles for platform groups
q1_q3 <- data_price_platform %>%
  group_by(platform_gr) %>%
  summarise(
    q1 = quantile(price, 0.25, na.rm = TRUE),
    q3 = quantile(price, 0.75, na.rm = TRUE),
    iqr = IQR(price, na.rm = TRUE)
  ) %>%
  mutate(
    lower_bound = q1 - 1.5 * iqr,
    upper_bound = q3 + 1.5 * iqr
  )

# get max upper bound for y-axis
y_limit <- max(q1_q3$upper_bound, na.rm = TRUE)

# plot_1: Windows (full range)
p1 <- data_price_platform %>%
  filter(platform_gr == 'Windows') %>%
  ggplot(aes(x = platform_gr, y = price)) +
  geom_boxplot() +
  labs(title = "Windows Platform (with outliers)",
       x = "Platform Group",
       y = "Price, USD") +
  theme_minimal()

# plot_2: all platform groups (limited y-axis to remove outliers)
p2 <- data_price_platform %>%
  ggplot(aes(x = platform_gr, y = price)) +
  geom_boxplot() +  # Hide outlier points
  coord_cartesian(ylim = c(0, y_limit)) +
  labs(title = "All Platforms (outliers removed)",
       x = "Platform Group",
       y = "Price, USD") +
  theme_minimal()

# Combine
p1 + p2


# visualization 2: scatter plot of relation between price and user score --------
# load data
data_price_score <- read_csv("C:\\Users\\Motorna\\identifier_main_games_part.csv")
data_price_score %>% head()

data_price_score %>% 
  filter(user_score != 0) %>% 
  count(user_score)

# plot: scatter plot of price vs user score
data_price_score %>% 
  filter(user_score != 0) %>%  # remove score = 0 as it probably just missing => distort data
  ggplot(aes(x = price, y = user_score)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(title = "Price vs User Score",
       x = "Price, USD",
       y = "User Score") +
  theme_minimal()

