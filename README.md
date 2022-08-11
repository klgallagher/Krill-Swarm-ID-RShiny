# Krill-Swarm-ID-RShiny

This RShiny was developed to plot, ID, and save data from Imaginex853 echosounders deployed on Slocum Electric Gliders in the austral summer of 2020 as part of Project SWARM. This app is available to serve as a framework for similar projects and datasets. 

Both the full app (app_full.R) and an example app (app_example.R) along with example data are provided in this repository. Due to the size of the data analyzed in the app, it is not possible to host the full dataset on GitHub, but a subset of the data are provided so that a smaller version of the app can be downloaded from this repository and examined. To test the example version of the app, download app_example.R and all provided .RData files. You will need to edit the file paths in app_example to direct the app to these files on your local machine. In the script, these areas are denoted as '/INSERT/PATH/TO/[filename].RData'. 

This app has 3 steps: 
1) Select data and plot - data are subsetted based on platform (UD vs UAF glider) and time (see note below), depth (0 - 1100 m, based on the instrument), dB threshold (determines color; defaults to 100 dB to include all possible returns), starting time of the plot, how many hours after the start time to include in the plot, and how many bins to remove from the top of the ping (Imaginex835 has 200, 0.5 m bins; this removes a number of bins [in bin #, not depth] from the top of the ping to reduce noise. 8 is the default). 
    	
	A quick note about time 'subsetting': the data used here are in long format, so the files are LARGE. Therefore, close inspection of the app code will reveal that the data for each platform are broken into 3 parts by date. Selecting the datetime will automatically match the time to the appropriate data 'chunk'. This was done to make the data managable in a local RStudio. If repurposing this app for a different use, this may or may not be necessary depending on the size of the data being used. 
	
	Another note about time: Over the course of the glider deployments, there were periods where the gliders were recovered and not collecting data. These occurred for mechanical reasons or to back up the data. If you select one of these time periods, no plot will appear. These periods were relatively short, with most being less than 24 hours. Setting the time window to the largest maximum time (10 hrs) is an easy way to scan the data for these missing periods. The UAF glider was recovered on 21 February 2020 and not redeployed. The UD glider was recovered on 11 March 2020. The example data provided for the example script does not contain any of these gaps. 

2) Isolate krill swarms - krill swarms observed in the data can then be highlighted with the cursor. The subset of the data is previewed below the plot. The data includes glider timestamp (timeGL), lat/lon position (m_gps_lat.lat and m_gps_lon.lon), glider-measured water pressure (sci_water_pressure.bar), 853 bin number (Bin), calibrated return from the 853 (value), raw depth of the bin (ping_depth; see below for correction), and ping color to help reduce plotting time (ping_col). 
    
		DEPTH CORRECTIONS: To account for pitch of the glider, the following equation was used to correct the bin depth following swarm annotation: 
            correctedDepth = (BinNumber * 0.5) * cos(gliderPitch - 22) + gliderDepth

3) Save data - Clicking the "Download Data" button will save the highlighted subset of the data to the local machine with the platform name and a numerical local timestamp. These downloaded csvs can then be compiled together, and matched to the glider data to determine the presence/absence of krill swarms.  

