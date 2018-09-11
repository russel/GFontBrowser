//  GFontBrowser — A font browser for GTK+, Fontconfig, Pango based systems.
//
//  Copyright © 2018  Russel Winder <russel@winder.org.uk>
//
//  This program is free software: you can redistribute it and/or modify it under the terms of the GNU
//  General Public License as published by the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
//  the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
//  License for more details.
//
//  You should have received a copy of the GNU General Public License along with this program. If not, see
//  <http://www.gnu.org/licenses/>.

import std.conv: to;
import std.file: exists;
import std.string: fromStringz, toStringz;

import pango.PgFontDescription;

import fontconfig;

//  It appears that GtkD assumes that Fontconfig is totally hidden by Pango and so does not give D style
//  access to the Fontconfig pattern to Pango font description parser. GtkD Pango binding similarly does not
//  expose functions that explicitly manipulate Fontconfig patterns. Of course Pango does have this function
//  so we can make use of it rather than trying to write our own.
//
//  However, the parser seems to have a problem with PostScript Type fonts called Book which it renders as
//  Bold.

extern(C) {
	PangoFontDescription * pango_fc_font_description_from_pattern(FcPattern * pattern, bool include_size);
}

/**
 *  The default configuration used by Fontconfig.
 */
private FcConfig * configuration;

alias FamilyMap = FcPattern*[][string];

/**
 *  An index into an <code>FcFontSet</code> that collects together all the styles associated with a given
 *  family. The value used is a pointer into the data, this data structure does not own the data.
 */
private FamilyMap familyMap;

void initialise() {
	configuration = FcInitLoadConfigAndFonts();
	if (! configuration) { throw new Exception("Cannot initialize Fontconfig library."); }
	auto fcFontSet = FcConfigGetFonts(configuration, FcSetName.FcSetSystem);
	if (! fcFontSet) { throw new Exception("Failed to create the font set."); }
	for (auto i = 0; i < fcFontSet.nfont; ++i) {
		auto pattern = fcFontSet.fonts[i];
		familyMap[getFontFamily(pattern)] ~= pattern;
	}
}

private void processDirectoryList(FcStrList * directoryList) {
	for (auto directoryName = FcStrListNext(directoryList); directoryName; directoryName = FcStrListNext(directoryList)) {
		processDirectoryEntry(directoryName);
	}
}

private void processDirectoryEntry(FcChar8 * directoryName) {
	auto dirName = to!string(directoryName);
	if (! dirName.exists) { return; }
	auto directoryFontSet = FcFontSetCreate();
	if (! directoryFontSet) { throw new Exception("Failed to create the font set for: " ~ dirName); }
	auto subdirectorySet = FcStrSetCreate();
	if (! subdirectorySet) { throw new Exception("Failed to create the subdirectory names set for directory: " ~ dirName); }
	//  TODO: Although this allows us to get the list of faces in the directory, it doesn't put them in the
	//  list that can be rendered; this should be fixed.
	auto returnCode = FcDirScan(directoryFontSet, subdirectorySet, null, FcConfigGetBlanks(configuration), directoryName, FcTrue);
	if (returnCode == FcFalse) { throw new Exception("Failed to scan directories with FcDirScan: " ~ dirName); }
	for (auto i = 0; i < directoryFontSet.nfont; ++i) {
		auto pattern = directoryFontSet.fonts[i];
		FcValue value;
		if (FcPatternGet(pattern, FC_FAMILY, 0, &value) != FcResult.FcResultMatch) { throw new Exception("Failed to find the family name for a font in: " ~ dirName); }
		if (value.type != FcType.FcTypeString) { throw new Exception("Return property is of the wrong type: " ~ dirName); }
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

void initialize(string[] directories) {
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

FamilyMap * getFamilyMap() { return &familyMap; }

string getStringProperty(string property, FcPattern * pattern) {
	FcChar8 * returnValue;
	if (FcPatternGetString(pattern, cast(char*)property.toStringz, 0, &returnValue) != FcResult.FcResultMatch) {
		throw new Exception("Failed to find the string property: " ~ property);
	}
	return to!string((cast(char*)returnValue).fromStringz);
}

string getFontFamily(FcPattern * pattern) { return getStringProperty(FC_FAMILY, pattern); }

string getFontStyle(FcPattern * pattern) { return getStringProperty(FC_STYLE, pattern); }

string getFontFileName(FcPattern * pattern) { return getStringProperty(FC_FILE, pattern); }

PgFontDescription getFontDescription(FcPattern * pattern) {
	return new PgFontDescription(pango_fc_font_description_from_pattern(pattern, false), false);
}

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
//  indent-tabs-mode: t
//  c-basic-offset: 4
//  tab-width: 4
//  End:

//  vim: noet ci pi sts=0 sw=4 ts=4
