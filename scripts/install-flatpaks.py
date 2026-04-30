#!/usr/bin/env python3
"""Interactive TUI for selecting and installing Flatpak applications."""

import subprocess
import sys
from pathlib import Path

from textual.app import App, ComposeResult
from textual.binding import Binding
from textual.widgets import Footer, Header, Label, SelectionList
from textual.widgets.selection_list import Selection

FLATPAKS_FILE = Path.home() / "flatpaks.txt"


def load_flatpaks(path: Path) -> list[str]:
    if not path.exists():
        print(f"Error: {path} not found.", file=sys.stderr)
        sys.exit(1)
    return [line.strip() for line in path.read_text().splitlines() if line.strip()]


def install_flatpaks(packages: list[str]) -> None:
    print(f"\nInstalling {len(packages)} flatpak(s)...\n")
    subprocess.run(
        ["flatpak", "install", "--user", "--assumeyes", *packages],
        check=True,
    )


class FlatpakInstaller(App[list[str]]):
    CSS = """
    Screen {
        padding: 1 2;
    }

    #instructions {
        margin-bottom: 1;
        color: $text-muted;
    }

    SelectionList {
        height: 1fr;
        border: round $primary;
    }
    """

    BINDINGS = [
        Binding("enter", "install", "Install selected", show=True),
        Binding("a", "select_all", "Select all", show=True),
        Binding("d", "deselect_all", "Deselect all", show=True),
        Binding("q", "quit", "Quit", show=True),
    ]

    def __init__(self, flatpaks: list[str]) -> None:
        super().__init__()
        self.flatpaks = flatpaks

    def compose(self) -> ComposeResult:
        yield Header()
        yield Label(
            "Which flatpaks do you want to install?\n\n"
            "[bold]↑↓[/bold] navigate  ·  "
            "[bold]Space[/bold] select  ·  "
            "[bold]A[/bold] select all  ·  "
            "[bold]D[/bold] deselect all  ·  "
            "[bold]Enter[/bold] install  ·  "
            "[bold]Q[/bold] quit",
            id="instructions",
        )
        yield SelectionList(*[Selection(pkg, pkg) for pkg in self.flatpaks])
        yield Footer()

    def action_install(self) -> None:
        selected = list(self.query_one(SelectionList).selected)
        if not selected:
            self.notify("No flatpaks selected.", severity="warning")
            return
        self.exit(selected)

    def action_select_all(self) -> None:
        self.query_one(SelectionList).select_all()

    def action_deselect_all(self) -> None:
        self.query_one(SelectionList).deselect_all()


def main() -> None:
    flatpaks = load_flatpaks(FLATPAKS_FILE)
    selected = FlatpakInstaller(flatpaks).run()

    if selected:
        install_flatpaks(selected)
    else:
        print("No flatpaks selected. Exiting.")


if __name__ == "__main__":
    main()
