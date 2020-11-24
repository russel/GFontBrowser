//  GFontBrowser — A font browser for GTK+, Fontconfig, Pango based systems.
//
//  Copyright © 2017–2020  Russel Winder <russel@winder.org.uk>
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
 * This file contains the code associated with creating and using the GFontBrowser `AboutDialog`.
 *
 * @author Russel Winder <russel@winder.org.uk>
 */

import std.string: strip;

import gtk.AboutDialog;
import gtk.Window;

import gdk.Pixbuf;
import gdkpixbuf.PixbufLoader;

import configuration: applicationName, applicationId, versionNumber;

/**
 * Construct the GFontBrowser `AboutDialog`.
 *
 * @return a reference to the `AboutDialog`.
 */
private AboutDialog create() {
    auto about = new AboutDialog();
    string[] authors;
    authors ~= "Russel Winder <russel@winder.org.uk>";
    string[] documentors;
    about.setAuthors(authors);
    about.setComments("A font browser for GTK+, Fontconfig, Pango based system.");
    about.setCopyright("Copyright © 2013–2014, 2017–2020  Russel Winder <russel@winder.org.uk>");
    about.setDocumenters(documentors);
    about.setLicense("This program is licenced under GNU General Public Licence (GPL) version 3.");
    auto loader = new PixbufLoader();
    loader.setSize(180, 147);
    loader.write(cast(char[]) import(applicationId ~ ".svg"));
    loader.close();
    about.setLogo(loader.getPixbuf());
    about.setName(applicationName);
    about.setProgramName(applicationName);
    //about.setTranslatorCredits("Translator Credits");
    about.setVersion(versionNumber);
    return about;
}

/**
 * Show the GFontBrowser `AboutDialog` in a non-modal way and return, unless one is already
 * being displayed in which case just return.
 *
 * @param parent the (temporary) parent of the `AboutDialogue`.
 */
public void showAbout(Window parent) {
    static bool active = false;
    if (!active) {
        auto dialog = create();
        dialog.setTransientFor(parent);
        dialog.addOnResponse(delegate void(_, d) {
            d.destroy();
            active = false;
        });
        dialog.show();
        active = true;
    }
}

//  Local Variables:
//  mode: d
//  indent-tabs-mode: nil
//  c-basic-offset: 4
//  tab-width: 4
//  End:

//  vim: et ci pi sts=0 sw=4 ts=4
