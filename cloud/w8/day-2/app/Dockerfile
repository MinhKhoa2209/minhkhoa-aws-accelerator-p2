FROM python:3.12-alpine

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080

COPY server.py /app/server.py

RUN addgroup -S app && adduser -S -G app -u 10001 app && chown -R app:app /app

USER app

EXPOSE 8080

CMD ["python", "/app/server.py"]
