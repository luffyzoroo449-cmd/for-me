# 🎨 Visual Style Guide: ShadowRise

To achieve a **professional indie Steam-level** aesthetic, your art team should follow these specific direction markers for "Semi-Realistic Dark Fantasy."

---

## 1. Hero Art Direction
**Keywords**: Agility, Mystery, Weighted Equipment, Ethereal Magic.

*   **Design**: The hero should have a slender but muscular build. Avoid bulky "World of Warcraft" armor. Instead, use light leather and silver plate highlights to show speed.
*   **Palette**: Primary colors should be **Deep Indigo (#1e1b4b)** and **Obsidian Black**, with high-contrast **Gold (#f59e0b)** embroidery.
*   **Animation Focus**: Spend extra time on the "Cape" and "Hair" animations (12+ frames). Use the `VerletCloth2D.gd` script I provided to make them react to the sprint and jump physics.

### 🖼️ Hero Concept Art Prompt (for DALL-E/Midjourney):
> "High-quality 2D concept art of a realistic semi-dark fantasy hero for a platformer game. The hero wears a tattered dark indigo cloak with subtle gold embroidery, light silver armor plates, and has dynamic flowing hair. He holds a glowing purple magic sword. Side-view character design, professional game art style, dark mood, ethereal glow, 4k."

---

## 2. Environment: Whispering Valley
**Keywords**: Atmospheric Fog, Overgrown Ruin, Deep Parallax, Bioluminescence.

*   **Lighting**: Use **2D Normal Maps** on your tiles. This allows your magic swords and lanterns to "cast" light on the bark of the trees and the rocks.
*   **Atmosphere**: Use a three-layer parallax:
    *   *Foreground*: Dark, silhouettes of branches to add depth.
    *   *Midground*: The playable area with weathered wood and stone.
    *   *Background*: Mist-covered mountains with deep purple/blue hues.

### 🖼️ Level Mockup Prompt (for DALL-E/Midjourney):
> "High-quality 2D side-scrolling level concept art for a dark fantasy forest called Whispering Valley. Ancient twisted trees with glowing purple moss, dynamic fog, a wooden bridge over a dark blue lake, mountains in a parallax background under a deep indigo sky. Professional indie game aesthetic, atmospheric lighting, moody, immersive, 4k."

---

## 3. Enemy Design: The Shadow Legion
**Keywords**: Jagged, Shadowy, Intimidating, Precise.

*   **Basic Soldier**: Wears the same style armor as the hero but tarnished and rusted. They have glowing red or white eyes behind their visors.
*   **Shadow Commander**: A towering figure with a massive Zweihänder sword. His cape should be made of actual "living shadows" (use a shader with liquid-like movement).

---

## 4. UI Design: The High-Fidelity HUD
*   **Frame**: Use thin, elegant gold lines to frame the HP/MP bars.
*   **Glow**: The bars should have a "pulsating" inner glow to indicate vitality and magic power.
*   **Icons**: Hand-painted icons for weapons and inventory items to increase the premium feel.

---

### 🎉 Your Visual Foundation
I have generated a **Hero Concept** and a **Level Mockup** in your project directory (refer to the images attached in the chat). Use these as the "North Star" for your visual style.

Your game now has the **Tech**, the **Logic**, and the **Vision** to be a standalone success!
