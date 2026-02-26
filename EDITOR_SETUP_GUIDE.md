# 🛠️ Godot Editor Setup Guide: ShadowRise

You now have a fully structures "app" (project) folder. Follow these steps to start developing inside the Godot Editor.

## 1. Opening the Project
1. Run **Godot Engine 4.x**.
2. Click **Import**.
3. Navigate to `c:\Users\Yashwanth Kumar\Documents\1\ShadowRise_Godot` and select `project.godot`.
4. Click **Import & Edit**.

## 2. Setting up the Scene Tree
- Open `res://scenes/Main.tscn` (This is your start scene).
- Open `res://scenes/Level_1.tscn` to see the work-in-progress map.

## 3. High-Resolution Sprites (1024px)
To import your realistic character art:
1. Copy your `.png` files into `res://assets/sprites/`.
2. In Godot, click on the image in the **FileSystem** tab.
3. In the **Import** tab (top left), set **Compress Mode** to `VRAM Compressed` (critical for Android performance).
4. For the Player, select the `MainSprite` node in `Player.tscn` and drag your image into the `Texture` slot.

## 4. Animation Setup
- Select the `AnimationTree` node in the `Player` scene.
- Ensure `Active` is checked.
- If you add new animations to the `AnimationPlayer`, you must add them to the `StateMachine` inside the `AnimationTree` editor (bottom panel).

## 5. Input Check
The project is pre-configured with:
- **A / D**: Move Left / Right
- **Space**: Jump
- **Left Click**: Attack (Standard Combo)

## 6. Testing Audio
Run the game (`F5`). If you see the "Level 1" text and can walk on the brown floor, the **SoundManager** and **GameManager** are successfully running in the background as singletons.

---

### 🚀 Production Note
I have set the window resolution to **1920x1080 (1080p)** with a `canvas_items` stretch mode. This ensures your high-res sprites look sharp on 4K monitors while scaling perfectly down to mobile screens.
