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

import std.algorithm: sort;
import std.string: strip;
import std.stdio: writeln;

import core.stdc.stdlib: exit;

import gtk.Application;
import gtk.ApplicationWindow;
import gtk.Builder;

import gtk.Button;
import gtk.CellRendererText;
import gtk.EditableIF;
import gtk.Entry;
import gtk.ListStore;
import gtk.SpinButton;
import gtk.TreeView;
import gtk.TreeViewColumn;

import gdk.Event;

import configuration: versionNumber;
import fontCatalogue: getFamilyMap;

private ApplicationWindow applicationWindow = null;
private TreeView familyList = null;
private TreeView presentationList = null;
private Entry sampleText = null;
private SpinButton fontSize = null;

ApplicationWindow getApplicationWindow(Application application) {
	if (applicationWindow is null) {
		auto builder = new Builder();
		if (!builder.addFromString(strip(import("gfontbrowser.glade")))) {
			writeln("Could not create widgets from the Glade file :-(");
			exit(1);
		}
		applicationWindow = cast(ApplicationWindow) builder.getObject("applicationWindow");
		assert(applicationWindow !is null);
		application.addWindow(applicationWindow);
		familyList = cast(TreeView)builder.getObject("familyList");
		auto familyListStore = new ListStore([GType.STRING]);
		writeln(*getFamilyMap());
		foreach (item; getFamilyMap().keys.sort) {
			auto iterator = familyListStore.createIter();
			//writeln(item);
			familyListStore.setValue(iterator, 0, item);
		}
		familyList.setModel(familyListStore);
		familyList.appendColumn(new TreeViewColumn("Font Family", new CellRendererText(), "text", 0));
		presentationList = cast(TreeView)builder.getObject("presentationList");
		sampleText = cast(Entry)builder.getObject("sampleText");
		sampleText.addOnChanged(delegate void(EditableIF ei) {
			writeln("sampleText changed.");
		});
		fontSize = cast(SpinButton)builder.getObject("fontSize");
		fontSize.addOnValueChanged(delegate void(SpinButton sb) {
			writeln("fontSize changed.");
		});
		applicationWindow.setTitle("GFontBrowser");
		applicationWindow.showAll();
	}
	return applicationWindow;
}
