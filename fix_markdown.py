import re

# Read the ASCII art
with open('cat_30x30_perfect.txt', 'r') as f:
    ascii_art = f.read()

# Read the Markdown file
with open('modelshow-published/generate-a-30-by-30-2026-03-15-1216.md', 'r') as f:
    content = f.read()

# Find the Pro model's response section and add the ASCII art
# Look for "**Full Response:**" followed by the Pro model's response
pro_section_start = content.find('### 🏆 **google/gemini-2.5-pro**')
if pro_section_start == -1:
    print("Could not find Pro model section")
    exit(1)

# Find the end of the Pro model section (next model or end of section)
next_model = content.find('### 🥈', pro_section_start)
if next_model == -1:
    next_model = len(content)

pro_section = content[pro_section_start:next_model]

# Find where to insert the ASCII art - after the existing response
response_end = pro_section.find('**Task completed:**')
if response_end == -1:
    response_end = len(pro_section)

# Insert the ASCII art
ascii_art_block = f"\n\n**Actual 30x30 ASCII Art:**\n\n```\n{ascii_art}\n```\n"
new_pro_section = pro_section[:response_end] + ascii_art_block + pro_section[response_end:]

# Replace the section in the full content
new_content = content[:pro_section_start] + new_pro_section + content[pro_section_start + len(pro_section):]

# Write back
with open('modelshow-published/generate-a-30-by-30-2026-03-15-1216.md', 'w') as f:
    f.write(new_content)

print("Markdown updated successfully")