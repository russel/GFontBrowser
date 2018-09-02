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

from SCons_PkgConfig import get_pkgconfig_flags
from SCons_GNUInstall import get_paths

build_directory_path = pathlib.Path('scons_build')

# unit-threaded test driver generator is locally built so we need it's location.
built_prefix, built_bindir, built_datadir, built_libdir = get_paths(prefix=os.path.join(os.environ['HOME'], 'Built'))

gtk_cflags_flags, gtk_libs_flags = get_pkgconfig_flags('gtkd-3')

unit_threaded_cflags, unitthreaded_libs = get_pkgconfig_flags('unit-threaded')
unit_threaded_libs = ['-L{}'.format(flags) for flags in unitthreaded_libs]

# Need the -Wl,--export-dynamic option to the linker to avoid the
# "Could not find signal handler XXXX.  Did you compile with -rdynamic?"
# problem at run time.

environment =  Environment(
    tools=['ldc', 'link'],
    #DFLAGS=['-g', '-gc', '-d-debug', '-J.', '-Jsource/resource'],
    DFLAGS=['-O', '-release', '-J.', '-Jsource/resource'] + gtk_cflags_flags + gtk_libs_flags,
    DLINKFLAGS=['-link-defaultlib-shared', '-L-Wl,--export-dynamic'],
    ENV=os.environ,
)

test_environment = environment.Clone()
test_environment.Append(DFLAGS=['-unittest'] + unit_threaded_cflags)
test_environment.Append(DLINKFLAGS=unit_threaded_libs)

source = Glob('source/*.d')
application = environment.ProgramAllAtOnce((build_directory_path / 'gfontbrowser').as_posix(), source)

test_main = test_environment.Command('generated/ut_main.d', source, 'gen-ut-main -f $TARGET source')
test = test_environment.ProgramAllAtOnce((build_directory_path / 'gfontbrowser_test').as_posix(), source + [test_main])

Default(environment.Alias('build', application))
environment.Command('run', application, './$SOURCE')
test_environment.Command('test', test, './$SOURCE')

Clean('.', [build_directory_path.as_posix(), 'generated'])
