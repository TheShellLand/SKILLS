# SKILLS.md

## Skills Library

### 1. Version Control & Git
*Specific protocols for managing history and branch state.*

#### **Standard Commit Messages**
- **Format**: Conventional Commits (e.g., `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`).
- **Structure**:
  - First line: Short summary (max 50 chars).
  - Optional Body: Detailed explanation of *why* the change was made and how it affects the system.
  - Optional Footer: References to issue numbers or breaking changes.
- **Rule**: Never use "fix" for a documentation update; use "docs".

### 2. Coding Standards
*General principles for code clarity and consistency.*

#### **Naming Conventions**
- Use descriptive variable names (e.g., `is_user_authenticated` instead of `auth`).
- Follow the language's standard (CamelCase for Java/TypeScript, snake_case for Python).

#### **Refactoring Logic**
- Before refactoring, explain the reasoning in a comment or in the commit message.
- Ensure TDD principles are followed where applicable; tests should be updated before or alongside code changes.

### 3. Documentation & Communication
*Standardizing how information is presented to humans and other tools.*

#### **README Generation**
Every project must have a README including:
- Project Title and a one-sentence pitch.
- Installation instructions.
- Usage examples (code blocks).
- Contribution guidelines (if applicable).

#### **API Documentation**
Use standardized formats (e.g., Swagger/OpenAPI for REST, JSDoc for JS packages) to ensure automated tools can parse the definitions.

### 4. Testing & Quality Assurance
*Procedures for ensuring code reliability.*

#### **Unit Testing**
- Aim for high coverage on core business logic.
- Use mocks/stubs for external dependencies (network calls, database hits).
