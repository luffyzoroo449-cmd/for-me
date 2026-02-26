# 📘 ENGINE MIGRATION PRD
## Project: ShadowRise
## Migration: Expo (React Native) ➜ Godot Engine 4.x
### Author: Yashwanth Kumar | Date: February 2026

---

## 1. PURPOSE OF MIGRATION

| Goal | Detail |
|------|--------|
| Performance | Stable 60 FPS even in heavy boss fights |
| Physics | Native 2D physics with CharacterBody2D |
| AI | Behavior trees & StateMachine nodes |
| Animation | Frame-based sprite animation (AnimationPlayer) |
| Scale | 100+ levels with TileMap system |
| Platform | Android/iOS export via Godot native exporters |

---

## 2. CURRENT SYSTEM (Expo) — Limitations

- React Native game-engine loop runs in JS thread → FPS drops
- matter-js is not hardware-accelerated
- Bullet/particle system manually built in JS
- No native sprite animation system
- Bundling 100 levels in JS causes slow load times

---

## 3. TARGET SYSTEM (Godot 4.x)

| Item | Choice |
|------|--------|
| Engine | Godot 4.x Stable |
| Language | GDScript (Python-like, easy to learn) |
| Physics | Physics2D server (built-in) |
| Animation | AnimationPlayer + AnimatedSprite2D |
| Tilemap | TileMap node |
| AI | StateMachine (custom) + NavigationAgent2D |
| Export | Android (APK / AAB), iOS (Xcode) |

---

## 4. MIGRATION SCOPE — ⚠ REBUILD, NOT CONVERSION

You **CANNOT** convert Expo JavaScript to GDScript automatically.
You must **recreate** each system.

This document provides **complete GDScript source code** for all systems.

---

## 5. ASSET MIGRATION

| Asset | What to do |
|-------|-----------|
| `assets/hero_realistic.png` | Copy → `res://assets/sprites/player/` |
| `assets/enemy_realistic.jpg` | Copy → `res://assets/sprites/enemies/` |
| `assets/map_realistic_*.jpg` | Copy → `res://assets/backgrounds/` |
| `assets/platform_realistic.png` | Copy → `res://assets/sprites/tiles/` |
| `assets/audio/sfx_*.mp3` | Copy → `res://assets/audio/sfx/` |
| `assets/audio/bgm_*.mp3` | Copy → `res://assets/audio/bgm/` |

---

## 6. SCENE STRUCTURE

```
res://
├── scenes/
│   ├── MainMenu.tscn
│   ├── WorldMap.tscn
│   ├── GameWorld.tscn       ← Main game scene
│   ├── Player.tscn
│   ├── enemies/
│   │   ├── EnemyBasic.tscn
│   │   ├── EnemyAdvanced.tscn
│   │   ├── EnemySniper.tscn
│   │   ├── EnemyRusher.tscn
│   │   └── Boss.tscn
│   ├── weapons/
│   │   ├── Bullet.tscn
│   │   └── EnemyBullet.tscn
│   └── ui/
│       ├── HUD.tscn
│       ├── PauseMenu.tscn
│       └── GameOver.tscn
├── scripts/              ← All GDScript files (see this folder)
├── assets/
│   ├── sprites/
│   ├── backgrounds/
│   └── audio/
└── project.godot
```

---

## 7. FEATURE MAPPING

| Expo/JS Feature | Godot 4 Equivalent |
|-----------------|-------------------|
| `Matter.Body` | `CharacterBody2D` / `RigidBody2D` |
| `matter-js gravity` | `ProjectSettings > gravity` |
| `matter-js collision` | `move_and_slide()` + Area2D |
| `react-native-game-engine loop` | `_physics_process(delta)` |
| `useGameStore` (Zustand) | `GameManager.gd` (Autoload singleton) |
| `useState` | GDScript `@export var` + signals |
| `AsyncStorage` | `ConfigFile` or `FileAccess` |
| `Animated.Value` | `Tween` node |
| `ParticleSystem.js` | `GPUParticles2D` node |
| `AISystem.js` | `StateMachine.gd` (custom) |
| `WeaponSystem.js` | `WeaponManager.gd` |
| `CollisionSystem.js` | Built-in physics + signal `body_entered` |
| `ParallaxBackground.js` | `ParallaxBackground` + `ParallaxLayer` nodes |
| `LinearGradient` | `GradientTexture2D` + `TextureRect` |

---

## 8. NODE STRUCTURE

### Player.tscn
```
CharacterBody2D (Player.gd)
├── AnimatedSprite2D          ← hero_realistic.png spritesheet
├── CollisionShape2D          ← CapsuleShape2D
├── Camera2D
│   └── (limit bounds per level)
├── Marker2D (MuzzlePoint)    ← bullet spawn position
├── Area2D (DamageArea)
│   └── CollisionShape2D
├── Timer (DashCooldown)
├── Timer (CoyoteTimer)
├── Timer (JumpBuffer)
└── AudioStreamPlayer (SFX)
```

### Enemy.tscn (shared base)
```
CharacterBody2D (EnemyBase.gd)
├── AnimatedSprite2D
├── CollisionShape2D
├── Area2D (DetectArea)       ← detection radius
│   └── CollisionShape2D (CircleShape2D)
├── Area2D (ShootArea)        ← shoot range
│   └── CollisionShape2D (CircleShape2D)
├── RayCast2D (GroundCheck)
├── NavigationAgent2D         ← pathfinding
├── Timer (ShootTimer)
├── Timer (ReactionTimer)
└── HealthBar (ProgressBar)
```

### GameWorld.tscn
```
Node2D (GameWorld.gd)
├── ParallaxBackground
│   ├── ParallaxLayer (sky)
│   └── ParallaxLayer (mid)
├── TileMap (LevelTiles)      ← all platforms/terrain
├── Player (Player.tscn)
├── Enemies (Node2D)          ← dynamically spawned
├── Coins (Node2D)
├── Gems (Node2D)
├── Bullets (Node2D)
├── GPUParticles2D (Effects)
├── HUD (CanvasLayer)
│   └── HUD.tscn
├── AudioStreamPlayer (BGM)
└── Camera2D
```

---

## 9. WORLD DATA (Migrated from WorldConfig.js)

| World | Name | Gravity | Theme |
|-------|------|---------|-------|
| 1 | Forest | 1.0 | Green |
| 2 | Cave | 1.05 | Brown |
| 3 | Snow | 1.08 | Blue-white |
| 4 | Desert | 1.12 | Gold |
| 5 | Lava | 1.18 | Red-orange |
| 6 | Sky | 0.88 | Light blue |
| 7 | Factory | 1.22 | Steel grey |
| 8 | Haunted | 1.25 | Purple-black |
| 9 | Cyber | 1.28 | Cyan-neon |
| 10 | Shadow Kingdom | 1.35 | Pure black |

---

## 10. WEAPONS (Migrated from WeaponConfig.js)

| Weapon | Unlock Level | Damage | Range | Fire Rate | Magazine |
|--------|-------------|--------|-------|-----------|----------|
| Pistol | 1 | 1 | 200 | 0.4s | 8 |
| SMG | 10 | 1 | 250 | 0.12s | 20 |
| Shotgun | 20 | 2 | 130 | 0.9s | 6 |
| Assault Rifle | 40 | 2 | 350 | 0.2s | 30 |
| Sniper | 60 | 5 | 700 | 1.5s | 5 |

---

## 11. ENEMY AI STATES (Migrated from AISystem.js)

| Enemy Type | Detect Range | Shoot Range | Speed | Special |
|-----------|-------------|-------------|-------|---------|
| Basic | 180px | None | 1.5 | Patrol only |
| Advanced | 250px | 200px | 2.0 | Chase + shoot |
| Sniper | 500px | 450px | 0.8 | Slow, deadly |
| Rusher | 220px | None | 3.5 | Fast charge |
| Boss | Infinite | 300px | 2.0 | 4-phase fight |
| Shadow Stalker | Infinite | None | N/A | Mirrors player history |

---

## 12. MIGRATION ROADMAP

### Phase 1 — Setup (Week 1)
- [ ] Install Godot 4.x
- [ ] Create project with Android export template
- [ ] Copy all assets to `res://assets/`
- [ ] Set project settings (gravity, window size 800×450)
- [ ] Create `GameManager.gd` autoload singleton

### Phase 2 — Core Player (Week 2)
- [ ] Implement `Player.gd` (movement, jump, dash, double jump)
- [ ] Implement `WeaponManager.gd` (all 5 weapons)
- [ ] Implement `Bullet.gd` + `EnemyBullet.gd`
- [ ] Implement `HUD.gd` (health, ammo bar, coins, timer)

### Phase 3 — Enemy AI (Week 3)
- [ ] Implement `StateMachine.gd` base
- [ ] Implement `EnemyBase.gd` with state machine
- [ ] Implement `BossAI.gd` (4-phase)
- [ ] Enemy bullet shooting

### Phase 4 — Level Building (Weeks 4–5)
- [ ] Build `LevelManager.gd` (load/save progress)
- [ ] Design TileSet with all platform types
- [ ] Build World 1 (10 levels) as TileMap scenes
- [ ] Add traps, coins, gems, checkpoints, exit portals
- [ ] Build World 2–10 (use template scenes)

### Phase 5 — Polish (Week 6)
- [ ] Connect `GameManager.gd` to save/load with ConfigFile
- [ ] Add screen shake (Camera2D trauma system)
- [ ] Add GPUParticles2D effects (jump dust, bullet hit, death)
- [ ] Implement all 10 BGM tracks
- [ ] Add parallax scrolling background per world

### Phase 6 — Testing (Week 7)
- [ ] Test all 5 weapons
- [ ] Test all enemy types
- [ ] Test boss fights (all 10 bosses)
- [ ] Performance profile (target 60 FPS on mid-range Android)
- [ ] Fix save/load bugs

---

## 13. RISKS & MITIGATIONS

| Risk | Mitigation |
|------|-----------|
| GDScript learning curve | All scripts provided in this package |
| TileMap learning curve | Use provided world templates |
| Asset reimport | Just copy PNGs — Godot auto-imports |
| Balancing | Keep all difficulty numbers same as JS config |
| Performance on low-end phones | Use GPUParticles2D (GPU accelerated), avoid heavy shaders |

---

## 14. WHAT STAYS THE SAME

✅ Game story and name (ShadowRise)
✅ 10 worlds × 10 levels = 100 levels
✅ All 5 weapon types with same stats
✅ All enemy types with same AI behavior
✅ All world themes and names
✅ Coin/gem/health system
✅ Missions and progression
✅ Skin system
✅ Boss patterns

🆕 IMPROVEMENTS:
- Longer, more realistic maps (TileMap allows huge scrolling worlds)
- Sprite-based characters (real 2D art instead of colored boxes)
- Frame-based animations (idle/run/jump/shoot/die)
- Native physics (no FPS drops)
- GPUParticles2D (beautiful effects)
- Real parallax backgrounds

---

## 15. GODOT PROJECT SETTINGS

```
# project.godot key settings

[application]
config/name = "ShadowRise"
run/main_scene = "res://scenes/MainMenu.tscn"

[display]
window/size/width = 800
window/size/height = 450
window/stretch/mode = "canvas_items"
window/stretch/aspect = "keep"

[physics]
common/physics_ticks_per_second = 60

[layer_names]
2d_physics/layer_1 = "world"
2d_physics/layer_2 = "player"
2d_physics/layer_3 = "enemy"
2d_physics/layer_4 = "bullet"
2d_physics/layer_5 = "pickup"
2d_physics/layer_6 = "trigger"
```

---

*All GDScript source files are in the `/scripts/` folder of this package.*
