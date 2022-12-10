### redis镜像
```text
使用Dockerfile文件构建 myredis:7.0.3-alphine
docker build . -t myredis:7.0.3-alphine
解决两个问题:
 1.时区
 2.redis.conf文件映射
```

### redis场景实例管理
```text
rds.sh 提供了构建不同场景的redis docker服务实例
执行: ./rds.sh显示帮助
根据提示使用相应的参数命令
注意: 在构建cluster模式时,构建成功后.执行完需要输入yes确认,才能完成节点的master/slave的角色分配
想要构建一些定制化的节点.请使用script下的脚本,传入可定制化的参数
深度定制:需要根据自己需要修改一些配置和脚本参数
本脚本生成的docker实例都一学习为主.如果需要使用到生产环境.请自行完善配置文件;比如设置密码(requirepass).或者开起保护模式
```
### configs

```text
配置文件的模板
cluster.conf cluster模式redis server的配置模板
sentinel.conf 哨兵服务器配置模板
standalone.conf master节点/单机/redlock锁节点节点配置模板; slaver使用的模板,追加master节点信息
```

### scripts
```text
生成不同redis使用场景的脚本
```

### 所有的场景容器启动完

```text
CONTAINER ID   IMAGE                    COMMAND                 CREATED              STATUS              PORTS                     NAMES
a46ed1be5d5b   myredis:7.0.3-alphine   "docker-entrypoint.s…"   47 seconds ago       Up 45 seconds       0.0.0.0:6380->6379/tcp    rds_standalone
ffe0b09a7497   myredis:7.0.3-alphine   "docker-entrypoint.s…"   About a minute ago   Up About a minute   0.0.0.0:6383->6379/tcp    rds_redlock-s2
ae0728ed6540   myredis:7.0.3-alphine   "docker-entrypoint.s…"   About a minute ago   Up About a minute   0.0.0.0:6381->6379/tcp    rds_redlock-s0
2e8022161376   myredis:7.0.3-alphine   "docker-entrypoint.s…"   About a minute ago   Up About a minute   0.0.0.0:6382->6379/tcp    rds_redlock-s1
11fd9bfce42e   myredis:7.0.3-alphine   "docker-entrypoint.s…"   6 hours ago          Up 6 hours          6379/tcp                  rds_sentinels-slave0
b44b8b18ddf1   myredis:7.0.3-alphine   "docker-entrypoint.s…"   6 hours ago          Up 6 hours          6379/tcp                  rds_sentinels-slave1
f09893a82510   myredis:7.0.3-alphine   "docker-entrypoint.s…"   6 hours ago          Up 6 hours          6379/tcp                  rds_sentinels-slave2
667a7edbc1e0   myredis:7.0.3-alphine   "docker-entrypoint.s…"   6 hours ago          Up 6 hours          0.0.0.0:11112->6379/tcp   rds_replication-slave1
da6582246b74   myredis:7.0.3-alphine   "docker-entrypoint.s…"   6 hours ago          Up 6 hours          0.0.0.0:11111->6379/tcp   rds_replication-master
774dccc54c73   myredis:7.0.3-alphine   "docker-entrypoint.s…"   6 hours ago          Up 6 hours          0.0.0.0:11113->6379/tcp   rds_replication-slave2
f84855fb0a33   myredis:7.0.3-alphine   "docker-entrypoint.s…"   6 hours ago          Up About an hour    0.0.0.0:16379->6379/tcp   rds_cluster-server1
ad3e9485d6ae   myredis:7.0.3-alphine   "docker-entrypoint.s…"   6 hours ago          Up 6 hours          0.0.0.0:16380->6379/tcp   rds_cluster-server2
dfa2f2957d3a   myredis:7.0.3-alphine   "docker-entrypoint.s…"   6 hours ago          Up 6 hours          0.0.0.0:16387->6379/tcp   rds_cluster-server9
0c3e4218d6db   myredis:7.0.3-alphine   "docker-entrypoint.s…"   6 hours ago          Up 6 hours          0.0.0.0:16385->6379/tcp   rds_cluster-server7
280c5f2d53b3   myredis:7.0.3-alphine   "docker-entrypoint.s…"   6 hours ago          Up 6 hours          0.0.0.0:16386->6379/tcp   rds_cluster-server8
b51372f29464   myredis:7.0.3-alphine   "docker-entrypoint.s…"   6 hours ago          Up 6 hours          0.0.0.0:16383->6379/tcp   rds_cluster-server5
1e5aedf5993a   myredis:7.0.3-alphine   "docker-entrypoint.s…"   6 hours ago          Up 6 hours          0.0.0.0:16382->6379/tcp   rds_cluster-server4
ea1829d60b32   myredis:7.0.3-alphine   "docker-entrypoint.s…"   6 hours ago          Up 5 hours          0.0.0.0:16381->6379/tcp   rds_cluster-server3
450f0b28b61e   myredis:7.0.3-alphine   "docker-entrypoint.s…"   6 hours ago          Up 6 hours          0.0.0.0:16384->6379/tcp   rds_cluster-server6

Cluster使用的网络:nt_rds_cluster ,对应容器rds_cluster-server*
 docker network inspect nt_rds_cluster
[
    {
        "Name": "nt_rds_cluster",
        "Id": "6513f389c4a4ce5b02d9fa9f1e935831e54b8efe781696308d6830976e7069d0",
        "Created": "2022-12-09T10:03:18.091010656Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.40.0.0/16",
                    "IPRange": "172.40.5.0/24",
                    "Gateway": "172.40.5.254"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "0c3e4218d6db12e861531ff20b0188ed7339d937c6b39498e0287f2bec4aab0e": {
                "Name": "rds_cluster-server7",
                "EndpointID": "4306bab3f66abac4527212648aeb6ef2fe6c0095ecdd724cd2a45f615f83c8e1",
                "MacAddress": "02:42:ac:28:05:06",
                "IPv4Address": "172.40.5.6/16",
                "IPv6Address": ""
            },
            "1e5aedf5993a84d3e5ec8233fc1b6919b5491590a3551d4dde55e339c90e89ed": {
                "Name": "rds_cluster-server4",
                "EndpointID": "abbaf1dd93d33a0957c12119244d3161569f9aa427aca33498309c5bf8e1f22e",
                "MacAddress": "02:42:ac:28:05:03",
                "IPv4Address": "172.40.5.3/16",
                "IPv6Address": ""
            },
            "280c5f2d53b32970afcdc3714f231d571dab5d553e24146c9b81dd05f26936f9": {
                "Name": "rds_cluster-server8",
                "EndpointID": "9502ed2f01447ee6e54b4950d136e517d221ee66a087e02df79b48d214383d9a",
                "MacAddress": "02:42:ac:28:05:07",
                "IPv4Address": "172.40.5.7/16",
                "IPv6Address": ""
            },
            "450f0b28b61ec6dd1675cd76d196b3c2787153b89cc037498d64f29f00f060ed": {
                "Name": "rds_cluster-server6",
                "EndpointID": "4db2e39557131fc5c6561b6ec3f5e2292ffea7a0bc15328fb0b505094619d8b4",
                "MacAddress": "02:42:ac:28:05:05",
                "IPv4Address": "172.40.5.5/16",
                "IPv6Address": ""
            },
            "ad3e9485d6ae2440d6f32ad7ad2fc373f61bbe2d117b24bceb8c4202512a1fc6": {
                "Name": "rds_cluster-server2",
                "EndpointID": "2c07daa90cf30a9a76c5840a570b214e6b8a446a4d11230ab57bd5af6eb7eee3",
                "MacAddress": "02:42:ac:28:05:01",
                "IPv4Address": "172.40.5.1/16",
                "IPv6Address": ""
            },
            "b51372f2946483e273dddcaddee3a1b9becf61ed6bb9ccc4a2604283d1f4033a": {
                "Name": "rds_cluster-server5",
                "EndpointID": "7c0d1b36b38636d2a5c9552c9d3730ccf06db4a30f17565187be549f400a0fa2",
                "MacAddress": "02:42:ac:28:05:04",
                "IPv4Address": "172.40.5.4/16",
                "IPv6Address": ""
            },
            "dfa2f2957d3a82b5651efbebb941bd1364f332d60720700f79938734d223c993": {
                "Name": "rds_cluster-server9",
                "EndpointID": "ec726f35b17a6f24352252c9e1fdda563c91735b8168988c5fb1e3d15b58da63",
                "MacAddress": "02:42:ac:28:05:08",
                "IPv4Address": "172.40.5.8/16",
                "IPv6Address": ""
            },
            "ea1829d60b32262b42cabb1e673b59f5de9c403f6494b5eb1be054793abb928f": {
                "Name": "rds_cluster-server3",
                "EndpointID": "afed89b71ea4332abde09d1d7431a5766a44625e204cdd4bcd527643e0b87d12",
                "MacAddress": "02:42:ac:28:05:02",
                "IPv4Address": "172.40.5.2/16",
                "IPv6Address": ""
            },
            "f84855fb0a3320ab51ecda30a31b14c48d3e18e6c0dc3ddda4c7c0f2c0e722ef": {
                "Name": "rds_cluster-server1",
                "EndpointID": "e3a3a6eb094c3e80d84e6e6a18fb2a1bb6b7f03a2a92770f7dc68c6a92446385",
                "MacAddress": "02:42:ac:28:05:00",
                "IPv4Address": "172.40.5.0/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {}
    }
]
```

### 验证Cluster(HA)

```text
1:验证数据存储没有问题
docker exec -it rds_cluster-server1 /bin/sh
/data # redis-cli -c   #//注意这里使用了客户端的集群模式:-c
127.0.0.1:6379> CLUSTER NODES
49e9731c727b646b06e2a449ad78b3d48e03ee14 172.40.5.0:6379@16379 myself,slave fd98ae08e69bef3bbfbd2e7a8384058b6d8ea05c 0 1670603977000 11 connected
51e392a51bb8dae1af12d30f8747ef0a82a56a13 172.40.5.2:6379@16379 slave 357ebe1e190e8e6d5a4f8475dc32e19160156f07 0 1670603979769 10 connected
0df4ba5af13e79c1bbb9b8b72c69dc2953c96705 172.40.5.7:6379@16379 slave 1273b95d8849d854b6aaf79a938f4b43ea63d1b9 0 1670603978554 2 connected
fd98ae08e69bef3bbfbd2e7a8384058b6d8ea05c 172.40.5.5:6379@16379 master - 0 1670603978000 11 connected 0-5460
7b544a203458a2a9df97b3ead36244a41f9b3f6d 172.40.5.6:6379@16379 slave 1273b95d8849d854b6aaf79a938f4b43ea63d1b9 0 1670603979000 2 connected
35b1aaad9d9587b2c6593f4113989d1449dbb2f9 172.40.5.4:6379@16379 slave fd98ae08e69bef3bbfbd2e7a8384058b6d8ea05c 0 1670603979260 11 connected
1273b95d8849d854b6aaf79a938f4b43ea63d1b9 172.40.5.1:6379@16379 master - 0 1670603978250 2 connected 5461-10922
357ebe1e190e8e6d5a4f8475dc32e19160156f07 172.40.5.8:6379@16379 master - 0 1670603978000 10 connected 10923-16383
597921f21f6a4a6818817ea12b14336c91504b8f 172.40.5.3:6379@16379 slave 357ebe1e190e8e6d5a4f8475dc32e19160156f07 0 1670603979000 10 connected
127.0.0.1:6379> CLUSTER SLOTS
1) 1) (integer) 0
   2) (integer) 5460
   3) 1) "172.40.5.5"
      2) (integer) 6379
      3) "fd98ae08e69bef3bbfbd2e7a8384058b6d8ea05c"
      4) (empty array)
   4) 1) "172.40.5.0"
      2) (integer) 6379
      3) "49e9731c727b646b06e2a449ad78b3d48e03ee14"
      4) (empty array)
   5) 1) "172.40.5.4"
      2) (integer) 6379
      3) "35b1aaad9d9587b2c6593f4113989d1449dbb2f9"
      4) (empty array)
2) 1) (integer) 5461
   2) (integer) 10922
   3) 1) "172.40.5.1"
      2) (integer) 6379
      3) "1273b95d8849d854b6aaf79a938f4b43ea63d1b9"
      4) (empty array)
   4) 1) "172.40.5.6"
      2) (integer) 6379
      3) "7b544a203458a2a9df97b3ead36244a41f9b3f6d"
      4) (empty array)
   5) 1) "172.40.5.7"
      2) (integer) 6379
      3) "0df4ba5af13e79c1bbb9b8b72c69dc2953c96705"
      4) (empty array)
3) 1) (integer) 10923
   2) (integer) 16383
   3) 1) "172.40.5.8"
      2) (integer) 6379
      3) "357ebe1e190e8e6d5a4f8475dc32e19160156f07"
      4) (empty array)
   4) 1) "172.40.5.2"
      2) (integer) 6379
      3) "51e392a51bb8dae1af12d30f8747ef0a82a56a13"
      4) (empty array)
   5) 1) "172.40.5.3"
      2) (integer) 6379
      3) "597921f21f6a4a6818817ea12b14336c91504b8f"
      4) (empty array)
127.0.0.1:6379> set testkey 'test message'
-> Redirected to slot [4757] located at 172.40.5.5:6379
OK
172.40.5.5:6379> EXPIRE testkey 120
(integer) 1
172.40.5.5:6379> ttl testkey
(integer) 114

找到服务器对应的容器:rds_cluster-server6
docker exec -it rds_cluster-server6 /bin/sh
/data # redis-cli
127.0.0.1:6379> keys *
1) "testkey"
127.0.0.1:6379> ttl testkey
(integer) 93
127.0.0.1:6379> get testkey
"test message"
结论:集群模式数据写入成功

2:验证集群模式下自我恢复能力.master节点faildown,对应的slave节点切换为master继续服务
step1: 任意节点执行:(这里使用的是rds_cluster-server1)
redis-cli -c
127.0.0.1:6379> set testkey 'test master faildown'
-> Redirected to slot [4757] located at 172.40.5.5:6379
OK
172.40.5.5:6379> EXPIRE testkey 480
(integer) 1
172.40.5.5:6379> ttl testkey
(integer) 476
172.40.5.5:6379>CLUSTER NODES
1273b95d8849d854b6aaf79a938f4b43ea63d1b9 172.40.5.1:6379@16379 master - 0 1670604979000 2 connected 5461-10922
0df4ba5af13e79c1bbb9b8b72c69dc2953c96705 172.40.5.7:6379@16379 slave 1273b95d8849d854b6aaf79a938f4b43ea63d1b9 0 1670604979569 2 connected
597921f21f6a4a6818817ea12b14336c91504b8f 172.40.5.3:6379@16379 slave 357ebe1e190e8e6d5a4f8475dc32e19160156f07 0 1670604979000 10 connected
51e392a51bb8dae1af12d30f8747ef0a82a56a13 172.40.5.2:6379@16379 slave 357ebe1e190e8e6d5a4f8475dc32e19160156f07 0 1670604979972 10 connected
35b1aaad9d9587b2c6593f4113989d1449dbb2f9 172.40.5.4:6379@16379 slave fd98ae08e69bef3bbfbd2e7a8384058b6d8ea05c 0 1670604978958 11 connected
49e9731c727b646b06e2a449ad78b3d48e03ee14 172.40.5.0:6379@16379 slave fd98ae08e69bef3bbfbd2e7a8384058b6d8ea05c 0 1670604978554 11 connected
fd98ae08e69bef3bbfbd2e7a8384058b6d8ea05c 172.40.5.5:6379@16379 myself,master - 0 1670604977000 11 connected 0-5460
357ebe1e190e8e6d5a4f8475dc32e19160156f07 172.40.5.8:6379@16379 master - 0 1670604979059 10 connected 10923-16383
7b544a203458a2a9df97b3ead36244a41f9b3f6d 172.40.5.6:6379@16379 slave 1273b95d8849d854b6aaf79a938f4b43ea63d1b9 0 1670604979000 2 connected

step2:关闭master节点: rds_cluster-server6(ip:172.40.5.5)
docker stop rds_cluster-server6

step3:再次查看节点状态
172.40.5.5:6379> CLUSTER NODES
Error: Operation timed out

step4:重新登录redis客户端,查看节点状态:master节点已经从172.40.5.5切换到172.40.5.4;172.40.5.5在集群中标记为mater,fail;之前存储的testkey还在
/data # redis-cli -c
127.0.0.1:6379> CLUSTER NODES
49e9731c727b646b06e2a449ad78b3d48e03ee14 172.40.5.0:6379@16379 myself,slave 35b1aaad9d9587b2c6593f4113989d1449dbb2f9 0 1670605093000 12 connected
51e392a51bb8dae1af12d30f8747ef0a82a56a13 172.40.5.2:6379@16379 slave 357ebe1e190e8e6d5a4f8475dc32e19160156f07 0 1670605093080 10 connected
0df4ba5af13e79c1bbb9b8b72c69dc2953c96705 172.40.5.7:6379@16379 slave 1273b95d8849d854b6aaf79a938f4b43ea63d1b9 0 1670605092471 2 connected
fd98ae08e69bef3bbfbd2e7a8384058b6d8ea05c 172.40.5.5:6379@16379 master,fail - 1670605018610 1670605016181 11 connected
7b544a203458a2a9df97b3ead36244a41f9b3f6d 172.40.5.6:6379@16379 slave 1273b95d8849d854b6aaf79a938f4b43ea63d1b9 0 1670605093484 2 connected
35b1aaad9d9587b2c6593f4113989d1449dbb2f9 172.40.5.4:6379@16379 master - 0 1670605094491 12 connected 0-5460
1273b95d8849d854b6aaf79a938f4b43ea63d1b9 172.40.5.1:6379@16379 master - 0 1670605094592 2 connected 5461-10922
357ebe1e190e8e6d5a4f8475dc32e19160156f07 172.40.5.8:6379@16379 master - 0 1670605094592 10 connected 10923-16383
597921f21f6a4a6818817ea12b14336c91504b8f 172.40.5.3:6379@16379 slave 357ebe1e190e8e6d5a4f8475dc32e19160156f07 0 1670605093180 10 connected
127.0.0.1:6379> get testkey
-> Redirected to slot [4757] located at 172.40.5.4:6379
"test master faildown"

step5:docker start rds_cluster-server6,拉起容器

step6:查看rds_cluster-server6是否重新加入集群: 172.40.5.5标识fail消失.角色slave(master切换到slave)
172.40.5.4:6379> CLUSTER NODES
1273b95d8849d854b6aaf79a938f4b43ea63d1b9 172.40.5.1:6379@16379 master - 0 1670605162284 2 connected 5461-10922
357ebe1e190e8e6d5a4f8475dc32e19160156f07 172.40.5.8:6379@16379 master - 0 1670605161277 10 connected 10923-16383
597921f21f6a4a6818817ea12b14336c91504b8f 172.40.5.3:6379@16379 slave 357ebe1e190e8e6d5a4f8475dc32e19160156f07 0 1670605162791 10 connected
51e392a51bb8dae1af12d30f8747ef0a82a56a13 172.40.5.2:6379@16379 slave 357ebe1e190e8e6d5a4f8475dc32e19160156f07 0 1670605162000 10 connected
7b544a203458a2a9df97b3ead36244a41f9b3f6d 172.40.5.6:6379@16379 slave 1273b95d8849d854b6aaf79a938f4b43ea63d1b9 0 1670605162000 2 connected
fd98ae08e69bef3bbfbd2e7a8384058b6d8ea05c 172.40.5.5:6379@16379 slave 35b1aaad9d9587b2c6593f4113989d1449dbb2f9 0 1670605161000 12 connected
49e9731c727b646b06e2a449ad78b3d48e03ee14 172.40.5.0:6379@16379 slave 35b1aaad9d9587b2c6593f4113989d1449dbb2f9 0 1670605163296 12 connected
35b1aaad9d9587b2c6593f4113989d1449dbb2f9 172.40.5.4:6379@16379 myself,master - 0 1670605160000 12 connected 0-5460
0df4ba5af13e79c1bbb9b8b72c69dc2953c96705 172.40.5.7:6379@16379 slave 1273b95d8849d854b6aaf79a938f4b43ea63d1b9 0 1670605162000 2 connected

step7:查看这次切换为master(rds_cluster-server5,ip:172.40.5.4)节点的replica是否包含刚刚拉起的节点rds_cluster-server6(ip:172.40.5.5):成功
172.40.5.4:6379> CLUSTER MYID
"35b1aaad9d9587b2c6593f4113989d1449dbb2f9"
172.40.5.4:6379> CLUSTER REPLICAS 35b1aaad9d9587b2c6593f4113989d1449dbb2f9
1) "49e9731c727b646b06e2a449ad78b3d48e03ee14 172.40.5.0:6379@16379 slave 35b1aaad9d9587b2c6593f4113989d1449dbb2f9 0 1670606015357 12 connected"
2) "fd98ae08e69bef3bbfbd2e7a8384058b6d8ea05c 172.40.5.5:6379@16379 slave 35b1aaad9d9587b2c6593f4113989d1449dbb2f9 0 1670606015357 12 connected"
172.40.5.4:6379>

```
