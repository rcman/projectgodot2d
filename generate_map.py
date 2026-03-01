#!/usr/bin/env python3
"""
Godot 2D Map Generator
Generates a .tscn scene file with platforms and ladders for a 2D platformer.
"""

import random
from dataclasses import dataclass
from typing import List


@dataclass
class Platform:
    x: float
    y: float
    width: float
    height: float = 32.0


@dataclass
class Ladder:
    x: float
    y: float
    height: float
    width: float = 32.0


@dataclass
class EnemySpawn:
    x: float
    y: float


class GodotMapGenerator:
    def __init__(self, map_width: int = 1920, map_height: int = 1080, seed: int = None):
        self.map_width = map_width
        self.map_height = map_height
        self.platforms: List[Platform] = []
        self.ladders: List[Ladder] = []
        self.enemy_spawns: List[EnemySpawn] = []

        if seed is not None:
            random.seed(seed)

    def generate_ground(self):
        """Generate the ground platform at the bottom of the map."""
        self.platforms.append(Platform(
            x=self.map_width / 2,
            y=self.map_height - 16,
            width=self.map_width,
            height=32
        ))

    def generate_platforms(self, num_platforms: int = 8, min_width: int = 150, max_width: int = 400):
        """Generate random platforms across the map."""
        # Define vertical levels for platforms
        levels = [
            self.map_height - 200,
            self.map_height - 350,
            self.map_height - 500,
            self.map_height - 650,
            self.map_height - 800,
        ]

        for level in levels:
            # Generate 1-3 platforms per level
            num_on_level = random.randint(1, 3)
            available_x = list(range(100, self.map_width - 100, 200))
            random.shuffle(available_x)

            for i in range(min(num_on_level, len(available_x))):
                width = random.randint(min_width, max_width)
                x = available_x[i]

                # Ensure platform stays within bounds
                x = max(width / 2, min(x, self.map_width - width / 2))

                self.platforms.append(Platform(
                    x=x,
                    y=level,
                    width=width
                ))

                # 50% chance to add an enemy spawn on this platform
                if random.random() > 0.5:
                    self.enemy_spawns.append(EnemySpawn(
                        x=x,
                        y=level - 40
                    ))

    def generate_ladders(self, num_ladders: int = 5):
        """Generate ladders connecting platforms."""
        # Sort platforms by y position (top to bottom)
        sorted_platforms = sorted(self.platforms, key=lambda p: p.y)

        # Try to connect platforms with ladders
        for i in range(len(sorted_platforms) - 1):
            upper = sorted_platforms[i]
            lower = sorted_platforms[i + 1]

            # Check if platforms are close enough horizontally
            if abs(upper.x - lower.x) < 300:
                # 70% chance to place a ladder
                if random.random() < 0.7:
                    ladder_x = (upper.x + lower.x) / 2
                    ladder_height = lower.y - upper.y

                    self.ladders.append(Ladder(
                        x=ladder_x,
                        y=upper.y + ladder_height / 2,
                        height=ladder_height
                    ))

        # Add some random ladders from ground
        ground_y = self.map_height - 32
        for platform in sorted_platforms[:-1]:  # Exclude ground
            if platform.y > self.map_height - 300 and random.random() < 0.3:
                self.ladders.append(Ladder(
                    x=platform.x,
                    y=(platform.y + ground_y) / 2,
                    height=ground_y - platform.y
                ))

    def generate_map(self):
        """Generate a complete map with all elements."""
        self.generate_ground()
        self.generate_platforms()
        self.generate_ladders()

    def to_tscn(self) -> str:
        """Export the map as a Godot .tscn file."""
        lines = []

        # Header
        lines.append('[gd_scene load_steps=1 format=3]')
        lines.append('')

        # Root node
        lines.append('[node name="Map" type="Node2D"]')
        lines.append('')

        # Platforms container
        lines.append('[node name="Platforms" type="Node2D" parent="."]')
        lines.append('')

        # Generate platform nodes
        for i, platform in enumerate(self.platforms):
            node_name = f"Platform_{i}"
            lines.append(f'[node name="{node_name}" type="StaticBody2D" parent="Platforms"]')
            lines.append(f'position = Vector2({platform.x}, {platform.y})')
            lines.append('')

            # Collision shape
            lines.append(f'[node name="CollisionShape2D" type="CollisionShape2D" parent="Platforms/{node_name}"]')
            lines.append('')

            # Sprite/Visual
            lines.append(f'[node name="Sprite" type="ColorRect" parent="Platforms/{node_name}"]')
            lines.append(f'offset_left = {-platform.width / 2}')
            lines.append(f'offset_top = {-platform.height / 2}')
            lines.append(f'offset_right = {platform.width / 2}')
            lines.append(f'offset_bottom = {platform.height / 2}')
            lines.append('color = Color(0.4, 0.3, 0.2, 1)')
            lines.append('')

        # Ladders container
        lines.append('[node name="Ladders" type="Node2D" parent="."]')
        lines.append('')

        # Generate ladder nodes
        for i, ladder in enumerate(self.ladders):
            node_name = f"Ladder_{i}"
            lines.append(f'[node name="{node_name}" type="Area2D" parent="Ladders"]')
            lines.append(f'position = Vector2({ladder.x}, {ladder.y})')
            lines.append('')

            # Collision shape for ladder
            lines.append(f'[node name="CollisionShape2D" type="CollisionShape2D" parent="Ladders/{node_name}"]')
            lines.append('')

            # Visual
            lines.append(f'[node name="Sprite" type="ColorRect" parent="Ladders/{node_name}"]')
            lines.append(f'offset_left = {-ladder.width / 2}')
            lines.append(f'offset_top = {-ladder.height / 2}')
            lines.append(f'offset_right = {ladder.width / 2}')
            lines.append(f'offset_bottom = {ladder.height / 2}')
            lines.append('color = Color(0.6, 0.5, 0.1, 1)')
            lines.append('')

        # Enemy spawns container
        lines.append('[node name="EnemySpawns" type="Node2D" parent="."]')
        lines.append('')

        for i, spawn in enumerate(self.enemy_spawns):
            node_name = f"EnemySpawn_{i}"
            lines.append(f'[node name="{node_name}" type="Marker2D" parent="EnemySpawns"]')
            lines.append(f'position = Vector2({spawn.x}, {spawn.y})')
            lines.append('')

        # Player spawn point
        lines.append('[node name="PlayerSpawn" type="Marker2D" parent="."]')
        lines.append(f'position = Vector2(100, {self.map_height - 80})')
        lines.append('')

        return '\n'.join(lines)

    def to_gdscript_resource(self) -> str:
        """Export map data as a GDScript resource file for dynamic loading."""
        lines = []
        lines.append('# Auto-generated map data')
        lines.append('extends Resource')
        lines.append('class_name MapData')
        lines.append('')
        lines.append('@export var platforms: Array[Dictionary] = [')

        for platform in self.platforms:
            lines.append(f'    {{"x": {platform.x}, "y": {platform.y}, "width": {platform.width}, "height": {platform.height}}},')

        lines.append(']')
        lines.append('')
        lines.append('@export var ladders: Array[Dictionary] = [')

        for ladder in self.ladders:
            lines.append(f'    {{"x": {ladder.x}, "y": {ladder.y}, "width": {ladder.width}, "height": {ladder.height}}},')

        lines.append(']')
        lines.append('')
        lines.append('@export var enemy_spawns: Array[Vector2] = [')

        for spawn in self.enemy_spawns:
            lines.append(f'    Vector2({spawn.x}, {spawn.y}),')

        lines.append(']')
        lines.append('')

        return '\n'.join(lines)

    def to_json(self) -> str:
        """Export map data as JSON for external tools."""
        import json

        data = {
            "map_width": self.map_width,
            "map_height": self.map_height,
            "platforms": [
                {"x": p.x, "y": p.y, "width": p.width, "height": p.height}
                for p in self.platforms
            ],
            "ladders": [
                {"x": l.x, "y": l.y, "width": l.width, "height": l.height}
                for l in self.ladders
            ],
            "enemy_spawns": [
                {"x": e.x, "y": e.y}
                for e in self.enemy_spawns
            ]
        }

        return json.dumps(data, indent=2)


def main():
    import argparse

    parser = argparse.ArgumentParser(description='Generate a 2D map for Godot')
    parser.add_argument('--width', type=int, default=1920, help='Map width in pixels')
    parser.add_argument('--height', type=int, default=1080, help='Map height in pixels')
    parser.add_argument('--seed', type=int, default=None, help='Random seed for reproducible maps')
    parser.add_argument('--output', type=str, default='generated_map.tscn', help='Output file name')
    parser.add_argument('--format', choices=['tscn', 'gd', 'json'], default='tscn', help='Output format')

    args = parser.parse_args()

    # Generate the map
    generator = GodotMapGenerator(
        map_width=args.width,
        map_height=args.height,
        seed=args.seed
    )
    generator.generate_map()

    # Export based on format
    if args.format == 'tscn':
        content = generator.to_tscn()
        output_file = args.output if args.output.endswith('.tscn') else f'{args.output}.tscn'
    elif args.format == 'gd':
        content = generator.to_gdscript_resource()
        output_file = args.output if args.output.endswith('.gd') else f'{args.output}.gd'
    else:
        content = generator.to_json()
        output_file = args.output if args.output.endswith('.json') else f'{args.output}.json'

    with open(output_file, 'w') as f:
        f.write(content)

    print(f"Map generated successfully!")
    print(f"Output: {output_file}")
    print(f"Platforms: {len(generator.platforms)}")
    print(f"Ladders: {len(generator.ladders)}")
    print(f"Enemy spawns: {len(generator.enemy_spawns)}")


if __name__ == '__main__':
    main()
