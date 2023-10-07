# ICrystal

ICrystal is a crystal kernel for [Jupyter project](https://jupyter.org/try).

Current status: early development stages (the kernel is very minimal). Expect more features in the future.

It is ported from the [IRuby](https://github.com/SciRuby/iruby) kernel.

![icrystal](https://user-images.githubusercontent.com/470056/81830095-f25cd280-953b-11ea-9922-0f6477399cef.gif)

## Installation

Prerequisites

- The latest version of [crystal](https://crystal-lang.org/).
- Be able to [compile crystal from sources](https://crystal-lang.org/install/from_sources/).
- [Jupyter](https://jupyter.org/)
- [ZeroMQ](https://zeromq.org/)

Clone the repository and switch current directory:

```
git clone https://github.com/RomainFranceschini/icrystal.git
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

## How it works

The code submitted to the kernel is run by the built-in crystal interpreter.

## Additional prelude

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

See [./samples/30-advanced-widgets.ipynb](samples/30-advanced-widgets.ipynb) for an example.

## Development

To build icrystal, install the dependencies first:

```
shards install
```

To build icrystal using the install crystal compiler run:

```
make all
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
- [ ] Support adding/removing shards dependencies
- [ ] Write specs
- [ ] Improve syntax and compiler error reporting

## Contributing

1. Fork it (<https://github.com/RomainFranceschini/icrystal/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Romain Franceschini](https://github.com/RomainFranceschini) - creator and maintainer

## License

Copyright (c) ICrystal contributors.

Licensed under the [MIT](LICENSE) license.
