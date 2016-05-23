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

## Getting Data In

rkaka has the ability to process data into the database. All data will be associated with an Experiment as well as a DataSource. Each Experiment and DataSource has a unique name. These names are impartant as
 all operations (delete data, reload data, load data) will be associated with them. There cannot be two Experiments or DataSources with the same name. The Experiment also requires
some basic meta info (please see the configuration below).

The method you can use for sending data is called "send" and is part of the Kaka api:

```
Kaka.send(data,config)
```

Whereby:

- data is your data set which can be either a pandas DataFrame or an array of dicts. **The data needs a unique ID column!** 
- config is a configuration dict

**The configuration dict:**

The configuration dict needs the following entries:

- Experiment 
 - Code: A unique name of the experiment the data are associated with. Please use characters, numbers and underscores only.
 - Date: The Date of your experiment
 - Description: A brief description of your experiment
 - Password: Allocate a password. This will protect your experiment from others overriding your data.
 - Pi: Who is the PI of the experiment
 - Realm: The realm your experiment belongs to (e.g. Genotype or Seafood). You cannot create a new one. Please contact admin as above
 - Password: A password or key that will protect your experiment from others tampering with it
- DataSource
 - Format: Can only be **python_dict** at the moment
 - IdColumn: Your data requires a unique ID column
 - Name: This can be either a path to a file or a unique name of your data set
 - Group: Data might be grouped in an experiment like treatments [optional]
 - Creator: Who has craeted the data?
 - Contact: A contact email address 
 - Mode: Can be "Clean", "Override", "Append"

Just a wee explanation about the **Mode**:

**Override:** This will delete all data in the experiment for your DataSource before your data is loaded. 
**Clean:** This will delete all data in a DataSource associated with your experiment
**Append:** Append will not delete anything but append all data you specify to the DataSource in an Experiment 
**Destroy:** All above modes leave  trace of the experiment and DataSources. Destroy will also clean those.


** Example of a config dict for loading a hapmap into Kaka:**

```
config = list(
    "DataSource"= list(
        "Format"= "python_dict",
        "IdColumn"= "rs#" , 
        "Name"= '/tmp/',
        "Group"= "None",
        "Creator"= "Helge",
        "Contact"= "helge.dzierzon@plantandfood.co.nz"
    ),
    "Experiment"=list(
        "Code"= "HapMap_Test",
        "Date"= "2016-01-07",
        "Description"= "REST test",
        "Realm"= "Genotype",
        "Mode"= "Override",
        "Password"= "inkl67z",
        "Pi"= "Willi Wimmer",
        "Species"= "Cymbidium",
        "Password"= "your_password"
    )
)
```

## Configuring teh host and port

If you don't acccess the pyrat docker instance you  need to configure the host and port. PyKaka uses a cfg structure:

```
cfg["web_host"] = 'wkoppb31.pfr.co.nz'
cfg["web_port"] = "8001"
Kaka.qry(..., cfg=cfg)
Kaka.send(...,cfg=cfg)
```


