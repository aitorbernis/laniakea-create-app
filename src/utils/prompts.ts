import inquirer from "inquirer";

export interface Answers {
  name: string;
  httpPort: number;
  adminPort: number;
  backendPort: number;
  dbPort: number;
  dbRootPassword: string;
  dbName: string;
  dbUser: string;
  dbPassword: string;
}

export async function askConfig(): Promise<Answers> {
  const questions = [
    {
      type: "input",
      name: "name",
      message: "Project name:",
      validate: (v: string) =>
        v.trim() !== "" || "You must provide a project name.",
    },
    {
      type: "input",
      name: "httpPort",
      message: "HTTP port for frontend:",
      default: "3000",
      filter: (v: string) => parseInt(v, 10),
    },
    {
      type: "input",
      name: "adminPort",
      message: "HTTP port for admin:",
      default: "3001",
      filter: (v: string) => parseInt(v, 10),
    },
    {
      type: "input",
      name: "backendPort",
      message: "Port for backend:",
      default: "8000",
      filter: (v: string) => parseInt(v, 10),
    },
    {
      type: "input",
      name: "dbPort",
      message: "MariaDB port:",
      default: "3306",
      filter: (v: string) => parseInt(v, 10),
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

  const answers = (await inquirer.prompt(questions as any)) as Answers;
  return answers;
}
