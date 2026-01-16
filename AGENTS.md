# AGENTS.md - Geeknote Rails Application

This document provides guidelines for AI agents working on the Geeknote Rails application.

## Project Overview

Geeknote is a blog community platform built with Ruby on Rails 8.1.2, using PostgreSQL, Hotwire (Turbo + Stimulus), and Tailwind CSS.

## Development Environment

### Setup
- Ruby 3.4.7
- Rails 8.1.2
- PostgreSQL database
- Node.js for JavaScript/CSS bundling

### Development Commands
```bash
# Start development server
bin/dev

# Run setup (database, dependencies)
bin/setup

# Run Rails console
bin/rails console

# Run database migrations
bin/rails db:migrate

# Run database seeds
bin/rails db:seed
```

## Testing

### Test Commands
```bash
# Run all tests
bin/rails test

# Run specific test file
bin/rails test test/controllers/home_controller_test.rb

# Run single test by line number
bin/rails test test/controllers/home_controller_test.rb:4

# Run system tests
bin/rails test:system

# Run tests in parallel (default)
RAILS_ENV=test bin/rails test

# Run tests sequentially (for debugging)
PARALLEL_WORKERS=0 bin/rails test
```

### Test Structure
- Tests use Minitest framework
- Test files follow Rails conventions: `test/**/*_test.rb`
- Use FactoryBot for test data (`create(:user)`, `build(:post)`)
- Integration tests inherit from `ActionDispatch::IntegrationTest`
- Model tests inherit from `ActiveSupport::TestCase`
- System tests use Capybara with Selenium

### Test Helpers
- `sign_in(user)` - Sign in a user in integration tests
- `sign_out` - Sign out current user
- `create(:factory_name)` - Create test records
- `assert_response :success` - Check HTTP response
- WebMock is configured to allow Meilisearch connections

## Code Quality & Security

### Linting & Style Checking
```bash
# Run Rubocop (Ruby style checker)
bin/rubocop

# Run Rubocop with auto-correct
bin/rubocop -A

# Run security audit for gems
bin/bundler-audit

# Run static security analysis
bin/brakeman
```

### Continuous Integration
```bash
# Run full CI pipeline (setup, lint, security, tests)
bin/ci
```

## Code Style Guidelines

### Ruby/Rails Style
- Follow **Rubocop Rails Omakase** configuration (inherited from gem)
- Use 2-space indentation
- Use single quotes for strings unless interpolation needed
- Prefer `&&`/`||` over `and`/`or`
- Use trailing commas in multiline arrays/hashes
- Prefer `%i[]` for symbol arrays
- Use `private`/`protected` sections in classes

### Naming Conventions
- **Models**: Singular nouns (`User`, `Post`, `Comment`)
- **Controllers**: Plural nouns (`UsersController`, `PostsController`)
- **Database tables**: Plural snake_case (`users`, `posts`)
- **Foreign keys**: `{table}_id` (`user_id`, `post_id`)
- **Associations**: Use descriptive names (`has_many :comments`)

### Imports & Requires
- Use `require` for external dependencies
- Use `require_relative` for project files
- Group gem requires by functionality
- Keep `Gemfile` organized with comments

### Error Handling
- Use Rails rescue_from for controller-level error handling
- Rescue specific exceptions, not generic `Exception`
- Use `render_404` helper for not found errors
- Validate models with ActiveRecord validations
- Use `optional_verify_recaptcha` helper for conditional CAPTCHA

### ActiveRecord Patterns
- Use scopes for common queries
- Prefer `where` with named arguments
- Use `includes`/`preload` for eager loading
- Use transactions for multiple database operations
- Implement `to_param` for friendly URLs when needed

### View Templates
- Use ERB templates with `.html.erb` extension
- Keep logic in helpers or presenters
- Use partials for reusable components
- Follow Rails form conventions with `form_with`
- Use Turbo Frames for partial page updates

### JavaScript/Stimulus
- JavaScript files in `app/javascript/`
- Use Stimulus controllers for interactive elements
- Follow Hotwire conventions for Turbo Streams
- Use `@rails/request.js` for AJAX requests
- Bundle with esbuild (`npm run build`)

### CSS/Tailwind
- Use Tailwind CSS utility classes
- Custom styles in `app/assets/stylesheets/`
- Build with `npm run build:css`
- Use DaisyUI components where appropriate

## Architecture Patterns

### Current Pattern
- Use `Current` model for request-scoped data
- `Current.user` provides current authenticated user
- `Current.account` provides current account context

### Authentication
- Uses `has_secure_password` for password management
- Session-based authentication with `sessions` table
- Token generation for email verification/password reset

### File Uploads
- Use Active Storage with AWS S3 or local storage
- Image processing with `image_processing` gem
- Variants for different image sizes
- Use `imgproxy-rails` for on-the-fly image processing

### Search
- Meilisearch integration via `meilisearch-rails`
- Searchable models include search callbacks
- Configured in `config/initializers/meilisearch.rb`

### Background Jobs
- Solid Queue for job processing
- Mission Control for job management
- Configured in `config/queue.yml`

## Database

### Migrations
- Use Rails migration generators
- Add indexes for foreign keys and search fields
- Use `change` method for reversible migrations
- Add `null: false` for required fields
- Set default values where appropriate

### Seeds
- Development seeds in `db/seeds.rb`
- Use `db:seed:replant` for test environment
- FactoryBot available in seeds for test data

## Deployment & Operations

### Environment Configuration
- Use `.env` files for environment variables (development/test)
- Configure database in `config/database.yml`
- Configure storage in `config/storage.yml`
- Use `dotenv-rails` gem for environment loading

### Monitoring
- New Relic for application monitoring
- Ahoy for analytics and visit tracking
- Chartkick for data visualization

## Common Tasks for Agents

### Adding a New Feature
1. Create migration: `bin/rails generate migration AddXToY`
2. Update model with validations and associations
3. Create controller with RESTful actions
4. Add routes in `config/routes.rb`
5. Create views/templates
6. Write tests for all new functionality
7. Run tests and linting

### Fixing a Bug
1. Write failing test that reproduces the bug
2. Fix the code to make test pass
3. Ensure all existing tests still pass
4. Run linting and security checks

### Refactoring Code
1. Ensure comprehensive test coverage
2. Make incremental changes
3. Run tests after each change
4. Maintain backward compatibility
5. Update documentation if needed

## Notes for AI Agents

- This is a production application with real users
- Always run tests before making changes
- Follow existing patterns in the codebase
- Use the provided bin scripts for common tasks
- Check the CI pipeline output for any issues
- Document significant changes in commit messages

## Resources

- [Rails Guides](https://guides.rubyonrails.org)
- [Rubocop Rails Omakase](https://github.com/rails/rubocop-rails-omakase)
- [Hotwire Documentation](https://hotwired.dev)
- [Tailwind CSS](https://tailwindcss.com)
- [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)