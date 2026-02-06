from PIL import Image, ImageDraw

def round_corners(image_path, output_path, radius_factor=0.22):
    img = Image.open(image_path).convert("RGBA")
    width, height = img.size
    radius = int(min(width, height) * radius_factor)

    # Create mask
    mask = Image.new("L", (width, height), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, width, height), radius=radius, fill=255)

    # Apply mask
    output = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    output.paste(img, mask=mask)
    
    output.save(output_path)
    print(f"Saved rounded icon to {output_path}")

if __name__ == "__main__":
    round_corners("assets/app_icon.jpg", "assets/app_icon_macos.png")
