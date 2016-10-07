import re
import os
import sys
path = "turnstile_data/"
files = os.listdir(path)

#This madness is to get everything past 10/18/2014, when the files contain station names.
post14 = re.compile("turnstile_1([56789][0-9]{4}|41(018|025|[1-9]{3})).txt$")
names = set()
if(len(sys.argv) == 2 and (sys.argv[1] == '-n' or sys.argv[1] == "-names")):
    for entry in files:
        if(re.match(post14, entry)):
        
            lines = open(path + entry).readlines()
            for line in lines:
                fields = line.split(",")
                names.add(fields[3])
    tsnames = open("turnstile_names.txt", "w")
    for name in names:
        tsnames.write(name + "\n")    
else:
    tsfiles = open("turnstile_files.txt", "w")
    for entry in files:
        if(re.match(post14, entry)):
            tsfiles.write(entry + "\n")
