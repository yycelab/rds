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