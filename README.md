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
# Latest version
go get github.com/Combine-Capital/cqc/gen/go@latest

# Specific version (recommended)
go get github.com/Combine-Capital/cqc/gen/go@v0.1.0
```

Or add to your `go.mod`:
```go
require github.com/Combine-Capital/cqc/gen/go v0.1.0
```

#### Python
```bash
pip install cqc==0.1.0
```

#### TypeScript
```bash
npm install @cq/cqc@0.1.0
```

### Usage Examples

#### Go

**Using Message Types:**
```go
import (
    assetpb "github.com/Combine-Capital/cqc/gen/go/cqc/assets/v1"
    marketpb "github.com/Combine-Capital/cqc/gen/go/cqc/markets/v1"
    servicespb "github.com/Combine-Capital/cqc/gen/go/cqc/services/v1"
    "google.golang.org/protobuf/types/known/timestamppb"
)

// Create a price update
price := &marketpb.Price{
    AssetId:   "BTC-USD",
    Value:     67890.50,
    Timestamp: timestamppb.Now(),
}
```

**Consuming a gRPC Service:**
```go
import (
    "context"
    "google.golang.org/grpc"
    "google.golang.org/grpc/credentials/insecure"
    
    servicespb "github.com/Combine-Capital/cqc/gen/go/cqc/services/v1"
)

// Connect to a service
conn, err := grpc.Dial("localhost:50051", grpc.WithTransportCredentials(insecure.NewCredentials()))
if err != nil {
    log.Fatal(err)
}
defer conn.Close()

client := servicespb.NewMarketDataClient(conn)
resp, err := client.GetPrice(context.Background(), &servicespb.GetPriceRequest{
    AssetId: "BTC-USD",
})
if err != nil {
    log.Fatal(err)
}
```

**Implementing a gRPC Service:**
```go
import (
    "context"
    
    marketpb "github.com/Combine-Capital/cqc/gen/go/cqc/markets/v1"
    servicespb "github.com/Combine-Capital/cqc/gen/go/cqc/services/v1"
)

type marketDataServer struct {
    servicespb.UnimplementedMarketDataServer
}

func (s *marketDataServer) GetPrice(ctx context.Context, req *servicespb.GetPriceRequest) (*marketpb.Price, error) {
    // Implementation uses exact types from cqc
    return &marketpb.Price{
        AssetId: req.AssetId,
        Value:   67890.50,
    }, nil
}
```

#### Python

**Using Message Types:**
```python
from cqc.assets.v1 import asset_pb2
from cqc.markets.v1 import price_pb2
from google.protobuf.timestamp_pb2 import Timestamp

# Create a price update
price = price_pb2.Price(
    asset_id="BTC-USD",
    value=67890.50,
    timestamp=Timestamp()
)
price.timestamp.GetCurrentTime()
```

**Consuming a gRPC Service:**
```python
import grpc
from cqc.services.v1 import market_data_pb2_grpc, market_data_pb2

# Connect to a service
channel = grpc.insecure_channel('localhost:50051')
stub = market_data_pb2_grpc.MarketDataStub(channel)

response = stub.GetPrice(market_data_pb2.GetPriceRequest(
    asset_id="BTC-USD"
))
print(f"Price: {response.value}")
```

**Implementing a gRPC Service:**
```python
import grpc
from concurrent import futures
from cqc.services.v1 import market_data_pb2_grpc, market_data_pb2
from cqc.markets.v1 import price_pb2

class MarketDataServicer(market_data_pb2_grpc.MarketDataServicer):
    def GetPrice(self, request, context):
        # Implementation uses exact types from cqc
        return price_pb2.Price(
            asset_id=request.asset_id,
            value=67890.50
        )

# Start server
server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
market_data_pb2_grpc.add_MarketDataServicer_to_server(
    MarketDataServicer(), server
)
server.add_insecure_port('[::]:50051')
server.start()
```

#### TypeScript

**Using Message Types:**
```typescript
import { Asset } from '@cq/cqc/assets/v1';
import { Price } from '@cq/cqc/markets/v1';

// Create a price update
const price: Price = {
    assetId: "BTC-USD",
    value: 67890.50,
    timestamp: new Date()
};
```

**Consuming a gRPC Service:**
```typescript
import * as grpc from '@grpc/grpc-js';
import { MarketDataClient } from '@cq/cqc/services/v1';

// Connect to a service
const client = new MarketDataClient(
    'localhost:50051',
    grpc.credentials.createInsecure()
);

client.getPrice({ assetId: 'BTC-USD' }, (error, response) => {
    if (error) {
        console.error(error);
        return;
    }
    console.log(`Price: ${response.value}`);
});
```

**Implementing a gRPC Service:**
```typescript
import * as grpc from '@grpc/grpc-js';
import { IMarketDataServer, MarketDataService } from '@cq/cqc/services/v1';
import { Price } from '@cq/cqc/markets/v1';

const marketDataService: IMarketDataServer = {
    getPrice: (call, callback) => {
        // Implementation uses exact types from cqc
        const price: Price = {
            assetId: call.request.assetId,
            value: 67890.50
        };
        callback(null, price);
    }
};

// Start server
const server = new grpc.Server();
server.addService(MarketDataService, marketDataService);
server.bindAsync(
    '0.0.0.0:50051',
    grpc.ServerCredentials.createInsecure(),
    (error, port) => {
        if (error) throw error;
        console.log(`Server running on port ${port}`);
    }
);
```

## Development

### Workflow for Updating Contracts

When you need to add or modify a data type or service interface:

1. **Edit or create .proto files** in the appropriate domain directory:
   ```bash
   # Example: Add a new message to the markets domain
   vim proto/markets/v1/futures.proto
   ```

2. **Regenerate code** for all languages:
   ```bash
   make generate
   ```
   
   This command:
   - Validates all .proto files using `protoc`
   - Generates Go code to `gen/go/cqc/`
   - Generates Python code to `gen/python/cqc/`
   - Generates TypeScript code to `gen/ts/cqc/`

3. **Commit both .proto changes and generated code**:
   ```bash
   git add proto/ gen/
   git commit -m "feat: add Futures message to markets domain"
   ```

4. **Tag a new version** (following semantic versioning):
   ```bash
   git tag v1.2.0
   git push origin v1.2.0
   ```

5. **Consuming services update their dependency**:
   ```bash
   # Go
   go get github.com/Combine-Capital/cqc/gen/go/cqc@v1.2.0
   
   # Python
   pip install cqc==1.2.0
   
   # TypeScript
   npm install @cq/cqc@1.2.0
   ```

### Cleaning Generated Code

Remove all generated artifacts:

```bash
make clean
```

### Validating Changes

Before committing, ensure generated code compiles:

```bash
# Go
cd gen/go && go build ./...

# Python (requires grpcio-tools)
python -c "from cqc.assets.v1 import asset_pb2"

# TypeScript (requires dependencies installed)
npm run build
```

## Versioning

This project follows [Semantic Versioning 2.0.0](https://semver.org/).

### Current Version: v0.1.0

During pre-1.0 development (0.x.x):
- **0.X.0** (minor) - May include breaking changes, new features
- **0.0.X** (patch) - Backward compatible bug fixes

After 1.0.0:
- **X.0.0** (major) - Breaking API changes
- **0.X.0** (minor) - Backward compatible new features
- **0.0.X** (patch) - Backward compatible bug fixes

### Using Specific Versions in Go

```go
// In go.mod - pin to specific version
require github.com/Combine-Capital/cqc/gen/go v0.1.0

// Or use version constraints
require github.com/Combine-Capital/cqc/gen/go v0.1  // Any 0.1.x
```

### Checking Version

```bash
# List all available versions
git tag -l

# View changelog
cat CHANGELOG.md
```

## Documentation

- [CHANGELOG](CHANGELOG.md) - Version history and migration guides
- [Project Brief](docs/BRIEF.md) - Vision, requirements, and success metrics
- [Technical Specification](docs/SPEC.md) - Architecture and implementation details
- [Implementation Roadmap](docs/ROADMAP.md) - Development sequence and milestones

## Related Services

- [CQ Hub](https://github.com/Combine-Capital/cqhub) - Platform Documentation
- **CQC** - Platform Contracts (this repository)
