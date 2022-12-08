FROM redis:7.0.3-alpine
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 
RUN echo 'Asia/Shanghai'>/etc/timezone
COPY redis.conf /usr/local/etc/redis/redis.conf
CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]
