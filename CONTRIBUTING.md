# Contributing to Bookmarks Manager

Thank you for your interest in contributing to Bookmarks Manager! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Commit Message Guidelines](#commit-message-guidelines)

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for everyone.

## Getting Started

### Prerequisites

- Node.js 22.5.0 or later (for native SQLite support)
- npm (comes with Node.js)
- Git

### Setup Development Environment

1. Fork the repository on GitHub
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/bookmarks-manager.git
   cd bookmarks-manager
   ```

3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/luski/bookmarks-manager.git
   ```

4. Install dependencies:
   ```bash
   npm install
   ```

5. Initialize the database:
   ```bash
   npm run db:migrate
   ```

6. Build the project:
   ```bash
   npm run build
   ```

## Development Workflow

### Creating a Feature Branch

Always create a new branch for your work:

```bash
git checkout master
git pull upstream master
git checkout -b feature/your-feature-name
```

Branch naming conventions:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation changes
- `refactor/` - Code refactoring
- `chore/` - Maintenance tasks

### Running in Development Mode

```bash
npm run dev
```

### Making Changes

1. Write your code following our [coding standards](#coding-standards)
2. Test your changes thoroughly
3. Run linting and formatting:
   ```bash
   npm run check
   ```
4. Build and verify:
   ```bash
   npm run build
   npm run db:migrate
   npm run bookmarks list
   ```

## Pull Request Process

1. **Update your fork** with the latest changes from upstream:
   ```bash
   git checkout master
   git pull upstream master
   git checkout your-feature-branch
   git rebase master
   ```

2. **Run all checks** before submitting:
   ```bash
   npm run ci          # Linting and formatting
   npm run build       # Build check
   npx tsc --noEmit    # Type check
   ```

3. **Push your changes**:
   ```bash
   git push origin feature/your-feature-name
   ```

4. **Create a Pull Request** on GitHub:
   - Use a clear, descriptive title
   - Reference any related issues
   - Describe what changes you made and why
   - Include screenshots if relevant (especially for UI changes)

5. **Wait for review**:
   - Address any feedback from reviewers
   - Keep your PR up to date with master
   - Be responsive to comments

6. **After approval**, your PR will be merged!

## Coding Standards

### TypeScript

- Use TypeScript for all new code
- Enable strict type checking
- Avoid `any` types - use `unknown` with type guards instead
- Export types and interfaces when they might be reused

### Code Style

We use [Biome](https://biomejs.dev/) for linting and formatting:

- 2-space indentation
- Double quotes for strings
- Semicolons required
- Trailing commas in multi-line structures

Run formatting:
```bash
npm run format
```

Run linting:
```bash
npm run lint
```

Run both:
```bash
npm run check
```

### File Organization

```
src/
├── db/           # Database-related code
├── models/       # Data models and operations
├── cli/          # CLI tools
└── utils/        # Utility functions
```

### Best Practices

- **DRY (Don't Repeat Yourself)**: Extract common logic into functions
- **Single Responsibility**: Each function should do one thing well
- **Clear Naming**: Use descriptive variable and function names
- **Comments**: Explain "why", not "what" (code should be self-documenting)
- **Error Handling**: Always handle errors gracefully
- **Type Safety**: Leverage TypeScript's type system

## Testing

### Manual Testing

Test database operations:
```bash
# Add a bookmark
npm run bookmarks add "https://example.com" "Example" "Test bookmark" "test"

# List bookmarks
npm run bookmarks list

# Search bookmarks
npm run bookmarks search "test"

# Delete bookmark
npm run bookmarks delete 1
```

### Interactive CLI Testing

```bash
# Interactive add
npm run add

# Interactive delete
npm run delete
```

### CI Testing

All pull requests automatically run:
- Linting and formatting checks
- TypeScript type checking
- Build verification
- Database operation tests
- Multi-version Node.js tests

## Commit Message Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/):

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `chore`: Maintenance tasks
- `ci`: CI/CD changes
- `test`: Adding or updating tests

### Examples

```
feat(cli): add interactive bookmark editing

Add new interactive CLI command for editing existing bookmarks.
Users can now modify title, URL, description, and tags.

Closes #123
```

```
fix(database): handle null favicon paths correctly

Previously, null favicon paths caused errors during bookmark listing.
Now properly handles null values with fallback to default icon.
```

```
docs: update installation instructions for Node.js 22.5+

Update README and INSTALL.md to reflect new minimum Node.js version
requirement for native SQLite support.
```

## Questions or Problems?

- **Bug Reports**: Open an issue with detailed reproduction steps
- **Feature Requests**: Open an issue describing the feature and use case
- **Questions**: Open a discussion or issue

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Thank You!

Your contributions make this project better for everyone. Thank you for taking the time to contribute! 🎉