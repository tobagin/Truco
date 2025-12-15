# Configure schema
gschema_xml = configure_file(
    input: 'io.github.tobagin.Truco.gschema.xml.in',
    output: 'io.github.tobagin.Truco.gschema.xml',
    configuration: conf_data
)

# Compile schemas in this directory
gnome.compile_schemas()

# Install schema
install_data(gschema_xml,
    install_dir: get_option('datadir') / 'glib-2.0' / 'schemas',
    rename: application_id + '.gschema.xml'
)
