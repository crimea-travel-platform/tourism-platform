SHELL := /bin/bash
COMPOSE := docker compose --env-file .env

.DEFAULT_GOAL := help

.PHONY: help init up down restart ps logs clean validate clone-repositories

help: ## Показать доступные команды
	@awk 'BEGIN {FS = ":.*## "; printf "Использование: make <command>\n\n"} /^[a-zA-Z_-]+:.*## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## Проверить зависимости и создать .env
	@./scripts/bootstrap.sh

up: ## Запустить локальную инфраструктуру
	@$(COMPOSE) up -d

down: ## Остановить локальную инфраструктуру
	@$(COMPOSE) down

restart: ## Перезапустить локальную инфраструктуру
	@$(COMPOSE) down
	@$(COMPOSE) up -d

ps: ## Показать состояние контейнеров
	@$(COMPOSE) ps

logs: ## Следить за логами контейнеров
	@$(COMPOSE) logs -f

clean: ## Удалить контейнеры и volumes (требует CONFIRM=yes)
	@if [[ "$(CONFIRM)" != "yes" ]]; then \
		echo "ОТКАЗ: команда удаляет все локальные volumes и данные."; \
		echo "Для подтверждения выполните: make clean CONFIRM=yes"; \
		exit 1; \
	fi
	@echo "Удаление локальных контейнеров и volumes подтверждено."
	@$(COMPOSE) down --volumes --remove-orphans

validate: ## Выполнить безопасные локальные проверки
	@./scripts/validate.sh

clone-repositories: ## Добавить будущие репозитории как submodules
	@./scripts/clone-repositories.sh
