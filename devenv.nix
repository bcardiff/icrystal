{ pkgs, ... }:

{
  env.JUPYTER_DATA_DIR = "./jupyter_data";

  packages = [ ];

  enterShell = ''
  '';

  languages.python.enable = true;
  languages.python.venv.enable = true;
  languages.python.venv.requirements = ''
    jupyter
    jupyter_kernel_test
  '';
}
