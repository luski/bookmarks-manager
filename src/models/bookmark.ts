import { db } from "../db/database.js";

export interface Bookmark {
  id?: number;
  title: string;
  url: string;
  description?: string;
  tags?: string;
  created_at?: string;
  updated_at?: string;
}

export function create(
  bookmark: Omit<Bookmark, "id" | "created_at" | "updated_at">,
): Bookmark {
  const stmt = db.prepare(`
    INSERT INTO bookmarks (title, url, description, tags)
    VALUES (@title, @url, @description, @tags)
  `);

  const result = stmt.run(bookmark);
  const created = findById(result.lastInsertRowid as number);

  if (!created) {
    throw new Error("Failed to create bookmark");
  }

  return created;
}

export function findAll(): Bookmark[] {
  const stmt = db.prepare("SELECT * FROM bookmarks ORDER BY created_at DESC");
  return stmt.all() as Bookmark[];
}

export function findById(id: number): Bookmark | undefined {
  const stmt = db.prepare("SELECT * FROM bookmarks WHERE id = ?");
  return stmt.get(id) as Bookmark | undefined;
}

export function search(query: string): Bookmark[] {
  const stmt = db.prepare(`
    SELECT * FROM bookmarks
    WHERE title LIKE ? OR url LIKE ? OR description LIKE ? OR tags LIKE ?
    ORDER BY created_at DESC
  `);
  const searchTerm = `%${query}%`;
  return stmt.all(searchTerm, searchTerm, searchTerm, searchTerm) as Bookmark[];
}

export function update(
  id: number,
  bookmark: Partial<Bookmark>,
): Bookmark | undefined {
  const fields = Object.keys(bookmark).filter((k) => k !== "id");
  const setClause = fields.map((f) => `${f} = @${f}`).join(", ");

  const stmt = db.prepare(`
    UPDATE bookmarks
    SET ${setClause}, updated_at = CURRENT_TIMESTAMP
    WHERE id = @id
  `);

  stmt.run({ ...bookmark, id });
  return findById(id);
}

export function deleteBookmark(id: number): boolean {
  const stmt = db.prepare("DELETE FROM bookmarks WHERE id = ?");
  const result = stmt.run(id);
  return result.changes > 0;
}
