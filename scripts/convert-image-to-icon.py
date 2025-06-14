#!/usr/bin/env python3
"""
Convert the Gemini generated image to app icon
"""

import os
from PIL import Image
import subprocess
import numpy as np

def remove_black_background(img):
    """Remove black background and make it transparent"""
    # Convert to RGBA
    img = img.convert('RGBA')
    
    # Get image data as numpy array
    data = np.array(img)
    
    # Find black pixels (with some tolerance for anti-aliasing)
    # Black pixels have RGB values close to 0
    tolerance = 30
    black_mask = (data[:,:,0] < tolerance) & (data[:,:,1] < tolerance) & (data[:,:,2] < tolerance)
    
    # Make black pixels transparent
    data[black_mask] = [0, 0, 0, 0]
    
    # Create new image
    new_img = Image.fromarray(data, 'RGBA')
    
    # Find the bounding box of non-transparent pixels
    bbox = new_img.getbbox()
    if bbox:
        # Crop to remove transparent edges
        new_img = new_img.crop(bbox)
    
    return new_img

def create_square_icon(img, size=1024):
    """Create a square icon with the image centered"""
    # Create a new square image with transparent background
    square_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    
    # Calculate position to center the image
    img_width, img_height = img.size
    
    # Scale image to fit within the square while maintaining aspect ratio
    scale = min(size * 0.9 / img_width, size * 0.9 / img_height)
    new_width = int(img_width * scale)
    new_height = int(img_height * scale)
    
    # Resize image
    img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
    
    # Calculate position to paste
    x = (size - new_width) // 2
    y = (size - new_height) // 2
    
    # Paste the image onto the square canvas
    square_img.paste(img, (x, y), img)
    
    # Add subtle dark background for better visibility
    background = Image.new('RGBA', (size, size), (20, 20, 30, 255))
    
    # Create rounded rectangle mask
    mask = Image.new('L', (size, size), 0)
    from PIL import ImageDraw
    draw = ImageDraw.Draw(mask)
    radius = 180
    draw.rounded_rectangle([(0, 0), (size, size)], radius=radius, fill=255)
    
    # Apply mask to background
    background.putalpha(mask)
    
    # Composite the icon over the background
    final = Image.alpha_composite(background, square_img)
    
    return final

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
        from PIL import Image, ImageDraw
        import numpy as np
    except ImportError:
        print("Installing required packages...")
        subprocess.run(['pip3', 'install', 'Pillow', 'numpy'])
        from PIL import Image, ImageDraw
        import numpy as np
    
    # Load the Gemini generated image
    input_path = 'CCUsageMac/Resources/Gemini_Generated_Image_s58u6js58u6js58u.jpeg'
    
    if not os.path.exists(input_path):
        print(f"Error: Image not found at {input_path}")
        exit(1)
    
    # Process image
    print("Loading image...")
    img = Image.open(input_path)
    
    print("Removing black background...")
    img = remove_black_background(img)
    
    print("Creating square icon...")
    icon = create_square_icon(img)
    
    # Save preview
    icon.save('icon_preview_new.png')
    print("Created icon_preview_new.png")
    
    # Create icns
    create_icns(icon)
    
    # Move to Resources directory
    import shutil
    shutil.move('icon.icns', 'CCUsageMac/Resources/AppIcon.icns')
    print("Moved icon to CCUsageMac/Resources/AppIcon.icns")