import os
import subprocess
from PIL import Image, ImageDraw

# Output directory for component icon images
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, "..", ".."))
PACKAGE_DIR = os.path.join(REPO_ROOT, "package")
ICONS_DIR = os.path.join(PACKAGE_DIR, "icons")
os.makedirs(ICONS_DIR, exist_ok=True)

S = 4  # 4x super-sampling (canvas 96x96 for 24x24 final output)
CANVAS_SIZE = 24 * S  # 96

def new_canvas():
    img = Image.new("RGBA", (CANVAS_SIZE, CANVAS_SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    return img, draw

def save_scaled(img, base_name):
    # Standard 100% (24x24)
    img_24 = img.resize((24, 24), Image.Resampling.LANCZOS)
    p24 = os.path.join(ICONS_DIR, f"{base_name}.png")
    img_24.save(p24, "PNG")

    # 150% HiDPI (36x36)
    img_36 = img.resize((36, 36), Image.Resampling.LANCZOS)
    p36 = os.path.join(ICONS_DIR, f"{base_name}_150.png")
    img_36.save(p36, "PNG")

    # 200% HiDPI (48x48)
    img_48 = img.resize((48, 48), Image.Resampling.LANCZOS)
    p48 = os.path.join(ICONS_DIR, f"{base_name}_200.png")
    img_48.save(p48, "PNG")
    
    return [p24, p36, p48]

# -----------------------------------------------------------------------------
# 1. TLazDroidAppBar (Top Mobile Navigation Bar)
# -----------------------------------------------------------------------------
def draw_app_bar():
    img, draw = new_canvas()
    # Phone screen background
    draw.rounded_rectangle([10, 10, 86, 86], radius=12, fill=(245, 247, 250, 255), outline=(176, 190, 197, 255), width=3)
    # Header App Bar
    draw.rounded_rectangle([10, 10, 86, 42], radius=10, fill=(21, 101, 192, 255))
    draw.rectangle([10, 26, 86, 42], fill=(21, 101, 192, 255)) # Square bottom of header
    # Back arrow chevron '<'
    draw.line([26, 26, 20, 26], fill=(255, 255, 255, 255), width=3)
    draw.line([20, 26, 25, 21], fill=(255, 255, 255, 255), width=3)
    draw.line([20, 26, 25, 31], fill=(255, 255, 255, 255), width=3)
    # Title bar line
    draw.rounded_rectangle([34, 23, 62, 29], radius=3, fill=(255, 255, 255, 255))
    # Action menu 3 dots
    draw.ellipse([73, 24, 77, 28], fill=(255, 255, 255, 255))
    # Body placeholder lines
    draw.rounded_rectangle([20, 52, 64, 58], radius=3, fill=(207, 216, 220, 255))
    draw.rounded_rectangle([20, 66, 76, 72], radius=3, fill=(207, 216, 220, 255))
    return save_scaled(img, "TLazDroidAppBar")

# -----------------------------------------------------------------------------
# 2. TLazDroidButton (Mobile Touch Button)
# -----------------------------------------------------------------------------
def draw_button():
    img, draw = new_canvas()
    # Drop shadow
    draw.rounded_rectangle([10, 26, 86, 74], radius=16, fill=(13, 71, 161, 80))
    # Button main body
    draw.rounded_rectangle([8, 22, 88, 70], radius=16, fill=(25, 118, 210, 255), outline=(66, 165, 245, 255), width=3)
    # Top subtle highlight
    draw.rounded_rectangle([14, 25, 82, 34], radius=5, fill=(255, 255, 255, 60))
    # Button center label pill / touch symbol
    draw.rounded_rectangle([24, 42, 72, 50], radius=4, fill=(255, 255, 255, 255))
    # Left icon dot
    draw.ellipse([30, 43, 36, 49], fill=(25, 118, 210, 255))
    return save_scaled(img, "TLazDroidButton")

# -----------------------------------------------------------------------------
# 3. TLazDroidEdit (Text Input Field)
# -----------------------------------------------------------------------------
def draw_edit():
    img, draw = new_canvas()
    # Input box container
    draw.rounded_rectangle([8, 22, 88, 74], radius=12, fill=(255, 255, 255, 255), outline=(25, 118, 210, 255), width=4)
    # Vertical cursor '|'
    draw.line([22, 34, 22, 62], fill=(25, 118, 210, 255), width=4)
    # Placeholder text simulation "Abc"
    # Letter 'A'
    draw.line([36, 60, 42, 36], fill=(55, 71, 79, 255), width=4)
    draw.line([42, 36, 48, 60], fill=(55, 71, 79, 255), width=4)
    draw.line([38, 50, 46, 50], fill=(55, 71, 79, 255), width=3)
    # Letter 'b'
    draw.line([56, 36, 56, 60], fill=(55, 71, 79, 255), width=4)
    draw.ellipse([56, 44, 70, 60], outline=(55, 71, 79, 255), width=3)
    # Small corner accent
    draw.ellipse([78, 62, 82, 66], fill=(0, 150, 136, 255))
    return save_scaled(img, "TLazDroidEdit")

# -----------------------------------------------------------------------------
# 4. TLazDroidCard (Material Elevated Card)
# -----------------------------------------------------------------------------
def draw_card():
    img, draw = new_canvas()
    # Drop shadow
    draw.rounded_rectangle([14, 16, 86, 88], radius=14, fill=(38, 50, 56, 70))
    # Card surface
    draw.rounded_rectangle([10, 12, 82, 84], radius=14, fill=(255, 255, 255, 255), outline=(207, 216, 220, 255), width=3)
    # Top banner / accent strip
    draw.rounded_rectangle([10, 12, 82, 34], radius=12, fill=(61, 220, 132, 255))
    draw.rectangle([10, 24, 82, 34], fill=(61, 220, 132, 255))
    # Inner card content lines
    draw.rounded_rectangle([20, 44, 60, 50], radius=3, fill=(38, 50, 56, 255))
    draw.rounded_rectangle([20, 58, 72, 64], radius=3, fill=(144, 164, 174, 255))
    draw.rounded_rectangle([20, 70, 50, 75], radius=2, fill=(176, 190, 197, 255))
    return save_scaled(img, "TLazDroidCard")

# -----------------------------------------------------------------------------
# 5. TLazDroidBadge (Status Pill / Chip)
# -----------------------------------------------------------------------------
def draw_badge():
    img, draw = new_canvas()
    # Drop shadow
    draw.rounded_rectangle([12, 28, 88, 72], radius=20, fill=(0, 0, 0, 50))
    # Oval pill
    draw.rounded_rectangle([10, 24, 86, 68], radius=22, fill=(255, 87, 34, 255), outline=(255, 138, 101, 255), width=3)
    # Left status indicator dot
    draw.ellipse([22, 38, 38, 54], fill=(255, 255, 255, 255))
    # Right count or status bars
    draw.rounded_rectangle([46, 40, 74, 46], radius=3, fill=(255, 255, 255, 255))
    draw.rounded_rectangle([46, 50, 64, 55], radius=2, fill=(255, 255, 255, 255))
    return save_scaled(img, "TLazDroidBadge")

# -----------------------------------------------------------------------------
# 6. TLazDroidSwitch (Toggle Switch ON)
# -----------------------------------------------------------------------------
def draw_switch():
    img, draw = new_canvas()
    # Track
    draw.rounded_rectangle([8, 24, 88, 72], radius=24, fill=(61, 220, 132, 255), outline=(46, 125, 50, 255), width=3)
    # Thumb Shadow
    draw.ellipse([46, 22, 90, 74], fill=(0, 0, 0, 40))
    # Thumb Knob (White circle on the right)
    draw.ellipse([48, 20, 88, 72], fill=(255, 255, 255, 255), outline=(224, 224, 224, 255), width=2)
    # Active check icon inside thumb
    draw.line([60, 46, 66, 54], fill=(46, 125, 50, 255), width=4)
    draw.line([66, 54, 76, 38], fill=(46, 125, 50, 255), width=4)
    return save_scaled(img, "TLazDroidSwitch")

# -----------------------------------------------------------------------------
# 7. TLazDroidActivityIndicator (Circular Spinner)
# -----------------------------------------------------------------------------
def draw_activity_indicator():
    img, draw = new_canvas()
    # Circular arc loader
    bbox = [14, 14, 82, 82]
    # Background faint track
    draw.arc(bbox, start=0, end=360, fill=(207, 216, 220, 120), width=10)
    # Active spinner arc (gradient simulated with segments)
    draw.arc(bbox, start=30, end=140, fill=(25, 118, 210, 255), width=10)
    draw.arc(bbox, start=140, end=260, fill=(0, 229, 255, 255), width=10)
    # Glowing tip
    draw.ellipse([42, 6, 54, 18], fill=(0, 229, 255, 255))
    return save_scaled(img, "TLazDroidActivityIndicator")

# -----------------------------------------------------------------------------
# 8. TLazDroidFAB (Floating Action Button)
# -----------------------------------------------------------------------------
def draw_fab():
    img, draw = new_canvas()
    # Drop shadow
    draw.ellipse([14, 16, 86, 88], fill=(0, 0, 0, 70))
    # FAB circle background (Material Indigo / Purple)
    draw.ellipse([10, 10, 86, 86], fill=(124, 77, 255, 255), outline=(179, 136, 255, 255), width=3)
    # Bold white plus '+'
    # Horizontal line
    draw.rounded_rectangle([28, 43, 68, 53], radius=4, fill=(255, 255, 255, 255))
    # Vertical line
    draw.rounded_rectangle([43, 28, 53, 68], radius=4, fill=(255, 255, 255, 255))
    return save_scaled(img, "TLazDroidFAB")

# -----------------------------------------------------------------------------
# 9. TLazDroidLayout (Flex / Grid Layout Container)
# -----------------------------------------------------------------------------
def draw_layout():
    img, draw = new_canvas()
    # Container boundary
    draw.rounded_rectangle([8, 8, 88, 88], radius=12, fill=(245, 247, 250, 255), outline=(96, 125, 139, 255), width=3)
    # Top block (Blue)
    draw.rounded_rectangle([16, 16, 80, 44], radius=6, fill=(2, 136, 209, 255))
    # Bottom Left block (Teal)
    draw.rounded_rectangle([16, 52, 44, 80], radius=6, fill=(0, 150, 136, 255))
    # Bottom Right block (Amber)
    draw.rounded_rectangle([52, 52, 80, 80], radius=6, fill=(255, 160, 0, 255))
    return save_scaled(img, "TLazDroidLayout")

# -----------------------------------------------------------------------------
# 10. TLazDroidBottomNav (Bottom Navigation Bar)
# -----------------------------------------------------------------------------
def draw_bottom_nav():
    img, draw = new_canvas()
    # Mobile screen frame
    draw.rounded_rectangle([10, 8, 86, 88], radius=12, fill=(250, 250, 250, 255), outline=(176, 190, 197, 255), width=3)
    # Content area simulation
    draw.rounded_rectangle([20, 20, 56, 26], radius=3, fill=(207, 216, 220, 255))
    draw.rounded_rectangle([20, 34, 76, 44], radius=4, fill=(224, 224, 224, 255))
    # Bottom Nav Bar
    draw.rounded_rectangle([10, 52, 86, 88], radius=10, fill=(30, 41, 59, 255))
    draw.rectangle([10, 52, 86, 68], fill=(30, 41, 59, 255))
    # Tab 1: Home icon (left)
    draw.polygon([(26, 64), (20, 70), (32, 70)], fill=(148, 163, 184, 255))
    draw.rectangle([22, 70, 30, 78], fill=(148, 163, 184, 255))
    # Tab 2: Active Center Tab (Pill indicator + star/dot)
    draw.rounded_rectangle([40, 60, 56, 80], radius=8, fill=(37, 99, 235, 255))
    draw.ellipse([45, 67, 51, 73], fill=(255, 255, 255, 255))
    # Tab 3: Profile/Settings (right)
    draw.ellipse([67, 64, 73, 70], fill=(148, 163, 184, 255))
    draw.arc([65, 72, 75, 82], start=180, end=360, fill=(148, 163, 184, 255), width=3)
    return save_scaled(img, "TLazDroidBottomNav")

# -----------------------------------------------------------------------------
# 11. TLazDroidListView (Card List View)
# -----------------------------------------------------------------------------
def draw_list_view():
    img, draw = new_canvas()
    # Row 1
    draw.rounded_rectangle([8, 10, 88, 32], radius=8, fill=(255, 255, 255, 255), outline=(186, 230, 253, 255), width=2)
    draw.ellipse([14, 14, 26, 26], fill=(2, 132, 199, 255))
    draw.rounded_rectangle([32, 15, 60, 20], radius=2, fill=(15, 23, 42, 255))
    draw.rounded_rectangle([32, 22, 76, 26], radius=2, fill=(148, 163, 184, 255))

    # Row 2
    draw.rounded_rectangle([8, 37, 88, 59], radius=8, fill=(255, 255, 255, 255), outline=(187, 247, 208, 255), width=2)
    draw.ellipse([14, 41, 26, 53], fill=(22, 163, 74, 255))
    draw.rounded_rectangle([32, 42, 64, 47], radius=2, fill=(15, 23, 42, 255))
    draw.rounded_rectangle([32, 49, 72, 53], radius=2, fill=(148, 163, 184, 255))

    # Row 3
    draw.rounded_rectangle([8, 64, 88, 86], radius=8, fill=(255, 255, 255, 255), outline=(254, 215, 170, 255), width=2)
    draw.ellipse([14, 68, 26, 80], fill=(234, 88, 12, 255))
    draw.rounded_rectangle([32, 69, 58, 74], radius=2, fill=(15, 23, 42, 255))
    draw.rounded_rectangle([32, 76, 68, 80], radius=2, fill=(148, 163, 184, 255))
    return save_scaled(img, "TLazDroidListView")

# -----------------------------------------------------------------------------
# Execution & lazres compilation
# -----------------------------------------------------------------------------
all_files = []
generators = [
    draw_app_bar,
    draw_button,
    draw_edit,
    draw_card,
    draw_badge,
    draw_switch,
    draw_activity_indicator,
    draw_fab,
    draw_layout,
    draw_bottom_nav,
    draw_list_view
]

print("Generating 24x24, 36x36 (_150) and 48x48 (_200) component icons...")
for gen in generators:
    files = gen()
    all_files.extend(files)

print(f"Total icons generated: {len(all_files)}")

# Compile with lazres into package/LazDroidControls.lrs
lazres_exe = r"C:\lazarus\tools\lazres.exe"
lrs_file = os.path.join(PACKAGE_DIR, "LazDroidControls.lrs")

if os.path.exists(lazres_exe):
    print(f"Compiling resource with lazres: {lrs_file}")
    # lazres takes list of files
    cmd = [lazres_exe, lrs_file] + [f for f in all_files if f.endswith(".png")]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode == 0:
        print("LazDroidControls.lrs created successfully!")
    else:
        print(f"lazres error: {res.stderr}")
else:
    print(f"lazres not found at {lazres_exe}")
