# Godot Master Audio Production Guide

## 1. Audio Bus Routing (The Pro Setup)
In Godot's **Audio** bottom panel, create the following hierarchy:
1. **Master** (Adds global peak limiting)
   - **Music** (Slot 0: Limiter)
   - **SFX** (Slot 0: Reverb-disabled, Slot 1: LowPass-disabled)
   - **Ambience** (Slot 0: Equalizer)
   - **UI** (Bypasses all environmental effects)

---

## 2. Adaptive "Vertical Layering" Strategy
To make music transitions feel AAA:
1. Compose your exploration track and combat track at the **same BPM (Tempo)**.
2. In Godot, start **both** players simultaneously at volume `-80`.
3. When combat starts, `SoundManager` tweens the Combat Layer to `0` and the Calm Layer to `-15` (staying slightly audible).
4. This ensures the rhythm never skips during a transition.

---

## 3. Performance & Object Pooling
To prevent frame drops on Android from too many SFX:
- **Footstep Pool**: Create an array of 5 `AudioStreamPlayer2D` nodes under `SoundManager`. Reuse them in a cycle.
- **Max Polyphony**: Set certain sounds (like weapon swings) to `Max Polyphony = 2`. This prevents the "ear-destroying" overlap if the player attacks too fast.

---

## 4. Acoustic Zone Triggers
Use the `AudioEnvironmentZone.gd` script on large `Area2D` nodes.
- **Caves**: Set `zone_type = "Cave"`. It will automatically enable the Reverb effect on the `SFX` bus for everything inside that area.
- **Underwater**: Set `zone_type = "Underwater"`. It will enable a `LowPass` filter on the `Master` bus, making everything sound muffled.

---

## 5. UI Premium Sound
For the home screen:
- Use `Button.mouse_entered` to trigger a soft "click" or "hover" sound.
- Use `Button.pressed` for the "Select" chime.
- These should always route to the **UI Bus** so they stay crisp and clear even if the player is in a muffled underwater cave.
