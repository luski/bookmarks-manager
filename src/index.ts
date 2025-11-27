import { initDatabase } from "./db/database.js";
import * as BookmarkModel from "./models/bookmark.js";

initDatabase();

console.log("Bookmarks Manager Backend");
console.log("Database initialized and ready");

const bookmarks = BookmarkModel.findAll();
console.log(`Total bookmarks: ${bookmarks.length}`);
