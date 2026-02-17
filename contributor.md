# Contributing

## Prerequisites

This project uses [claat](https://github.com/googlecodelabs/tools/tree/main/claat) (Codelabs as a Thing) to generate the workshop from Markdown files.

The `claat` tool is already installed in the **devcontainer**. It is recommended to open the project in the devcontainer to get a ready-to-use environment.

## Development

### Edit content

The workshop content lives in `workshop.md`, using the claat format. Edit this file to add or update workshop steps.

### Build

To generate the HTML files from the Markdown sources:

```bash
# Export a single codelab
claat export workshop.md

# Or export all codelabs in the project
./build.sh
```

### Local server

To preview the workshop in your browser:

```bash
claat serve
```

Then open [localhost:9090](http://localhost:9090) in your browser.

## Project structure

```
├── workshop.md              # Workshop source (claat format)
├── git-workshop/            # Generated files (do not edit manually)
│   ├── ...
├── build.sh                 # Build script
├── .devcontainer/           # Devcontainer configuration
│   ├── ...
├── program.md               # Workshop program
└── README.md                # Workshop presentation
└── contributor.md           # Contribution guide
```
