FROM redis:7.0.3
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 
RUN echo 'Asia/Shanghai'>/etc/timezone
# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
# RUN apk update 
# RUN apk add --no-cache libgcc
# RUN apk add --no-cache libc6-compat
COPY redis.conf /usr/local/etc/redis/redis.conf
CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]
