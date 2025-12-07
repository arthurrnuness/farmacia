# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "calendario", to: "calendario.js"
pin "tag_filter", to: "tag_filter.js"
pin "ver_hoje", to: "ver_hoje.js"
pin "grid_toggle", to: "grid_toggle.js"
pin "grid_click", to: "grid_click.js"
pin "long_press", to: "long_press.js"
