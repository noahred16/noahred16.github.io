void mousePressed() {
  if (mouseButton == RIGHT) {
    setup(); // Resets the canvas by calling setup()
  }
}

void mouseDragged() {
  if (mouseButton == LEFT) {
    explosion(mouseX, mouseY);
  }
}

void explosion(float x, float y) {
  int numParticles = 32;
  float maxRadius = 28;
  float minRadius = 10;
  float angleStep = TWO_PI / numParticles;
  float baseHue = millis() % 255;
  for (int i = 0; i < numParticles; i++) {
    float angle = i * angleStep;
    float ex = x + cos(angle) * random(minRadius, maxRadius);
    float ey = y + sin(angle) * random(minRadius, maxRadius);
    float size = random(3, 8);
    float hue = (baseHue + i * 8) % 255;
    fill(hue, 255, 255, 180);
    noStroke();
    ellipse(ex, ey, size, size);
  }
}

void setup() {
  size(290, 290);
  colorMode(RGB, 255); // Set to RGB for background
  background(158, 173, 161); // RGB for #9eada1
  colorMode(HSB, 255); // Switch to HSB for drawing
}
void draw() {
  variableEllipse(mouseX, mouseY, pmouseX, pmouseY);
}

void variableEllipse(int x, int y, int px, int py) {
  float speed = abs(x - px) + abs(y - py);
  // Calculate a hue value that cycles over time
  float hueValue = millis() % 255;
  // Use fill() to color the inside of the ellipse and stroke() for the border
//   fill(hueValue, 255, 255, 127); // The last value (127) controls the transparency
  //if (mousePressed == true) {
    stroke(hueValue, 255, 255); // You can adjust or remove this if you don't want an outline
    strokeWeight(5); // Adjust the thickness of the outline
    ellipse(x, y, speed, speed);
  //}
}
