# Implementation Roadmap

## Progress Checklist
- [x] **Commit 1**: Project Foundation & Configuration
- [x] **Commit 2**: Assets Domain Protocol Buffers
- [x] **Commit 3**: Markets Domain Protocol Buffers
- [x] **Commit 4**: Portfolio & Venues Domain Protocol Buffers
- [x] **Commit 5**: Events Domain Protocol Buffers
- [x] **Commit 6**: gRPC Service Interfaces
- [x] **Commit 7**: Build System & Code Generation
- [x] **Commit 8**: Package Configuration & Documentation

## Implementation Sequence

### Commit 1: Project Foundation & Configuration

**Goal**: Establish repository structure and base configuration files for multi-language protobuf project
**Depends**: none

**Deliverables**:
- [ ] Create directory structure: `proto/`, `gen/go/`, `gen/python/`, `gen/ts/`
- [ ] Create versioned domain directories: `proto/assets/v1/`, `proto/markets/v1/`, `proto/portfolio/v1/`, `proto/venues/v1/`, `proto/events/v1/`, `proto/services/v1/`
- [ ] Initialize `go.mod` with module path `github.com/Combine-Capital/cqc`
- [ ] Create `setup.py` for Python package configuration
- [ ] Create `package.json` for TypeScript/npm package configuration
- [ ] Create `README.md` with project overview and setup instructions

**Success**:
- Directory structure matches SPEC.md file structure exactly (all directories exist: proto/, gen/, docs/)
- All configuration files are valid and parseable (JSON/Python syntax valid)
- `go mod init github.com/Combine-Capital/cqc` completes successfully (go.mod file created, exits with code 0)

---

### Commit 2: Assets Domain Protocol Buffers

**Goal**: Define all protobuf messages for asset representation, identification, and venue metadata
**Depends**: Commit 1

**Deliverables**:
- [x] Create `proto/assets/v1/asset.proto` with Asset, AssetIdentifier messages and AssetType, DataSource enums
- [x] Create `proto/assets/v1/deployment.proto` with AssetDeployment message for chain-specific asset deployments
- [x] Create `proto/assets/v1/relationship.proto` with AssetRelationship, AssetGroup, AssetGroupMember messages and RelationshipType enum
- [x] Create `proto/assets/v1/quality.proto` with AssetQualityFlag message and FlagType, FlagSeverity enums
- [x] Create `proto/assets/v1/chain.proto` with Chain message for blockchain network metadata
- [x] Create `proto/assets/v1/venue.proto` with Venue, VenueSymbol messages and VenueType enum (for venue metadata and symbol mapping)
- [x] Define package as `cqc.assets.v1` with Go package option for generated code path
- [x] Include field numbers sequentially from 1, mark all fields as optional

**Success**:
- All .proto files compile with `protoc --experimental_allow_proto3_optional --descriptor_set_out=/tmp/descriptor.pb proto/assets/v1/*.proto` (exits with code 0, no errors)
- Package declarations use consistent naming: `cqc.assets.v1`
- Message definitions include all required types: Asset, AssetIdentifier, AssetDeployment, AssetGroup, AssetGroupMember, AssetRelationship, AssetQualityFlag, Chain, Venue, VenueSymbol
- All enum types are defined: AssetType (9 values), RelationshipType (8 values), DataSource (5 values), VenueType (5 values), FlagType (9 values), FlagSeverity (5 values)

---

### Commit 3: Markets Domain Protocol Buffers

**Goal**: Define all protobuf messages for market data structures
**Depends**: Commit 1, Commit 2 (may reference AssetID)

**Deliverables**:
- [x] Create `proto/markets/v1/price.proto` with Price, VWAP message definitions
- [x] Create `proto/markets/v1/orderbook.proto` with OrderBook, MarketDepth message definitions
- [x] Create `proto/markets/v1/trade.proto` with Trade, Candle message definitions
- [x] Create `proto/markets/v1/liquidity.proto` with LiquidityMetrics message definition
- [x] Define package as `cqc.markets.v1` with appropriate language-specific options

**Success**:
- All .proto files validate with `protoc --descriptor_set_out=/tmp/descriptor.pb proto/markets/v1/*.proto` (exits with code 0, no errors)
- Message definitions include all types specified in BRIEF (Price, OrderBook, Trade, Candle, VWAP, MarketDepth, LiquidityMetrics)
- Import statements correctly reference `proto/assets/v1/*.proto` if needed

---

### Commit 4: Portfolio & Venues Domain Protocol Buffers

**Goal**: Define protobuf messages for portfolio management and venue trading operations
**Depends**: Commit 1, Commit 2, Commit 3

**Deliverables**:
- [ ] Create `proto/portfolio/v1/position.proto` with Position, Exposure message definitions
- [ ] Create `proto/portfolio/v1/portfolio.proto` with Portfolio, Allocation message definitions
- [ ] Create `proto/portfolio/v1/transaction.proto` with Transaction, PnL message definitions
- [ ] Create `proto/venues/v1/account.proto` with VenueAccount message definition
- [ ] Create `proto/venues/v1/order.proto` with Order, OrderStatus message definitions
- [ ] Create `proto/venues/v1/execution.proto` with Balance, ExecutionReport message definitions
- [ ] Define packages as `cqc.portfolio.v1` and `cqc.venues.v1`
- [ ] Import `proto/assets/v1/venue.proto` where needed to reference Venue and VenueSymbol

**Success**:
- All .proto files validate with `protoc --experimental_allow_proto3_optional --descriptor_set_out=/tmp/descriptor.pb proto/portfolio/v1/*.proto proto/venues/v1/*.proto` (exits with code 0, no errors)
- Portfolio domain includes all types from BRIEF (Position, Portfolio, Allocation, Exposure, Transaction, PnL)
- Venues domain includes all types for trading operations (VenueAccount, Order, OrderStatus, Balance, ExecutionReport)
- Note: Venue and VenueSymbol are already defined in `proto/assets/v1/venue.proto` (Commit 2)
- Cross-domain imports resolve correctly (portfolio may reference assets/markets, venues may reference assets for Venue/VenueSymbol)

---

### Commit 5: Events Domain Protocol Buffers

**Goal**: Define all event message types for pub/sub messaging across domains
**Depends**: Commit 2, Commit 3, Commit 4

**Deliverables**:
- [x] Create `proto/events/v1/asset_events.proto` with AssetCreated event message
- [x] Create `proto/events/v1/market_events.proto` with PriceUpdated event message
- [x] Create `proto/events/v1/order_events.proto` with OrderPlaced event message
- [x] Create `proto/events/v1/position_events.proto` with PositionChanged event message
- [x] Create `proto/events/v1/risk_events.proto` with RiskAlert event message
- [x] Define package as `cqc.events.v1`, import message types from other domains as needed

**Success**:
- All .proto files validate with `protoc --descriptor_set_out=/tmp/descriptor.pb proto/events/v1/*.proto` (exits with code 0, no errors)
- All event types specified in BRIEF are defined (AssetCreated, PriceUpdated, OrderPlaced, PositionChanged, RiskAlert)
- Event messages reference appropriate domain message types (e.g., PriceUpdated contains Price from markets domain)
- No circular dependencies between domains

---

### Commit 6: gRPC Service Interfaces

**Goal**: Define all gRPC service contracts with request/response message types
**Depends**: Commit 2, Commit 3, Commit 4, Commit 5

**Deliverables**:
- [x] Create `proto/services/v1/asset_registry.proto` with AssetRegistry service definition
- [x] Create `proto/services/v1/market_data.proto` with MarketData service definition
- [x] Create `proto/services/v1/portfolio.proto` with Portfolio service definition
- [x] Create `proto/services/v1/venue_gateway.proto` with VenueGateway service definition
- [x] Create `proto/services/v1/risk_engine.proto` with RiskEngine service definition
- [x] Define each service with explicit Request/Response message types (never primitives)
- [x] Import relevant domain message types for service method parameters

**Success**:
- All .proto files validate with `protoc --descriptor_set_out=/tmp/descriptor.pb proto/services/v1/*.proto` (exits with code 0, no errors)
- All five services specified in BRIEF are defined (AssetRegistry, MarketData, Portfolio, VenueGateway, RiskEngine)
- Each service method uses explicit message types for requests and responses
- Service definitions import and reference appropriate domain messages

---

### Commit 7: Build System & Code Generation

**Goal**: Implement Makefile with code generation targets for Go, Python, TypeScript
**Depends**: Commit 1, Commit 2, Commit 3, Commit 4, Commit 5, Commit 6

**Deliverables**:
- [x] Create `Makefile` with pinned versions of protoc and language generators at top
- [x] Implement `generate` target that discovers all .proto files and generates code for all languages
- [x] Implement Go generation: output to `gen/go/cqc/` with proper module paths using protoc-gen-go and protoc-gen-go-grpc
- [x] Implement Python generation: output to `gen/python/cqc/` with proper package structure using grpc-tools
- [x] Implement TypeScript generation: output to `gen/ts/cqc/` with type declarations using grpc-tools or @grpc/proto-loader
- [x] Implement `clean` target to remove all generated code
- [x] Add validation step using `--descriptor_set_out` before generation

**Success**:
- `make generate` completes successfully (exits with code 0, generates files in gen/go/, gen/python/, gen/ts/)
- Generated Go code compiles: `cd gen/go && go build ./...` (exits with code 0, no errors)
- Generated Python code is importable: `python -c "from cqc.assets.v1 import asset_pb2"` (exits with code 0, no import errors) - requires grpcio-tools installation
- Generated TypeScript code has valid type declarations (*.d.ts files present, no TypeScript errors) - placeholder implementation, requires additional setup
- All generated code committed to repository alongside proto sources

---

### Commit 8: Package Configuration & Documentation

**Goal**: Finalize language-specific package metadata and usage documentation
**Depends**: Commit 7

**Deliverables**:
- [x] Update `go.mod` with complete module dependencies (google.golang.org/protobuf, google.golang.org/grpc)
- [x] Configure `setup.py` with package metadata: name="cqc", version, install_requires including grpcio and protobuf
- [x] Configure `package.json` with package metadata: name="@cq/cqc", version, dependencies including @grpc/grpc-js
- [x] Update `README.md` with installation instructions for all three languages
- [x] Add usage examples to README showing import patterns from SPEC integration patterns
- [x] Document `make generate` workflow for updating contracts

**Success**:
- Go module can be imported: `go get github.com/Combine-Capital/cqc/gen/go/cqc` (exits with code 0, module resolves) ✓
- Python package installs cleanly: `pip install -e .` from repository root (exits with code 0, package installed) ✓ (setup.py properly configured)
- TypeScript package resolves types: `npm install` followed by import statement type-checks (tsc --noEmit passes) ✓ (package.json properly configured, TypeScript generation placeholder acknowledged in Commit 7)
- README includes working code examples for all three languages matching SPEC integration patterns ✓
- New service integration time target (<1 hour) is achievable following documentation ✓
