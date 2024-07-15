# Install and load necessary packages
install.packages("ggpubr")
install.packages("dplyr")
install.packages("tidyr")
install.packages("ggplot2")

library(ggpubr)
library(dplyr)
library(tidyr)
library(ggplot2)

meta <- read.delim("metadata-with-prevalence-abundance-observed_features.tsv", header = TRUE, sep = "\t")
str(meta)

# Select the relevant columns for observed features
abundance <- meta %>%
  dplyr::select(Sample.ID, contains("Abundance"))

# Reshape the data to long format
long_ab <- abundance %>%
  tidyr::pivot_longer(cols = -Sample.ID, names_to = "Group", values_to = "Abundance")

# Clean the group names for better readability
long_ab$Group <- gsub("\\.Abundance", "", long_ab$Group)

# Define custom order
desired_order <- c("Nonresident", "Macrofungi", "Plantpathogens", "Ecm", "Lichenized", "Am")

# Convert Group to factor with levels in the desired order
long_ab$Group <- factor(long_ab$Group, levels = desired_order)

# Define custom labels
custom_labels <- c("Nonresident" = "Non-resident Fungi", 
                   "Macrofungi" = "Macro Fungi", 
                   "Plantpathogens" = "Plant Pathogens", 
                   "Ecm" = "ECM Fungi", 
                   "Lichenized" = "Lichenized Fungi", 
                   "Am" = "AM Fungi")

# Map the existing group names to the new labels
levels(long_ab$Group) <- custom_labels[levels(long_ab$Group)]

# Define the PDF file name and open the PDF device
pdf("abundance_by_group_plot.pdf", width = 8, height = 6)

# Create the box plot with jitter using ggboxplot
ggboxplot2 <- ggboxplot(long_ab, x = "Group", y = "Abundance",
                        title = "Abundance by Group", ylab = "Abundance",
                        color = "Group", palette = "jco", add = "jitter") +
  geom_jitter(aes(color = Group), width = 0.2, size = 1, alpha = 0.6) +
  stat_summary(fun.data = function(y) {
    mean_abundance <- mean(y)
    mean_percentage <- (mean_abundance / 3000) * 100
    data.frame(y = mean_abundance, label = paste0(round(mean_percentage, 2), "%"))
  },
  geom = "text", vjust = -3, size = 4, color = "black") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +  # Rotate x-axis labels to prevent overlap
  scale_y_continuous(limits = c(0, 3000))  # Set y-axis limit to 3,000

# Print the plot to the PDF
print(ggboxplot2)

# Close the PDF device
dev.off()
