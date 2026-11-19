# NextAnime

NextAnime recommande des anime par swipe : tu notes quelques références, l'application cerne tes goûts et te propose des titres qui te ressemblent, plutôt que ceux que tout le monde regarde. Projet portfolio.

## Fonctionnalités

- **Swipe** pour cerner ses goûts, sans créer de compte
- **Recommandations** personnalisées à partir des swipes
- **Catalogue** filtrable et fiche détaillée de chaque anime
- **Disponibilités de streaming** selon le pays, avec un lien vers la plateforme
- **Watchlist** et **calendrier** des sorties
- **Compte** (Devise) avec export et suppression des données depuis le profil
- **Politique de confidentialité** et balises de partage (Open Graph, Twitter Card)

## Stack

Ruby 3.3.5, Rails 8.1, PostgreSQL, Hotwire (Turbo + Stimulus, importmap), Bootstrap + SCSS, ViewComponent (design atomique), Devise, Pundit, Solid Queue, RSpec + Capybara (Selenium, Chrome headless).

Les couleurs, typographies et espacements sont décrits dans [docs/DESIGN_TOKENS.md](docs/DESIGN_TOKENS.md).

## Prérequis

- Ruby 3.3.5
- Node 20.20.2 et Yarn
- PostgreSQL
- Google Chrome (pour les tests système)

## Installation

```bash
git clone git@github.com:mtremauville/nextanime.git
cd nextanime
bin/setup
```

`bin/setup` installe les dépendances, prépare les bases de données (celle de l'application et celle des jobs) puis lance `bin/dev`. Pour ne pas démarrer le serveur : `bin/setup --skip-server`.

`bin/dev` démarre trois process : le serveur (`web`), la compilation du CSS (`css`) et le worker des jobs (`jobs`). L'application est sur http://localhost:3000.

## Importer les données

Le catalogue est vide au départ. Les imports sont des jobs : ils sont mis en file par la commande, puis exécutés par le worker lancé avec `bin/dev`, avec une pause entre deux pages. Les guillemets sont nécessaires avec zsh.

```bash
bin/rails "anilist:import[500]"          # les 500 anime les mieux classés
bin/rails "anilist:import_airing[500]"   # les anime en cours de diffusion
bin/rails "tmdb:import_availabilities[100]"   # où les regarder (voir ci-dessous)
```

La progression se suit dans `log/development.log` (lignes `Performed ImportTopAnimeJob`).

### Disponibilités de streaming (jeton TMDB)

Seul l'import des disponibilités a besoin d'un jeton TMDB. Il est lu dans les credentials Rails sous `tmdb.read_access_token`. Le fichier `config/credentials.yml.enc` du dépôt est chiffré avec la clé de l'auteur : pour utiliser le tien, crée un compte sur [TMDB](https://www.themoviedb.org/), récupère ton « API Read Access Token », puis :

```bash
rm config/credentials.yml.enc
EDITOR=nano bin/rails credentials:edit
```

Ajoute dans le fichier qui s'ouvre :

```yaml
tmdb:
  read_access_token: ton_jeton
```

Ne commite pas ce changement : `config/master.key` reste local.

Pour chaque anime, le lien de streaming est le lien direct d'AniList quand il existe, sinon une recherche sur la plateforme (`config/streaming_platform_searches.yml`), sinon sa page d'accueil (`config/streaming_platform_homepages.yml`).

## Tests et qualité

```bash
bundle exec rspec        # suite complète, tests système et audits d'accessibilité inclus
bundle exec rubocop
bin/brakeman
```

La couverture est mesurée par SimpleCov (rapport dans `coverage/index.html`). Les tests système vérifient aussi l'accessibilité des écrans (axe, cibles tactiles d'au moins 44 px).

La CI (GitHub Actions) exécute trois jobs sur chaque pull request et sur `dev` et `main` : `lint`, `security` et `test`.

## Sources des données

- **Catalogue** : [AniList](https://anilist.co/).
- **Disponibilités de streaming** : données [JustWatch](https://www.justwatch.com/), fournies par l'API [TMDB](https://www.themoviedb.org/) et affichées avec leur source.

This product uses the TMDB API but is not endorsed or certified by TMDB.

## Conventions Git

- `main` (releases) et `dev` (intégration). Chaque branche (`feature/xxx`, `fix/xxx`, `docs/xxx`, `chore/xxx`, `refactor/xxx`) part de `dev` et y revient par pull request avec la CI verte, en squash merge. `dev` est fusionnée dans `main` à chaque release.
- Commits au format Conventional Commits (`feat:`, `fix:`, `test:`, `docs:`, `chore:`, `refactor:`).
- Les messages de commit, les titres et descriptions des pull requests et les noms de branche sont rédigés en anglais.
