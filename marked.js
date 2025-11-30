module.exports = {
  renderer: {
    image({href, text}) {
      return `
        <div class="centered-div">
          <div class="blog-image" style="display: inline-flex">
            <img src="${href}">
            <div class="blog-image-text">
              ${text}
            </div>
          </div>
        </div>
      `;
    },

    heading({depth, text}) {
      const decors = [
        "#######",
        "=====",
        "---"
      ];
      const decor = decors[depth-1];
      return `
        <h${depth} class="centered">
          ${decor} ${text} ${decor}
        </h${depth}>
      `;
    },

    code({lang: display, text: code}) {
      const escapedText = escape(code);
      const parts = display.split('@')

      return `
        <div class="centered-div">
          <div class="blog-image" style="display: inline-flex">
            <pre style="margin: 8px; overflow-y: auto"><code class="hljs ${(parts[0] ? "code-hl language-" + parts[0] : "")}">${escapedText}</code></pre>
            <div class="blog-image-text">
              ${parts[1] || ""}
            </div>
          </div>
        </div>
      `;
    },

    codespan({text}) {
      return `
        <code class="codespan">${text}</code>
      `;
    }
  },
}

const escapeReplacements = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#39;',
};
const getEscapeReplacement = (ch) => escapeReplacements[ch];
const escapeTest = /[&<>"']/;
const escapeReplace = /[&<>"']/g;

function escape(text) {
  if (escapeTest.test(text)) {
    return text.replace(escapeReplace, getEscapeReplacement);
  }
  return text;
}
