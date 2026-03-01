# Factory Run

A 2D platformer game built with Godot 4.x featuring procedurally generated levels, enemies, boss fights, and an industrial factory theme.

## Features

- **Multiple Levels**: 6 levels with increasing difficulty
- **Player Mechanics**: Run, jump, climb ladders, shoot
- **Enemies**: Patrol AI that chases and shoots when player is nearby
- **Boss Fights**: Large boss enemies with spread shot attacks and enrage mode
- **Searchable Lockers**: Find ammo, health, armor, and keys
- **Locked Doors**: Collect keys to unlock doors blocking your path
- **HUD**: Health bar, ammo count, armor, keys, score, and level display
- **Sound Effects**: Procedurally generated retro-style sounds
- **Background Music**: Support for OGG music files

## Controls

| Key | Action |
|-----|--------|
| A / Left Arrow | Move left |
| D / Right Arrow | Move right |
| W / Up Arrow | Jump / Climb up ladder |
| S / Down Arrow | Climb down ladder |
| Space | Shoot |
| E | Interact (open lockers, unlock doors) |

## How to Play

1. Navigate through the factory using platforms and ladders
2. Defeat all enemies including the boss
3. Search lockers for supplies (ammo, health, armor)
4. Defeat the boss to get a key
5. Use the key to unlock the exit door
6. Progress through all 6 levels to win

## Project Structure

```
projectgodot2d/
├── project.godot          # Godot project configuration
├── main_menu.tscn/gd      # Start menu
├── game_over.tscn/gd      # Game over screen
├── level_complete.tscn/gd # Level complete screen
├── level_1.tscn           # Level 1 (4 enemies + 1 boss)
├── level_2.tscn           # Level 2 (8 enemies + 1 boss)
├── level_3.tscn           # Level 3 (12 enemies + 2 bosses)
├── player.tscn/gd         # Player character
├── enemy.tscn/gd          # Regular enemy
├── boss.tscn/gd           # Boss enemy
├── bullet.tscn/gd         # Projectile
├── platform.tscn/gd       # One-way platforms
├── ladder.tscn/gd         # Climbable ladders
├── locker.tscn/gd         # Searchable containers
├── locked_door.tscn/gd    # Doors requiring keys
├── hud.tscn/gd            # Heads-up display
├── game_manager.tscn/gd   # Score and level tracking
├── level_manager.gd       # Level progression
├── sound_manager.tscn/gd  # Audio management
├── factory_background.tscn # Industrial background
└── generate_map.py        # Python script for map generation
```

## Difficulty Progression

| Level | Enemies | Bosses | Enemy Speed | Detection | Shoot Rate |
|-------|---------|--------|-------------|-----------|------------|
| 1     | 4       | 1      | Normal      | 300       | 1.5s       |
| 2     | 8       | 1      | Normal      | 300       | 1.5s       |
| 3     | 12      | 2      | Normal      | 300       | 1.5s       |
| 4     | 14      | 2      | Fast        | 350       | 1.2s       |
| 5     | 16      | 3      | Faster      | 400       | 1.0s       |
| 6     | 18      | 3      | Very Fast   | 450       | 0.8s       |

## Enemy Types

### Regular Enemy
- Patrols platforms
- Chases player when in range
- Shoots when close enough
- Stats scale with level difficulty

### Boss
- Larger size (3x scale)
- Fires spread shot (3 bullets)
- Enrage mode at low health (5 bullets, faster fire rate)
- Health and damage increase in later levels

## Items

| Item | Effect |
|------|--------|
| Ammo | +10 bullets |
| Health | +25 HP |
| Armor | +15 armor (reduces damage) |
| Key | Opens locked doors |

## Requirements

- Godot 4.x

## Running the Game

1. Open the project in Godot 4.x
2. Press F5 or click the Play button
3. Click "Start Game" from the main menu

## Credits

Built with Godot Engine 4.x
