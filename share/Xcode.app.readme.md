# The role of the dummy `/Applications/Xcode.app`

Don't remove it, it's used for disabling the Developer category in Spotlight
[](http://apple.stackexchange.com/a/181326/67191)

Installation:

```sh
touch /Applications/Xcode.app
ln -s "$DOTFILES_SHARED"/share/Xcode.app.readme.md /Applications/
```

Then System Preferences > Spotlight > Uncheck "Developer"

## 2024-01-23

Change of plans: enable developer search by default, use "Spotlight Privacy" for exclusion.

## 2023-07-08

It seems it's still there in some form. But quickly accessing some dev files can be useful. So,
decided to add large projects to Spotlight Privacy tab.

## 2022-03-13

New MacBook Pro 16": code files are still included in Spotlight. Thought of ignoring ~/Code in the
Privacy tab, but ... ?

## 2021-12-24

Renamed from .bak due to performance & "indexing..." issues

## 2021-12-19

Monterey (12.0.1): Still happening. Renamed to .bak for now since Code is ignored

## 2020-12-13

Installed Big Sur. Renamed to .bak. Full hard disk "Macintosh HD" is ignored in Privacy tab anyway.
... but it's still indexing source code. So back to the fake app...

## 2019-10-23

:( code files started appearing again... Renamed back.

## 2018-09

It looks like it's fixed in Mojave (or was already fixed)

## 2019-01-17

Still indexing and Developer option is not visible. Restoring the dummy back.

## 2019-10-11

After Catalina, `brew upgrade` reports "Xcode is not installed/outdated". Renamed to ....bak.
