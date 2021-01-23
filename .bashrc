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

