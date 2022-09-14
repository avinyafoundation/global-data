.DEFAULT_GOAL := help

# Run GitHub Workflows with Act
###############################

.PHONY: run
run: ## Run GitHub workflows with act
	act -v

.PHONY: clean
clean: ## Clean docker containers and volumes (causes act to break sometimes)
	docker rm -f $(shell docker ps -a -q)
	docker volume rm $(shell docker volume ls -q)

.PHONY: all
all: ## Cleans up docker containers, and runs GitHub workflows with act
	$(MAKE) clean
	$(MAKE) run

# Util
#######

.PHONY: help
help: # See: https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
