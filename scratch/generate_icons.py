import os
from PIL import Image, ImageDraw

ICONS_DIR = r"d:\Projetos AntiGravity\LazarusAndroid\package\icons"

PRIMARY = (14, 116, 217, 255)      # Vibrant Blue
ACCENT = (217, 119, 6, 255)        # Amber / Orange
DARK = (30, 41, 59, 255)           # Slate 800
LIGHT_BG = (241, 245, 249, 255)    # Slate 100
BORDER = (148, 163, 184, 255)      # Slate 400
WHITE = (255, 255, 255, 255)
STAR_GOLD = (245, 158, 11, 255)    # Amber 500

def draw_star(draw, center, r_outer, r_inner, fill, outline=None):
    import math
    cx, cy = center
    pts = []
    for i in range(10):
        angle = -math.pi / 2 + i * (math.pi / 5)
        r = r_outer if (i % 2 == 0) else r_inner
        pts.append((cx + r * math.cos(angle), cy + r * math.sin(angle)))
    draw.polygon(pts, fill=fill, outline=outline)

def make_date_picker(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size / 24.0
    
    # Body
    x0, y0, x1, y1 = 3 * s, 4 * s, 21 * s, 21 * s
    d.rounded_rectangle([x0, y0, x1, y1], radius=3 * s, fill=WHITE, outline=PRIMARY, width=max(1, int(1.5 * s)))
    
    # Header bar
    d.rounded_rectangle([x0, y0, x1, y0 + 6 * s], radius=2 * s, fill=PRIMARY)
    
    # Binder rings
    for rx in [7 * s, 17 * s]:
        d.rectangle([rx - 0.7 * s, y0 - 1.5 * s, rx + 0.7 * s, y0 + 1.5 * s], fill=DARK)
        
    # Grid dots (days)
    for row in range(2):
        for col in range(3):
            dx = 7 * s + col * 4.5 * s
            dy = 13 * s + row * 4 * s
            d.ellipse([dx - 1 * s, dy - 1 * s, dx + 1 * s, dy + 1 * s], fill=PRIMARY if (row == 0 and col == 1) else BORDER)
            
    return img

def make_time_picker(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size / 24.0
    
    cx, cy = 12 * s, 12 * s
    r = 9 * s
    # Outer circle
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=WHITE, outline=PRIMARY, width=max(1, int(1.8 * s)))
    # Inner center dot
    d.ellipse([cx - 1.2 * s, cy - 1.2 * s, cx + 1.2 * s, cy + 1.2 * s], fill=DARK)
    # Hour hand (pointing to 10)
    d.line([cx, cy, cx - 4 * s, cy - 3 * s], fill=DARK, width=max(1, int(1.8 * s)))
    # Minute hand (pointing to 2)
    d.line([cx, cy, cx + 5 * s, cy - 3.5 * s], fill=PRIMARY, width=max(1, int(1.4 * s)))
    # Top crown/button
    d.rectangle([cx - 1.5 * s, 1.5 * s, cx + 1.5 * s, 3.5 * s], fill=BORDER)
    return img

def make_progress_bar(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size / 24.0
    
    # Progress track
    x0, y0, x1, y1 = 2 * s, 9 * s, 22 * s, 15 * s
    d.rounded_rectangle([x0, y0, x1, y1], radius=3 * s, fill=LIGHT_BG, outline=BORDER, width=max(1, int(1 * s)))
    # Filled progress (65%)
    fill_w = (x1 - x0) * 0.65
    d.rounded_rectangle([x0, y0, x0 + fill_w, y1], radius=3 * s, fill=PRIMARY)
    # Small shine dot
    d.ellipse([x0 + 3 * s, y0 + 1.5 * s, x0 + 5 * s, y0 + 3.5 * s], fill=(255, 255, 255, 180))
    return img

def make_slider(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size / 24.0
    
    y = 12 * s
    # Inactive track
    d.line([3 * s, y, 21 * s, y], fill=BORDER, width=max(1, int(2.5 * s)))
    # Active track up to thumb (around 14*s)
    thumb_x = 13.5 * s
    d.line([3 * s, y, thumb_x, y], fill=PRIMARY, width=max(1, int(2.5 * s)))
    # Thumb
    tr = 4 * s
    d.ellipse([thumb_x - tr, y - tr, thumb_x + tr, y + tr], fill=WHITE, outline=PRIMARY, width=max(1, int(2 * s)))
    d.ellipse([thumb_x - 1.5 * s, y - 1.5 * s, thumb_x + 1.5 * s, y + 1.5 * s], fill=PRIMARY)
    return img

def make_segmented_control(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size / 24.0
    
    # Outer frame
    x0, y0, x1, y1 = 2 * s, 7 * s, 22 * s, 17 * s
    d.rounded_rectangle([x0, y0, x1, y1], radius=4 * s, fill=LIGHT_BG, outline=BORDER, width=max(1, int(1 * s)))
    # Active segment (middle segment)
    seg_w = (x1 - x0) / 3.0
    ax0 = x0 + seg_w + 1 * s
    ax1 = x0 + 2 * seg_w - 1 * s
    d.rounded_rectangle([ax0, y0 + 1.5 * s, ax1, y1 - 1.5 * s], radius=3 * s, fill=PRIMARY)
    # Segment dividers
    d.line([x0 + seg_w, y0 + 2 * s, x0 + seg_w, y1 - 2 * s], fill=BORDER, width=1)
    d.line([x0 + 2 * seg_w, y0 + 2 * s, x0 + 2 * seg_w, y1 - 2 * s], fill=BORDER, width=1)
    return img

def make_checkbox(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size / 24.0
    
    # Box
    x0, y0, x1, y1 = 3 * s, 3 * s, 21 * s, 21 * s
    d.rounded_rectangle([x0, y0, x1, y1], radius=4 * s, fill=PRIMARY)
    # Checkmark in white
    chk_pts = [(7 * s, 12 * s), (10.5 * s, 15.5 * s), (17 * s, 8 * s)]
    d.line([chk_pts[0], chk_pts[1]], fill=WHITE, width=max(1, int(2.5 * s)))
    d.line([chk_pts[1], chk_pts[2]], fill=WHITE, width=max(1, int(2.5 * s)))
    return img

def make_rating_bar(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size / 24.0
    
    # 3 Stars in a row
    star_r_out = 3.5 * s
    star_r_in = 1.6 * s
    for i, fill_col in enumerate([STAR_GOLD, STAR_GOLD, BORDER]):
        cx = 5 * s + i * 7 * s
        cy = 12 * s
        draw_star(d, (cx, cy), star_r_out, star_r_in, fill=fill_col, outline=STAR_GOLD if fill_col == STAR_GOLD else BORDER)
    return img

COMPONENTS = [
    ("TLazDroidDatePicker", make_date_picker),
    ("TLazDroidTimePicker", make_time_picker),
    ("TLazDroidProgressBar", make_progress_bar),
    ("TLazDroidSlider", make_slider),
    ("TLazDroidSegmentedControl", make_segmented_control),
    ("TLazDroidCheckBox", make_checkbox),
    ("TLazDroidRatingBar", make_rating_bar),
]

for name, func in COMPONENTS:
    # 24x24 (standard)
    im24 = func(24)
    im24.save(os.path.join(ICONS_DIR, f"{name}.png"))
    
    # 36x36 (150%)
    im36 = func(36)
    im36.save(os.path.join(ICONS_DIR, f"{name}_150.png"))
    
    # 48x48 (200%)
    im48 = func(48)
    im48.save(os.path.join(ICONS_DIR, f"{name}_200.png"))

print(f"Generated icons for {len(COMPONENTS)} components successfully in {ICONS_DIR}")
