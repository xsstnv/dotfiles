alias assetfinder='~/go/bin/assetfinder'
alias chaos='~/go/bin/chaos'
alias dalfox='~/go/bin/dalfox'
alias ffuf='~/go/bin/ffuf'
alias gau='~/go/bin/gau'
alias gf='~/go/bin/gf'
alias hakrawler='~/go/bin/hakrawler'
alias unfurl='~/go/bin/unfurl'
alias unfurl='~/go/bin/waybackurls'

am() {
  amass enum --passive -d $1 -json $1.json
  jq .name $1.json | sed "s/\"//g"| httprobe -c 60 | tee -a $1-domains.txt
}

sqlmap() {
  python ~/tools/sqlmap*/sqlmap.py -u $1 
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
