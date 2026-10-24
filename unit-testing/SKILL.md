---
name: unit-testing
description: Write or update unit tests for core business logic while isolating network and database dependencies.
---

# Unit Testing

Prioritize meaningful coverage of core business logic and changed behavior. Follow the existing test framework and conventions. Update tests before or alongside code changes where appropriate.

Use mocks or stubs for external dependencies such as network calls and database access when isolating a unit. Check observable outcomes and relevant edge cases.

Best: test a business rule using controlled dependency responses. Avoid: routine unit tests that require live external services or only mirror implementation details.
