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
      `
    }
  }
}
