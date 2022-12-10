#!/bin/bash
# 参数说明
# 建立网关:{network_name} {subnet}  {gateway} {ip_range} {driver}
# eg: mynetwork 172.20.0.0/16 172.20.5.254 172.20.5.0/24
# 移除网关: rm {network_name}
echotitle="[network]"
if [ -z "$1" ]; then
  echo "$echotitle invalid input args"
  exit 1
fi
if [ "$1" == "rm" ]; then
  if [ -z "$2" ]; then
    echo "$echotitle must spec the network name for removing"
    exit 1
  fi
  echo "$echotitle docker network rm $2"
  res=$(docker network rm "$2")
  if [ "$2" = "$res" ]; then
    echo "$echotitle network removed $2 success"
    exit 0
  else
    echo "$echotitle network removed $2 faile! $res"
    exit 1
  fi
fi

find=$(docker network ls | grep $1)
if [ -n "$find" ]; then
  echo "$echotitle $1 is exist,skipped!"
  exit 0
fi

params="--driver=$5"
if [ -z "$5" ]; then
  params="--driver=bridge"
  if [ -n "$2" ]; then
    params="$params --subnet=$2"
    if [ -n "$3" ]; then
      params="$params --gateway=$3"
      if [ -n "$4" ]; then
        params="$params --ip-range=$4"
      fi
    fi
  fi
fi

echo "$echotitle docker network create $params $1"
cmd=$(docker network create $params $1)
if [ ${#cmd} == 64 ]; then
  echo "$echotitle network created $1 success"
  exit 0
else
  echo "$echotitle network created $1 failed! $cmd"
  exit 1
fi
