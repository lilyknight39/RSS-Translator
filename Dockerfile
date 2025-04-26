# Build in local: docker build . --platform linux/arm64 -t rsstranslator/rsstranslator:no-csrf
# Multi-arch build:
# docker buildx create --use
# docker buildx build . --platform linux/arm64,linux/amd64 --push -t rsstranslator/rsstranslator:no-csrf

FROM rsstranslator/rsstranslator:latest

# 创建禁用 CSRF 的启动脚本
RUN echo '#!/bin/bash \n\
# 找到 settings.py 文件 \n\
SETTINGS_FILE=$(find /home/rsstranslator -name "settings.py") \n\
# 备份原始文件 \n\
cp $SETTINGS_FILE ${SETTINGS_FILE}.bak \n\
# 注释掉 CSRF 中间件 \n\
sed -i "s/'\''django.middleware.csrf.CsrfViewMiddleware'\'',/# '\''django.middleware.csrf.CsrfViewMiddleware'\'',/" $SETTINGS_FILE \n\
# 执行原始命令 \n\
python manage.py init_server && python manage.py run_huey -f & uvicorn config.asgi:application --host 0.0.0.0 \n\
' > /home/rsstranslator/start-no-csrf.sh && \
    chmod +x /home/rsstranslator/start-no-csrf.sh

# 使用新的启动脚本
CMD ["/home/rsstranslator/start-no-csrf.sh"]
