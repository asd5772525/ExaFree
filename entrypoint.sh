bash
#!/bin/bash
set -e

echo "=== ExaFree Hugging Face Spaces 启动 ==="

# 确保持久化存储（HF 的 /data 卷）
mkdir -p /data
if [ ! -L "/app/data" ] || [ "$(readlink /app/data)" != "/data" ]; then
echo "→ 创建软链接 /app/data → /data（HF 持久存储）"
rm -rf /app/data 2>/dev/null || true
ln -sfn /data /app/data
fi

echo "数据目录状态: $(ls -ld /app/data)"
echo "端口: ${PORT:-7860}"
echo "启动 FastAPI 服务..."

# 启动主程序（main.py 已经自动读取 $PORT 并绑定 0.0.0.0）
exec python -u main.py
