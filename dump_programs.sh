#!/bin/bash

get_scope(){

    #curl -sL https://github.com/projectdiscovery/public-bugbounty-programs/raw/master/chaos-bugbounty-list.json | jq -r '.programs[].domains | to_entries | .[].value' >> bbt.txt
    curl -sL https://github.com/arkadiyt/bounty-targets-data/raw/master/data/intigriti_data.json | jq -r '.[].targets.in_scope[] | select(.type=="url") |  [.endpoint] |@tsv' >> bbt.txt
    curl -sL https://github.com/arkadiyt/bounty-targets-data/blob/master/data/hackerone_data.json?raw=true | jq -r '.[].targets.in_scope[] | select(.asset_type=="URL") | [.asset_identifier] | @tsv' >> bbt.txt
    curl -sL https://github.com/arkadiyt/bounty-targets-data/raw/master/data/bugcrowd_data.json | jq -r '.[].targets.in_scope[] | select(.type=="website testing") | [.target] | @tsv' >> bbt.txt
    curl -sL https://github.com/arkadiyt/bounty-targets-data/raw/master/data/yeswehack_data.json | jq -r '.[].targets.in_scope[] | select(.type=="web-application")| [.target]| @tsv' >> bbt.txt
    #curl -sL https://github.com/arkadiyt/bounty-targets-data/raw/master/data/hackenproof_data.json | jq -r '.[].targets.in_scope[]| select(.type=="Web")| [.target] | @tsv' >> bbt.txt
    #curl -sL https://github.com/arkadiyt/bounty-targets-data/raw/master/data/federacy_data.json | jq -r '.[].targets.in_scope[] | select(.type=="website") | [.target] | @tsv' >> bbt.txt

    cat bbt.txt | tr ',' '\n' > new.txt
    sort -u new.txt -o bbt.txt
    rm -rf new.txt

    sed -i '
    s/\*\.//g ;
    s/^\.// ;
    s/http[s]*:\/\/// ;
    s/\/.*$// ;
    / /d 
    ' bbt.txt
    cat bbt.txt | tr -d '(' | tr -d ')' | tr -d '*' | sed '/\[/d ; s/^\.//' | sort -u > scope.txt
    rm -rf scope.temp bbt.txt
}

get_subs(){
    subfinder -silent -dL scope.txt -timeout 3 -t 10000 -nW -nC -o subs.temp
    cat subs.temp | sort -u | tac > subs.txt
    rm -rf subs.temp
}

cleanup(){
    if [[ $# -eq 1 ]]
    then
        zip -r open_programs_with_subdomains.zip scope.txt subs.txt && rm -rf scope.txt subs.txt
    else
        zip -r open_programs.zip scope.txt && rm -rf scope.txt
    fi 
}

main(){

    if [[ ! -f scope.txt ]]
    then
        get_scope
        echo "$(wc -l scope.txt) Domains dumped"
    fi

    if [[ $# -eq 1 && ! -f subs.txt  ]]
    then 
        get_subs
        echo "$(wc -l scope.txt) Domains dumped"
        echo "$(wc -l subs.txt) Subdomains dumped"
    fi

}

if [[ $# -eq 1 ]]
then
    main $1
    #cleanup $1
else
    main
    #cleanup
fi
