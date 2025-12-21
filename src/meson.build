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
    'DialogFactory.vala',
    'RulesEngine.vala',
    'ScoreManager.vala',
    'SoundManager.vala',
    'TutorialManager.vala',
    'dialogs/NewGameDialog.vala',
    'dialogs/MatchEndDialog.vala',
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
        dependency('gstreamer-1.0'),
    ],
    install: true,
)

test_sources = [
    'test_rules_engine.vala',
    'RulesEngine.vala',
    'ScoreManager.vala',
    'Game.vala',
    'SoundManager.vala',
    config_vala,
    gresource_bundle,
]

rules_test = executable('test_rules', test_sources,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('gee-0.8'),
        dependency('gstreamer-1.0'),
        dependency('gtk4'),
        dependency('libadwaita-1'),
    ],
        install: false,
    )
    
    test_env = environment()
    test_env.set('GSETTINGS_SCHEMA_DIR', join_paths(meson.project_build_root(), 'data'))
    
    test('Rules Engine Tests', rules_test, env: test_env)
    
    score_test_sources = [
    

    'test_score_manager.vala',

    'ScoreManager.vala',

    config_vala,

]



score_test = executable('test_score', score_test_sources,



    dependencies: [



        dependency('glib-2.0'),



        dependency('gobject-2.0'),



        dependency('gee-0.8'),



    ],



        install: false,



    )



    



    test('Score Manager Tests', score_test, env: test_env)



    



    ai_test_sources = [



    
    'test_ai_integration.vala',
    'RulesEngine.vala',
    'ScoreManager.vala',
    'Game.vala',
    'SoundManager.vala',
    config_vala,
    gresource_bundle,
]

ai_test = executable('test_ai', ai_test_sources,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('gee-0.8'),
        dependency('gstreamer-1.0'),
        dependency('gtk4'),
        dependency('libadwaita-1'),
    ],
    install: false,
)

test('AI Integration Tests', ai_test, env: test_env)

ui_test_sources = [
    'test_ui_consistency.vala',
    'DialogFactory.vala',
    config_vala,
    gresource_bundle,
]

ui_test = executable('test_ui', ui_test_sources,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('gee-0.8'),
        dependency('gtk4'),
        dependency('libadwaita-1'),
    ],
    install: false,
)

test('UI Consistency Tests', ui_test, env: test_env)
