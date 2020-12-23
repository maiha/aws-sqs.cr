SHELL=/bin/bash
export GNUMAKEFLAGS=--no-print-directory
.SHELLFLAGS = -o pipefail -c

######################################################################
### Generations

AWS_SERVICES=sqs

.PHONY: gen
gen:
	@make gen/codegen
	@make gen/boto
	@make gen/botocode

gen/codegen: gen/codegen.cr
	@crystal build -o "$@" "$<"

gen/boto:
	rm -rf "$@.tmp"
	git clone --filter=blob:none --sparse "https://github.com/boto/botocore.git" --depth=1 "$@.tmp"
	cd "$@.tmp" && git sparse-checkout set $(addprefix botocore/data/,$(AWS_SERVICES))
	mv "$@.tmp" "$@"

gen/botocode: $(sort $(addprefix gen/botocode/,$(notdir $(shell find gen/boto/botocore/data/ -maxdepth 1 -type d | grep -E '/([a-z0-9]+)$$' ))))
gen/botocode/%:
	@mkdir -p "gen/logs"
	./gen/codegen "$*" "`find gen/boto/botocore/data/$*/ -name 'service*.json' | tail -1`" "gen/src/$*" > "gen/logs/$*.log" 2>&1 && make "gen/deploy/$*"

gen/deploy/%:
	@mkdir -p "src/aws-$*"
	@rm -rf   "src/aws-$*/gen"
	@mv "gen/src/$*" "src/aws-$*/gen"

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
