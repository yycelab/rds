#!/usr/bin/env bash
wdir="rds_cluster"
cdir=$(pwd)
if [[ "$cdir" = */scripts ]]; then
    cd ..
    cdir=$(pwd)
fi
echotitle="[clusters]"
nodenum=3
masters=3
replica=0
expose_port=16379
echo "$echotitle work dir $cdir"
conf="$cdir/configs/cluster.conf"
network="nt_$wdir"
subnet="172.40.0.0/16"
ipstart="172.40.5"
iprange="$ipstart.0/24"
gateway="172.40.5.254"
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
if [ "$1" == "-f" ]; then
    rm -rf $wdir
    echo "$echotitle clean $wdir"
    if [[ $2 -gt 0 ]]; then
        replica=$2
    fi
    if [[ $3 -gt 3 ]]; then
        masters=$3
    fi
else
    if [[ $1 -gt 0 ]]; then
        replica=$1
    fi
    if [[ $2 -gt 3 ]]; then
        masters=$2
    fi
fi
if [[ $replica -gt 0 ]]; then
    nodenum=$(($masters * $replica + $masters))
fi

echo "$echotitle cluster init $nodenum nodes"

if [ ! -d $wdir ]; then
    mkdir $wdir
fi

cat >$yaml <<EOF
version: '3'
services:
EOF
nodes=""
for ((i = 0; i < nodenum; i++)); do
    order=$(($i + 1))
    nodeip="$ipstart.$i"
    nodes="$nodes $nodeip:6379"
    node="server-node$order"
    dconf="$cdir/$wdir/$node/conf"
    if [ ! -d $dconf ]; then
        mkdir -p $dconf
        echo "$echotitle ensure '$dconf' directory exists"
    fi
    cp -f $conf $dconf/redis.conf
    echo "$echotitle copy redis config file"
    expose=$(($expose_port + $i))
    cat >>$yaml <<EOF
  cluster_node$i:
    container_name: $wdir-server$order
    command: redis-server /usr/local/etc/redis/redis.conf
    image: myredis:7.0.3-alphine
    networks:
      $network:
        ipv4_address: $nodeip
    ports:
      - $expose:6379
    volumes:
      - ./$node/conf:/usr/local/etc/redis/
      - ./$node/data:/data:rw
    restart: always
EOF
done

cat >>$yaml <<EOF
networks:
  $network:
    external: true
EOF

echo "$echotitle write $yaml success"
echo "$echotitle $($script $network $subnet $gateway $iprange)"
docker-compose -f $yaml up -d
init_cluster="redis-cli --cluster create $nodes --cluster-replicas $replica"

# todo 自动化
# docker exec -it $wdir-server1 $init_cluster&

echo "$init_cluster"