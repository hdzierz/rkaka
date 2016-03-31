# R API for Kaka

## Tools

- R/knitr
- KAKA's restful API
- Jupyter notebooks in form of a Pyrat



## R

The R API is very similar to [PyKaka](https://github.com/hdzierz/PyKaka). It loads data from the database [Kaka](https://github.com/hdzierz/Kaka) using its RESTful API. 

Kaka runs using docker. The docker installation includes a Pyrat (Jupyter notebook) instance on port 8888. rkaka is pre-installed on that pyrat instance. 

### Installation

If you are on the above mentioned Kaka Pyrat instance just call library("rkaka"). Otherwise use:

```
devtools::install_github("hdzierz/rkaka")
```

### Use it

The syntax for the API is as follows:

```
kaka.qry(realm='some_realm', qry='some_query') 
```

Whereby:

"realm" can currrently be:

- genotype
- kiwifruit

"qry":

This is a pql query. For more info see: [pql](https://github.com/alonho/pql)

"mode":

- pql (default)
- mongo (can perform better for larger queries)

Return value:

The return value is an R data frame.

**Example:**

To obtain data from Kaka you run which loads an example data set:

```
dat <- kaka.qry('genotype', experiment=='Gene Expression')
dat
```

Or more complicated:

```
dat <- kaka.qry('genotype', "experiment=='Gene Expression' and gene==regex('^AT1G029.*')")
dat
```

Gene expression data (any data really) can be supplemented with exprimental design information similar to the old micro array targets file:

```
dat <- kaka.qry('design', "experiment=='Gene Expression'")
dat
```

```
	phenotype	condition	typ
1	PFD1001L3R1	treated	paired-end
2	PFD1001L3R2	treated	paired-end
3	PFD1001L4R1	treated	paired-end
4	PFD1001L4R2	treated	paired-end
5	PFD1002L3R1	untreated	paired-end
6	PFD1002L3R2	untreated	paired-end
7	PFD1002L4R1	untreated	paired-end
8	PFD1002L4R2	untreated	paired-end
```

## DESeq2

## pathview



