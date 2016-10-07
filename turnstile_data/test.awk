#sort -k 7,7 turnstile_150704.txt --field-separator=, > sortedts.txt
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
    else{
	OFS = ","
	while((getline < file) > 0){
	    curr = $1 "," $2 "," $3 "," $4
	    diff = $10 - lastentries
	    if($1 == ca && $2 == unit && scp == $3 && station == $4 && diff > 0 && diff < 100000){
		key = $7 #The date
		dict[key] += diff
		lastentry[curr] = $10
	    }
	    else{
		if(lastentry[curr]){
		    print(lastentry[curr], " exists for ", curr)
		    diff = $10 - lastentry[curr]
		    if(diff > 0 && diff < 100000)
			dict[$7] += diff
		}
	    }
	    ca = $1
	    unit = $2
	    scp = $3
	    station = $4
	    lastentries = $10
	    lastall = $1 "," $2 "," $3 "," $4 "," $8 "," $7 "," $10
	}	    
	for(x in dict){
	    print x, dict[x] >> "julynums.csv"
	}
    }
}
