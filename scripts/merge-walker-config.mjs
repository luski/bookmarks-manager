#!/usr/bin/env node

/**
 * Merge the repository's Walker config template into the user's existing
 * ~/.config/walker/config.toml in a safe, TOML-aware way.
 *
 * Strategy:
 *  - Parse existing user config (if any) and template config.
 *  - Merge with user config taking precedence on conflicts.
 *  - For [providers]:
 *      - default: union of user + template entries (no duplicates).
 *      - prefixes: union by (prefix, provider) pair.
 *      - actions: for each key (e.g. "menus:bookmarks"), add template actions
 *        whose `action` field is not already present in the user list.
 *  - For other top-level keys: copy from template only if missing in user.
 *
 * Requirements:
 *  - Node 18+ (for import.meta and built-in modules).
 *  - A TOML library installed as a dependency, e.g.:
 *      npm install @iarna/toml
 *
 * This script is intended to be invoked from the project root or via
 * scripts/setup-walker-integration.sh.
 */

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import * as toml from "@iarna/toml";

const PROJECT_ROOT = path.resolve(
  path.join(path.dirname(new URL(import.meta.url).pathname), ".."),
);
const CONFIG_DIR = path.join(PROJECT_ROOT, "config");
const TEMPLATE_PATH = path.join(CONFIG_DIR, "walker-template.toml");
const WALKER_CONFIG_DIR = path.join(os.homedir(), ".config", "walker");
const WALKER_CONFIG_PATH = path.join(WALKER_CONFIG_DIR, "config.toml");

function ensureDir(dirPath) {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }
}

function readTomlIfExists(filePath) {
  if (!fs.existsSync(filePath)) return {};
  const content = fs.readFileSync(filePath, "utf8");
  if (!content.trim()) return {};
  return toml.parse(content);
}

function mergeArrayUnique(base, extra) {
  const result = Array.isArray(base) ? [...base] : [];
  const seen = new Set(result);
  for (const item of extra || []) {
    if (!seen.has(item)) {
      result.push(item);
      seen.add(item);
    }
  }
  return result;
}

/**
 * Merge [[providers.prefixes]] arrays:
 * - Identify entries by (prefix, provider).
 * - Preserve all user entries.
 * - Add template entries that don't exist in user config yet.
 */
function mergePrefixes(userPrefixes, templatePrefixes) {
  const result = Array.isArray(userPrefixes) ? [...userPrefixes] : [];
  const tmpl = Array.isArray(templatePrefixes) ? templatePrefixes : [];

  const hasEntry = (p) =>
    result.some((x) => x && x.prefix === p.prefix && x.provider === p.provider);

  for (const p of tmpl) {
    if (!p || typeof p !== "object") continue;
    if (!hasEntry(p)) {
      result.push(p);
    }
  }

  return result;
}

/**
 * Merge [providers.actions] tables:
 * - For each key ("menus:bookmarks", etc.):
 *   - If user is missing the key, copy template list entirely.
 *   - If user has the key, add template actions with a distinct `action`
 *     field that does not already appear in the user's list.
 */
function mergeActions(userActions, templateActions) {
  const user =
    userActions && typeof userActions === "object" ? userActions : {};
  const tmpl =
    templateActions && typeof templateActions === "object"
      ? templateActions
      : {};
  const result = { ...user };

  for (const [key, tmplListRaw] of Object.entries(tmpl)) {
    const tmplList = Array.isArray(tmplListRaw) ? tmplListRaw : [];
    const userListRaw = user[key];

    if (!userListRaw) {
      // Entire key missing: take template list
      result[key] = tmplList;
      continue;
    }

    const userList = Array.isArray(userListRaw) ? userListRaw : [];
    const merged = [...userList];

    const existingActions = new Set(
      userList
        .map((entry) =>
          entry && typeof entry === "object" ? entry.action : undefined,
        )
        .filter((a) => typeof a === "string"),
    );

    for (const act of tmplList) {
      if (!act || typeof act !== "object") continue;
      const name = act.action;
      if (!name || typeof name !== "string") continue;
      if (existingActions.has(name)) continue;
      merged.push(act);
      existingActions.add(name);
    }

    result[key] = merged;
  }

  return result;
}

/**
 * Merge user and template Walker configs.
 * - User config is the base.
 * - Template config fills gaps and extends arrays/tables under [providers].
 */
function mergeConfigs(userConfig, templateConfig) {
  const user = userConfig && typeof userConfig === "object" ? userConfig : {};
  const tmpl =
    templateConfig && typeof templateConfig === "object" ? templateConfig : {};
  const merged = { ...user };

  // Special handling for [providers]
  if (tmpl.providers && typeof tmpl.providers === "object") {
    const userProv =
      merged.providers && typeof merged.providers === "object"
        ? merged.providers
        : {};
    const tmplProv = tmpl.providers;

    // default providers array
    if (Array.isArray(tmplProv.default)) {
      userProv.default = mergeArrayUnique(userProv.default, tmplProv.default);
    }

    // [[providers.prefixes]]
    if (Array.isArray(tmplProv.prefixes)) {
      userProv.prefixes = mergePrefixes(userProv.prefixes, tmplProv.prefixes);
    }

    // [providers.actions]
    if (tmplProv.actions && typeof tmplProv.actions === "object") {
      userProv.actions = mergeActions(userProv.actions, tmplProv.actions);
    }

    merged.providers = userProv;
  }

  // Copy any other top-level template keys that user is missing
  for (const [key, value] of Object.entries(tmpl)) {
    if (key === "providers") continue; // already handled specially
    if (merged[key] === undefined) {
      merged[key] = value;
    }
  }

  return merged;
}

function backupIfExists(filePath) {
  if (!fs.existsSync(filePath)) return null;
  const backupPath = `${filePath}.backup.${Date.now()}`;
  fs.copyFileSync(filePath, backupPath);
  return backupPath;
}

function main() {
  console.log("=== Merging Walker configuration with template ===");

  ensureDir(WALKER_CONFIG_DIR);

  if (!fs.existsSync(TEMPLATE_PATH)) {
    console.error(`Template TOML not found at: ${TEMPLATE_PATH}`);
    process.exit(1);
  }

  const userConfig = readTomlIfExists(WALKER_CONFIG_PATH);
  const templateConfig = readTomlIfExists(TEMPLATE_PATH);

  const backupPath = backupIfExists(WALKER_CONFIG_PATH);
  if (backupPath) {
    console.log(`  ✓ Backed up existing Walker config to: ${backupPath}`);
  } else {
    console.log("  ⚠ No existing Walker config found, creating a new one.");
  }

  const mergedConfig = mergeConfigs(userConfig, templateConfig);
  const outputToml = toml.stringify(mergedConfig);
  fs.writeFileSync(WALKER_CONFIG_PATH, outputToml);

  console.log(`  ✓ Updated Walker config at: ${WALKER_CONFIG_PATH}`);
  console.log("=== Walker configuration merge complete ===");
}

main();
