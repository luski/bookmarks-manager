#!/usr/bin/env node
import { execSync } from "node:child_process";
import { initDatabase } from "../db/database.js";
import * as BookmarkModel from "../models/bookmark.js";
import { downloadFavicon } from "../utils/favicon.js";

initDatabase();

async function promptInput(
  prompt: string,
  defaultValue: string = "",
  options: string[] = [],
): Promise<string> {
  try {
    // Create input with prompt as first line followed by options or default
    const input =
      options.length > 0
        ? `${prompt}\n${options.join("\n")}`
        : `${prompt}\n${defaultValue}`;

    const result = execSync(
      `printf "${input.replace(/"/g, '\\"')}" | walker --dmenu`,
      { encoding: "utf-8", shell: "/bin/bash" },
    ).trim();

    // Remove the prompt from result if user selected it
    return result === prompt ? "" : result;
  } catch (_error) {
    return "";
  }
}

async function addBookmarkInteractive() {
  try {
    // Get URL from clipboard
    let clipboardUrl = "";
    try {
      clipboardUrl = execSync("wl-paste", { encoding: "utf-8" }).trim();
    } catch {
      // Clipboard might be empty
    }

    // Validate if clipboard contains a URL
    const isUrl = clipboardUrl.match(/^https?:\/\//);
    const defaultUrl = isUrl ? clipboardUrl : "";

    // Step 1: Prompt for URL with helpful hint
    execSync(`notify-send 'Add Bookmark - Step 1/4' 'Enter the URL'`);
    const _urlOptions = [
      "📋 Enter or paste URL below:",
      defaultUrl || "https://example.com",
    ];

    const url = await promptInput(
      "🔗 Enter URL:",
      defaultUrl,
      defaultUrl ? [defaultUrl] : [],
    );
    if (!url || url.includes("Enter URL")) {
      execSync(`notify-send 'Cancelled' 'Bookmark creation cancelled'`);
      process.exit(0);
    }

    // Validate URL
    if (!url.match(/^https?:\/\//)) {
      execSync(
        `notify-send 'Invalid URL' 'URL must start with http:// or https://'`,
      );
      process.exit(1);
    }

    // Extract default title from URL (domain name)
    const defaultTitle = new URL(url).hostname.replace(/^www\./, "");

    // Step 2: Prompt for title
    execSync(
      `notify-send 'Add Bookmark - Step 2/4' 'Enter a title for: ${url.substring(0, 40)}...'`,
    );
    const title = await promptInput("📝 Enter Title:", defaultTitle, [
      defaultTitle,
    ]);
    if (!title || title.includes("Enter Title")) {
      execSync(`notify-send 'Cancelled' 'Bookmark creation cancelled'`);
      process.exit(0);
    }

    // Step 3: Prompt for description (optional)
    execSync(
      `notify-send 'Add Bookmark - Step 3/4' 'Enter description (or leave empty)'`,
    );
    const descOptions = ["💬 Description (optional - press Esc to skip)", ""];
    const description = await promptInput(
      "💬 Description (optional):",
      "",
      descOptions,
    );

    // Step 4: Prompt for tags (optional)
    execSync(
      `notify-send 'Add Bookmark - Step 4/4' 'Enter tags (or leave empty)'`,
    );
    const tagsOptions = [
      "🏷️  Tags (optional - space separated, press Esc to skip)",
      "",
    ];
    const tags = await promptInput("🏷️  Tags:", "", tagsOptions);

    // Show progress
    execSync(
      `notify-send 'Processing...' 'Downloading favicon and saving bookmark'`,
    );

    // Download favicon
    console.log("Downloading favicon...");
    const faviconPath = await downloadFavicon(url);

    // Create bookmark
    const bookmark = BookmarkModel.create({
      title,
      url,
      description:
        description && !description.includes("optional")
          ? description
          : undefined,
      tags: tags && !tags.includes("optional") ? tags : undefined,
      favicon: faviconPath,
    });

    execSync(
      `notify-send '✅ Bookmark Added!' '${title}' -i ${faviconPath || "bookmark"}`,
    );
    console.log("Bookmark added:", bookmark);
  } catch (error: unknown) {
    const errorMessage =
      error instanceof Error ? error.message : "Unknown error";
    if (errorMessage.includes("UNIQUE constraint failed")) {
      execSync(`notify-send 'Error' 'Bookmark already exists'`);
    } else {
      execSync(`notify-send 'Error' 'Failed to add bookmark: ${errorMessage}'`);
      console.error(error);
    }
    process.exit(1);
  }
}

addBookmarkInteractive();
