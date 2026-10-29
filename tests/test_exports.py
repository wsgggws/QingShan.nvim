"""Verify native theme files against the shared Neovim palette."""

import importlib
import json
import plistlib
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))
exporter = importlib.import_module("export")


class NativeFormats(unittest.TestCase):
    def test_terminal_selection_and_preview_have_distinct_surfaces(self):
        colors = json.loads((ROOT / "extras/palette.json").read_text())["colors"]
        wezterm = (ROOT / "extras/wezterm/QingShan.toml").read_text()
        self.assertIn(f'selection_bg = "{colors["jade"]}"', wezterm)
        self.assertIn(f'selection_fg = "{colors["bg_dark"]}"', wezterm)
        tmux = (ROOT / "extras/tmux/qingshan.conf").read_text()
        self.assertIn(f"mode-style 'fg={colors['bg_dark']},bg={colors['jade']},bold'", tmux)
        oh_my_tmux = (ROOT / "extras/tmux/qingshan.oh-my-tmux.conf").read_text()
        self.assertIn(f'tmux_conf_theme_mode_fg="{colors["bg_dark"]}"', oh_my_tmux)
        self.assertIn(f'tmux_conf_theme_mode_bg="{colors["jade"]}"', oh_my_tmux)
        fzf = (ROOT / "extras/fzf/qingshan.sh").read_text()
        self.assertIn(f"preview-bg:{colors['bg']}", fzf)
        self.assertIn(f"bg:{colors['bg_float']},", fzf)
        self.assertIn(f"preview-fg:{colors['fg']}", fzf)

    def test_exported_syntax_distinguishes_comments_variables_and_keywords(self):
        colors = json.loads((ROOT / "extras/palette.json").read_text())["colors"]
        bat = plistlib.loads((ROOT / "extras/bat/QingShan.tmTheme").read_bytes())
        scopes = {entry["scope"]: entry["settings"] for entry in bat["settings"] if "scope" in entry}
        self.assertEqual(scopes["comment"], {"foreground": colors["comment"], "fontStyle": "italic"})
        self.assertEqual(scopes["variable"], {"foreground": colors["fg"]})
        self.assertEqual(scopes["keyword, storage"], {"foreground": colors["keyword"], "fontStyle": "bold"})
        self.assertEqual(scopes["variable.parameter"], {"foreground": colors["sand"]})
        slides = json.loads((ROOT / "extras/slides/qingshan_theme.json").read_text())["code_block"]["chroma"]
        self.assertEqual(slides["comment"], {"color": colors["comment"], "italic": True})
        self.assertEqual(slides["literal_string_doc"], slides["comment"])
        self.assertEqual(slides["literal_string"], {"color": colors["string"]})
        self.assertEqual(slides["name"], {"color": colors["fg"]})
        self.assertEqual(slides["keyword"], {"color": colors["keyword"], "bold": True})

    def test_generated_files_match_the_source_palette(self):
        expected = exporter.artifacts(exporter.palette())
        for name, content in expected.items():
            self.assertEqual((ROOT / name).read_text(), content, name)

    def test_bat_alfred_and_slides_use_the_same_background(self):
        colors = json.loads((ROOT / "extras/palette.json").read_text())["colors"]
        bat = plistlib.loads((ROOT / "extras/bat/QingShan.tmTheme").read_bytes())
        self.assertEqual(bat["settings"][0]["settings"]["background"], colors["bg"])
        alfred = json.loads((ROOT / "extras/alfred/QingShan Dark Large.alfredappearance").read_text())["alfredtheme"]
        self.assertEqual(alfred["window"]["color"], colors["bg"] + "FF")
        self.assertEqual(alfred["window"]["blur"], 0)
        slides = json.loads((ROOT / "extras/slides/qingshan_theme.json").read_text())
        self.assertEqual(slides["document"]["background_color"], colors["bg"])
        self.assertEqual(slides["code_block"]["chroma"]["name_function"]["color"], colors["jade"])
        self.assertNotIn(
            "theme", slides["code_block"], "a built-in Chroma theme must not override custom syntax colors"
        )
        uid = plistlib.loads((ROOT / "extras/alfred/qingshan.plist").read_bytes())
        self.assertEqual(uid["lightthemeuid"], uid["darkthemeuid"])


if __name__ == "__main__":
    unittest.main()
