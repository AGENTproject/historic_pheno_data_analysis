#! /usr/bin/bash

find -name '*ipynb' -not -path '*/.ipynb_checkpoints/*' \
-not -name 'figures_and_tables.ipynb' \
-print -exec jupyter execute --inplace {} \;
jupyter execute --inplace figures_and_tables.ipynb;
