expect 0 src/App.tsx ""

printf 'import { useState } from "react";\nexport function Bad({ on }: { on: boolean }) {\n  if (on) {\n    const [x] = useState(0);\n    return <p>{x}</p>;\n  }\n  return <img src="/a.png" />;\n}\n' > src/Bad.tsx
expect 2 src/Bad.tsx "rules-of-hooks"
expect 2 src/Bad.tsx "alt-text"
rm src/Bad.tsx

blocks "missing Open Graph tags: og:title og:description og:image"
sed -i '' 's|<title>Fixture</title>|<title>Fixture</title>\
    <meta property="og:title" content="Fixture" />\
    <meta property="og:description" content="A fixture." />\
    <meta property="og:image" content="https://example.com/og.png" />|' index.html
passes
