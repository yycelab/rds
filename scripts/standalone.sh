#!/bin/bash
wdir="rds_standalone"
cdir=$(pwd)
if [[ "$cdir" = */scripts ]]; then
  cd ..
  cdir=$(pwd)
fi
echotitle="[standalone]"
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

if [ "$2" == "-f" ]; then
  rm -rf $wdir
  echo "$echotitle clean $wdir"
fi
dconf="$cdir/$wdir/conf"
if [ ! -d $dconf ]; then
  mkdir -p $dconf
  echo "$echotitle ensure '$dconf' directory exists"
fi
cp -f $conf $dconf/redis.conf
cp -f $cdir/libs/*.so $dconf/
cat>>$dconf/redis.conf<<EOF
loadmodule /usr/local/etc/redis/rebloom.so
loadmodule /usr/local/etc/redis/libredis_cell.so
EOF
echo "$echotitle copy redis config file"

cat >$yaml <<EOF
version: '3'
services:
  standalone:
    container_name: ${wdir}
    command: redis-server /usr/local/etc/redis/redis.conf
    image: myredis:7.0.3
    networks:
      $network:
    ports:
      - 6380:6379
    volumes:
      - ./conf:/usr/local/etc/redis/
      - ./data:/data:rw
    restart: always
    
networks:
  $network:
    external: true
EOF
echo "$echotitle write standalone.yaml success"
echo "$echotitle $($script $network)"
docker-compose -f $yaml up -d
