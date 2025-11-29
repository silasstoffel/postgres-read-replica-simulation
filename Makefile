docker-up:
	docker-compose up -d

primary-db-shell:
	docker exec -it primary-db psql -U primary -d primary-db

replica1-db-shell:
	docker exec -it replica1-db psql -U primary -d primary-db	
