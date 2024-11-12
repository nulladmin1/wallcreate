from PIL import Image, ImageDraw, ImageFilter
from pathlib import Path

def main():
    base_image = Image.new("RGBA",(1920, 1200), color='white')
    logo = Image.open('assets/distros/NixOS/nixos.svg')

    base_image.paste(logo)
    base_image.save('img.png')
if __name__ == "__main__":
    main()
