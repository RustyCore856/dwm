#!/bin/bash

function get_bytes {
	# Find active network interface
	interface=$(ip route get 8.8.8.8 2>/dev/null| awk '{print $5}')
	line=$(grep $interface /proc/net/dev | cut -d ':' -f 2 | awk '{print "received_bytes="$1, "transmitted_bytes="$9}')
	eval $line
	now=$(date +%s%N)
}

function get_velocity {
	value=$1
	old_value=$2
	now=$3

	timediff=$(($now - $old_time))
	velKB=$(echo "1000000000*($value-$old_value)/1024/$timediff" | bc)
	if test "$velKB" -gt 1024
	then
		echo $(echo "$velKB/1024" | bc)MB/s
	else
		echo ${velKB}KB/s
	fi
}

get_bytes
old_received_bytes=$received_bytes
old_transmitted_bytes=$transmitted_bytes
old_time=$now

check_connect(){
	interface=$(ip route get 8.8.8.8 2>/dev/null| awk '{print $5}')
	line=$(grep $interface /proc/net/dev | cut -d ':' -f 2 | awk '{print "received_bytes="$1, "transmitted_bytes="$9}')
	sped=$(echo $line | sed -r "s/.*=(.*).*/\1/")
	if ["$sped" -eq 0]; then
		printf ""
	else 
		printf ""
	fi
}

print_date(){
	date '+%Y-%m-%d %l:%M:%S %p'
}

print_mem(){
	memfree=$(($(grep -m1 'MemAvailable:' /proc/meminfo | awk '{print $2}') / 1024))
	echo -e "$memfree"
}

dwm_weather() {
        printf "摒 %s" "$(curl -s wttr.in/Harbin?format=1 | grep -o "[-0-9].*")"
}

dwm_alsa () {
    VOL=$(amixer -M get Master | tail -n1 | sed -r "s/.*\[(.*)%\].*/\1/")
	VOLSTAT=$(amixer -M get Master | tail -n1 | sed -r "s/.*\[(.*)%\] \[(.*)\]/\2/")
    printf "%s" "$SEP1"
    if [ "$VOLSTAT" = "off" ]; then
        printf "ﱝ"
    else
        printf "墳: %s%%" "$VOL"
    fi
    printf "%s\n" "$SEP2"
}

get_bytes
vel_recv=$(get_velocity $received_bytes $old_received_bytes $now)
vel_trans=$(get_velocity $transmitted_bytes $old_transmitted_bytes $now)

xsetroot -name "| $(print_mem)M| $(check_connect) ↓$vel_recv ↑$vel_trans | $(dwm_alsa) | $(dwm_weather) | $(print_date) |"

exit 0
