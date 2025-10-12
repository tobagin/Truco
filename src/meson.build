# Configure Config.vala from template
config_vala = configure_file(
    input: 'Config.vala.in',
    output: 'Config.vala',
    configuration: conf_data
)

sources = [
    'Main.vala',
    'Application.vala',
    config_vala,
    gresource_bundle,
]

executable('truco', sources,
    dependencies: [
        dependency('gtk4'),
        dependency('libadwaita-1'),
    ],
    install: true,
)