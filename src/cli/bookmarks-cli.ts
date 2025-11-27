#!/usr/bin/env node
import { initDatabase } from "../db/database.js";
import * as BookmarkModel from "../models/bookmark.js";

initDatabase();

const command = process.argv[2];
const arg = process.argv[3];

if (command === "list") {
  const bookmarks = BookmarkModel.findAll();
  bookmarks.forEach((b) => {
    const tags = b.tags ? ` [${b.tags}]` : "";
    console.log(`${b.id}|${b.title}|${b.url}|${b.description || ""}${tags}`);
  });
} else if (command === "search") {
  const query = arg || "";
  const results = BookmarkModel.search(query);
  results.forEach((b) => {
    const tags = b.tags ? ` [${b.tags}]` : "";
    console.log(`${b.id}|${b.title}|${b.url}|${b.description || ""}${tags}`);
  });
} else if (command === "add") {
  const url = arg;
  const title = process.argv[4] || url;
  const description = process.argv[5] || "";
  const tags = process.argv[6] || "";

  try {
    const bookmark = BookmarkModel.create({ title, url, description, tags });
    console.log(`Added: ${bookmark.title}`);
  } catch (error) {
    console.error(`Error: ${error}`);
    process.exit(1);
  }
} else if (command === "delete") {
  const id = parseInt(arg, 10);
  const success = BookmarkModel.deleteBookmark(id);
  console.log(success ? "Deleted" : "Not found");
} else {
  console.error("Usage: bookmarks-cli <list|search|add|delete> [args]");
  process.exit(1);
}
