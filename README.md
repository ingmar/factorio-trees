# Factorio Trees

This is a collection of Lua scripts that parse Factorio's data files and then use GraphViz to generate trees for recipe and technology dependencies.

![Partial screenshot](screenshot.png "Example")


# Prerequisites

* Lua
* GraphViz

## Mac OS X

    brew install lua graphviz

# Install

    git clone https://github.com/ingmar/factorio-trees.git
    cd factorio-trees
    make
    open *.pdf
    