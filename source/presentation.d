//  GFontBrowser — A font browser for GTK+, Fontconfig, Pango based systems.
//
//  Copyright © 2018, 2020  Russel Winder <russel@winder.org.uk>
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
//
//  Author:  Russel Winder <russel@winder.org.uk>

import std.algorithm: remove;
import std.conv: to;
import std.process: spawnProcess;
import std.stdio: writeln;

import gtk.ApplicationWindow;
import gtk.CellRendererText;
import gtk.Dialog;
import gtk.ListStore;
import gtk.TreeIter;
import gtk.TreePath;
import gtk.TreeView;
import gtk.TreeViewColumn;

import gobject.Value;

import pango.PgFontDescription;

import configuration: applicationName;
import fontCatalogue: getFamilyMap, getFontStyle, getFontFileName, getFontDescription, isVisible;

private PresentationTreeView[] registry;

/**
 * Enumeration over the column numbers of the `PresentationListStore` which is the
 * data model for rendering the sample text in all the `PresentationTreeView`s
 */
enum ColumnNumber {
    style, // = 0
    visibility,
    sampleText,
    fontFilePath,
    fontDescription,
}

/**
 * Class to represent the data model for rendering a typeface and it's fonts.
 */
class PresentationListStore: ListStore {
    this(string familyName, string sampleText, double fontSize) {
        super([
        GType.STRING,  // ColumnNumber.style
        GType.STRING,  // ColumnNumber.visibility
        GType.STRING,  // ColumnNumber.sampleText
        GType.STRING,  // ColumnNumber.fontFilePath
        PgFontDescription.getType,  // ColumnNumber.fontDescription, gets Boxed.
        ]);
        foreach (pattern; getFamilyMap.get(familyName, [])) {
            auto iter = createIter;
            auto fontDescription = getFontDescription(pattern);
            fontDescription.setSize(to!int(fontSize * PANGO_SCALE));
            setValue(iter, ColumnNumber.style, getFontStyle(pattern));
            setValue(iter, ColumnNumber.visibility, isVisible(pattern) ? "*": " ");
            setValue(iter, ColumnNumber.sampleText, sampleText);
            setValue(iter, ColumnNumber.fontFilePath, getFontFileName(pattern));
            setValue(iter, ColumnNumber.fontDescription, fontDescription);
        }
    }
}

/**
 * Class to represent the renderer of a typeface and it's fonts.
 */
class PresentationTreeView: TreeView {
    private void initialise() {
        appendColumn(new TreeViewColumn("Font Style", new CellRendererText(), "text", ColumnNumber.style));
        appendColumn(new TreeViewColumn(" ", new CellRendererText(), "text", ColumnNumber.visibility));
        auto sampleTextRenderer = new CellRendererText();
        auto sampleTextColumn = new TreeViewColumn("Sample Text", sampleTextRenderer, "text", ColumnNumber.sampleText);
        sampleTextColumn.setResizable(true);
        sampleTextColumn.addAttribute(sampleTextRenderer, "font-desc", ColumnNumber.fontDescription);
        appendColumn(sampleTextColumn);
        appendColumn(new TreeViewColumn("Font File Path", new CellRendererText(), "text", ColumnNumber.fontFilePath));
        addOnRowActivated(delegate void(TreePath tp, TreeViewColumn tvc, TreeView tv) {
            auto model = tv.getModel;
            auto iter = tv.getSelection.getSelected;
            spawnProcess(["gnome-font-viewer", model.getValueString(iter, ColumnNumber.fontFilePath)]);
        });
        registry ~= this;
    }

    this(TreeView tv) {
        super(tv.getTreeViewStruct);
        initialise();
    }

    this(string familyName) {
        initialise();
    }

    ~this() {
        foreach (i; 0..registry.length) {
            if (this == registry[i]) {
                registry.remove(i);
                break;
            }
        }
    }
}

/**
 * Class for a dialogue rendering a typeface and it's fonts.
 */
class PresentationDialog: Dialog {
    this(ApplicationWindow parent, string familyName, string sampleText, double fontSize) {
        super(applicationName ~ " — " ~ familyName, parent, DialogFlags.DESTROY_WITH_PARENT, cast(string[])null, null);
        auto presentationTreeView = new PresentationTreeView(familyName);
        presentationTreeView.setModel(new PresentationListStore(familyName, sampleText, fontSize));
        getContentArea.packStart(presentationTreeView, true, true, 0);
        showAll();
    }
}

/**
 * Event handler for any change in the sample text of the application window.
 *
 * Params:
 *     newSize = the new sample test to render in all the `PresentationTreeView` instances
 *       by iterating over all the `PresentationListStore` instances.
 */
void onSampleTextChanged(string newText) {
    foreach(view; registry){
        auto model = cast(ListStore)view.getModel;
        TreeIter iter;
        if (model.getIterFirst(iter)) {
            do {
                model.setValue(iter, ColumnNumber.sampleText, newText);
            } while (model.iterNext(iter));
        }
    }
}

/**
 * Event handler for any change in the sample font size of the application window.
 *
 * Params:
 *     newSize = the new font size (in points) to render all the sample texts in all the
 *       `PresentationTreeView` instances by iterating over all the `PresentationListStore`
 *       instances.
 */
void onFontSizeChanged(double newSize) {
    foreach(view; registry){
        auto model = cast(ListStore)view.getModel;
        TreeIter iter;
        if (model.getIterFirst(iter)) {
            do {
                auto object = model.getValue(iter, ColumnNumber.fontDescription).getBoxed;
                auto fontDescription = new PgFontDescription(cast(PangoFontDescription*)object);
                fontDescription.setSize(to!int(newSize * PANGO_SCALE));
                model.setValue(iter, ColumnNumber.fontDescription, fontDescription);
            } while (model.iterNext(iter));
        }
    }
}

//  Local Variables:
//  mode: d
//  indent-tabs-mode: nil
//  c-basic-offset: 4
//  tab-width: 4
//  End:

//  vim: et ci pi sts=0 sw=4 ts=4
