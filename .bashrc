# Reconnaissance

am(){ #runs amass passively and saves to json
amass enum --passive -d $1 -json $1.json
jq .name $1.json | sed "s/\"//g"| httprobe -c 60 | tee -a $1-domains.txt
}

# Vulnerability scanning

sqlmap(){
python ~/tools/sqlmap*/sqlmap.py -u $1 
}

