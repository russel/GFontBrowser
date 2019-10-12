# -*- mode:python; coding:utf-8; -*-

#  GFontBrowser — A font browser for GTK+, Fontconfig, Pango based systems.
#
#  Copyright © 2017–2019  Russel Winder <russel@winder.org.uk>
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

prefix = get_option('prefix')
datadir = get_option('datadir')
applicationsdir = join_paths(datadir, 'applications')
iconsdir = join_paths(datadir, 'icons')

conf_data = configuration_data()
conf_data.set('PREFIX', prefix)
configure_file(
    input: 'gfontbrowser.desktop.in',
    output: 'gfontbrowser.desktop',
    configuration: conf_data,
    install_dir: applicationsdir
)

# install_data('gfontbrowser.png', install_dir: iconsdir)
install_data('../source/resource/gfontbrowser.svg', install_dir: iconsdir)
