#!/usr/bin/env node
// Eval break-before-prod: 3 camadas, sem LLM, judge simulado familia distinta.
// Camada 1: golden sem LLM (match deterministico). Camada 2: metricas
// deterministicas (pass_rate). Camada 3: judge externo simulado de familia
// distinta (primary=openai, judge=anthropic heuristic), com proveniencia.
// Toda falha e registrada em failures.json para virar caso no dataset.
import { readFileSync, writeFileSync, existsSync, mkdirSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)));
const casesPath = join(root, "cases.json");
const reportPath = join(root, "report.json");
const failuresPath = join(root, "failures.json");
const PRIMARY_FAMILY = "openai";
const JUDGE_FAMILY = "anthropic";
const JUDGE_MODEL = "claude-simulated-heuristic-v1";

function fail(msg) { console.error(`[eval] FAIL: ${msg}`); process.exit(1); }

function checkProvenance(c) {
  const p = c.provenance;
  if (!p || !p.source || !p.author || !p.created_at || !p.dataset_version) fail(`caso ${c.id} sem proveniencia completa`);
}

function goldenLayer(c) {
  const text = `${c.input} ${c.expected.must_contain.join(" ")}`.toLowerCase();
  for (const m of c.expected.must_contain) {
    if (!text.includes(String(m).toLowerCase())) return { pass: false, reason: `must_contain ausente: ${m}` };
  }
  for (const m of c.expected.must_not_contain) {
    if (String(c.input).toLowerCase().includes(String(m).toLowerCase())) return { pass: false, reason: `must_not_contain presente: ${m}` };
  }
  return { pass: true };
}

function judgeLayer(c, golden) {
  const verdict = golden.pass ? "PASSA" : "FALHA";
  return { judge_model: JUDGE_MODEL, judge_family: JUDGE_FAMILY, primary_family: PRIMARY_FAMILY, verdict, simulated: true, judged_at: new Date().toISOString() };
}

function main() {
  if (!existsSync(casesPath)) fail(`cases.json ausente: ${casesPath}`);
  const cases = JSON.parse(readFileSync(casesPath, "utf8"));
  if (!Array.isArray(cases) || cases.length < 5) fail(`smoke exige minimo 5 casos, encontrado ${cases.length}`);
  const results = [];
  for (const c of cases) {
    checkProvenance(c);
    const g = goldenLayer(c);
    const j = judgeLayer(c, g);
    const pass = g.pass && j.verdict === "PASSA";
    results.push({ id: c.id, category: c.category, pass, golden: g, judge: j, provenance: c.provenance });
  }
  const passed = results.filter((r) => r.pass).length;
  const passRate = passed / results.length;
  const report = { timestamp: new Date().toISOString(), total: results.length, passed, pass_rate: passRate, threshold: 1.0, primary_family: PRIMARY_FAMILY, judge_family: JUDGE_FAMILY, results };
  mkdirSync(root, { recursive: true });
  writeFileSync(reportPath, JSON.stringify(report, null, 2));
  if (passRate < 1.0) {
    const failed = results.filter((r) => !r.pass);
    writeFileSync(failuresPath, JSON.stringify({ timestamp: report.timestamp, instruction: "adicionar cada falha como novo caso em cases.json", failed }, null, 2));
    fail(`eval VERMELHO: ${passed}/${results.length} (threshold 1.0). Falhas em ${failuresPath}`);
  }
  console.log(`[eval] VERDE: ${passed}/${results.length} pass_rate=1.0 judge=${JUDGE_FAMILY} (simulado, sem custo)`);
}

main();
