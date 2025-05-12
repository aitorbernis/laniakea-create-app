import chalk from "chalk";

export type Level = "info" | "success" | "warn" | "error";

const prefixes: Record<Level, string> = {
  info: "[ℹ]",
  success: "[✓]",
  warn: "[!]",
  error: "[✗]",
};

const colorFns: Record<Level, (s: string) => string> = {
  info: chalk.gray,
  success: chalk.green,
  warn: chalk.yellow,
  error: chalk.red,
};

export function log(level: Level, message: string, verboseOnly = false) {
  if (verboseOnly && !process.argv.includes("--verbose")) return;
  console.log(colorFns[level](`${prefixes[level]} ${message}`));
}
