#!/bin/bash
# 修复生产环境前端财务统计功能的脚本

echo "开始修复前端容器..."

# 1. 修改 Financial.js 文件，将 API 调用改为使用 /api 前缀
echo "正在修改 Financial.js..."
docker exec cocktail-frontend sed -i 's|D="http://localhost:8080"|D="/api"|g' /usr/share/nginx/html/assets/Financial-*.js 2>/dev/null

# 2. 验证修改
echo "验证修改..."
if docker exec cocktail-frontend grep 'D="/api"' /usr/share/nginx/html/assets/Financial-*.js >/dev/null 2>&1; then
    echo "✅ Financial.js 已成功修改"
else
    echo "❌ 修改失败"
    exit 1
fi

# 3. 测试 API 访问
echo "测试 API 访问..."
response=$(curl -s http://localhost:8081/api/financial/today)
if echo "$response" | grep -q '"code":200'; then
    echo "✅ API 访问正常"
    echo "财务数据: $(echo "$response" | jq -r '.data | "收入:\(.totalRevenue) 成本:\(.totalCost) 利润:\(.totalProfit)"')"
else
    echo "❌ API 访问失败"
    echo "响应: $response"
    exit 1
fi

echo ""
echo "🎉 修复完成！"
echo "请清除浏览器缓存后访问: http://47.94.123.202:8081/financial"
echo ""
echo "清除缓存方式："
echo "  Chrome: Ctrl+Shift+Delete 或 Cmd+Shift+Delete"
echo "  或直接使用无痕模式/隐私模式访问"
