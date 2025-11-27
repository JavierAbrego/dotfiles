#!/usr/bin/env node

import { execFileSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";

// 1) Obtener cURL pasado como argumento
const cliArgs = process.argv.slice(2);

if (!cliArgs.length || cliArgs[0] !== "curl") {
  console.error("❌ Debes pasar un comando curl entre comillas");
  process.exit(1);
}

const curlArgs = cliArgs.slice(1);

// 2) Ejecutar el cURL y capturar el response
let response = "";
try {
  response = execFileSync("curl", curlArgs, { encoding: "utf8" });
} catch (e) {
  response = e.stdout || e.stderr || String(e);
}

// 3) Extraer la URL
const urlArg = curlArgs.find(arg => /^https?:\/\//.test(arg));

if (!urlArg) {
  console.error("❌ No se pudo extraer la URL del comando curl");
  process.exit(1);
}

const url = urlArg;
const parsed = new URL(url);

// 4) Construir un nombre de archivo basado en el endpoint
let fileName = parsed.pathname.replace(/\/$/, "").replace(/\//g, "-");
fileName = fileName || "request";
fileName = fileName.replace(/^-/, "");

fileName += ".http";

// 5) Convertir cURL → request .http
function convertCurlToHttp(tokens, response, url) {
  let method = "GET";
  const headers = [];
  let body = "";

  for (let i = 0; i < tokens.length; i++) {
    const token = tokens[i];
    const next = tokens[i + 1];

    if ((token === "-X" || token === "--request") && next) {
      method = next;
      i++;
      continue;
    }

    if ((token === "-H" || token === "--header") && next) {
      headers.push(next);
      i++;
      continue;
    }

    const isDataFlag =
      token === "-d" ||
      token === "--data" ||
      token === "--data-raw" ||
      token === "--data-binary" ||
      token.startsWith("--data-");

    if (isDataFlag && next) {
      body = next;
      i++;
    }
  }

  // Pretty-print JSON si es posible
  let prettyResponse = response;
  try {
    prettyResponse = JSON.stringify(JSON.parse(response), null, 2);
  } catch (_) {}

  let http = `${method} ${url}\n`;
  headers.forEach(h => (http += h + "\n"));

  if (body) http += `\n${body}\n`;

  http += `\n### Response\n\n${prettyResponse}\n`;

  return http;
}

const httpContent = convertCurlToHttp(curlArgs, response, url);

// 6) Guardar archivo en el directorio actual (PWD)
const outputPath = path.join(process.cwd(), fileName);
fs.writeFileSync(outputPath, httpContent, "utf8");

console.log(`✅ Archivo creado: ${outputPath}`);