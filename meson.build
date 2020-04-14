# -*- mode: python; coding: utf-8; -*-

# GFontBrowser — A font browser for GTK+, Fontconfig, Pango based systems.
#
# Copyright © 2018–2020  Russel Winder <russel@winder.org.uk>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

project(
    'GFontBrowser',
    'd',
    version: '0.1.0',
    default_options: ['buildtype=release'],
)

sources = run_command('sh', '-c', 'cd $MESON_SOURCE_ROOT && ls source/*.d').stdout().split()

dependencies = [
    # Versions of dependencies as in Debian Buster (Stable as at 2020-03-10) and later.
    dependency('gtkd-3', version: '>= 3.8.5'), # 3.9.0 is available in Sid, but is not required.
    dependency('fontconfig', version: '>= 2.13.1'),
    dependency('pangoft2', version: '>= 1.42.4'),
]

test_dependencies = [
    dependency('unit-threaded', version: '>= 0.10.8'),
]

includes = [
    include_directories('source'),
    include_directories('generated'),
]

d_args = [
    '-J' + meson.current_source_dir(),
    '-J' + meson.current_source_dir() + '/source/resource',
]

link_args = [
]

executable(
    'gfontbrowser',
    sources,
    dependencies: dependencies,
    include_directories: includes,
    d_args: d_args,
    link_args: link_args,
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
    link_args: link_args + ['-main'],
    build_by_default: false,
)

test('all tests', testExecutable)

subdir('data')
subdir('doc')
