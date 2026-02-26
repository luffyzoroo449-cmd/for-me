# 🏆 GODOT 4.X ULTRA-REALISTIC PRODUCTION BLUEPRINT

To build a premium, cinematic 2D platformer like the one described, your technical implementation must be highly structured.

---

## 🏗️ 1. SUGGESTED NODE HIERARCHY

### **Player / Enemy Template**
```text
CharacterBody2D (HighFidelityCharacter.gd)
├── Visuals (Node2D)
│   ├── MainSprite (Sprite2D + ShaderMaterial)
│   │   └── ReflectShield (Subtle overlay for metal shine)
│   ├── Skeleton2D (For bone-based cloth/secondary motion)
│   │   └── (Torso, ArmL, ArmR, Neck, Head, CapeBones...)
│   └── WeaponSprite (With WeaponTrail.gd)
├── AnimationPlayer (The 16-frame "engine")
├── AnimationTree (The logic "brain" with StateMachine)
├── CinematicVisuals (Handles Blur/Particles)
├── CollisionShape2D (Anatomy accurate)
├── Hitbox (Area2D - for dealing damage)
├── Hurtbox (Area2D - for receiving damage)
└── GPUParticles2D (Always ready for dust/blood)
```

---

## 🧠 2. ANIMATIONTREE SETUP (SMOOTH BLENDING)

For 12-16 frame realism, you **cannot** just switch animations. You must **blend**.

- **Move BlendSpace1D**: Create a blend between `Idle` -> `Walk` -> `Run`.
  - As player velocity increases, the AnimationTree automatically selects the correct frame and blends the transitions.
- **Action Layers**: Use **AnimationNodeStateMachine** with "Add" or "Multiply" nodes.
  - *Layer 1*: Locomotion (Legs/Torso)
  - *Layer 2*: Combat (Arms/Secondary Motion) - Allows attacking while running without snapping the legs back to an idle pose.
- **OneShot Transitions**: Use `OneShot` nodes for `Hurt`, `Jump_Start`, and `Dash` to ensure they finish correctly and return to the movement blend.

---

## 🎨 3. SPRITE SPECS & RESOLUTION

- **Base Resolution**: Character height should be **1024px** to allow for high-detail painting (scars, armor texture).
- **Format**: 16-bit PNG for deep color range (Dark Fantasy needs rich shadows).
- **Atlas Optimization**: Use Godot's **TextureAtlas** for NPCs to minimize draw calls.
- **Lighting**: Use **Normal Maps** for every character sprite. This is the only way to get the "rim light" and "lava glow" to feel physical and realistic on a 2D plane.

---

## ⚡ 4. PERFORMANCE OPTIMIZATION

- **Skeleton2D Interpolation**: Keep bone calculations in `_physics_process` but enable **Physics Interpolation** in Godot 4 settings for 60fps smoothness on 144Hz monitors.
- **Shader Optimization**: Avoid complex loops in your blur/glow shaders. Use simple distance calculations for heat distortion.
- **VisibilityEnablers**: Crucial for 10,000px maps. All NPCs and distant enemies should have `VisibilityEnabler2D` nodes to stop all processing when off-screen.

---

## 🎭 5. HITBOX & HURTBOX LAYOUT

- **Hurtbox**: Should be split into **Head**, **Torso**, and **Legs**.
  - Headshot = Critical/Stun.
  - Leg hit = Slow down.
  - Torso = Standard damage.
- **Hitbox**: Should be dynamic. It only activates during specific frames of the `Attack` animation (defined by the AnimationPlayer).

---

### Implementation Ready
The scripts I have provided (`HighFidelityCharacter.gd`, `NPCLogic.gd`, `CinematicVisuals.gd`) are ready for your 1024px assets. You can now build the "Living World" with high-fidelity NPCs and the "Semi-Dark Fantasy" hero! 🗡️🌑✨🦾
