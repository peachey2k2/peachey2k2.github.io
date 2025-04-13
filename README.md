This is the surce code for [peachey2k2.github.io](https://peachey2k2.github.io/).

We use `nix` to handle dependencies, along with some shell scripting to build it all as a static website.

To run the website locally for testing purposes, simply run:
```sh
nix build && nix run
```

Pushing to the repository triggers a workflow, which automatically deploys the website.
