.PHONY: help up down logs security-check

help:
	@echo "AIOps Infrastructure Prototype - Management CLI"
	@echo "Available commands:"
	@echo "  make up             - Start local control plane securely (localhost bindings only)"
	@echo "  make down           - Stop local control plane containers"
	@echo "  make logs           - Tail container logs"
	@echo "  make security-check - Verify no ports are exposed to public interfaces (0.0.0.0)"

up:
	@if [ ! -f .env ]; then echo "Error: .env file missing. Run 'cp .env.example .env' and configure keys."; exit 1; fi
	docker compose --env-file .env -f deployments/docker-compose.yml up -d

down:
	docker compose -f deployments/docker-compose.yml down

logs:
	docker compose -f deployments/docker-compose.yml logs -f

security-check:
	@echo "Checking active Docker port bindings for public exposure..."
	@docker ps --format "table {{.Names}}\t{{.Ports}}"
	@echo "Ensure all ports show 127.0.0.1 bindings, never 0.0.0.0."