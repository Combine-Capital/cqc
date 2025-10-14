# Release Process

This document describes how to create and publish new versions of CQC.

## Prerequisites

- Clean git working directory
- All changes committed
- All tests passing (`make generate && cd gen/go && go build ./...`)
- CHANGELOG.md updated with changes
- README.md updated if necessary

## Version Numbers

Follow [Semantic Versioning 2.0.0](https://semver.org/):

### Pre-1.0 (Current: 0.x.x)
- `0.X.0` - May include breaking changes, new features
- `0.0.X` - Bug fixes only

### Post-1.0 (Future: 1.x.x+)
- `X.0.0` - Breaking changes to proto definitions
- `0.X.0` - New fields, messages, services (backward compatible)
- `0.0.X` - Bug fixes, documentation, generation improvements

## Release Steps

### 1. Update CHANGELOG.md

Add new section at the top:

```markdown
## [0.2.0] - 2025-XX-XX

### Added
- New feature description

### Changed
- Breaking change description

### Fixed
- Bug fix description

[0.2.0]: https://github.com/Combine-Capital/cqc/releases/tag/v0.2.0
```

### 2. Update Version References

Update version numbers in:
- `README.md` - Installation examples
- `CHANGELOG.md` - Version links
- Any other documentation

### 3. Commit Version Changes

```bash
git add CHANGELOG.md README.md
git commit -m "chore: prepare release v0.2.0"
git push origin main
```

### 4. Create Git Tag

```bash
# Create annotated tag
git tag -a v0.2.0 -m "Release v0.2.0

- Feature 1
- Feature 2
- Breaking change 3
"

# Push tag to remote
git push origin v0.2.0
```

### 5. Verify Tag

```bash
# List all tags
git tag -l

# View tag details
git show v0.2.0
```

### 6. Create GitHub Release

Go to: https://github.com/Combine-Capital/cqc/releases/new

- Choose tag: `v0.2.0`
- Release title: `v0.2.0`
- Description: Copy from CHANGELOG.md
- Mark as pre-release if version < 1.0.0
- Publish release

## Using Released Versions

### Go Consumers

After publishing a tag, Go modules can import specific versions:

```bash
# Get latest
go get github.com/Combine-Capital/cqc/gen/go@latest

# Get specific version
go get github.com/Combine-Capital/cqc/gen/go@v0.2.0

# Get latest patch in minor version
go get github.com/Combine-Capital/cqc/gen/go@v0.2
```

In `go.mod`:
```go
require github.com/Combine-Capital/cqc/gen/go v0.2.0
```

### Verify Version Availability

```bash
# List available versions
go list -m -versions github.com/Combine-Capital/cqc/gen/go

# View specific version info
go list -m github.com/Combine-Capital/cqc/gen/go@v0.2.0
```

## Breaking Changes

### When to Increment Major Version (Future 1.x.x → 2.0.0)

- Removing fields from proto messages
- Changing field types
- Changing field numbers
- Removing messages or services
- Renaming messages or services
- Changing service method signatures

### How to Handle Breaking Changes (Pre-1.0)

During 0.x.x development:

1. Document in CHANGELOG.md under "### Changed - Breaking"
2. Provide migration guide with before/after examples
3. Increment minor version (0.1.0 → 0.2.0)
4. Notify consuming services before release

### Deprecation Process (Post-1.0)

Instead of removing immediately:

1. Mark field as deprecated in proto:
   ```protobuf
   optional string old_field = 1 [deprecated = true];
   ```

2. Add comment explaining alternative:
   ```protobuf
   // Deprecated: Use new_field instead
   optional string old_field = 1 [deprecated = true];
   optional string new_field = 2;
   ```

3. Maintain deprecated field for at least one major version
4. Document deprecation in CHANGELOG.md
5. Remove in next major version

## Hotfix Process

For critical bugs that need immediate release:

```bash
# Create hotfix branch from tag
git checkout -b hotfix/v0.1.1 v0.1.0

# Make fixes
git commit -m "fix: critical bug description"

# Update CHANGELOG.md
git commit -m "chore: prepare hotfix v0.1.1"

# Merge to main
git checkout main
git merge hotfix/v0.1.1

# Tag and release
git tag -a v0.1.1 -m "Hotfix v0.1.1"
git push origin main v0.1.1
```

## Version Numbering Examples

### Current State (v0.1.0)
Initial release with all domains implemented.

### Example Future Releases

**v0.2.0** - Add new optional fields to existing messages
- Add `metadata` field to Symbol message
- Add new event types
- Backward compatible

**v0.3.0** - Add new service
- Add new Analytics service
- May include breaking changes (pre-1.0)

**v1.0.0** - Stable API
- First production-ready release
- Backward compatibility guaranteed from this point
- No breaking changes without major version bump

**v1.1.0** - Add features (backward compatible)
- New optional fields
- New messages
- New services

**v1.1.1** - Bug fixes
- Documentation fixes
- Code generation improvements
- No proto changes

**v2.0.0** - Breaking changes
- Remove deprecated fields
- Change field types
- Restructure services

## Troubleshooting

### Tag Already Exists

```bash
# Delete local tag
git tag -d v0.2.0

# Delete remote tag
git push origin :refs/tags/v0.2.0

# Recreate tag
git tag -a v0.2.0 -m "Release v0.2.0"
git push origin v0.2.0
```

### Go Module Cache Issues

Consumers may need to clear cache:

```bash
# Clear module cache
go clean -modcache

# Re-download
go get github.com/Combine-Capital/cqc/gen/go@v0.2.0
```

### Version Not Showing Up

Wait a few minutes for Go proxy to refresh, then:

```bash
# Force proxy refresh
GOPROXY=direct go get github.com/Combine-Capital/cqc/gen/go@v0.2.0
```

## Checklist

Before creating a release, verify:

- [ ] All proto files compile without errors
- [ ] Generated Go code builds: `cd gen/go && go build ./...`
- [ ] CHANGELOG.md updated with all changes
- [ ] Version numbers updated in README.md
- [ ] Migration guide included for breaking changes (if any)
- [ ] All changes committed and pushed
- [ ] Git tag created with correct version
- [ ] GitHub release created
- [ ] Consuming services notified of new version
