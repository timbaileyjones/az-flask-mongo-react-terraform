FROM python:3.7.2-alpine as base
WORKDIR /src/app

LABEL MAINTAINER='Tim Bailey-Jones "tbaileyjones.cw@mmm.com"'

ENV LC_ALL=en_US.utf8
ENV LANG=en_US.utf8
ENV FLASK_APP=main.py
ENV FLASK_ENV=development
ENV AWS_DEFAULT_REGION us-east-1
ENV LOG_LEVEL debug

COPY app/requirements.txt .

# Install Flask dependencies
RUN pip install --upgrade pip
RUN pip install -r /src/app/requirements.txt

FROM base as prod
ADD app .
ADD build /src/build
CMD [ "flask", "run", "--host", "0.0.0.0", "--port", "80" ]

FROM base as stage
WORKDIR /src
RUN apk add --update \
    nodejs \
    yarn

FROM stage as dev
ENV FLASK_ENV=development
RUN apk add --update vim groff
#RUN python -m pip install python-local-lambda
WORKDIR /src
COPY . /src
ENTRYPOINT [ "./docker-entrypoint.sh" ]
CMD [ "/bin/ash" ]
