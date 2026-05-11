from __future__ import annotations

import math
import re
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
CONFIG_ROOT = ROOT / "res" / "config" / "street"
TEXTURE_ROOT = ROOT / "res" / "textures" / "ui" / "streets"

FONT_CANDIDATES = [
	"/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
	"/usr/share/fonts/dejavu/DejaVuSans-Bold.ttf",
]

ERA_COLORS = {
	"old": "#8C6239",
	"mid": "#2E8B8B",
	"new": "#355CBE",
}

PALETTES = {
	"urban": {
		"bg": "#EDF3FF",
		"road": "#667085",
		"road_edge": "#4B5563",
		"accent": "#2563EB",
		"text": "#17325F",
		"marker": "#FFFFFF",
		"side": "#D8E4FF",
	},
	"country": {
		"bg": "#EEF8EC",
		"road": "#71777A",
		"road_edge": "#58615E",
		"accent": "#2F855A",
		"text": "#1E4B34",
		"marker": "#FDFEFD",
		"side": "#D9EFD6",
	},
	"highway": {
		"bg": "#FFF2E8",
		"road": "#5F6673",
		"road_edge": "#464C57",
		"accent": "#E67E22",
		"text": "#6B3A0E",
		"marker": "#FFFFFF",
		"side": "#FFE0C8",
	},
	"depot": {
		"bg": "#F3EEFF",
		"road": "#6B7280",
		"road_edge": "#4B5563",
		"accent": "#7C3AED",
		"text": "#43206A",
		"marker": "#FFFFFF",
		"side": "#E7DFFF",
	},
}

WIDTH_SCALE = {
	"small": 16,
	"medium": 22,
	"large": 28,
	"x_large": 34,
}


def read_text(path: Path) -> str:
	return path.read_text(encoding="utf-8")


def rx(pattern: str, text: str, default: str = "") -> str:
	match = re.search(pattern, text, re.MULTILINE)
	return match.group(1) if match else default


def count_forward_lanes(text: str) -> int:
	count = len(re.findall(r"\{\s*forward\s*=\s*true\s*\}", text))
	if count:
		return count
	num_lanes = rx(r"\bnumLanes\s*=\s*([0-9.]+)", text)
	return int(float(num_lanes)) if num_lanes else 2


def load_font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
	for candidate in FONT_CANDIDATES:
		path = Path(candidate)
		if path.exists():
			return ImageFont.truetype(str(path), size)
	return ImageFont.load_default()


def text_size(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.ImageFont) -> tuple[int, int]:
	bbox = draw.textbbox((0, 0), text, font=font)
	return bbox[2] - bbox[0], bbox[3] - bbox[1]


def rounded_rect(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], radius: int, fill: str, outline: str | None = None, width: int = 1) -> None:
	draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def category_kind(category: str, scope: str) -> str:
	if scope == "street_depot":
		return "depot"
	if category == "highway":
		return "highway"
	if category == "country":
		return "country"
	return "urban"


def era_label(name: str) -> str:
	if "_old" in name:
		return "OLD"
	if "_mid" in name:
		return "MID"
	return "NEW"


def width_label(name: str) -> str:
	for token in ("x_large", "large", "medium", "small"):
		if token in name:
			return token
	return "medium"


def draw_category_glyph(draw: ImageDraw.ImageDraw, kind: str, x: int, y: int, scale: int, color: str) -> None:
	if kind == "urban":
		w = 4 * scale
		gap = 2 * scale
		heights = [8 * scale, 12 * scale, 6 * scale]
		for index, height in enumerate(heights):
			left = x + index * (w + gap)
			draw.rectangle((left, y + 14 * scale - height, left + w, y + 14 * scale), fill=color)
	elif kind == "country":
		draw.polygon([(x + 5 * scale, y), (x, y + 10 * scale), (x + 10 * scale, y + 10 * scale)], fill=color)
		draw.rectangle((x + 4 * scale, y + 10 * scale, x + 6 * scale, y + 14 * scale), fill=color)
		draw.ellipse((x + 12 * scale, y + 2 * scale, x + 22 * scale, y + 12 * scale), fill=color)
		draw.rectangle((x + 16 * scale, y + 11 * scale, x + 18 * scale, y + 15 * scale), fill=color)
	elif kind == "highway":
		arrow = [(x, y + 8 * scale), (x + 9 * scale, y), (x + 9 * scale, y + 5 * scale), (x + 18 * scale, y + 5 * scale), (x + 18 * scale, y + 11 * scale), (x + 9 * scale, y + 11 * scale), (x + 9 * scale, y + 16 * scale)]
		draw.polygon(arrow, fill=color)
	else:
		draw.rectangle((x, y + 4 * scale, x + 7 * scale, y + 16 * scale), fill=color)
		draw.rectangle((x + 10 * scale, y + 4 * scale, x + 22 * scale, y + 16 * scale), outline=color, width=max(1, scale))
		draw.line((x + 13 * scale, y + 16 * scale, x + 13 * scale, y + 20 * scale), fill=color, width=max(1, scale))
		draw.line((x + 19 * scale, y + 16 * scale, x + 19 * scale, y + 20 * scale), fill=color, width=max(1, scale))


def draw_arrows(draw: ImageDraw.ImageDraw, bounds: tuple[int, int, int, int], color: str, scale: int) -> None:
	left, top, right, bottom = bounds
	center_y = (top + bottom) // 2
	for x in range(left + 14 * scale, right - 12 * scale, 16 * scale):
		draw.line((x - 7 * scale, center_y, x + 4 * scale, center_y), fill=color, width=max(1, scale))
		draw.polygon([(x + 4 * scale, center_y), (x - 1 * scale, center_y - 4 * scale), (x - 1 * scale, center_y + 4 * scale)], fill=color)


def draw_lane_markers(draw: ImageDraw.ImageDraw, bounds: tuple[int, int, int, int], lanes: int, flow: str, marker_color: str, accent: str, scale: int) -> None:
	left, top, right, bottom = bounds
	width = right - left
	height = bottom - top
	center_y = (top + bottom) // 2
	if flow == "one_way":
		draw_arrows(draw, bounds, marker_color, scale)
		return

	if lanes <= 2:
		for dash_x in range(left + 10 * scale, right - 8 * scale, 12 * scale):
			draw.line((dash_x, center_y, dash_x + 6 * scale, center_y), fill=accent, width=max(1, scale))
		return

	separator_count = max(1, lanes - 1)
	for index in range(1, separator_count + 1):
		y = top + height * index / (separator_count + 1)
		color = accent if index == math.ceil(separator_count / 2) else marker_color
		for dash_x in range(left + 10 * scale, right - 8 * scale, 12 * scale):
			draw.line((dash_x, y, dash_x + 6 * scale, y), fill=color, width=max(1, scale))


def build_icon(meta: dict[str, str | int], size: tuple[int, int]) -> Image.Image:
	width, height = size
	scale = width // 120
	image = Image.new("RGBA", size, (0, 0, 0, 0))
	draw = ImageDraw.Draw(image)
	kind = meta["kind"]
	palette = PALETTES[kind]
	card = (4 * scale, 4 * scale, width - 4 * scale, height - 4 * scale)
	rounded_rect(draw, card, 12 * scale, palette["bg"], outline=palette["side"], width=max(1, scale))

	road_h = WIDTH_SCALE[meta["width_class"]] * scale
	road = (12 * scale, height // 2 - road_h // 2, width - 12 * scale, height // 2 + road_h // 2)

	if kind in {"urban", "depot"}:
		upper_side = (road[0], road[1] - 5 * scale, road[2], road[1])
		lower_side = (road[0], road[3], road[2], road[3] + 5 * scale)
		rounded_rect(draw, upper_side, 4 * scale, palette["side"])
		rounded_rect(draw, lower_side, 4 * scale, palette["side"])
	elif kind == "country":
		draw.rectangle((road[0], road[1] - 4 * scale, road[2], road[1]), fill="#C9E7B9")
		draw.rectangle((road[0], road[3], road[2], road[3] + 4 * scale), fill="#C9E7B9")
	else:
		draw.rectangle((road[0], road[1] - 3 * scale, road[2], road[1]), fill=palette["side"])
		draw.rectangle((road[0], road[3], road[2], road[3] + 3 * scale), fill=palette["side"])

	rounded_rect(draw, road, 8 * scale, palette["road"], outline=palette["road_edge"], width=max(1, scale))
	draw_lane_markers(draw, road, int(meta["lanes"]), meta["flow"], palette["marker"], palette["accent"], scale)

	era_chip = (8 * scale, 8 * scale, 34 * scale, 22 * scale)
	rounded_rect(draw, era_chip, 7 * scale, ERA_COLORS[meta["era"]])
	era_font = load_font(7 * scale if scale == 1 else 14)
	era_text = meta["era"].upper()
	tw, th = text_size(draw, era_text, era_font)
	draw.text((era_chip[0] + (era_chip[2] - era_chip[0] - tw) / 2, era_chip[1] + (era_chip[3] - era_chip[1] - th) / 2 - 1 * scale), era_text, fill="#FFFFFF", font=era_font)

	speed_font = load_font(9 * scale if scale == 1 else 18)
	badge_r = 12 * scale
	badge_center = (width - 16 * scale, 18 * scale)
	draw.ellipse((badge_center[0] - badge_r, badge_center[1] - badge_r, badge_center[0] + badge_r, badge_center[1] + badge_r), fill="#FFFFFF", outline=palette["accent"], width=max(2, scale))
	speed_text = str(meta["speed"])
	tw, th = text_size(draw, speed_text, speed_font)
	draw.text((badge_center[0] - tw / 2, badge_center[1] - th / 2 - 1 * scale), speed_text, fill=palette["text"], font=speed_font)

	label_font = load_font(7 * scale if scale == 1 else 14)
	label_text = meta["label"]
	label_w, label_h = text_size(draw, label_text, label_font)
	label_box = (8 * scale, height - 20 * scale, 16 * scale + label_w, height - 8 * scale)
	rounded_rect(draw, label_box, 6 * scale, palette["accent"])
	draw.text((label_box[0] + 4 * scale, label_box[1] + (label_box[3] - label_box[1] - label_h) / 2 - 1 * scale), label_text, fill="#FFFFFF", font=label_font)

	draw_category_glyph(draw, kind, 40 * scale, 10 * scale, scale, palette["accent"])

	if meta["scope"] == "street_depot":
		depot_font = load_font(6 * scale if scale == 1 else 12)
		depot_text = "DEPOT"
		dw, dh = text_size(draw, depot_text, depot_font)
		depot_box = (width - dw - 14 * scale, height - 20 * scale, width - 8 * scale, height - 8 * scale)
		rounded_rect(draw, depot_box, 5 * scale, palette["text"])
		draw.text((depot_box[0] + 3 * scale, depot_box[1] + (depot_box[3] - depot_box[1] - dh) / 2 - 1 * scale), depot_text, fill="#FFFFFF", font=depot_font)

	return image


def build_meta(config_path: Path) -> dict[str, str | int]:
	text = read_text(config_path)
	filename = config_path.stem
	category = rx(r"categories\s*=\s*\{\s*\"([^\"]+)\"", text, "urban")
	speed = int(float(rx(r"\bspeed\s*=\s*([0-9.]+)", text, "30")))
	flow = "one_way" if "laneConfig" in text else "two_way"
	lanes = count_forward_lanes(text)
	width_class = width_label(filename)
	era = "old" if "_old" in filename else "mid" if "_mid" in filename else "new"
	if category == "one-way":
		label = "URBAN"
	else:
		label = category.upper()
	kind = category_kind(category, config_path.parent.name)
	return {
		"category": category,
		"flow": flow,
		"kind": kind,
		"label": label,
		"lanes": lanes,
		"scope": config_path.parent.name,
		"speed": speed,
		"width_class": width_class,
		"era": era,
	}


def output_path(config_path: Path, suffix: str = "") -> Path:
	rel = config_path.relative_to(CONFIG_ROOT).with_suffix("")
	filename = rel.name + suffix + ".tga"
	return TEXTURE_ROOT / rel.parent / filename


def generate_for_config(config_path: Path) -> list[Path]:
	meta = build_meta(config_path)
	outputs = []
	for size, suffix in [((120, 75), ""), ((240, 150), "@2x")]:
		icon = build_icon(meta, size)
		out = output_path(config_path, suffix)
		out.parent.mkdir(parents=True, exist_ok=True)
		icon.save(out)
		outputs.append(out)
	return outputs


def main() -> None:
	configs = sorted(CONFIG_ROOT.glob("**/*.lua"))
	count = 0
	for config_path in configs:
		outputs = generate_for_config(config_path)
		count += len(outputs)
		print(config_path.relative_to(ROOT), "->", ", ".join(str(path.relative_to(ROOT)) for path in outputs))
	print(f"Generated {count} icons from {len(configs)} street configs.")


if __name__ == "__main__":
	main()
