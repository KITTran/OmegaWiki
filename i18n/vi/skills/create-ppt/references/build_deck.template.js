// ============================================================
// build_deck.template.js — khung pptxgenjs cho /create-ppt
// Copy file này vào thư mục deck, đổi palette/nội dung, rồi `node build_deck.js`.
// Quy tắc đầy đủ: docs/ppt-guide.vi.md
// Cài: cd <deck-dir> && npm install pptxgenjs
// ============================================================
const pptxgen = require("pptxgenjs");
const fs = require("fs");
const path = require("path");

const ROOT = __dirname;
const DIMS = JSON.parse(fs.readFileSync(path.join(ROOT, "figures/dims.json")));
const P = (k) => path.join(ROOT, k);

// ---------- palette: gán THEO VAI TRÒ (đổi theme chỉ sửa ở đây) ----------
const SAGE = "A5B9A1", SAGE_D = "839388";   // chủ đạo / phụ
const BLUE = "4375BC";                       // kicker, header bảng, số liệu chính
const TERRA = "B17158";                      // highlight kết quả + dải dọc slide đặc biệt
const SLATE = "606969";                      // dữ liệu phụ
const INK = "172332";                        // tiêu đề + chữ chính
const LIGHT = "F4F4EE", CARD = "FFFFFF";     // nền sáng + card
const MUTED = "414240", LINE = "D4D5D0", PANEL = "E7E8E1";
const HEAD = "Lato", BODY = "Lato";          // sans cho chữ; công thức render ngoài bằng STIX

const W = 13.33, H = 7.5;
let pres = new pptxgen();
pres.defineLayout({ name: "WIDE", width: W, height: H });
pres.layout = "WIDE";

let PAGE = 0;

// shadow factory — KHÔNG tái dùng cùng object (pptxgenjs mutate in-place)
const sh = () => ({ type: "outer", color: "3A3D38", blur: 7, offset: 3, angle: 135, opacity: 0.16 });

// nền sáng cho mọi slide; sp = thêm dải dọc accent bên trái cho slide đặc biệt
function newSlide(sp) {
  PAGE++;
  const s = pres.addSlide();
  s.background = { color: LIGHT };
  if (sp) s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 0.35, h: H, fill: { color: TERRA } });
  return s;
}

function head(slide, kicker, title) {
  slide.addText(kicker.toUpperCase(), { x: 0.6, y: 0.40, w: 12, h: 0.3, fontSize: 12, bold: true, color: BLUE, charSpacing: 2, fontFace: BODY, margin: 0 });
  slide.addText(title, { x: 0.6, y: 0.70, w: 12.1, h: 0.9, fontSize: 27, bold: true, color: INK, fontFace: HEAD, margin: 0 });
}

function footer(slide) {
  slide.addText([
    { text: "DECK-NAME", options: { bold: true, color: BLUE } },
    { text: "   subtitle / one-liner", options: { color: MUTED } },
  ], { x: 0.55, y: 7.04, w: 11, h: 0.3, fontSize: 9, fontFace: BODY, align: "left", margin: 0 });
  slide.addText(String(PAGE), { x: 12.5, y: 7.04, w: 0.4, h: 0.3, fontSize: 9, color: MUTED, align: "right", margin: 0 });
}

// nhúng ảnh GIỮ TỶ LỆ trong box (bx,by,bw,bh) — đọc dims.json
function fitImg(slide, key, bx, by, bw, bh, opts = {}) {
  const [iw, ih] = DIMS[key]; const ar = iw / ih;
  let w = bw, h = bw / ar;
  if (h > bh) { h = bh; w = bh * ar; }
  const x = bx + (bw - w) / 2, y = by + (bh - h) / 2;
  slide.addImage(Object.assign({ path: P(key), x, y, w, h }, opts));
  return { x, y, w, h };
}

function caption(slide, txt, x, y, w) {
  slide.addText(txt, { x, y, w, h: 0.3, fontSize: 10, italic: true, color: MUTED, align: "center", fontFace: BODY, margin: 0 });
}

function card(slide, x, y, w, h, fill) {
  slide.addShape(pres.shapes.RECTANGLE, { x, y, w, h, fill: { color: fill || CARD }, line: { color: LINE, width: 1 }, shadow: sh() });
}

// bullet THẬT (không ký tự "•"); hỗ trợ {t, b:bold, lvl} hoặc string
function bullets(slide, items, x, y, w, h, opts = {}) {
  const fsz = opts.fontSize || 15;
  const runs = items.map((it) => {
    const isObj = typeof it === "object";
    const text = isObj ? it.t : it;
    const lvl = isObj ? (it.lvl || 0) : 0;
    return { text, options: {
      bullet: { code: "2022", indent: 14 }, indentLevel: lvl,
      color: opts.color || INK, fontSize: lvl ? fsz - 2 : fsz, bold: isObj && it.b,
      breakLine: true, paraSpaceAfter: opts.gap != null ? opts.gap : 7, fontFace: BODY,
    } };
  });
  slide.addText(runs, { x, y, w, h, valign: "top", margin: 0 });
}

function divider(num, title, sub) {
  const s = newSlide(true);
  s.addText(num, { x: 0.9, y: 1.9, w: 4, h: 2.2, fontSize: 150, bold: true, color: "DBD8CF", fontFace: HEAD, margin: 0 });
  s.addText("PART " + num, { x: 1.0, y: 2.5, w: 11, h: 0.4, fontSize: 14, bold: true, color: BLUE, charSpacing: 3, fontFace: BODY, margin: 0 });
  s.addText(title, { x: 1.0, y: 2.9, w: 11.5, h: 1.0, fontSize: 44, bold: true, color: INK, fontFace: HEAD, margin: 0 });
  s.addText(sub, { x: 1.0, y: 4.0, w: 10.5, h: 0.8, fontSize: 17, color: "2E3A30", italic: true, fontFace: BODY, margin: 0 });
  footer(s);
  return s;
}

// ============================================================
// SLIDES — thay bằng nội dung thật. Khung 5 phần:
// Motivation → Method → Architecture → Experiments → Discussion
// ============================================================

// 1. TITLE (slide đặc biệt → dải dọc accent)
(() => {
  const s = newSlide(true);
  s.addText("PAPER REVIEW · SEMINAR", { x: 0.9, y: 1.25, w: 11, h: 0.4, fontSize: 14, bold: true, color: BLUE, charSpacing: 3, fontFace: BODY, margin: 0 });
  s.addText("DECK TITLE", { x: 0.9, y: 1.7, w: 11.5, h: 1.0, fontSize: 60, bold: true, color: INK, fontFace: HEAD, margin: 0 });
  s.addText("Subtitle / paper full title", { x: 0.9, y: 2.85, w: 11.3, h: 1.0, fontSize: 21, color: "2E3A30", italic: true, fontFace: HEAD, margin: 0 });
  footer(s);
})();

// 2. AGENDA / nội dung — slide thường (nền sáng, không dải)
(() => {
  const s = newSlide(false);
  head(s, "Roadmap", "What this talk covers");
  bullets(s, ["Motivation", "Method", "Architecture", "Experiments", "Discussion"], 0.6, 1.9, 12, 4);
  footer(s);
})();

// ví dụ slide có hình giữ tỷ lệ + caption:
// (() => {
//   const s = newSlide(false);
//   head(s, "Figure 1", "Architecture");
//   const b = fitImg(s, "figures/fig1_architecture.png", 0.6, 1.8, 8.4, 4.9);
//   caption(s, "Fig. 1 — ...", 0.6, b.y + b.h + 0.05, 8.4);
//   footer(s);
// })();

// ví dụ divider:  divider("01", "Method", "...");

const outFile = path.join(ROOT, "DECK-NAME.pptx");
pres.writeFile({ fileName: outFile }).then(() => console.log("WROTE", outFile, " slides:", PAGE));
