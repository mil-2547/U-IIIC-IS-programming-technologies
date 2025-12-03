FROM alpine:latest

RUN apk add --update python3 py3-pip

# Python3 virtual env to install flask
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install flask

WORKDIR /app
COPY app.py .

CMD ["python3", "app.py"]