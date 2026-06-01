from pathlib import Path
import json

PROJECT_ROOT = Path.cwd()

OUTPUT_TXT = PROJECT_ROOT / "extracted_example_data.txt"
OUTPUT_JSON = PROJECT_ROOT / "extracted_example_data.json"

# Folders/files we definitely want
INCLUDE_PATHS = [
    PROJECT_ROOT / "main",
    PROJECT_ROOT / "CMakeLists.txt",
    PROJECT_ROOT / "idf_component.yml",
    PROJECT_ROOT / "README.md",

    # Important for model flashing / partition setup
    PROJECT_ROOT / "partitions.csv",
    PROJECT_ROOT / "partitions2.csv",

    # Board / dependency lock files can show which target and components are used
    PROJECT_ROOT / "dependencies.lock.esp32_p4_function_ev_board",
    PROJECT_ROOT / "dependencies.lock.esp32_p4_eye",
    PROJECT_ROOT / "dependencies.lock.esp32_s3_eye",
    PROJECT_ROOT / "dependencies.lock.esp32_s3_korvo_2",
    PROJECT_ROOT / "dependencies.lock.esp32_s3_lcd_ev_board",

    # sdkconfig files can contain camera/LCD/model/component settings
    PROJECT_ROOT / "sdkconfig",
    PROJECT_ROOT / "sdkconfig.defaults",
    PROJECT_ROOT / "sdkconfig.bsp.esp32_p4_function_ev_board",
    PROJECT_ROOT / "sdkconfig.bsp.esp32_p4_eye",
    PROJECT_ROOT / "sdkconfig.bsp.esp32_s3_eye",
    PROJECT_ROOT / "sdkconfig.bsp.esp32_s3_korvo_2",

    # Flash script may show how model.bin is flashed
    PROJECT_ROOT / "flash_p4.sh",
]

EXCLUDE_DIRS = {
    "build",
    ".git",
    ".vscode",
    "__pycache__",
    "managed_components",
}

TEXT_EXTENSIONS = {
    ".c",
    ".h",
    ".cpp",
    ".hpp",
    ".cc",
    ".hh",
    ".txt",
    ".cmake",
    ".yml",
    ".yaml",
    ".csv",
    ".md",
    ".json",
    ".defaults",
    ".sh",
}

SPECIAL_NAMES = {
    "CMakeLists.txt",
    "sdkconfig",
    "sdkconfig.defaults",
}


def should_skip(path: Path) -> bool:
    return any(part in EXCLUDE_DIRS for part in path.parts)


def is_text_file(path: Path) -> bool:
    if path.name in SPECIAL_NAMES:
        return True
    if path.suffix in TEXT_EXTENSIONS:
        return True
    if path.name.startswith("dependencies.lock"):
        return True
    if path.name.startswith("sdkconfig.bsp"):
        return True
    return False


def read_file(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        try:
            return path.read_text(encoding="latin-1")
        except Exception as e:
            return f"[ERROR READING FILE: {e}]"
    except Exception as e:
        return f"[ERROR READING FILE: {e}]"


def collect_files():
    files = []

    for target in INCLUDE_PATHS:
        if not target.exists():
            continue

        if should_skip(target):
            continue

        if target.is_file():
            if is_text_file(target):
                files.append(target)
            continue

        if target.is_dir():
            for path in target.rglob("*"):
                if should_skip(path):
                    continue
                if path.is_file() and is_text_file(path):
                    files.append(path)

    return sorted(set(files))


def main():
    files = collect_files()
    data = []

    with OUTPUT_TXT.open("w", encoding="utf-8") as txt:
        for file_path in files:
            rel = file_path.relative_to(PROJECT_ROOT)
            content = read_file(file_path)

            data.append({
                "path": str(rel),
                "content": content,
            })

            txt.write("\n" + "=" * 80 + "\n")
            txt.write(f"FILE: {rel}\n")
            txt.write("=" * 80 + "\n\n")
            txt.write(content)
            txt.write("\n")

    with OUTPUT_JSON.open("w", encoding="utf-8") as js:
        json.dump(data, js, indent=2, ensure_ascii=False)

    print(f"Extracted {len(files)} files.")
    print(f"Text output: {OUTPUT_TXT}")
    print(f"JSON output: {OUTPUT_JSON}")

    print("\nFiles extracted:")
    for file_path in files:
        print("-", file_path.relative_to(PROJECT_ROOT))


if __name__ == "__main__":
    main()
