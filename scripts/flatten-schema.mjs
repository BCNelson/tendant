#!/usr/bin/env node
// Flatten the server GraphQL SDL for the Flutter ferry client.
//
// ferry's bundled gql_code_builder does NOT merge `extend type X { ... }` into
// the base `type X { ... }` — a field left in an extend block fails codegen with
// `_getFieldTypeNode: Bad state: No element`. This folds every `extend type`
// into its base type so the client schema is a single definition per type.
//
// Usage: node scripts/flatten-schema.mjs <out.graphql> <in1.graphqls> [in2 ...]
import { readFileSync, writeFileSync } from 'node:fs';

const [outPath, ...inPaths] = process.argv.slice(2);
if (!outPath || inPaths.length === 0) {
  console.error('usage: flatten-schema.mjs <out> <in...>');
  process.exit(2);
}

const text = inPaths.map((p) => readFileSync(p, 'utf8')).join('\n');
const lines = text.split('\n');

// Scan top-level (extend) type blocks by brace depth.
const blocks = [];
for (let i = 0; i < lines.length; ) {
  const m = lines[i].match(/^\s*(extend\s+)?type\s+(\w+)/);
  if (!m) { i++; continue; }
  let depth = 0;
  let started = false;
  let j = i;
  const buf = [];
  while (j < lines.length) {
    for (const ch of lines[j]) {
      if (ch === '{') { depth++; started = true; }
      else if (ch === '}') { depth--; }
    }
    buf.push(lines[j]);
    j++;
    if (started && depth === 0) break;
  }
  blocks.push({
    isExtend: !!m[1],
    name: m[2],
    start: i,
    end: j - 1,
    text: buf.join('\n'),
  });
  i = j;
}

const innerOf = (t) => t.slice(t.indexOf('{') + 1, t.lastIndexOf('}'));
const headerOf = (t) => t.slice(0, t.indexOf('{')).trim();

// Which type names are extended, and the merged inner field text per name.
const extended = new Set(blocks.filter((b) => b.isExtend).map((b) => b.name));
const innerParts = new Map(); // name -> [inner, ...] in document order
const baseHeader = new Map(); // name -> "type X implements Y"
for (const b of blocks) {
  if (!extended.has(b.name)) continue;
  if (!innerParts.has(b.name)) innerParts.set(b.name, []);
  innerParts.get(b.name).push(innerOf(b.text));
  if (!b.isExtend) baseHeader.set(b.name, headerOf(b.text));
}

const blockAt = new Map(blocks.map((b) => [b.start, b]));
const emittedMerge = new Set();
const out = [];
for (let i = 0; i < lines.length; ) {
  const b = blockAt.get(i);
  if (!b) { out.push(lines[i]); i++; continue; }
  if (!extended.has(b.name)) {
    out.push(b.text); // untouched type — emit verbatim
  } else if (!emittedMerge.has(b.name)) {
    // Emit the merged definition at the first block we hit for this name.
    const header = baseHeader.get(b.name) ?? `type ${b.name}`;
    const fields = innerParts.get(b.name).join('\n').replace(/\n{2,}/g, '\n');
    out.push(`${header} {${fields}}`);
    emittedMerge.add(b.name);
  } // subsequent blocks for an already-merged name: skip
  i = b.end + 1;
}

writeFileSync(outPath, out.join('\n').replace(/\n{3,}/g, '\n\n'));
console.error(`flattened ${blocks.length} type blocks (${extended.size} merged) → ${outPath}`);
