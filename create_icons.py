#!/usr/bin/env python3
import base64
import json
from pathlib import Path

from PIL import Image
from PIL import ImageDraw


ROOT = Path(__file__).resolve().parent
SOURCE_PNG = ROOT / 'FacturioIcon.png'
ASSETS_DIR = ROOT / 'assets' / 'icons'
WEB_DIR = ROOT / 'web'
ANDROID_RES_DIR = ROOT / 'android' / 'app' / 'src' / 'main' / 'res'
IOS_ASSETS_DIR = ROOT / 'ios' / 'Runner' / 'Assets.xcassets'

ANDROID_ICON_SIZES = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}

IOS_ICON_SPECS = [
    ('iphone', '60x60', '2x', 120),
    ('iphone', '60x60', '3x', 180),
    ('ipad', '76x76', '2x', 152),
    ('ipad', '83.5x83.5', '2x', 167),
]


def scale(value: float, size: int) -> int:
    return int(round(value * size / 1024))


def new_canvas(color: str, size: int = 1024) -> Image.Image:
    image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle((0, 0, size, size), radius=scale(224, size), fill=color)
    return image


def draw_calculator(size: int = 1024) -> Image.Image:
    image = new_canvas('#388E3C', size)
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle((scale(264, size), scale(176, size), scale(760, size), scale(848, size)), radius=scale(92, size), fill='white')
    draw.rounded_rectangle((scale(332, size), scale(256, size), scale(692, size), scale(376, size)), radius=scale(28, size), fill='#D9F0DA')
    for row in range(2):
        for col in range(3):
            left = 332 + col * 128
            top = 448 + row * 128
            if row == 1 and col == 2:
                continue
            draw.rounded_rectangle((scale(left, size), scale(top, size), scale(left + 104, size), scale(top + 104, size)), radius=scale(24, size), fill='#388E3C')
    draw.rounded_rectangle((scale(588, size), scale(576, size), scale(692, size), scale(808, size)), radius=scale(24, size), fill='#388E3C')
    draw.rounded_rectangle((scale(332, size), scale(704, size), scale(564, size), scale(808, size)), radius=scale(24, size), fill='#388E3C')
    return image


def draw_money(size: int = 1024) -> Image.Image:
    image = new_canvas('#F57C00', size)
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle((scale(176, size), scale(272, size), scale(848, size), scale(752, size)), radius=scale(88, size), fill='white')
    draw.rounded_rectangle((scale(224, size), scale(320, size), scale(800, size), scale(704, size)), radius=scale(64, size), fill='#FFE0B2')
    draw.ellipse((scale(380, size), scale(380, size), scale(644, size), scale(644, size)), fill='#F57C00')
    draw.rounded_rectangle((scale(320, size), scale(384, size), scale(416, size), scale(432, size)), radius=scale(24, size), fill='#F57C00')
    draw.rounded_rectangle((scale(608, size), scale(592, size), scale(704, size), scale(640, size)), radius=scale(24, size), fill='#F57C00')
    draw.text((scale(468, size), scale(402, size)), '$', fill='white')
    return image


def draw_documents(size: int = 1024) -> Image.Image:
    image = new_canvas('#7B1FA2', size)
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle((scale(304, size), scale(168, size), scale(704, size), scale(856, size)), radius=scale(64, size), fill='white')
    draw.polygon([
        (scale(616, size), scale(168, size)),
        (scale(704, size), scale(256, size)),
        (scale(704, size), scale(372, size)),
        (scale(656, size), scale(372, size)),
        (scale(616, size), scale(332, size)),
    ], fill='#CE93D8')
    for top, width in [(396, 256), (484, 256), (572, 192), (660, 224)]:
        draw.rounded_rectangle((scale(384, size), scale(top, size), scale(384 + width, size), scale(top + 36, size)), radius=scale(18, size), fill='#7B1FA2')
    return image


def draw_chart(size: int = 1024) -> Image.Image:
    image = new_canvas('#0097A7', size)
    draw = ImageDraw.Draw(image)
    draw.line((scale(240, size), scale(760, size), scale(784, size), scale(760, size)), fill='white', width=scale(48, size))
    for left, top, height in [(292, 512, 200), (464, 408, 304), (636, 308, 404)]:
        draw.rounded_rectangle((scale(left, size), scale(top, size), scale(left + 96, size), scale(top + height, size)), radius=scale(28, size), fill='white')
    draw.line([
        (scale(300, size), scale(420, size)),
        (scale(454, size), scale(304, size)),
        (scale(580, size), scale(374, size)),
        (scale(738, size), scale(224, size)),
    ], fill='#B2EBF2', width=scale(44, size), joint='curve')
    draw.line((scale(658, size), scale(228, size), scale(786, size), scale(228, size)), fill='#B2EBF2', width=scale(44, size))
    draw.line((scale(786, size), scale(228, size), scale(786, size), scale(356, size)), fill='#B2EBF2', width=scale(44, size))
    return image


def draw_business(size: int = 1024) -> Image.Image:
    image = new_canvas('#303F9F', size)
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle((scale(208, size), scale(324, size), scale(816, size), scale(744, size)), radius=scale(72, size), fill='white')
    draw.rounded_rectangle((scale(380, size), scale(224, size), scale(644, size), scale(336, size)), radius=scale(40, size), fill='#C5CAE9')
    draw.rounded_rectangle((scale(436, size), scale(268, size), scale(588, size), scale(312, size)), radius=scale(20, size), fill='#303F9F')
    draw.rectangle((scale(208, size), scale(452, size), scale(816, size), scale(560, size)), fill='#C5CAE9')
    draw.rounded_rectangle((scale(476, size), scale(420, size), scale(548, size), scale(592, size)), radius=scale(24, size), fill='#303F9F')
    draw.rounded_rectangle((scale(336, size), scale(520, size), scale(472, size), scale(624, size)), radius=scale(24, size), fill='white')
    draw.rounded_rectangle((scale(552, size), scale(520, size), scale(688, size), scale(624, size)), radius=scale(24, size), fill='white')
    return image


ICON_GENERATORS = {
    'calculator': draw_calculator,
    'money': draw_money,
    'documents': draw_documents,
    'chart': draw_chart,
    'business': draw_business,
}


IOS_SET_NAMES = {
    'calculator': 'AppIconCalculator',
    'money': 'AppIconMoney',
    'documents': 'AppIconDocuments',
    'chart': 'AppIconChart',
    'business': 'AppIconBusiness',
}


def write_svg_from_png(source_png: Path, output_svg: Path) -> None:
    encoded = base64.b64encode(source_png.read_bytes()).decode('ascii')
    svg = f'''<?xml version="1.0" encoding="utf-8"?>
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="1024" height="1024" viewBox="0 0 1024 1024">
  <image width="1024" height="1024" xlink:href="data:image/png;base64,{encoded}"/>
</svg>
'''
    output_svg.write_text(svg, encoding='utf-8')


def generate_png_sizes(source_png: Path, output_dir: Path) -> None:
    sizes = [16, 32, 48, 64, 128, 192, 256, 512]
    image = Image.open(source_png).convert('RGBA')

    for size in sizes:
        resized = image.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(output_dir / f'icon-{size}.png')
        print(f'Criado icon-{size}.png')


def generate_android_icons(images: dict[str, Image.Image]) -> None:
    for key, image in images.items():
        resource_name = f'ic_launcher_{key}'
        for folder, size in ANDROID_ICON_SIZES.items():
            destination = ANDROID_RES_DIR / folder / f'{resource_name}.png'
            image.resize((size, size), Image.Resampling.LANCZOS).save(destination)
            print(f'Criado {destination.relative_to(ROOT)}')


def generate_android_primary_icon(source_png: Path) -> None:
    image = Image.open(source_png).convert('RGBA')

    for folder, size in ANDROID_ICON_SIZES.items():
        destination = ANDROID_RES_DIR / folder / 'ic_launcher.png'
        image.resize((size, size), Image.Resampling.LANCZOS).save(destination)
        print(f'Atualizado {destination.relative_to(ROOT)}')

    drawable_legacy = [
        ANDROID_RES_DIR / 'drawable' / 'ic_launcher.png',
        ANDROID_RES_DIR / 'drawable-v21' / 'ic_launcher.png',
    ]
    for destination in drawable_legacy:
        image.resize((128, 128), Image.Resampling.LANCZOS).save(destination)
        print(f'Atualizado {destination.relative_to(ROOT)}')


def write_ios_contents_json(app_icon_set: Path, icon_name: str) -> None:
    contents = {
        'images': [
            {
                'idiom': idiom,
                'size': size,
                'scale': scale_value,
                'filename': f'{icon_name}-{size}@{scale_value}.png',
            }
            for idiom, size, scale_value, _ in IOS_ICON_SPECS
        ],
        'info': {
            'version': 1,
            'author': 'xcode',
        },
    }
    (app_icon_set / 'Contents.json').write_text(json.dumps(contents, indent=2), encoding='utf-8')


def generate_ios_icons(images: dict[str, Image.Image]) -> None:
    for key, image in images.items():
        icon_name = IOS_SET_NAMES[key]
        app_icon_set = IOS_ASSETS_DIR / f'{icon_name}.appiconset'
        app_icon_set.mkdir(parents=True, exist_ok=True)
        write_ios_contents_json(app_icon_set, icon_name)

        for _, size_name, scale_value, pixels in IOS_ICON_SPECS:
            filename = f'{icon_name}-{size_name}@{scale_value}.png'
            destination = app_icon_set / filename
            image.resize((pixels, pixels), Image.Resampling.LANCZOS).save(destination)
            print(f'Criado {destination.relative_to(ROOT)}')


def main() -> None:
    if not SOURCE_PNG.exists():
        raise FileNotFoundError(f'Fonte do ícone não encontrada: {SOURCE_PNG}')

    ASSETS_DIR.mkdir(parents=True, exist_ok=True)
    WEB_DIR.mkdir(parents=True, exist_ok=True)

    write_svg_from_png(SOURCE_PNG, ASSETS_DIR / 'app_icon.svg')
    print('Criado app_icon.svg')

    generate_png_sizes(SOURCE_PNG, ASSETS_DIR)

    generated_images = {
        key: generator()
        for key, generator in ICON_GENERATORS.items()
    }

    generate_android_primary_icon(SOURCE_PNG)
    generate_android_icons(generated_images)
    generate_ios_icons(generated_images)

    favicon = Image.open(SOURCE_PNG).convert('RGBA').resize((32, 32), Image.Resampling.LANCZOS)
    favicon.save(WEB_DIR / 'favicon.png')
    print('Criado favicon.png')

    print('Todos os ícones foram criados com sucesso a partir de FacturioIcon.png!')


if __name__ == '__main__':
    main()
