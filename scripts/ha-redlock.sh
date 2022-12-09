#!/bin/bash
wdir="rds_redlock"
cdir=$(pwd)
if [[ "$cdir" = */scripts ]]; then
    cd ..
    cdir=$(pwd)
fi
echotitle="[redlock]"
locknum=3

expose_port=6381
echo "$echotitle work dir $cdir"
conf="$cdir/configs/standalone.conf"
network="nt_$wdir"
script="$cdir/scripts/networks.sh"
yaml="$cdir/$wdir/compose.yaml"
if [ "$1" = "stop" ]; then
    docker-compose -f $yaml down
    if [ "$2" == "-f" ]; then
        echo "$echotitle $($script rm $network)"
        rm -rf $wdir
        echo "$echotitle clean directories $wdir"
    fi
    exit 0
fi
if [[ $1 -gt 3 ]]; then
    locknum=$1
fi

if [ "$2" == "-f" ]; then
    rm -rf $wdir
    echo "$echotitle clean $wdir"
fi
if [ ! -d $wdir ]; then
    mkdir $wdir
fi

cat >>$yaml <<EOF
version: '3'
services:
EOF

for ((i = 0; i < locknum; i++)); do
    dconf="$cdir/$wdir/lock-server$i/conf"
    if [ ! -d $dconf ]; then
        mkdir -p $dconf
        echo "$echotitle ensure '$dconf' directory exists"
    fi
    cp -f $conf $dconf/redis.conf
    echo "$echotitle copy redis config file"
    expose=$(expr $expose_port + $i)
    cat >>$yaml <<EOF
  lock_server$i:
    container_name: $wdir-s$i
    command: redis-server /usr/local/etc/redis/redis.conf
    image: myredis:7.0.3-alphine
    networks:
      $network:
    ports:
      - $expose:6379
    volumes:
      - ./lock-server$i/conf:/usr/local/etc/redis/
      - ./lock-server$i/data:/data:rw
    restart: always
EOF
done

cat >>$yaml <<EOF
networks:
  $network:
    external: true
EOF

echo "$echotitle write $yaml success"
echo "$echotitle $($script $network)"
docker-compose -f $yaml up -d
