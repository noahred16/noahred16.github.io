float bx, by;
float vx = 2.3, vy = 1.8;
float bw = 86, bh = 62;

int[] palette;
int colorIdx = 0;
int boxColor;

ArrayList bits;
boolean partying = false;
int partyTimer = 0;

void setup() {
  size(290, 290);
  frameRate(30);

  palette = new int[8];
  palette[0] = color(220, 65,  65);
  palette[1] = color(55,  140, 220);
  palette[2] = color(55,  195, 95);
  palette[3] = color(240, 200, 40);
  palette[4] = color(195, 60,  220);
  palette[5] = color(240, 120, 40);
  palette[6] = color(40,  205, 205);
  palette[7] = color(235, 75,  160);

  boxColor = palette[0];
  bx = 55;
  by = 85;
  bits = new ArrayList();
}

void draw() {
  background(216, 243, 220);

  bx += vx;
  by += vy;

  boolean hx = false, hy = false;

  if (bx <= 0)           { bx = 0;           vx =  abs(vx); hx = true; }
  if (bx + bw >= width)  { bx = width - bw;  vx = -abs(vx); hx = true; }
  if (by <= 0)           { by = 0;            vy =  abs(vy); hy = true; }
  if (by + bh >= height) { by = height - bh; vy = -abs(vy); hy = true; }

  if (hx || hy) {
    colorIdx = (colorIdx + 1) % 8;
    boxColor = palette[colorIdx];
  }

  boolean corner = false;
  if (hx && hy)                                corner = true;
  if (hx && (by < 8 || by + bh > height - 8)) corner = true;
  if (hy && (bx < 8 || bx + bw > width - 8))  corner = true;

  if (corner && !partying) triggerParty();

  for (int i = bits.size() - 1; i >= 0; i--) {
    Confetti c = bits.get(i);
    c.update();
    c.display();
    if (c.dead()) bits.remove(i);
  }

  if (partying) {
    partyTimer--;
    if (partyTimer <= 0) partying = false;
  }

  drawLogo();
}

void triggerParty() {
  partying = true;
  partyTimer = 100;
  float cx = bx + bw / 2;
  float cy = by + bh / 2;
  for (int i = 0; i < 90; i++) {
    bits.add(new Confetti(cx, cy, palette[i % 8]));
  }
}

void drawLogo() {
  pushMatrix();
  translate(bx + bw / 2, by + bh / 2);

  // ── "NRS" italic via shear ──
  pushMatrix();
  translate(0, -14);
  shearX(-0.22);
  textAlign(CENTER, CENTER);
  textSize(32);
  noStroke();
  fill(red(boxColor), green(boxColor), blue(boxColor), 40);
  text("NRS", 2, 2);
  fill(boxColor);
  text("NRS", 0, 0);
  popMatrix();

  // ── VIDEO oval ──
  float ow = 72, oh = 22;
  noFill();
  stroke(red(boxColor), green(boxColor), blue(boxColor), 40);
  strokeWeight(2.5);
  ellipse(2, 20, ow, oh);
  stroke(boxColor);
  strokeWeight(partying ? 3 : 2.5);
  noFill();
  ellipse(0, 18, ow, oh);
  noStroke();
  fill(boxColor);
  textAlign(CENTER, CENTER);
  textSize(10);
  text("VIDEO", 0, 18);

  popMatrix();
}

class Confetti {
  float x, y, vx, vy;
  float sz;
  int col;
  float alpha;
  float rot, rotV;

  Confetti(float px, float py, int c) {
    x = px;
    y = py;
    float angle = random(TWO_PI);
    float speed = random(3, 9);
    vx = cos(angle) * speed;
    vy = sin(angle) * speed - 2.5;
    sz = random(4, 9);
    col = c;
    alpha = 255;
    rot = random(TWO_PI);
    rotV = random(-0.18, 0.18);
  }

  void update() {
    x += vx;
    y += vy;
    vy += 0.35;
    vx *= 0.97;
    alpha -= 3.5;
    rot += rotV;
  }

  void display() {
    pushMatrix();
    translate(x, y);
    rotate(rot);
    noStroke();
    fill(red(col), green(col), blue(col), alpha);
    rect(-sz / 2, -sz / 2, sz, sz, 2);
    popMatrix();
  }

  boolean dead() {
    return alpha <= 0 || y > height + 20;
  }
}
