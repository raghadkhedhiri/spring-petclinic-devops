setTimeout(function () {
  ["success-message", "error-message"].forEach(function (id) {
    const message = document.getElementById(id);

    if (message) {
      message.style.display = "none";
    }
  });
}, 3000);
