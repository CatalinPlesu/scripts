#!/usr/bin/env python3
"""
prompt-compose - A TUI for composing prompts from files
Improved Python version with better menu structure and clipboard fixes
"""

import os
import sys
import tempfile
import shutil
import subprocess
import time
import threading
from pathlib import Path
from dataclasses import dataclass
from typing import List, Optional, Dict, Any

@dataclass
class Config:
    prompts_dir: Path
    config_dir: Path
    temp_dir: Path
    cache_file: Path
    editor: str = "nvim"
    clipboard_check_interval: float = 0.2

class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    CYAN = '\033[0;36m'
    BOLD = '\033[1m'
    DIM = '\033[2m'
    NC = '\033[0m'

class ClipboardManager:
    def __init__(self, config: Config):
        self.config = config
        self.squashed_content = []
        self.is_squashing = False
        self.squash_thread = None
        self.clipboard_file = config.temp_dir / "clipboard_content.txt"
        
    def get_clipboard_command(self) -> tuple:
        """Determine available clipboard utilities"""
        if shutil.which("wl-copy") and shutil.which("wl-paste"):
            return ("wl-copy", "wl-paste")
        elif shutil.which("xclip"):
            return ("xclip -selection clipboard", "xclip -selection clipboard -o")
        elif shutil.which("pbcopy") and shutil.which("pbpaste"):
            return ("pbcopy", "pbpaste")
        return (None, None)
    
    def get_clipboard_content(self) -> str:
        """Get current clipboard content"""
        copy_cmd, paste_cmd = self.get_clipboard_command()
        if not paste_cmd:
            return ""
        
        try:
            result = subprocess.run(paste_cmd, shell=True, capture_output=True, text=True)
            return result.stdout.strip()
        except:
            return ""
    
    def set_clipboard_content(self, content: str):
        """Set clipboard content"""
        copy_cmd, _ = self.get_clipboard_command()
        if not copy_cmd:
            return
        
        try:
            subprocess.run(copy_cmd, shell=True, input=content, text=True)
        except:
            pass
    
    def clear_clipboard(self):
        """Clear clipboard content"""
        copy_cmd, _ = self.get_clipboard_command()
        if copy_cmd:
            try:
                subprocess.run(copy_cmd, shell=True, input="", text=True)
            except:
                pass
    
    def start_squashing(self):
        """Start actively squashing clipboard content"""
        if self.is_squashing:
            return
        
        # Clear clipboard first to remove any trash
        self.clear_clipboard()
        
        self.is_squashing = True
        self.squashed_content = []
        self.squash_thread = threading.Thread(target=self._squash_loop, daemon=True)
        self.squash_thread.start()
        print(f"{Colors.GREEN}Clipboard squashing started{Colors.NC}")
    
    def stop_squashing(self):
        """Stop clipboard squashing"""
        self.is_squashing = False
        if self.squash_thread:
            self.squash_thread.join(timeout=1.0)
        print(f"{Colors.YELLOW}Clipboard squashing stopped{Colors.NC}")
    
    def _squash_loop(self):
        """Main loop for clipboard squashing"""
        last_content = ""
        
        while self.is_squashing:
            current_content = self.get_clipboard_content()
            
            # If clipboard has new content and it's not empty
            if (current_content and 
                current_content != last_content and 
                current_content not in self.squashed_content):
                
                self.squashed_content.append(current_content)
                last_content = current_content
                self.clear_clipboard()
                
                # Save squashed content to file
                with open(self.clipboard_file, 'w') as f:
                    f.write("\n---\n".join(self.squashed_content))
                
                print(f"{Colors.GREEN}Squashed clipboard content ({len(self.squashed_content)} items){Colors.NC}")
            
            time.sleep(self.config.clipboard_check_interval)
    
    def get_squashed_content(self) -> str:
        """Get all squashed content as string"""
        return "\n---\n".join(self.squashed_content)
    
    def get_fresh_clipboard_content(self) -> str:
        """Get fresh clipboard content (not squashed)"""
        return self.get_clipboard_content()

class FZF:
    @staticmethod
    def select_file(prompts: List[Path]) -> Optional[Path]:
        """Use fzf to select a file from list"""
        if not prompts:
            return None
            
        # Prepare input for fzf - use relative paths for display but keep full paths
        file_list = []
        for prompt in prompts:
            rel_path = prompt.relative_to(prompt.parent.parent) if prompt.parent.parent else prompt.name
            file_list.append(f"{rel_path}\t{prompt}")
        
        try:
            result = subprocess.run(
                ["fzf", "--delimiter=\t", "--with-nth=1", "--preview", "head -20 {2}"],
                input="\n".join(file_list),
                text=True,
                capture_output=True,
                timeout=30
            )
            
            if result.returncode == 0 and result.stdout.strip():
                # Extract the full path from the second column
                selected_line = result.stdout.strip()
                if '\t' in selected_line:
                    full_path = selected_line.split('\t')[1]
                    return Path(full_path)
        except (subprocess.TimeoutExpired, subprocess.CalledProcessError, FileNotFoundError):
            pass
            
        return None
    
    @staticmethod
    def select_preset(presets: List[Path]) -> Optional[Path]:
        """Use fzf to select a preset"""
        if not presets:
            return None
            
        try:
            preset_names = [f"{p.stem}\t{p}" for p in presets]
            result = subprocess.run(
                ["fzf", "--delimiter=\t", "--with-nth=1"],
                input="\n".join(preset_names),
                text=True,
                capture_output=True,
                timeout=30
            )
            
            if result.returncode == 0 and result.stdout.strip():
                selected_line = result.stdout.strip()
                if '\t' in selected_line:
                    full_path = selected_line.split('\t')[1]
                    return Path(full_path)
        except (subprocess.TimeoutExpired, subprocess.CalledProcessError, FileNotFoundError):
            pass
            
        return None

class PromptComposer:
    def __init__(self):
        self.config = self.setup_config()
        self.clipboard_manager = ClipboardManager(self.config)
        self.fzf = FZF()
        self.last_action = "c"
        self.selected_files = []
        self.cached_prompts = []
        self.cache_time = 0
        self.cache_validity = 5  # seconds
        
        # Initialize
        self.init()
    
    def setup_config(self) -> Config:
        """Setup configuration paths"""
        home = Path.home()
        prompts_dir = home / "Documents" / "Notes" / "prompts"
        config_dir = prompts_dir / ".config"
        temp_dir = Path(tempfile.mkdtemp(prefix="prompt-compose-"))
        cache_file = config_dir / ".last_action"
        
        # Get editor from environment
        editor = os.environ.get("EDITOR", "nvim")
        
        return Config(prompts_dir, config_dir, temp_dir, cache_file, editor)
    
    def init(self):
        """Initialize application"""
        self.config.config_dir.mkdir(parents=True, exist_ok=True)
        self.config.temp_dir.mkdir(parents=True, exist_ok=True)
        
        if not self.config.prompts_dir.exists():
            print(f"{Colors.RED}Error: Prompts directory not found: {self.config.prompts_dir}{Colors.NC}")
            sys.exit(1)
        
        # Load last action
        if self.config.cache_file.exists():
            self.last_action = self.config.cache_file.read_text().strip()
        else:
            self.last_action = "c"
    
    def cleanup(self):
        """Cleanup temporary files"""
        if self.config.temp_dir.exists():
            shutil.rmtree(self.config.temp_dir)
    
    def save_last_action(self, action: str):
        """Save last action to cache"""
        self.last_action = action
        self.config.cache_file.write_text(action)
    
    def find_prompts(self, force_refresh: bool = False) -> List[Path]:
        """Find all prompt files with caching"""
        current_time = time.time()
        
        if (not force_refresh and self.cached_prompts and 
            current_time - self.cache_time < self.cache_validity):
            return self.cached_prompts
        
        prompts = []
        for ext in ("*.md", "*.txt", "*.prompt"):
            prompts.extend(self.config.prompts_dir.rglob(ext))
        
        # Filter out config directory
        prompts = [p for p in prompts if ".config" not in str(p)]
        prompts.sort()
        
        self.cached_prompts = prompts
        self.cache_time = current_time
        return prompts
    
    def show_main_menu(self):
        """Display main menu - UPDATED STRUCTURE"""
        os.system('clear')
        print(f"{Colors.BOLD}{Colors.CYAN}=== Prompt Composer ==={Colors.NC}\n")
        print(f"{Colors.BOLD}Options:{Colors.NC}")
        print(f"  {Colors.GREEN}n{Colors.NC}) Create new composition")
        print(f"  {Colors.GREEN}cd{Colors.NC}) Load preset")
        print(f"  {Colors.GREEN}cds{Colors.NC}) Load preset with squash ON")
        print(f"  {Colors.GREEN}cp{Colors.NC}) Load preset and copy immediately") 
        print(f"  {Colors.GREEN}ls{Colors.NC}) List presets")
        print(f"  {Colors.GREEN}rm{Colors.NC}) Delete preset")
        print(f"  {Colors.GREEN}q{Colors.NC}) Quit")
        print()
        
        default_hint = ""
        if self.last_action == "n":
            default_hint = "new composition"
        elif self.last_action == "cd":
            default_hint = "load preset"
        elif self.last_action == "cds":
            default_hint = "load preset with squash"
        elif self.last_action == "cp":
            default_hint = "copy preset"
        elif self.last_action == "ls":
            default_hint = "list presets"
        
        if default_hint:
            print(f"{Colors.DIM}Press ENTER for last action: {default_hint}{Colors.NC}")
    
    def reset_composition(self):
        """Reset current composition state"""
        self.selected_files = []
    
    def manage_files(self) -> bool:
        """Manage composition files - UPDATED STRUCTURE"""
        while True:
            os.system('clear')
            print(f"{Colors.BOLD}{Colors.CYAN}=== File Management ==={Colors.NC}\n")
            
            if self.selected_files:
                print(f"{Colors.BOLD}Current files:{Colors.NC}")
                for i, file_path in enumerate(self.selected_files, 1):
                    if str(file_path) == "[CLIPBOARD]":
                        display_name = f"{Colors.YELLOW}[CLIPBOARD]{Colors.NC}"
                    else:
                        display_name = file_path.name
                    print(f"  {Colors.GREEN}{i}{Colors.NC}) {display_name}")
                print()
            else:
                print(f"{Colors.DIM}No files selected yet{Colors.NC}\n")
            
            print(f"{Colors.BOLD}Options:{Colors.NC}")
            print(f"  {Colors.GREEN}a{Colors.NC}) Add file")
            print(f"  {Colors.GREEN}n{Colors.NC}) Create new file")
            print(f"  {Colors.GREEN}e{Colors.NC}) Edit file")
            print(f"  {Colors.GREEN}c{Colors.NC}) Add clipboard placeholder")
            print(f"  {Colors.GREEN}r{Colors.NC}) Remove file")
            print(f"  {Colors.GREEN}o{Colors.NC}) Reorder files")
            print(f"  {Colors.GREEN}x{Colors.NC}) Clear all (x)")
            print(f"  {Colors.GREEN}d{Colors.NC}) Done (continue to preview)")
            print(f"  {Colors.GREEN}b{Colors.NC}) Back to main menu")
            print()
            
            if self.selected_files:
                print(f"{Colors.DIM}Press ENTER to add another file{Colors.NC}")
            else:
                print(f"{Colors.DIM}Press ENTER to add first file{Colors.NC}")
            
            choice = input("Choice: ").strip().lower()
            
            # Handle default action
            if not choice:
                choice = "a"
            
            if choice == "a":
                self.add_file()
            elif choice == "n":
                self.create_new_file()
            elif choice == "e":
                self.edit_file()
            elif choice == "c":
                self.add_clipboard_placeholder()
            elif choice == "r":
                self.remove_file()
            elif choice == "o":
                if self.selected_files:
                    self.reorder_files()
                else:
                    print(f"{Colors.YELLOW}No files to reorder{Colors.NC}")
                    input("Press ENTER to continue...")
            elif choice == "x":
                self.reset_composition()
                print(f"{Colors.GREEN}All files cleared{Colors.NC}")
                input("Press ENTER to continue...")
            elif choice == "d":
                if self.selected_files:
                    return True
                else:
                    print(f"{Colors.YELLOW}No files selected{Colors.NC}")
                    input("Press ENTER to continue...")
            elif choice == "b":
                return False
            else:
                print(f"{Colors.RED}Invalid choice{Colors.NC}")
                input("Press ENTER to continue...")
    
    def preview_preset(self, preset_name: str, start_with_squash: bool = False):
        """NEW: Preview preset with dedicated menu"""
        # Start squash mode if requested
        if start_with_squash and not self.clipboard_manager.is_squashing:
            self.clipboard_manager.start_squashing()
        
        while True:
            os.system('clear')
            print(f"{Colors.BOLD}{Colors.CYAN}=== Preset Preview: {preset_name} ==={Colors.NC}\n")
            
            if not self.selected_files:
                print(f"{Colors.YELLOW}No files in preset{Colors.NC}\n")
            else:
                print(f"{Colors.BOLD}Preset content:{Colors.NC}")
                for i, file_path in enumerate(self.selected_files, 1):
                    if str(file_path) == "[CLIPBOARD]":
                        print(f"  {Colors.GREEN}{i}{Colors.NC}) {Colors.YELLOW}[CLIPBOARD]{Colors.NC}")
                        if self.clipboard_manager.squashed_content:
                            content = self.clipboard_manager.get_squashed_content()
                            preview = content[:50].replace('\n', ' ')
                            print(f"      {Colors.DIM}{preview}...{Colors.NC}")
                    else:
                        print(f"  {Colors.GREEN}{i}{Colors.NC}) {file_path.name}")
                        try:
                            content = file_path.read_text()
                            preview = content[:50].replace('\n', ' ')
                            print(f"      {Colors.DIM}{preview}...{Colors.NC}")
                        except:
                            print(f"      {Colors.RED}Error reading file{Colors.NC}")
                print()
            
            print(f"{Colors.BOLD}Options:{Colors.NC}")
            print(f"  {Colors.GREEN}c{Colors.NC}) Copy to clipboard")
            squash_status = "ON" if self.clipboard_manager.is_squashing else "OFF"
            print(f"  {Colors.GREEN}s{Colors.NC}) Toggle squash mode (currently: {squash_status})")
            print(f"  {Colors.GREEN}e{Colors.NC}) Edit preset")
            print(f"  {Colors.GREEN}r{Colors.NC}) Remove preset")
            print(f"  {Colors.GREEN}b{Colors.NC}) Back to main menu")
            print()
            
            if not self.selected_files:
                print(f"{Colors.DIM}Press ENTER to copy to clipboard{Colors.NC}")
            
            choice = input("Choice: ").strip().lower()
            
            # Handle default action
            if not choice:
                choice = "c"
            
            if choice == "c":
                self.copy_to_clipboard()
                input("Press ENTER to continue...")
            elif choice == "s":
                if self.clipboard_manager.is_squashing:
                    self.clipboard_manager.stop_squashing()
                else:
                    self.clipboard_manager.start_squashing()
                # Don't wait for input - refresh immediately to show new status
            elif choice == "e":
                # Enter edit mode - use the file management but with preset context
                if self.manage_files_preset(preset_name):
                    # If user saved changes, reload the preset
                    self.load_preset_files(preset_name)
            elif choice == "r":
                confirm = input(f"Delete preset '{preset_name}'? (y/N): ").strip().lower()
                if confirm == 'y':
                    preset_file = self.config.config_dir / f"{preset_name}.preset"
                    preset_file.unlink()
                    print(f"{Colors.GREEN}Preset deleted: {preset_name}{Colors.NC}")
                    input("Press ENTER to continue...")
                    return True  # Return to main menu
            elif choice == "b":
                return False
            else:
                print(f"{Colors.RED}Invalid choice{Colors.NC}")
                input("Press ENTER to continue...")
    
    def manage_files_preset(self, preset_name: str) -> bool:
        """File management specifically for preset editing"""
        while True:
            os.system('clear')
            print(f"{Colors.BOLD}{Colors.CYAN}=== Editing Preset: {preset_name} ==={Colors.NC}\n")
            
            if self.selected_files:
                print(f"{Colors.BOLD}Current files:{Colors.NC}")
                for i, file_path in enumerate(self.selected_files, 1):
                    if str(file_path) == "[CLIPBOARD]":
                        display_name = f"{Colors.YELLOW}[CLIPBOARD]{Colors.NC}"
                    else:
                        display_name = file_path.name
                    print(f"  {Colors.GREEN}{i}{Colors.NC}) {display_name}")
                print()
            else:
                print(f"{Colors.DIM}No files selected yet{Colors.NC}\n")
            
            print(f"{Colors.BOLD}Options:{Colors.NC}")
            print(f"  {Colors.GREEN}a{Colors.NC}) Add file")
            print(f"  {Colors.GREEN}n{Colors.NC}) Create new file")
            print(f"  {Colors.GREEN}e{Colors.NC}) Edit file")
            print(f"  {Colors.GREEN}c{Colors.NC}) Add clipboard placeholder")
            print(f"  {Colors.GREEN}r{Colors.NC}) Remove file")
            print(f"  {Colors.GREEN}o{Colors.NC}) Reorder files")
            print(f"  {Colors.GREEN}x{Colors.NC}) Clear all (x)")
            print(f"  {Colors.GREEN}s{Colors.NC}) Save changes")
            print(f"  {Colors.GREEN}q{Colors.NC}) Quit without saving")
            print()
            
            choice = input("Choice: ").strip().lower()
            
            if choice == "a":
                self.add_file()
            elif choice == "n":
                self.create_new_file()
            elif choice == "e":
                self.edit_file()
            elif choice == "c":
                self.add_clipboard_placeholder()
            elif choice == "r":
                self.remove_file()
            elif choice == "o":
                if self.selected_files:
                    self.reorder_files()
                else:
                    print(f"{Colors.YELLOW}No files to reorder{Colors.NC}")
                    input("Press ENTER to continue...")
            elif choice == "x":
                self.reset_composition()
                print(f"{Colors.GREEN}All files cleared{Colors.NC}")
                input("Press ENTER to continue...")
            elif choice == "s":
                if self.save_preset(preset_name):
                    print(f"{Colors.GREEN}Preset updated: {preset_name}{Colors.NC}")
                    input("Press ENTER to continue...")
                    return True
            elif choice == "q":
                # Reload original preset
                self.load_preset_files(preset_name)
                return False
            else:
                print(f"{Colors.RED}Invalid choice{Colors.NC}")
                input("Press ENTER to continue...")
    
    def add_file(self):
        """Add file to composition using fzf"""
        prompts = self.find_prompts()
        
        if not prompts:
            print(f"{Colors.YELLOW}No prompt files found{Colors.NC}")
            input("Press ENTER to continue...")
            return
        
        print(f"{Colors.BOLD}Select file to add (using fzf):{Colors.NC}")
        selected_file = self.fzf.select_file(prompts)
        
        if not selected_file:
            print(f"{Colors.YELLOW}No file selected{Colors.NC}")
            input("Press ENTER to continue...")
            return
        
        # Check if already exists
        if selected_file in self.selected_files:
            print(f"{Colors.YELLOW}File already in composition{Colors.NC}")
            input("Press ENTER to continue...")
            return
        
        self.selected_files.append(selected_file)
        print(f"{Colors.GREEN}Added: {selected_file.name}{Colors.NC}")
        input("Press ENTER to continue...")
    
    def create_new_file(self):
        """Create a new prompt file"""
        print(f"{Colors.BOLD}Create new file:{Colors.NC}")
        filename = input("Filename: ").strip()
        
        if not filename:
            return
        
        # Add extension if missing
        if not any(filename.endswith(ext) for ext in ['.md', '.txt', '.prompt']):
            filename += '.md'
        
        file_path = self.config.prompts_dir / filename
        
        if file_path.exists():
            overwrite = input(f"File exists. Overwrite? (y/N): ").strip().lower()
            if overwrite != 'y':
                return
        
        # Create directory if needed
        file_path.parent.mkdir(parents=True, exist_ok=True)
        
        # Open editor
        try:
            subprocess.run([self.config.editor, str(file_path)], check=True)
            
            if file_path.exists() and file_path.stat().st_size > 0:
                # Refresh cache and add to composition
                self.find_prompts(force_refresh=True)
                if file_path not in self.selected_files:
                    self.selected_files.append(file_path)
                    print(f"{Colors.GREEN}Created and added: {filename}{Colors.NC}")
                else:
                    print(f"{Colors.YELLOW}File already in composition{Colors.NC}")
            else:
                print(f"{Colors.YELLOW}File creation cancelled or empty{Colors.NC}")
                
        except subprocess.CalledProcessError:
            print(f"{Colors.RED}Failed to open editor{Colors.NC}")
        
        input("Press ENTER to continue...")
    
    def edit_file(self):
        """Edit an existing file"""
        if not self.selected_files:
            print(f"{Colors.YELLOW}No files to edit{Colors.NC}")
            input("Press ENTER to continue...")
            return
        
        print(f"{Colors.BOLD}Select file to edit:{Colors.NC}")
        for i, file_path in enumerate(self.selected_files, 1):
            if str(file_path) == "[CLIPBOARD]":
                display_name = f"{Colors.YELLOW}[CLIPBOARD]{Colors.NC}"
            else:
                display_name = file_path.name
            print(f"  {i}) {display_name}")
        
        try:
            choice = int(input("File number: ")) - 1
            if 0 <= choice < len(self.selected_files):
                file_path = self.selected_files[choice]
                
                if str(file_path) == "[CLIPBOARD]":
                    print(f"{Colors.YELLOW}Cannot edit clipboard placeholder{Colors.NC}")
                else:
                    try:
                        subprocess.run([self.config.editor, str(file_path)], check=True)
                        print(f"{Colors.GREEN}Edited: {file_path.name}{Colors.NC}")
                    except subprocess.CalledProcessError:
                        print(f"{Colors.RED}Failed to open editor{Colors.NC}")
            else:
                print(f"{Colors.RED}Invalid selection{Colors.NC}")
        except ValueError:
            print(f"{Colors.RED}Invalid number{Colors.NC}")
        
        input("Press ENTER to continue...")
    
    def add_clipboard_placeholder(self):
        """Add clipboard placeholder to composition"""
        clipboard_placeholder = Path("[CLIPBOARD]")
        
        if clipboard_placeholder in self.selected_files:
            print(f"{Colors.YELLOW}Clipboard placeholder already in composition{Colors.NC}")
        else:
            self.selected_files.append(clipboard_placeholder)
            print(f"{Colors.GREEN}Added clipboard placeholder{Colors.NC}")
        
        input("Press ENTER to continue...")
    
    def remove_file(self):
        """Remove file from composition"""
        if not self.selected_files:
            print(f"{Colors.YELLOW}No files to remove{Colors.NC}")
            input("Press ENTER to continue...")
            return
        
        print(f"{Colors.BOLD}Select file to remove:{Colors.NC}")
        for i, file_path in enumerate(self.selected_files, 1):
            if str(file_path) == "[CLIPBOARD]":
                display_name = f"{Colors.YELLOW}[CLIPBOARD]{Colors.NC}"
            else:
                display_name = file_path.name
            print(f"  {i}) {display_name}")
        
        try:
            choice = int(input("File number: ")) - 1
            if 0 <= choice < len(self.selected_files):
                removed = self.selected_files.pop(choice)
                if str(removed) == "[CLIPBOARD]":
                    print(f"{Colors.GREEN}Removed clipboard placeholder{Colors.NC}")
                else:
                    print(f"{Colors.GREEN}Removed: {removed.name}{Colors.NC}")
            else:
                print(f"{Colors.RED}Invalid selection{Colors.NC}")
        except ValueError:
            print(f"{Colors.RED}Invalid number{Colors.NC}")
        
        input("Press ENTER to continue...")
    
    def reorder_files(self):
        """Reorder files in composition"""
        print(f"{Colors.BOLD}Current order:{Colors.NC}")
        for i, file_path in enumerate(self.selected_files, 1):
            if str(file_path) == "[CLIPBOARD]":
                display_name = f"{Colors.YELLOW}[CLIPBOARD]{Colors.NC}"
            else:
                display_name = file_path.name
            print(f"  {i}) {display_name}")
        
        print(f"\n{Colors.BOLD}Reorder options:{Colors.NC}")
        print(f"  {Colors.GREEN}k{Colors.NC}) Keep current order")
        print(f"  {Colors.GREEN}s{Colors.NC}) Swap two files")
        print(f"  {Colors.GREEN}m{Colors.NC}) Move file to position")
        print(f"  {Colors.GREEN}r{Colors.NC}) Reverse order")
        
        choice = input("Choice: ").strip().lower()
        
        if choice == "k":
            print(f"{Colors.GREEN}Order kept{Colors.NC}")
        elif choice == "s":
            self.swap_files()
        elif choice == "m":
            self.move_file()
        elif choice == "r":
            self.selected_files.reverse()
            print(f"{Colors.GREEN}Order reversed{Colors.NC}")
        else:
            print(f"{Colors.RED}Invalid choice{Colors.NC}")
        
        input("Press ENTER to continue...")
    
    def swap_files(self):
        """Swap positions of two files"""
        try:
            pos1 = int(input("First file position: ")) - 1
            pos2 = int(input("Second file position: ")) - 1
            
            if (0 <= pos1 < len(self.selected_files) and 
                0 <= pos2 < len(self.selected_files)):
                self.selected_files[pos1], self.selected_files[pos2] = \
                    self.selected_files[pos2], self.selected_files[pos1]
                print(f"{Colors.GREEN}Files swapped{Colors.NC}")
            else:
                print(f"{Colors.RED}Invalid positions{Colors.NC}")
        except ValueError:
            print(f"{Colors.RED}Invalid numbers{Colors.NC}")
    
    def move_file(self):
        """Move file to different position"""
        try:
            from_pos = int(input("File to move (position): ")) - 1
            to_pos = int(input("New position: ")) - 1
            
            if (0 <= from_pos < len(self.selected_files) and 
                0 <= to_pos < len(self.selected_files)):
                file = self.selected_files.pop(from_pos)
                self.selected_files.insert(to_pos, file)
                print(f"{Colors.GREEN}File moved{Colors.NC}")
            else:
                print(f"{Colors.RED}Invalid positions{Colors.NC}")
        except ValueError:
            print(f"{Colors.RED}Invalid numbers{Colors.NC}")
    
    def preview_composition(self) -> bool:
        """Preview composition and handle actions"""
        if not self.selected_files:
            print(f"{Colors.RED}No files in composition{Colors.NC}")
            return False
        
        os.system('clear')
        print(f"{Colors.BOLD}{Colors.CYAN}=== Composition Preview ==={Colors.NC}\n")
        
        for i, file_path in enumerate(self.selected_files, 1):
            if str(file_path) == "[CLIPBOARD]":
                print(f"{Colors.BOLD}{Colors.YELLOW}[{i}] [CLIPBOARD]{Colors.NC}")
                if self.clipboard_manager.squashed_content:
                    content = self.clipboard_manager.get_squashed_content()
                    preview = content[:100].replace('\n', ' ')
                    print(f"  {Colors.DIM}{preview}...{Colors.NC}")
                else:
                    print(f"  {Colors.DIM}Clipboard content will be inserted here{Colors.NC}")
            else:
                print(f"{Colors.BOLD}{Colors.BLUE}[{i}] {file_path.name}{Colors.NC}")
                try:
                    content = file_path.read_text()
                    preview = content[:100].replace('\n', ' ')
                    print(f"  {Colors.DIM}{preview}...{Colors.NC}")
                except:
                    print(f"  {Colors.RED}Error reading file{Colors.NC}")
            print()
        
        print(f"{Colors.BOLD}Actions:{Colors.NC}")
        print(f"  {Colors.GREEN}c{Colors.NC}) Copy to clipboard")
        print(f"  {Colors.GREEN}s{Colors.NC}) Save as preset")
        print(f"  {Colors.GREEN}x{Colors.NC}) Save as preset and copy")
        print(f"  {Colors.GREEN}e{Colors.NC}) Edit composition")
        print(f"  {Colors.GREEN}b{Colors.NC}) Back to main menu")
        print()
        
        default_hint = ""
        if self.last_action == "c":
            default_hint = "copy to clipboard"
        elif self.last_action == "s":
            default_hint = "save preset"
        elif self.last_action == "x":
            default_hint = "save and copy"
        
        if default_hint:
            print(f"{Colors.DIM}Press ENTER for last action: {default_hint}{Colors.NC}")
        
        return True
    
    def generate_composition(self) -> str:
        """Generate final composition text"""
        composition = []
        
        for file_path in self.selected_files:
            if str(file_path) == "[CLIPBOARD]":
                # Insert fresh clipboard content (not squashed)
                clipboard_content = self.clipboard_manager.get_fresh_clipboard_content()
                if clipboard_content:
                    composition.append(clipboard_content)
            else:
                # Add file content
                try:
                    composition.append(file_path.read_text())
                except:
                    print(f"{Colors.RED}Error reading file: {file_path}{Colors.NC}")
        
        return "\n\n".join(composition)
    
    def copy_to_clipboard(self):
        """Copy composition to clipboard"""
        # Stop squashing if active before copying
        if self.clipboard_manager.is_squashing:
            self.clipboard_manager.stop_squashing()
        
        composition = self.generate_composition()
        self.clipboard_manager.set_clipboard_content(composition)
        print(f"{Colors.GREEN}Composition copied to clipboard{Colors.NC}")
        self.save_last_action("c")
    
    def save_preset(self, preset_name: str = None) -> bool:
        """Save current composition as preset"""
        if not preset_name:
            print()
            preset_name = input("Preset name: ").strip()
        
        if not preset_name:
            print(f"{Colors.RED}Invalid preset name{Colors.NC}")
            return False
        
        # Sanitize filename
        preset_name = "".join(c for c in preset_name if c.isalnum() or c in '_-')
        preset_file = self.config.config_dir / f"{preset_name}.preset"
        
        if preset_file.exists() and not preset_name:
            confirm = input("Preset exists. Overwrite? (y/N): ").strip().lower()
            if confirm != 'y':
                print(f"{Colors.YELLOW}Preset not saved{Colors.NC}")
                return False
        
        # Save file paths (use absolute paths for compatibility)
        with open(preset_file, 'w') as f:
            for file_path in self.selected_files:
                if str(file_path) == "[CLIPBOARD]":
                    f.write("[CLIPBOARD]\n")
                else:
                    f.write(str(file_path) + "\n")  # Absolute path
        
        print(f"{Colors.GREEN}Preset saved: {preset_name}{Colors.NC}")
        self.save_last_action("s")
        return True
    
    def load_preset_files(self, preset_name: str) -> List[Path]:
        """Load preset files without changing mode"""
        preset_file = self.config.config_dir / f"{preset_name}.preset"
        
        if not preset_file.exists():
            return []
        
        files = []
        with open(preset_file, 'r') as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                    
                if line == "[CLIPBOARD]":
                    files.append(Path("[CLIPBOARD]"))
                else:
                    # Try as absolute path first, then as relative path
                    file_path = Path(line)
                    if not file_path.exists():
                        # Try as relative to prompts_dir
                        file_path = self.config.prompts_dir / line
                    
                    if file_path.exists():
                        files.append(file_path)
        
        return files
    
    def load_preset(self, mode: str = "preview", start_with_squash: bool = False) -> Optional[str]:
        """Load preset from file using fzf - FIXED"""
        presets = list(self.config.config_dir.glob("*.preset"))
        
        if not presets:
            print(f"{Colors.YELLOW}No presets found{Colors.NC}")
            input("Press ENTER to continue...")
            return None
        
        print(f"{Colors.BOLD}Select preset (using fzf):{Colors.NC}")
        selected_preset = self.fzf.select_preset(presets)
        
        if not selected_preset:
            print(f"{Colors.YELLOW}No preset selected{Colors.NC}")
            input("Press ENTER to continue...")
            return None
        
        preset_name = selected_preset.stem
        
        # Load the files into selected_files
        self.selected_files = self.load_preset_files(preset_name)
        
        if not self.selected_files:
            print(f"{Colors.YELLOW}Preset is empty or files not found{Colors.NC}")
            input("Press ENTER to continue...")
            return None
        
        print(f"{Colors.GREEN}Loaded preset: {preset_name}{Colors.NC}")
        print(f"{Colors.GREEN}Loaded {len(self.selected_files)} files{Colors.NC}")
        
        if mode == "copy":
            self.copy_to_clipboard()
            return None
        else:
            self.save_last_action("cd")
            return preset_name
    
    def list_presets(self):
        """List all available presets"""
        os.system('clear')
        print(f"{Colors.BOLD}{Colors.CYAN}=== Available Presets ==={Colors.NC}\n")
        
        presets = list(self.config.config_dir.glob("*.preset"))
        
        if not presets:
            print(f"{Colors.YELLOW}No presets found{Colors.NC}")
        else:
            for preset in presets:
                files = self.load_preset_files(preset.stem)
                file_count = len(files)
                
                print(f"{Colors.GREEN}{preset.stem}{Colors.NC} {Colors.DIM}({file_count} items){Colors.NC}")
                
                # Show first few items
                for i, file_path in enumerate(files):
                    if i >= 3:
                        break
                    if str(file_path) == "[CLIPBOARD]":
                        display = f"{Colors.YELLOW}[CLIPBOARD]{Colors.NC}"
                    else:
                        # Show just the filename for clarity
                        display = file_path.name
                    print(f"  - {display}")
                
                if file_count > 3:
                    print(f"  {Colors.DIM}... and {file_count - 3} more{Colors.NC}")
                print()
        
        input("Press ENTER to continue...")
        self.save_last_action("ls")
    
    def delete_preset(self):
        """Delete a preset using fzf"""
        presets = list(self.config.config_dir.glob("*.preset"))
        
        if not presets:
            print(f"{Colors.YELLOW}No presets found{Colors.NC}")
            input("Press ENTER to continue...")
            return
        
        print(f"{Colors.BOLD}Select preset to delete (using fzf):{Colors.NC}")
        selected_preset = self.fzf.select_preset(presets)
        
        if not selected_preset:
            print(f"{Colors.YELLOW}No preset selected{Colors.NC}")
            input("Press ENTER to continue...")
            return
        
        preset_name = selected_preset.stem
        confirm = input(f"Delete preset '{preset_name}'? (y/N): ").strip().lower()
        if confirm == 'y':
            selected_preset.unlink()
            print(f"{Colors.GREEN}Preset deleted: {preset_name}{Colors.NC}")
        else:
            print(f"{Colors.YELLOW}Deletion cancelled{Colors.NC}")
        
        input("Press ENTER to continue...")
    
    def create_composition(self):
        """Create new composition workflow"""
        self.reset_composition()  # Fix: Clear previous state
        
        if not self.manage_files():
            return
        
        while True:
            if not self.preview_composition():
                break
            
            choice = input("Choice: ").strip().lower()
            
            # Handle default action
            if not choice:
                choice = self.last_action
            
            if choice == "c":
                self.copy_to_clipboard()
                input("Press ENTER to continue...")
            elif choice == "s":
                self.save_preset()
                input("Press ENTER to continue...")
            elif choice == "x":
                if self.save_preset():
                    self.copy_to_clipboard()
                input("Press ENTER to continue...")
            elif choice == "e":
                self.manage_files()
            elif choice == "b":
                return
            else:
                print(f"{Colors.RED}Invalid choice{Colors.NC}")
                input("Press ENTER to continue...")
    
    def run(self):
        """Main application loop"""
        try:
            # Handle command line argument
            if len(sys.argv) > 1:
                preset_name = sys.argv[1]
                preset_file = self.config.config_dir / f"{preset_name}.preset"
                
                if preset_file.exists():
                    # Load and copy preset directly
                    self.selected_files = self.load_preset_files(preset_name)
                    self.copy_to_clipboard()
                    return
                else:
                    print(f"{Colors.RED}Preset not found: {preset_name}{Colors.NC}")
                    return
            
            # Main menu loop
            while True:
                self.show_main_menu()
                choice = input("Choice: ").strip().lower()
                
                # Handle default action
                if not choice:
                    choice = self.last_action
                
                if choice == "n":
                    self.create_composition()
                    self.save_last_action("n")
                elif choice == "cd":
                    preset_name = self.load_preset("preview")
                    if preset_name:
                        self.preview_preset(preset_name)
                elif choice == "cds":
                    preset_name = self.load_preset("preview")
                    if preset_name:
                        self.preview_preset(preset_name, start_with_squash=True)
                elif choice == "cp":
                    self.load_preset("copy")
                    self.save_last_action("cp")
                elif choice == "ls":
                    self.list_presets()
                elif choice == "rm":
                    self.delete_preset()
                elif choice in ("q", "quit"):
                    print(f"{Colors.GREEN}Goodbye!{Colors.NC}")
                    break
                else:
                    print(f"{Colors.RED}Invalid choice{Colors.NC}")
                    input("Press ENTER to continue...")
        
        finally:
            self.cleanup()
            self.clipboard_manager.stop_squashing()

def main():
    """Main entry point"""
    # Check if fzf is available
    if not shutil.which("fzf"):
        print(f"{Colors.RED}Error: fzf is required but not installed{Colors.NC}")
        print(f"Install with: {Colors.CYAN}sudo apt install fzf{Colors.NC} (Ubuntu/Debian)")
        print(f"           or: {Colors.CYAN}brew install fzf{Colors.NC} (macOS)")
        sys.exit(1)
    
    composer = PromptComposer()
    composer.run()

if __name__ == "__main__":
    main()
