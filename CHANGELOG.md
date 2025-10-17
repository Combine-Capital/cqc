# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2025-10-17

### Changed - Major Architecture Refactor: Symbol → Instrument + Market

**BREAKING CHANGES**: This release introduces a fundamental architectural change from Symbol-based to Instrument + Market architecture with string-based types instead of enums.

#### Removed Files
- **BREAKING**: Deleted `proto/markets/v1/symbol.proto` - Replaced with Instrument + Market pattern
- **BREAKING**: Deleted `proto/markets/v1/symbol_identifier.proto` - Replaced with unified Identifier
- **BREAKING**: Deleted `proto/venues/v1/venue_symbol.proto` - Replaced with Market (in markets domain)

#### New Files - Instrument Domain (9 files)

**Base Instrument**
- Added `proto/markets/v1/instrument.proto` - Product-level abstraction independent of venue
  - Fields: id, instrument_type (string), code, timestamps
  - instrument_type values: "SPOT", "PERPETUAL", "FUTURE", "OPTION", "LENDING_DEPOSIT", "LENDING_BORROW"

**Instrument Subtypes** (1:1 relationship with Instrument via instrument_id)
- Added `proto/markets/v1/spot_instrument.proto` - Spot trading pairs (e.g., ETH/USDT)
- Added `proto/markets/v1/perp_contract.proto` - Perpetual futures contracts
- Added `proto/markets/v1/future_contract.proto` - Dated futures with expiry
- Added `proto/markets/v1/option_series.proto` - Options contracts with strike/type/style
- Added `proto/markets/v1/lending_deposit.proto` - Lending deposit products (e.g., Aave WETH)
- Added `proto/markets/v1/lending_borrow.proto` - Lending borrow products (e.g., Aave USDC)

**Market (Venue Listing)**
- Added `proto/markets/v1/market.proto` - Venue-specific instrument listings
  - Links instrument to venue with trading rules, fees, limits
  - All decimal fields as strings (tick_size, lot_size, fees, etc.)
  - Status field as string: "active", "suspended", "delisted"
  - Metadata support for AMM pools, lending markets, perpetual contracts

**Unified Identifiers**
- Added `proto/identifiers/v1/identifier.proto` - Single identifier mapping for all entities
  - Supports entity_type: "ASSET", "INSTRUMENT", "MARKET"
  - Exactly one of asset_id, instrument_id, market_id must be set

#### Service Updates

**AssetRegistry Service** (`proto/services/v1/asset_registry.proto`)
- **BREAKING**: Removed all Symbol-related RPCs (GetSymbol, ListSymbols, CreateSymbol, etc.)
- **BREAKING**: Removed all SymbolIdentifier RPCs
- **BREAKING**: Removed all VenueSymbol RPCs
- Added 9 new RPCs:
  - `GetInstrument` - Retrieve base instrument by ID
  - `GetSpotInstrument` - Retrieve spot instrument details
  - `GetPerpContract` - Retrieve perpetual contract details
  - `GetFutureContract` - Retrieve future contract details
  - `GetOptionSeries` - Retrieve option series details
  - `GetLendingDeposit` - Retrieve lending deposit details
  - `GetLendingBorrow` - Retrieve lending borrow details
  - `GetMarket` - Retrieve market by market_id
  - `ResolveMarket` - Resolve market by venue_id + venue_symbol

**MarketData Service** (`proto/services/v1/market_data.proto`)
- **BREAKING**: Replaced all `symbol_id` fields with `market_id` (venue-specific)
- Added `instrument_id` support for product-level aggregation across venues
- Added venue_id + venue_symbol resolver option in GetPrice request

#### Market Data Messages

**Price** (`proto/markets/v1/price.proto`)
- **BREAKING**: Changed `symbol_id` → `market_id` in Price message
- **BREAKING**: Changed `symbol_id` → `market_id` in VWAP message

**Trade** (`proto/markets/v1/trade.proto`)
- **BREAKING**: Changed `symbol_id` → `market_id` in Trade message
- **BREAKING**: Changed `symbol_id` → `market_id` in Candle message

**OrderBook** (`proto/markets/v1/orderbook.proto`)
- **BREAKING**: Changed `symbol_id` → `market_id` in OrderBook message
- **BREAKING**: Changed `symbol_id` → `market_id` in MarketDepth message

#### Events

**Market Events** (`proto/events/v1/market_events.proto`)
- **BREAKING**: Removed `SymbolCreated` event
- Added `InstrumentCreated` event - Published when new instrument is registered
- Added `MarketCreated` event - Published when new market listing is created

**Venue Events** (`proto/events/v1/venue_events.proto`)
- **BREAKING**: Removed `VenueSymbolListed` and `VenueSymbolDelisted` events
- Added `VenueMarketListed` event - Published when market becomes available on venue
- Added `VenueMarketDelisted` event - Published when market is removed from venue

#### Design Principles

**String-based Types (No Enums)**
- All type discriminators use strings to avoid breaking changes
- instrument_type: "SPOT", "PERPETUAL", "FUTURE", "OPTION", "LENDING_DEPOSIT", "LENDING_BORROW"
- option_type: "CALL", "PUT"
- exercise_style: "european", "american"
- market.status: "active", "suspended", "delisted"
- identifier.entity_type: "ASSET", "INSTRUMENT", "MARKET"

**Decimal Precision**
- All monetary and decimal values stored as strings
- Examples: strike_price, contract_multiplier, tick_size, lot_size, fees
- Preserves precision, avoids floating-point errors

**Separation of Concerns**
- Instrument = Product definition (what is being traded)
- Market = Venue listing (where and how it trades)
- Clear distinction between product-level and venue-specific data

#### Documentation

- Updated `docs/BRIEF.md` with new Instrument + Market architecture
- Updated `docs/SPEC.md` with detailed domain model explanations
- Updated `docs/ROADMAP.md` with Commit 10 implementation summary
- Added `docs/REFACTOR_VALIDATION_RESULTS.md` with comprehensive validation report

#### Migration Guide

**For Service Developers:**
1. Replace imports of `symbol.proto` with `instrument.proto` and `market.proto`
2. Change all `symbol_id` references to `market_id` for venue-specific operations
3. Use `instrument_id` for product-level operations (cross-venue aggregation)
4. Update to new AssetRegistry RPCs (GetInstrument, GetMarket, etc.)
5. Handle string-based types instead of enums

**For Database Schemas:**
1. Split symbol tables into instrument and market tables
2. Create subtype tables: spot_instruments, perp_contracts, future_contracts, option_series, lending_deposits, lending_borrows
3. Update foreign keys from symbol_id to market_id or instrument_id as appropriate
4. Migrate enum columns to string columns

## [0.3.1] - 2025-10-15

### Fixed

**Build System**
- Updated Makefile to automatically clean generated code before regeneration
- `make generate` now calls `clean` first to prevent stale files
- Removed stale `gen/go/cqc/assets/v1/venue.pb.go` (leftover from domain migration in v0.1.0)

### Changed

**Documentation**
- Added comprehensive v0.3.0 changelog documentation

## [0.3.0] - 2025-10-15

### Changed - Proto Definition Cleanup and Standardization

#### Assets Domain Updates

**`proto/assets/v1/chain.proto`**
- **BREAKING**: Standardized chain identifiers to uppercase (e.g., "ETHEREUM", "POLYGON", "ARBITRUM", "SOLANA", "BITCOIN")
- **BREAKING**: Standardized chain types to uppercase (e.g., "EVM", "SOLANA", "BITCOIN", "COSMOS")
- Removed `rpc_url` field (field 7) - RPC endpoints should be managed at infrastructure level, not in canonical definitions
- Renumbered fields 8-9 to 7-8 for cleaner field numbering

**`proto/assets/v1/deployment.proto`**
- **BREAKING**: Standardized deployment_id format to use uppercase chain IDs (e.g., "ETHEREUM:0xA0b8...", "SOLANA:EPjF...")
- **BREAKING**: Standardized chain_id values to uppercase
- Removed deployment-specific fields that belong at infrastructure/indexer level:
  - `is_canonical` (field 7) - Canonicality is a relationship concern
  - `deployment_block` (field 8) - Infrastructure detail
  - `deployment_tx` (field 9) - Infrastructure detail
  - `deployer_address` (field 10) - Infrastructure detail
  - `is_verified` (field 11) - Explorer-specific metadata
- Renumbered remaining fields for cleaner structure (fields 12-15 → 7-10)
- Simplified to focus on essential deployment information: contract address, decimals, timestamps

**`proto/assets/v1/relationship.proto`**
- Improved documentation for `AssetGroup.name` field with concrete examples
- Added examples: "usdc_variants", "eth_equivalents", "top_10_by_mcap", "stablecoins"

#### Generated Code
- Regenerated Go bindings for all updated proto definitions
- Reduced generated code size due to removed fields

### Rationale

This release focuses on **separation of concerns** and **data modeling clarity**:

1. **Uppercase identifiers**: Chain IDs and types are now consistently uppercase, treating them as constants rather than freeform strings
2. **Removed infrastructure fields**: Fields like `rpc_url`, `deployment_block`, `deployer_address` are infrastructure concerns, not part of the canonical asset model
3. **Simplified deployments**: AssetDeployment now focuses solely on "where does this asset exist" rather than "how was it deployed"
4. **Cleaner field numbering**: Removed gaps in field numbers for better readability

### Migration Guide

#### Chain ID Updates
```go
// Old
chainId := "ethereum"
chainType := "evm"

// New
chainId := "ETHEREUM"
chainType := "EVM"
```

#### Deployment ID Updates
```go
// Old
deploymentId := "ethereum:0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"

// New
deploymentId := "ETHEREUM:0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
```

#### Removed Fields
If you were using removed fields, handle them as follows:
- `Chain.rpc_url` → Manage RPC endpoints in your infrastructure configuration
- `AssetDeployment.is_canonical` → Use AssetRelationship with CANONICAL type
- `AssetDeployment.deployment_block/tx/deployer_address` → Query from blockchain indexer
- `AssetDeployment.is_verified` → Query from block explorer API

## [0.1.0] - 2025-10-14

### Added - Initial Release with Domain Separation

#### New Proto Definitions
- **`proto/markets/v1/symbol.proto`** - Trading symbol/market definitions
  - `Symbol` message with support for SPOT, PERPETUAL, FUTURE, OPTION, MARGIN types
  - Includes base_asset_id, quote_asset_id, settlement_asset_id
  - Market specifications: tick_size, lot_size, min/max order sizes
  - Option-specific fields: strike_price, expiry, option_type

- **`proto/markets/v1/symbol_identifier.proto`** - Symbol to external data provider mappings
  - Maps canonical symbols to CoinGecko, CoinMarketCap, DefiLlama, etc.
  - DataSource enum for different market data providers

- **`proto/venues/v1/venue.proto`** - Exchange/protocol platform definitions
  - Migrated from assets domain with VenueType enum
  - Supports CEX, DEX, DEX Aggregators, Bridges, Lending protocols

- **`proto/venues/v1/venue_asset.proto`** - Asset availability on venues
  - Tracks which tokens are available on which platforms
  - deposit/withdraw/trading enabled flags, fees, listing dates

- **`proto/venues/v1/venue_symbol.proto`** - Symbol/market availability on venues
  - Maps canonical symbols to venue-specific representations
  - Fee structures: maker/taker fees, leverage limits

- **`proto/events/v1/venue_events.proto`** - Venue-related events
  - VenueAssetListed/VenueAssetDelisted events
  - VenueSymbolListed/VenueSymbolDelisted events

- **`proto/events/v1/market_events.proto`** - Added SymbolCreated event

#### Updated Proto Definitions
- **`proto/markets/v1/price.proto`** - Changed from asset_id pairs to symbol_id
- **`proto/markets/v1/orderbook.proto`** - Updated to reference symbol_id
- **`proto/markets/v1/trade.proto`** - Updated to reference symbol_id
- **`proto/services/v1/market_data.proto`** - All methods now query by symbol_id
- **`proto/services/v1/asset_registry.proto`** - Added Symbol, SymbolIdentifier, and VenueAsset operations

#### Removed
- **`proto/assets/v1/venue.proto`** - Moved to venues domain

### Features

#### Clean Domain Architecture
- **MarketData service** now requires `symbol_id` instead of `asset_id` + `quote_asset_id` pairs
  - `GetPrice(symbol_id)` instead of `GetPrice(asset_id, quote_asset_id)`
  - `GetOrderBook(symbol_id)` instead of `GetOrderBook(asset_id, quote_asset_id)`
  - `StreamTrades(symbol_id)` instead of `StreamTrades(asset_id, quote_asset_id)`

- **Price, OrderBook, Trade, Candle, VWAP messages** now use `symbol_id` field
  - Removed: `asset_id`, `quote_asset_id` fields
  - Added: `symbol_id` field

#### Domain Restructuring
- **Assets domain** (`assets/v1/`) - Now strictly individual tokens/coins
- **Markets domain** (`markets/v1/`) - Now includes Symbol definitions + market data
- **Venues domain** (`venues/v1/`) - Now includes Venue, VenueAsset, VenueSymbol

### Migration Guide

#### For Consuming Services (BREAKING CHANGES)

**1. Update imports:**
```go
// Old
import "github.com/Combine-Capital/cqc/gen/go/cqc/assets/v1" // for Venue

// New
import "github.com/Combine-Capital/cqc/gen/go/cqc/venues/v1"   // for Venue
import "github.com/Combine-Capital/cqc/gen/go/cqc/markets/v1"  // for Symbol
```

**2. Update MarketData service calls:**
```go
// Old
resp, err := client.GetPrice(ctx, &servicespb.GetPriceRequest{
    AssetId:      "btc",
    QuoteAssetId: "usdt",
    VenueId:      "binance",
})

// New - First create or fetch the symbol
symbolResp, err := registryClient.GetSymbol(ctx, &servicespb.GetSymbolRequest{
    SymbolId: "btc-usdt-spot",
})

resp, err := client.GetPrice(ctx, &servicespb.GetPriceRequest{
    SymbolId: "btc-usdt-spot",
    VenueId:  "binance",
})
```

**3. Use proper domain types:**
```go
// Price with symbol
price := &marketpb.Price{
    SymbolId: "btc-usdt-spot",
    Value:    67890.50,
}
```

### Architecture

Proper domain separation established:
- **Asset** = Individual token (BTC, ETH, USDT) - managed once
- **Symbol** = Trading pair/market (BTC/USDT spot, ETH-PERP) - represents tradeable instrument
- **Venue** = Platform (Binance, Uniswap V3) - where trading occurs
- **VenueAsset** = Asset availability (which tokens on which venue)
- **VenueSymbol** = Market availability (which trading pairs on which venue)

Benefits:
- Proper handling of multi-chain assets (USDT on Ethereum vs USDT on Tron)
- Support for derivatives (perpetuals, futures, options)
- Clear venue-specific symbol mappings ("BTCUSDT" vs "BTC-USD")
- Extensible market types without conflating assets and symbols

### All Domains Implemented
- **Assets**: Asset, AssetDeployment, AssetRelationship, AssetQualityFlag, Chain
- **Markets**: Symbol, SymbolIdentifier, Price, OrderBook, Trade, Candle, VWAP, MarketDepth, LiquidityMetrics
- **Portfolio**: Position, Portfolio, Allocation, Transaction, PnL
- **Venues**: Venue, VenueAsset, VenueSymbol, VenueAccount, Order, Balance, ExecutionReport
- **Events**: Asset, Symbol, Venue, Order, Position, Risk events
- **Services**: AssetRegistry, MarketData, Portfolio, VenueGateway, RiskEngine

### Build System
- Makefile with code generation for Go, Python, TypeScript
- Automated proto validation
- Generated code committed to repository

---

## Version Policy

### Semantic Versioning

This project follows [Semantic Versioning 2.0.0](https://semver.org/):

- **MAJOR** version (X.0.0) - Incompatible API changes (breaking changes to proto definitions)
- **MINOR** version (0.X.0) - Add functionality in a backward compatible manner (new fields, new messages, new services)
- **PATCH** version (0.0.X) - Backward compatible bug fixes (documentation, code generation fixes)

### Go Module Import Path

Consumers should always import using:
```go
import "github.com/Combine-Capital/cqc/gen/go/cqc@v0.1.0"
```

Or in `go.mod`:
```
require github.com/Combine-Capital/cqc/gen/go v0.1.0
```

### Pre-1.0 Development

During pre-1.0 development (0.x.x versions):
- **MINOR** version changes (0.X.0) may include breaking changes
- API is considered unstable and subject to change
- We will document breaking changes in this CHANGELOG
- After 1.0.0, we will follow strict semantic versioning with backward compatibility

### Protobuf Best Practices

- Field numbers will never be reused (even after deprecation)
- New optional fields can be added in MINOR versions
- Removing fields or changing types requires MAJOR version bump (after 1.0)
- Deprecated fields will be marked with `[deprecated = true]`

[0.3.1]: https://github.com/Combine-Capital/cqc/releases/tag/v0.3.1
[0.3.0]: https://github.com/Combine-Capital/cqc/releases/tag/v0.3.0
[0.2.0]: https://github.com/Combine-Capital/cqc/releases/tag/v0.2.0
[0.1.0]: https://github.com/Combine-Capital/cqc/releases/tag/v0.1.0
