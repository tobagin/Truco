# Configure Config.vala from template
config_vala = configure_file(
    input: 'Config.vala.in',
    output: 'Config.vala',
    configuration: conf_data
)


sources = [
    'Main.vala',
    'Application.vala',
    'Window.vala',
    'Game.vala',
    'Game.vala',
    'dialogs/NewGameDialog.vala',
    'dialogs/MatchEndDialog.vala',
    'dialogs/PreferencesDialog.vala',
    'dialogs/AvatarSelector.vala',
    'dialogs/PreferencesDialog.vala',
    'dialogs/AvatarSelector.vala',
    'dialogs/About.vala',
    config_vala,
    gresource_bundle,
]

executable('truco', sources,
    dependencies: [
        dependency('gtk4'),
        dependency('libadwaita-1'),
        dependency('gee-0.8'),
    ],
    install: true,
)