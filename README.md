# Atlassian JIRA Docker

## Run single container

Just run `docker run -it --name jira -p 8080:8080 webinventions/atlassian-jira` and open browser http://127.0.0.1:8080

## Docker compose

Run `docker-compose up -d` and open browser http://127.0.0.1:8080 and use following settings `host: postgres`, `user: jira`, `password: jira`, `database: jira`.

