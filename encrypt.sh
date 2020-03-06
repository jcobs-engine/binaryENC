#!/bin/bash

function a_ascii() {
    local_command=$1
    if [ "$local_command" != ':s:' ]; then
	LC_CTYPE=C printf '%d' "'$local_command"
    else
	printf '32'
    fi
}

function a_bin() {
    local_command=$1

    b1=0
    b2=0
    b3=0
    b4=0
    b5=0
    b6=0
    b7=0
    b8=0

    if [ $local_command -ge 128 ]; then
	b1=1
	local_command=$(( $local_command - 128 ))
    fi
    if [ $local_command -ge 64 ]; then
	b2=1
	local_command=$(( $local_command - 64 ))
    fi
    if [ $local_command -ge 32 ]; then
	b3=1
	local_command=$(( $local_command - 32 ))
    fi
    if [ $local_command -ge 16 ]; then
	b4=1
	local_command=$(( $local_command - 16 ))
    fi
    if [ $local_command -ge 8 ]; then
	b5=1
	local_command=$(( $local_command - 8 ))
    fi
    if [ $local_command -ge 4 ]; then
	b6=1
	local_command=$(( $local_command - 4 ))
    fi
    if [ $local_command -ge 2 ]; then
	b7=1
	local_command=$(( $local_command - 2 ))
    fi
    if [ $local_command -ge 1 ]; then
	b8=1
	local_command=$(( $local_command - 1 ))
    fi

    echo -n "$b1$b2$b3$b4$b5$b6$b7$b8"
}

function a_switchcrypt() {
    local_txt=$( echo $1 | sed 's/./& /g;s/ $//' )
    local_key=$( echo $2 | sed 's/./& /g;s/ $//' )
    local_key=($local_key)
    returna=''
    a=0
    for i in $local_txt; do
	if [ "${local_key[$a]}" == "1" ]; then
	    if [ "$i" == "0" ]; then
		returna=$returna"1"
	    else
		returna=$returna"0"
	    fi
	else
	    returna=$returna"$i"
	fi
	
	a=$(( $a + 1 ))
    done
    echo $returna
}

# ===================================================== #
echo -en "\033[0m "
clear
a=0
while [ $COLUMNS -ge $a ]; do
    tput cup 0 $a
    echo -en "\033[0m="
    a=$(( $a + 1 ))
done
tput cup 0 $(( ( $COLUMNS / 2 ) - 4 ))
echo -en "\033[0m TEXT \033[0;1;43m\n"
a=0
while [ $COLUMNS -ge $a ]; do
    tput cup 1 $a
    echo -en "\033[1;43;37m "
    a=$(( $a + 1 ))
done
tput cup 1 0
read command
a=0
while [ $COLUMNS -ge $a ]; do
    tput cup 3 $a
    echo -en "\033[0m="
    a=$(( $a + 1 ))
done
tput cup 3 $(( ( $COLUMNS / 2 ) - 4 ))
echo -en "\033[0m KEY \033[0;1;43m\n"
a=0
while [ $COLUMNS -ge $a ]; do
    tput cup 4 $a
    echo -en "\033[1;41m "
    a=$(( $a + 1 ))
done
tput cup 4 0
read key
a=0
while [ $COLUMNS -ge $a ]; do
    tput cup 6 $a
    echo -en "\033[0m="
    a=$(( $a + 1 ))
done
tput cup 6 $(( ( $COLUMNS / 2 ) - 4 ))
echo -en "\033[0m HOST === [www.levi-jacobs.de/binaryENC/] \033[0;1;43m\n"
a=0
while [ $COLUMNS -ge $a ]; do
    tput cup 7 $a
    echo -en "\033[1;44m "
    a=$(( $a + 1 ))
done
tput cup 7 0
read host

echo -en "\033[0m"
clear

if [ "$host" == "" ]; then
    host='www.levi-jacobs.de/binaryENC/'
fi

keycapture=$key

keylen=${#key}

key=$( echo $key | sed 's/./& /g;s/ $//' )
out=''
keynum=0
for i in $key; do
    i=$( a_ascii $i )
    i=$( a_bin $i )
    out="$out $i"
    keynum=$(( $keynum + 1 ))
done

keynum=$(( $keynum - 1 ))

key=( $out )

command=${command// /:s:}
command=$( echo $command | sed 's/./& /g;s/ $//' )
command=${command//: s :/:s:}

i=0
while [ $i -lt 256 ]; do
    eval vh_$i='0'
    i=$(( $i + 1 ))
done


txtlen=0
for i in $command; do
    txt_1=$( a_ascii $i )
    vhtxt='vh_'$txt_1
    eval vh_$txt_1=$(( ${!vhtxt} + 1 ))
    txtlen=$(( $txtlen + 1 ))
done

wertdump=''
for i in $command; do
    txt_1=$( a_ascii $i )
    vhtxt='vh_'$txt_1
    wertdump=$wertdump' '${!vhtxt}
done

werte=(${wertdump%?})
readarray -t maxwerte < <(for a in "${werte[@]}"; do echo "$a"; done | sort -n )

for i in ${maxwerte[@]}; do
    maxwert=$i
done

code=''
vhdump=''
a=0
for i in $command; do
    
    tposx=$(( ( $COLUMNS / 9 ) * ( $RANDOM % 9 ) ))
    tposy=$(( ( $RANDOM % ( $LINES / ( $keynum + 3 ) ) ) * ( $LINES / ( $LINES / ( $keynum + 3 ) ) ) ))
    
    txt_1=$( a_ascii $i )
    txt_2=$( a_bin $txt_1 )

    vhtxt='vh_'$txt_1

    if [ ${!vhtxt} -eq $maxwert ]; then
	add='\033[41m'
    else
	add=''
    fi
    
    vh=$(( ( ( ( ${!vhtxt} * 1000 ) / $maxwert ) * ( $keynum ) ) / 1000 ))
    if [ $vh -eq 0 ]; then
	vh=1
    fi
    vhdump=$vhdump' '$vh
    
    tput cup $tposy $tposx
    echo -en "\033[4;31m$i ($vh)\033[0m"
    switchcrypt=$txt_2
    b=0
    while [ $b -lt $vh ]; do
	acap=$( printf "%.2i\n" $a )
	switchcrypt=$( a_switchcrypt $switchcrypt ${key[$a]} )
	tput cup $(( $b + 2 + $tposy )) $tposx
	echo -en "\033[0;44m$add$acap\033[0m$add > \033[1;32m$switchcrypt\033[0m"
	if [ $a -eq $keynum ]; then
	    a=0
	else
	    a=$(( $a + 1 ))
	fi
	b=$(( $b + 1 ))
    done
    while [ $b -lt $keynum ]; do
	tput cup $(( $b + 2 + $tposy )) $tposx
	echo -en "\033[0m$add             \033[0m"
	b=$(( $b + 1 ))
    done
    code=$code' '$switchcrypt

done

vhdump=${vhdump:1}

tanc1=$(( $RANDOM % 9 ))
tan1=$( a_ascii $tanc1 )
tan1=$( a_bin $tan1 )
tanc2=$(( $RANDOM % 9 ))
tan2=$( a_ascii $tanc2 )
tan2=$( a_bin $tan2 )
tanc3=$(( $RANDOM % 9 ))
tan3=$( a_ascii $tanc3 )
tan3=$( a_bin $tan3 )
tanc4=$(( $RANDOM % 9 ))
tan4=$( a_ascii $tanc4 )
tan4=$( a_bin $tan4 )
tan=$tan1' '$tan2' '$tan3' '$tan4' '

ntan=$tanc1$tanc2$tanc3$tanc4

nkey=$( echo -n "$keycapture$ntan" | md5sum )
nkey=${nkey%?}
nkey=${nkey%?}
nkey=${nkey%?}

vhdump=${vhdump// /'%20'}

nothing=$( ( curl $host'/write.php?tan='$ntan'&key='$nkey'&netkey='$vhdump 2>&1 ) >/dev/null )

clear
echo -e "\033[4mKEY:\033[0;1m"
echo $keycapture
echo -e "\n\033[4mCODE:\033[0;1m"
echo $tan$code
echo -en "\033[0m"
tput civis
read -sn1 hallo
tput cnorm
