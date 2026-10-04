import os, math
from PIL import Image, ImageDraw

ICONS_DIR = r"d:\Projetos AntiGravity\LazarusAndroid\package\icons"

PRIMARY = (14, 116, 217, 255)      # Vibrant Blue
ACCENT = (217, 119, 6, 255)        # Amber / Orange
DARK = (30, 41, 59, 255)           # Slate 800
LIGHT_BG = (241, 245, 249, 255)    # Slate 100
BORDER = (148, 163, 184, 255)      # Slate 400
WHITE = (255, 255, 255, 255)
GREEN = (34, 197, 94, 255)         # Green 500

def make_search_bar(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size / 24.0
    # Pill box
    d.rounded_rectangle([2*s, 6*s, 22*s, 18*s], radius=6*s, fill=WHITE, outline=PRIMARY, width=max(1, int(1.5*s)))
    # Magnifier
    cx, cy = 7.5*s, 12*s
    r = 2.5*s
    d.ellipse([cx-r, cy-r, cx+r, cy+r], outline=PRIMARY, width=max(1, int(1.5*s)))
    d.line([cx+1.8*s, cy+1.8*s, cx+3.8*s, cy+3.8*s], fill=PRIMARY, width=max(1, int(1.5*s)))
    # Placeholder line
    d.line([13*s, 12*s, 19*s, 12*s], fill=BORDER, width=max(1, int(1.5*s)))
    return img

def make_chip_group(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size / 24.0
    # Chip 1 (active)
    d.rounded_rectangle([2*s, 4*s, 14*s, 12*s], radius=4*s, fill=PRIMARY)
    # Check mark
    d.line([5*s, 8*s, 6.5*s, 9.5*s, 10*s, 6*s], fill=WHITE, width=max(1, int(1.2*s)))
    # Chip 2 (inactive)
    d.rounded_rectangle([10*s, 14*s, 22*s, 21*s], radius=3.5*s, fill=LIGHT_BG, outline=BORDER, width=1)
    d.line([14*s, 17.5*s, 19*s, 17.5*s], fill=DARK, width=max(1, int(1.2*s)))
    return img

def make_radio_group(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size / 24.0
    # Radio 1 (checked)
    d.ellipse([3*s, 4*s, 10*s, 11*s], fill=WHITE, outline=PRIMARY, width=max(1, int(1.5*s)))
    d.ellipse([5*s, 6*s, 8*s, 9*s], fill=PRIMARY)
    d.line([12*s, 7.5*s, 21*s, 7.5*s], fill=DARK, width=max(1, int(1.5*s)))
    # Radio 2 (unchecked)
    d.ellipse([3*s, 14*s, 10*s, 21*s], fill=WHITE, outline=BORDER, width=max(1, int(1.5*s)))
    d.line([12*s, 17.5*s, 19*s, 17.5*s], fill=BORDER, width=max(1, int(1.5*s)))
    return img

def make_otp_box(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size / 24.0
    # 4 squares
    for i in range(4):
        x = 2*s + i * 5.2*s
        fill_col = PRIMARY if i < 2 else BORDER
        d.rounded_rectangle([x, 7*s, x + 4.2*s, 17*s], radius=2*s, outline=fill_col, width=max(1, int(1.2*s)), fill=WHITE)
        if i < 2:
            d.ellipse([x + 1.6*s, 11*s, x + 2.6*s, 13*s], fill=DARK)
    return img

def make_signature_pad(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size / 24.0
    # Pad area
    d.rounded_rectangle([2*s, 3*s, 22*s, 21*s], radius=3*s, fill=WHITE, outline=BORDER, width=1)
    # Baseline
    d.line([4*s, 17*s, 20*s, 17*s], fill=BORDER, width=1)
    # Signature line
    pts = [(5*s, 16*s), (7*s, 10*s), (10*s, 15*s), (12*s, 8*s), (15*s, 14*s), (19*s, 11*s)]
    for i in range(len(pts)-1):
        d.line([pts[i], pts[i+1]], fill=PRIMARY, width=max(1, int(1.5*s)))
    # Pen icon top right
    d.line([17*s, 5*s, 20*s, 2*s], fill=ACCENT, width=max(1, int(1.5*s)))
    return img

def make_keypad(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size / 24.0
    # Phone/POS Keypad grid
    d.rounded_rectangle([3*s, 2*s, 21*s, 22*s], radius=3*s, fill=LIGHT_BG, outline=BORDER, width=1)
    for r in range(3):
        for c in range(3):
            kx = 5*s + c * 5.2*s
            ky = 4*s + r * 4.8*s
            d.rounded_rectangle([kx, ky, kx + 3.8*s, ky + 3.6*s], radius=1*s, fill=WHITE)
    # Bottom action bar
    d.rounded_rectangle([5*s, 18.5*s, 19*s, 21*s], radius=1*s, fill=PRIMARY)
    return img

def make_metric_card(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size / 24.0
    # Card
    d.rounded_rectangle([2*s, 4*s, 22*s, 20*s], radius=3*s, fill=WHITE, outline=BORDER, width=1)
    # Header label
    d.line([5*s, 7*s, 11*s, 7*s], fill=BORDER, width=max(1, int(1.2*s)))
    # Big value line
    d.line([5*s, 11*s, 15*s, 11*s], fill=DARK, width=max(1, int(2*s)))
    # Trend pill with green up arrow
    d.rounded_rectangle([5*s, 14*s, 13*s, 18*s], radius=2*s, fill=GREEN)
    d.line([7*s, 16.5*s, 9*s, 15*s, 11*s, 16.5*s], fill=WHITE, width=1)
    # Icon circle top-right
    d.ellipse([16*s, 6*s, 20*s, 10*s], fill=PRIMARY)
    return img

def make_bottom_sheet(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size / 24.0
    # Screen frame
    d.rectangle([3*s, 2*s, 21*s, 22*s], outline=BORDER, width=1)
    # Translucent backdrop
    d.rectangle([4*s, 3*s, 20*s, 10*s], fill=(30, 41, 59, 100))
    # Sheet coming up from bottom
    d.rounded_rectangle([3*s, 10*s, 21*s, 22*s], radius=3*s, fill=WHITE, outline=PRIMARY, width=max(1, int(1.2*s)))
    # Handle bar
    d.line([10*s, 12*s, 14*s, 12*s], fill=BORDER, width=max(1, int(1.5*s)))
    # Sheet content lines
    d.line([6*s, 15*s, 18*s, 15*s], fill=DARK, width=1)
    d.line([6*s, 18*s, 15*s, 18*s], fill=BORDER, width=1)
    return img

def make_speed_dial(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size / 24.0
    # Main FAB
    d.ellipse([13*s, 13*s, 22*s, 22*s], fill=PRIMARY)
    # Close X in main FAB
    d.line([16*s, 16*s, 19*s, 19*s], fill=WHITE, width=max(1, int(1.5*s)))
    d.line([19*s, 16*s, 16*s, 19*s], fill=WHITE, width=max(1, int(1.5*s)))
    # Mini FAB 1 above
    d.ellipse([14.5*s, 6.5*s, 20.5*s, 12.5*s], fill=ACCENT)
    d.line([17.5*s, 8.5*s, 17.5*s, 10.5*s], fill=WHITE, width=1)
    d.line([16.5*s, 9.5*s, 18.5*s, 9.5*s], fill=WHITE, width=1)
    # Mini Label pill
    d.rounded_rectangle([4*s, 7.5*s, 13*s, 11.5*s], radius=2*s, fill=LIGHT_BG, outline=BORDER, width=1)
    return img

def make_section_header(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size / 24.0
    # Text block
    d.rectangle([2*s, 10*s, 10*s, 14*s], fill=DARK)
    # Separator line extending across
    d.line([12*s, 12*s, 22*s, 12*s], fill=BORDER, width=max(1, int(1.5*s)))
    # Small top indicator
    d.line([2*s, 5*s, 6*s, 5*s], fill=BORDER, width=1)
    return img

def make_avatar(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size / 24.0
    # Avatar Circle
    cx, cy = 11*s, 11*s
    r = 8.5*s
    d.ellipse([cx-r, cy-r, cx+r, cy+r], fill=PRIMARY)
    # Head & Shoulder silhouette
    d.ellipse([cx-3*s, cy-5*s, cx+3*s, cy+1*s], fill=WHITE)
    d.pieslice([cx-6*s, cy-1*s, cx+6*s, cy+9*s], start=190, end=350, fill=WHITE)
    # Status green badge (bottom right)
    d.ellipse([15*s, 15*s, 21*s, 21*s], fill=WHITE)
    d.ellipse([16*s, 16*s, 20*s, 20*s], fill=GREEN)
    return img

COMPONENTS = [
    ("TLazDroidSearchBar", make_search_bar),
    ("TLazDroidChipGroup", make_chip_group),
    ("TLazDroidRadioGroup", make_radio_group),
    ("TLazDroidOtpBox", make_otp_box),
    ("TLazDroidSignaturePad", make_signature_pad),
    ("TLazDroidKeypad", make_keypad),
    ("TLazDroidMetricCard", make_metric_card),
    ("TLazDroidBottomSheet", make_bottom_sheet),
    ("TLazDroidSpeedDial", make_speed_dial),
    ("TLazDroidSectionHeader", make_section_header),
    ("TLazDroidAvatar", make_avatar),
]

for name, func in COMPONENTS:
    im24 = func(24)
    im24.save(os.path.join(ICONS_DIR, f"{name}.png"))
    im36 = func(36)
    im36.save(os.path.join(ICONS_DIR, f"{name}_150.png"))
    im48 = func(48)
    im48.save(os.path.join(ICONS_DIR, f"{name}_200.png"))

print(f"Generated icons for {len(COMPONENTS)} additional components successfully in {ICONS_DIR}")
