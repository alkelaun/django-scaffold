.PHONY: help up down restart logs shell migrate makemigrations createsuperuser collectstatic test clean

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

up: ## Start all containers
	docker compose up -d

down: ## Stop and remove all containers
	docker compose down

restart: ## Restart all containers
	docker compose restart

logs: ## Show logs from all containers (Ctrl+C to exit)
	docker compose logs -f

shell: ## Open Django shell
	docker compose exec django python manage.py shell

dbshell: ## Open database shell
	docker compose exec django python manage.py dbshell

migrate: ## Run database migrations
	docker compose exec django python manage.py migrate

makemigrations: ## Create new migrations
	docker compose exec django python manage.py makemigrations

createsuperuser: ## Create a Django superuser
	docker compose exec django python manage.py createsuperuser

collectstatic: ## Collect static files
	docker compose exec django python manage.py collectstatic --noinput

test: ## Run tests
	docker compose exec django python manage.py test

bash: ## Open bash shell in Django container
	docker compose exec django /bin/bash

build: ## Build or rebuild containers
	docker compose up -d --build

clean: ## Remove containers, volumes, and orphan containers
	docker compose down -v --remove-orphans

ps: ## Show status of all containers
	docker compose ps

startapp: ## Create a new Django app (usage: make startapp name=myapp)
	docker compose exec django python manage.py startapp $(name)
