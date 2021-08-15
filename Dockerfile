# Adjust Python version and Alpine version as needed
# A different Linux distro can be used, other than Alpine, if desired
FROM python:3.9-alpine3.14
LABEL maintainer="hamiltonhart.com"

ENV PYTHONUNBUFFERED 1


# Add to requirements.txt as needed
COPY ./requirements.txt /requirements.txt
# The app directory will house the Django app
COPY ./app /app
COPY ./scripts /scripts

# Further commands are executed in this directory
WORKDIR /app
# Exposes port 8000
EXPOSE 8000

# Runs the following commands on build
# They can be adjusted as needed
# Creates venv, upgrades pip, installs requirements.txt, creates a non-root user
# Adds postgres along with temp dependencies to install psycopg2
# Makes directories for static and media files at /vol/web and makes the owner app-user
RUN python -m venv /py && \
  /py/bin/pip install --upgrade pip && \
  apk add --update --no-cache postgresql-client && \
  apk add --update --no-cache --virtual .tmp-deps \
  build-base postgresql-dev musl-dev linux-headers && \
  /py/bin/pip install -r /requirements.txt && \
  apk del .tmp-deps && \
  adduser --disabled-password --no-create-home app-user && \
  mkdir -p /vol/web/static && \
  mkdir -p /vol/web/media && \
  chown -R app-user:app-user /vol && \
  chmod -R 755 /vol && \
  chmod -R +x /scripts

# Adds the venv execution path to the PATH variable
ENV PATH="/scripts:/py/bin:$PATH"

# Switches to the non-root user
USER app-user

CMD ["run.sh"]
