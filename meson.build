project('io.github.tobagin.Truco', 'vala', 'c',
    version: '0.1.0',
    meson_version: '>= 0.59.0',
    default_options: [
        'warning_level=2',
        'werror=false',
    ]
)

gnome = import('gnome')

# Add Vala-specific arguments
vala_args = ['--vapidir', meson.current_source_dir() / 'src']

# Get buildtype
buildtype = get_option('buildtype')

# Configure application ID and profile based on buildtype
base_app_id = 'io.github.tobagin.Truco'
if buildtype in ['debug', 'debugoptimized']
    # Development builds: use .Devel suffix
    # Used by io.github.tobagin.Truco.Devel.yml (debugoptimized)
    application_id = base_app_id + '.Devel'
    profile = 'development'
    vala_args += ['--debug']
    add_project_arguments(['-DDEBUG'], language: 'c')
    message('Building DEVELOPMENT version (buildtype: @0@, app_id: @1@)'.format(buildtype, application_id))
elif buildtype == 'release'
    # Release build: use base app ID
    # Used by io.github.tobagin.Truco.yml
    application_id = base_app_id
    profile = 'release'
    add_project_arguments(['-DNDEBUG'], language: 'c')
    message('Building RELEASE version (app_id: @0@)'.format(application_id))
elif buildtype == 'minsize'
    # Minimal size build: use base app ID
    application_id = base_app_id
    profile = 'release'
    add_project_arguments(['-DNDEBUG'], language: 'c')
    message('Building MINSIZE version (app_id: @0@)'.format(application_id))
elif buildtype == 'plain'
    # Plain build: use base app ID
    application_id = base_app_id
    profile = 'release'
    message('Building PLAIN version (app_id: @0@)'.format(application_id))
else
    # Custom buildtype: use base app ID
    application_id = base_app_id
    profile = 'release'
    message('Building with custom buildtype: @0@ (app_id: @1@)'.format(buildtype, application_id))
endif

add_project_arguments(vala_args, language: 'vala')

# Configuration data for template files
conf_data = configuration_data()
conf_data.set_quoted('APP_ID', application_id)
conf_data.set_quoted('VERSION', meson.project_version())
conf_data.set_quoted('PROFILE', profile)
conf_data.set('NAME', '"Truco"')
conf_data.set('GETTEXT_PACKAGE', '"truco"')
conf_data.set('LOCALEDIR', '"' + get_option('prefix') / get_option('localedir') + '"')

# Make application_id available to subdirs
# Note: In meson, variables defined in parent meson.build are available in subdirs
# So application_id and conf_data are already accessible in src/meson.build and data/meson.build

subdir('data')
subdir('src')
subdir('po')