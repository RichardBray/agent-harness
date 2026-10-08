export default {
  rules: {
    "max-lines": {
      meta: { type: "suggestion", schema: [{ type: "integer" }] },
      create(context) {
        const max = context.options[0] ?? 300;
        return {
          Program(node) {
            const lines = context.sourceCode.lines.length;
            if (lines > max) {
              context.report({
                node,
                message: `File is ${lines} lines (max ${max}). Split it into modules under src/features/<name>/ instead of growing it.`,
              });
            }
          },
        };
      },
    },
  },
};
