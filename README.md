microplate parser toolbox
-------------------------
Description of functions, workflow and configuration files.
For a typical workflow, refer to demo.m

* Authors: Ce Gao
* Created: 2013-05-30
* Revised:
* Toolbox: microplate parser

Typical workflow
----------------
importAssayData: import data from raw data files, construct structure, uses:
  1. readPlateList:  return featureData
  2. readPlateConf:  read Plateconf file
  3. readPlateFile:  read OD and GFP, import them to assayData, uses:
  4. importFun:      design specific for our data format

Output Data structure
---------------------
```
data
    .assayData
        .OD:  an array, zeros(nTotalWells, nTime)
        .GFP: an array, zeros(nTotalWells, nTime)
    .featureData: Note: all fields below are vectors of size (nTotalWells,:)
        .plate:    plate serial number   
        .layout:   layout type
        .repPlate: plate replicates
        .control:  containing type of control in the well
        .chemical: different chemical
        .conc:     different chemical concentration
        .gene:     genes
        .pathway:  pathway
        .metaData  
            .dataPath:       directory the data/conf files
            .plateConfFile:  plate configuration file name
            .plateListFile:  plate list file name
            .dataFiles:      cell(nPlates,1), data file names      
            .nPlates:        total plate number
            .nLayout:        distinct plate types
            .nWells:         well number on each plate
            .nTotalWells:    nWells*nPlates
            .nTimePoints:    time points
            .timeCreated:    time
            .lastModified:   time
            .lastAccessedBy: function name
```

Configuration files
-------------------
###### Platelist.txt

* Layout:  different plate layouts, (wca.featureData.layout); 
* Replicate: experimental replication,(wca.featureData.replicate); 
* Chemical: denotes different toxicant,(wca.featureData.chemical)

The first 2 lines are shown:

    Filename Layout Replicate Chemical
    BaP.txt 1 1 1

###### Plateconf.txt

* Wells:         total well number on a single plate
* Layouts:       total types of unique layouts
* TimePoints:    number of time points sampled
* Layout:        types of layout
* Well:          well number on the plate
* ControlStatus: sample control status
* Gene
* Pathway
* Concentration

The first 6 lines are shown here:

    Wells: 60                 
    Layouts: 2                 
    TimePoints: 10                 
    Layout Well ControlStatus Gene Pathway Concentration
    1 A01 NA NA NA -1
    1 A02 media NA NA 0
