SHELL=/bin/bash
export GNUMAKEFLAGS=--no-print-directory
.SHELLFLAGS = -o pipefail -c

######################################################################
### Generations

# AWS_SERVICES=s3 sqs
AWS_SERVICES=sqs
AWS_SDK_GO=https://github.com/aws/aws-sdk-go.git

.PHONY: gen
gen:
	@make gen/aws-sdk-go
	@make gen/code

gen/aws-sdk-go:
	rm -rf "$@.tmp"
	git clone --filter=blob:none --sparse "$(AWS_SDK_GO)" --depth=1 "$@.tmp"
	cd "$@.tmp" && git sparse-checkout set $(addprefix models/apis/,$(AWS_SERVICES))
	mv "$@.tmp" "$@"

gen/code: $(addprefix gen/code/,$(AWS_SERVICES))

gen/code/%: gen/aws-sdk-go
	crystal gen/gen-code.cr "$<" "$*"

######################################################################
### Versioning

VERSION=
CURRENT_VERSION=$(shell git tag -l | sort -V | tail -1 | sed -e 's/^v//')
GUESSED_VERSION=$(shell git tag -l | sort -V | tail -1 | awk 'BEGIN { FS="." } { $$3++; } { printf "%d.%d.%d", $$1, $$2, $$3 }')

.PHONY : version
version: README.md
	@if [ "$(VERSION)" = "" ]; then \
	  echo "ERROR: specify VERSION as bellow. (current: $(CURRENT_VERSION))";\
	  echo "  make version VERSION=$(GUESSED_VERSION)";\
	else \
	  sed -i -e 's/^version: .*/version: $(VERSION)/' shard.yml ;\
	  sed -i -e 's/^    version: [0-9]\+\.[0-9]\+\.[0-9]\+/    version: $(VERSION)/' $< ;\
	  echo git commit -a -m "'$(COMMIT_MESSAGE)'" ;\
	  git commit -a -m 'version: $(VERSION)' ;\
	  git tag "v$(VERSION)" ;\
	fi

.PHONY : bump
bump:
	make version VERSION=$(GUESSED_VERSION) -s
