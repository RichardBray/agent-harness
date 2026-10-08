for i in $(seq 301); do echo "export const v$i = $i;"; done > src/long.ts

expect 0 src/good.ts ""
expect 2 src/bad.ts "No \`as\` casts"
expect 2 src/bad.ts "No console"
expect 2 src/bad.ts "through its index"
expect 2 src/long.ts "Split it"

printf 'export const  a={b:1}\n' > src/fmt.ts
formats src/fmt.ts "export const a = { b: 1 };"
rm src/fmt.ts

blocks "No console"
rm -rf src/bad.ts src/long.ts src/features

body='export function sum(xs: number[]): number {
let total = 0;
for (const x of xs) {
if (x > 0) total += x;
else total -= x;
}
const avg = total / xs.length;
return avg > 10 ? total : avg;
}'
echo "$body" > src/dup1.ts
echo "$body" | sed 's/sum/sum2/' > src/dup2.ts
printf 'export { sum } from "./dup1.js";\nexport { sum2 } from "./dup2.js";\n' >> src/index.ts
blocks "Duplicated code"
rm src/dup1.ts src/dup2.ts
cp "$fx/src/index.ts" src/index.ts

cp package.json package.json.bak
jq '.dependencies = {"left-pad": "^1.3.0"}' package.json.bak > package.json
blocks "Pin the exact version"
mv package.json.bak package.json

echo 'export const orphan = 1;' > src/orphan.ts
blocks "Unused code"
rm src/orphan.ts
passes

printf 'export const a = JSON.parse("1") as number;\nexport const b = 2;\n' > src/legacy.ts
echo 'export { a, b } from "./legacy.js";' >> src/index.ts
blocks "No \`as\` casts"
"$root/bin/harness" baseline >/dev/null
passes
printf 'export const c = JSON.parse("1") as string;\n' >> src/legacy.ts
echo 'export { c } from "./legacy.js";' >> src/index.ts
blocks "New issues"
rm -rf .claude/baseline src/legacy.ts
cp "$fx/src/index.ts" src/index.ts
passes
