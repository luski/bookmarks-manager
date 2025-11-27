#!/usr/bin/env node
import * as BookmarkModel from "../models/bookmark.js";

const args = process.argv.slice(2);
const command = args[0];

switch (command) {
  case "search": {
    const query = args[1] || "";
    const results = BookmarkModel.search(query);
    console.log(JSON.stringify(results, null, 2));
    break;
  }

  case "list": {
    const bookmarks = BookmarkModel.findAll();
    console.log(JSON.stringify(bookmarks, null, 2));
    break;
  }

  default:
    console.error("Usage: walker.js <search|list> [query]");
    process.exit(1);
}
