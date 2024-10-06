FROM eclipse-temurin:8-jre-alpine

# 安装 OpenSSH
RUN apk add --no-cache openssh

# 将 restart.sh 脚本添加到 Docker 镜像的 /data 目录中
ADD restart.sh /root/restart.sh

# 将 init.sh 脚本添加到 Docker 镜像的 /root 目录中
ADD init.sh /root/init.sh

# 使 /root/init.sh 脚本可执行
RUN chmod +x /root/init.sh

# 在运行 Docker 容器时执行 /root/init.sh 脚本
ENTRYPOINT ["/bin/sh", "/root/init.sh"]

EXPOSE 22/tcp
VOLUME /data
