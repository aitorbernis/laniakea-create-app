"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.log = log;
const chalk_1 = __importDefault(require("chalk"));
const prefixes = {
    info: "[ℹ]",
    success: "[✓]",
    warn: "[!]",
    error: "[✗]",
};
const colorFns = {
    info: chalk_1.default.gray,
    success: chalk_1.default.green,
    warn: chalk_1.default.yellow,
    error: chalk_1.default.red,
};
function log(level, message, verboseOnly = false) {
    if (verboseOnly && !process.argv.includes("--verbose"))
        return;
    console.log(colorFns[level](`${prefixes[level]} ${message}`));
}
