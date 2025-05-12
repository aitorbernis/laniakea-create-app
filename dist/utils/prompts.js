"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.askConfig = askConfig;
const inquirer_1 = __importDefault(require("inquirer"));
async function askConfig() {
    const questions = [
        {
            type: "input",
            name: "name",
            message: "Project name:",
            validate: (v) => v.trim() !== "" || "You must provide a project name.",
        },
        {
            type: "input",
            name: "httpPort",
            message: "HTTP port for frontend:",
            default: "3000",
            filter: (v) => parseInt(v, 10),
        },
        {
            type: "input",
            name: "adminPort",
            message: "HTTP port for admin:",
            default: "3001",
            filter: (v) => parseInt(v, 10),
        },
        {
            type: "input",
            name: "backendPort",
            message: "Port for backend:",
            default: "8000",
            filter: (v) => parseInt(v, 10),
        },
        {
            type: "input",
            name: "dbPort",
            message: "MariaDB port:",
            default: "3306",
            filter: (v) => parseInt(v, 10),
        },
        {
            type: "input",
            name: "dbRootPassword",
            message: "Root DB password:",
            default: "rootpass",
        },
        {
            type: "input",
            name: "dbName",
            message: "DB name:",
            default: "name",
        },
        {
            type: "input",
            name: "dbUser",
            message: "DB user:",
            default: "user",
        },
        {
            type: "input",
            name: "dbPassword",
            message: "DB password:",
            default: "pass",
        },
    ];
    const answers = (await inquirer_1.default.prompt(questions));
    return answers;
}
