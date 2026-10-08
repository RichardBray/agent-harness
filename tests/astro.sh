blocks "missing Open Graph tags: og:title og:description og:image"
sed -i '' 's|<title>{title}</title>|<title>{title}</title>\
    <meta property="og:title" content={title} />\
    <meta property="og:description" content="A fixture." />\
    <meta property="og:image" content="https://example.com/og.png" />|' src/pages/index.astro
passes
