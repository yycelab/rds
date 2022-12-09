#!/bin/bash
# stop [-f]
# [-f] {conf.file} {external-networks} {sentinelnum}
# eg: 3 rds_master_slaves/sentinel.conf nt_rds_master_slaves nt_rds_master_slaves
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
  inputs=("$2" "$3" "$4")
else
  inputs=("$1" "$2" "$3")
fi

# declare vars
wdir="rds_sentinels"
network="nt_$wdir"
cdir=$(pwd)
if [[ "$cdir" = */scripts ]]; then
  cd ..
  cdir=$(pwd)
fi
echotitle="[sentinels]"
echo "$echotitle work dir $cdir"
conf="$cdir/configs/sentinel.conf"
yaml="$cdir/$wdir/compose.yaml"
script="$cdir/scripts/networks.sh"
if [[ $stop == 1 ]]; then
  docker-compose -f $yaml down
  if [[ $force == 1 ]]; then
    echo "$echotitle $($script rm $network)"
    rm -rf $wdir
    echo "$echotitle clean directories $wdir"
  fi
  exit 0
fi
sentinelnum=3
#初始化
if [ -n "${inputs[0]}" ]; then
  conf=${inputs[0]}
  if [ ! -f "$conf" ]; then
    conf="$cdir/$conf"
  fi
  if [ ! -f "$conf" ]; then
    echo "$conf can't found!"
    exit 1
  fi
  if [ -n "${inputs[1]}" ]; then
    OLD_IFS="$IFS"
    IFS=","
    external_networks="${inputs[1]}"
    echo "external networks: $external_networks"
    IFS=$OLD_IFS
    if [[ ${inputs[2]} -gt 3 ]]; then
      sentinelnum=${inputs[2]}
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
for ((i = 0; i < sentinelnum; i++)); do
  nodedir="sentinel$i"
  dconf="$wdir/$nodedir/conf"
  if [ ! -d $dconf ]; then
    mkdir -p $dconf
    echo "$echotitle ensure '$dconf' directory exists"
  fi
  cp -f $conf $dconf/sentinel.conf
  echo "$echotitle copy redis config file"
  cat >>$yaml <<EOF
 salve_$i:
    container_name: ${wdir}-slave$i
    command: redis-sentinel /usr/local/etc/redis/sentinel.conf
    image: myredis:7.0.3-alphine
    volumes:
      - ./$nodedir/conf:/usr/local/etc/redis/
      - ./$nodedir/data:/data:rw
    networks:
      $network:
EOF
  if [ -n "$external_networks" ]; then
    for item in "${external_networks[@]}"; do
      cat >>$yaml <<EOF
      $item:
EOF
    done
  fi
done

cat >>$yaml <<EOF
networks:
  $network:
    external: true
EOF
if [[ -n $external_networks ]]; then
  for item in "${external_networks[@]}"; do
    cat >>$yaml <<EOF
  $item:
    external: true
EOF
  done
fi

echo "$echotitle write $yaml success"

echo "$echotitle $($script $network)"

docker-compose -f $yaml up -d
