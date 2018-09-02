# -*- mode:python; coding:utf-8; -*-

#  GFontBrowser — A font browser for GTK+, Fontconfig, Pango based systems.
#
#  Copyright © 2017, 2018  Russel Winder <russel@winder.org.uk>
#
#  This program is free software: you can redistribute it and/or modify it under the terms of the GNU
#  General Public License as published by the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
#  the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
#  License for more details.
#
#  You should have received a copy of the GNU General Public License along with this program.  If not, see
#  <http://www.gnu.org/licenses/>.
#
#  Author: Russel Winder <russel@winder.org.uk>

data_directory_process = run_command('python3', ['-c',  'import os; print(os.environ.get("XDG_DATA_HOME", os.path.join(os.environ["HOME"], ".local", "share")))'])
data_directory = data_directory_process.stdout().strip()

desktop_target = custom_target('desktop-file',
    input: 'gfontbrowser.desktop.in',
    output: 'gfontbrowser.desktop',
    command: [find_program('sed'), 's,@PREFIX@,' + get_option('prefix') + ',; w @OUTPUT@', '@INPUT@'],
    install: true,
    install_dir: join_paths(data_directory, 'applications'),
)

install_data('gfontbrowser.png', install_dir: join_paths(get_option('datadir'), 'pixmaps'))
