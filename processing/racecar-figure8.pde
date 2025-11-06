// Figure 8 Race Track with Bumpable Car
// Click near the car to bump it!

float t = 0; // parameter for figure-8 path
float carX, carY; // car position
float targetX, targetY; // target position on path
float carAngle = 0; // car rotation
float bumpOffsetX = 0; // bump displacement
float bumpOffsetY = 0;
float bumpVelX = 0; // bump velocity
float bumpVelY = 0;
boolean isBumped = false;

void setup() {
  size(290, 290);
  smooth();
}

void draw() {
  background(158, 173, 161); // #9eada1
  
  // Draw the figure-8 track
  drawTrack();
  
  // Update path parameter (increased from 0.01 to 0.02 for faster car)
  t += 0.02;
  if (t > TWO_PI) t -= TWO_PI;
  
  // Calculate target position on figure-8
  // Figure-8 parametric equations (lemniscate)
  float scale = 120; // Increased to make track edges touch canvas edges
  float centerX = width / 2;
  float centerY = height / 2;
  
  targetX = centerX + scale * sin(t);
  targetY = centerY + scale * sin(t) * cos(t);
  
  // Check if mouse is held down near car for continuous bumping
  if (mousePressed) {
    float d = dist(mouseX, mouseY, carX, carY);
    if (d < 30) {
      // Calculate bump direction (away from click)
      float bumpAngle = atan2(carY - mouseY, carX - mouseX);
      float bumpForce = 3.0; // Reduced force for continuous application
      
      // Add continuous bump velocity
      bumpVelX += cos(bumpAngle) * bumpForce;
      bumpVelY += sin(bumpAngle) * bumpForce;
      
      // Cap maximum velocity
      float maxVel = 20;
      float velMag = sqrt(bumpVelX * bumpVelX + bumpVelY * bumpVelY);
      if (velMag > maxVel) {
        bumpVelX = (bumpVelX / velMag) * maxVel;
        bumpVelY = (bumpVelY / velMag) * maxVel;
      }
      
      isBumped = true;
    }
  }
  
  // Update bump physics
  if (isBumped) {
    // Apply damping to bump velocity
    bumpVelX *= 0.9;
    bumpVelY *= 0.9;
    bumpOffsetX += bumpVelX;
    bumpOffsetY += bumpVelY;
    
    // Return to track
    bumpOffsetX *= 0.85;
    bumpOffsetY *= 0.85;
    
    // Stop bump when settled
    if (abs(bumpOffsetX) < 0.5 && abs(bumpOffsetY) < 0.5) {
      isBumped = false;
      bumpOffsetX = 0;
      bumpOffsetY = 0;
    }
  }
  
  // Smooth car movement toward target
  if (!isBumped) {
    carX = lerp(carX, targetX, 0.15);
    carY = lerp(carY, targetY, 0.15);
  } else {
    // When bumped, car still tries to follow but with offset
    carX = lerp(carX, targetX + bumpOffsetX, 0.1);
    carY = lerp(carY, targetY + bumpOffsetY, 0.1);
  }
  
  // Calculate car angle based on direction of movement
  float dx = targetX - carX;
  float dy = targetY - carY;
  float targetAngle = atan2(dy, dx);
  carAngle = lerpAngle(carAngle, targetAngle, 0.2);
  
  // Draw the race car
  drawCar(carX, carY, carAngle);
  
  // Draw click radius hint when hovering
  float d = dist(mouseX, mouseY, carX, carY);
  if (d < 30 && !isBumped) {
    noFill();
    stroke(255, 100);
    strokeWeight(1);
    ellipse(carX, carY, 60, 60);
  }
}

void drawTrack() {
  // Draw outer edge of track
  noFill();
  stroke(100, 110, 105);
  strokeWeight(50);
  
  beginShape();
  for (float i = 0; i <= TWO_PI; i += 0.05) {
    float scale = 120; // Increased to make track edges touch canvas edges
    float x = width/2 + scale * sin(i);
    float y = height/2 + scale * sin(i) * cos(i);
    vertex(x, y);
  }
  endShape(CLOSE);
  
  // Draw inner line
  stroke(80, 90, 85);
  strokeWeight(2);
  strokeCap(ROUND);
  
  beginShape();
  for (float i = 0; i <= TWO_PI; i += 0.05) {
    float scale = 120; // Increased to make track edges touch canvas edges
    float x = width/2 + scale * sin(i);
    float y = height/2 + scale * sin(i) * cos(i);
    vertex(x, y);
  }
  endShape(CLOSE);
}

void drawCar(float x, float y, float angle) {
  pushMatrix();
  translate(x, y);
  rotate(angle);
  
  // Car body
  fill(220, 50, 50); // Red
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
  ellipse(-8, 10, 5, 7);
  ellipse(8, -10, 5, 7);
  ellipse(8, 10, 5, 7);
  
  // Racing stripe
  fill(255);
  noStroke();
  rect(-8, -2, 16, 4);
  
  // Headlights
  fill(255, 255, 150);
  ellipse(12, -5, 3, 3);
  ellipse(12, 5, 3, 3);
  
  popMatrix();
  
  // Speed lines when bumped
  if (isBumped && (abs(bumpVelX) > 2 || abs(bumpVelY) > 2)) {
    stroke(255, 150);
    strokeWeight(2);
    for (int i = 0; i < 3; i++) {
      float offsetDist = 15 + i * 8;
      line(x - cos(angle) * offsetDist, y - sin(angle) * offsetDist,
           x - cos(angle) * (offsetDist + 6), y - sin(angle) * (offsetDist + 6));
    }
  }
}

// Helper function to interpolate angles correctly
float lerpAngle(float a, float b, float t) {
  float diff = b - a;
  while (diff > PI) diff -= TWO_PI;
  while (diff < -PI) diff += TWO_PI;
  return a + diff * t;
}