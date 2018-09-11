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
import std.array: array;
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
import gtk.TreePath;
import gtk.TreeView;
import gtk.TreeViewColumn;

import gdk.Event;

import configuration: versionNumber;
import fontCatalogue: getFamilyMap;
import presentation: PresentationDialog, PresentationListStore, PresentationTreeView,
	onSampleTextChanged, onFontSizeChanged;

private ApplicationWindow applicationWindow = null;
private TreeView familyList = null;
private PresentationTreeView presentationList = null;
private Entry sampleText = null; // Access needed by presentation module.
private SpinButton fontSize = null;  // Access needed by presentation module.

ApplicationWindow getApplicationWindow(Application application) {
	if (applicationWindow is null) {
		auto builder = new Builder();
		if (!builder.addFromString(strip(import("gfontbrowser.glade")))) {
			writeln("Could not create widgets from the Glade file :-(");
			exit(1);
		}
		applicationWindow = cast(ApplicationWindow) builder.getObject("applicationWindow");
		application.addWindow(applicationWindow);
		familyList = cast(TreeView)builder.getObject("familyList");
		auto familyListStore = new ListStore([GType.STRING]);
		auto familyListData = getFamilyMap.keys.sort.array;
		foreach (item; familyListData) {
			auto iterator = familyListStore.createIter();
			familyListStore.setValue(iterator, 0, item);
		}
		familyList.setModel(familyListStore);
		familyList.appendColumn(new TreeViewColumn("Font Family", new CellRendererText(), "text", 0));
		familyList.addOnCursorChanged(delegate void(TreeView tv) {
			TreePath tp = null;
			TreeViewColumn tvc = null;
			tv.getCursor(tp, tvc);
			presentationList.setModel(new PresentationListStore(familyListData[tp.getIndices[0]], sampleText.getText, fontSize.getValue));
		});
		familyList.addOnRowActivated(delegate void(TreePath tp, TreeViewColumn tvc, TreeView tv) {
			new PresentationDialog(applicationWindow, familyListData[tp.getIndices[0]],sampleText.getText, fontSize.getValue);
		});
		presentationList = new PresentationTreeView(cast(TreeView)builder.getObject("presentationList"));
		sampleText = cast(Entry)builder.getObject("sampleText");
		sampleText.addOnChanged(delegate void(EditableIF ei) {
			onSampleTextChanged(sampleText.getText);
		});
		fontSize = cast(SpinButton)builder.getObject("fontSize");
		fontSize.addOnValueChanged(delegate void(SpinButton sb) {
			onFontSizeChanged(fontSize.getValue);
		});
		applicationWindow.setTitle("GFontBrowser");
		applicationWindow.showAll();
	}
	return applicationWindow;
}

//  Local Variables:
//  mode: d
//  indent-tabs-mode: t
//  c-basic-offset: 4
//  tab-width: 4
//  End:

//  vim: noet ci pi sts=0 sw=4 ts=4