i18n = import('i18n')

# Find blueprint-compiler
blueprint_compiler = find_program('blueprint-compiler', required: true)

# Compile Blueprint files to UI
blueprints = custom_target('compile-window',
  input: files('ui/window.blp'),
  output: 'window.ui',
  command: [blueprint_compiler, 'compile', '--output', '@OUTPUT@', '@INPUT@'],
  install: false,
)

shortcuts_ui = custom_target('compile-shortcuts',
  input: files('ui/shortcuts.blp'),
  output: 'shortcuts.ui',
  command: [blueprint_compiler, 'compile', '--output', '@OUTPUT@', '@INPUT@'],
  install: false,
)

compiled_blueprints = [blueprints, shortcuts_ui]

# Configure desktop file from template with dynamic app ID
desktop_file_in = configure_file(
    input: 'io.github.tobagin.Truco.desktop.in',
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
    input: 'io.github.tobagin.Truco.metainfo.xml.in',
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
icon_source = 'icons/hicolor/scalable/apps/' + application_id + '.svg'
install_data(
    icon_source,
    install_dir: get_option('datadir') / 'icons' / 'hicolor' / 'scalable' / 'apps'
)

# Configure GResource XML with dynamic resource path
gresource_xml = configure_file(
    input: 'io.github.tobagin.Truco.gresource.xml.in',
    output: 'io.github.tobagin.Truco.gresource.xml',
    configuration: conf_data
)

# Compile GResource bundle (will be linked into executable)
gresource_bundle = gnome.compile_resources(
    'io.github.tobagin.Truco',
    gresource_xml,
    c_name: 'resources',
    dependencies: compiled_blueprints,
    source_dir: meson.current_build_dir()
)