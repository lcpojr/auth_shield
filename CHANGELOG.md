# Changelog

All notable changes in this project are documented here.

We based this file in [*Keep a Changelog*](https://keepachangelog.com/en/1.0.0/) and [*Semantic Versioning*](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## Added

- Loggin attempts now are saved when user is authenticated by login function;
- Login function now has brute force protection;

## Changed

- Improve on documentations and validation schemas;
- Change domain authentication functions to accept credential structs;

## [0.0.3] - 09-11-2019

Alpha release for test purposes.

## Changed

- README.md was updated to add a better installation guide;

## Fixed

- Migrations now are done by using the module and can be easily extendable;

## [0.0.2] - 06-11-2019

Alpha release for test purposes.

### Changed

- Update docs and add mocks to tests;

## [0.0.1] - 01-11-2019

Alpha release for test purposes.

### Added

- User, Roles and Permissions resources;
- Password, PIN and TOTP credentials (in development);
- Session authentication flow;

[0.0.1]: https://github.com/dlpco/banking-panda/compare/v0.0.1...v0.0.2
[0.0.2]: https://github.com/dlpco/banking-panda/compare/v0.0.2...HEAD