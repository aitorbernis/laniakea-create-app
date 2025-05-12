#!/usr/bin/env node
import { log } from "./utils/logger";
import { askConfig, Answers } from "./utils/prompts";
import ora from "ora";
import { execSync } from "child_process";
import path from "path";
import fs from "fs";

async function main() {
  try {
    log("info", "🔧 Welcome to the Laniakea project generator");

    // 1) Leer configuración
    const cfg: Answers = await askConfig();
    log("success", `Configuration received for "${cfg.name}"`);

    // 2) Clonar plantilla (overrideable con env var)
    const tplUrl =
      process.env.TEMPLATE_URL ||
      "https://github.com/aitorbernis/laniakea-app-template.git";
    const spinner = ora(`Cloning template from ${tplUrl}…`).start();
    try {
      execSync(`git clone --depth 1 ${tplUrl} ${cfg.name}`, {
        stdio: "inherit",
      });
      spinner.succeed("Template cloned");
    } catch (err) {
      spinner.fail("Failed to clone template");
      log("error", (err as Error).message);
      process.exit(1);
    }

    // 3) Cambiar al nuevo directorio
    const projectDir = path.resolve(process.cwd(), cfg.name);
    process.chdir(projectDir);

    // 4) Generar .env raíz
    log("info", "Generating root .env…", true);
    const envRoot = `HTTP_PORT=${cfg.httpPort}
ADMIN_PORT=${cfg.adminPort}
BACKEND_PORT=${cfg.backendPort}
DB_PORT=${cfg.dbPort}

DB_ROOT_PASSWORD=${cfg.dbRootPassword}
DB_NAME=${cfg.dbName}
DB_USER=${cfg.dbUser}
DB_PASSWORD=${cfg.dbPassword}
`;
    fs.writeFileSync(path.join(projectDir, ".env"), envRoot);
    log("success", "Root .env created");

    // 5) Generar backend/.env
    log("info", "Generating backend/.env…", true);
    const envBackend = `DATABASE_URL="mysql://${cfg.dbUser}:${cfg.dbPassword}@localhost:${cfg.dbPort}/${cfg.dbName}"
PORT=${cfg.backendPort}
`;
    fs.writeFileSync(path.join(projectDir, "backend", ".env"), envBackend);
    log("success", "backend/.env created");

    // 6) Generar frontend/.env.local
    log("info", "Generating frontend/.env.local…", true);
    const envFrontend = `VITE_API_URL=http://localhost:${cfg.backendPort}
`;
    fs.writeFileSync(
      path.join(projectDir, "frontend", ".env.local"),
      envFrontend
    );
    log("success", "frontend/.env.local created");

    // 7) Generar admin/.env.local
    log("info", "Generating admin/.env.local…", true);
    const envAdmin = `VITE_API_URL=http://localhost:${cfg.backendPort}
`;
    fs.writeFileSync(path.join(projectDir, "admin", ".env.local"), envAdmin);
    log("success", "admin/.env.local created");

    // 8) Instrucciones finales
    log("info", "You can now run:", true);
    log("info", `  cd ${cfg.name}`);
    log("info", "  npm run dev");
    log("success", "🚀 Project ready!");
  } catch (err) {
    log("error", "Unexpected error");
    console.error(err);
    process.exit(1);
  }
}

main();
