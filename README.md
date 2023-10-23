# ICrystal

ICrystal is a crystal kernel for [Jupyter project](https://jupyter.org/try).

This repo started as a fork of [RomainFranceschini/icrystal](https://github.com/RomainFranceschini/icrystal) to explore how crystal interpreter can be leveraged. [RomainFranceschini/icrystal](https://github.com/RomainFranceschini/icrystal) was ported from the [IRuby](https://github.com/SciRuby/iruby) kernel.

This project motivated the creation of [bcardiff/crystal-repl-server](https://github.com/bcardiff/crystal-repl-server) as a way to interact with the crystal interpreter.

Current status:

* Early development stages (the kernel is very minimal)
* Executes code using the experimental crystal interpreter
* Supports rich output (images, html, svg, ...)
* Supports shards dependencies

https://github.com/bcardiff/icrystal/assets/459923/7cf13ddc-f7fe-4837-9110-5fd753ab25c9

## Installation

Prerequisites

- The latest version of [crystal](https://crystal-lang.org/).
- Be able to [compile crystal from sources](https://crystal-lang.org/install/from_sources/).
- [Jupyter](https://jupyter.org/)
- [ZeroMQ](https://zeromq.org/)

Clone the repository and switch current directory:

```
git clone https://github.com/bcardiff/icrystal.git
cd icrystal
```

Build icrystal, see [Development](#development) section for more details.

Register the kernel, see [Usage](#usage) section for more details.

Start jupyter.


## Usage

To register the kernel (ensure jupyter is installed):

```
./bin/icrystal register
```

Now run jupyter and choose the ICrystal kernel as a backend for your notebook:

```
jupyter notebook
```

or

```
jupyter lab
```

### How it works

The code submitted to the kernel is run by the built-in crystal interpreter.

### Additional prelude

There are some extended prelude available when evaluating Crystal code from the notebook.
See [./src/std](.src/std). The main functionality is to return rich output like

```crystal
ICrystal.html "<h1>hello</h1>"
```

or to skip the default output

```crystal
ICrystal.none
```

and allow you to send `display_data`, `update_display_data` messages directly.

```crystal
ICrystal.session.publish("display_data", {
  "data"            => {"text/html" => "<h1>hello</h1>"},
  "metadata"        => {} of String => ICrystal::Any,
  "transient"       => {"display_id" => "some_id"},
})
ICrystal.none
```

See [./samples/30-update-display.ipynb](samples/30-update-display.ipynb) for an example.

### Shards

When running code by a jupyter server you will have access to

* Crystal's std-lib
* Some additionals explained in [addional prelude](#additional-prelude)
* Shards installed in a container folder where the server is launched
* Shards declared in the notebook itself

A notebook can declare which shards to install via `ICrystal.shards` method. *IMPORTANT:* The call to this method must be in its own cell.

Either embed the shards.yml content in the notebook:

```crystal
ICrystal.shards <<-YML
  name: notebook
  version: 0.0.1
  license: MIT

  dependencies:
    lorem:
      github: bcardiff/crystal-lorem
  YML
```

Or use a DSL

```crystal
ICrystal.shards do
  dep "lorem", github: "bcardiff/crystal-lorem"
end
```

If you need to customize things further use the CRYSTAL_PATH environment variable as with the crystal compiler.

## Development

To build icrystal, install the dependencies first:

```
shards install
```

To build icrystal using the install crystal compiler run:

```
make all
```

It is recommended to build the crystal-repl-server in release mode first.

```
make bin/crystal-repl-server FLAGS=--release
```

NOTE: you will need to have the same llvm version installed as the one informed in `crystal --version`.

To build icrystal using crystal sources run:

```
make all CRYSTAL=~/path/to/crystal-clone/bin/crystal
```

NOTE: you will need to run `make clean deps` in your crystal-clone first.

In either case, the icrystal binary will be left in the `./bin/icrystal`.

To specify a specific llvm-config, use the `LLVM_CONFIG` environment variable.

### Specs

To run the crystal specs do

```
make spec
```

or

```
make spec CRYSTAL=~/path/to/crystal-clone/bin/crystal
```

To run the jupyter kernel testing tool (Python 3.4 or greater required):

```
pip3 install jupyter_kernel_test
python3 test/test_kernel.py
```

### Nix / devenv

If you have [devenv.sh](https://devenv.sh/) installed you can use it to get a python environment with jupyter installed and some safe configuration for kernel development. In particular the kernel registration will be done in a local directory instead of the system-wide one.

The crystal compiler and it's dependency is currently out of the scope of devenv.sh, so you will have to install them manually.

## Roadmap

- [ ] Widget support
- [x] Rich output (images, ...) support
- [ ] Add special commands
- [x] Support adding/removing shards dependencies
- [ ] Write specs
- [ ] Improve syntax and compiler error reporting

## Contributing

1. Fork it (<https://github.com/bcardiff/icrystal/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Romain Franceschini](https://github.com/RomainFranceschini) - creator and maintainer
- [Brian J. Cardiff](https://github.com/bcardiff) - maintainer

## License

Copyright (c) ICrystal contributors.

Licensed under the [MIT](LICENSE) license.
