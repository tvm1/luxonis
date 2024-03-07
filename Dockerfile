# Use an official base image with a specific version of Linux
FROM python:3.9-slim-buster

# Set the working directory in the container
WORKDIR /app

# Copy the local code to the container at /app
COPY . /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    libpq-dev \
    postgresql \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install Flask==3.0.0 psycopg2-binary==2.9.3 requests==2.31.0

USER postgres
RUN /etc/init.d/postgresql start && \
    echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/11/main/pg_hba.conf && \
    echo "listen_addresses = '0.0.0.0'" >> /etc/postgresql/11/main/postgresql.conf && \
    sed -ie 's/local   all             all                                     peer/local all all md5/'  /etc/postgresql/11/main/pg_hba.conf && \
    /etc/init.d/postgresql stop

# Set up PostgreSQL database and user
RUN /etc/init.d/postgresql start && \
    psql --command "CREATE USER myuser WITH PASSWORD '123';" && \
    createdb -O myuser mydatabase

# Create table
RUN /etc/init.d/postgresql start && PGPASSWORD=123 psql -d mydatabase -U myuser -c "CREATE TABLE mytable (id SERIAL PRIMARY KEY, name VARCHAR(255), image VARCHAR(255));"

USER root

# Expose the port the app runs on
EXPOSE 8080

# Define environment variables for Flask and PostgreSQL
ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV DATABASE_URL=postgresql://myuser:mypassword@localhost:5432/mydatabase

ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
