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

Les messages de commit, les titres et descriptions des pull requests et les noms de branche sont rédigés en anglais.

Chaque branche (`feature/xxx`, `fix/xxx`, etc.) part de `dev` et y revient par pull request avec la CI verte, en squash merge. La branche `dev` est fusionnée dans `main` pour chaque release.
