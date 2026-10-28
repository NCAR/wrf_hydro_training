all: build

build:
	docker pull wrfhydro/training
run:
	docker run --name wrf-hydro-training -it -v $(PWD)/lessons:/home/docker/saved wrfhydro/training
server:
	docker run --name wrf-hydro-training -p 8888:8888 wrfhydro/training

list:
	docker images
	@echo ""
	docker ps -a

# Run the local lessons/ and tests/ inside the container, then copy the
# executed notebooks back out. The local checkout is mounted read-only
# because the container user (uid 1001) can't write host-owned files;
# docker cp writes them back as the invoking user instead. -t is required
# so the entrypoint runs the given command rather than starting jupyter.
TEST_CONTAINER = wrf-hydro-training-test
TRAINING_DIR = /home/docker/wrf_hydro_training
test:
	-@docker rm -f $(TEST_CONTAINER) >/dev/null 2>&1
	docker run -t --name $(TEST_CONTAINER) \
	-v $(PWD):/workspace:ro \
	wrfhydro/training \
	bash -c 'rm -rf $(TRAINING_DIR)/lessons $(TRAINING_DIR)/tests && \
	         cp -r /workspace/lessons /workspace/tests $(TRAINING_DIR)/ && \
	         cd $(TRAINING_DIR)/tests && bash run_training_notebooks.sh'; \
	status=$$?; \
	docker cp $(TEST_CONTAINER):$(TRAINING_DIR)/lessons/training/. lessons/training/; \
	docker rm $(TEST_CONTAINER) >/dev/null; \
	exit $$status

clean:
	docker rm wrf-hydro-training
