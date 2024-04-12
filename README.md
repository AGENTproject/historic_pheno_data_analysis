# historic_pheno_data_analysis

Analysis of wheat and barley historic data from [NPPC](https://www.vurv.sk/en/), [CREA-CI](https://www.crea.gov.it/web/cerealicoltura-e-colture-industriali) and [INIA](https://www.inia.es/en-en/units/Institutes%20and%20Centres/CRF): Calculation of heritability and BLUEs of traits of agronomic interest, in an easy-to-reuse manner thanks to notebooks and custom functions.

The analysis methods come from the data descriptors of IPK wheat and barley historical data:
- [Philipp, N. et al. Historical phenotypic data from seven decades of seed regeneration in a wheat ex situ collection. Sci Data 6, 137 (2019)](https://doi.org/10.1038/s41597-019-0146-y)
- [Gonzalez, M. et al. Unbalanced historical phenotypic data from seed regeneration of a barley ex situ collection. Sci Data 5, 180278 (2018)](https://doi.org/10.1038/sdata.2018.278)

The main packages used are:
- the [`tidyverse`](https://www.tidyverse.org/), [from conda-forge](https://anaconda.org/conda-forge/r-tidyverse)
- [`multtest`, Bioconductor package, from bioconda](https://bioconda.github.io/recipes/bioconductor-multtest/README.html)
- [`asreml`](https://vsni.co.uk/software/asreml-r)(proprietary R package)

Acknowledgements:
- to the IPK Quantitative Genetics group, for the guidance.
- to the NPPC, CREA-CI and INIA genebanks, for their collaboration.
