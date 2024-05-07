#! /usr/bin/bash

micromamba run -n jupyter find -name '*.ipynb' -print -exec jupyter execute {} \;
