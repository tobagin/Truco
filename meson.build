project('io.github.tobagin.Truco', ['c', 'vala'],
  version: '0.1.0',
  meson_version: '>= 0.59.0',
)

i18n = import('i18n')
gnome = import('gnome')

if get_option('profile') == 'development'
  application_id = 'io.github.tobagin.Truco.Devel'
  profile_name = 'Devel'
else
  application_id = 'io.github.tobagin.Truco'
  profile_name = 'Default'
endif

add_project_arguments('-DGETTEXT_PACKAGE="@0@"'.format(application_id), language: 'c')

gettext_package = application_id

conf_data = configuration_data()
conf_data.set_quoted('APP_ID', application_id)
conf_data.set('APPLICATION_ID', application_id)
conf_data.set_quoted('GETTEXT_PACKAGE', application_id)
conf_data.set_quoted('VERSION', meson.project_version())
conf_data.set('RESOURCE_PATH', '/io/github/tobagin/Truco')
conf_data.set_quoted('RESOURCE_PATH_QUOTED', '/io/github/tobagin/Truco')
conf_data.set_quoted('NAME', 'Truco')
conf_data.set_quoted('PROFILE', profile_name)
conf_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))

# Find blueprint-compiler
blueprint_compiler = find_program('blueprint-compiler', required: true)

blueprints = custom_target('compile-window',
  input: files('data/ui/window.blp'),
  output: 'window.ui',
  command: [blueprint_compiler, 'compile', '--output', '@OUTPUT@', '@INPUT@'],
  install: false,
)

new_game_dialog = custom_target('compile-new-game',
  input: files('data/ui/new_game_dialog.blp'),
  output: 'new_game_dialog.ui',
  command: [blueprint_compiler, 'compile', '--output', '@OUTPUT@', '@INPUT@'],
  install: false,
)

shortcuts_ui = custom_target('compile-shortcuts',
  input: files('data/ui/shortcuts.blp'),
  output: 'shortcuts.ui',
  command: [blueprint_compiler, 'compile', '--output', '@OUTPUT@', '@INPUT@'],
  install: false,
)

preferences_dialog = custom_target('compile-preferences',
  input: files('data/ui/preferences_dialog.blp'),
  output: 'preferences_dialog.ui',
  command: [blueprint_compiler, 'compile', '--output', '@OUTPUT@', '@INPUT@'],
  install: false,
)

avatar_selector = custom_target('compile-avatar-selector',
  input: files('data/ui/avatar_selector.blp'),
  output: 'avatar_selector.ui',
  command: [blueprint_compiler, 'compile', '--output', '@OUTPUT@', '@INPUT@'],
  install: false,
)

match_end_dialog = custom_target('compile-match-end',
  input: files('data/ui/match_end_dialog.blp'),
  output: 'match_end_dialog.ui',
  command: [blueprint_compiler, 'compile', '--output', '@OUTPUT@', '@INPUT@'],
  install: false,
)

compiled_blueprints = [blueprints, new_game_dialog, match_end_dialog, shortcuts_ui, preferences_dialog, avatar_selector]


# Configure desktop file from template with dynamic app ID
desktop_file_in = configure_file(
    input: 'data/io.github.tobagin.Truco.desktop.in',
    output: application_id + '.desktop.in',
    configuration: conf_data
)

desktop_file = i18n.merge_file(
    input: desktop_file_in,
    output: application_id + '.desktop',
    type: 'desktop',
    po_dir: '../po',
    install: true,
    install_dir: get_option('datadir') / 'applications',
)

desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
    test('Validate desktop file', desktop_utils,
        args: [desktop_file],
    )
endif

# Configure metainfo file from template with dynamic app ID
metainfo_file_in = configure_file(
    input: 'data/io.github.tobagin.Truco.metainfo.xml.in',
    output: application_id + '.metainfo.xml.in',
    configuration: conf_data
)

appstream_file = i18n.merge_file(
    input: metainfo_file_in,
    output: application_id + '.metainfo.xml',
    po_dir: '../po',
    install: true,
    install_dir: get_option('datadir') / 'metainfo',
)

appstream_util = find_program('appstream-util', required: false)
if appstream_util.found()
    test('Validate appstream file', appstream_util,
        args: [appstream_file],
    )
endif

# Install icon with correct name based on application_id
# Install icon with correct name based on application_id
icon_source = 'data/icons/hicolor/scalable/apps/io.github.tobagin.Truco.svg'
install_data(
    icon_source,
    rename: application_id + '.svg',
    install_dir: get_option('datadir') / 'icons' / 'hicolor' / 'scalable' / 'apps'
)

symbolic_icon_source = 'data/icons/hicolor/symbolic/apps/io.github.tobagin.Truco-symbolic.svg'
install_data(
    symbolic_icon_source,
    rename: application_id + '-symbolic.svg',
    install_dir: get_option('datadir') / 'icons' / 'hicolor' / 'symbolic' / 'apps'
)

# Configure GResource XML with dynamic resource path
gresource_xml = configure_file(
    input: 'data/io.github.tobagin.Truco.gresource.xml.in',
    output: 'io.github.tobagin.Truco.gresource.xml',
    configuration: conf_data
)

# Compile GResource bundle (will be linked into executable)
gresource_bundle = gnome.compile_resources(
    'io.github.tobagin.Truco',
    gresource_xml,
    c_name: 'resources',
    dependencies: compiled_blueprints,
    source_dir: [meson.current_build_dir(), join_paths(meson.current_source_dir(), 'data')]
)

subdir('data')
subdir('src')
subdir('help')
subdir('po')
