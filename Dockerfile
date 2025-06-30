FROM ruby:3.3

# Install dependencies (nodejs for JS runtime, sqlite3 client)
RUN apt-get update -qq && apt-get install -y nodejs sqlite3

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD ["bin/rails", "server", "-b", "0.0.0.0"]
