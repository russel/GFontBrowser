//  GFontBrowser — A font browser for GTK+, Fontconfig, Pango based systems.
//
//  Copyright © 2013–2014, 2017–2020  Russel Winder <russel@winder.org.uk>
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
 * This file contains the code associated with creating and using the `ApplicationWindow` for
 * this `Application`.
 *
 * @author Russel Winder <russel@winder.org.uk>
 */

import std.algorithm: sort;
import std.array: array;
import std.string: strip;
import std.stdio: writeln;

import core.stdc.stdlib: exit;

import gio.Menu;
import gio.SimpleAction;

import gtk.Application;
import gtk.ApplicationWindow;
import gtk.Builder;
import gtk.Button;
import gtk.CellRendererText;
import gtk.EditableIF;
import gtk.Entry;
import gtk.HeaderBar;
import gtk.Image;
import gtk.ListStore;
import gtk.MenuButton;
import gtk.SpinButton;
import gtk.TreePath;
import gtk.TreeView;
import gtk.TreeViewColumn;
import gtk.c.types: GtkIconSize;

import gdk.Event;

import about: showAbout;
import configuration: applicationName, applicationId, versionNumber;
import fontCatalogue: getFamilyMap;
import presentation: PresentationDialog, PresentationListStore, PresentationTreeView, 
    onSampleTextChanged, onFontSizeChanged;

private ApplicationWindow applicationWindow = null;
private TreeView familyList = null;
private PresentationTreeView presentationList = null;
private Entry sampleText = null; // Access needed by presentation module.
private SpinButton fontSize = null;  // Access needed by presentation module.

/**
 * Returns the GFontBrowser `ApplicationWindow`.
 *
 * @param application the `Application` this `ApplicationWindow` is for.
 */
ApplicationWindow getApplicationWindow(Application application) {
    if (applicationWindow is null) {
        auto builder = new Builder();
        if (!builder.addFromString(strip(import(applicationId ~ ".glade")))) {
            writeln("Could not create widgets from the Glade file :-(");
            exit(1);
        }
        applicationWindow = cast(ApplicationWindow) builder.getObject("applicationWindow");
        assert(applicationWindow !is null);
        application.addWindow(applicationWindow);
        familyList = cast(TreeView)builder.getObject("familyList");
        assert(familyList !is null);
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
        assert(sampleText !is null);
        sampleText.addOnChanged(delegate void(EditableIF ei) {
            onSampleTextChanged(sampleText.getText);
        });
        fontSize = cast(SpinButton)builder.getObject("fontSize");
        assert(fontSize !is null);
        fontSize.addOnValueChanged(delegate void(SpinButton sb) {
            onFontSizeChanged(fontSize.getValue);
        });
        auto headerBar = new HeaderBar();
        headerBar.setTitle(applicationName);
        headerBar.setShowCloseButton(true);
        auto menuButton = new MenuButton();
        auto menuButtonImage = new Image();
        menuButtonImage.setFromIconName("open-menu-symbolic", GtkIconSize.BUTTON);
        menuButton.setImage(menuButtonImage);
        auto menuBuilder = new Builder();
        menuBuilder.addFromString(import("application_menu.xml"));
        auto applicationMenu = cast(Menu)menuBuilder.getObject("application_menu");
        assert(applicationMenu !is null);
        auto aboutAction = new SimpleAction("about", null);
        aboutAction.addOnActivate(delegate void(_, __){ showAbout(applicationWindow); });
        applicationWindow.addAction(aboutAction);
        menuButton.setMenuModel(applicationMenu);
        headerBar.packEnd(menuButton);
        applicationWindow.setTitlebar(headerBar);
        applicationWindow.setTitle(applicationName);
        applicationWindow.showAll();
    }
    return applicationWindow;
}

//  Local Variables:
//  mode: d
//  indent-tabs-mode: nil
//  c-basic-offset: 4
//  tab-width: 4
//  End:

//  vim: et ci pi sts=0 sw=4 ts=4
