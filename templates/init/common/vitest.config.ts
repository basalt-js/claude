import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    // Projects stay valid while they are still empty.
    passWithNoTests: true,
    projects: [
      {
        extends: true,
        test: {
          name: "unit",
          include: ["tests/unit/**/*.test.ts"]
        }
      },
      {
        extends: true,
        test: {
          name: "integration",
          include: ["tests/integration/**/*.test.ts"]
        }
      }
    ],
    coverage: {
      provider: "istanbul",
      include: ["src/**/*.ts"],
      exclude: ["src/**/types.ts"],
      reporter: ["text", "lcov"],
      reportsDirectory: "./coverage",
      thresholds: {
        lines: 90,
        functions: 90,
        branches: 90,
        statements: 90
      }
    }
  }
});
