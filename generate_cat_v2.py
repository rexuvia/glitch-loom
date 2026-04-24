#!/usr/bin/env python3

# Create a 30x30 ASCII art cat silhouette/face
# Using a more creative design that fills the space

cat = [
    "        .-""""""""-.        ",
    "       /            \\       ",
    "      /              \\      ",
    "     /                \\     ",
    "    /                  \\    ",
    "   /                    \\   ",
    "  /                      \\  ",
    " /                        \\ ",
    "|        .-""""-.        |",
    "|       /        \\       |",
    "|      |  o    o  |      |",
    "|      |    ∆     |      |",
    "|       \\  ----  /       |",
    "|        '-....-'        |",
    "|                        |",
    "|        /      \\        |",
    "|       /        \\       |",
    "|      /          \\      |",
    "|     /            \\     |",
    "|    /              \\    |",
    "|   /                \\   |",
    "|  /                  \\  |",
    "| /                    \\ |",
    "|/                      \\|",
    "|                        |",
    "|                        |",
    "|                        |",
    "|                        |",
    "|                        |",
    "|                        |"
]

# Fix string escaping
for i in range(len(cat)):
    cat[i] = cat[i].replace('""""""""', '\"\"\"\"\"\"\"\"')
    cat[i] = cat[i].replace('""""', '\"\"\"\"')

# Ensure each line is exactly 30 characters
for i in range(len(cat)):
    line = cat[i]
    if len(line) < 30:
        line = line + " " * (30 - len(line))
    elif len(line) > 30:
        line = line[:30]
    cat[i] = line

# Print the result
print("30x30 ASCII Cat Art:")
print("=" * 32)
for i, line in enumerate(cat):
    print(f"{i+1:2}: {line}")
print("=" * 32)

# Also save to file
with open("cat_30x30_final.txt", "w") as f:
    for line in cat:
        f.write(line + "\n")

print(f"\nSaved to cat_30x30_final.txt")
print(f"Total lines: {len(cat)}")
print(f"Line length: {len(cat[0])}")