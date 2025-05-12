#!/usr/bin/env node
"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const logger_1 = require("./utils/logger");
const prompts_1 = require("./utils/prompts");
const ora_1 = __importDefault(require("ora"));
const child_process_1 = require("child_process");
const path_1 = __importDefault(require("path"));
const fs_1 = __importDefault(require("fs"));
async function main() {
    try {
        (0, logger_1.log)("info", "🔧 Welcome to the Laniakea project generator");
        // 1) Leer configuración
        const cfg = await (0, prompts_1.askConfig)();
        (0, logger_1.log)("success", `Configuration received for "${cfg.name}"`);
        // 2) Clonar plantilla (overrideable con env var)
        const tplUrl = process.env.TEMPLATE_URL ||
            "https://github.com/aitorbernis/laniakea-app-template.git";
        const spinner = (0, ora_1.default)(`Cloning template from ${tplUrl}…`).start();
        try {
            (0, child_process_1.execSync)(`git clone --depth 1 ${tplUrl} ${cfg.name}`, {
                stdio: "inherit",
            });
            spinner.succeed("Template cloned");
        }
        catch (err) {
            spinner.fail("Failed to clone template");
            (0, logger_1.log)("error", err.message);
            process.exit(1);
        }
        // 3) Cambiar al nuevo directorio
        const projectDir = path_1.default.resolve(process.cwd(), cfg.name);
        process.chdir(projectDir);
        // 4) Generar .env raíz
        (0, logger_1.log)("info", "Generating root .env…", true);
        const envRoot = `HTTP_PORT=${cfg.httpPort}
ADMIN_PORT=${cfg.adminPort}
BACKEND_PORT=${cfg.backendPort}
DB_PORT=${cfg.dbPort}

DB_ROOT_PASSWORD=${cfg.dbRootPassword}
DB_NAME=${cfg.dbName}
DB_USER=${cfg.dbUser}
DB_PASSWORD=${cfg.dbPassword}
`;
        fs_1.default.writeFileSync(path_1.default.join(projectDir, ".env"), envRoot);
        (0, logger_1.log)("success", "Root .env created");
        // 5) Generar backend/.env
        (0, logger_1.log)("info", "Generating backend/.env…", true);
        const envBackend = `DATABASE_URL="mysql://${cfg.dbUser}:${cfg.dbPassword}@localhost:${cfg.dbPort}/${cfg.dbName}"
PORT=${cfg.backendPort}
`;
        fs_1.default.writeFileSync(path_1.default.join(projectDir, "backend", ".env"), envBackend);
        (0, logger_1.log)("success", "backend/.env created");
        // 6) Generar frontend/.env.local
        (0, logger_1.log)("info", "Generating frontend/.env.local…", true);
        const envFrontend = `VITE_API_URL=http://localhost:${cfg.backendPort}
`;
        fs_1.default.writeFileSync(path_1.default.join(projectDir, "frontend", ".env.local"), envFrontend);
        (0, logger_1.log)("success", "frontend/.env.local created");
        // 7) Generar admin/.env.local
        (0, logger_1.log)("info", "Generating admin/.env.local…", true);
        const envAdmin = `VITE_API_URL=http://localhost:${cfg.backendPort}
`;
        fs_1.default.writeFileSync(path_1.default.join(projectDir, "admin", ".env.local"), envAdmin);
        (0, logger_1.log)("success", "admin/.env.local created");
        // 8) Instrucciones finales
        (0, logger_1.log)("info", "You can now run:", true);
        (0, logger_1.log)("info", `  cd ${cfg.name}`);
        (0, logger_1.log)("info", "  npm run dev");
        (0, logger_1.log)("success", "🚀 Project ready!");
    }
    catch (err) {
        (0, logger_1.log)("error", "Unexpected error");
        console.error(err);
        process.exit(1);
    }
}
main();
