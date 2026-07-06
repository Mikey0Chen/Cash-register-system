FROM maven:3.9.8-eclipse-temurin-11-alpine AS builder

WORKDIR /app

COPY pom.xml .
COPY src ./src

# 构建项目
RUN mvn clean package -DskipTests

FROM eclipse-temurin:11-jre-alpine

WORKDIR /app

# 复制 jar 包
COPY --from=builder /app/target/*.jar app.jar

# 设置时区
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/actuator/health || exit 1

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
