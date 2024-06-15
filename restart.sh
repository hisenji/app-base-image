#!/bin/sh

# 设置你的jar文件的路径
JAVA_BIN="/opt/java/openjdk/bin/java"
JAR_ARGS="JAR_ARGS_PLACEHOLDER"
JAR_FILE="JAR_FILE_PLACEHOLDER"
JAVA_CMD="$JAVA_BIN $JAR_ARGS -jar $JAR_FILE"

# 查找正在运行的Java进程
PID=$(ps aux | grep $JAR_FILE | grep -v grep | awk '{print $1}')

# 如果找到了进程，杀掉它
if [ -n "$PID" ]; then
    echo "Killing old process..."
    kill $PID
    sleep 5
fi

# 启动新的Java进程
echo "Starting new process..."
nohup $JAVA_CMD > /dev/null 2>&1 &

exit 0
