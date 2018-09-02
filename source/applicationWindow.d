//  GFontBrowser — A font browser for GTK+, Fontconfig, Pango based systems.
//
//  Copyright © 2013–2014, 2017, 2018  Russel Winder <russel@winder.org.uk>
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

import std.string: strip;
import std.stdio: writeln;

import core.stdc.stdlib: exit;

import gtk.Application;
import gtk.ApplicationWindow;
import gtk.Builder;

import gtk.Button;
import gtk.Widget;

import gdk.Event;

import configuration: versionNumber;

extern (C) void quit() {
  exit(0);
}

extern (C) void refreshFontSize() {
  writeln("refreshFontSize");
}

extern (C) void refreshSampleText() {
  writeln("refreshSampleText");
}

extern (C) void familyListSingleClicked() {
  writeln("familyListSingleClicked");
}

extern (C) void familyListDoubleClicked() {
  writeln("familyListDoubleClicked");
}

private ApplicationWindow applicationWindow = null;
private Widget familyList = null;
private Widget presentationList = null;
private Widget sampleText = null;
private Widget fontSize = null;

ApplicationWindow getApplicationWindow(Application application) {
	if (applicationWindow is null) {
		auto builder = new Builder();
		if (!builder.addFromString(strip(import("gfontbrowser.glade")))) {
			writeln("Could not create widgets from the Glade file :-(");
			exit(1);
		}
		builder.connectSignals(null);
		applicationWindow = cast(ApplicationWindow) builder.getObject("applicationWindow");
		assert(applicationWindow !is null);
		application.addWindow(applicationWindow);
		familyList = cast(Widget) builder.getObject("familyList");
		presentationList = cast(Widget) builder.getObject("presentationList");
		sampleText = cast(Widget) builder.getObject("sampleText");
		fontSize = cast(Widget) builder.getObject("fontSize");
		applicationWindow.setTitle("GFontBrowser");
		applicationWindow.showAll();
	}
	return applicationWindow;
}
