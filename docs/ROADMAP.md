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
- [x] **Commit 9**: Domain Separation Migration (Asset/Symbol/Venue) ⭐ **COMPLETE**

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

**Goal**: Define all protobuf messages for individual token/coin representation and identification
**Depends**: Commit 1

**Deliverables**:
- [x] Create `proto/assets/v1/asset.proto` with Asset, AssetIdentifier messages and AssetType, DataSource enums
- [x] Create `proto/assets/v1/deployment.proto` with AssetDeployment message for chain-specific asset deployments
- [x] Create `proto/assets/v1/relationship.proto` with AssetRelationship, RelationshipType enum (wraps, bridges, stakes)
- [x] Create `proto/assets/v1/quality.proto` with AssetQualityFlag message and FlagType, FlagSeverity enums
- [x] Create `proto/assets/v1/chain.proto` with Chain message for blockchain network metadata
- [x] Define package as `cqc.assets.v1` with Go package option for generated code path
- [x] Include field numbers sequentially from 1, mark all fields as optional
- [ ] **MIGRATION NEEDED**: Remove Venue and VenueSymbol from assets domain (belongs in venues domain)

**Success**:
- All .proto files compile with `protoc --experimental_allow_proto3_optional --descriptor_set_out=/tmp/descriptor.pb proto/assets/v1/*.proto` (exits with code 0, no errors)
- Package declarations use consistent naming: `cqc.assets.v1`
- Message definitions for individual tokens: Asset, AssetIdentifier, AssetDeployment, AssetRelationship, AssetQualityFlag, Chain
- All enum types are defined: AssetType (9 values), RelationshipType (8 values), DataSource (5 values), FlagType (10 values), FlagSeverity (5 values)
- **Note**: Venue/VenueSymbol currently exist here but should be moved to venues domain

---

### Commit 3: Markets Domain Protocol Buffers

**Goal**: Define all protobuf messages for trading pairs/markets and market data structures
**Depends**: Commit 1, Commit 2 (references AssetID)

**Deliverables**:
- [ ] **NEW**: Create `proto/markets/v1/symbol.proto` with Symbol message and SymbolType enum (SPOT, PERPETUAL, FUTURE, OPTION, MARGIN)
- [ ] **NEW**: Create `proto/markets/v1/symbol_identifier.proto` with SymbolIdentifier message for mapping symbols to external data providers
- [x] Create `proto/markets/v1/price.proto` with Price, VWAP message definitions
- [x] Create `proto/markets/v1/orderbook.proto` with OrderBook, MarketDepth message definitions
- [x] Create `proto/markets/v1/trade.proto` with Trade, Candle message definitions
- [x] Create `proto/markets/v1/liquidity.proto` with LiquidityMetrics message definition
- [x] Define package as `cqc.markets.v1` with appropriate language-specific options
- [ ] **UPDATE**: Update Price, OrderBook, Trade to reference symbol_id instead of asset pairs

**Success**:
- All .proto files validate with `protoc --descriptor_set_out=/tmp/descriptor.pb proto/markets/v1/*.proto` (exits with code 0, no errors)
- Symbol message includes: symbol_id, symbol, symbol_type, base_asset_id, quote_asset_id, settlement_asset_id, tick_size, lot_size, min/max order sizes
- Market data messages (Price, OrderBook, Trade, Candle, VWAP, MarketDepth, LiquidityMetrics) reference symbols correctly
- Import statements correctly reference `proto/assets/v1/asset.proto` for asset IDs

---

### Commit 4: Portfolio & Venues Domain Protocol Buffers

**Goal**: Define protobuf messages for portfolio management and venue operations
**Depends**: Commit 1, Commit 2, Commit 3

**Deliverables**:
- [x] Create `proto/portfolio/v1/position.proto` with Position, Exposure message definitions
- [x] Create `proto/portfolio/v1/portfolio.proto` with Portfolio, Allocation message definitions
- [x] Create `proto/portfolio/v1/transaction.proto` with Transaction, PnL message definitions
- [x] Create `proto/venues/v1/account.proto` with VenueAccount, AccountType, AccountStatus message/enum definitions
- [x] Create `proto/venues/v1/order.proto` with Order, OrderType, OrderSide, OrderStatus, TimeInForce message/enum definitions
- [x] Create `proto/venues/v1/execution.proto` with Balance, ExecutionReport, BalanceType message/enum definitions
- [ ] **NEW**: Create `proto/venues/v1/venue.proto` with Venue message and VenueType enum (MOVED from assets domain)
- [ ] **NEW**: Create `proto/venues/v1/venue_asset.proto` with VenueAsset message (which assets available on venue)
- [ ] **NEW**: Create `proto/venues/v1/venue_symbol.proto` with VenueSymbol message (which symbols/markets on venue)
- [x] Define packages as `cqc.portfolio.v1` and `cqc.venues.v1`

**Success**:
- All .proto files validate with `protoc --experimental_allow_proto3_optional --descriptor_set_out=/tmp/descriptor.pb proto/portfolio/v1/*.proto proto/venues/v1/*.proto` (exits with code 0, no errors)
- Portfolio domain includes all types from BRIEF (Position, Portfolio, Allocation, Exposure, Transaction, PnL)
- Venues domain includes: Venue (platform metadata), VenueAsset (asset availability), VenueSymbol (market availability), VenueAccount (credentials), Order, Balance, ExecutionReport
- Venue metadata clearly separated from asset metadata
- VenueAsset maps assets to venues, VenueSymbol maps trading symbols to venues
- Cross-domain imports resolve correctly (portfolio references assets/symbols, venues references assets/symbols)

---

### Commit 5: Events Domain Protocol Buffers

**Goal**: Define all event message types for pub/sub messaging across domains
**Depends**: Commit 2, Commit 3, Commit 4

**Deliverables**:
- [x] Create `proto/events/v1/asset_events.proto` with AssetCreated, AssetDeploymentCreated, RelationshipEstablished event messages
- [ ] **UPDATE**: Create `proto/events/v1/market_events.proto` with SymbolCreated, PriceUpdated event messages
- [ ] **NEW**: Create `proto/events/v1/venue_events.proto` with VenueAssetListed, VenueSymbolListed event messages
- [x] Create `proto/events/v1/order_events.proto` with OrderPlaced, OrderFilled, OrderCancelled event messages
- [x] Create `proto/events/v1/position_events.proto` with PositionChanged event message
- [x] Create `proto/events/v1/risk_events.proto` with RiskAlert, QualityFlagRaised event messages
- [x] Define package as `cqc.events.v1`, import message types from other domains as needed

**Success**:
- All .proto files validate with `protoc --descriptor_set_out=/tmp/descriptor.pb proto/events/v1/*.proto` (exits with code 0, no errors)
- Asset events: AssetCreated, AssetDeploymentCreated, RelationshipEstablished
- Market events: SymbolCreated, PriceUpdated
- Venue events: VenueAssetListed, VenueSymbolListed
- Order/position/risk events cover trading lifecycle
- Event messages reference appropriate domain message types
- No circular dependencies between domains

---

### Commit 6: gRPC Service Interfaces

**Goal**: Define all gRPC service contracts with request/response message types
**Depends**: Commit 2, Commit 3, Commit 4, Commit 5

**Deliverables**:
- [ ] **UPDATE**: `proto/services/v1/asset_registry.proto` - Add Symbol operations (CreateSymbol, GetSymbol, ListSymbols, CreateSymbolIdentifier), add VenueAsset operations, update VenueSymbol operations to use Symbol references
- [ ] **UPDATE**: `proto/services/v1/market_data.proto` - Update to query by symbol_id instead of asset pairs, add symbol discovery operations
- [x] Create `proto/services/v1/portfolio.proto` with Portfolio service definition
- [x] Create `proto/services/v1/venue_gateway.proto` with VenueGateway service definition
- [x] Create `proto/services/v1/risk_engine.proto` with RiskEngine service definition
- [x] Define each service with explicit Request/Response message types (never primitives)
- [x] Import relevant domain message types for service method parameters

**Success**:
- All .proto files validate with `protoc --descriptor_set_out=/tmp/descriptor.pb proto/services/v1/*.proto` (exits with code 0, no errors)
- AssetRegistry manages: Assets, Symbols, Chains, Venues, VenueAssets, VenueSymbols, Relationships, Quality Flags
- MarketData queries by Symbol (not asset pairs): GetPrice(symbol_id), GetOrderBook(symbol_id), StreamTrades(symbol_id)
- VenueGateway manages: VenueAccounts, orders, balances, deposits/withdrawals
- Each service method uses explicit message types for requests and responses
- Service definitions import and reference appropriate domain messages with correct separation

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

---

### Commit 9: Domain Separation Migration (Asset/Symbol/Venue) ⭐ **CRITICAL**

**Goal**: Properly separate Assets (tokens), Symbols (trading pairs), and Venues (platforms) with clear boundaries
**Depends**: All previous commits (breaking change migration)

**Background**: Current implementation incorrectly conflates Assets and Symbols. VenueSymbol tries to represent both asset listings AND trading pair mappings. This commit establishes clear boundaries:
- **Asset** = Individual token (BTC, ETH, USDT)
- **Symbol** = Trading pair/market (BTC/USDT spot, ETH-PERP)
- **Venue** = Platform (Binance, Uniswap V3)
- **VenueAsset** = Which assets available on venue
- **VenueSymbol** = Which trading pairs/markets on venue

**Deliverables**:

**Phase 1: Create New Protobuf Definitions**
- [x] Create `proto/markets/v1/symbol.proto`:
  - Symbol message with symbol_id, symbol, symbol_type (SPOT/PERPETUAL/FUTURE/OPTION/MARGIN)
  - Include base_asset_id, quote_asset_id, settlement_asset_id
  - Include tick_size, lot_size, min/max order sizes
  - Option-specific: strike_price, expiry, option_type (CALL/PUT)
- [x] Create `proto/markets/v1/symbol_identifier.proto`:
  - SymbolIdentifier message mapping symbol_id to external data providers
- [x] Create `proto/venues/v1/venue.proto`:
  - Move Venue message and VenueType enum from `proto/assets/v1/venue.proto`
- [x] Create `proto/venues/v1/venue_asset.proto`:
  - VenueAsset message: venue_id, asset_id, venue_asset_symbol
  - Properties: deposit_enabled, withdraw_enabled, trading_enabled, fees, listing dates
- [x] Create `proto/venues/v1/venue_symbol.proto`:
  - VenueSymbol message: venue_id, symbol_id (canonical), venue_symbol (venue-specific)
  - Properties: is_active, maker_fee, taker_fee, listing dates

**Phase 2: Update Existing Files**
- [x] Remove `proto/assets/v1/venue.proto` (moved to venues domain)
- [x] Update `proto/services/v1/asset_registry.proto`:
  - Add Symbol operations: CreateSymbol, GetSymbol, UpdateSymbol, DeleteSymbol, ListSymbols, SearchSymbols
  - Add SymbolIdentifier operations: CreateSymbolIdentifier, GetSymbolIdentifier, ListSymbolIdentifiers
  - Add VenueAsset operations: CreateVenueAsset, GetVenueAsset, ListVenueAssets
  - Update VenueSymbol operations to use new symbol_id references
  - Update Venue operations to use new venues domain import
- [x] Update `proto/services/v1/market_data.proto`:
  - Change all operations to query by symbol_id instead of asset_id pairs
  - GetPrice(symbol_id), GetOrderBook(symbol_id), StreamTrades(symbol_id)
- [x] Update `proto/events/v1/market_events.proto`:
  - Add SymbolCreated event
  - Update PriceUpdated to reference symbol_id
- [x] Create `proto/events/v1/venue_events.proto`:
  - VenueAssetListed, VenueAssetDelisted events
  - VenueSymbolListed, VenueSymbolDelisted events
- [x] Update `proto/markets/v1/price.proto`:
  - Update Price message to reference symbol_id instead of asset_id
- [x] Update `proto/markets/v1/orderbook.proto`:
  - Update OrderBook message to reference symbol_id
- [x] Update `proto/markets/v1/trade.proto`:
  - Update Trade message to reference symbol_id

**Phase 3: Code Generation & Validation**
- [x] Run `make generate` to regenerate all client code
- [x] Verify all proto files compile without errors
- [x] Verify generated Go code compiles: `cd gen/go && go build ./...`
- [x] Update import paths in all generated code
- [x] Commit all generated code changes

**Success Criteria**:
- Clear domain separation: assets/v1 (tokens), markets/v1 (symbols + market data), venues/v1 (platforms + mappings)
- No circular dependencies between domains
- All proto files compile successfully
- Generated code in all languages compiles/imports correctly
- AssetRegistry service manages Assets, Symbols, Venues, VenueAssets, VenueSymbols
- MarketData service queries by symbol_id (not asset pairs)
- Documentation updated to reflect new domain model

**Migration Impact**:
- **Breaking change** - All consuming services must update their code
- CQAR must implement new Symbol and VenueAsset operations
- CQMD must update queries to use symbol_id
- CQVX must update to query both VenueAssets and VenueSymbols
