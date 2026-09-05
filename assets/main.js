document.querySelectorAll(".quote-form").forEach((form) => {
  form.addEventListener("submit", (event) => {
    event.preventDefault();
    const contactEmail = "ruishengmao05@gmail.com";
    const labels = {
      sticker_type: "Sticker Type",
      email: "Buyer Email",
      whatsapp: "Buyer WhatsApp",
      country: "Country",
      application: "Intended Application",
      size: "Size",
      shape: "Shape",
      quantity: "Quantity",
      material_preference: "Material Preference",
      finish_preference: "Finish Preference",
      artwork_reference: "Artwork / Reference",
      message: "Message"
    };
    const lines = Array.from(new FormData(form).entries()).map(([key, value]) => {
      const text = value instanceof File ? value.name : value;
      return `${labels[key] || key}: ${text || "Not provided"}`;
    });
    lines.push("Note: Please attach artwork or reference files in your email if needed.");
    const subject = encodeURIComponent("Custom Sticker Quote Request");
    const body = encodeURIComponent(lines.join("\n"));
    const message = form.querySelector(".form-message");
    if (message) {
      message.textContent = "Opening your email client with the quote request details.";
    }
    window.location.href = `mailto:${contactEmail}?subject=${subject}&body=${body}`;
  });
});
