document.querySelectorAll(".quote-form").forEach((form) => {
  form.addEventListener("submit", (event) => {
    event.preventDefault();
    const message = form.querySelector(".form-message");
    if (message) {
      message.textContent = "Your quote request details are ready. Connect this form to a verified business email or CRM before public launch.";
    }
  });
});
