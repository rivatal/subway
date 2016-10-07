function shut(list){
    if(close(list)){
	print list " failed to close" > "/dev/stderr";
    }
}
BEGIN{
file1 = "turnstile.html"

RS = "</a>"
FS = "/"
while((getline < file1) > 0){
    split($5, v, /"/)
    if(v[1] ~ /turnstile/)
	print v[1] > "./mta_data_files.txt"
}

shut(file1)
}
