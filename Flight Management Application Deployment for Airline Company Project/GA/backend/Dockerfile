# backend/Dockerfile

FROM python:3.9

WORKDIR /app

# Copy the Nginx configuration file to the container
COPY default.conf /etc/nginx/conf.d/

# Copy all application files into the container
COPY . /app

# Install dependencies
RUN pip install -r requirements.txt

# Expose the port the Flask app will run on
EXPOSE 5000
EXPOSE 80

ENV FLASK_ENV=development
ENV FLASK_DEBUG=1

# Run the Flask app as a service
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000", "--debug"]
