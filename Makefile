default: build 

# build Docker image
build: docker_build output

# build and push Docker image
release: docker_build docker_push output

# image can be overwritten with env var.
DOCKER_IMAGE ?= cnatzke/root-cern

# get latest commit
GIT_COMMIT = $(strip $(shell git rev-parse --short HEAD))

# get the date as version number
CODE_VERSION = $(strip $(shell date +"%Y-%m-%d"))

# find out if workign directory is clean
GIT_NOT_CLEAN_CHECK = $(shell git status --porcelain)
ifneq (x$(GIT_NOT_CLEAN_CHECK), x)
DOCKER_TAG_SUFFIX = "-dirty"
endif

# if releasing to DockerHub and marking with latest tag, it should match
# a version release
ifeq ($(MAKECMDGOALS),release)
# use the version number as the release tag
DOCKER_TAG = $(CODE_VERSION)

# see what commit is tagged to match the version
VERSION_COMMIT = $(strip $(shell git rev-list $(CODE_VERSION) -n 1 | cut -c1-7))
ifneq ($(VERSION_COMMIT), $(GIT_COMMIT))
$(error echo You are trying to push a build based on commit $(GIT_COMMIT) but the tagged version release is $(VERSION_COMMIT))
endif

# don't push to DockerHub if this is not a clean repo
ifneq (x$(GIT_NOT_CLEAN_CHECK), x)
$(error echo You are trying to release a build based on a dirty repo)
endif 

else
# add the commit ref for development builds. Mark as dirty if the working
# directory is not clean 
DOCKER_TAG = $(CODE_VERSION)-$(GIT_COMMIT)$(DOCKER_TAG_SUFFIX)
endif

#################################################################
# EVERYTHING BELOW HERE REQUIRES TAB, NOT SPACE
#################################################################

docker_build:
	# build Docker image
	docker build \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--build-arg VERSION=$(CODE_VERSION) \
		--build-arg VCS_URL=`git config --get remote.origin.url` \
		--build-arg VCS_REF=$(GIT_COMMIT) \
			-t $(DOCKER_IMAGE):$(DOCKER_TAG) . \
			# experimental for smaller image size. need to test later 
			#--compress --squash .

	# tag image as latest
	docker tag $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):latest

docker_push:
	# push to DockerHub
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)
	docker push $(DOCKER_IMAGE):latest

output: 
	@echo Docker Image: $(DOCKER_IMAGE):$(DOCKER_TAG)

