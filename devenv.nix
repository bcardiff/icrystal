{ pkgs, ... }:

{
  packages = [ ];

  enterShell = ''
  '';

  languages.python.enable = true;
  languages.python.venv.enable = true;
  languages.python.venv.requirements = ''
    jupyter
  '';
}
