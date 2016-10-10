#Sorted by date and time.
#sort -k7,7 -k8,8 turnstile_150704.txt --field-separator=, > sortedts.txt
BEGIN{
    FS = ","    
    file = "sortedts.txt"
    ncount = 0
    fsize = 0
    if(ARGV[1] == "n" || ARGV[1] == "negativecounters"){
	while((getline < file) > 0){
	    curr = $1 "," $2 "," $3 "," $4 "," $8 "," $7 "," $10
	    if($1 == ca && $2 == unit && scp == $3 && station == $4){
		diff = $10-lastentries
		if(diff < 0){
		    print lastall "\n" curr > "bad.txt"
		    ncount++
		}   
	    }
	    ca = $1
	    unit = $2
	    scp = $3
	    station = $4
	    lastentries = $10
	    lastall = $1 "," $2 "," $3 "," $4 "," $8 "," $7 "," $10
	    fsize++
	}
	print "Found " ncount " negative records out of " fsize " total records. (" ncount/fsize*100 " percent)." 
    }
    #The number of entries ticks upward and are recorded ~every four hours. To g#et the entries for a four hour period, the correlating rows need to be identifi#ed and subtracted. Rows that are connected share C.A, Unit, SCP, and STATION na#mes.
    else{
	OFS = ","
	while((getline < file) > 0){
	    #C.A. UNIT, SCP, STATION
	    curr = $1 "," $2 "," $3 "," $4 "," $5
	    diff = $10-lastentry[curr]
	    if(diff > 0 && diff < 100000){
		key = $7 #The date
		dict[key] += diff
	    }
	    lastentry[curr] = $10
	}	    
	for(x in dict){
	    print x, dict[x] > "julynums.csv"
	}
    }
}
