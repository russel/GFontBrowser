# -*- mode: python; coding: utf-8; -*-

# GFontBrowser — A font browser for GTK+, Fontconfig, Pango based systems.
#
# Copyright © 2018  Russel Winder <russel@winder.org.uk>
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

from SCons_PkgConfig import get_pkgconfig_data
from SCons_GNUInstall import get_paths

build_directory_path = pathlib.Path('scons_build')

# unit-threaded test driver generator is locally built so we need it's location.
built_prefix, built_bindir, built_datadir, built_libdir = get_paths(prefix=os.path.join(os.environ['HOME'], 'Built'))

def dmd_style_link_flags(libs_list):
    return ['-L{}'.format(flag) for flag in libs_list]

gtk_flags, gtk_libs = get_pkgconfig_data('gtkd-3')
fontconfig_flags, fontconfig_libs = get_pkgconfig_data('fontconfig')
pangoft2_flags, pangoft2_libs = get_pkgconfig_data('pangoft2')

dependency_flags = gtk_flags + fontconfig_flags + pangoft2_flags
dependency_libs = dmd_style_link_flags(gtk_libs) + dmd_style_link_flags(fontconfig_libs) + dmd_style_link_flags(pangoft2_libs)

unitthreaded_flags, unitthreaded_libs = get_pkgconfig_data('unit-threaded')
unitthreaded_libs = dmd_style_link_flags(unitthreaded_libs)

# Need the -Wl,--export-dynamic option to the linker to avoid the
# "Could not find signal handler XXXX.  Did you compile with -rdynamic?"
# problem at run time.

environment =  Environment(
    tools=['ldc', 'link'],
    #DFLAGS=['-g', '-gc', '-d-debug', '-J.', '-Jsource/resource'],
    DFLAGS=['-O', '-release', '-J.', '-Jsource/resource'] + dependency_flags,
    DLINKFLAGS=['-link-defaultlib-shared'] + dependency_libs,
    ENV=os.environ,
)

test_environment = environment.Clone()
test_environment.Append(DFLAGS=['-unittest'] + unitthreaded_flags)
test_environment.Append(DLINKFLAGS=unitthreaded_libs)

source = Glob('source/*.d')
fontconfig_module = environment.Command('generated/fontconfig.d', '/usr/include/fontconfig/fontconfig.h', 'dstep -o $TARGET $SOURCE')
NoClean(fontconfig_module)
application = environment.ProgramAllAtOnce((build_directory_path / 'gfontbrowser').as_posix(), source + [fontconfig_module])

test_main = test_environment.Command('generated/ut_main.d', source, 'gen-ut-main -f $TARGET source')
test = test_environment.ProgramAllAtOnce((build_directory_path / 'gfontbrowser_test').as_posix(), source + [fontconfig_module, test_main])

Default(environment.Alias('build', application))
environment.Command('run', application, './$SOURCE')
test_environment.Alias('build_test', test)
test_environment.Command('test', test, './$SOURCE')

Clean('.', [build_directory_path.as_posix()])
