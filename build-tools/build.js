/**
 * build.js
 * Converts SVG assets into an animated Lottie file for the Perspective splash.
 *
 * Quick start:
 *   npm init -y
 *   npm install @lottiefiles/svg-to-lottie
 *   node build.js
 */

const { svgToLottie } = require("@lottiefiles/svg-to-lottie");
const fs = require("fs").promises;

const FPS = 30;
const TOTAL_FRAMES = 60;
const WIDTH = 360;
const HEIGHT = 240;

/**
 * Helper: build position keyframes
 * @param {Array<[number, [number, number]]>} pts
 */
function kf(pts) {
  return {
    a: 1,
    k: pts.map(([t, [x, y]]) => ({ t, s: [x, y] })),
  };
}

async function shapeLayer(index, name, svgFile, keyframes) {
  const svg = await fs.readFile(svgFile, "utf8");
  const lottieShape = await svgToLottie(svg, {
    defaultShapeName: name + "_shape",
    shapeOptions: { fillRule: "nonzero" },
  });

  return {
    ddd: 0,
    ind: index,
    ty: 4,
    nm: name,
    sr: 1,
    ks: {
      p: kf(keyframes),
      a: { a: 0, k: [30, 30, 0] },
      s: { a: 0, k: [100, 100, 100] },
      r: { a: 0, k: 0 },
      o: { a: 0, k: 100 },
    },
    shapes: lottieShape.shapes,
    ao: 0,
  };
}

(async () => {
  const layers = [];

  layers.push(
    await shapeLayer(1, "Triangle", "triangle.svg", [
      [0, [-50, 40]],
      [15, [90, 120]],
      [20, [102, 120]],
      [32, [90, 120]],
    ])
  );

  layers.push(
    await shapeLayer(2, "Square", "square.svg", [
      [0, [150, -40]],
      [15, [150, 120]],
      [20, [150, 132]],
      [32, [150, 120]],
    ])
  );

  layers.push(
    await shapeLayer(3, "Circle", "circle.svg", [
      [0, [370, 120]],
      [15, [210, 120]],
      [20, [198, 120]],
      [32, [210, 120]],
    ])
  );

  // Wordmark layer (text)
  layers.push({
    ddd: 0,
    ind: 4,
    ty: 5,
    nm: "Wordmark",
    sr: 1,
    ks: {
      p: { a: 0, k: [180, 60] },
      a: { a: 0, k: [0, 0, 0] },
      s: { a: 0, k: [100, 100, 100] },
      r: { a: 0, k: 0 },
      o: {
        a: 1,
        k: [
          { t: 0, s: [0] },
          { t: 32, s: [100] },
        ],
      },
    },
    text: {
      d: {
        k: [
          {
            s: {
              sz: [300, 50],
              ps: [-150, -25],
              text: "PERSPECTIVE",
              f: "Montserrat-Bold",
              j: 1,
              tr: 0,
              lh: 60,
              ls: 0,
              fc: [0, 0.2, 0.4],
            },
            t: 0,
          },
        ],
      },
      p: { m: 0, f: "Montserrat-Bold" },
      a: [],
    },
    ao: 0,
  });

  const animation = {
    v: "5.10.1",
    fr: FPS,
    w: WIDTH,
    h: HEIGHT,
    ip: 0,
    op: TOTAL_FRAMES,
    nm: "Perspective Splash",
    layers,
  };

  await fs.writeFile("perspective_option3.json", JSON.stringify(animation));
  console.log("✅  perspective_option3.json generated!");
})();