# fungi-thesis
MSc Thesis - Trait-based Analysis of Human Gut Fungi

This github repository serves as appendix for the Master's Thesis "Trait-based Analysis of Human Gut Fungi" written by Sven Stoltenberg in July 2024. 

It contains all relevant files and scripts related to the making of the thesis. 


Files:

"bioinformatics-workflow-example.sh": this type of bash-script was used for every project individually, run on the ETH cluster computer Euler. Project IDs as well as primer sequences differ between projects. 

"metadata-merging.ipynb": this Jupyter Notebook describes the approach of merging together all individual metadata files. After a first general concatenation, columns were then homogenised according to identical information. 

"unite_taxonomy-fungaltraits-merging.iypnb": this Jupyter Notebook shows how the two tables were merged based on genus. Genera needed to be extracted from more complex taxonomic names. 

"prevalence-plot.R": RStudio Script used for creating the plot on prevalence

"abundance-plot.R": RStudio Script used for creating the plot on abundance

"observed-features-plot.R": RStudio Script used for creating the plot on observed features
