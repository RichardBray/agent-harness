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
      "harness/no-as-cast": "error",
      "harness/no-console": "error",
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
