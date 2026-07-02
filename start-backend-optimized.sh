#!/bin/bash

# 鸡尾酒收银系统后端启动脚本（内存优化版 - 2C2G）
# 适用于低配置服务器

cd "$(dirname "$0")/backend"

echo "正在启动后端服务（内存优化模式）..."

# JVM 内存参数（总共分配约 512M）
JAVA_OPTS="-Xms256m -Xmx512m"

# 垃圾回收优化
JAVA_OPTS="$JAVA_OPTS -XX:+UseG1GC"
JAVA_OPTS="$JAVA_OPTS -XX:MaxGCPauseMillis=200"
JAVA_OPTS="$JAVA_OPTS -XX:G1HeapRegionSize=4m"

# 元空间优化
JAVA_OPTS="$JAVA_OPTS -XX:MetaspaceSize=128m"
JAVA_OPTS="$JAVA_OPTS -XX:MaxMetaspaceSize=256m"

# 压缩指针和字符串优化
JAVA_OPTS="$JAVA_OPTS -XX:+UseCompressedOops"
JAVA_OPTS="$JAVA_OPTS -XX:+UseStringDeduplication"

# 关闭不必要的功能
JAVA_OPTS="$JAVA_OPTS -Djava.awt.headless=true"
JAVA_OPTS="$JAVA_OPTS -Dfile.encoding=UTF-8"

# 启动应用
export JAVA_OPTS
/opt/maven/bin/mvn spring-boot:run -Dspring-boot.run.jvmArguments="$JAVA_OPTS" > /tmp/backend-startup.log 2>&1 &

echo "后端服务已在后台启动"
echo "日志文件: /tmp/backend-startup.log"
echo "端口: 8080"
echo ""
echo "查看日志: tail -f /tmp/backend-startup.log"
echo "停止服务: pkill -f spring-boot:run"
