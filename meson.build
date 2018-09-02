# -*- mode: python; coding: utf-8; -*-

project(
    'GFontBrowser',
    'd',
    version: '0.0.0',
    default_options: ['buildtype=release'],
)

sources = run_command('sh', '-c', 'cd $MESON_SOURCE_ROOT && ls source/*.d').stdout().split()

dependencies = [
    #dependency('gtk-d:gtkd', version: '>= 3.8.3', method: 'dub'),
    dependency('gtkd-3', version: '>= 3.8.3'),
]

test_dependencies = [
    #dependency('unit-threaded', version: '>= 0.7.51', method: 'dub'),
    dependency('unit-threaded', version: '>= 0.7.49'),  # Problem building 0.7.51
]

includes = [
   include_directories('source'),
]

d_args = [
    '-J' + meson.current_source_dir(),
    '-J' + meson.current_source_dir() + '/source/resource',
]

executable(
    'gfontbrowser',
    sources,
    dependencies: dependencies,
    include_directories: includes,
    d_args: d_args,
    link_args: [],
    install: true,
)

# Switched to using unit-threaded which requires unity builds
# but Meson doesn't support unity builds for D yet, so no tests
# ever get run.

testExecutable = executable(
    'gfontbrowser-test',
    sources,
    dependencies: dependencies + test_dependencies,
    include_directories: includes,
    d_args: d_args + ['-unittest'],
    link_args: ['-main'],
)

test('all tests', testExecutable)

subdir('data')
subdir('doc')
