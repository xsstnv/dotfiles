# Amass passive enumeration / from @nahamsec
am() {
  amass enum --passive -d $1 -json $1.json
  jq .name $1.json | sed "s/\"//g"| httprobe -c 60 | tee -a $1-domains.txt
}

# start sqlmap / from @nahamsec
sqlmap() {
  python ~/tools/sqlmap*/sqlmap.py -u $1
}

firstRun() { 
  subfinder -silent -dL $1 | anew $2
}

secondRun() {
  while true; do subfinder -dL $1 -all | anew $2 | httpx | nuclei -t nuclei-templates/ | notify ; sleep 3600; done
}

goclean() {
 local pkg=$1; shift || return 1
 local ost
 local cnt
 local scr

 # Clean removes object files from package source directories (ignore error)
 go clean -i $pkg &>/dev/null

 # Set local variables
 [[ "$(uname -m)" == "x86_64" ]] \
 && ost="$(uname)";ost="${ost,,}_amd64" \
 && cnt="${pkg//[^\/]}"

 # Delete the source directory and compiled package directory(ies)
 if (("${#cnt}" == "2")); then
  rm -rf "${GOPATH%%:*}/src/${pkg%/*}"
  rm -rf "${GOPATH%%:*}/pkg/${ost}/${pkg%/*}"
 elif (("${#cnt}" > "2")); then
  rm -rf "${GOPATH%%:*}/src/${pkg%/*/*}"
  rm -rf "${GOPATH%%:*}/pkg/${ost}/${pkg%/*/*}"
 fi

 # Reload the current shell
 source ~/.bashrc
}

# ffuf quickhits list / @from rez0
ffuf_quick() {
	dom=$(echo $1 | unfurl format %s%d)
	ffuf -c -v -u $1/FUZZ -w quick.txt \
	-H "User-Agent: Mozilla Firefox Mozilla/5.0" \
	-H "X-Bug-Bounty: rez0" -ac -mc all -o quick_$dom.csv \
	-of csv $2 -maxtime 360 $3
}

# ffuf deep recursive (this alias takes a wordlist as a parameter unlike ffuf_quick) / @from rez0
ffuf_recursive() {
  mkdir -p recursive
  dom=$(echo $1 | unfurl format %s%d)
  ffuf -c -v -u $1/FUZZ -w $2 -H "User-Agent: Mozilla Firefox Mozilla/5.0" \
  -H "X-Bug-Bounty: rez0" -recursion -recursion-depth 5 -mc all -ac \
  -o recursive/recursive_$dom.csv -of csv $3
}

# Using ffuf to find vhosts (a special wordlist I have + subs that resolve to internal IPs) / @from rez0
ffuf_vhost() {
	dom=$(echo $1 | unfurl format %s%d)
	ffuf -c -u $1 -H "Host: FUZZ" -w vhosts.txt \
	-H "X-Bug-Bounty: rez0" -ac -mc all -fc 400,404 -o vhost_$dom.csv \
	-of csv -maxtime 120
}

nuclei_site() {
    echo $1 | nuclei -t cves/ -t exposed-tokens/ -t exposed-tokens/ \
		-t exposed-tokens/ -t vulnerabilities/ -t fuzzing/ -t misconfiguration/ \
		-t miscellaneous/dir-listing.yaml -pbar -c 30
}
 
nuclei_file() {
    nuclei -l $1 -t cves/ -t exposed-tokens/ -t exposed-tokens/ \
		-t exposed-tokens/ -t vulnerabilities/ -t fuzzing/ -t misconfiguration/ \
		-t miscellaneous/dir-listing.yaml -pbar -c 50
}
