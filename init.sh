#!/bin/sh

# exit script if return code !=0
set -e

# 检查标记文件是否存在
if [ -f /root/.init ]; then
    echo "init.sh has already been executed."
else
    # 执行初始化操作
    echo "Running the init.sh..."

    # 添加一个新用户
    adduser -D app
    # 使用 /dev/urandom 生成随机密码
    password=$(head /dev/urandom | tr -dc 'A-Za-z0-9!@#$%^&*()' | head -c 18 ; echo '')
    echo "Generated password: ${password}"
    # 使用生成的密码修改用户密码
    echo "app:${password}" | chpasswd

    # 创建项目文件夹
    if [ ! -d "/data" ]; then
        mkdir /data
    fi
    chown app:app /data
    chmod 755 /data

    # 生成 SSH 密钥
    ssh-keygen -Aq
    # 创建 .ssh 目录并设置权限
    mkdir -p /home/app/.ssh && chmod 700 /home/app/.ssh
    # 使用环境变量来设置公钥
    echo "$SSH_PUBLIC_KEY" > /home/app/.ssh/authorized_keys
    # 设置 .ssh 目录和 authorized_keys 文件的所有者
    chown -R app:app /home/app/.ssh && chmod 600 /home/app/.ssh/authorized_keys
    # 修改 sshd_config 文件以禁用密码登录开启公钥验证
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication no/PasswordAuthentication no/g' /etc/ssh/sshd_config
    sed -i 's/#PubkeyAuthentication no/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
    sed -i 's/PubkeyAuthentication no/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
    #sed -i 's/#UsePAM no/UsePAM yes/g' /etc/ssh/sshd_config
    #sed -i 's/UsePAM no/UsePAM yes/g' /etc/ssh/sshd_config
    #sed -i 's/#UsePAM yes/UsePAM yes/g' /etc/ssh/sshd_config

    # 生成 jar 重启脚本
    cp -f /root/restart.sh /data/restart.sh
    chown app:app /data/restart.sh
    chmod +x /data/restart.sh
    sed -i 's|JAR_ARGS_PLACEHOLDER|'"$JAR_ARGS"'|g' /data/restart.sh
    sed -i 's|JAR_FILE_PLACEHOLDER|'"$JAR_FILE"'|g' /data/restart.sh

    # 创建标记文件
    touch /root/.init

    echo "init.sh executed."
fi

/usr/sbin/sshd -f /etc/ssh/sshd_config -D

exec "$@"
