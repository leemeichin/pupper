test: ## Run all tests for the project in docker
	echo "> Running tests..."
	docker-compose run builder bundle exec rspec
