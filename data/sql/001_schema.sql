-- ============================================================================
-- CRYPTO ASSET METADATA REGISTRY - DuckDB Schema
-- File: data/sql/001_schema.sql
-- Version: 1.0.0
-- Description: Immutable, versioned metadata registry for crypto assets
-- ============================================================================

-- ============================================================================
-- 1. REFERENCE TABLES (Enums)
-- ============================================================================

CREATE TABLE asset_types (
    code VARCHAR PRIMARY KEY,
    display_name VARCHAR NOT NULL,
    description VARCHAR
);

INSERT INTO asset_types VALUES
    ('NATIVE', 'Native Token', 'Native blockchain token (ETH, SOL, BTC)'),
    ('ERC20', 'ERC-20 Token', 'Fungible token standard on EVM chains'),
    ('SPL', 'SPL Token', 'Solana Program Library token'),
    ('ERC721', 'ERC-721 NFT', 'Non-fungible token'),
    ('ERC1155', 'ERC-1155 Multi-Token', 'Multi-token standard'),
    ('SYNTHETIC', 'Synthetic Asset', 'Synthetic/derivative representation'),
    ('LP_TOKEN', 'LP Token', 'Liquidity provider token'),
    ('RECEIPT_TOKEN', 'Receipt Token', 'Receipt for deposited assets (aTokens, cTokens)'),
    ('WRAPPED', 'Wrapped Asset', 'Wrapped version of native asset');

CREATE TABLE relationship_types (
    code VARCHAR PRIMARY KEY,
    display_name VARCHAR NOT NULL,
    description VARCHAR
);

INSERT INTO relationship_types VALUES
    ('WRAPS', 'Wraps', 'Wraps an underlying asset (WETH wraps ETH)'),
    ('BRIDGES', 'Bridges', 'Bridged to another chain'),
    ('STAKES', 'Stakes', 'Liquid staking derivative (stETH stakes ETH)'),
    ('SYNTHETIC_OF', 'Synthetic Of', 'Synthetic representation of an asset'),
    ('LIQUIDITY_PAIR', 'Liquidity Pair', 'LP token containing multiple assets'),
    ('MIGRATES_TO', 'Migrates To', 'Token migration path (old -> new)'),
    ('FORKS_FROM', 'Forks From', 'Blockchain fork (ETH -> ETC)'),
    ('REBASES_WITH', 'Rebases With', 'Rebasing token variant');

CREATE TABLE data_sources (
    code VARCHAR PRIMARY KEY,
    display_name VARCHAR NOT NULL,
    base_url VARCHAR,
    documentation_url VARCHAR,
    requires_api_key BOOLEAN NOT NULL DEFAULT false
);

INSERT INTO data_sources VALUES
    ('COINGECKO', 'CoinGecko', 'https://api.coingecko.com/api/v3', 'https://docs.coingecko.com', false),
    ('COINMARKETCAP', 'CoinMarketCap', 'https://pro-api.coinmarketcap.com/v1', 'https://coinmarketcap.com/api', true),
    ('DEFILLAMA', 'DefiLlama', 'https://api.llama.fi', 'https://defillama.com/docs/api', false),
    ('MESSARI', 'Messari', 'https://data.messari.io/api/v1', 'https://messari.io/api/docs', true),
    ('INTERNAL', 'Internal', NULL, NULL, false);

CREATE TABLE venue_types (
    code VARCHAR PRIMARY KEY,
    display_name VARCHAR NOT NULL,
    description VARCHAR
);

INSERT INTO venue_types VALUES
    ('CEX', 'Centralized Exchange', 'Centralized cryptocurrency exchange'),
    ('DEX', 'Decentralized Exchange', 'Decentralized exchange/AMM'),
    ('DEX_AGGREGATOR', 'DEX Aggregator', 'DEX aggregator (1inch, Paraswap)'),
    ('BRIDGE', 'Bridge', 'Cross-chain bridge'),
    ('LENDING', 'Lending Protocol', 'DeFi lending protocol');

CREATE TABLE flag_types (
    code VARCHAR PRIMARY KEY,
    display_name VARCHAR NOT NULL,
    description VARCHAR,
    default_severity VARCHAR
);

INSERT INTO flag_types VALUES
    ('SCAM', 'Scam Token', 'Known scam or fraudulent token', 'CRITICAL'),
    ('RUGPULL', 'Rug Pull', 'Project executed a rug pull', 'CRITICAL'),
    ('EXPLOITED', 'Exploited', 'Contract has been exploited', 'CRITICAL'),
    ('DEPRECATED', 'Deprecated', 'Token deprecated by issuer', 'HIGH'),
    ('PAUSED', 'Paused', 'Contract functionality paused', 'MEDIUM'),
    ('UNVERIFIED', 'Unverified', 'Contract not verified', 'LOW'),
    ('LOW_LIQUIDITY', 'Low Liquidity', 'Insufficient liquidity', 'MEDIUM'),
    ('HONEYPOT', 'Honeypot', 'Cannot sell after buying', 'CRITICAL'),
    ('TAX_TOKEN', 'Tax Token', 'Buy/sell tax mechanism', 'LOW');

-- ============================================================================
-- 2. CORE ASSET TABLES
-- ============================================================================

-- Canonical assets (cross-chain representation)
-- NOTE: Use gen_random_uuid() or uuid() to generate asset_id values for new assets
--       This allows for creating assets when only external identifiers are known
CREATE TABLE assets (
    asset_id UUID PRIMARY KEY,             -- Unique UUID identifier for each asset
    symbol VARCHAR NOT NULL,                -- BTC, ETH, USDC
    name VARCHAR NOT NULL,                  -- Bitcoin, Ethereum, USD Coin
    asset_type VARCHAR NOT NULL REFERENCES asset_types(code),
    category VARCHAR,                       -- stablecoin, governance, blue_chip, meme
    description VARCHAR,
    logo_url VARCHAR,
    website_url VARCHAR,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metadata JSON
);

-- External identifiers from data providers
CREATE TABLE asset_identifiers (
    asset_id UUID NOT NULL REFERENCES assets(asset_id),
    source VARCHAR NOT NULL REFERENCES data_sources(code),
    external_id VARCHAR NOT NULL,           -- CoinGecko ID, CMC ID, etc.
    is_primary BOOLEAN NOT NULL DEFAULT false,
    metadata JSON,
    PRIMARY KEY (asset_id, source, external_id)
);

-- Chain deployments (where assets exist on-chain)
CREATE TABLE asset_deployments (
    deployment_id VARCHAR PRIMARY KEY,      -- Format: {chain}:{address} e.g. "ethereum:0xA0b..."
    asset_id UUID NOT NULL REFERENCES assets(asset_id),
    chain_id VARCHAR NOT NULL,              -- ethereum, polygon, arbitrum, solana, bitcoin
    chain_name VARCHAR NOT NULL,            -- Ethereum, Polygon, Arbitrum, Solana, Bitcoin
    address VARCHAR,                        -- Contract address or "native" for native tokens
    decimals INTEGER NOT NULL CHECK (decimals >= 0 AND decimals <= 18),
    is_canonical BOOLEAN NOT NULL DEFAULT false,
    deployment_block BIGINT,
    deployment_tx VARCHAR,
    deployer_address VARCHAR,
    is_verified BOOLEAN NOT NULL DEFAULT false,
    deployed_at TIMESTAMP,
    metadata JSON
);

-- Asset groups (for multi-chain natives like USDC)
CREATE TABLE asset_groups (
    group_id VARCHAR PRIMARY KEY,           -- usdc-circle, eth-native, btc-native
    canonical_symbol VARCHAR NOT NULL,      -- USDC, ETH, BTC
    issuer VARCHAR,                         -- circle, ethereum-foundation, etc.
    description VARCHAR,
    metadata JSON
);

CREATE TABLE asset_group_members (
    group_id VARCHAR NOT NULL REFERENCES asset_groups(group_id),
    asset_id UUID NOT NULL REFERENCES assets(asset_id),
    is_canonical BOOLEAN NOT NULL DEFAULT false,
    PRIMARY KEY (group_id, asset_id)
);

-- Asset relationships (wrapped, bridged, staked variants)
CREATE TABLE asset_relationships (
    parent_asset_id UUID NOT NULL REFERENCES assets(asset_id),
    child_asset_id UUID NOT NULL REFERENCES assets(asset_id),
    relationship_type VARCHAR NOT NULL REFERENCES relationship_types(code),
    conversion_rate DECIMAL(38, 18),        -- NULL for non-1:1 conversions (max precision for DuckDB)
    protocol VARCHAR,                       -- Lido, Aave, Uniswap, etc.
    metadata JSON,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (parent_asset_id, child_asset_id, relationship_type),
    CHECK (parent_asset_id != child_asset_id)
);

-- Asset quality flags
CREATE TABLE asset_quality_flags (
    asset_id UUID NOT NULL REFERENCES assets(asset_id),
    flag_type VARCHAR NOT NULL REFERENCES flag_types(code),
    severity VARCHAR NOT NULL,              -- CRITICAL, HIGH, MEDIUM, LOW, INFO
    source VARCHAR NOT NULL,                -- certik, tokensniffer, manual, etc.
    flagged_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    cleared_at TIMESTAMP,
    notes VARCHAR,
    evidence_url VARCHAR,
    metadata JSON,
    CHECK (cleared_at IS NULL OR cleared_at >= flagged_at)
);

-- ============================================================================
-- 3. VENUE & SYMBOL MAPPING
-- ============================================================================

CREATE TABLE venues (
    venue_id VARCHAR PRIMARY KEY,           -- binance, coinbase, uniswap-v3-eth, curve-eth
    name VARCHAR NOT NULL,                  -- Binance, Coinbase, Uniswap V3, Curve
    venue_type VARCHAR NOT NULL REFERENCES venue_types(code),
    chain_id VARCHAR,                       -- NULL for CEXs, chain for DEXs
    protocol_address VARCHAR,               -- Contract address for DEXs
    website_url VARCHAR,
    api_endpoint VARCHAR,
    is_active BOOLEAN NOT NULL DEFAULT true,
    metadata JSON
);

-- Venue-specific symbol mappings (resolves symbol collisions)
CREATE TABLE venue_symbols (
    venue_id VARCHAR NOT NULL REFERENCES venues(venue_id),
    venue_symbol VARCHAR NOT NULL,          -- Exchange-specific symbol (BTCUSDT, BTC-USD, WBTC)
    asset_id UUID NOT NULL REFERENCES assets(asset_id),
    deployment_id VARCHAR REFERENCES asset_deployments(deployment_id),
    quote_asset_id UUID REFERENCES assets(asset_id), -- For trading pairs
    listed_at TIMESTAMP,
    delisted_at TIMESTAMP,
    metadata JSON,
    PRIMARY KEY (venue_id, venue_symbol)
);

-- ============================================================================
-- 4. CHAIN METADATA
-- ============================================================================

CREATE TABLE chains (
    chain_id VARCHAR PRIMARY KEY,           -- ethereum, polygon, arbitrum, solana
    chain_name VARCHAR NOT NULL,            -- Ethereum, Polygon, Arbitrum, Solana
    native_asset_id UUID REFERENCES assets(asset_id),
    chain_type VARCHAR NOT NULL,            -- evm, solana, bitcoin, cosmos
    network_id INTEGER,                     -- 1, 137, 42161, etc.
    explorer_url VARCHAR,
    rpc_url VARCHAR,
    is_testnet BOOLEAN NOT NULL DEFAULT false,
    metadata JSON
);

-- ============================================================================
-- 5. INDEXES FOR PERFORMANCE (<100ns lookups)
-- ============================================================================

-- Assets
CREATE INDEX idx_assets_symbol ON assets(symbol);
CREATE INDEX idx_assets_type ON assets(asset_type);
CREATE INDEX idx_assets_category ON assets(category);

-- Identifiers
CREATE INDEX idx_identifiers_source_id ON asset_identifiers(source, external_id);

-- Deployments
CREATE INDEX idx_deployments_asset ON asset_deployments(asset_id);
CREATE INDEX idx_deployments_chain ON asset_deployments(chain_id);
CREATE INDEX idx_deployments_address ON asset_deployments(chain_id, address);
CREATE INDEX idx_deployments_canonical ON asset_deployments(asset_id, is_canonical);

-- Relationships
CREATE INDEX idx_relationships_parent ON asset_relationships(parent_asset_id);
CREATE INDEX idx_relationships_child ON asset_relationships(child_asset_id);
CREATE INDEX idx_relationships_type ON asset_relationships(relationship_type);

-- Quality flags
CREATE INDEX idx_quality_active ON asset_quality_flags(asset_id, severity);

-- Venue symbols (critical for <100ns venue-specific lookups)
CREATE INDEX idx_venue_symbols_asset ON venue_symbols(asset_id);
CREATE INDEX idx_venue_symbols_lookup ON venue_symbols(venue_id, venue_symbol);

-- ============================================================================
-- 6. VIEWS FOR COMMON QUERIES
-- ============================================================================

-- All variants of an asset
CREATE VIEW asset_variants AS
SELECT 
    a.asset_id as parent_asset_id,
    a.symbol as parent_symbol,
    ar.relationship_type,
    child.asset_id as variant_asset_id,
    child.symbol as variant_symbol,
    ar.conversion_rate,
    ar.protocol
FROM assets a
JOIN asset_relationships ar ON a.asset_id = ar.parent_asset_id
JOIN assets child ON ar.child_asset_id = child.asset_id;

-- Asset deployments with chain info
CREATE VIEW asset_deployments_full AS
SELECT 
    ad.deployment_id,
    ad.asset_id,
    a.symbol,
    a.name,
    ad.chain_id,
    ad.chain_name,
    ad.address,
    ad.decimals,
    ad.is_canonical,
    ad.is_verified
FROM asset_deployments ad
JOIN assets a ON ad.asset_id = a.asset_id;

-- Venue listings with asset info
CREATE VIEW venue_listings AS
SELECT 
    vs.venue_id,
    v.name as venue_name,
    v.venue_type,
    vs.venue_symbol,
    vs.asset_id,
    a.symbol,
    a.name,
    vs.listed_at,
    vs.delisted_at,
    vs.delisted_at IS NULL as is_active
FROM venue_symbols vs
JOIN venues v ON vs.venue_id = v.venue_id
JOIN assets a ON vs.asset_id = a.asset_id;

-- Active quality flags
CREATE VIEW active_quality_flags AS
SELECT 
    aqf.asset_id,
    a.symbol,
    a.name,
    aqf.flag_type,
    ft.display_name as flag_name,
    aqf.severity,
    aqf.source,
    aqf.flagged_at,
    aqf.notes
FROM asset_quality_flags aqf
JOIN assets a ON aqf.asset_id = a.asset_id
JOIN flag_types ft ON aqf.flag_type = ft.code
WHERE aqf.cleared_at IS NULL;

-- ============================================================================
-- 7. SCHEMA VERSION TRACKING
-- ============================================================================

CREATE TABLE schema_version (
    version VARCHAR PRIMARY KEY,
    applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    description VARCHAR
);

INSERT INTO schema_version VALUES ('1.1.0', CURRENT_TIMESTAMP, 'Updated asset_id to UUID type for better uniqueness and external identifier support');
