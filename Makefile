docker-compose-split=docker compose -f ./docker-compose.split.yml 
docker-compose-full=docker compose -f ./docker-compose.full.yml 


tag:
	git tag -f -a -m "First version" v1 && git push --force --tags

test-split:
	${docker-compose-split} down && \
		${docker-compose-split} up && \
		${docker-compose-split} down

test-full:
	${docker-compose-full} down && \
		${docker-compose-full} up && \
		${docker-compose-full} down
