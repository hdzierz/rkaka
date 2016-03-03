# R API for Kaka

## Tools

- R/knitr
- Python 2/3
- Mongo connectors
- KAkAs restful API
- Jupyter notebooks in form of a Pyrat



## R

The R API is very similar to the python one. However, the installation is different and the return value will be a data frame.

### Installation

If you are on the above mentioned Kaka Pyrat instance just call library("rkaka"). Otherwise use:

```
devtools::install_github("hdzierz/rkaka")
```


### Use it

The syntax for the API is as follows:

```
Kaka.qry(realm='some_realm', qry='some_query', mode='a-mode') 
```

Whereby:

"realm" can currrently be:

- genotype
- seafood

"qry":

This is a pql query. For more info see: [pql](https://github.com/alonho/pql)

"mode":

- pql (default)
- mongo (can perform better for larger queries)

Return value:

The return value is an R data frame.

**Example:**

To obtain data from Kaka you run:

```
dat <- Kaka.qry('genotype', experiment=='gene_expression')
dat
```

Or more complicated:

```
dat <- Kaka.qry('genotype', "experiment=='gene_expression' and genotype==regex('^A123.*')")
dat
```


## DESeq2

## pathview



