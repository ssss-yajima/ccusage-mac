#!/usr/bin/env python3
"""
Create an app icon for CCUsageMac using the brain emoji
"""

import os
from PIL import Image, ImageDraw, ImageFont
import subprocess

def create_icon():
    # Create a 1024x1024 image with gradient background
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Create gradient background (dark blue to purple)
    for y in range(size):
        # Gradient from top to bottom
        ratio = y / size
        r = int(30 + (60 - 30) * ratio)
        g = int(40 + (30 - 40) * ratio)
        b = int(80 + (120 - 80) * ratio)
        draw.rectangle([(0, y), (size, y+1)], fill=(r, g, b, 255))
    
    # Add rounded corners
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    radius = 180
    mask_draw.rounded_rectangle([(0, 0), (size, size)], radius=radius, fill=255)
    
    # Apply rounded corners
    output = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    output.paste(img, (0, 0))
    output.putalpha(mask)
    
    # Add brain emoji text
    try:
        # Try to use system font
        font = ImageFont.truetype('/System/Library/Fonts/Apple Color Emoji.ttc', 600)
    except:
        # Fallback to default
        font = ImageFont.load_default()
    
    # Draw brain emoji
    text = "🧠"
    draw = ImageDraw.Draw(output)
    
    # Get text bbox for centering
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    x = (size - text_width) // 2
    y = (size - text_height) // 2 - 50  # Slightly above center
    
    # Draw text with shadow
    shadow_offset = 20
    draw.text((x + shadow_offset, y + shadow_offset), text, font=font, fill=(0, 0, 0, 128))
    draw.text((x, y), text, font=font, fill=(255, 255, 255, 255))
    
    # Add cost indicator at bottom
    try:
        small_font = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', 120)
    except:
        small_font = ImageFont.load_default()
    
    cost_text = "$"
    bbox = draw.textbbox((0, 0), cost_text, font=small_font)
    text_width = bbox[2] - bbox[0]
    x = (size - text_width) // 2
    y = size - 300
    
    # Draw dollar sign with glow effect
    for offset in range(10, 0, -2):
        alpha = int(255 * (1 - offset/10) * 0.3)
        draw.text((x - offset, y), cost_text, font=small_font, fill=(255, 255, 255, alpha))
        draw.text((x + offset, y), cost_text, font=small_font, fill=(255, 255, 255, alpha))
        draw.text((x, y - offset), cost_text, font=small_font, fill=(255, 255, 255, alpha))
        draw.text((x, y + offset), cost_text, font=small_font, fill=(255, 255, 255, alpha))
    
    draw.text((x, y), cost_text, font=small_font, fill=(255, 255, 255, 255))
    
    return output

def create_icns(base_image):
    """Create .icns file from base image"""
    
    # Create temporary directory
    os.makedirs('icon.iconset', exist_ok=True)
    
    # Define icon sizes
    sizes = [
        (16, 1), (16, 2),
        (32, 1), (32, 2),
        (128, 1), (128, 2),
        (256, 1), (256, 2),
        (512, 1), (512, 2)
    ]
    
    for size, scale in sizes:
        actual_size = size * scale
        suffix = f"@{scale}x" if scale > 1 else ""
        filename = f"icon_{size}x{size}{suffix}.png"
        
        # Resize image
        resized = base_image.resize((actual_size, actual_size), Image.Resampling.LANCZOS)
        resized.save(f"icon.iconset/{filename}")
    
    # Convert to icns
    subprocess.run(['iconutil', '-c', 'icns', 'icon.iconset'])
    
    # Clean up
    subprocess.run(['rm', '-rf', 'icon.iconset'])
    
    print("Created icon.icns")

if __name__ == '__main__':
    # Check if PIL is installed
    try:
        from PIL import Image, ImageDraw, ImageFont
    except ImportError:
        print("Installing Pillow...")
        subprocess.run(['pip3', 'install', 'Pillow'])
        from PIL import Image, ImageDraw, ImageFont
    
    # Create icon
    icon = create_icon()
    icon.save('icon_preview.png')
    print("Created icon_preview.png")
    
    # Create icns
    create_icns(icon)