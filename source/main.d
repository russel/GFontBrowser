//  GFontBrowser — A font browser for GTK+, Fontconfig, Pango based systems.
//
//  Copyright © 2013–2014, 2017–2019  Russel Winder <russel@winder.org.uk>
//
//  This program is free software: you can redistribute it and/or modify it under the terms of the GNU
//  General Public License as published by the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
//  the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
//  License for more details.
//
//  You should have received a copy of the GNU General Public License along with this program.  If not, see
//  <http://www.gnu.org/licenses/>.
//
//  Author:  Russel Winder <russel@winder.org.uk>

import std.stdio: writeln;

import gio.Application: GioApplication = Application;
import gio.ApplicationCommandLine;
import gio.MenuModel;
import gio.SimpleAction;

import glib.Util;
import glib.Variant;
import glib.VariantDict;

import gtk.Application;
import gtk.Builder;

import about: showAbout;
import applicationWindow: getApplicationWindow;
import configuration: applicationName, versionNumber;
import fontCatalogue: initialise;

version (unittest) {
    @("Gratuitous test to ensure there is at least one test.") unittest {
        assert(0 == 0);
    }
}
else {
    int main(string[] args) {
        //auto application = new Application("uk.org.winder.gfrontbrowser", GApplicationFlags.HANDLES_COMMAND_LINE);
        auto application = new Application("uk.org.winder.gfrontbrowser", GApplicationFlags.FLAGS_NONE);
        Util.setApplicationName(applicationName);
        application.addMainOption("version", 'v', GOptionFlags.NONE, GOptionArg.NONE, "Show the " ~ applicationName ~ " version.", null);
        application.addOnStartup(delegate void(GioApplication app) {
                initialise();
                auto applicationWindow = getApplicationWindow(cast(Application) app);
        });
        application.addOnActivate(delegate void(GioApplication app) {
        });
        application.addOnHandleLocalOptions(delegate int(VariantDict vd, GioApplication a){
            if (vd.contains("version")) {
                writeln(versionNumber);
                return 0;
            }
            return -1;
        });
        application.addOnCommandLine(delegate int(ApplicationCommandLine acl, GioApplication a){
            return -1;
        });
        return application.run(args);
    }
}

//  Local Variables:
//  mode: d
//  indent-tabs-mode: nil
//  c-basic-offset: 4
//  tab-width: 4
//  End:

//  vim: noet ci pi sts=0 sw=4 ts=4
