// function include(id, file) {
//   fetch(file).then(r => r.text()).then(t => document.getElementById(id).innerHTML = t);
// }

function include(id, file) {
  fetch(file)
    .then(r => r.text())
    .then(t => {
      document.getElementById(id).innerHTML = t;
    })
    .catch(err => console.error("Include error:", err));
}