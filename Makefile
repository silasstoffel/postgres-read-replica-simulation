primary-db-shell:
	docker exec -it primary-db psql -U primary -d primary-db

replica-db-shell:
	docker exec -it replica1-db psql -U primary -d primary-db	
