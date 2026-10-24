# NextAnime — Design tokens et thème (Bootstrap + SCSS)

Source : maquettes Claude Design (néon / cyber japonisant), thèmes **sombre** (défaut) et **clair**.

## Fichiers

| Fichier | Où le copier dans Rails | Rôle |
|---|---|---|
| `stylesheets/tokens/_colors.scss` | `app/assets/stylesheets/tokens/` | Palette brute des deux thèmes + dégradés d'affiches |
| `stylesheets/tokens/_scale.scss` | idem | Polices, tailles, espacements, rayons, layout, lueurs |
| `stylesheets/tokens/_theme.scss` | idem | Variables CSS sémantiques `--na-*` par thème |
| `stylesheets/_bootstrap_overrides.scss` | `app/assets/stylesheets/` | Variables Sass Bootstrap (avant l'import) |
| `stylesheets/application.bootstrap.scss` | `app/assets/stylesheets/` (remplace le fichier généré par `rails new`) | Ordre d'import + premiers composants atomiques |

Règle : les composants n'utilisent que `var(--na-*)` (jamais un hex en dur). Changer de thème = changer `data-bs-theme` sur `<html>`.

## Tokens principaux

| Token | Sombre | Clair |
|---|---|---|
| `--na-bg` | `#0B0A14` | `#F4EFE6` |
| `--na-surface` | `#14122A` | `#FBF8F2` |
| `--na-surface-2` | `#1C1A38` | `#ECE5D8` |
| `--na-border` | `#2C2A55` | `#D8CFBE` |
| `--na-text` | `#F2F0FF` | `#3A3550` |
| `--na-muted` | `#A9A6D0` | `#655F7A` |
| `--na-magenta` | `#FF2E93` | `#A83A6F` |
| `--na-cyan` | `#19E3F2` | `#2F6F76` |

Polices : Chakra Petch 600/700 (titres, boutons), Manrope 400/600/800 (texte), DotGothic16 (chiffres, étiquettes).
Rayons : 8 (boutons, champs), 12 (petites cartes), 16 (cartes), 999 (tags, barres). Zones cliquables ≥ 44 px.
Layout : contenu desktop 1344 px max, gouttières 48 px (desktop) / 16 px (mobile), maquettes mobiles 390 px.

## Mise en place (commandes à lancer toi-même)

Le projet utilise `cssbundling-rails` : Sass et Bootstrap sont installés par Yarn (déjà fait). Copie les fichiers aux emplacements du tableau, en remplaçant `app/assets/stylesheets/application.bootstrap.scss`, puis :

```bash
yarn build:css
```

Les imports relatifs (`tokens/colors`, `bootstrap_overrides`) sont résolus depuis le dossier du fichier d'entrée, et `bootstrap/scss/bootstrap` via `--load-path=node_modules` (déjà dans `package.json`). Dart Sass signale des avertissements de dépréciation sur `@import` : c'est attendu, Bootstrap n'a pas encore migré vers `@use`.

Polices, dans `<head>` de `app/views/layouts/application.html.erb` :

```erb
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Chakra+Petch:wght@600;700&family=DotGothic16&family=Manrope:wght@400;600;800&display=swap">
```

Et `<html lang="fr" data-bs-theme="dark">`.

## Bascule clair / sombre (Stimulus)

`app/javascript/controllers/theme_controller.js` :

```js
import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "nextanime-theme"

export default class extends Controller {
  connect() {
    const saved = this.#read()
    const preferred = window.matchMedia("(prefers-color-scheme: light)").matches ? "light" : "dark"
    this.#apply(saved || preferred)
  }

  toggle() {
    this.#apply(document.documentElement.dataset.bsTheme === "dark" ? "light" : "dark")
  }

  #apply(theme) {
    document.documentElement.dataset.bsTheme = theme
    try { localStorage.setItem(STORAGE_KEY, theme) } catch (_) { /* stockage indisponible */ }
  }

  #read() {
    try { return localStorage.getItem(STORAGE_KEY) } catch (_) { return null }
  }
}
```

Bouton dans la navbar (accessible) :

```erb
<button type="button" class="btn btn-sm" data-controller="theme" data-action="theme#toggle"
        aria-label="Basculer entre thème clair et sombre">◐</button>
```

Pour éviter un flash au chargement, ajoute dans le `<head>`, avant le CSS, un petit script qui lit `localStorage` et pose `data-bs-theme` (à ajouter quand on fera la branche `feature/polish-deploy`).

## Contrôle qualité

- Contrastes : texte principal et secondaire, magenta et cyan des deux thèmes visent WCAG AA (≥ 4,5:1) sur leur fond ; les couleurs néon d'origine ne sont utilisées que sur fond sombre.
- Les badges de match et les zones de texte sur affiche restent sombres dans les deux thèmes (classes `.na-badge-match` et `.na-poster-overlay`).
- À vérifier au moment de l'intégration : les écarts de rendu entre les maquettes et Bootstrap (espacements, états hover/focus/disabled).

## Où ça s'insère dans le plan

Branche `feature/design-system`, après `feature/init` : tokens + overrides, layout (navbar desktop / tab bar mobile), puis composants atomiques (bouton, tag, carte, barre de progression, badge de match) avec un spec RSpec de rendu par composant, avant les écrans.
