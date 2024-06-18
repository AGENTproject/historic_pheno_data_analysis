# historic_pheno_data_analysis

Analysis of wheat and barley historic data from 8 AGENT genebanks : Calculation of heritability and BLUEs of traits of agronomic interest, in an easy-to-reuse manner thanks to notebooks and custom functions.

The analysis methods come from the article of Philipp et al. (2018) [Leveraging the Use of Historical Data Gathered During Seed Regeneration of an ex Situ Genebank Collection of Wheat](https://doi.org/10.3389/fpls.2018.00609).

The main packages used are:

- the [`tidyverse`](https://www.tidyverse.org/) metapackage, [from conda-forge](https://anaconda.org/conda-forge/r-tidyverse)
- [`multtest`](https://bioconductor.org/packages/3.18/bioc/html/multtest.html), Bioconductor package, [from bioconda](https://bioconda.github.io/recipes/bioconductor-multtest/README.html)
- [`asreml`](https://vsni.co.uk/software/asreml-r)(proprietary R package)

Acknowledgements:

- to the IPK Quantitative Genetics group, for the hospitality and guidance.
- to the CREA-CI and INIA genebanks, for their hospitality, and to all genebanks for their collaboration.
