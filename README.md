# NextAnime

Application de recommandation d'anime par swipe, inspirée d'AnimeSphere. Projet portfolio.

## Stack
Rails 8, PostgreSQL, Hotwire (Turbo + Stimulus), Bootstrap + SCSS, Devise, RSpec.

## Installation
```bash
bundle install
bin/rails db:prepare
bin/dev
```

## Tests et qualité
```bash
bundle exec rspec
bundle exec rubocop
bin/brakeman
```

## Conventions Git
Branches `feature/xxx` depuis `dev`, Pull Request avec CI verte, squash vers `dev`.
Commits au format Conventional Commits (`feat:`, `fix:`, `test:`, `docs:`, `chore:`, `refactor:`).
