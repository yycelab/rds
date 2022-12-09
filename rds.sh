#!/bin/bash
# [h|std(standalone)|c(cluster)|m(sentinel)|r(replica)|lock]
if [ -z "$1" ] || [ "$1" == "h" ]; then
    echo ""
    echo "usage: [command [subcommand] [option]]"
    echo "available command:"
    echo "     h help info."
    echo "   std create a standalone redis server"
    echo "     c create a redis's cluster (3masters,2replicas) with 9 server nodes"
    echo "     m create a sentinel cluster (3 sentinels),port:6000"
    echo "     r create a replication(1master,2slaves)"
    echo "  lock create 3 redis server(standalone) for redlock"
    echo "subcommand:"
    echo "  stop stop services and destroy the compose.yaml file spec resources."
    echo "command(std|c|m|r|lock) option:"
    echo "    -f remove all auto dir's directory,remove the internal spec network"
else
    force=0
    args=""
    exec=""
    if [ "$2" == "-f" ] || [ "$3" == "-f" ]; then
        force=1
    fi
    if [ "$2" == "stop" ]; then
        args=" $2"
        if [ $force == 1 ]; then
            args="$args -f"
        fi
    else
        if [ $force == 1 ]; then
            args=" -f"
        fi
    fi

    if [ "$1" == "std" ]; then
        exec="./scripts/standalone.sh"
    elif [ "$1" == "c" ]; then
        if [ "$2" != "stop" ]; then
            args="$args 2"
        fi
        exec="./scripts/ha-cluster.sh"
    elif [ "$1" == "m" ]; then
        if [ "$2" != "stop" ]; then
            env_replcation_name="rds_replication"
            env_sentinel_conf="$env_replcation_name/sentinel.conf"
            env_replcation_network="nt_$env_replcation_name"
            args="$args $env_sentinel_conf $env_replcation_network"
        fi
        exec="./scripts/ha-sentinel.sh"
    elif [ "$1" == "r" ]; then
        exec="./scripts/replication.sh"
    elif [ "$1" == "lock" ]; then
        exec="./scripts/ha-redlock.sh"
    else
        echo "command '$1' not found!"
    fi
    if [ -n "$exec" ]; then
        echo "[rds-exec] $exec $args"
        $exec $args
    fi
fi
