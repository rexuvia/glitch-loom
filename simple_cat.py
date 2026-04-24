#!/usr/bin/env python3

# Create a 30x30 ASCII art cat using a different approach
# Let's make a cat silhouette using @, #, *, ., -, _, |, /, \, =, +, o, O, 0

cat = []

# Top of head
cat.append("        .-\"\"\"\"\"\"-.        ")
cat.append("       /          \\       ")
cat.append("      /            \\      ")
cat.append("     /              \\     ")
cat.append("    /                \\    ")
cat.append("   /                  \\   ")
cat.append("  /                    \\  ")
cat.append(" /                      \\ ")

# Face area
cat.append("|       .-\"\"-.       |")
cat.append("|      /      \\      |")
cat.append("|     |  @  @  |     |")  # Eyes
cat.append("|     |   #    |     |")  # Nose
cat.append("|      \\  --  /      |")  # Mouth
cat.append("|       '-..-'       |")
cat.append("|                    |")

# Whiskers and lower face
cat.append("|    \\  /      \\  /    |")
cat.append("|     \\/        \\/     |")
cat.append("|      /\\        /\\     |")
cat.append("|     /  \\      /  \\    |")
cat.append("|    /    \\    /    \\   |")
cat.append("|   /      \\  /      \\  |")
cat.append("|  /        \\/        \\ |")
cat.append("| /                    \\|")
cat.append("|/                      \\")

# Chin/neck area
cat.append("|                        |")
cat.append("|                        |")
cat.append("|                        |")
cat.append("|                        |")
cat.append("|                        |")
cat.append("|                        |")
cat.append("|                        |")
cat.append("|                        |")

# Ensure we have exactly 30 lines
while len(cat) < 30:
    cat.append(" " * 30)

# Trim to first 30 lines
cat = cat[:30]

# Ensure each line is exactly 30 characters
for i in range(len(cat)):
    line = cat[i]
    if len(line) < 30:
        line = line + " " * (30 - len(line))
    elif len(line) > 30:
        line = line[:30]
    cat[i] = line

# Print with line numbers for verification
print("30x30 ASCII Cat Art:")
print("=" * 32)
for i, line in enumerate(cat):
    print(f"{line}")
print("=" * 32)

# Save to file
with open("cat_ascii_30x30.txt", "w") as f:
    for line in cat:
        f.write(line + "\n")

print(f"\nSaved to cat_ascii_30x30.txt")
print(f"Dimensions: {len(cat)} lines x {len(cat[0])} chars")