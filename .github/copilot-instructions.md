# CQC Development Guidelines

## Context & Documentation

Always use Context7 for current docs on Protocol Buffers, gRPC, and language-specific protobuf implementations; invoke automatically without being asked.

## Development Standards

### Protocol Buffers v3 Best Practices
- Use explicit field numbers sequentially from 1 and never reuse retired numbers to maintain backward compatibility across service versions
- Mark all fields as optional by default in proto3; required fields cannot be added later without breaking changes

### gRPC Patterns
- Define service methods with explicit request/response message types (never use primitives directly) to enable future field additions without breaking clients
- Use streaming RPCs (server/client/bidirectional) only when data volume justifies it; unary calls are simpler and sufficient for most use cases

### Makefile Conventions
- Pin exact versions of protoc and language generators in variables at top of Makefile to ensure reproducible builds across all developer machines
- Always regenerate all languages together in single `make generate` target to keep cross-language contracts synchronized

### Code Quality Standards
- Run `protoc` with `--descriptor_set_out` to validate proto syntax errors before committing; generated code that compiles doesn't guarantee valid proto definitions
- Never manually edit generated code (*.pb.go, *_pb2.py, *.ts); changes will be overwritten on next generation

### Project Conventions
- Organize protos strictly by domain/version path (assets/v1/, markets/v1/) with one message type per file for granular imports and clear ownership
- Commit generated code to repository alongside proto sources to avoid generator version mismatches between development and consuming services

### Agentic AI Guidelines
- Never create "summary" documents; direct action is more valuable than summarization