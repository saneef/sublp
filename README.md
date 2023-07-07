# sublp

It's a smarter `subl` CLI tool for Sublime Text.

The `sublp` opens the matching project file for a provided path, or the current directory.
If the project file doesn't exist, it opens the path in Sublime Text as would `subl` normally do.

The `sublp` internally uses `subl`.

## Installation

[Terser](https://terser.org) must be installed for this tool to work. The Sublime Text's JSON files with comments are sanitised using Terser before parsing.

## Development

### Testing

```sh
raco test . # Runs the unit tests
```

### Building

```sh
raco exe sublp.rkt # Builds the executable `sublp` in the current directory
```
