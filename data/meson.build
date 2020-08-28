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
#
#  Author: Russel Winder <russel@winder.org.uk>

prefix = get_option('prefix')
datadir = get_option('datadir')

application_id = 'uk.org.winder.GFontBrowser'

#install_data(
#    '@0@.png'.format(application_id),
#    install_dir: datadir / 'icons' / 'hicolor' / '48x48' / 'apps')

install_data(
    '../source/resource/@0@.svg'.format(application_id),
    install_dir: datadir / 'icons' / 'hicolor' / 'scalable' / 'apps')

install_data(
    '@0@.desktop'.format(application_id),
    install_dir: datadir / 'applications')

install_data(
    '@0@.appdata.xml'.format(application_id),
    install_dir: datadir / 'appdata')
