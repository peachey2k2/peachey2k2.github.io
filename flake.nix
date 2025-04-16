{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/24.11";
  };

  outputs = { self, nixpkgs }:
  let
    pkgs = import nixpkgs { system = "x86_64-linux"; };

    marked = pkgs.callPackage ./packages/marked/package.nix {};
    hljs = pkgs.callPackage ./packages/highlight.js-cli/package.nix {};
  in {
    devShell.default = pkgs.mkShell {
      name = "static-website-dev";
      packages = [
        marked
        hljs
        pkgs.python3Minimal
        pkgs.imagemagick
      ];
    };

    packages.default = pkgs.stdenv.mkDerivation {
      pname = "static-website";
      version = "0.1.0";
      src = ./.;

      installPhase = ''
        mkdir -p "$out"

        cp "favicon.ico" "$out/favicon.ico"
        cp "style.css" "$out/style.css"
        cp "VT323.ttf" "$out/VT323.ttf"
        cp -r "88x31" "$out/88x31"
        cp -r "images" "$out/images"

        createThumbnail() {
          splittedTitle="$(echo "$blogTitle" | sed -E 's/(.{20}.? )/\1\n/')"
          topLine="$(echo "$splittedTitle" | head -n 1)"
          botLine="$(echo "$splittedTitle" | tail -n +2)"

          asp=$(${pkgs.imagemagick}/bin/identify -format '%[fx:w/h]' "images/$blogImage")

          ${pkgs.imagemagick}/bin/magick -size 1200x800 xc:#0000ff \
          -font VT323.ttf -gravity Center -pointsize 72 \
          -fill \#000000 -draw 'rectangle 160, 100 1120, 740' \
          -fill \#b2b2b2 -draw 'rectangle 120, 60 1080, 700' \
          -fill \#000000 -annotate +0+180 "$topLine" \
          -fill \#000000 -annotate +0+250 "$botLine" \
          -fill \#000000 -draw "rectangle %[fx:600-210*$asp-20], 80 %[fx:600+210*$asp+20], 540" \
          -fill \#b2b2b2 -draw "rectangle %[fx:600-210*$asp-16], 84 %[fx:600+210*$asp+16], 536" \
          -fill \#b2b2b2 -draw 'rectangle 500, 78 700, 86' \
          -pointsize 40 \
          -fill \#000000 -annotate +0-320 "$blogDate" \
          -draw "image SrcOver 0, -90 %[fx:420*$asp], 420 images/$blogImage" \
          "$out/images/thumb_$blogImage"
        }

        buildMainPage() {
          cat "template/head.html" |
            sed 's/@title@/about - peachey2k2/g' |
            sed 's/@desc@//g' |
            sed 's/@image@//g' |
            sed 's/@url@//g'                  >> "$out/index.html"
          echo '<div id="markdown-content">'  >> "$out/index.html"
          cat "markdown/about.md" |
            ${marked}/bin/marked -c "marked.js" |
            ${hljs}/bin/hljs                  >> "$out/index.html"
          echo '</div>'                       >> "$out/index.html"
          cat "template/tail.html"            >> "$out/index.html"
        }

        buildBlogPost() {
          mkdir -p "$out/b/$1"
          cat "template/head.html" |
            sed "s/@title@/$blogTitle - peachey2k2/g" |
            sed "s/@desc@/$blogTldr/g" |
            sed "s/@image@/\/images\/thumb_$blogImage/g" |
            sed "s/@url@/\/b\/$1/g"            >> "$out/b/$1/index.html"

          echo '<div id="markdown-content">'   >> "$out/b/$1/index.html"
          echo "![$blogDate](/images/$blogImage)" |
            ${marked}/bin/marked -c "marked.js" >> "$out/b/$1/index.html"
          echo "<h1 class=centered style=\"text-decoration: underline\">$blogTitle</h1> <p>" >> "$out/b/$1/index.html"
          echo "TL;DR - $blogTldr" | ${marked}/bin/marked >> "$out/b/$1/index.html"
          echo '</p> </div>'                        >> "$out/b/$1/index.html"

          echo '<div id="markdown-content">'   >> "$out/b/$1/index.html"
          ${marked}/bin/marked -c "marked.js" |
            ${hljs}/bin/hljs                   >> "$out/b/$1/index.html"
          echo '</div>'                        >> "$out/b/$1/index.html"
          cat "template/tail.html"             >> "$out/b/$1/index.html"
        }

        buildBlogsList() {
          mkdir -p "$out/blog"
          cat "template/head.html" |
            sed "s/@title@/blogs - peachey2k2/g" |
            sed "s/@desc@//g" |
            sed "s/@image@//g" |
            sed "s/@url@/\/blog/g"             >> "$out/blog/index.html"
          echo "<div class='blog-list'>"       >> "$out/blog/index.html"

          mkdir -p "$out/b"
          touch "$out/blog-list.ini"

          ls -1r "./blog" | while read file; do
            if (echo $file | grep "\.md\$" > "/dev/null"); then
              nameStripped="''\'''${file%.md}'"
              nameHash=$(echo $nameStripped | md5sum | head -c 8)

              cat "blog/$file" | while read line; do
                if [[ "$line" == "---" ]]; then

                  createThumbnail

                  echo "
                    <div class="blog-card">
                      <div class="blog-image">
                        <a href = \"/b/$nameHash\">
                          <img src=\"/images/$blogImage\" alt=\"Sample Image\">
                        </a>
                        <time datetime=\"$blogDate\" class=\"blog-image-text\">$blogDate</time>
                      </div>
                      <h3 class=\"blog-title\">
                        <a href=\"/b/$nameHash\" class=\"invis-link\" style=\"color: black; text-decoration: underline\">
                          $blogTitle
                        </a>
                      </h3>
                    </div>
                  " >> "$out/blog/index.html"
                  buildBlogPost "$nameHash"                  break
                fi

                curKey="$(echo "$line" | cut -d '=' -f 1 | xargs)"
                curVal="$(echo "$line" | cut -d '=' -f 2 | xargs)"

                case "$curKey" in
                  "title")
                    blogTitle=$curVal
                    ;;
                  "date")
                    blogDate=$curVal
                    ;;
                  "image")
                    blogImage=$curVal
                    ;;
                  "tldr")
                    blogTldr=$curVal
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
