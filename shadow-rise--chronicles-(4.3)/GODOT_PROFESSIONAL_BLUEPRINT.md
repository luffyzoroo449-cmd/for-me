# Godot Professional Production Blueprint (Steam/Professional Level)

## 1. Visual Standards & Color Palette
To achieve the "Premium AAA Indie" feel, use the following color standards:
- **Base/Background**: `#1e1b4b` (Deep Indigo)
- **Primary Highlights**: `#f59e0b` (Premium Gold)
- **Secondary Glow**: `#8b5cf6` (Magical Purple)
- **Hazard (Lava)**: `#f97316` (Warm Orange)
- **Utility (Water)**: `#0369a1` (Deep Blue)

**Art Tip**: Use `WorldEnvironment` with `Glow` enabled. Set your UI nodes' `Modulate` to values > 1.0 (e.g., 1.5) to make the gold and purple elements actually shine.

---

## 2. Advanced Scene Hierarchy (Large Maps)
For a 6000px wide map, do not put everything in one TileMap. Breakdown:
- **WorldRoot (Node2D)**
  - **EnvironmentLayer (Parallax)**
  - **CollisionLayer (TileMap)**: Use 'Terrains' for automatic realistic tiling.
  - **PropLayer (Foliage/Vines)**: Use `GPUParticles2D` for falling leaves.
  - **EntityPooler (Node)**: Manages reuse of 20-30 enemies.
  - **WeatherController**: Handles Fog, Night/Day, and Rain.

---

## 3. AI Architecture Design (Tactical Group)
Instead of simple chase logic, use this **Tactical Loop**:
1. **Search**: Find player via `RayCast2D`.
2. **Coordination**: If player is isolated, transition to `FLANK`.
3. **Engagement**: Attack. If player swings, 30% chance to `DODGE` (roll back).
4. **Survival**: If HP < 30%, transition to `RETREAT` and trigger `SIGNAL` to nearby allies.
5. **Reinforcement**: Nearby allies in `IDLE` or `PATROL` automatically swap to `CHASE` at the signal location.

---

## 4. Performance Requirements (Optimization)
- **TileMap**: Enable `Collision > Physics Layer` and use the built-in `NavigationLayer` for the `NavigationAgent2D`.
- **Lighting**: Use `PointLight2D` sparingly. Static lights (lamps in village) should be baked into the tiles if possible.
- **Memory**: Use **ResourcePreloader** for weapon effects and bullet particles to avoid stuttering when first spawning a projectile.

---

## 5. UI Architecture
Use a `CanvasLayer` for the HUD to separate it from the 2D world.
- **Overlay (Control)**
  - **HealthGroup**: Animated ProgressBars (HP/MP).
  - **LevelMarker**: Gold-tinted Label with a 'Scale' tween on level-up.
  - **StaminaWheel**: A circular Progress bar near the character's feet (optional realism).
