# Krill-Swarm-ID-RShiny

This RShiny was developed to plot, ID, and save data from Imaginex853 echosounders deployed on Slocum Electric Gliders in the austral summer of 2020 as part of Project SWARM. A paper is currently in prep to Scientific Reports to describe this app and the data it collected in terms of diel vertical migration behaviors of zooplankton in Palmer Deep Canyon. A DOI will be published here upon acceptance and publication. This app is available to serve as a framework for similar projects and datasets. 

This app has 3 steps: 
1) Select data and plot - data are subsetted based on platform (UD vs UAF glider) and time (see note below), depth (0 - 1100 m, based on the instrument), dB threshold (determines color; defaults to 100 dB to include all possible returns), starting time of the plot, how many hours after the start time to include in the plot, and how many bins to remove from the top of the ping (Imaginex835 has 200, 0.5 m bins; this removes a number of bins [in bin #, not depth] from the top of the ping to reduce noise. 8 is the default). 
    A quick note about time 'subsetting': the data used here are in long format, so the files are LARGE. Therefore, close inspection of the app code will reveal that the data for each platform are broken into 3 parts by date. Selecting the datetime will automatically match the time to the appropriate data 'chunk'. This was done to make the data managable in a local RStudio. If repurposing this app for a different use, this may or may not be possible depending on the size of the data being used. 

2) Isolate krill swarms - krill swarms observed in the data can then be highlighted with the cursor. The subset of the data is previewed below the plot. The data includes glider timestamp (timeGL), lat/lon position (m_gps_lat.lat and m_gps_lon.lon), glider-measured water pressure (sci_water_pressure.bar), 853 bin number (Bin), calibrated return from the 853 (value), raw depth of the bin (ping_depth; see below for correction), and ping color to help reduce plotting time (ping_col). 
    DEPTH CORRECTIONS: To account for pitch of the glider, the following equation was used to correct the bin depth: 
            correctedDepth = (BinNumber * 0.5) * cos(gliderPitch - 22) + gliderDepth

3) Save data - Clicking the "Download Data" button will save the highlighted subset of the data to the local machine with the platform name and a numerical local timestamp. These downloaded csvs can then be compiled together, and matched to the glider data to determine the presence/absence of krill swarms.  
