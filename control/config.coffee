exports.config =
  # See docs at http://brunch.readthedocs.org/en/latest/config.html.
  files:
    javascripts:
      defaultExtension: 'coffee'
      joinTo:
        'javascripts/app.js': /^app/
        'javascripts/vendor.js': /^vendor/
      order:
        before: [
          'vendor/scripts/common-vendor/console-helper.js',
          'vendor/scripts/common-vendor/jquery-1.9.0.min.js',
          'vendor/scripts/common-vendor/underscore-1.4.4.js',
          'vendor/scripts/common-vendor/backbone-0.9.10.js'
        ]

        after: [
          'vendor/scripts/common-vendor/bootstrap.min.js'
        ]

    stylesheets:
      defaultExtension: 'styl'
      joinTo: 'stylesheets/app.css'
      order:
        before: [
          'vendor/styles/bootstrap.css',
        ]

        after: [
          'vendor/styles/bootstrap-responsive.css'
        ]

    templates:
      defaultExtension: 'hbs'
      joinTo: 'javascripts/app.js'
