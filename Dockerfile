FROM python:3.11-slim

ARG APT_MIRROR=http://deb.debian.org

ENV PYTHONDONTWRITEBYTECODE=1 \
PYTHONUNBUFFERED=1 \
PIP_NO_CACHE_DIR=1 \
PORT=7860

WORKDIR /app

# 系统依赖（Playwright 需要）
RUN if [ -f /etc/apt/sources.list ]; then \
sed -i "s|http://deb.debian.org|${APT_MIRROR}|g" /etc/apt/sources.list; \
elif [ -f /etc/apt/sources.list.d/debian.sources ]; then \
sed -i "s|http://deb.debian.org|${APT_MIRROR}|g" /etc/apt/sources.list.d/debian.sources; \
fi \
&& apt-get update \
&& apt-get install -y --no-install-recommends \
curl ca-certificates fonts-liberation libasound2 libatk-bridge2.0-0 libatk1.0-0 libcups2 libdrm2 libgbm1 libgtk-3-0 libnspr4 libnss3 libx11-xcb1 libxcomposite1 libxdamage1 libxfixes3 libxkbcommon0 libxrandr2 libxshmfence1 libxss1 libxtst6 lsb-release xdg-utils \
&& rm -rf /var/lib/apt/lists/*

# Python 依赖 + Playwright
COPY requirements.txt ./
RUN python -m pip install --no-cache-dir --upgrade pip \
&& pip install -r requirements.txt \
&& python -m playwright install --with-deps chromium

# 复制所有代码（包含已构建好的 static/）
COPY . .

# HF Spaces 持久化存储适配（关键！）
RUN chmod +x entrypoint.sh \
&& mkdir -p /data \
&& rm -rf /app/data \
&& ln -sfn /data /app/data \
&& chmod -R 777 /data /app/data /app/static

EXPOSE 7860
VOLUME ["/data"]

# 使用增强版 entrypoint 启动
CMD ["./entrypoint.sh"]
