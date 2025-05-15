# Use a multi-step build to reduce the size of the final image
FROM python:3.9-slim AS builder

# Install dependencies in virtual enviroment
WORKDIR /build
COPY . .
RUN pip install --no-cache-dir flask gunicorn

# Final step with minimal dependencies
FROM python:3.9-slim
WORKDIR /app

# Copy files and install dependencies
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY app.py /app/

# Add image metadata
LABEL maintainer="**VLASOV**"
LABEL version="1.0.0"
LABEL description="CI/CD Demo Flask Application"

# Setting enviroment variables
ENV APP_VERSION=1.0.0
ENV PORT=5000

# Setting check container is work
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
	CMD curl -f http://localhost:${PORT}/health || exit 1

# Open port
EXPOSE ${PORT}

# Run application by gunicorn for release enviroment
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
