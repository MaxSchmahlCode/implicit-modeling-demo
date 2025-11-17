// function include(id, file) {
//   fetch(file)
//     .then(r => r.text())
//     .then(t => {
//       document.getElementById(id).innerHTML = t;
//     })
//     .catch(err => console.error("Include error:", err));
// }


// function include(id, file) {
//   fetch(file)
//     .then(r => r.text())
//     .then(t => {
//       const container = document.getElementById(id);
//       container.innerHTML = t;

//       // Execute any <script> tags inside the included file
//       const scripts = container.querySelectorAll("script");
//       scripts.forEach(oldScript => {
//         const newScript = document.createElement("script");
//         if (oldScript.src) {
//           newScript.src = oldScript.src;
//         } else {
//           newScript.textContent = oldScript.textContent;
//         }
//         document.body.appendChild(newScript);
//       });
//     })
//     .catch(err => console.error("Include error:", err));
// }


function include(id, file, callback) {
  fetch(file)
    .then(r => {
      if (!r.ok) throw new Error(`Include fetch failed: ${r.status} ${r.statusText}`);
      return r.text();
    })
    .then(htmlText => {
      const container = document.getElementById(id);
      if (!container) throw new Error(`No element with id="${id}" found`);

      // Insert HTML
      container.innerHTML = htmlText;

      // Find and execute scripts inside the inserted HTML
      // (Browsers do not execute <script> tags injected via innerHTML)
      const scripts = Array.from(container.querySelectorAll("script"));
      scripts.forEach(oldScript => {
        const newScript = document.createElement("script");

        // Copy attributes like type, async, defer, crossorigin if present
        for (let i = 0; i < oldScript.attributes.length; i++) {
          const attr = oldScript.attributes[i];
          newScript.setAttribute(attr.name, attr.value);
        }

        if (oldScript.src) {
          // External script — re-add so browser will fetch & execute it
          newScript.src = oldScript.src;
          // Keep execution order: append synchronously (no async attribute) unless original requested async
          // If original had async attribute, it will be preserved above.
          document.body.appendChild(newScript);
        } else {
          // Inline script — set the text and append to execute immediately
          newScript.textContent = oldScript.textContent;
          document.body.appendChild(newScript);
        }
        // Remove the original script tag to avoid duplication if needed
        oldScript.parentNode && oldScript.parentNode.removeChild(oldScript);
      });

      // === Automatic initializer for common components ===
      // This helps when included scripts used DOMContentLoaded and thus didn't run.
      // If your header contains navToggle / mobileMenu, attach the handler now.
      const toggle = container.querySelector("#navToggle");
      const menu = container.querySelector("#mobileMenu");
      if (toggle && menu) {
        // avoid duplicate listeners
        if (!toggle.__navToggleInitialized) {
          toggle.addEventListener("click", () => {
            menu.classList.toggle("hidden");
          });
          // close menu on link click (nice mobile UX)
          menu.querySelectorAll("a").forEach(a =>
            a.addEventListener("click", () => menu.classList.add("hidden"))
          );
          toggle.__navToggleInitialized = true;
          console.debug("include.js: nav toggle initialized");
        }
      }

      // If the caller provided a callback, call it now
      if (typeof callback === "function") callback();

    })
    .catch(err => {
      console.error("Include error:", err);
    });
}
