# crit

[![GitHub release](https://img.shields.io/github/release/igbanam/crit.svg)](https://github.com/igbanam/crit/releases)

A [makeshift Git](https://thoughtbot.com/blog/rebuilding-git-in-ruby)

## Installation

- Clone the repository
- `shards build`

## Usage

This is a proof of concept and shouldn't be used in any production setting.
Building this toool was a learning process into CLI apps with Crystal.

To use this,

- `./bin/crit init` initializes the crit repository
- `./bin/crit add` stages a change
- `./bin/crit commit` records this change

## Development

This depends on having Vim installed. Since it's not meant to be too robust a
solution, Vim is hardcoded as the default editor.

## Contributing

1. Fork it (<https://github.com/igbanam/crit/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Owajigbanam Ogbuluijah](https://github.com/igbanam) - creator and maintainer
