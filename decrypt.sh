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

function b_ascii() {
    echo $1 | awk '{ printf("%c",$0); }'
}

function b_bin() {
    local_command=$( echo $1 | sed 's/./& /g;s/ $//' )

    a=0
    returna=0
    for q in $local_command; do
	if [ $q -eq 1 ]; then
	    if [ $a -eq 0 ]; then
		returna=$(( $returna + 128 ))
	    elif [ $a -eq 1 ]; then
		returna=$(( $returna + 64 ))
	    elif [ $a -eq 2 ]; then
		returna=$(( $returna + 32 ))
	    elif [ $a -eq 3 ]; then
		returna=$(( $returna + 16 ))
	    elif [ $a -eq 4 ]; then
		returna=$(( $returna + 8 ))
	    elif [ $a -eq 5 ]; then
		returna=$(( $returna + 4 ))
	    elif [ $a -eq 6 ]; then
		returna=$(( $returna + 2 ))
	    elif [ $a -eq 7 ]; then
		returna=$(( $returna + 1 ))
	    fi
	fi
	a=$(( $a + 1 ))
    done
    echo -n $returna
}

function switchcrypt() {
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
echo -en "\033[0m CODE \033[0;1;43m\n"
a=0
while [ $COLUMNS -ge $a ]; do
    tput cup 1 $a
    echo -en "\033[1;43;37m "
    a=$(( $a + 1 ))
done
a=0
while [ $COLUMNS -ge $a ]; do
    tput cup 2 $a
    echo -en "\033[1;43;37m "
    a=$(( $a + 1 ))
done
a=0
while [ $COLUMNS -ge $a ]; do
    tput cup 3 $a
    echo -en "\033[1;43;37m "
    a=$(( $a + 1 ))
done
a=0
while [ $COLUMNS -ge $a ]; do
    tput cup 4 $a
    echo -en "\033[1;43;37m "
    a=$(( $a + 1 ))
done
a=0
while [ $COLUMNS -ge $a ]; do
    tput cup 5 $a
    echo -en "\033[1;43;37m "
    a=$(( $a + 1 ))
done
tput cup 1 0
read command
a=0
while [ $COLUMNS -ge $a ]; do
    tput cup 7 $a
    echo -en "\033[0m="
    a=$(( $a + 1 ))
done
tput cup 7 $(( ( $COLUMNS / 2 ) - 4 ))
echo -en "\033[0m KEY \033[0;1;43m\n"
a=0
while [ $COLUMNS -ge $a ]; do
    tput cup 8 $a
    echo -en "\033[1;41m "
    a=$(( $a + 1 ))
done
tput cup 8 0
read key
a=0
while [ $COLUMNS -ge $a ]; do
    tput cup 10 $a
    echo -en "\033[0m="
    a=$(( $a + 1 ))
done
tput cup 10 $(( ( $COLUMNS / 2 ) - 4 ))
echo -en "\033[0m HOST === [www.levi-jacobs.de/binaryENC/] \033[0;1;43m\n"
a=0
while [ $COLUMNS -ge $a ]; do
    tput cup 11 $a
    echo -en "\033[1;44m "
    a=$(( $a + 1 ))
done
tput cup 11 0
read host

echo -en "\033[0m"
clear

if [ "$host" == "" ]; then
    host='www.levi-jacobs.de/binaryENC/'
fi

tan=''
a=0
for i in $command; do
    if [ $a -lt 4 ]; then
	ntan=$( b_bin $i )
	ntan=$( b_ascii $ntan )
	tan=$tan$ntan
    fi
    a=$(( $a + 1 ))
done

command=${command:36}

nkey=$( echo -n "$key$tan" | md5sum )
nkey=${nkey%?}
nkey=${nkey%?}
nkey=${nkey%?}

nk=$( curl $host'read.php?tan='$tan'&key='$nkey 2>/dev/null )

nk=($nk)

keylen=${#key}

key=$( echo $key | sed 's/./& /g;s/ $//' )
key=($key)
text=''
a=0
c=0
for i in $command; do
    echo -en "\n\033[4m$i (${nk[$c]})\033[0m\n"
    switchcrypt=$i
    b=${nk[$c]}
    while [ $b -gt 0 ]; do
	nowkey=$( a_ascii ${key[$a]} )
	nowkey=$( a_bin $nowkey )
	switchcrypt=$( switchcrypt $switchcrypt $nowkey )
	echo -en "$a > $switchcrypt\n"
	if [ $a -eq $(( $keylen - 1 )) ]; then
	    a=0
	else
	    a=$(( $a + 1 ))
	fi
	b=$(( $b - 1 ))
    done
    nt=$( b_bin $switchcrypt )
    nt=$( b_ascii $nt )
    text=$text$nt
    c=$(( $c + 1 ))
done


clear
echo -e "\n\033[4mTEXT:\033[0m"
echo $text


echo ""
