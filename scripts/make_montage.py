
import os as _export_os
import pathlib as _export_pathlib
from pathlib import Path
from PIL import Image, ImageDraw

files = sorted(Path(str(_export_pathlib.Path(_export_os.environ.get('R2D2_WORKSPACE', str(_export_pathlib.Path(__file__).resolve().parents[1]))) / 'Downloads')).glob('*.jpg'))
W, H, cols = 320, 240, 3
rows = (len(files) + cols - 1) // cols
out = Image.new('RGB', (cols * W, rows * H), 'white')
draw = ImageDraw.Draw(out)
for i, f in enumerate(files):
    im = Image.open(f).convert('RGB')
    im.thumbnail((W - 10, H - 40))
    x = (i % cols) * W + (W - im.width) // 2
    y = (i // cols) * H + 5
    out.paste(im, (x, y))
    draw.text(((i % cols) * W + 5, (i // cols) * H + H - 28), f.name, fill='black')
out.save('/tmp/screener_montage.jpg', quality=90)
