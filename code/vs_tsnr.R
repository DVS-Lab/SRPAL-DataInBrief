# Load the required libraries
library(ggplot2)
library(dplyr)

# Read the CSV file
data <- read.csv("tsnrvals.csv")
data_stan <- read.csv("tsnrvals.csv")

# Read the file containing the list of subjects for the new flip angle
new_flip_angle_subs <- read.csv("newflip.csv", header = TRUE)

# Create a new column in data indicating whether each subject is in the new flip angle
data$flip_angle <- ifelse(data$sub %in% new_flip_angle_subs$sub, "new flip angle", "old flip angle")
data_stan$flip_angle <- ifelse(data_stan$sub %in% new_flip_angle_subs$sub, "new flip angle", "old flip angle")

# Remove unwanted rows
#data = select(data, -1, -2, -4, -9)
data = select(data, -5, -6)
data_stan = select(data_stan, -4, -7, -8, -9)

# Convert everything to numeric for NA removal
data$vsmean_nat <- as.numeric(as.character(data$vsmean_nat))
data_stan$vsmean_stan <- as.numeric(as.character(data_stan$vsmean_stan))
data$mean_nat <- as.numeric(as.character(data$mean_nat))
data_stan$mean_stan <- as.numeric(as.character(data_stan$mean_stan))
data$max <- as.numeric(as.character(data$max))

# Remove rows with NAs
data <- na.omit(data)
data_stan <- na.omit(data_stan)
data_stan <- distinct(data_stan)

# Group data_stan by sub, task, and echo, calculate averages for mean_stan and vsmean_stan
averaged_data_stan <- data_stan %>%
  group_by(sub, echo) %>%
  summarize(vsmean_stan = mean(vsmean_stan)) %>%
  ungroup()

# Group data_stan by sub, task, and echo, calculate averages for mean_stan and vsmean_stan
averaged_data_nat <- data %>%
  group_by(sub, echo) %>%
  summarize(vsmean_nat = mean(vsmean_nat)) %>%
  ungroup()

# Bind the averaged rows to the original data_stan
data_stan <- bind_rows(data_stan, averaged_data_stan)
data <- bind_rows(data, averaged_data_nat)

# Create a new column in data indicating whether each subject is in the new flip angle
data$flip_angle <- ifelse(data$sub %in% new_flip_angle_subs$sub, "new flip angle", "old flip angle")
data_stan$flip_angle <- ifelse(data_stan$sub %in% new_flip_angle_subs$sub, "new flip angle", "old flip angle")

averaged_data_stan$flip_angle <- ifelse(averaged_data_stan$sub %in% new_flip_angle_subs$sub, "new flip angle", "old flip angle")
averaged_data_nat$flip_angle <- ifelse(averaged_data_nat$sub %in% new_flip_angle_subs$sub, "new flip angle", "old flip angle")


# Define the echoes to iterate over
echoes <- c('1', '2', '3', '4')

# Initialize an empty data frame to store the results
result <- data.frame(
  echo = character(),
  mean_nat_new = double(),
  mean_nat_old = double(),
  mean_stan_new = double(),
  mean_stan_old = double(),
  stringsAsFactors = FALSE
)

# Loop over each echo
for (echo in echoes) {
  if (echo %in% c('stan_new', 'stan_old')) {
    # Skip calculations for stan_new and stan_old
    continue
  }
  
  averaged_data_nat <- as.data.frame(averaged_data_nat)
  averaged_data_stan <- as.data.frame(averaged_data_stan)
  
  # Calculate means for VS per echo and group
  mean_nat_new <- mean(as.numeric(averaged_data_nat[averaged_data_nat$echo == echo & averaged_data_nat$flip_angle == 'new flip angle', 'mean_nat']))
  mean_nat_old <- mean(as.numeric(averaged_data_nat[averaged_data_nat$echo == echo & averaged_data_nat$flip_angle == 'old flip angle', 'mean_nat']))
  mean_stan_new <- mean(as.numeric(averaged_data_stan[averaged_data_stan$flip_angle == 'new flip angle', 'vsmean_stan']))
  mean_stan_old <- mean(as.numeric(averaged_data_stan[averaged_data_stan$flip_angle == 'old flip angle', 'vsmean_stan']))
  
  # Add the results to the data frame
  result <- rbind(result, data.frame(
    echo = echo,
    mean_nat_new = mean_nat_new,
    mean_nat_old = mean_nat_old,
    mean_stan_new = mean_stan_new,
    mean_stan_old = mean_stan_old
  ))
}

# Convert the data from wide to long format for plotting
result_long <- tidyr::gather(result, key = "variable", value = "value", -echo)

# Add a new column for "optimally combined" before echo 1
result_long$echo <- factor(result_long$echo, levels = c('stan_new', 'stan_old', as.character(echoes)))

# Change the value of rows 9 to 16 to "Optimally combined"
result_long <- result_long %>%
  mutate(echo = if_else(row_number() %in% 9:16, "Optimally Comb.", echo))

# Add a column to data_stan named echo, where every row has "Optimally Comb."
averaged_data_stan$echo <- "Optimally Comb."
averaged_data_stan <- averaged_data_stan %>% distinct()

# Calculate SEM for each group in data
sem_data <- averaged_data_nat %>%
  group_by(echo, flip_angle) %>%
  summarize(mean = mean(vsmean_nat), sem = sd(vsmean_nat) / sqrt(n()))

# Calculate SEM for each group in data_stan
sem_data_stan <- averaged_data_stan %>%
  group_by(echo, flip_angle) %>%
  summarize(mean = mean(vsmean_stan), sem = sd(vsmean_stan) / sqrt(n()))

# Convert the echo column in sem_data to character
sem_data$echo <- as.character(sem_data$echo)

# Combine the SEM data frames
sem_data_combined <- bind_rows(sem_data, sem_data_stan)

# Combine the SEM data frames
sem_data_combined <- bind_rows(sem_data, sem_data_stan)
sem_data_combined$echo <- factor(sem_data_combined$echo, levels = c("Optimally Comb.", "1", "2", "3", "4", "5"))


# Merge the result_long data frame with the SEM data
#result_long <- merge(result_long, sem_data_combined, by = c("echo", "variable"))

# # List to store t-test results
# t_test_results <- list()
# 
# # Loop over each echo
# for (echo in echoes) {
#   # Convert echo to integer
#   echo_int <- as.integer(echo)
#   
#   # Subset the data for the current echo
#   echo_data <- subset(averaged_data_stan, echo == echo_int)
#   
#   # Perform t-test
#   t_test_result <- t.test(mean_stan ~ flip_angle, data = echo_data)
#   
#   # Store the result in the list
#   t_test_results[[echo]] <- t_test_result
# }
# 
# # Print the t-test results
# for (echo in echoes) {
#   cat("Echo:", echo, "\n")
#   print(t_test_results[[echo]])
#   cat("\n")
# }

# Subset the data for echo "Optimally Comb."
echo_data_comb <- subset(averaged_data_stan, echo == "Optimally Comb.")

# Perform t-test
t_test_result_comb <- t.test(vsmean_stan ~ flip_angle, data = echo_data_comb)

# Print the t-test result
print(t_test_result_comb)


# Define a theme with standardized settings
standard_theme <- function() {
  theme_minimal() +
    theme(
      axis.title = element_text(size = 12),  # Increase axis title size
      axis.text = element_text(size = 10),   # Increase axis text size
      legend.title = element_text(size = 0),  # Remove legend title
      legend.text = element_text(size = 12),  # Increase legend text size
      panel.background = element_rect(fill = "lightgrey"),
      plot.title = element_text(size = 14, hjust = 0.5),  # Center plot title
      panel.grid.major = element_line(color = "grey", size = 0.2),  # Set major gridlines
      panel.grid.minor = element_blank(),  # Remove minor gridlines
      axis.line = element_line(color = "black"),  # Set axis line color
      axis.ticks = element_line(color = "black")  # Set axis tick color
    )
}

# Plot the bar graph with SEM bars using the standardized theme
ggplot(sem_data_combined, aes(x = echo, y = mean, fill = flip_angle)) +
  geom_bar(stat = "identity", position = "dodge", color = "black") +
  geom_errorbar(aes(ymin = mean - sem, ymax = mean + sem), 
                position = position_dodge(width = 0.9), 
                width = 0.25, color = "black") +
  labs(title = "B)",
       x = "Echo",
       y = "Average Ventral Striatum tSNR",
       fill = "Variable") +
  scale_fill_manual(values = c("old flip angle" = "darkturquoise", "new flip angle" = "dodgerblue4")) +  # Adjust fill colors
  scale_y_continuous(limits = c(0, 55), breaks = seq(0, 50, by = 10)) +  # Set y-axis limits and breaks
  standard_theme()
