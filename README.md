# Client Search Tool (Ruby on Rails)

This project is a command-line search tool built with **Ruby 3.3.8** and **Rails 8.0.2**. 

It enables efficient searching and duplicate detection across a JSON dataset of clients. 

It's designed with flexibility in mind — easily extensible into a REST API, and ready for team collaboration and containerized deployment.

---

## 🚀 How to Use

Make sure you're in the **project root directory**, then run the following rake tasks:

### 🔍 Search Clients

### Witout Docker

1. **Search keyword by specific field**  
   ```bash
   rake "client_search:find[john,full_name]"

2. **Search keyword globally (across all fields)
   ```bash
   rake "client_search:find[john]"

3. **Find duplicates by specific field
   ```bash
   rake "client_search:duplicates[email]"

4. Find duplicates by default field (email)
   ```bash
   rake "client_search:duplicates"

### If you are using Docker

#### Build and run the app:

```bash
docker-compose build
docker-compose up
```
1. **Search keyword by specific field**  
   ```bash
   docker-compose run web rake "client_search:find[john,full_name]"

2. **Search keyword globally (across all fields)
   ```bash
    docker-compose run web rake "client_search:find[john]"

3. **Find duplicates by specific field
   ```bash
   docker-compose run web rake "client_search:duplicates[email]"

4. Find duplicates by default field (email)
   ```bash
   docker-compose run web rake "client_search:duplicates"

### How to swap to different JSON dataset

#### Create a .env file in the root:

CLIENTS_JSON_PATH=lib/data/clients.json

The JsonClientSearchService will automatically use this file path unless overridden manually.

## 🧠 Solution Overview

### ✅ Service Class (JsonClientSearchService)

This core service handles all the logic for searching and duplicate detection.

#### Benefits:

Clean separation of concerns.

Easily testable and maintainable.

Ready to be exposed via a REST API in the future:

Can be reused directly in controllers or background jobs.

Promotes consistent business logic across interfaces (CLI, API, background tasks).

### ✅ Rake Tasks as CLI Interface

Provides a quick way to interact with the system using simple commands — ideal for non-technical users or scripting in CI pipelines.

## 🏗 Infrastructure

### 🐳 Dockerized Environment

The project includes a Dockerfile and docker-compose.yml for running the app in an isolated container.

#### Benefits:

Zero local setup — no need to install Ruby, Rails, or dependencies locally.

Ensures consistency across environments (dev, test, prod).

Easily deployable or runnable on any system with Docker.

#### To build and run the app:

```bash
docker-compose build
docker-compose up
```

#### To run tasks in the container:

```bash
docker-compose run web rake "client_search:find[john]"
```

### 🧹 Rubocop

Used to enforce consistent code style and quality.

#### Benefits:

Catches bad patterns early.

Keeps code clean and standardized across team members.

Integrates easily with CI for automated checks.

### 🧪 RSpec for Testing
We use RSpec to test our service logic and rake tasks.

#### Benefits:

Describes behavior clearly and concisely

Encourages test-driven development (TDD)

Reduces regressions during refactors

Easily integrates with CI pipelines

Supports mocking, stubbing, and shared contexts for complex input

#### Run all tests:

```bash
bundle exec rspec
```

### 💬 Commit Message Convention

All commits should include:

A Jira ticket number (e.g. BT-001)

A brief summary of the acceptance criteria or purpose

This will benefit for the code review

### 🌱 Dotenv for Configuration
The app uses the dotenv gem to load environment variables from a .env file.

#### Benefits:

Keeps config values out of code

Supports multiple environments (e.g., dev/test/prod)

Easily shareable via .env.example template

## 🛠️ Recommendations for Scalability & Architecture

### Add REST API

Expose the service via Rails controllers for web or mobile use:

GET /clients/search?query=john&field=full_name

GET /clients/duplicates?field=email

### Use ActiveModel for Structuring Responses

If you plan to expose this as an API, wrap results in presenter objects or use ActiveModel::Serializer to format output.

### Plug Into a Background Queue

For large JSON files or integrations, use Sidekiq or ActiveJob to offload the processing from rake/API.

### Add Logging & Metrics

Track usage or anomalies for ops visibility using Rails logger or services like Logtail, NewRelic, or Datadog.
