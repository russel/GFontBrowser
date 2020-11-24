//  GFontBrowser — A font browser for GTK+, Fontconfig, Pango based systems.
//
//  Copyright © 2018–2020  Russel Winder <russel@winder.org.uk>
//
//  This program is free software: you can redistribute it and/or modify it under the terms of
//  the GNU General Public License as published by the Free Software Foundation, either version
//  3 of the License, or (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
//  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//  See the GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along with this program.
//  If not, see <http://www.gnu.org/licenses/>.

/**
 * @file
 *
 * This file contains the code associated with configuration options.
 *
 * @author Russel Winder <russel@winder.org.uk>
 */

import std.algorithm: map;
import std.conv: to;
import std.string: split, strip;

/// The name of the application.
public immutable applicationName = "GFontBrowser";
/// The GTK+ application Id.
public immutable applicationId = "uk.org.winder.GFontBrowser";
/// The version number of the application.
public immutable versionNumber = import("VERSION").strip();

version(unittest) {
    import unit_threaded;
}

@("versionNumberIsVaguelyReasonable")
unittest {
    immutable result = versionNumber.split(".");
    result.length.should == 3;
    foreach (x; result) {
        to!uint(x);  // Throws std.conv.ConvException on error which causes the test to fail.
    }
}

//  Local Variables:
//  mode: d
//  indent-tabs-mode: nil
//  c-basic-offset: 4
//  tab-width: 4
//  End:

//  vim: et ci pi sts=0 sw=4 ts=4
