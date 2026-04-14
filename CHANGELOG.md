# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- GitHub Actions CI/CD pipeline
- Docker support with Dockerfile and docker-compose
- Pre-commit hooks for code quality
- EditorConfig for consistent coding styles
- HLint configuration for Haskell code quality
- Issue and PR templates
- Security policy documentation
- Code of Conduct
- Support guidelines
- Installation and test scripts

## [1.0.0] - 2024-04-14

### Added
- Initial release of WiFi Diagnostic Tool
- Support for Linux platform (nmcli, rfkill)
- Support for Windows platform (netsh)
- Interactive mode with full diagnostics
- Command-line interface with multiple options
- Automatic repair for common WiFi issues:
  - Adapter disabled
  - DNS resolution failures
  - IP conflicts
  - Network stack reset
- Network scanning functionality
- Network status display
- Forget network feature
- Comprehensive README in Arabic
- MIT License
- Unit tests with Hspec
- Professional project structure with Stack

### Supported Issues
- NoWiFiAdapterFound
- AdapterDisabled
- NotConnected
- ConnectedNoInternet
- DnsResolutionFailure
- WeakSignalStrength
- WrongPassword
- IpConflict
- DriverIssue
- CaptivePortalDetected

[Unreleased]: https://github.com/peaceara777-star/haskell-wifi/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/peaceara777-star/haskell-wifi/releases/tag/v1.0.0
