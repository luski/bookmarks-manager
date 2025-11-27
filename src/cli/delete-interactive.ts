#!/usr/bin/env node
import { execSync } from "node:child_process";
import { initDatabase } from "../db/database.js";
import * as BookmarkModel from "../models/bookmark.js";

initDatabase();

async function selectAndDelete() {
  const bookmarks = BookmarkModel.findAll();

  if (bookmarks.length === 0) {
    execSync(`notify-send 'No Bookmarks' 'No bookmarks to delete'`);
    process.exit(0);
  }

  // Create list for walker dmenu
  const options = bookmarks
    .map((b) => `${b.id}|${b.title}|${b.url}`)
    .join("\n");

  try {
    const result = execSync(
      `printf "${options.replace(/"/g, '\\"')}" | walker --dmenu`,
      { encoding: "utf-8", shell: "/bin/bash" },
    ).trim();

    if (!result) {
      console.log("Cancelled");
      process.exit(0);
    }

    // Parse selection
    const [id, title] = result.split("|");

    // Confirm deletion
    const confirm = execSync(
      `printf "Yes, delete '${title}'\nNo, cancel" | walker --dmenu`,
      { encoding: "utf-8", shell: "/bin/bash" },
    ).trim();

    if (confirm.startsWith("Yes")) {
      BookmarkModel.deleteBookmark(parseInt(id, 10));
      execSync(`notify-send '🗑️  Bookmark Deleted' '${title}'`);
      console.log(`Deleted: ${title}`);
    } else {
      execSync(`notify-send 'Cancelled' 'Bookmark not deleted'`);
    }
  } catch (_error) {
    console.log("Cancelled");
    process.exit(0);
  }
}

selectAndDelete();
