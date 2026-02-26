# Ultra-Realistic 2D Map Blueprint (ShadowRise)

## 1. Map Layout (Whispering Valley - 8000px Width)
- **0 - 2000px (Dense Forest)**: Dynamic lighting, fog, Scout AI patterns.
- **2000 - 4000px (Living Village)**: NPC schedules, shop trade system, story branching point.
- **4000 - 6000px (Mountain Pass)**: Climbing mechanics, wind-based physics, Harpy/Flying AI.
- **6000 - 8000px (Ruin Castle)**: Stealth sections, Heavy Knight block AI, Shadow Realm transition.

---

## 2. Lighting & Visual Hierarchy
To achieve "Steam-level" graphics:
- **Depth**: Use at least 5 Parallax Layers. Far mountains should move at 0.05 scale, foreground bushes at 1.2 scale.
- **Atmosphere**: Use a `CanvasModulate` node to tint the entire world.
- **God Rays**: Add a dedicated `ColorRect` layer with a **Ray Shader** that reacts to the sun position in `EnvironmentalSystems.gd`.
- **Shadows**: Enable `2D Shadows` on all lamps and fires to cast long, cinematic shadows against the background.

---

## 3. Audio Architecture (Orchestral)
- **Bus 1 (Ambience)**: Lava bubbling, wind, birds.
- **Bus 2 (Music)**: Crossfade between `Calm_String_Section` and `Heavy_Choir_Boss`.
- **Bus 3 (SFX)**: Weapon swings, metal clangs with distance-based reverb.

---

## 4. Performance Tips
- **LOD (Level of Detail)**: Hide small decorative particles (leaves, grass sway) when the player is > 1500px away.
- **Physics**: Set `Physics Layer Masks` correctly so bullets don't check for collisions with backgrounds.
- **TileMap**: Use `CollisionPolygons` carefully to avoid overlapping collision shapes, which slows down Godot's physics server.
