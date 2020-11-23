#!/bin/bash -e

## clean long running vstest dockers and server namespace
while read -r img name date time tshift tzname cmd status; do
    echo $img $name $date $time $cmd
    t1=$(date -u -d "$date $time" "+%s")
    t2=$(date -u "+%s")
    timediff=$((t2 - t1))
    # if the docker has been created for 8 hours, remove them
    if [[ $timediff -gt 28800 ]]; then
        if [[ $img == "debian:jessie" ]]; then
            echo "remove base container $name"
            docker rm -f $name
            ip netns list | grep ${name}-srv | awk '{print $1}' | xargs -I {} sudo ip netns delete {}
        elif [[ $cmd == "\"/usr/bin/supervisord\"" || $cmd =~ \"/usr/local/bin/supe.*\" ]]; then
            echo "remove vs container $name"
            docker rm -f $name
        fi
    fi
done < <(docker ps -a --format "{{.Image}} {{.Names}} {{.CreatedAt}} {{.Command}} {{.Status}}")
