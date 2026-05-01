# Custom Sounds

Drop `.wav` files here to override the default macOS system sounds.

## Recognized filenames

| File          | Plays when                          | Default fallback                          |
|---------------|-------------------------------------|-------------------------------------------|
| `boot.wav`    | Script starts                       | `/System/Library/Sounds/Hero.aiff`        |
| `nav.wav`     | Arrow-key menu navigation           | `/System/Library/Sounds/Tink.aiff`        |
| `select.wav`  | Menu item selected (Enter)          | `/System/Library/Sounds/Pop.aiff`         |
| `ok.wav`      | Tool installs successfully          | `/System/Library/Sounds/Morse.aiff`       |
| `fail.wav`    | Tool install fails                  | `/System/Library/Sounds/Funk.aiff`        |
| `done.wav`    | Final summary, all green            | `/System/Library/Sounds/Glass.aiff`       |

Drop a file in this directory with the matching name to override. WAVs are detected automatically — no config needed.

## Recommended specs

- Format: WAV (PCM 16-bit) or AIFF — `afplay` handles both
- Length: ≤ 0.5s for `nav` / `ok` / `fail` (they fire often)
- Length: ≤ 1.5s for `boot` / `done`
- Sample rate: any (8kHz / 22kHz / 44.1kHz all fine — 8kHz keeps the chiptune vibe)

## Volume / disable

- `TDF_SOUND=0` — disable all playback
- `TDF_SOUND_VOL=0.25` — quieter (default `0.5`)
- `TDF_SOUND_VOL=1.0` — full volume

## Where to grab 8-bit sounds

- [freesound.org](https://freesound.org) — search `"8bit"`, `"chiptune"`, `"NES"`
- [opengameart.org](https://opengameart.org/art-search?keys=8-bit+sfx)
- [sfxr](https://www.drpetter.se/project_sfxr.html) — generate your own retro sounds
