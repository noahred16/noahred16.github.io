/**
 * Flower animation for my love.
 *
 * @author:  Noah Red Smith
 */

// variables for the garden (how the flowers are placed and how they vary)
int flowerCount = 12;
float ringRadius = 25;                // flowers stand evenly on a circle this wide, centered at the bottom of the scene
float minStemHeight = 90;
float maxStemHeight = 170;
float minLean = radians(12);          // each flower tips outward from the ring by a random amount in this range
float maxLean = radians(20);
float leanJitter = radians(20);       // random wiggle on the lean direction so they don't all fan out perfectly
float petalOpenJitter = radians(8);   // random +/- on how open each flower is
float headTiltJitter = radians(12);   // random +/- on how far each head nods (on top of headTilt)
float headNodJitter = radians(45);    // random +/- on which way each head nods (0 = always straight outward)
float branchTiltJitter = radians(15); // random +/- on each branch's tilt (on top of branchTilt)
float branchSpinJitter = radians(25); // random +/- on each branch's twist around the stem
int seed = 47;                         // change for a different (but repeatable) arrangement

// variables for the background
color backgroundColor = color(255, 227, 236);   // #ffe3ec, matches the birthday card (css/styles.css)

// variables for the camera
float cameraTilt = 0.2;               // radians; 0 = looking from the side, HALF_PI = straight down from above
float groundOffset = 60;              // how far above the bottom of the window the soil sits (leaves room for the pot)
float spinSpeed = 0.15;               // how fast the camera circles, in radians per second

// variables for the pot (the soil surface is at y = 0; the pot hangs below it)
float potTopRadius = 36;              // keep > ringRadius + stemWidth so the stems fit inside
float potBottomRadius = 26;           // narrower base gives the tapered shape
float potHeight = 42;                 // from the soil down to the pot's bottom
int potDetail = 32;                   // segments around the circle: higher = rounder

// variables for the corner text
String topLeftLabel = "for KR <3";
String bottomRightLabel = "love NS";
float labelSize = 14;
float labelMargin = 10;              // distance from the window edges
color labelColor = color(200, 60, 90);  // soft rose

// variables for the stem
float stemWidth = 5;

// variables for the branches
int branchCount = 5;
float branchWidth = 4;
float branchLength = 15;
float branchTilt = radians(50);       // how far each branch leans away from the stem (0 = straight up)
float branchSpin = radians(137.5);    // twist between branches ("golden angle" looks natural)

// variables for the leaves
float leafLength = 14;
float leafWidth = 6;                  // half-width at the widest point
float leafCurl = radians(35);         // tips the leaf out of the branch's plane so it reads as 3D
int leafDetail = 8;                   // points along each side of the leaf: higher = smoother curve

// variables for the flower head
int petalCount = 6;
float petalLength = 30;
float petalWidth = 8;                 // half-width at the widest point
float headTilt = radians(20);         // extra outward tip of the flower head on top of the stem's lean
float petalOpen = radians(70);        // 0 = petals straight up (closed bud), 90 = flat open
float centerSize = 6;                 // radius of the yellow middle
float centerDrop = 4;                 // how far the yellow middle sits below the top of the stem
float petalCup = 4;                   // how deep each petal dips in the middle (spoon/bowl shape)
// where the stem pokes out of the bottom of the yellow center, measured down from the top of the stem
float stemJoinDepth = centerDrop + sqrt(sq(centerSize) - sq(stemWidth / 2));
// how far the petal base tucks under the center: far enough that, once the petal is swung open by
// petalOpen, its base lands right where the stem meets the yellow center, so no gap shows there
float petalBaseDrop = stemJoinDepth / sin(petalOpen);
// white squashed sphere under the head that hides any gap where the stem meets the petals
float collarRadius = centerSize * 1.2;
float collarSquash = 0.75;            // collar height relative to its width (1 = round ball, 0 = flat disc)
float collarDepth = stemJoinDepth-2;    // sits where the stem pokes out of the bottom of the yellow center
float petalShadeDepth = 95;           // how much darker the petal's edges and base are than its middle (0 = flat white)
int petalDetail = 12;                 // mesh resolution: higher = smoother curves

Flower[] flowers;
PVector[][] petalMesh;                // one petal's grid of points, built once in setup() and reused for every petal
float[][] petalShades;                // brightness at each mesh point, standing in for real lighting (see beginUnlit())


void setup() {
  size(290, 290, P3D);
  frameRate(30);
  petalMesh = createPetalMesh();
  petalShades = createPetalShades();
  flowers = createFlowers();
}

void draw() {
  background(backgroundColor);

  // lights() is called before applyCamera() so the light stays fixed while the world spins
  lights();
  pushMatrix();
  applyCamera();
  drawPot();
  for (Flower flower : flowers) {
    flower.draw();
  }
  popMatrix();

  drawLabels();
}

// flat 2D text in the window corners, drawn last and on top of the 3D scene
void drawLabels() {
  hint(DISABLE_DEPTH_TEST);    // so the flowers can never cover the text
  noLights();
  fill(labelColor);
  textSize(labelSize);

  textAlign(LEFT, TOP);
  text(topLeftLabel, labelMargin, labelMargin);

  textAlign(RIGHT, BOTTOM);
  text(bottomRightLabel, width - labelMargin, height - labelMargin);

  hint(ENABLE_DEPTH_TEST);
}

// processing.js gives no normals to shapes built with vertex() (only box() and sphere() get them),
// so with the lights on those shapes only catch the dim ambient light and come out about half as
// bright as their fill color. Draw them between beginUnlit()/endUnlit() to show their true colors.
void beginUnlit() {
  noLights();
}

// turns the lights back on exactly as draw() set them: lights() aims by the current transform,
// so reset to the frame's starting camera first
void endUnlit() {
  pushMatrix();
  camera();
  lights();
  popMatrix();
}

// "camera": pivots around the window center, tilts the view down a bit, and spins the world,
// then drops the origin to the center of the soil. Everything in the scene is positioned
// relative to the soil center, with the soil surface at y = 0.
void applyCamera() {
  translate(width/2, height/2, 0);
  rotateX(-cameraTilt);
  rotateY(millis() / 1000.0 * spinSpeed);   // clock-based, so a slow frame doesn't slow the spin
  translate(0, height/2 - groundOffset, 0);
}

// a random value within +/- amount of center
float jitter(float center, float amount) {
  return center + random(-amount, amount);
}

// builds the ring of flowers once, so their random values stay the same every frame
Flower[] createFlowers() {
  randomSeed(seed);
  float groundY = 0;   // applyCamera() puts the origin at the soil center

  Flower[] result = new Flower[flowerCount];
  for (int i = 0; i < flowerCount; i++) {
    float angle = i * TWO_PI / flowerCount;
    PVector base = new PVector(ringRadius * cos(angle), groundY, ringRadius * sin(angle));

    result[i] = new Flower(base, angle);
  }
  return result;
}


/**
 * Petal mesh, built once in setup(): a curved white oval "spoon" pointing "up" (-y)
 * whose base tucks under the flower's center. It's a grid of points: rows go base -> tip,
 * columns go edge -> edge. Local +z is the petal's underside.
 * (Stored as points rather than a PShape because processing.js has no createShape().)
 */
PVector[][] createPetalMesh() {
  PVector[][] mesh = new PVector[petalDetail + 1][petalDetail + 1];
  for (int row = 0; row <= petalDetail; row++) {
    for (int col = 0; col <= petalDetail; col++) {
      mesh[row][col] = petalPoint(row / (float) petalDetail, map(col, 0, petalDetail, -1, 1));
    }
  }
  return mesh;
}

// baked-in shading: bright down the middle, a little darker toward the edges and the base,
// so the white petals don't disappear against the white background when drawn unlit
float[][] createPetalShades() {
  float[][] shades = new float[petalDetail + 1][petalDetail + 1];
  for (int row = 0; row <= petalDetail; row++) {
    for (int col = 0; col <= petalDetail; col++) {
      float t = row / (float) petalDetail;
      float s = map(col, 0, petalDetail, -1, 1);
      shades[row][col] = 255 - petalShadeDepth * (0.6 * s * s + 0.4 * sq(1 - t));
    }
  }
  return shades;
}

// draws the petal mesh as quads between neighboring grid points
void drawPetalMesh() {
  noStroke();
  beginShape(QUADS);
  for (int row = 0; row < petalDetail; row++) {
    for (int col = 0; col < petalDetail; col++) {
      petalVertex(row, col);
      petalVertex(row + 1, col);
      petalVertex(row + 1, col + 1);
      petalVertex(row, col + 1);
    }
  }
  endShape();
}

void petalVertex(int row, int col) {
  PVector p = petalMesh[row][col];
  fill(petalShades[row][col]);
  vertex(p.x, p.y, p.z);
}

// a point on the petal surface.
// t: 0 at the base, 1 at the tip.  s: -1 at one edge, 0 down the middle, +1 at the other edge.
PVector petalPoint(float t, float s) {
  // oval outline: wide-ish at the base so neighbors overlap, widest past the middle, closing at the tip
  float halfWidth = petalWidth * pow(sin(PI * lerp(0.2, 1, t)), 0.7);

  // base starts below the center and curves up into the petal, forming the bowl under the bulb
  float baseDrop = petalBaseDrop * sq(1 - t);

  // spoon shape: the middle of the petal dips lower than its edges
  float cup = petalCup * (1 - s * s) * sin(PI * t);

  return new PVector(s * halfWidth, -petalLength * t, baseDrop + cup);
}


/**
 * Pot: a simple clay pot, a tapered cup with soil on top.
 * The soil surface is at y = 0 and the pot extends down (+y) from there.
 */

color potColor = color(196, 98, 60);   // terracotta
color soilColor = color(70, 45, 30);
float potShadeDepth = 0.3;             // how much darker the pot's base is than its rim (0-1)

void drawPot() {
  color potBaseColor = lerpColor(potColor, color(0), potShadeDepth);
  beginUnlit();
  noStroke();

  drawFrustum(potTopRadius, 0, potColor, potBottomRadius, potHeight, potBaseColor);
  fill(potBaseColor);
  drawDisc(potBottomRadius, potHeight);

  fill(soilColor);
  drawDisc(potTopRadius, 0);
  endUnlit();
}

// open-ended tube around the Y axis, radius r1 at height y1 to radius r2 at height y2,
// with its color fading from c1 at the first end to c2 at the other
void drawFrustum(float r1, float y1, color c1, float r2, float y2, color c2) {
  beginShape(QUAD_STRIP);
  for (int i = 0; i <= potDetail; i++) {
    float a = i * TWO_PI / potDetail;
    fill(c1);
    vertex(r1 * cos(a), y1, r1 * sin(a));
    fill(c2);
    vertex(r2 * cos(a), y2, r2 * sin(a));
  }
  endShape();
}

// flat solid circle lying in the XZ plane at height y
void drawDisc(float r, float y) {
  beginShape(TRIANGLE_FAN);
  vertex(0, y, 0);
  for (int i = 0; i <= potDetail; i++) {
    float a = i * TWO_PI / potDetail;
    vertex(r * cos(a), y, r * sin(a));
  }
  endShape();
}


/**
 * Flower: one flower, a stem with leafy branches and a white flower head.
 *
 * Each flower stores only what makes it different from the others (where it stands,
 * how tall it is, which way it leans and nods...), picked randomly once when it's created.
 * The shared look (petal shape, colors, leaf size...) and the ranges for the random
 * values come from the global variables at the top of this file.
 */
class Flower {
  PVector base;          // where the stem meets the ground
  float stemHeight;
  float leanAngle;       // how far the whole flower tips away from vertical
  float leanDirection;   // which way it tips, as an angle around the world Y axis
  float spin;            // turns the flower on its own stem so branch layouts differ
  float petalOpenAngle;  // 0 = closed bud, HALF_PI = flat open
  float headTiltAngle;   // how far the head nods on top of the stem's lean
  float headNod;         // which way the head nods, relative to straight outward
  float headTwist;       // turns the petals around the center so they don't all line up
  float[] branchTilts;   // each branch's lean away from the stem
  float[] branchSpins;   // each branch's twist around the stem

  // base: where it stands.  outwardAngle: the direction pointing away from the ring's center.
  // Uses random(), so call randomSeed() first for a repeatable garden.
  Flower(PVector base, float outwardAngle) {
    this.base = base;
    // (order matters: keeping these first keeps the same arrangement for a given seed)
    stemHeight = random(minStemHeight, maxStemHeight);
    leanAngle = random(minLean, maxLean);
    leanDirection = outwardAngle + random(-leanJitter, leanJitter);   // lean roughly outward
    spin = random(TWO_PI);                                             // branches face a different way
    petalOpenAngle = jitter(petalOpen, petalOpenJitter);

    headTiltAngle = jitter(headTilt, headTiltJitter);
    headNod = random(-headNodJitter, headNodJitter);
    headTwist = random(TWO_PI / petalCount);    // petals repeat every TWO_PI / petalCount

    branchTilts = new float[branchCount];
    branchSpins = new float[branchCount];
    for (int i = 0; i < branchCount; i++) {
      branchTilts[i] = jitter(branchTilt, branchTiltJitter);
      branchSpins[i] = jitter(i * branchSpin, branchSpinJitter);
    }
  }
  void draw() {
    pushMatrix();
    translate(base.x, base.y, base.z);
    rotateY(-leanDirection);   // aim local +x at leanDirection (negative because of Processing's axes)
    rotateZ(leanAngle);        // tip toward local +x, pivoting at the base
    rotateY(spin);

    translate(0, -stemHeight/2, 0);   // origin to the stem's center (box() is drawn centered)
    drawStem();
    drawBranches();

    translate(0, -stemHeight/2, 0);   // top of the stem
    rotateY(-spin);                   // undo the spin so local +x points outward again (the lean direction)
    rotateY(headNod);                 // turn the nod a little off straight-outward
    rotateZ(headTiltAngle);           // nod the head
    rotateY(headTwist);               // turn the petals around the center
    drawFlowerHead();
    popMatrix();
  }

  // ---- stem & branches -------------------------------------------------

  void drawStem() {
    fill(100, 200, 100);
    noStroke();
    box(stemWidth, stemHeight, stemWidth);
  }

  // branches spaced evenly up the stem, each twisted around it and leaning outward.
  // Expects the origin at the stem's center.
  void drawBranches() {
    for (int i = 0; i < branchCount; i++) {
      // stem bottom is +stemHeight/2, top is -stemHeight/2 (up is -y).
      // Dividing by (branchCount + 2) leaves a gap below the flower head so the top leaf clears the petals.
      float attachY = stemHeight/2 - stemHeight * (i + 1) / (branchCount + 2.0);

      pushMatrix();
      translate(0, attachY, 0);
      rotateY(branchSpins[i]);
      rotateZ(branchTilts[i]);
      drawBranch();
      popMatrix();
    }
  }

  // one branch, starting at the origin and pointing "up" (-y), with a leaf at the tip
  void drawBranch() {
    fill(80, 170, 80);
    noStroke();
    pushMatrix();
    translate(0, -branchLength/2, 0);
    box(branchWidth, branchLength, branchWidth);
    popMatrix();

    pushMatrix();
    translate(0, -branchLength, 0);
    rotateX(leafCurl);
    drawLeaf();
    popMatrix();
  }

  // flat almond-shaped leaf with a center vein, pointing "up" (-y)
  void drawLeaf() {
    beginUnlit();
    fill(60, 160, 70);
    noStroke();
    drawAlmond(leafLength, leafWidth);
    endUnlit();

    stroke(40, 110, 50);
    strokeWeight(1);
    line(0, 0, 0.1, 0, -leafLength * 0.9, 0.1);   // nudged off the surface so it isn't hidden
    noStroke();
  }

  // ---- flower head -----------------------------------------------------

  // petals arranged evenly around a yellow center. Expects the origin at the top of the stem.
  void drawFlowerHead() {
    beginUnlit();
    for (int i = 0; i < petalCount; i++) {
      pushMatrix();
      rotateY(i * TWO_PI / petalCount);   // spread petals evenly around the stem
      rotateZ(petalOpenAngle);            // swing the petal down from vertical toward flat
      rotateY(HALF_PI);                   // spin it on its long axis so its face points up
      drawPetal();
      popMatrix();
    }

    // also unlit: lit, the top of the center faces away from the light and goes a dull olive green
    fill(250, 210, 60);
    noStroke();
    pushMatrix();
    translate(0, centerDrop, 0);   // sink the center down into the petal bowl so no stem shows through
    sphere(centerSize);
    popMatrix();
    endUnlit();

    // white squashed sphere where the stem meets the head, covering any gap between the petal bases
    // and the center. Lit (sphere() has normals), so it shades and has depth from the side.
    fill(255);
    noStroke();
    pushMatrix();
    translate(0, collarDepth, 0);
    scale(1, collarSquash, 1);
    sphere(collarRadius);
    popMatrix();
  }

  void drawPetal() {
    drawPetalMesh();
  }

  // flat almond shape from the origin to (0, -len), filled as a triangle fan around its middle.
  // Each side follows a bezier curve; the points are computed with bezierPoint() rather than
  // drawn with bezierVertex(), because processing.js doesn't fill bezier shapes in 3D.
  void drawAlmond(float len, float halfWidth) {
    beginShape(TRIANGLE_FAN);
    vertex(0, -len / 2, 0);                 // fan center
    for (int i = 0; i <= leafDetail; i++) {     // right side, base -> tip
      float t = i / (float) leafDetail;
      vertex(almondX(halfWidth, t), almondY(len, t), 0);
    }
    for (int i = leafDetail; i >= 0; i--) {     // left side, tip -> base
      float t = i / (float) leafDetail;
      vertex(-almondX(halfWidth, t), almondY(len, t), 0);
    }
    endShape();
  }

  float almondX(float halfWidth, float t) {
    return bezierPoint(0, halfWidth, halfWidth, 0, t);
  }

  float almondY(float len, float t) {
    return bezierPoint(0, -len * 0.25, -len * 0.75, -len, t);
  }
}
