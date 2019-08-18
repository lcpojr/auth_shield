# Changelog

All notable changes in this project are documented here.

We based this file in [*Keep a Changelog*](https://keepachangelog.com/en/1.0.0/) and [*Semantic Versioning*](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Resume

This is the first major version of AuthX framework.
It contains all necessary features to begin usage as:

- Resource management;
- Credentials management;
- Password and PIN basic authentication (TOTP is also available but it is an work in progress);
- Role and Permission basic authorization;

### Added

- feat: add authentication tests (#28)
- feat: add authorization tests (#27)
- feat: add credentials tests (#26)
- feat: add resources tests (#25)
- feat: add coveralls (#24)
- feat: add travis (#23)
- feat: add password as an credential (#18)
- feat: add database model documentations (#19)
- feat: add authorization by roles and permissions (#17)
- feat: add list functions to all modules (#16)
- feat: add relations in users, roles and permissions (#14)
- feat: add permissions creation (#11)
- feat: add role creation (#10)
- feat: add roles and permitions relations (#9)
- feat: add otp credential and do some refactors (#6)
- feat: add otp credential (#4)
- feat: add pin credential (#3)
- feat: add ecto and user schemas

### Fixed

- fix: remove unstable totp check tests (#29)
- fix: roles criation and credentials bugs (#12)
- fix: repo supervisor tree

### Changed

- chore: rename folder and add user functions (#2)
- chore: remove exposed postgres configs
- chore: change postgres version
- chore(deps-dev): bump ex_doc from 0.20.2 to 0.21.1 (#22)
- chore(deps-dev): bump credo from 1.1.0 to 1.1.2 (#21)
- chore(deps): bump postgrex from 0.14.3 to 0.15.0 (#20)
- chore: update all module docs (#15)