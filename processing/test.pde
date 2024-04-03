void setup() {
  size(640, 360);
  background(102);
  colorMode(HSB, 255); // Switch to HSB mode with a max value of 255 for each component
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
  stroke(hueValue, 255, 255); // You can adjust or remove this if you don't want an outline
  strokeWeight(5); // Adjust the thickness of the outline
  ellipse(x, y, speed, speed);
}
