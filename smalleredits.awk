BEGIN{
    a["howard bch jfk"] = "Howard Beach - JFK Airport"
    a["twenty third st"] = "23 St"
    a["thirty third st"] = "33 St"
    a["e tremont av"] = "West Farms Sq - E Tremont Av"
    a["jfk jamaica ct1"] = "Jamaica Center - Parsons/Archer"
    a["e 177 st parkch"] ="Parkchester"
    a["81 st museum"] ="81 St - Museum of Natural History"
    a["jfk howard bch"] ="Howard Beach - JFK Airport"
    a["ditmars bl 31 s"] ="Astoria - Ditmars Blvd"
    a["union tpk kew g"] ="Kew Gardens - Union Tpke"
    a["barclays center"] ="Atlantic Av - Barclays Ctr"
    a["greenwood 111"] ="111 St"
    a["rit roosevelt"] ="Roosevelt Island"
    a["7 av 53 st"] ="7 Av"
    a["jamaica center"] ="Jamaica Center - Parsons/Archer"
    a["van wyck blvd"] ="Briarwood - Van Wyck Blvd"
    a["lefferts blvd"] ="Ozone Park - Lefferts Blvd"
    a["washington 36 a"] ="36 Av"
    a["e 143 st"] ="E 143 St - St Mary's St"
    a["hoyt st astoria"] ="Astoria Blvd"
    a["stillwell av"] ="Coney Island - Stillwell Av"
    a["5 av bryant pk"] ="42 St - Bryant Pk"
    a["broadway 31 st"] = "Broadway"
    a["orchard beach"] ="Pelham Bay Park"
    a["forest parkway"] ="85 St - Forest Pkwy"
    a["242 st"] ="Van Cortlandt Park - 242 St"
    a["westchester sq"] ="Westchester Sq - E Tremont Av"
    a["bushwick av"] ="Bushwick Av - Aberdeen St"
    a["elderts lane"] ="75 St"
    a["eastern pkwy"] ="Eastern Pkwy - Brooklyn Museum"
    a["flatbush av"] ="Flatbush Av - Brooklyn College"
    a["court sq 23 st"] ="Court Sq"
    a["roosevelt av"] ="74 St - Broadway"
    a["morrison av"] ="Morrison Av- Sound View"
    a["broadway lafay"] ="Broadway-Lafayette St"
    a["lexington av"] ="Lexington Av/59 St"
    a["dyre av"] ="Eastchester - Dyre Av"
    a["main st"] ="Flushing - Main St"
    a["42 st times sq"] ="Times Sq - 42 St"
    a["42 st pa bus te"] ="42 St - Port Authority Bus Terminal"
    a["42 st grd cntrl"] ="Grand Central - 42 St"
    a["eern pkwy"] = "Eastern Pkwy - Brooklyn Museum"
    a["broadway eny"] = "Broadway Jct"
    a["wchester sq"] = "None"
    a["van alston 21st"] = "21 St"
    a["21 st"] = "21 St - Queensbridge"
    

    file = "matchtable.txt"
    outfile = "smalleredits.txt"
    FS = ","
    OFS = ", "
    count = 0
    
    while((getline < file) > 0){
	#print tolower(stop), $2
	stop = $1
	#print stop
	if ($2 >= 0 && tolower(stop) in a){
	    print stop, 0, a[stop], $4 > outfile
	}
#	    print 0, a[stop], $2 #
#	}
	else{
	    print $0 > outfile
	}

    }
}
	
