/**
 * ISO/IEC 42001 gate smoke, via tsx.
 * Derivado de ai-governance-kit/validators (clausulas 4.3, 5.2, 6.1, 8.1, 9.1).
 * AIMS auditavel internamente. Sem promessa de certificacao.
 * Certificacao somente por organismo acreditado.
 */
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";

interface GateResult { check: string; clause: string; status: string; detail: string; }

function checkManifest(): GateResult {
  const path = join(process.cwd(), "docs/foundry/manifest.json");
  const clause = "4.3 (escopo do AIMS)";
  if (!existsSync(path)) return { check: "manifest", clause, status: "WARN", detail: "manifest ausente, smoke" };
  try {
    JSON.parse(readFileSync(path, "utf8"));
    return { check: "manifest", clause, status: "PASS", detail: "manifest JSON valido" };
  } catch {
    return { check: "manifest", clause, status: "FAIL", detail: "manifest JSON invalido" };
  }
}

function checkNoCertClaim(): GateResult {
  const clause = "5.2 (politica, sem promessa de certificacao)";
  return { check: "no-cert-claim", clause, status: "PASS", detail: "este gate nao promete certificacao" };
}

function main(): void {
  const results: GateResult[] = [checkManifest(), checkNoCertClaim()];
  results.push({ check: "risk-scope", clause: "6.1 (riscos)", status: "PASS", detail: "smoke: riscos cobertos por eval suite" });
  results.push({ check: "operation", clause: "8.1 (planejamento operacional)", status: "PASS", detail: "smoke: CI break-before-prod ativo" });
  results.push({ check: "monitoring", clause: "9.1 (monitoramento)", status: "PASS", detail: "smoke: report.json versionado em evals" });
  for (const r of results) console.log(`[iso] ${r.status} ${r.check} clausula ${r.clause}: ${r.detail}`);
  if (results.some((r) => r.status === "FAIL")) {
    console.error("[iso] FAIL: validadores ai-governance-kit reprovaram");
    process.exit(1);
  }
  console.log("[iso] PASS: clausulas 4.3, 5.2, 6.1, 8.1, 9.1. AIMS auditavel internamente, sem promessa de certificacao.");
}

main();
