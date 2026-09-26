const planner = document.querySelector("#spec-planner");

if (planner) {
  const brief = document.querySelector("#spec-brief");
  const progress = document.querySelector("#spec-progress");
  const status = document.querySelector("#spec-status");
  const email = document.querySelector("#spec-email");
  const fields = [
    ["Product / application", "product"],
    ["Finished format", "format"],
    ["Width", "width", " mm"],
    ["Height", "height", " mm"],
    ["Container diameter", "diameter", " mm"],
    ["Wrap gap or overlap", "seam", " mm"],
    ["Shape", "shape"],
    ["Total quantity", "quantity", " pieces"],
    ["Artwork versions / SKUs", "designs"],
    ["Backing sheet size", "sheet", " mm x mm"],
    ["Application surface", "surface"],
    ["Material direction", "material"],
    ["Finish direction", "finish"],
    ["Use conditions", "conditions"],
    ["Application method", "application"],
    ["Roll core inner diameter", "core", " mm"],
    ["Maximum roll outer diameter", "roll_outer", " mm"],
    ["Roll unwind direction", "unwind"],
    ["Packing format", "packing"],
    ["Destination market", "market"],
    ["Artwork status", "artwork"],
    ["Other requirements", "notes"]
  ];

  function currentBrief() {
    const data = new FormData(planner);
    const supplied = fields.filter(([, key]) => String(data.get(key) || "").trim()).length;
    const lines = fields.map(([label, key, unit = ""]) => {
      const value = String(data.get(key) || "").trim();
      return `${label}: ${value ? value + unit : "To confirm"}`;
    });
    return {
      supplied,
      text: [
        "CUSTOM LABEL PROJECT BRIEF",
        "Prepared by the buyer for factory review",
        "",
        ...lines,
        "",
        "Please review the open items before quoting. Artwork and package photos will be sent separately."
      ].join("\n")
    };
  }

  function render() {
    const current = currentBrief();
    brief.textContent = current.text;
    progress.textContent = `${current.supplied} of ${fields.length} fields supplied. Unknowns stay marked "To confirm".`;
    email.href = `mailto:ruishengmao05@gmail.com?subject=${encodeURIComponent("Custom label specification for review")}&body=${encodeURIComponent(current.text)}`;
  }

  planner.addEventListener("input", render);
  planner.addEventListener("change", render);
  document.querySelector("#spec-copy").addEventListener("click", async () => {
    try {
      await navigator.clipboard.writeText(currentBrief().text);
      status.textContent = "Brief copied. Paste it into WhatsApp or your email, then attach your artwork.";
      if (typeof trackConversionEvent === "function") {
        trackConversionEvent("spec_brief_copy", { fields_supplied: currentBrief().supplied });
      }
    } catch {
      status.textContent = "Clipboard access was blocked. Select the brief above and copy it manually.";
    }
  });
  email.addEventListener("click", () => {
    if (typeof trackConversionEvent === "function") {
      trackConversionEvent("spec_brief_email", { fields_supplied: currentBrief().supplied });
    }
  });
  render();
}
