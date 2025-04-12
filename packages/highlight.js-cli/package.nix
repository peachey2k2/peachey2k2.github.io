{
  lib,
  buildNpmPackage,
  # fetchFromGitHub,
  fetchgit,
}:

let
  owner = "tzemanovic";
  repo = "highlight.js-cli";
in
  buildNpmPackage rec {
    pname = "";
    version = "0.1.1";

    src = fetchgit {
      url = "https://github.com/${owner}/${repo}";
      hash = "sha256-55B+0ziYwJdtnwXALc9Ye8ZWDRFKl5LMn6inyFCwn5E=";
    };

    dontNpmBuild = true;

    npmDepsHash = "sha256-L8pOYxjNV0z9xO17YipwKEJdFPL6+T+S5iwzzxgu4e0=";

    # why is this not in the repo smh
    postPatch = ''
      cp ${./package-lock.json} ./package-lock.json
    '';

    postInstall = ''
      rm -rf $out/lib/node_modules/@${owner}/${repo}/node_modules/.bin
    '';

    meta = {
      description = "Use highlight.js from command line on HTML file.";
      homepage = "https://github.com/tzemanovic/highlight.js-cli";
      license = lib.licenses.mit;
      maintainers = [ ];
      mainProgram = "mljs";
    };
  }
