float carX, carY;
float carAngle = 0;
float carSpeed = 0;
float maxSpeed = 5.0;
float boostMax = 9.0;
float accel = 0.18;
float friction = 0.06;
float turnRate = 0.09;

boolean keyUp, keyDown, keyLeft, keyRight, keyBoost;

int score = 0;
int numDots = 5;
float[] dotX = new float[numDots];
float[] dotY = new float[numDots];
float collectDist = 15;

void setup() {
  size(290, 290);
  frameRate(30);
  carX = width / 2;
  carY = height / 2;
  for (int i = 0; i < numDots; i++) spawnDot(i);
}

void spawnDot(int i) {
  float nx, ny;
  do {
    nx = random(20, width  - 20);
    ny = random(20, height - 20);
  } while (dist(nx, ny, carX, carY) < 40);
  dotX[i] = nx;
  dotY[i] = ny;
}

void draw() {
  background(216, 243, 220);

  boolean boosting = keyBoost && carSpeed > 0.3;
  float curMax = boosting ? boostMax : maxSpeed;

  // Acceleration / braking
  if (keyUp) {
    carSpeed = min(carSpeed + (boosting ? accel * 2.8 : accel), curMax);
  } else if (keyDown) {
    carSpeed = max(carSpeed - accel * 1.4, -maxSpeed * 0.5);
  } else {
    carSpeed *= (1 - friction);
    if (abs(carSpeed) < 0.01) carSpeed = 0;
  }
  if (boosting && !keyUp) carSpeed = min(carSpeed + accel * 1.2, curMax);

  // Turning
  float turn = turnRate * constrain(abs(carSpeed) / maxSpeed, 0.2, 1.0);
  if (carSpeed < 0) turn = -turn;
  if (keyLeft)  carAngle -= turn;
  if (keyRight) carAngle += turn;

  // Move + wraparound
  carX += cos(carAngle) * carSpeed;
  carY += sin(carAngle) * carSpeed;
  if (carX < -14)         carX += width  + 28;
  if (carX > width  + 14) carX -= width  + 28;
  if (carY < -14)         carY += height + 28;
  if (carY > height + 14) carY -= height + 28;

  // Collect dots
  for (int i = 0; i < numDots; i++) {
    if (dist(carX, carY, dotX[i], dotY[i]) < collectDist) {
      score++;
      spawnDot(i);
    }
  }

  // Draw dots
  for (int i = 0; i < numDots; i++) {
    float pulse = 1 + 0.18 * sin(frameCount * 0.15 + i * 1.3);
    float r = 5 * pulse;
    noStroke();
    fill(255, 200, 50, 70);
    ellipse(dotX[i], dotY[i], r * 3.2, r * 3.2);
    fill(255, 210, 60);
    ellipse(dotX[i], dotY[i], r * 2, r * 2);
    fill(255, 240, 150);
    ellipse(dotX[i], dotY[i], r * 0.9, r * 0.9);
  }

  drawCar(carX, carY, carAngle, carSpeed, boosting);

  // Score — top right
  noStroke();
  fill(26, 71, 50, 160);
  rect(width - 52, 8, 44, 22, 4);
  fill(240, 250, 244);
  textAlign(RIGHT, CENTER);
  textSize(13);
  text(score, width - 12, 20);
}

void drawCar(float x, float y, float angle, float spd, boolean boosting) {
  pushMatrix();
  translate(x, y);
  rotate(angle);

  if (boosting) drawFlame();

  // Car body
  fill(220, 50, 50);
  stroke(30);
  strokeWeight(2);
  rect(-12, -8, 24, 16, 3);

  // Windshield
  fill(100, 150, 200, 180);
  triangle(-5, -6, -5, 6, 8, 0);

  // Wheels
  fill(40);
  stroke(20);
  strokeWeight(1);
  ellipse(-8, -10, 5, 7);
  ellipse(-8,  10, 5, 7);
  ellipse( 8, -10, 5, 7);
  ellipse( 8,  10, 5, 7);

  // Racing stripe
  fill(255);
  noStroke();
  rect(-8, -2, 16, 4);

  // Headlights
  fill(255, 255, 150);
  ellipse(12, -5, 3, 3);
  ellipse(12,  5, 3, 3);

  // Speed lines
  if (spd > 2.5) {
    stroke(boosting ? color(255, 160, 0, 160) : color(180, 130));
    strokeWeight(boosting ? 2.0 : 1.5);
    int lines = boosting ? 5 : 3;
    for (int i = 0; i < lines; i++) {
      float d = 15 + i * 7;
      line(-d, -4, -(d + 6), -4);
      line(-d,  4, -(d + 6),  4);
    }
  }

  popMatrix();
}

void drawFlame() {
  noStroke();
  fill(255, 60, 0, 120);
  triangle(-12, -7, -12, 7, -12 - random(20, 32), random(-3, 3));
  fill(255, 130, 0, 190);
  triangle(-12, -5, -12, 5, -12 - random(16, 26), random(-2, 2));
  fill(255, 100, 0, 160);
  triangle(-12, -3, -12, 3, -12 - random(10, 20), random(-4, 4));
  fill(255, 230, 80, 230);
  triangle(-12, -3, -12, 3, -12 - random(8, 15), random(-1, 1));
  fill(255, 245, 200, 200);
  triangle(-12, -1.5, -12, 1.5, -12 - random(4, 9), 0);
}

void keyPressed() {
  if (keyCode == UP)    keyUp    = true;
  if (keyCode == DOWN)  keyDown  = true;
  if (keyCode == LEFT)  keyLeft  = true;
  if (keyCode == RIGHT) keyRight = true;
  if (key == ' ')       keyBoost = true;
}

void keyReleased() {
  if (keyCode == UP)    keyUp    = false;
  if (keyCode == DOWN)  keyDown  = false;
  if (keyCode == LEFT)  keyLeft  = false;
  if (keyCode == RIGHT) keyRight = false;
  if (key == ' ')       keyBoost = false;
}
