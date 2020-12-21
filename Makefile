SHELL=/bin/bash
export GNUMAKEFLAGS=--no-print-directory
.SHELLFLAGS = -o pipefail -c

######################################################################
### Generations

AWS_SERVICES=sqs
AWS_SDK_GO=https://github.com/aws/aws-sdk-go.git

.PHONY: gen
gen:
	@make gen/gen-code
	@make gen/aws-sdk-go
	@make gen/code -j 8

gen/gen-code: gen/gen-code.cr
	@crystal build -o "$@" "$<"

gen/aws-sdk-go:
	rm -rf "$@.tmp"
	git clone --filter=blob:none --sparse "$(AWS_SDK_GO)" --depth=1 "$@.tmp"
	cd "$@.tmp" && git sparse-checkout set $(addprefix models/apis/,$(AWS_SERVICES))
	mv "$@.tmp" "$@"

_AWS_SERVICES=$(sort $(notdir $(shell find gen/aws-sdk-go/models/apis/ -maxdepth 1 -type d | grep -E '/([a-z0-9]+)$$' )))
gen/code: $(addprefix gen/code/,$(_AWS_SERVICES))

gen/code/%: gen/aws-sdk-go
	@mkdir -p "src/aws-$*"
	@mkdir -p "gen/logs"
	./gen/gen-code "$<" "$*" > "gen/logs/$*.log" 2>&1 || make "gen/fail/aws-$*"

gen/fail/%:
	@rm -rf      "gen/failed/$*"
	@mkdir -p    "gen/failed/$*"
	@mv "src/$*" "gen/failed/"

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
