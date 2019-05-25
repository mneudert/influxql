# Changelog

## v0.2.1-dev

- Bug fixes
    - Compilation for OTP-22.0 has been fixed ([#3](https://github.com/mneudert/influxql/pull/3))

## v0.2.0 (2018-12-30)

- Enhancements
    - Most possibilities (as currently known) of InfluxQL injection via malicious identifier or value arguments should be prevented ([#1](https://github.com/mneudert/influxql/pull/1))
    - Trying to quote invalid identifier or value types (such as functions) now raises an `ArgumentError`

- Bug fixes
    - Values like atoms or booleans are now properly quoted

## v0.1.0 (2018-04-14)

- Initial Release
