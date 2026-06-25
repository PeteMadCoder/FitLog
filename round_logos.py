import os
import glob
from PIL import Image, ImageDraw

def process_icon(src_image_path, dest_path):
    print(f"Processing: {dest_path}")
    
    # Get original icon size and format
    with Image.open(dest_path) as orig:
        width, height = orig.size
        orig_mode = orig.mode
        
    N = width
    # Check if target should be RGB (e.g. iOS icons) or RGBA (Android, macOS, Web)
    # iOS App Icons must not have transparency (must be RGB or opaque)
    if "ios/Runner/Assets.xcassets" in dest_path:
        target_mode = "RGB"
    else:
        target_mode = "RGBA"
        
    # Load source bike logo
    bike_src = Image.open(src_image_path)
    
    if target_mode == "RGBA":
        # Create a transparent canvas
        canvas = Image.new("RGBA", (N, N), (0, 0, 0, 0))
        
        # Determine padding/margin and corner radius
        if N <= 32:
            # Small icons like favicons: no margins, no rounded corners needed
            margin = 0
            radius = 0
        else:
            margin = int(N * 0.08)
            radius = int((N - 2 * margin) * 0.22)
            
        draw = ImageDraw.Draw(canvas)
        if N > 32:
            # Draw white rounded rectangle card
            draw.rounded_rectangle(
                [margin, margin, N - margin, N - margin],
                radius=radius,
                fill=(255, 255, 255, 255)
            )
        else:
            # Solid white rectangle for small canvas
            draw.rectangle(
                [0, 0, N, N],
                fill=(255, 255, 255, 255)
            )
            
        # Paste resized bike logo centered in the rounded rectangle
        bike_size = N - 2 * margin
        bike_resized = bike_src.resize((bike_size, bike_size), Image.Resampling.LANCZOS)
        canvas.paste(bike_resized, (margin, margin), bike_resized)
    else:
        # RGB mode (solid white background, no transparent corners)
        canvas = Image.new("RGB", (N, N), (255, 255, 255))
        
        # Center the bike logo with a small padding (e.g. 84% scale)
        W = int(N * 0.84)
        bike_resized = bike_src.resize((W, W), Image.Resampling.LANCZOS)
        offset = (N - W) // 2
        
        # Since bike_resized is RGBA, we paste it using itself as the mask
        canvas.paste(bike_resized, (offset, offset), bike_resized)
        
    # Save the generated icon overwriting the destination file
    canvas.save(dest_path)
    print(f"  Successfully wrote {N}x{N} ({target_mode}) to {dest_path}")

def main():
    src_image = "bike.png"
    if not os.path.exists(src_image):
        print(f"Source file {src_image} not found!")
        return
        
    # Find all target icons
    targets = []
    
    # 1. Android main app icons
    targets.extend(glob.glob("fitlog_app/android/app/src/main/res/mipmap-*/ic_launcher.png"))
    # 2. Android location plugin example icons
    targets.extend(glob.glob("fitlog_app/plugins/location_plugin/example/android/app/src/main/res/mipmap-*/ic_launcher.png"))
    # 3. iOS app icons
    targets.extend(glob.glob("fitlog_app/ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png"))
    # 4. macOS app icons
    targets.extend(glob.glob("fitlog_app/macos/Runner/Assets.xcassets/AppIcon.appiconset/*.png"))
    # 5. Web icons
    targets.extend(glob.glob("fitlog_app/web/favicon.png"))
    targets.extend(glob.glob("fitlog_app/web/icons/*.png"))
    
    # De-duplicate list
    targets = sorted(list(set(targets)))
    
    print(f"Found {len(targets)} launcher icon files to update.")
    for t in targets:
        try:
            process_icon(src_image, t)
        except Exception as e:
            print(f"  Error processing {t}: {e}")

if __name__ == "__main__":
    main()
