# Shared, visible identity and buyer navigation. No invented credentials or AI-only content.
function OrganizationReference {
  return @{ "@type"="Organization"; "@id"="$BaseUrl/#organization"; name=$OrganizationName; url="$BaseUrl/" }
}

function SiteOrganizationStructuredData {
  return @{
    "@context"="https://schema.org"; "@type"="Organization"; "@id"="$BaseUrl/#organization";
    name=$OrganizationName; alternateName=$Brand; url="$BaseUrl/";
    description="B2B custom sticker and decorative label project support for artwork, formats, materials, proof review and packing.";
    email=$ContactEmail;
    contactPoint=@{ "@type"="ContactPoint"; contactType="project inquiries"; email=$ContactEmail; url="$BaseUrl/contact/"; availableLanguage=@("English") }
  }
}

$BuyerDecisionRoutes = @(
  @{ Question="Roll labels or sticker sheets?"; Answer="Choose around the application sequence, quantities per design and leftover handling, rather than total label count alone."; Url="/blog/roll-labels-vs-sheet-stickers/"; Link="Compare the supply workflow" },
  @{ Question="What does a proof approve?"; Answer="A digital proof records artwork and identified instructions. Physical appearance and use questions need references that represent those conditions."; Url="/blog/custom-sticker-samples-and-digital-proofs/"; Link="Separate proof and sample decisions" },
  @{ Question="Which material and adhesive?"; Answer="Identify the actual contact surface, coating, application conditions and intended use before comparing proposed constructions."; Url="/blog/sticker-adhesive-surface-matching-guide/"; Link="Build a surface brief" },
  @{ Question="What makes two quotes comparable?"; Answer="Align the finished unit, artwork allocation, construction, packing and delivery scope before comparing amounts."; Url="/blog/how-much-do-custom-stickers-cost/"; Link="Check the quoted unit and scope" },
  @{ Question="What should an artwork handoff contain?"; Answer="Connect the controlling artwork revision to dimensions, cut intent, quantities by design and the delivered format. Keep missing items visible."; Url="/blog/prepare-artwork-for-custom-stickers/"; Link="Prepare a controlled artwork package" },
  @{ Question="Is a reorder still the same specification?"; Answer="Compare the new request with the approved baseline, then identify which artwork, package, construction or packing changes need review."; Url="/blog/custom-sticker-reorder-checklist/"; Link="Review changes before reusing approval" }
)

function BuyerDecisionSection([string]$Id) {
  $cards = foreach ($route in $BuyerDecisionRoutes) {
    '<article><h3>' + (Escape-Html $route.Question) + '</h3><p>' + (Escape-Html $route.Answer) + '</p><a href="' + $route.Url + '">' + (Escape-Html $route.Link) + ' <span aria-hidden="true">&rarr;</span></a></article>'
  }
  return '<section class="section buyer-decisions" id="' + $Id + '" aria-labelledby="' + $Id + '-heading"><div class="section-head"><p class="eyebrow">Buyer decision guides</p><h2 id="' + $Id + '-heading">Start with the Decision You Need to Make</h2><p>Find a specific comparison or checklist, then bring the relevant details into your project brief.</p></div><div class="decision-route-grid">' + ($cards -join "`n") + '</div></section>'
}

function ArticleSectionNavigation([string]$Body) {
  $entries = [System.Collections.Generic.List[string]]::new()
  $used = @{}
  # Preserve existing IDs and reserve all IDs before creating any new fragment.
  foreach ($match in [regex]::Matches($Body, '\bid="([^"]+)"')) { $used[$match.Groups[1].Value] = $true }
  $bodyWithIds = [regex]::Replace($Body, '<h2(?<attrs>[^>]*)>(?<heading>.*?)</h2>', {
    param($match)
    $text = [System.Net.WebUtility]::HtmlDecode([regex]::Replace($match.Groups['heading'].Value, '<[^>]+>', '')).Trim()
    if (-not $text) { return $match.Value }
    $attrs = $match.Groups['attrs'].Value
    $existing = [regex]::Match($attrs, '\bid="([^"]+)"')
    if ($existing.Success) { $id = $existing.Groups[1].Value }
    else {
      $stem = ([regex]::Replace($text.ToLowerInvariant(), '[^a-z0-9]+', '-')).Trim('-')
      if (-not $stem) { $stem = 'section' }
      $id = $stem; $suffix = 2
      while ($used.ContainsKey($id)) { $id = "$stem-$suffix"; $suffix++ }
      $used[$id] = $true
      $attrs += ' id="' + $id + '"'
    }
    $entries.Add('<li><a href="#' + (Escape-Html $id) + '">' + (Escape-Html $text) + '</a></li>')
    return '<h2' + $attrs + '>' + $match.Groups['heading'].Value + '</h2>'
  }, [System.Text.RegularExpressions.RegexOptions]::Singleline)
  if ($entries.Count -lt 2) { return $Body }
  $navigation = '<nav class="article-contents" aria-label="In this guide"><strong>In this guide</strong><ol>' + ($entries -join '') + '</ol></nav>'
  return $bodyWithIds.Replace('<article class="section blog-article">', '<article class="section blog-article">' + "`n" + $navigation)
}

function SiteBodyEnhancements([string]$Url, [string]$Body) {
  if ($Url -eq '/') {
    $identity = @"
<section class="section site-introduction" aria-labelledby="site-introduction-heading">
  <p class="eyebrow">ZC Labels</p><h2 id="site-introduction-heading">Custom Stickers and Labels for B2B Buying Decisions</h2>
  <p>ZC Labels is the name behind this custom sticker and decorative label website. Explore individual die-cut stickers, kiss-cut pieces, sheets, roll labels and retail packs, then confirm the artwork, application and delivered format for your project.</p>
  <p><a href="/about-us/">About ZC Labels</a> &middot; <a href="/about-us/#editorial-standards">How our buyer guides are prepared</a> &middot; <a href="/get-quote/">Send a project brief</a></p>
</section>
"@
    $firstSectionEnd = $Body.IndexOf('</section>') + '</section>'.Length
    if ($firstSectionEnd -ge '</section>'.Length) { $Body = $Body.Insert($firstSectionEnd, "`n" + $identity) }
    $Body += "`n" + (BuyerDecisionSection 'buyer-decisions')
  }
  if ($Url -eq '/blog/') {
    $firstSectionEnd = $Body.IndexOf('</section>') + '</section>'.Length
    if ($firstSectionEnd -ge '</section>'.Length) { $Body = $Body.Insert($firstSectionEnd, "`n" + (BuyerDecisionSection 'find-your-guide')) }
  }
  if ($Url -eq '/about-us/') {
    $Body += @"
<section class="section two-col" id="publisher-details" aria-labelledby="publisher-heading">
  <div><p class="eyebrow">Site publisher</p><h2 id="publisher-heading">ZC Labels and This Website</h2><p>ZC Labels publishes this English-language website for B2B custom sticker and decorative label projects. The catalog organizes product directions; the buyer guides help prepare decisions about artwork, material, application, proof review and packing.</p><p>A website guide is a starting point for a project discussion. Availability, construction, pricing, quantities, timing and document scope need confirmation for the actual order.</p></div>
  <div id="publisher-contact"><h2>Contact and Corrections</h2><p>Email <a href="$MailtoUrl">$ContactEmail</a> or use the <a href="/contact/">contact page</a>. For a correction, include the page URL, the specific statement and a relevant source or project detail. Send only the information needed to explain the issue.</p><p>For a new project, the <a href="/get-quote/">quote form</a> organizes dimensions, artwork, quantities, use conditions and packing requirements.</p></div>
</section>
<section class="section editorial-standards" id="editorial-standards" aria-labelledby="editorial-heading">
  <div class="section-head"><p class="eyebrow">How to read our guides</p><h2 id="editorial-heading">Content Sources, AI Assistance and Approval Limits</h2><p>Buyer guides are published under the ZC Labels organization name. This identifies the site publisher, rather than a named individual reviewer or a claimed certification.</p></div>
  <div class="decision-route-grid">
    <article><h3>Research and practical judgment</h3><p>Guides combine procurement checklists and conditional comparisons with relevant source material. Where a technical claim relies on an outside source, its scope matters: another supplier's specification is not automatically a ZC Labels product specification.</p></article>
    <article><h3>AI-assisted preparation</h3><p>AI tools assist with research, drafting and illustrative packaging design. They do not establish that an order, interview, factory visit or performance test occurred. Named fictional examples are used to explain a decision, not presented as customer records.</p></article>
    <article><h3>Images and evidence</h3><p>AI-generated packaging examples are identified in their captions. An attractive mockup cannot prove adhesion, color matching, compliance or production capability. Use project-specific documents and appropriate representative samples for those decisions.</p></article>
    <article><h3>Versions and unresolved questions</h3><p>A visible publication or update date identifies the page version, not a test date. A guide cannot replace the accepted artwork, quotation, specification or written project approval. Keep any unanswered application or document question visible before release.</p></article>
  </div>
  <p><a href="/blog/custom-sticker-samples-and-digital-proofs/">Understand what proofs and samples can approve</a> &middot; <a href="/compliance-and-document-review/">Prepare a project-specific document request</a></p>
</section>
"@
  }
  $formatGuides = @{
    '/products/custom-die-cut-stickers/' = @(@('/blog/sticker-sheets-vs-die-cut-stickers/','Compare die-cut and kiss-cut supply formats'), @('/blog/how-to-add-cutline-to-sticker-artwork/','Agree the physical cut edge'));
    '/products/custom-kiss-cut-stickers/' = @(@('/blog/sticker-sheets-vs-die-cut-stickers/','Identify the sticker and delivered backing'), @('/blog/easy-peel-tab-stickers-guide/','Plan a place to start peeling'));
    '/products/custom-sticker-sheets/' = @(@('/blog/custom-planner-sticker-sheets-guide/','Review the smallest functional sticker'), @('/blog/roll-labels-vs-sheet-stickers/','Compare sheet and roll workflows'));
    '/products/custom-roll-labels/' = @(@('/blog/label-roll-unwind-direction-core-size-guide/','Confirm roll direction and core requirements'), @('/blog/automatic-label-applicator-first-run-guide/','Prepare an application trial record'));
    '/products/custom-holographic-stickers/' = @(@('/blog/holographic-stickers-artwork-production-guide/','Choose reflective and opaque areas'), @('/blog/white-ink-small-text-custom-stickers/','Review essential text at final size'))
  }
  if ($formatGuides.ContainsKey($Url)) {
    $links = foreach ($guide in $formatGuides[$Url]) { '<li><a href="' + $guide[0] + '">' + (Escape-Html $guide[1]) + '</a></li>' }
    $Body += '<section class="section format-guide-links"><h2>Before You Approve This Format</h2><p>Use the relevant guide to settle the production question, then include the accepted details in your project brief.</p><ul>' + ($links -join '') + '</ul><p><a href="/label-specification-planner/">Organize your specification</a> or <a href="/get-quote/">request a project review</a>.</p></section>'
  }
  return $Body
}
