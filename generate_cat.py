#!/usr/bin/env python3

# Create a 30x30 ASCII art cat face
cat_art = []

# Top border and head shape
cat_art.append("        .-\"\"\"\"\"\"-.        ")
cat_art.append("       /          \\       ")
cat_art.append("      /            \\      ")
cat_art.append("     /              \\     ")
cat_art.append("    /                \\    ")
cat_art.append("   /                  \\   ")
cat_art.append("  /                    \\  ")
cat_art.append(" /                      \\ ")
cat_art.append("|       .-\"\"-.       |")
cat_art.append("|      /      \\      |")
cat_art.append("|     |  o  o  |     |")
cat_art.append("|     |   ∆    |     |")
cat_art.append("|      \\  --  /      |")
cat_art.append("|       '-..-'       |")
cat_art.append("|                    |")
cat_art.append("|       /      \\     |")
cat_art.append("|      /        \\    |")
cat_art.append("|     /          \\   |")
cat_art.append("|    /            \\  |")
cat_art.append("|   /              \\ |")
cat_art.append("|  /                \\|")
cat_art.append("| /                  \\ ")
cat_art.append("|/                    \\ ")
cat_art.append("|                      |")
cat_art.append("|                      |")
cat_art.append("|                      |")
cat_art.append("|                      |")
cat_art.append("|                      |")
cat_art.append("|                      |")
cat_art.append("|                      |")

# Pad to exactly 30 lines
while len(cat_art) < 30:
    cat_art.append(" " * 30)

# Ensure each line is exactly 30 characters
for i in range(len(cat_art)):
    line = cat_art[i]
    if len(line) < 30:
        line = line + " " * (30 - len(line))
    elif len(line) > 30:
        line = line[:30]
    cat_art[i] = line

# Print the result
for line in cat_art:
    print(line)

# Also save to file
with open("cat_final.txt", "w") as f:
    for line in cat_art:
        f.write(line + "\n")