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
- [MVP] Define protobuf messages for assets domain (Asset, Token, AssetMapping, AssetMetadata, Chain, AssetID)
- [MVP] Define protobuf messages for markets domain (Price, OrderBook, Trade, Candle, VWAP, MarketDepth, LiquidityMetrics)
- [MVP] Define protobuf messages for portfolio domain (Position, Portfolio, Allocation, Exposure, Transaction, PnL)
- [MVP] Define protobuf messages for venues domain (Venue, VenueAccount, Order, OrderStatus, Balance, ExecutionReport)
- [MVP] Define protobuf messages for events domain (AssetCreated, PriceUpdated, OrderPlaced, PositionChanged, RiskAlert)
- [MVP] Define gRPC service interfaces for AssetRegistry, MarketData, Portfolio, VenueGateway, RiskEngine
- [MVP] Provide Makefile with code generation targets for Go, Python, TypeScript from protobuf definitions
- [MVP] Organize protos by versioned domain structure (assets/v1/, markets/v1/, venues/v1/, portfolio/v1/, events/v1/)
- [Post MVP] Define OpenAPI 3.0 specifications for REST endpoints per service
- [Post MVP] Provide JSON Schema definitions for service configuration files
- [Post MVP] Include usage examples and integration tests for generated code in all target languages

## Success Metrics
1. 100% of CQ platform services (12 total) successfully import and use generated code without modification
2. Zero type mismatches or serialization errors between services in production over 30-day period
3. New service integration time reduced to <1 hour from contract import to successful inter-service communication