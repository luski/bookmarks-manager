import { db } from '../db/database.js';

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

export class BookmarkModel {
  static create(bookmark: Omit<Bookmark, 'id' | 'created_at' | 'updated_at'>): Bookmark {
    const stmt = db.prepare(`
      INSERT INTO bookmarks (title, url, description, tags, favicon)
      VALUES (@title, @url, @description, @tags, @favicon)
    `);
    
    const result = stmt.run(bookmark);
    return this.findById(result.lastInsertRowid as number)!;
  }

  static findAll(): Bookmark[] {
    const stmt = db.prepare('SELECT * FROM bookmarks ORDER BY created_at DESC');
    return stmt.all() as Bookmark[];
  }

  static findById(id: number): Bookmark | undefined {
    const stmt = db.prepare('SELECT * FROM bookmarks WHERE id = ?');
    return stmt.get(id) as Bookmark | undefined;
  }

  static search(query: string): Bookmark[] {
    const stmt = db.prepare(`
      SELECT * FROM bookmarks 
      WHERE title LIKE ? OR url LIKE ? OR description LIKE ? OR tags LIKE ?
      ORDER BY created_at DESC
    `);
    const searchTerm = `%${query}%`;
    return stmt.all(searchTerm, searchTerm, searchTerm, searchTerm) as Bookmark[];
  }

  static update(id: number, bookmark: Partial<Bookmark>): Bookmark | undefined {
    const fields = Object.keys(bookmark).filter(k => k !== 'id');
    const setClause = fields.map(f => `${f} = @${f}`).join(', ');
    
    const stmt = db.prepare(`
      UPDATE bookmarks 
      SET ${setClause}, updated_at = CURRENT_TIMESTAMP
      WHERE id = @id
    `);
    
    stmt.run({ ...bookmark, id });
    return this.findById(id);
  }

  static delete(id: number): boolean {
    const stmt = db.prepare('DELETE FROM bookmarks WHERE id = ?');
    const result = stmt.run(id);
    return result.changes > 0;
  }
}
