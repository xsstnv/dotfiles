# Amass passive enumeration / from @nahamsec
am() {
  amass enum --passive -d $1 -json $1.json
  jq .name $1.json | sed "s/\"//g"| httprobe -c 60 | tee -a $1-domains.txt
}

# start sqlmap / from @nahamsec
sqlmap() {
  python ~/tools/sqlmap*/sqlmap.py -u $1
}

# from @DhiyaneshDk
firstRun() { 
  subfinder -silent -dL $1 | anew $2
}

# from @DhiyaneshDk
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

# ffuf deep recursive / @from rez0
ffuf_recursive() {
  mkdir -p recursive
  dom=$(echo $1 | unfurl format %s%d)
  ffuf -c -v -u $1/FUZZ -w $2 -H "User-Agent: Mozilla Firefox Mozilla/5.0" \
  -H "X-Bug-Bounty: rez0" -recursion -recursion-depth 5 -mc all -ac \
  -o recursive/recursive_$dom.csv -of csv $3
}

# from @rez0
nuclei_site() {
    echo $1 | nuclei -t cves/ -t exposed-tokens/ -t exposed-tokens/ \
		-t exposed-tokens/ -t vulnerabilities/ -t fuzzing/ -t misconfiguration/ \
		-t miscellaneous/dir-listing.yaml -pbar -c 30
}
 

# from @rez0
nuclei_file() {
    nuclei -l $1 -t cves/ -t exposed-tokens/ -t exposed-tokens/ \
		-t exposed-tokens/ -t vulnerabilities/ -t fuzzing/ -t misconfiguration/ \
		-t miscellaneous/dir-listing.yaml -pbar -c 50
}

# from @rez0
httprobemore(){
	httprobe -p http:8000 -p https:9443 -p http:8080 -p https:8443 -c 50 -t 1000
}

# tamper http verbs / from @rez0
tamper() {
    echo -n "$1: "; for i in GET POST HEAD PUT DELETE CONNECT OPTIONS TRACE PATCH ASDF; \
	do echo "echo -n \"$i-$(curl -k -s -X $i $1 -o /dev/null -w '%{http_code}') \""; done \
	| parallel -j 10 ; echo
}

# enumerate, filter and crawl / @from bugcrowd
efc() {
    subfinder -d $1 -silent | httpx -silent | hakrawler -plain | tr "[:punct:]" "\n" | sort -u
}
