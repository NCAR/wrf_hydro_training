tag=wrfhydro/training:lsu_2026
all: pull

pull:
	docker pull $(tag)

run:
	docker run --name wrf-hydro-training -p 8888:8888 -t $(tag)

list:
	docker images
	@echo ""
	docker ps -a

clean:
	containers=$$(docker ps -aq --filter "ancestor=${tag}"); \
	if [ -n "$$containers" ]; then \
		docker rm -f $$containers; \
	fi
.PHONY: all build
