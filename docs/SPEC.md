# MVP Technical Specification: CQC - Crypto Quant Contracts

**Project Type:** Shared Contract Library (Protocol Buffer definitions + code generation)

## Domain Separation Principles

### Critical Distinctions

**Asset vs Symbol vs Venue**
- **Asset** = Individual token/coin (BTC, ETH, USDT, WETH)
  - Lives in: `assets/v1/asset.proto`
  - Examples: Bitcoin, Ethereum, USD Coin, Wrapped Ether
  - Properties: symbol, name, type, deployments across chains
  
- **Symbol** = Trading pair/market (BTC/USDT spot, ETH-PERP, BTC-25OCT24-3000-C)
  - Lives in: `markets/v1/symbol.proto`
  - Examples: BTC/USDT spot, ETH/USD perpetual, ETH call option
  - Properties: base_asset_id, quote_asset_id, type (SPOT/PERPETUAL/FUTURE/OPTION), market specs
  
- **Venue** = Exchange/protocol platform (Binance, Uniswap V3, dYdX)
  - Lives in: `venues/v1/venue.proto`
  - Examples: Binance (CEX), Uniswap V3 on Ethereum (DEX), dYdX (DEX Perpetuals)
  - Properties: venue_id, name, type, API endpoints

**VenueAsset vs VenueSymbol**
- **VenueAsset** = Asset availability on a venue (which tokens you can trade)
  - "Binance lists BTC, ETH, USDT"
  - "Uniswap V3 on Ethereum lists WETH, USDC, DAI"
  
- **VenueSymbol** = Symbol/market availability on a venue (which trading pairs exist)
  - "Binance offers BTC/USDT spot market as 'BTCUSDT'"
  - "Binance offers BTC/USDT perpetual as 'BTCUSDT' in futures"
  - "dYdX offers ETH/USD perpetual as 'ETH-USD'"

**DataSource vs Venue**
- **DataSource** = Information provider (CoinGecko, CoinMarketCap, DeFiLlama)
  - Purpose: Get asset metadata, prices, market cap
  - AssetIdentifier: Canonical Asset → CoinGecko ID
  - SymbolIdentifier: Canonical Symbol → Provider ID
  
- **Venue** = Tradeable platform (Binance, Coinbase, Uniswap)
  - Purpose: Execute orders, deposit, withdraw
  - VenueAsset: Which assets exist on venue
  - VenueSymbol: Which symbols/markets exist on venue

## Core Requirements (from Brief)

### MVP Scope

#### Assets Domain (Individual Tokens/Coins)
- Define protobuf messages: Asset, AssetIdentifier, AssetDeployment, AssetRelationship, AssetQualityFlag, Chain, AssetGroup, AssetGroupMember
- Define protobuf enums: AssetType, RelationshipType, DataSource, FlagType, FlagSeverity
- Asset represents individual tokens (BTC, ETH, USDT, WETH)
- AssetDeployment tracks token addresses across chains
- AssetRelationship maps wrapping/staking/bridging relationships

#### Markets Domain (Trading Pairs/Markets)
- Define protobuf messages: Symbol, SymbolIdentifier
- Define protobuf enums: SymbolType (SPOT, PERPETUAL, FUTURE, OPTION, MARGIN), OptionType (CALL, PUT)
- Symbol represents trading pairs/markets (BTC/USDT spot, ETH-PERP, BTC-25OCT24-3000-C)
- Symbol includes: base_asset_id, quote_asset_id, settlement_asset_id, tick_size, lot_size, order limits
- SymbolIdentifier maps canonical symbols to external data provider identifiers
- Define market data messages: Price, OrderBook, Trade, Candle, VWAP, MarketDepth, LiquidityMetrics

#### Venues Domain (Exchanges/Protocols)
- Define protobuf messages: Venue, VenueAsset, VenueSymbol, VenueAccount, Balance, Order, ExecutionReport
- Define protobuf enums: VenueType (CEX, DEX, DEX_AGGREGATOR, BRIDGE, LENDING), AccountType, AccountStatus, OrderType, OrderSide, OrderStatus, TimeInForce, BalanceType
- Venue represents exchange/protocol metadata (Binance, Uniswap V3, dYdX)
- VenueAsset maps which assets are available on each venue
- VenueSymbol maps which trading symbols/markets are available on each venue
- VenueAccount manages user credentials and permissions per venue

#### Portfolio Domain (Position Tracking)
- Define protobuf messages: Position, Portfolio, Allocation, Exposure, Transaction, PnL

#### Events Domain (Inter-Service Communication)
- Define event messages: AssetCreated, AssetDeploymentCreated, RelationshipEstablished, SymbolCreated, VenueAssetListed, VenueSymbolListed, PriceUpdated, OrderPlaced, PositionChanged, RiskAlert, QualityFlagRaised

#### Service Interfaces
- AssetRegistry: Manages Assets, Symbols, Chains, Venues, VenueAssets, VenueSymbols, Relationships, Quality Flags
- VenueGateway: Manages VenueAccounts, order execution, balance queries, deposits/withdrawals
- MarketData: Price feeds, orderbook streams, trade history for Symbols
- Portfolio: Position tracking, PnL calculation
- RiskEngine: Risk limits, exposure monitoring

#### Code Generation & Organization
- Provide Makefile with code generation targets for Go, Python, TypeScript from protobuf definitions
- Organize protos by versioned domain structure (assets/v1/, markets/v1/, venues/v1/, portfolio/v1/, events/v1/, services/v1/)
- Commit generated code to repository for versioning

### Post-MVP Scope
- Define OpenAPI 3.0 specifications for REST endpoints per service
- Provide JSON Schema definitions for service configuration files
- Include usage examples and integration tests for generated code in all target languages

## Technology Stack

### Core Technologies
- **Protocol Buffers v3** - Industry standard for service contracts, supports code generation for all target languages
- **gRPC** - High-performance RPC framework built on protobuf, native Go/Python/TypeScript support
- **Make** - Standard build automation tool, universal availability on development machines

### Code Generation Tools
- **protoc** (Protocol Buffer Compiler) - Official compiler for .proto files
- **protoc-gen-go** + **protoc-gen-go-grpc** - Official Go code generators
- **grpc-tools** (Python) - Official Python protobuf/gRPC code generator
- **grpc-web** or **@grpc/grpc-js** + **@grpc/proto-loader** (TypeScript) - Official TypeScript/Node.js generators

### Justification for Choices
- Protocol Buffers: Type-safe, language-agnostic, backward-compatible, smaller payload than JSON
- gRPC: Built-in streaming, load balancing, authentication, better performance than REST for inter-service communication
- Makefile: Simple, widely understood, no additional runtime dependencies

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        CQC Repository                            │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │            Protocol Buffer Definitions (.proto)           │  │
│  │                                                            │  │
│  │  ┌─────────┐ ┌─────────┐ ┌──────────┐ ┌────────┐        │  │
│  │  │ assets/ │ │ markets/│ │portfolio/│ │ venues/│ ...    │  │
│  │  │   v1/   │ │   v1/   │ │   v1/    │ │  v1/   │        │  │
│  │  └─────────┘ └─────────┘ └──────────┘ └────────┘        │  │
│  │                                                            │  │
│  │  ┌──────────────────────────────────────────────────┐    │  │
│  │  │  gRPC Service Definitions (services/*.proto)     │    │  │
│  │  └──────────────────────────────────────────────────┘    │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              │                                  │
│                              ▼                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    Makefile                               │  │
│  │              (protoc + code generators)                   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              │                                  │
│                ┌─────────────┼─────────────┐                   │
│                ▼             ▼             ▼                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │   gen/go/    │  │  gen/python/ │  │   gen/ts/    │        │
│  │   (*.pb.go)  │  │   (*_pb2.py) │  │  (*.ts/*.js) │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────────┐
        │    Consuming Services (cqar, cqvx, etc.)    │
        │      Import generated code as modules       │
        └─────────────────────────────────────────────┘
```

## Data Flow

### Primary Development Flow (Service Developer)

1. **Service developer identifies need for new data type or service interface**
   - Example: Need to add `LiquidationEvent` to events domain

2. **Developer updates or creates .proto file in cqc repository**
   - Edits `proto/events/v1/events.proto`
   - Defines new message with appropriate fields and types

3. **Developer runs `make generate`**
   - Makefile invokes protoc with language-specific generators
   - Generated code output to `gen/go/`, `gen/python/`, `gen/ts/`

4. **Developer commits changes and publishes new version**
   - Git commit includes both .proto changes and generated code
   - Version tag applied (e.g., `v1.2.0`)

5. **Consuming services update their cqc dependency**
   - Go: `go get github.com/Combine-Capital/cqc@v1.2.0`
   - Python: `pip install cqc==1.2.0`
   - TypeScript: `npm install @cq/cqc@1.2.0`

6. **Service immediately has type-safe access to new contracts**
   - Import generated types/clients
   - IDE provides autocomplete and type checking

## System Components

### Protocol Buffer Definitions
**Purpose:** Define all shared data structures and service interfaces as the single source of truth

**Inputs:** 
- Domain requirements from service teams
- Data modeling decisions for trading platform entities

**Outputs:** 
- Versioned .proto files organized by domain
- Language-agnostic interface definitions

**Dependencies:** 
- Protocol Buffers v3 syntax specification
- gRPC service definition conventions

**Key Responsibilities:**
- Define message structure for assets domain (Asset, AssetIdentifier, AssetDeployment, AssetGroup, AssetGroupMember, AssetRelationship, AssetQualityFlag, Chain)
- Define enum types for assets (AssetType, RelationshipType, DataSource, FlagType, FlagSeverity)
- Define message structure for markets domain (Symbol, SymbolIdentifier, Price, OrderBook, Trade, Candle, VWAP, MarketDepth, LiquidityMetrics)
- Define enum types for markets (SymbolType, OptionType)
- Define message structure for venues domain (Venue, VenueAsset, VenueSymbol, VenueAccount, Balance, Order, ExecutionReport)
- Define enum types for venues (VenueType, AccountType, AccountStatus, OrderType, OrderSide, OrderStatus, TimeInForce, BalanceType)
- Define message structure for portfolio domain (Position, Portfolio, Allocation, Exposure, Transaction, PnL)
- Define message structure for events domain (AssetCreated, AssetDeploymentCreated, RelationshipEstablished, SymbolCreated, VenueAssetListed, VenueSymbolListed, PriceUpdated, OrderPlaced, PositionChanged, RiskAlert, QualityFlagRaised)
- Define gRPC service interfaces (AssetRegistry, MarketData, Portfolio, VenueGateway, RiskEngine)
- Maintain backward compatibility through proper versioning
- Include field-level documentation and validation constraints
- Clearly separate Assets (tokens) from Symbols (trading pairs) from Venues (platforms)

**Post-MVP:**
- Add OpenAPI annotations for REST endpoint generation
- Include JSON schema generation directives

---

### Code Generation Pipeline (Makefile)
**Purpose:** Automate generation of type-safe client/server code in Go, Python, and TypeScript

**Inputs:**
- All .proto files from domain directories
- Language-specific generator configurations

**Outputs:**
- Go packages with .pb.go and _grpc.pb.go files
- Python modules with _pb2.py and _pb2_grpc.py files
- TypeScript declaration files and compiled JavaScript

**Dependencies:**
- protoc compiler (v3.20+)
- protoc-gen-go (v1.28+)
- protoc-gen-go-grpc (v1.2+)
- grpcio-tools (Python, v1.50+)
- grpc-tools (TypeScript, v1.12+)

**Key Responsibilities:**
- Discover all .proto files in versioned domain directories
- Generate Go code with proper module paths
- Generate Python code with proper package structure
- Generate TypeScript code with type declarations
- Validate generated code compiles without errors
- Provide clean/regenerate targets for development workflow

**Post-MVP:**
- Generate validation code from constraint annotations
- Generate REST gateway code from OpenAPI annotations
- Run integration tests on generated code

---

### Generated Code Artifacts
**Purpose:** Provide ready-to-import, type-safe client libraries for consuming services

**Inputs:**
- Generated code from compilation pipeline
- Language-specific packaging metadata

**Outputs:**
- Go module publishable via Go modules
- Python package publishable to PyPI
- TypeScript/JavaScript package publishable to npm

**Dependencies:**
- go.mod for Go module definition
- setup.py/pyproject.toml for Python packaging
- package.json for npm packaging

**Key Responsibilities:**
- Organize generated code by language and domain
- Provide idiomatic interfaces for each target language
- Include type information for IDE integration
- Version artifacts in sync with proto definitions
- Enable simple import patterns (e.g., `from cqc.markets.v1 import Price`)

**Post-MVP:**
- Include usage examples in each language
- Provide mock/test utilities for consuming services
- Generate API documentation from proto comments

## File Structure

```
cqc/
├── proto/                          # Protocol Buffer definitions
│   ├── assets/v1/                  # INDIVIDUAL TOKENS/COINS
│   │   ├── asset.proto             # Asset, AssetIdentifier, AssetType enum, DataSource enum
│   │   ├── deployment.proto        # AssetDeployment (on-chain addresses)
│   │   ├── relationship.proto      # AssetRelationship, RelationshipType enum (wraps, bridges, stakes)
│   │   ├── quality.proto           # AssetQualityFlag, FlagType enum, FlagSeverity enum
│   │   └── chain.proto             # Chain (blockchain networks)
│   │
│   ├── markets/v1/                 # TRADING PAIRS/MARKETS
│   │   ├── symbol.proto            # Symbol, SymbolType enum (SPOT, PERPETUAL, FUTURE, OPTION)
│   │   ├── symbol_identifier.proto # SymbolIdentifier (Symbol → external data provider)
│   │   ├── price.proto             # Price, VWAP
│   │   ├── orderbook.proto         # OrderBook, MarketDepth
│   │   ├── trade.proto             # Trade, Candle
│   │   └── liquidity.proto         # LiquidityMetrics
│   │
│   ├── venues/v1/                  # EXCHANGES/PROTOCOLS
│   │   ├── venue.proto             # Venue (exchange/protocol metadata), VenueType enum
│   │   ├── venue_asset.proto       # VenueAsset (which assets available on venue)
│   │   ├── venue_symbol.proto      # VenueSymbol (which symbols/markets on venue)
│   │   ├── account.proto           # VenueAccount (credentials, permissions), AccountType, AccountStatus
│   │   ├── order.proto             # Order, OrderType, OrderSide, OrderStatus, TimeInForce
│   │   └── execution.proto         # Balance, ExecutionReport, BalanceType
│   │
│   ├── portfolio/v1/               # POSITION TRACKING
│   │   ├── position.proto          # Position, Exposure
│   │   ├── portfolio.proto         # Portfolio, Allocation
│   │   └── transaction.proto       # Transaction, PnL
│   │
│   ├── events/v1/                  # INTER-SERVICE EVENTS
│   │   ├── asset_events.proto      # AssetCreated, AssetDeploymentCreated, RelationshipEstablished
│   │   ├── market_events.proto     # SymbolCreated, PriceUpdated
│   │   ├── venue_events.proto      # VenueAssetListed, VenueSymbolListed
│   │   ├── order_events.proto      # OrderPlaced, OrderFilled, OrderCancelled
│   │   ├── position_events.proto   # PositionChanged
│   │   └── risk_events.proto       # RiskAlert, QualityFlagRaised
│   │
│   └── services/v1/                # GRPC SERVICE INTERFACES
│       ├── asset_registry.proto    # AssetRegistry (Assets, Symbols, Venues, VenueAssets, VenueSymbols, Chains)
│       ├── market_data.proto       # MarketData (price feeds, orderbooks for Symbols)
│       ├── portfolio.proto         # Portfolio (position tracking, PnL)
│       ├── venue_gateway.proto     # VenueGateway (VenueAccounts, orders, balances, execution)
│       └── risk_engine.proto       # RiskEngine (risk limits, exposure monitoring)
│
├── gen/                            # Generated code (committed to repo)
│   ├── go/
│   │   └── cqc/                    # Go module: github.com/Combine-Capital/cqc/gen/go/cqc
│   │       ├── assets/v1/*.pb.go
│   │       ├── markets/v1/*.pb.go
│   │       ├── portfolio/v1/*.pb.go
│   │       ├── venues/v1/*.pb.go
│   │       ├── events/v1/*.pb.go
│   │       └── services/v1/*_grpc.pb.go
│   ├── python/
│   │   └── cqc/                    # Python package: cqc
│   │       ├── assets/v1/*_pb2.py
│   │       ├── markets/v1/*_pb2.py
│   │       ├── portfolio/v1/*_pb2.py
│   │       ├── venues/v1/*_pb2.py
│   │       ├── events/v1/*_pb2.py
│   │       └── services/v1/*_pb2_grpc.py
│   └── ts/
│       └── cqc/                    # TypeScript package: @cq/cqc
│           ├── assets/v1/*.ts
│           ├── markets/v1/*.ts
│           ├── portfolio/v1/*.ts
│           ├── venues/v1/*.ts
│           ├── events/v1/*.ts
│           └── services/v1/*.ts
│
├── Makefile                        # Build automation
├── go.mod                          # Go module definition
├── setup.py                        # Python package definition
├── package.json                    # npm package definition
├── README.md                       # Usage instructions
└── docs/
    ├── BRIEF.md                    # Project brief
    └── SPEC.md                     # This specification
```

## Integration Patterns

### MVP Usage Pattern

**For Service Developers (Primary Flow):**

1. **Add cqc as dependency to service**
   ```bash
   # Go service
   go get github.com/Combine-Capital/cqc/gen/go/cqc
   
   # Python service
   pip install cqc
   
   # TypeScript service
   npm install @cq/cqc
   ```

2. **Import required types and service clients**
   ```go
   // Go example
   import (
       assetpb "github.com/Combine-Capital/cqc/gen/go/cqc/assets/v1"
       marketpb "github.com/Combine-Capital/cqc/gen/go/cqc/markets/v1"
       "github.com/Combine-Capital/cqc/gen/go/cqc/services/v1"
   )
   ```
   
   ```python
   # Python example
   from cqc.assets.v1 import asset_pb2
   from cqc.markets.v1 import price_pb2
   from cqc.services.v1 import market_data_pb2_grpc
   ```
   
   ```typescript
   // TypeScript example
   import { Asset, Token } from '@cq/cqc/assets/v1';
   import { Price, OrderBook } from '@cq/cqc/markets/v1';
   import { MarketDataClient } from '@cq/cqc/services/v1';
   ```

3. **Use types for data structures**
   ```go
   // Create a price update
   price := &marketpb.Price{
       AssetId: "BTC-USD",
       Value:   67890.50,
       Timestamp: timestamppb.Now(),
   }
   ```

4. **Implement or consume gRPC services**
   ```go
   // Consume a service
   conn, _ := grpc.Dial("localhost:50051")
   client := servicespb.NewMarketDataClient(conn)
   resp, _ := client.GetPrice(ctx, &servicespb.GetPriceRequest{
       AssetId: "BTC-USD",
   })
   
   // Implement a service
   type marketDataServer struct {
       servicespb.UnimplementedMarketDataServer
   }
   
   func (s *marketDataServer) GetPrice(ctx context.Context, req *servicespb.GetPriceRequest) (*marketpb.Price, error) {
       // Implementation uses exact types from cqc
   }
   ```

**For AI Agents (Secondary Flow):**

1. **Parse proto files to understand data structures**
   - Read .proto files to extract message definitions
   - Understand field types, required/optional flags, nested structures

2. **Generate service implementation scaffolding**
   - Import generated types from cqc
   - Implement service interfaces defined in services/v1/*.proto
   - Use message types for parameters and return values

3. **Validate implementation against contracts**
   - Ensure all required fields are populated
   - Match exact types expected by service interfaces
   - Follow gRPC patterns for error handling

### Post-MVP Extensions

**Validation and Constraints:**
- Add protobuf validation rules using `protoc-gen-validate`
- Generate validation code alongside message definitions
- Services automatically validate messages on receive

**REST Gateway:**
- Add google.api.http annotations to service definitions
- Generate REST gateway proxies using grpc-gateway
- Provide HTTP/JSON alternative to gRPC for browser clients

**Documentation Generation:**
- Generate API documentation from proto comments
- Create interactive API explorers (e.g., Buf Studio)
- Provide language-specific usage guides and examples

**Mock Generation:**
- Generate mock implementations for testing
- Provide factory functions for test data creation
- Include contract testing utilities

**Breaking Change Detection:**
- Use Buf Schema Registry or similar tool
- CI pipeline checks for breaking changes before merge
- Automated semantic versioning based on proto changes
