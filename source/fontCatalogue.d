//  GFontBrowser — A font browser for GTK+, Fontconfig, Pango based systems.
//
//  Copyright © 2018–2020  Russel Winder <russel@winder.org.uk>
//
//  This program is free software: you can redistribute it and/or modify it under the terms of
//  the GNU General Public License as published by the Free Software Foundation, either version
//  3 of the License, or (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
//  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
//  PURPOSE. See the GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along with this
//  program. If not, see <http://www.gnu.org/licenses/>.

/**
 * @file
 *
 * This file contains the code associated with construction and processing of the map of
 * typefaces and fonts.
 *
 * @author Russel Winder <russel@winder.org.uk>
 */

import std.conv: to;
import std.file: exists;
import std.string: fromStringz, toStringz;

import pango.PgFontDescription;

import fontconfig;

//  It appears that GtkD assumes that Fontconfig is totally hidden by Pango and so does not give
//  D style access to the Fontconfig pattern to Pango font description parser. GtkD Pango
//  binding similarly does not expose functions that explicitly manipulate Fontconfig
//  patterns. Of course Pango does have this function so we can make use of it rather than
//  trying to write our own. However, the parser seems to have a problem with PostScript Type
//  fonts called Book which it renders as Bold.

extern(C) {
    PangoFontDescription * pango_fc_font_description_from_pattern(FcPattern * pattern, bool include_size);
}

/**
 * The default configuration used by Fontconfig.
 */
private FcConfig * configuration;

/**
 * Type name for the associative array (aka map) that maps typeface names to
 * an array of patterns for available fonts of that typeface.
 */
alias FamilyMap = FcPattern*[][string];

/**
 * An index into an `FcFontSet` that collects together all the styles associated with
 * a given family. The value used is a pointer into the data, this data structure does
 * not own the data.
 */
private FamilyMap familyMap;

/**
 * Initialise the application using the standard set of user fonts as provided by
 * Fontconfig.
 */
void initialise_default() {
    configuration = FcInitLoadConfigAndFonts();
    if (! configuration) { throw new Exception("Cannot initialize Fontconfig library."); }
    auto fcFontSet = FcConfigGetFonts(configuration, FcSetName.FcSetSystem);
    if (! fcFontSet) { throw new Exception("Failed to create the font set."); }
    for (auto i = 0; i < fcFontSet.nfont; ++i) {
        auto pattern = fcFontSet.fonts[i];
        familyMap[getFontFamily(pattern)] ~= pattern;
    }
}

/**
 * Process all the directories in a directory list.
 *
 * @param directoryList iterator over the list of directories.
 */
private void processDirectoryList(FcStrList * directoryList) {
    for (auto directoryName = FcStrListNext(directoryList); directoryName; directoryName = FcStrListNext(directoryList)) {
        processDirectoryEntry(directoryName);
    }
}

/**
 * Process a given directory.
 *
 * @param directoryName path to the directory to process.
 */
private void processDirectoryEntry(FcChar8 * directoryName) {
    auto dirName = to!string(directoryName);
    if (! dirName.exists) { return; }
    auto directoryFontSet = FcFontSetCreate();
    if (! directoryFontSet) { throw new Exception("Failed to create the font set for: " ~ dirName); }
    auto subdirectorySet = FcStrSetCreate();
    if (! subdirectorySet) { throw new Exception("Failed to create the subdirectory names set for directory: " ~ dirName); }
    //  TODO Although this allows us to get the list of faces in the directory, it doesn't put
    //     them in the list that can be rendered; this should be fixed.
    immutable returnCode = FcDirScan(directoryFontSet, subdirectorySet, null, FcConfigGetBlanks(configuration), directoryName, FcTrue);
    if (returnCode == FcFalse) { throw new Exception("Failed to scan directories with FcDirScan: " ~ dirName); }
    for (auto i = 0; i < directoryFontSet.nfont; ++i) {
        auto pattern = directoryFontSet.fonts[i];
        FcValue value;
        if (FcPatternGet(pattern, FC_FAMILY, 0, &value) != FcResult.FcResultMatch) {
            throw new Exception("Failed to find the family name for a font in: " ~ dirName); 
        }
        if (value.type != FcType.FcTypeString) { 
            throw new Exception("Return property is of the wrong type: " ~ dirName); 
        }
        familyMap[to!string(value.u.s)] ~= pattern;
    }
    auto subdirectoryList = FcStrListCreate(subdirectorySet);
    if (! subdirectoryList) { throw new Exception("Failed to create subdirectory list in: " ~ dirName); }
    processDirectoryList(subdirectoryList);
    FcStrListDone(subdirectoryList);
    FcStrSetDestroy(subdirectorySet);
    //  NB Do not destroy directoryFontSet since this would destroy the FcPatterns we have put into family_map
    //  which would sort of ruin the whole application.
}

/**
 * Initialise the application using the fonts in an array of directories.
 *
 * @param directories array of paths to directories containing font files.
 */
void initialise_explicit(string[] directories) {
    configuration = null;
    auto directorySet = FcStrSetCreate();
    if (! directorySet) { throw new Exception("Directory set has not been made."); }
    foreach (item; directories) {
        FcStrSetAdd(directorySet, cast(FcChar8*)item.toStringz);
    }
    auto directoryList = FcStrListCreate(directorySet);
    if (! directoryList) { throw new Exception("Directory list has not been made."); }
    processDirectoryList(directoryList);
    FcStrListDone(directoryList);
}

/**
 * Getter of the associative array (aka map) that maps typeface names to an
 * array of font patterns for that typeface.
 */
FamilyMap * getFamilyMap() { return &familyMap; }

/**
 * Getter for a property of a font.
 *
 * @param property string key for the property required.
 * @param pattern the pattern for the font being queried.
 * @returns `string` value of the property requested.
 */
private string getStringProperty(string property, FcPattern * pattern) {
    FcChar8 * returnValue;
    if (FcPatternGetString(pattern, cast(char*)property.toStringz, 0, &returnValue) != FcResult.FcResultMatch) {
        throw new Exception("Failed to find the string property: " ~ property);
    }
    return to!string((cast(char*)returnValue).fromStringz);
}

/**
 * Getter for the typeface name (aka font family name) of a font.
 *
 * @param pattern the pattern for the font being queried.
  * @returns `string` of the typeface name.
*/
string getFontFamily(FcPattern * pattern) { return getStringProperty(FC_FAMILY, pattern); }

/**
 * Getter for the style of a font.
 *
 * @param pattern the pattern for the font being queried.
 * @returns `string` of the style of the font.
*/
string getFontStyle(FcPattern * pattern) { return getStringProperty(FC_STYLE, pattern); }

/**
 * Getter for the path to the file of a font.
 *
 * @param pattern the pattern for the font being queried.
 * @returns `string` of the path to the font file.
*/
string getFontFileName(FcPattern * pattern) { return getStringProperty(FC_FILE, pattern); }

/**
 * Getter for the Pango font description of a font given a FontConfig pattern.
 *
 * @param pattern the pattern for the font being queried.
 * @returns `PgFontDescription` of the font requested.
 */
PgFontDescription getFontDescription(FcPattern * pattern) {
    return new PgFontDescription(pango_fc_font_description_from_pattern(pattern, false), false);
}

/**
 * Getter for the visibility of a font.
 *
 * When using `initialise_default` all fonts should be visible. When using
 * `initialise_explicit` some fonts may be in the default set and thus visible, some
 * fonts may not be in the default set and so not visible.
 *
 * @param pattern = the pattern for the font being queried.
 * @returns `bool` value of the visibility of the font.
*/
bool isVisible(FcPattern * pattern) {

    return true; ////////////////////////////////////////////////////////////////////////////////////////////////////////////

    /*
	FcDefaultSubstitute(pattern);

#if DO_DEBUGGING
	std::cerr <<	"Just about to start substitution: " << configuration << ", " << pattern << ", " << FcMatchPattern << std::endl;
#endif

	FcBool returnCode = FcConfigSubstitute(configuration, pattern, FcMatchPattern);

#if DO_DEBUGGING
	std::cerr <<	"Just finished" << std::endl;
#endif

#if DO_DEBUGGING
	if (returnCode != FcTrue) { std::cerr << "Could not do substitutes." << std::endl; }
#endif

	FcResult result;
	FcPattern * returnValue = FcFontMatch(configuration, pattern, &result);

#if DO_DEBUGGING
	if (result != FcResultMatch) {
		std::cerr << "FcFontMatch failed, asked for " << get_font_file_name(pattern) << " got ";
		if (returnValue == 0) { std::cerr << "null returned by FcFontMatch"; }
		else { std::cerr << get_font_file_name(returnValue); }
		std::cerr << std::endl;
		return false;
	}
#endif

	return result == FcResult.FcResultMatch;
	*/
}

//  Local Variables:
//  mode: d
//  indent-tabs-mode: nil
//  c-basic-offset: 4
//  tab-width: 4
//  End:

//  vim: et ci pi sts=0 sw=4 ts=4
