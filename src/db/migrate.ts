import { initDatabase } from './database.js';

console.log('Running database migrations...');
initDatabase();
console.log('Database initialized successfully!');
process.exit(0);
