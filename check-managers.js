// SPDX-License-Identifier: BSD-2-Clause
// SPDX-FileCopyrightText: 2026 Aryan Ameri <github@aryan.ameri.coffee>

// Fails when a matchManagers value in the given Renovate configs names no
// manager. The validator checks the shape of a config but not these values,
// and Renovate's runtime ignores an unknown one, so a rule resting on a
// misspelt name never fires. Run by `just validate` inside the pinned
// Renovate image, so the list is that image's own.
//
// Usage: node check-managers.js <config.json>...
// Exit codes: 0 every name is known, 1 at least one is not, 2 usage error.

const fs = require("node:fs");
const { getManagerList } = require("/usr/local/renovate/dist/modules/manager/index.js");

const known = new Set(getManagerList());
const files = process.argv.slice(2);
if (files.length === 0) {
  console.error("usage: node check-managers.js <config.json>...");
  process.exit(2);
}

// Every matchManagers array anywhere in the config, wherever a rule nests it.
function* managers(node) {
  if (Array.isArray(node)) {
    for (const item of node) yield* managers(item);
  } else if (node && typeof node === "object") {
    for (const [key, value] of Object.entries(node)) {
      if (key === "matchManagers" && Array.isArray(value)) yield* value;
      else yield* managers(value);
    }
  }
}

let bad = 0;
for (const file of files) {
  for (const name of managers(JSON.parse(fs.readFileSync(file, "utf8")))) {
    // A leading "!" negates; custom.regex and custom.jsonata are the custom managers
    const bare = String(name).replace(/^!/, "");
    if (!known.has(bare) && !bare.startsWith("custom.")) {
      console.error(`${file}: matchManagers names no manager: ${name}`);
      bad = 1;
    }
  }
}
process.exit(bad);
