function getPageContext() {
  const path = window.location.pathname;
  const productMatch = path.match(/\/products\/([^/]+)\//);
  const params = new URLSearchParams(window.location.search);
  return {
    source_page: path,
    product_category: productMatch ? productMatch[1] : "",
    keyword_group: path.includes("/blog/") ? "blog_content_cluster" : (productMatch ? "product_commercial" : "site_navigation"),
    campaign: params.get("utm_campaign") || "",
    referrer: document.referrer || ""
  };
}

function trackConversionEvent(name, details = {}) {
  const payload = { ...getPageContext(), ...details };
  window.dataLayer = window.dataLayer || [];
  window.dataLayer.push({ event: name, ...payload });
  if (typeof window.gtag === "function") {
    window.gtag("event", name, payload);
  }
}

document.querySelectorAll('a[href^="https://api.whatsapp.com"], a[href^="mailto:"]').forEach((link) => {
  link.addEventListener("click", () => {
    const isWhatsApp = link.href.includes("api.whatsapp.com");
    trackConversionEvent(isWhatsApp ? "whatsapp_quote_click" : "email_quote_click", {
      link_text: link.textContent.trim()
    });
  });
});

document.querySelectorAll(".quote-form").forEach((form) => {
  form.addEventListener("submit", (event) => {
    event.preventDefault();
    const contactEmail = "ruishengmao05@gmail.com";
    const labels = {
      sticker_type: "Sticker Type",
      sticker_format: "Sticker Format",
      email: "Buyer Email",
      whatsapp: "Buyer WhatsApp",
      country: "Country",
      application: "Intended Application",
      size: "Size",
      shape: "Shape",
      quantity: "Quantity",
      material_preference: "Material Preference",
      finish_preference: "Finish Preference",
      artwork_status: "Artwork Status",
      artwork_reference: "Artwork / Reference",
      deadline: "Deadline",
      message: "Message"
    };
    const lines = Array.from(new FormData(form).entries()).map(([key, value]) => {
      const text = value instanceof File ? value.name : value;
      return `${labels[key] || key}: ${text || "Not provided"}`;
    });
    const context = getPageContext();
    lines.push("");
    lines.push("Tracking Context");
    lines.push(`Source Page: ${context.source_page || "Not provided"}`);
    lines.push(`Product Category: ${context.product_category || "Not provided"}`);
    lines.push(`Keyword Group: ${context.keyword_group || "Not provided"}`);
    lines.push(`Campaign: ${context.campaign || "Not provided"}`);
    lines.push(`Referrer: ${context.referrer || "Not provided"}`);
    lines.push("Note: Please attach artwork or reference files in your email if needed.");
    const subject = encodeURIComponent("Custom Sticker Quote Request");
    const body = encodeURIComponent(lines.join("\n"));
    const message = form.querySelector(".form-message");
    if (message) {
      message.textContent = "Opening your email client with the quote request details.";
    }
    trackConversionEvent("quote_form_prepare_email", {
      form_id: form.id || "",
      sticker_type: form.elements.sticker_type?.value || "",
      sticker_format: form.elements.sticker_format?.value || "",
      artwork_status: form.elements.artwork_status?.value || ""
    });
    window.location.href = `mailto:${contactEmail}?subject=${subject}&body=${body}`;
  });
});
