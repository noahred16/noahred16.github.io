void setup() {
  background(158, 173, 161); // RGB for #9eada1
  size(290, 290);
  frameRate(30);
  noStroke();
}

void draw() {
  background(158, 173, 161); // RGB for #9eada1
  float barheight = 0;
  for (float i = 0; i < 1; i += 1 / 16.0) {
    fill(255, 0, 0, 150);
    barheight = inOutSin(tri(timeLoop(60, i * 60))) * 100;
    rect(15 + i * 264, 195 - barheight, 13, barheight);
    fill(0, 255, 0, 150);
    barheight = inOutSin(tri(timeLoop(60, i * 60 + 20))) * 100;
    rect(15 + i * 264, 195 - barheight, 13, barheight);
    fill(0, 0, 255, 150);
    barheight = inOutSin(tri(timeLoop(60, i * 60 + 40))) * 100;
    rect(15 + i * 264, 195 - barheight, 13, barheight);
  }
}

float timeLoop(float totalframes, float offset) {
  return (frameCount + offset) % totalframes / totalframes;
}

float tri(float t) {
  return t < 0.5 ? t * 2 : 2 - (t * 2);
}

float inOutSin(float t) {
  return 0.5 - cos(PI * t) / 2;
}