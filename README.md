# Devil Daggers Practice Tool

A small command-line tool that lets you switch your active spawnset for
[Devil Daggers](https://store.steampowered.com/app/422970/Devil_Daggers/)
on Linux, without touching Devil Daggers Survival Editor (which doesn't
run natively on Linux).

![screenshot](https://cdn.discordapp.com/attachments/643540982154919966/945867763723939890/unknown.png)

## Installation

```bash
git clone https://github.com/Evelyn1337/Devil-Daggers-Practice-Tool
cd Devil-Daggers-Practice-Tool
chmod +x dd-practice-tool.sh
```

## Usage

Run it with:

```bash
./dd-practice-tool.sh
```

or add it to your `$PATH`.

The script auto-detects your Devil Daggers install under either:

- `~/.local/share/Steam/steamapps/common/devildaggers/dd` (native Steam)
- `~/.var/app/com.valvesoftware.Steam/data/Steam/steamapps/common/devildaggers/dd` (Flatpak Steam)

If your install lives somewhere else, edit `FLATPAK_DD` / `NATIVE_DD` near
the top of the script to point at the right path.

There's no manual first-time setup step anymore — the first time you pick
a spawnset, the script automatically backs up your real `survival` file to
`survivalbackup` before touching anything. From then on, choosing "vanilla"
restores it.

If your Devil Daggers install ever gets messed up, delete the `dd` folder
under `common/devildaggers` and validate your game files through Steam.

**I am not responsible for anything that happens to your game, your
account, or you.**

## How it works

- Choosing a spawnset copies it into the game's `survival` file, which is
  what Devil Daggers reads on launch.
- If you've already downloaded that spawnset before, the script reuses the
  cached copy instead of re-downloading it.
- If it's not cached yet, the script downloads it from devildaggers.info,
  checks that the download actually succeeded (correct HTTP status, and a
  non-empty file), and only *then* overwrites `survival`. If the download
  fails — for example because a spawnset was renamed or removed on the
  site — you'll get an explicit error message and your current spawnset is
  left alone, instead of getting silently overwritten with a broken file.
- The `s` option lets you search for and play any spawnset by its exact
  name on devildaggers.info, the same way the numbered options do.

Note: this version no longer ships the old hardcoded "no farm" dagger-count
practice presets (e.g. a 440/400/350... series). devildaggers.info no
longer serves those under their old names, and rather than guess at
replacements, the `s` search option is the reliable way to find and load
current equivalents by name.

### Adding your own spawnsets to the menu

Named community spawnsets live in one place near the top of the script:

```
SPAWNSETS="
Pedeslayer|pedeslayer|Pedeslayer
Scanner|scanner|Scanner
"
```

Each line is `menu label|local cache filename|devildaggers.info name`.
Add a line to add a new numbered menu option — no other code needs to
change.

## Compatibility

The script is written in plain POSIX shell (`#!/bin/sh`, no bashisms) and
has been tested under `dash`, so it should run the same under `bash`,
`dash`, `ash`, or any other POSIX-compliant shell. It shells out to
`wget`, `mktemp`, and `awk`, which should be present on any typical Linux
system.

## Contributing

You are welcome to open issues, pull requests, or fork this repo as you
see fit.

## License

[GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html)
