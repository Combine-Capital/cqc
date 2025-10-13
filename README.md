# CQC - Crypto Quant Contracts

Central contract repository providing Protocol Buffer definitions, OpenAPI specs, and event schemas as the single source of truth for all service interfaces across the Crypto Quant trading platform.

## Overview

CQC is a shared contract library that defines:
- **Protocol Buffer messages** for all trading platform data types
- **gRPC service interfaces** for inter-service communication
- **Event schemas** for pub/sub messaging
- **Generated client libraries** for Go, Python, and TypeScript

## Repository Structure

```
cqc/
├── proto/              # Protocol Buffer definitions
│   ├── assets/v1/      # Asset domain messages
│   ├── markets/v1/     # Market data messages
│   ├── portfolio/v1/   # Portfolio management messages
│   ├── venues/v1/      # Venue integration messages
│   ├── events/v1/      # Event messages
│   └── services/v1/    # gRPC service definitions
├── gen/                # Generated code (committed)
│   ├── go/             # Generated Go code
│   ├── python/         # Generated Python code
│   └── ts/             # Generated TypeScript code
├── docs/               # Documentation
│   ├── BRIEF.md        # Project brief
│   ├── SPEC.md         # Technical specification
│   └── ROADMAP.md      # Implementation roadmap
└── Makefile            # Build automation
```

## Getting Started

### Prerequisites

- **protoc** (Protocol Buffer Compiler) v3.20+
- **Go** 1.21+ (for Go code generation)
- **Python** 3.8+ (for Python code generation)
- **Node.js** 18+ (for TypeScript code generation)

### Installation

#### Go
```bash
go get github.com/Combine-Capital/cqc/gen/go/cqc
```

#### Python
```bash
pip install cqc
```

#### TypeScript
```bash
npm install @cq/cqc
```

### Usage Examples

#### Go
```go
import (
    assetpb "github.com/Combine-Capital/cqc/gen/go/cqc/assets/v1"
    marketpb "github.com/Combine-Capital/cqc/gen/go/cqc/markets/v1"
)

// Use the generated types
asset := &assetpb.Asset{
    Symbol: "BTC",
    Name:   "Bitcoin",
}
```

#### Python
```python
from cqc.assets.v1 import asset_pb2
from cqc.markets.v1 import price_pb2

# Use the generated types
asset = asset_pb2.Asset(
    symbol="BTC",
    name="Bitcoin"
)
```

#### TypeScript
```typescript
import { Asset } from '@cq/cqc/assets/v1';
import { Price } from '@cq/cqc/markets/v1';

// Use the generated types
const asset: Asset = {
    symbol: "BTC",
    name: "Bitcoin"
};
```

## Development

### Generating Code

After modifying .proto files, regenerate code for all languages:

```bash
make generate
```

### Cleaning Generated Code

```bash
make clean
```

## Documentation

- [Project Brief](docs/BRIEF.md) - Vision, requirements, and success metrics
- [Technical Specification](docs/SPEC.md) - Architecture and implementation details
- [Implementation Roadmap](docs/ROADMAP.md) - Development sequence and milestones

## Related Services

- [CQ Hub](https://github.com/Combine-Capital/cqhub) - Platform Documentation
- **CQC** - Platform Contracts (this repository)
