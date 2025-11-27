import { db } from "../db/database.js";

export interface Bookmark {
  id?: number;
  title: string;
  url: string;
  description?: string;
  tags?: string;
  favicon?: string;
  created_at?: string;
  updated_at?: string;
}

export function create(
  bookmark: Omit<Bookmark, "id" | "created_at" | "updated_at">,
): Bookmark {
  const stmt = db.prepare(`
    INSERT INTO bookmarks (title, url, description, tags, favicon)
    VALUES (?, ?, ?, ?, ?)
  `);

  const result = stmt.run(
    bookmark.title,
    bookmark.url,
    bookmark.description || null,
    bookmark.tags || null,
    bookmark.favicon || null,
  );

  const created = findById(Number(result.lastInsertRowid));

  if (!created) {
    throw new Error("Failed to create bookmark");
  }

  return created;
}

export function findAll(): Bookmark[] {
  const stmt = db.prepare("SELECT * FROM bookmarks ORDER BY created_at DESC");
  return stmt.all() as unknown as Bookmark[];
}

export function findById(id: number): Bookmark | undefined {
  const stmt = db.prepare("SELECT * FROM bookmarks WHERE id = ?");
  return stmt.get(id) as unknown as Bookmark | undefined;
}

export function search(query: string): Bookmark[] {
  const stmt = db.prepare(`
    SELECT * FROM bookmarks
    WHERE title LIKE ? OR url LIKE ? OR description LIKE ? OR tags LIKE ?
    ORDER BY created_at DESC
  `);
  const searchTerm = `%${query}%`;
  return stmt.all(
    searchTerm,
    searchTerm,
    searchTerm,
    searchTerm,
  ) as unknown as Bookmark[];
}

export function update(
  id: number,
  bookmark: Partial<Bookmark>,
): Bookmark | undefined {
  const fields = Object.keys(bookmark).filter((k) => k !== "id");
  const setClause = fields.map((f) => `${f} = ?`).join(", ");
  const values = fields.map((f) => bookmark[f as keyof Bookmark] ?? null);

  const stmt = db.prepare(`
    UPDATE bookmarks
    SET ${setClause}, updated_at = CURRENT_TIMESTAMP
    WHERE id = ?
  `);

  stmt.run(...values, id);
  return findById(id);
}

export function deleteBookmark(id: number): boolean {
  const stmt = db.prepare("DELETE FROM bookmarks WHERE id = ?");
  const result = stmt.run(id);
  return result.changes > 0;
}
