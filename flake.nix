{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/24.11";
  };

  outputs = { self, nixpkgs }:
  let
    pkgs = import nixpkgs { system = "x86_64-linux"; };

    marked = pkgs.callPackage ./packages/marked/package.nix {};
  in {
    devShell.default = pkgs.mkShell {
      name = "static-website-dev";
      packages = [
        marked
        pkgs.python3Minimal
      ];
    };

    packages.default = pkgs.stdenv.mkDerivation {
      pname = "static-website";
      version = "0.1.0";
      src = ./.;

      installPhase = ''
        mkdir -p "$out"

        cp favicon.ico "$out/favicon.ico"
        cp "style.css" "$out/style.css"
        cp -r "88x31" "$out/88x31"

        iniAppend() {
          echo "$1" >> "$out/blog-list.ini"
        }

        toYearMonthDay() {
          x=""
          x+="$(echo $1 | head -c 10 | tail -c 4)"
          x+="$(echo $1 | head -c 5  | tail -c 2)"
          x+="$(echo $1 | head -c 2)"
          echo "$x"
        }

        buildMainPage() {
          cat "template/head.html"                                      >> "$out/index.html"
          echo '<div id="markdown-content">'                            >> "$out/index.html"
          cat "markdown/about.md" | ${marked}/bin/marked -c "marked.js" >> "$out/index.html"
          echo '</div>'                                                 >> "$out/index.html"
          cat "template/tail.html"                                      >> "$out/index.html"
        }
        
        buildBlogPost() {
          mkdir -p "$out/b/$1"
          cat "template/head.html"            >> "$out/b/$1/index.html"
          echo '<div id="markdown-content">'  >> "$out/b/$1/index.html"
          ${marked}/bin/marked -c "marked.js" >> "$out/b/$1/index.html"
          echo '</div>'                       >> "$out/b/$1/index.html"
          cat "template/tail.html"            >> "$out/b/$1/index.html"
        }

        buildBlogsList() {
          mkdir -p "$out/blog"
          cat "template/head.html"         >> "$out/blog/index.html"
          echo "<div class='blog-list'>"   >> "$out/blog/index.html"

          
          mkdir -p "$out/b"
          touch "$out/blog-list.ini"

          ls -1 "./blog" | while read file; do
            if (echo $file | grep "\.md\$" > "/dev/null"); then
              nameStripped="''\'''${file%.md}'"
              nameHash=$(echo $nameStripped | md5sum | head -c 8)

              cat "blog/$file" | while read line; do
                if [[ "$line" == "---" ]]; then
                
                  echo "
                    <div class="blog-card">
                      <div class="blog-image">
                        <a href = \"/b/$nameHash\">
                          <img src=\"https://placehold.co/200x200\" alt=\"Sample Image\">
                        </a>
                        <div class=\"blog-image-text\">$blogDate</div>
                      </div>
                      <h3 class=\"blog-title\">
                        <a href=\"/b/$nameHash\" class=\"invis-link\" style=\"color: black\">
                          $blogTitle
                        </a>
                      </h3>
                    </div>
                  " >> "$out/blog/index.html"
                  buildBlogPost "$nameHash"
                  break
                fi

                curKey="$(echo $line | cut -d '=' -f 1 | xargs)"
                curVal="$(echo $line | cut -d '=' -f 2 | xargs)"

                case "$curKey" in
                  "title")
                    blogTitle=$curVal
                    ;;
                  "date")
                    blogDate=$curVal
                    ;;
                esac                
              done
            fi
          done

          echo "</div>"                   >> "$out/blog/index.html"
          cat "template/tail.html"        >> "$out/blog/index.html"
        }

        buildMainPage
        buildBlogsList

      '';      
    };

    apps.default = {
      type = "app";
      program = let
        script = pkgs.writeShellScriptBin "run-server" ''
          ${pkgs.python3Minimal}/bin/python3 -m http.server 8000 --directory result/;
        '';
      in
        "${script}/bin/run-server";
        
    };

    defaultPackage.x86_64-linux = self.packages.default;
    defaultApp.x86_64-linux = self.apps.default;
  };
}
