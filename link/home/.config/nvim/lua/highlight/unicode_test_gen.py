# generate_unicode_test.py
import os

# Get the absolute directory where this script is located
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
filename = os.path.join(SCRIPT_DIR, "unicode_test.txt")

# 1. Structured list with acronyms as keys and merged hex values
unicode_chars = [
    # --- Invisible Characters ---
    {"key": "ZWSP", "hex": "U+200B", "name": "Zero-Width Space", "category": "invisible"},
    {"key": "ZWNJ", "hex": "U+200C", "name": "Zero-Width Non-Joiner", "category": "invisible"},
    {"key": "ZWJ",  "hex": "U+200D", "name": "Zero-Width Joiner", "category": "invisible"},
    {"key": "BOM",  "hex": "U+FEFF", "name": "Byte Order Mark", "category": "invisible"},
    {"key": "NBSP", "hex": "U+00A0", "name": "Non-Breaking Space", "category": "invisible"},
    {"key": "SHY",  "hex": "U+00AD", "name": "Soft Hyphen", "category": "invisible"},

    # --- Problematic / Security Characters ---
    {"key": "RLO",  "hex": "U+202E", "name": "Right-to-Left Override", "category": "problematic"},
    {"key": "LRE",  "hex": "U+202A", "name": "Left-to-Right Embedding", "category": "problematic"},
    {"key": "PDF",  "hex": "U+202C", "name": "Pop Directional Formatting", "category": "problematic"},

    # --- Invalid Unicode / Non-characters ---
    {"key": "B_SUR", "hex": "U+D800", "name": "Isolated Lead Surrogate (Invalid UTF-8)", "category": "invalid"},
    {"key": "E_SUR", "hex": "U+DFFF", "name": "Isolated Trail Surrogate (Invalid UTF-8)", "category": "invalid"},
    {"key": "NON_C", "hex": "U+FFFF", "name": "Unicode Non-character (U+FFFF)", "category": "invalid"},
]

# Helper function to safely convert "U+XXXX" string to raw character symbol
def get_char(hex_str):
    return chr(int(hex_str.replace("U+", ""), 16))

# --- GENERATE TEST FILE CONTENT ---
content_bytes = bytearray()

def append_str(text):
    # Use surrogatepass here to allow the strings containing surrogates to compile cleanly into bytes
    content_bytes.extend(text.encode("utf-8", errors="surrogatepass"))

# Standard characters output loop
for i, item in enumerate(unicode_chars, 1):
    val = int(item["hex"].replace("U+", ""), 16)
    raw_char = chr(val)
    append_str(f"{i}. {item['name']} ({item['key']} - {item['hex']}):\n   Before->")
    content_bytes.extend(raw_char.encode("utf-8", errors="surrogatepass"))
    append_str("<-After\n\n")

# Add the ASCII smuggling range block
append_str("13. ASCII Smuggling Block Range (U+E0000 to U+E007F):\n   Before->")
for code_point in range(0xE0000, 0xE0080):
    content_bytes.extend(chr(code_point).encode("utf-8"))
append_str("<-After\n")

# Write out using binary mode to preserve bad/corrupted sequences
with open(filename, "wb") as f:
    f.write(content_bytes)

print(f"Success! Created 'unicode_test.txt' at: {filename}\n")


# --- GENERATE AND PRINT PATTERNS BY DISTINCT CATEGORY VARIABLES ---

invisible_patterns = []
problematic_patterns = []
invalid_patterns = []
range_patterns = []

# Populate block ranges into the range list
block_ranges = [
    "\\%u0000-\\%u001f", # C0 Controls
    "\\%u007f-\\%u009f", # Delete & C1 Controls
    "\\%ud800-\\%udfff"  # Surrogate pairs block
]
for block in block_ranges:
    range_patterns.append(f"\\[{block}\\]")

# Dynamically add the ASCII Smuggling Block character range to the range list
start_char = chr(0xE0000)
end_char = chr(0xE007F)
range_patterns.append(f"\\[{start_char}-{end_char}\\]")

# Sort the dictionary items into their respective category variables
for item in unicode_chars:
    clean_hex = item["hex"].replace("U+", "").lower()
    pattern_str = f"\\%u{clean_hex}"

    if item["category"] == "invisible":
        invisible_patterns.append(pattern_str)
    elif item["category"] == "problematic":
        problematic_patterns.append(pattern_str)
    elif item["category"] == "invalid":
        # Skip entries entirely covered by the surrogate range block to avoid redundancy
        if not (0xD800 <= int(clean_hex, 16) <= 0xDFFF):
            invalid_patterns.append(pattern_str)

# Join each category collection into individual strings
invisible_regex = "\\|".join(invisible_patterns)
problematic_regex = "\\|".join(problematic_patterns)
invalid_regex = "\\|".join(invalid_patterns)
range_regex = "\\|".join(range_patterns)

# Print distinct variable outputs
print("=" * 60)
print("DISTINCT CATEGORY VARIABLES:")
print("=" * 60)
print(f"INVISIBLE_REGEX   = {invisible_regex}")
print(f"PROBLEMATIC_REGEX = {problematic_regex}")
print(f"INVALID_REGEX     = {invalid_regex}")
print(f"RANGE_REGEX       = {range_regex}")
print("=" * 60)

# Combine all lists for the final merged regex string
all_patterns = range_patterns + invisible_patterns + problematic_patterns + invalid_patterns
final_regex_str = "\\|".join(all_patterns)

print("\nFINAL_MERGED_REGEX_STR:")
print(final_regex_str)
print("=" * 60)
