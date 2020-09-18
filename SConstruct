# -*- mode: python; coding: utf-8; -*-

# GFontBrowser — A font browser for GTK+, Fontconfig, Pango based systems.
#
# Copyright © 2018, 2020  Russel Winder <russel@winder.org.uk>
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

import os
import pathlib

from PkgConfig import get_pkgconfig_data
from GNUInstall import get_paths

build_directory_path = pathlib.Path('bin_scons')
ddoc_directory_path = pathlib.Path('DDoc')

# Versions of dependencies as in Debian Buster (Stable as at 2020-03-10) and later.
gtk_flags, gtk_libs = get_pkgconfig_data('gtkd-3', version='>= 3.8.5')
fontconfig_flags, fontconfig_libs = get_pkgconfig_data('fontconfig', version='>= 2.13.1')
pangoft2_flags, pangoft2_libs = get_pkgconfig_data('pangoft2', version='>= 1.42.4')

dependency_flags = gtk_flags + fontconfig_flags + pangoft2_flags
# Multiple copies of the option -pthread get added to the flags, ldc2 really doesn't like this option at all.
dependency_flags = [f for f in dependency_flags if f != '-pthread']

# pkgconfig gives GCC style library flags, ldc2 requires DMD style library flags.
def dmd_style_link_flags(libs_list):
    return [f'-L{flag}' for flag in libs_list]

dependency_libs = dmd_style_link_flags(gtk_libs) + dmd_style_link_flags(fontconfig_libs) + dmd_style_link_flags(pangoft2_libs)

environment =  Environment(
    tools=['ldc', 'link'],
    #DFLAGS=['-g', '-gc', '-d-debug', '-J.', '-Jsource/resource'] + dependency_flags,
    DFLAGS=['-O', '-release', '-J.', '-Jsource/resource'] + dependency_flags,
    DLINKFLAGS=['-link-defaultlib-shared'] + dependency_libs,
    ENV=os.environ,
)

fontconfig_module = environment.Command('generated/fontconfig.d', '/usr/include/fontconfig/fontconfig.h', 'dstep -o $TARGET $SOURCE')
NoClean(fontconfig_module)

source = Glob('source/*.d')

application = environment.ProgramAllAtOnce((build_directory_path / 'gfontbrowser').as_posix(), source +  fontconfig_module)

unitthreaded_flags, unitthreaded_libs = get_pkgconfig_data('unit-threaded')  # Whatever version is available, it must be provided locally.
unitthreaded_libs = dmd_style_link_flags(unitthreaded_libs)

test_environment = environment.Clone()
test_environment.Append(DFLAGS=['-unittest'] + unitthreaded_flags)
test_environment.Append(DLINKFLAGS=unitthreaded_libs)

test_source = [item for item in source if item.name != 'main.d']

module_names_for_testing =  ', '.join([f'"{f.name.replace(".d", "")}"' for f in test_source])

with open('generated/ut_scons_main.d', 'w+') as test_main_file:
    test_main_file.write(f'''
//Automatically generated, do not edit by hand.
import unit_threaded.runner : runTestsMain;

mixin runTestsMain!({module_names_for_testing});
''')
    test_source.append(test_main_file.name)

test = test_environment.ProgramAllAtOnce((build_directory_path / 'gfontbrowser_test').as_posix(), test_source + fontconfig_module)

Default(environment.Alias('build', application))
environment.Command('run', application, './$SOURCE')
test_environment.Alias('build_test', test)
test_environment.Command('test', test, './$SOURCE')

environment.Command('ddoc', source + fontconfig_module, f'$DC -Dd={ddoc_directory_path.as_posix()} $DFLAGS $DLINKFLAGS $SOURCES')

Clean('.', [build_directory_path.as_posix(), ddoc_directory_path.as_posix()])
