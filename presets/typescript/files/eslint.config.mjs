import { defineConfig } from "eslint/config";
import tseslint from "typescript-eslint";
import harness from "./.harness/rules.mjs";

export default defineConfig(
  { ignores: ["dist/**", "node_modules/**", ".harness/**", "*.config.*"] },
  tseslint.configs.strictTypeChecked,
  {
    languageOptions: { parserOptions: { projectService: true } },
    plugins: { harness },
    rules: {
      "harness/max-lines": ["error", 300],
      "no-restricted-syntax": [
        "error",
        {
          selector: "TSAsExpression:not([typeAnnotation.typeName.name='const'])",
          message: "No `as` casts. Narrow with a type guard or parse the value (e.g. zod) instead.",
        },
        {
          selector: "CallExpression[callee.object.name='console']",
          message: "No console. Use the project logger.",
        },
      ],
      "no-restricted-imports": [
        "error",
        {
          patterns: [
            {
              regex: "features/[^/]+/.",
              message: "Import another feature only through its index: `features/<name>`.",
            },
          ],
        },
      ],
    },
  },
);
