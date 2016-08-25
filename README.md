subway_research:

Both .sh files let you get gtfs data and turnstile data.
##1: join_gtfs.R
Joins together the various gtfs datasets and gives stations unique ids.

##2: Get turnstile names for matching:
####cat turnstile_data/turnstile*.txt | cut -d, -f4 | sort | uniq > turnstile_names.txt
####cat station_ids_trips.csv | cut -d, -f5 | sort | uniq > gtfs_names.txt

(After cat station_ids_trips.csv | cut -d, -f10 | sort | uniq | wc)
There are 440 unique station ids in the gtfs data.
There are 385 individual station names in the turnstile data && 377 in the gtfs
Why such a disparity?
-Different stations with the same name:
3- "Van Siclen Av"'s
2 "Wall St"'s

Test:
station_names_ids_disparity_test.R

##3: Match up the names from the above files.
match_names.py

##4: Small, more manual edits:
smalleredits.awk

##5: Merge it up! (gtfs and turnstile data)
merge.R

##6: Get average hourly entries, exits by station:
load_subway_trips.R

##7: Balance the entries and exits to make a closed system:
balance_entries_exits.R

##7.5: Make a train_travel.csv dataset with from and to stations?
make_routes.R

##8: Compute minimum cost flow?
Flow.py




