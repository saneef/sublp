# sublp

It's a smarter `subl` CLI tool for Sublime Text.

The `sublp` opens the matching project file (`.sublime-project`) for a provided path, or the current directory.
If the project file doesn't exist, it opens the path in Sublime Text as would `subl` normally do.

The `sublp` internally uses `subl`.

## Installation & Usage

[Terser](https://terser.org) must be installed for this tool to work. The Sublime Text's JSON files with comments are sanitised using Terser before parsing.

Set environment variable `SUBLP_PATH` with paths to search for `.sublime-project` files.

## Development

### Testing

```sh
raco test . # Runs the unit tests
```

### Building

```sh
raco exe sublp.rkt # Builds the executable `sublp` in the current directory
```
