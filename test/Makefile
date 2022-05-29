docker-compose-split=docker compose -f ./docker-compose.split.yml 
docker-compose-full=docker compose -f ./docker-compose.full.yml 


test-full:
		${docker-compose-full} down; \
		${docker-compose-full} up; \
		${docker-compose-full} down

test-split:
		${docker-compose-split} down; \
		${docker-compose-split} up; \
		${docker-compose-split} down

test-full-down:
		${docker-compose-full} down

test-full-up:
		${docker-compose-full} up

test-split-down:
		${docker-compose-split} down

test-split-up:
		${docker-compose-split} up

tag:
	git tag -f -a -m "First version" v1 && git push --force --tags

phony: test-full test-split test-full-up test-full-down test-split-up test-split-down tag
