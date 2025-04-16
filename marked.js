/** @type (text: string) => boolean */
const isDate = (text) => !isNaN(new Date(text).getTime());

module.exports = {
  renderer: {
    image({href, text}) {
      const tag = isDate(text) ? 'time' : 'div';
      const prop = isDate(text) ? `datetime=\"${text}\"` : '';
      return `
        <div class="centered-div">
          <div class="blog-image" style="display: inline-flex">
            <img src="${href}">
            <${tag} ${prop} class="blog-image-text">
              ${text}
            </${tag}>
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
    code({lang, text}) {
      const escapedText = escape(text);

      return `
        <div class="centered-div">
          <div class="blog-image" style="display: inline-flex">
            <pre style="margin: 8px; overflow-y: auto"><code class="language-${lang}">${escapedText}</code></pre>
            <div class="blog-image-text">
              ${lang}
            </div>
          </div>
        </div>
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
