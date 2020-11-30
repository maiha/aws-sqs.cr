SHELL=/bin/bash
export GNUMAKEFLAGS=--no-print-directory
.SHELLFLAGS = -o pipefail -c

# AWS_SERVICES=s3 sqs
AWS_SERVICES=sqs
AWS_SDK_GO=https://github.com/aws/aws-sdk-go.git
AWS_SDK_GO_PATHS := $(addprefix models/apis/,$(AWS_SERVICES))

.PHONY: gen
gen:
	@make gen/aws-sdk-go
	@make gen/code

gen/aws-sdk-go:
	rm -rf "$@.tmp"
	git clone --filter=blob:none --sparse "$(AWS_SDK_GO)" --depth=1 "$@.tmp"
	cd "$@.tmp" && git sparse-checkout set $(AWS_SDK_GO_PATHS)
	mv "$@.tmp" "$@"

gen/code: $(addprefix gen/code/,$(AWS_SERVICES))

gen/code/%: gen/aws-sdk-go
	crystal gen/gen-code.cr "$<" "$*"
