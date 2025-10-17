# Project Brief: CQC - Crypto Quant Contracts

## Vision
Central contract repository providing Protocol Buffer definitions, OpenAPI specs, and event schemas as the single source of truth for all service interfaces across the Crypto Quant trading platform, with automated code generation for Go, Python, and TypeScript clients.

## User Personas
### Primary User: Service Developer
- **Role:** Developer building or maintaining CQ platform services (cqar, cqvx, cqmd)
- **Needs:** Protobuf definitions for all data types, gRPC service contracts, generated client libraries, event schemas
- **Pain Points:** Type mismatches between services, manual boilerplate code, service synchronization overhead, breaking API changes
- **Success:** Import generated code and achieve type-safe inter-service communication immediately

### Secondary User: AI Agent
- **Role:** Autonomous system implementing features or services
- **Needs:** Complete protobuf definitions, explicit service contracts, event schemas, validation rules
- **Pain Points:** Ambiguous data structures, missing field definitions, unclear message formats, lack of usage examples
- **Success:** Generate service implementations with correct data types and successful inter-service communication

## Core Requirements

### Assets Domain (Individual Tokens/Coins)
- [MVP] Define protobuf messages: Asset, AssetIdentifier, AssetDeployment, AssetRelationship, AssetQualityFlag, Chain
- [MVP] Define protobuf enums: AssetType (NATIVE, ERC20, SPL, WRAPPED, SYNTHETIC, etc.), RelationshipType (WRAPS, BRIDGES, STAKES, etc.), DataSource (COINGECKO, COINMARKETCAP, DEFILLAMA, etc.), FlagType (SCAM, EXPLOITED, DEPRECATED, etc.), FlagSeverity (INFO, LOW, MEDIUM, HIGH, CRITICAL)
- [MVP] Support asset grouping (AssetGroup, AssetGroupMember) for aggregation (e.g., "all ETH variants")

### Markets Domain (Trading Instruments/Markets)
- [MVP] Define protobuf messages: Instrument (base product definition), SpotInstrument, PerpContract, FutureContract, OptionSeries, LendingDeposit, LendingBorrow (instrument subtypes)
- [MVP] Define protobuf message: Market (venue-specific listing of an instrument with trading rules, fees, limits)
- [MVP] Instrument subtypes use string fields instead of enums (e.g., instrument_type: "SPOT", "PERPETUAL", "FUTURE", "OPTION", "LENDING_DEPOSIT", "LENDING_BORROW")
- [MVP] Option fields use strings: option_type ("CALL", "PUT"), exercise_style ("european", "american")
- [MVP] Market includes: instrument_id, venue_id, venue_symbol, tick_size, lot_size, fees, trading limits, metadata for AMM/lending/perp specifics
- [MVP] All decimal values (prices, fees, sizes) stored as strings for precision
- [MVP] Define market data messages: Price, OrderBook, Trade, Candle, VWAP, MarketDepth, LiquidityMetrics (all using market_id instead of symbol_id)

### Identifiers Domain (External ID Mappings)
- [MVP] Define protobuf message: Identifier (unified external identifier mapping for any entity type)
- [MVP] Identifier supports mapping for assets, instruments, or markets to external data sources
- [MVP] entity_type uses strings: "ASSET", "INSTRUMENT", "MARKET"
- [MVP] Exactly one of asset_id, instrument_id, or market_id must be set per identifier

### Venues Domain (Exchanges/Protocols)
- [MVP] Define protobuf messages: Venue (exchange/protocol metadata), VenueAsset (which assets listed on venue)
- [MVP] Define protobuf enums: VenueType (CEX, DEX, DEX_AGGREGATOR, BRIDGE, LENDING), AccountType (SPOT, MARGIN, FUTURES, OPTIONS, WALLET), AccountStatus (ACTIVE, INACTIVE, SUSPENDED, etc.)
- [MVP] Venue account management: VenueAccount (credentials, permissions, fees, limits), Balance, Order, ExecutionReport
- [MVP] Clear separation: Venue = platform metadata, VenueAsset = asset availability, Market = instrument listings with trading rules

### Portfolio Domain (Position Tracking)
- [MVP] Define protobuf messages: Position, Portfolio, Allocation, Exposure, Transaction, PnL

### Events Domain (Inter-Service Communication)
- [MVP] Define event messages: AssetCreated, AssetDeploymentCreated, RelationshipEstablished, InstrumentCreated, MarketCreated, VenueAssetListed, VenueMarketListed, PriceUpdated, OrderPlaced, PositionChanged, RiskAlert

### Service Interfaces
- [MVP] Define gRPC service: AssetRegistry (manages Assets, Instruments, Markets, Identifiers, Venues, VenueAssets, Chains)
- [MVP] AssetRegistry provides RPCs: GetInstrument, GetSpotInstrument, GetPerpContract, GetFutureContract, GetOptionSeries, GetLendingDeposit, GetLendingBorrow, GetMarket, ResolveMarket (by venue_id + venue_symbol)
- [MVP] Define gRPC service: VenueGateway (manages VenueAccounts, order execution, balance queries, deposits/withdrawals)
- [MVP] Define gRPC service: MarketData (price feeds using market_id, orderbook streams, trade history)
- [MVP] Define gRPC service: Portfolio (position tracking, PnL calculation)
- [MVP] Define gRPC service: RiskEngine (risk limits, exposure monitoring)

### Code Generation & Organization
- [MVP] Provide Makefile with code generation targets for Go, Python, TypeScript from protobuf definitions
- [MVP] Organize protos by versioned domain structure (assets/v1/, markets/v1/, identifiers/v1/, venues/v1/, portfolio/v1/, events/v1/, services/v1/)
- [MVP] Commit generated code to repository for versioning and easy import

### Post-MVP
- [Post MVP] Define OpenAPI 3.0 specifications for REST endpoints per service
- [Post MVP] Provide JSON Schema definitions for service configuration files
- [Post MVP] Include usage examples and integration tests for generated code in all target languages

## Success Metrics
1. 100% of CQ platform services (12 total) successfully import and use generated code without modification
2. Zero type mismatches or serialization errors between services in production over 30-day period
3. New service integration time reduced to <1 hour from contract import to successful inter-service communication