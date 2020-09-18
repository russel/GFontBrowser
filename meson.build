#  GFontBrowser — A font browser for GTK+, Fontconfig, Pango based systems.
#
#  Copyright © 2017–2020  Russel Winder <russel@winder.org.uk>
#
#  This program is free software: you can redistribute it and/or modify it under the terms of
#  the GNU General Public License as published by the Free Software Foundation, either version 3
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
#  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#  See the GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License along with this program.
#  If not, see <http://www.gnu.org/licenses/>.

project(
  'GFontBrowser',
  'd',
  version: '0.1.0',  # Ensure this is the same as in ./VERSION
  default_options: ['buildtype=release'],
)

prefix = get_option('prefix')
datadir = get_option('datadir')

application_id = 'uk.org.winder.GFontBrowser'

test_module_names = [
  'about',
  'applicationWindow',
  'configuration',
  'fontCatalogue',
  'presentation',
]

sources = []
foreach m: test_module_names
  sources += 'source/' + m + '.d'
endforeach
sources += [
  'source/main.d',
  'generated/fontconfig.d', # Does not seem to matter if this one is present, not sure why.
]

ut_meson_main = configure_file(
  input: 'data/ut_meson_main.d.in',
  output: 'ut_meson_main.d',
  configuration: {'TEST_MODULE_NAME_LIST': '"' + '", "'.join(test_module_names) + '"'},
)

test_sources = [ut_meson_main]
foreach m: test_module_names
  test_sources += 'source/' + m + '.d'
endforeach

dependencies = [
  # Versions of dependencies as in Debian Buster (Stable as at 2020-03-10) and later.
  dependency('gtkd-3', version: '>= 3.8.5'), # 3.9.0 is available in Sid, but is not required.
  dependency('fontconfig', version: '>= 2.13.1'),
  dependency('pangoft2', version: '>= 1.42.4'),
]

test_dependencies = [
  dependency('unit-threaded'),  # Whatever version is available, it must be provided locally.
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

testExecutable = executable(
  'gfontbrowser-test',
  test_sources,
  dependencies: dependencies + test_dependencies,
  include_directories: includes,
  d_args: d_args + ['-unittest'],
  link_args: link_args,
  build_by_default: false,
  # override_options: ['unity=on'] # Doesn't work as at 2020-08-26. Uses separate build. :-(
)

test('all tests', testExecutable)

install_man('doc/gfontbrowser.1')

install_data(
  'source/resource/@0@.svg'.format(application_id),
  install_dir: datadir / 'icons' / 'hicolor' / 'scalable' / 'apps'
)

#install_data(
#  'data/@0@.png'.format(application_id),
#  install_dir: datadir / 'icons' / 'hicolor' / '48x48' / 'apps'
#)

install_data(
  'data/@0@.desktop'.format(application_id),
  install_dir: datadir / 'applications'
)

install_data(
  'data/@0@.appdata.xml'.format(application_id),
  install_dir: datadir / 'appdata'
)
