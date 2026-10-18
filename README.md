This is the source code for my website at [2k2pea.ch](https://2k2pea.ch/).

We use `nix` to handle dependencies, along with some shell scripting to build it all as a static website.

To run the website locally for testing purposes, simply run:
```sh
nix build && nix run
```

Pushing to the repository triggers a workflow, which automatically deploys the website.
