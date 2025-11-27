import { createWriteStream } from 'fs';
import { mkdir } from 'fs/promises';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import https from 'https';
import http from 'http';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const FAVICON_DIR = join(__dirname, '../../favicons');

export async function ensureFaviconDir() {
  try {
    await mkdir(FAVICON_DIR, { recursive: true });
  } catch (error) {
    // Directory might already exist
  }
}

export async function downloadFavicon(url: string): Promise<string | undefined> {
  try {
    await ensureFaviconDir();
    
    const urlObj = new URL(url);
    const domain = urlObj.hostname;
    
    // Try different favicon URLs
    const faviconUrls = [
      `${urlObj.protocol}//${domain}/favicon.ico`,
      `https://www.google.com/s2/favicons?domain=${domain}&sz=64`,
      `https://icons.duckduckgo.com/ip3/${domain}.ico`
    ];
    
    for (const faviconUrl of faviconUrls) {
      const faviconPath = join(FAVICON_DIR, `${domain}.png`);
      
      try {
        const downloaded = await downloadFile(faviconUrl, faviconPath);
        if (downloaded) {
          return faviconPath;
        }
      } catch (error) {
        continue; // Try next URL
      }
    }
    
    return undefined;
  } catch (error) {
    console.error('Error downloading favicon:', error);
    return undefined;
  }
}

function downloadFile(url: string, dest: string): Promise<boolean> {
  return new Promise((resolve, reject) => {
    const protocol = url.startsWith('https') ? https : http;
    
    protocol.get(url, (response) => {
      if (response.statusCode === 200) {
        const file = createWriteStream(dest);
        response.pipe(file);
        file.on('finish', () => {
          file.close();
          resolve(true);
        });
      } else if (response.statusCode === 301 || response.statusCode === 302) {
        // Follow redirect
        if (response.headers.location) {
          downloadFile(response.headers.location, dest)
            .then(resolve)
            .catch(reject);
        } else {
          resolve(false);
        }
      } else {
        resolve(false);
      }
    }).on('error', (err) => {
      reject(err);
    });
  });
}
