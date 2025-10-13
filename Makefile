# CQC - Crypto Quant Contracts
# Makefile for Protocol Buffer code generation

# Tool versions (pinned for reproducibility)
PROTOC_VERSION := 25.1
PROTOC_GEN_GO_VERSION := v1.31.0
PROTOC_GEN_GO_GRPC_VERSION := v1.3.0
GRPCIO_TOOLS_VERSION := 1.59.3

# Directories
PROTO_DIR := proto
GEN_DIR := gen
GO_OUT := $(GEN_DIR)/go
PYTHON_OUT := $(GEN_DIR)/python
TS_OUT := $(GEN_DIR)/ts

# Go module path
GO_MODULE := github.com/Combine-Capital/cqc

# Find all proto files
PROTO_FILES := $(shell find $(PROTO_DIR) -name '*.proto')

# Proto include paths
PROTO_INCLUDES := -I. -I$(PROTO_DIR)

.PHONY: all
all: generate

.PHONY: help
help: ## Display this help message
	@echo "CQC - Crypto Quant Contracts Makefile"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

.PHONY: install-tools
install-tools: ## Install code generation tools
	@echo "Installing protoc-gen-go $(PROTOC_GEN_GO_VERSION)..."
	@go install google.golang.org/protobuf/cmd/protoc-gen-go@$(PROTOC_GEN_GO_VERSION)
	@echo "Installing protoc-gen-go-grpc $(PROTOC_GEN_GO_GRPC_VERSION)..."
	@go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@$(PROTOC_GEN_GO_GRPC_VERSION)
	@echo "Installing grpcio-tools $(GRPCIO_TOOLS_VERSION) for Python..."
	@pip install grpcio-tools==$(GRPCIO_TOOLS_VERSION)
	@echo ""
	@echo "✓ All tools installed successfully!"
	@echo ""
	@echo "Note: Ensure protoc $(PROTOC_VERSION) is installed separately:"
	@echo "  - macOS: brew install protobuf"
	@echo "  - Linux: apt-get install protobuf-compiler or download from GitHub releases"
	@echo "  - Verify: protoc --version"

.PHONY: check-tools
check-tools: ## Check if required tools are installed
	@echo "Checking required tools..."
	@which protoc > /dev/null || (echo "Error: protoc not found. Install protobuf compiler." && exit 1)
	@which protoc-gen-go > /dev/null || (echo "Error: protoc-gen-go not found. Run 'make install-tools'" && exit 1)
	@which protoc-gen-go-grpc > /dev/null || (echo "Error: protoc-gen-go-grpc not found. Run 'make install-tools'" && exit 1)
	@echo "✓ Required tools are installed (Python and TypeScript generation optional)"

.PHONY: clean
clean: ## Remove all generated code
	@echo "Cleaning generated code..."
	@rm -rf $(GO_OUT)/*
	@rm -rf $(PYTHON_OUT)/*
	@rm -rf $(TS_OUT)/*
	@echo "✓ Generated code cleaned"

.PHONY: validate
validate: ## Validate proto files compile without errors
	@echo "Validating proto files..."
	@protoc $(PROTO_INCLUDES) \
		--experimental_allow_proto3_optional \
		--descriptor_set_out=/tmp/cqc_descriptor.pb \
		$(PROTO_FILES)
	@echo "✓ All proto files are valid"

.PHONY: generate-go
generate-go: ## Generate Go code from proto files
	@echo "Generating Go code..."
	@protoc $(PROTO_INCLUDES) \
		--experimental_allow_proto3_optional \
		--go_out=. \
		--go_opt=module=$(GO_MODULE) \
		--go-grpc_out=. \
		--go-grpc_opt=module=$(GO_MODULE) \
		$(PROTO_FILES)
	@echo "✓ Go code generated in $(GO_OUT)"

.PHONY: generate-python
generate-python: ## Generate Python code from proto files
	@echo "Generating Python code..."
	@if python3 -c "import grpc_tools.protoc" 2>/dev/null; then \
		mkdir -p $(PYTHON_OUT) && \
		python3 -m grpc_tools.protoc $(PROTO_INCLUDES) \
			--experimental_allow_proto3_optional \
			--python_out=$(PYTHON_OUT) \
			--grpc_python_out=$(PYTHON_OUT) \
			$(PROTO_FILES) && \
		find $(PYTHON_OUT) -type d -exec touch {}/__init__.py \; && \
		echo "✓ Python code generated in $(PYTHON_OUT)"; \
	else \
		echo "⚠ grpcio-tools not installed. Skipping Python generation."; \
		echo "  Install with: pip3 install grpcio-tools"; \
	fi

.PHONY: generate-ts
generate-ts: ## Generate TypeScript code from proto files
	@echo "Generating TypeScript code..."
	@mkdir -p $(TS_OUT)
	@echo "⚠ TypeScript generation requires additional setup."
	@echo "Options:"
	@echo "  1. Use @grpc/proto-loader for dynamic loading (no codegen needed)"
	@echo "  2. Use ts-proto: npm install ts-proto && protoc with --plugin"
	@echo "  3. Use grpc-tools: npm install @grpc/grpc-js @grpc/proto-loader"
	@echo ""
	@echo "For now, TypeScript generation is a placeholder."
	@echo "See package.json and docs for TypeScript integration patterns."
	@echo "✓ TypeScript directory created at $(TS_OUT)"

.PHONY: generate
generate: check-tools validate generate-go generate-python generate-ts ## Generate code for all languages
	@echo ""
	@echo "════════════════════════════════════════════════════════"
	@echo "✓ Code generation complete!"
	@echo "════════════════════════════════════════════════════════"
	@echo ""
	@echo "Generated code locations:"
	@echo "  Go:         $(GO_OUT)"
	@echo "  Python:     $(PYTHON_OUT)"
	@echo "  TypeScript: $(TS_OUT)"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Verify Go code:   cd $(GO_OUT) && go build ./..."
	@echo "  2. Verify Python:    python -c 'from cqc.assets.v1 import asset_pb2'"
	@echo "  3. Commit generated code to repository"
	@echo ""

.PHONY: verify-go
verify-go: ## Verify generated Go code compiles
	@echo "Verifying Go code compiles..."
	@cd $(GO_OUT) && go mod init $(GO_MODULE)/$(GO_OUT) 2>/dev/null || true
	@cd $(GO_OUT) && go mod tidy
	@cd $(GO_OUT) && go build ./...
	@echo "✓ Go code compiles successfully"

.PHONY: verify-python
verify-python: ## Verify generated Python code can be imported
	@echo "Verifying Python code imports..."
	@PYTHONPATH=$(PYTHON_OUT) python -c "from cqc.assets.v1 import asset_pb2; print('✓ Python imports work')"

.PHONY: verify
verify: verify-go verify-python ## Verify all generated code
	@echo ""
	@echo "✓ All generated code verified successfully"

.PHONY: format-proto
format-proto: ## Format proto files (requires buf or clang-format)
	@echo "Proto formatting requires 'buf' or 'clang-format'"
	@echo "Install buf: https://docs.buf.build/installation"
	@which buf > /dev/null && buf format -w $(PROTO_DIR) || echo "⚠ buf not found, skipping format"

.PHONY: lint-proto
lint-proto: ## Lint proto files (requires buf)
	@echo "Linting proto files..."
	@which buf > /dev/null && buf lint $(PROTO_DIR) || echo "⚠ buf not found, install from https://docs.buf.build/installation"

.PHONY: info
info: ## Display project information
	@echo "CQC - Crypto Quant Contracts"
	@echo ""
	@echo "Module:      $(GO_MODULE)"
	@echo "Proto files: $(words $(PROTO_FILES))"
	@echo ""
	@echo "Tool versions:"
	@echo "  protoc:               $(PROTOC_VERSION)"
	@echo "  protoc-gen-go:        $(PROTOC_GEN_GO_VERSION)"
	@echo "  protoc-gen-go-grpc:   $(PROTOC_GEN_GO_GRPC_VERSION)"
	@echo "  grpcio-tools:         $(GRPCIO_TOOLS_VERSION)"
	@echo ""
	@echo "Directories:"
	@echo "  Proto source: $(PROTO_DIR)"
	@echo "  Generated:    $(GEN_DIR)"
	@echo ""
