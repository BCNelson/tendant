#!/usr/bin/env node
// fingerprint-web.mjs — give the per-build Flutter web output files content-hashed
// names so they can be cached immutably (the server then serves everything but
// index.html with `immutable`; see services/api/internal/webui/webui.go).
//
// Flutter has no native fingerprinting (its web FAQ recommends a manual `?v=`
// query or rename), so this post-build step renames every file that changes on
// each app build and rewrites the references that point at it:
//
//   main.dart.js                 -> main.<hash>.js
//   main.dart.js_<n>.part.js     -> main.dart.js_<n>.<hash>.part.js   (deferred chunks)
//   flutter_bootstrap.js         -> flutter_bootstrap.<hash>.js
//
// References: deferred `*.part.js` chunks are named inside main.dart.js, the
// hashed main is named inside flutter_bootstrap.js, and the hashed bootstrap is
// named in index.html's <script src>. canvaskit/ and assets/ keep their names —
// those references live in minified engine code / binary manifests, and change
// only on an SDK/asset edit (rare); they are cached immutably and a fresh deploy
// hash is the escape hatch if one ever changes.
//
// The script fails loudly on an output shape it cannot fingerprint safely (e.g.
// a `--wasm` build with main.dart.wasm, or a split chunk it can't find a
// reference for) rather than silently shipping a stale immutable-cached file.
//
// Usage: node scripts/fingerprint-web.mjs <build/web dir>

import { readFileSync, writeFileSync, renameSync, existsSync, readdirSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { join } from 'node:path';

const dir = process.argv[2];
if (!dir) {
  console.error('usage: fingerprint-web.mjs <build/web dir>');
  process.exit(2);
}

const fail = (msg) => {
  console.error(`fingerprint-web: ${msg}`);
  process.exit(1);
};

const hash = (buf) => createHash('sha256').update(buf).digest('hex').slice(0, 12);

// Guard: a --wasm build has no main.dart.js (main.dart.wasm + main.dart.mjs
// instead). This script targets the dart2js output; bail clearly if that
// assumption no longer holds so a misconfigured build can't ship stale chunks.
if (!existsSync(join(dir, 'main.dart.js'))) {
  fail('main.dart.js not found — a non-dart2js (e.g. --wasm) build is not handled; update this script.');
}

// 1. Read main.dart.js as text so deferred-chunk references can be rewritten.
let main = readFileSync(join(dir, 'main.dart.js'), 'utf8');

// 2. Fingerprint deferred-loading chunks (main.dart.js_<n>.part.js), rewriting
//    their baked references inside main.dart.js. Longest names first so a short
//    chunk name can't be a substring of a longer one during replacement.
const parts = readdirSync(dir)
  .filter((f) => f.endsWith('.part.js'))
  .sort((a, b) => b.length - a.length);
for (const part of parts) {
  if (!main.includes(part)) {
    fail(`split chunk ${part} is not referenced in main.dart.js — cannot fingerprint it safely.`);
  }
  const hashed = part.replace(/\.part\.js$/, `.${hash(readFileSync(join(dir, part)))}.part.js`);
  renameSync(join(dir, part), join(dir, hashed));
  main = main.replaceAll(part, hashed);
}
writeFileSync(join(dir, 'main.dart.js'), main);

// 3. Hash main.dart.js itself (now with rewritten chunk refs) and rename it.
const mainHashed = `main.${hash(Buffer.from(main))}.js`;
renameSync(join(dir, 'main.dart.js'), join(dir, mainHashed));

// 4. Repoint the bootstrap at the hashed main, then hash the bootstrap. All
//    `"main.dart.js"` literals (entrypointUrl, mainJsPath fallback + value) move
//    together, so replaceAll is intended.
const bootPath = join(dir, 'flutter_bootstrap.js');
if (!existsSync(bootPath)) fail('flutter_bootstrap.js not found.');
let boot = readFileSync(bootPath, 'utf8');
if (!boot.includes('main.dart.js')) {
  fail('no "main.dart.js" reference in flutter_bootstrap.js — Flutter output changed; update this script.');
}
boot = boot.replaceAll('main.dart.js', mainHashed);
writeFileSync(bootPath, boot);
const bootHashed = `flutter_bootstrap.${hash(Buffer.from(boot))}.js`;
renameSync(bootPath, join(dir, bootHashed));

// 5. Repoint index.html's <script src> at the hashed bootstrap (anchored on
//    src= so the explanatory HTML comment is left untouched).
const indexPath = join(dir, 'index.html');
if (!existsSync(indexPath)) fail('index.html not found.');
let html = readFileSync(indexPath, 'utf8');
const srcRef = 'src="flutter_bootstrap.js"';
if (!html.includes(srcRef)) {
  fail('no <script src="flutter_bootstrap.js"> in index.html — Flutter output changed; update this script.');
}
html = html.replace(srcRef, `src="${bootHashed}"`);
writeFileSync(indexPath, html);

console.log(`fingerprint-web: ${mainHashed}, ${bootHashed}` + (parts.length ? `, ${parts.length} deferred chunk(s)` : ''));
