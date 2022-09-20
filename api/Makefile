.DEFAULT_GOAL := help

# GraphQL
#######

.PHONY: generate_client
generate_client: ## Generate client for the GraphQL API, from the schema in `schema/`
	cd schema && bal graphql -i ./graphql.config.yaml -o ../../client


# Util
#######

.PHONY: help
help: # See: https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
