[![Travis-CI](https://travis-ci.org/russel/GFontBrowser_D.svg?branch=master)](https://travis-ci.org/russel/GFontBrowser)
[![Licence](https://img.shields.io/badge/license-GPL_3-green.svg)](https://www.gnu.org/licenses/gpl-3.0.txt)

# GFontBrowser — A font browser for GTK+, Fontconfig, Pango based systems.

## Introduction

This applications allows browsing and investigating the fonts that are installed on your system – which is
assumed to be one on which GTK+3, Fontconfig, and Pango are installed.

This application was originally to solve a fonts browsing problem I had that no GNOME tool solved (there
still isn't), and it serves that purpose – though it could be improved a lot.

## Building for Yourself

The de facto build system for D programs is Dub and so there is a Dub build capability. Increasingly Meson
is the de facto build tool for GTK-related builds on Linux, so there is a Meson build capability. I like
SCons so that it supported as well.

Dub and SCons work directly in the project directory, but they are nonetheless out-of-tree builds. So you
can run:

    dub build

or:

    scons

in the project directory to build the project. Both builds support build, run, and test targets.

As an example of building using Meson, if this clone is in ~/Repositories/Git/GFontBrowser\_D,
then create a build location, for example ~/BuildArea/GFontBrowser\_D, cd to that directory and then:

    meson --prefix=$HOME/Built ~/Repositories/Git/GFontBrowser_C++

will construct a Ninja build. Then:

    ninja
    ninja install

should do the right thing building and installing the executable. It is assumed people have a ~/Built place
for installing things they build themselves. You may need to adjust accordingly.

## Licence

This code is licenced under GPLv3. [![Licence](https://img.shields.io/badge/license-GPL_3-green.svg)](https://www.gnu.org/licenses/gpl-3.0.txt)
