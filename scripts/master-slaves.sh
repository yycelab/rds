#!/usr/bin/env bash
# stop [-f]
# [-f] {network} {ip_prefix} {begin} {slave_num}

stop=0
# 标记删除工作目录 1 true
force=0

if [ "$1" == "stop" ]; then
    stop=1
    if [ "$2" == "-f" ]; then
        force=1
    fi
elif [ "$1" == "-f" ]; then
    force=1
    inputs=($2 $3 $4 $5)
else
    inputs=($1 $2 $3 $4)
fi

# declare vars
wdir="rds_master_slaves"
network="nt_$wdir"
cdir=$(pwd)
if [[ "$cdir" = */scripts ]]; then
    cd ..
    cdir=$(pwd)
fi
echotitle="[master-slaves]"
echo "$echotitle work dir $cdir"
conf="$cdir/configs/standalone.conf"
yaml="$cdir/$wdir/compose.yaml"
if [[ $stop == 1 ]]; then
    docker-compose -f $yaml down
    if [[ $force == 1 ]]; then
        echo "$echotitle $($script rm $network)"
        rm -rf $wdir
        echo "$echotitle clean directories $wdir"
    fi
    exit 0
fi

ipprefix="172.50.5"
iprange="172.50.5.0/24"
gateway="172.50.5.254"
subnet="172.50.0.0/16"
script="$cdir/scripts/networks.sh"
port=11111
ipstart=0
slavenum=2
builnet=1
#初始化
if [ -n "${inputs[0]}" ]; then
    network=${inputs[0]}
    builnet=0
    if [ -n "${inputs[1]}" ]; then
        ipprefix=${inputs[1]}
        if [[ ${inputs[2]} -gt -1 ]]; then
            ipstart=${inputs[2]}
            if [[ ${inputs[3]} -gt 0 ]]; then
                slavenum=${inputs[3]}
            fi
        fi
    fi
fi

if [[ $force == 1 ]]; then
    rm -rf $wdir
    echo "$echotitle clean $wdir"
fi
if [ ! -d $cdir/$wdir ]; then
    mkdir $cdir/$wdir
    echo "$echotitle ensure '$cdir/$wdir' directory exists"
fi
cat >$yaml <<EOF
version: '3'
services:
EOF
for ((i = 0; i < (slavenum + 1); i++)); do
    nodedir="master"
    nodeip="$ipprefix.$(($ipstart + $i))"
    exposeport=$(($i + $port))
    if [ $i -gt 0 ]; then
        nodedir="salve$i"
    fi

    dconf="$wdir/$nodedir/conf"
    if [ ! -d $dconf ]; then
        mkdir -p $dconf
        echo "$echotitle ensure '$dconf' directory exists"
    fi
    cp -f $conf $dconf/redis.conf
    echo "$echotitle copy redis config file"
    if [ $i -gt 0 ]; then
        cat >>$dconf/redis.conf <<EOF
#slave config
replicaof $ipprefix.$ipstart 6379
replica-serve-stale-data yes
replica-read-only yes
repl-diskless-sync yes
repl-diskless-sync-delay 5
# masteruser <username>

EOF
        cat >>$yaml <<EOF
 salve_$i:
    container_name: ${wdir}-slave$i
    command: redis-server /usr/local/etc/redis/redis.conf
    image: myredis:7.0.3-alphine
    networks:
      $network:
        ipv4_address: $nodeip
    ports:
      - $exposeport:6379
    volumes:
      - ./$nodedir/conf:/usr/local/etc/redis/
      - ./$nodedir/data:/data:rw
EOF
    else
        # generate master service
        cat >>$yaml <<EOF
 master:
    container_name: ${wdir}-master
    command: redis-server /usr/local/etc/redis/redis.conf
    image: myredis:7.0.3-alphine
    networks:
      $network:
        ipv4_address: $nodeip
    ports:
      - $exposeport:6379
    volumes:
      - ./$nodedir/conf:/usr/local/etc/redis/
      - ./$nodedir/data:/data:rw
EOF
    fi
done

cat >>$yaml <<EOF
networks:
  $network:
    external: true
EOF

# write a sentinel.conf
cat >>$cdir/$wdir/sentinel.conf <<EOF
port 6000
sentinel monitor $wdir-$port $ipprefix.$ipstart 6379 2
sentinel down-after-milliseconds $wdir-$port 5000
sentinel failover-timeout $wdir-$port 60000
sentinel parallel-syncs $wdir-$port 1
logfile 'sentinel.log'
dir ./
EOF

echo "$echotitle write $yaml success"
if [[ $builnet == 1 ]]; then
    echo "$echotitle $($script $network $subnet $gateway $iprange)"
fi
docker-compose -f $yaml up -d
