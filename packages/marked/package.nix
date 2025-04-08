{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "marked";
  version = "15.0.7";

  src = fetchFromGitHub {
    owner = "markedjs";
    repo = "marked";
    rev = "v${version}";
    hash = "sha256-U71KM+GuicCbGCLgO2SIWA7g7GtSMGgfEyJxJT74e3w=";
  };

  npmDepsHash = "sha256-RNDOM3cbj802T5yGrMh2gFoGOZMhk3Li9T7/9Kdvj7Y=";

  postInstall = ''
    rm -rf $out/lib/node_modules/@${src.owner}/${src.repo}/node_modules/.bin
  '';

  meta = {
    description = "A markdown parser and compiler. Built for speed.";
    homepage = "https://marked.js.org";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "marked";
  };
}
