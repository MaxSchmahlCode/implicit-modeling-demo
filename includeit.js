function includeit(id, file, callback) {
  fetch(file)
    .then(r => r.text())
    .then(t => {
      document.getElementById(id).innerHTML = t;
      if (callback) callback();
    });
}