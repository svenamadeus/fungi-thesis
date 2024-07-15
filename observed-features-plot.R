meta <- read.delim("metadata-with-prevalence-abundance-observed_features.tsv", header = TRUE, sep = "\t")
str(meta)

# Install and load necessary packages
install.packages("ggpubr")
install.packages("dplyr")
install.packages("tidyr")
install.packages("ggplot2")

library(ggpubr)
library(dplyr)
library(tidyr)
library(ggplot2)

# Select the relevant columns for observed features
observed_features <- meta %>%
  dplyr::select(Sample.ID, contains("Observed.Features"))

# Reshape the data to long format
long_of <- observed_features %>%
  tidyr::pivot_longer(cols = -Sample.ID, names_to = "Group", values_to = "Observed_Features")

# Clean the group names for better readability
long_of$Group <- gsub("\\.Observed.Features", "", long_of$Group)

# Remove "Total Observed Features" for better scaling
long_of <- long_of %>%
  filter(Group != "Total")

# Define custom order
desired_order <- c("Nonresident", "Macrofungi", "Plantpathogens", "Ecm", "Lichenized", "Am")

# Convert Group to factor with levels in the desired order
long_of$Group <- factor(long_of$Group, levels = desired_order)

# Define custom labels
custom_labels <- c("Nonresident" = "Non-resident Fungi", 
                   "Macrofungi" = "Macro Fungi", 
                   "Plantpathogens" = "Plant Pathogens", 
                   "Ecm" = "ECM Fungi", 
                   "Lichenized" = "Lichenized Fungi", 
                   "Am" = "AM Fungi")

# Map the existing group names to the new labels
levels(long_of$Group) <- custom_labels[levels(long_of$Group)]


# Define the PDF file name and open the PDF device
pdf("observed_features_by_group_plot.pdf", width = 8, height = 6)

# Create the box plot with jitter using ggboxplot
ggboxplot1 <- ggboxplot(long_of, x = "Group", y = "Observed_Features",
                    title = "Observed Features by Group", ylab = "Observed Features",
                    color = "Group", palette = "jco", add = "jitter") +
  geom_jitter(aes(color = Group), width = 0.2, size = 1, alpha = 0.6) +
  stat_summary(fun.data = function(y) data.frame(y = mean(y), label = round(mean(y), 2)),
               geom = "text", vjust = -3, size = 4, color = "black") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels to prevent overlap

# Print the plot to the PDF
print(ggboxplot1)

# Close the PDF device
dev.off()


# Install and load necessary packages
install.packages("ggpubr")
install.packages("dplyr")
install.packages("tidyr")
install.packages("ggplot2")

library(ggpubr)
library(dplyr)
library(tidyr)
library(ggplot2)

# Load the data
meta <- read.delim("metadata-with-prevalence-abundance-observed_features.tsv", header = TRUE, sep = "\t")

# Select the relevant columns for observed features
observed_features <- meta %>%
  dplyr::select(Sample.ID, contains("Observed.Features"))

# Reshape the data to long format
long_of <- observed_features %>%
  tidyr::pivot_longer(cols = -Sample.ID, names_to = "Group", values_to = "Observed_Features")

# Clean the group names for better readability
long_of$Group <- gsub("\\.Observed.Features", "", long_of$Group)

# Define custom order, including "Total" at the beginning
desired_order <- c("Nonresident", "Macrofungi", "Plantpathogens", "Ecm", "Lichenized", "Am", "Total")

# Convert Group to factor with levels in the desired order
long_of$Group <- factor(long_of$Group, levels = desired_order)

# Define custom labels, including a label for "Total"
custom_labels <- c("Nonresident" = "Non-resident Fungi", 
                   "Macrofungi" = "Macro Fungi", 
                   "Plantpathogens" = "Plant Pathogens", 
                   "Ecm" = "ECM Fungi", 
                   "Lichenized" = "Lichenized Fungi", 
                   "Am" = "AM Fungi",
                   "Total" = "Total Observed Features")

# Map the existing group names to the new labels
levels(long_of$Group) <- custom_labels[levels(long_of$Group)]


# Define the PDF file name and open the PDF device
pdf("observed_features_with_total_by_group_plot.pdf", width = 8, height = 6)

# Create the box plot with jitter using ggboxplot
ggboxplot1 <- ggboxplot(long_of, x = "Group", y = "Observed_Features",
                        title = "Observed Features by Group", ylab = "Observed Features",
                        color = "Group", palette = "jco", add = "jitter") +
  geom_jitter(aes(color = Group), width = 0.2, size = 1, alpha = 0.6) +
  stat_summary(fun.data = function(y) data.frame(y = mean(y), label = round(mean(y), 2)),
               geom = "text", vjust = -3, size = 4, color = "black") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels to prevent overlap

# Print the plot to the PDF
print(ggboxplot1)

# Close the PDF device
dev.off()
