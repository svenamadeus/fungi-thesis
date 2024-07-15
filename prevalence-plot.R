# Load necessary packages
install.packages("ggplot2")
library(ggplot2)
library(dplyr)

# Set the working directory and read the TSV file
meta <- read.delim("metadata-with-prevalence-abundance-observed_features.tsv", header = TRUE, sep = "\t")

# Inspect column names
print(names(meta))

# Calculate total samples
total_samples <- nrow(meta)

# Calculate prevalence for each group
prevalence_counts <- data.frame(
  Group = c("Total Samples", "Am", "Ecm", "Lichenized", "Plantpathogens", "Macrofungi", "Nonresident"),
  Count = c(total_samples,
            sum(meta$Am.Prevalence == "True", na.rm = "True"),
            sum(meta$Ecm.Prevalence == "True", na.rm = "True"),
            sum(meta$Lichenized.Prevalence == "True", na.rm = "True"),
            sum(meta$Plantpathogens.Prevalence == "True", na.rm = "True"),
            sum(meta$Macrofungi.Prevalence == "True", na.rm = "True"),
            sum(meta$Nonresident.Prevalence == "True", na.rm = "True"))
)

# Ensure the same order and colors as the previous plot
prevalence_counts$Group <- factor(prevalence_counts$Group, 
                                  levels = c("Total Samples", "Nonresident", "Macrofungi", "Plantpathogens", "Ecm", "Lichenized", "Am"))

# Define custom colors using the jco palette
palette_colors <- ggpubr::get_palette("jco", 6)
custom_colors <- c("Total Samples" = "grey", "Nonresident" = palette_colors[1], 
                   "Macrofungi" = palette_colors[2], "Plantpathogens" = palette_colors[3], 
                   "Ecm" = palette_colors[4], "Lichenized" = palette_colors[5], "Am" = palette_colors[6])

# Define custom labels
custom_labels <- c("Total Samples" = "Total Samples",
                   "Nonresident" = "Non-resident Fungi", 
                   "Macrofungi" = "Macro Fungi", 
                   "Plantpathogens" = "Plant Pathogens", 
                   "Ecm" = "ECM Fungi", 
                   "Lichenized" = "Lichenized Fungi", 
                   "Am" = "AM Fungi")

# Create the bar plot
ggbarplot <- ggplot(prevalence_counts, aes(x = Group, y = Count, fill = Group)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = Count), vjust = -0.5, size = 4, color = "black") +  # Add text labels
  scale_fill_manual(values = custom_colors, labels = custom_labels) +
  scale_x_discrete(labels = custom_labels) +  # Apply custom labels
  labs(title = "Prevalence of Groups", x = "Group", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels to prevent overlap

# Save the bar plot to a PDF
pdf("prevalence_by_group_bar_plot.pdf", width = 8, height = 6)
print(ggbarplot)
dev.off()
