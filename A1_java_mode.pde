import java.util.ArrayList;

// stage
final float groundY = 300;
final float scrollSpeed = 5;
final float genAheadDistance = 1000;

// character
final float playerScreenX = 150;
final float playerSize = 40;
final float gravity = 0.9;
final float jumpForce = -16;

// Game
float playerY = 0;
float playerVelY = 0;
boolean isJumping = false;

float worldOffset = 0;
int score = 0;
String gameState = "PLAYING";  // "PLAYING" or "LOSE"

// barrier
class Obstacle {
  float x;
  float w;
  float h;
  boolean passed;

  Obstacle(float x, float w, float h) {
    this.x = x;
    this.w = w;
    this.h = h;
    this.passed = false;
  }
}

ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();
float nextObstacleX = 400;

PFont thaiFont;

void setup() {
  size(800, 400);
  textAlign(CENTER, CENTER);
  resetGame();
}

void resetGame() {
  playerY = groundY - playerSize;
  playerVelY = 0;
  isJumping = false;

  worldOffset = 0;
  score = 0;
  gameState = "PLAYING";

  obstacles.clear();
  nextObstacleX = 400;
  generateObstacles();
}

void addObstacle(float x) {
  float h = random(30, 60);
  obstacles.add(new Obstacle(x, 30, h));
}

void generateObstacles() {
  while (nextObstacleX < worldOffset + width + genAheadDistance) {
    addObstacle(nextObstacleX);
    nextObstacleX += random(180, 320);
  }
}

void draw() {
  drawBackground();

  if (gameState.equals("PLAYING")) {
    updatePlayer();
    updateWorld();
    checkCollisions();
  }

  drawGround();
  drawObstacles();
  drawPlayer();
  drawHUD();

  if (gameState.equals("LOSE")) {
    drawEndScreen("You lose! click R to start new game", color(200, 60, 60));
  }
}

void updatePlayer() {
  playerVelY += gravity;
  playerY += playerVelY;

  float floorY = groundY - playerSize;
  if (playerY >= floorY) {
    playerY = floorY;
    playerVelY = 0;
    isJumping = false;
  }
}

// ---------- อัปเดตระยะทางโลก / สร้าง-ลบอุปสรรค ----------
void updateWorld() {
  worldOffset += scrollSpeed;

  // นับคะแนนเมื่อผ่านอุปสรรคไปแล้ว
  for (Obstacle o : obstacles) {
    float screenX = o.x - worldOffset;
    if (!o.passed && screenX + o.w < playerScreenX) {
      o.passed = true;
      score++;
    }
  }

  generateObstacles();

  for (int i = obstacles.size() - 1; i >= 0; i--) {
    if (obstacles.get(i).x - worldOffset <= -100) {
      obstacles.remove(i);
    }
  }
}

void checkCollisions() {
  for (Obstacle o : obstacles) {
    float screenX = o.x - worldOffset;

    boolean overlapX = (playerScreenX + playerSize * 0.5 > screenX) &&
                       (playerScreenX - playerSize * 0.5 < screenX + o.w);
    boolean overlapY = playerY + playerSize > groundY - o.h;

    if (overlapX && overlapY) {
      gameState = "LOSE";
    }
  }
}

void jump() {
  if (gameState.equals("PLAYING") && !isJumping) {
    playerVelY = jumpForce;
    isJumping = true;
  }
}

void keyPressed() {
  if (key == ' ') {
    jump();
  }
  if (key == 'r' || key == 'R') {
    resetGame();
  }
}

void mousePressed() {
  jump();}

void drawBackground() {
  background(135, 206, 235); }

void drawGround() {
  noStroke();
  fill(90, 60, 30);
  rect(0, groundY, width, height - groundY);
}

void drawPlayer() {
  fill(255, 200, 0);
  noStroke();
  rectMode(CORNER);
  rect(playerScreenX - playerSize / 2, playerY, playerSize, playerSize, 8);
  fill(0);
  ellipse(playerScreenX + 8, playerY + 14, 6, 6);
}

void drawObstacles() {
  fill(200, 40, 40);
  noStroke();
  for (Obstacle o : obstacles) {
    float screenX = o.x - worldOffset;
    if (screenX > -50 && screenX < width + 50) {
      triangle(screenX, groundY,
               screenX + o.w, groundY,
               screenX + o.w / 2, groundY - o.h);
    }
  }
}

void drawHUD() {
  fill(0);
  textAlign(LEFT, TOP);
  textSize(18);
  text("Score: " + score, 15, 15);
  text("Distance: " + int(worldOffset) + " px", 15, 40);
  textAlign(CENTER, CENTER);
}

void drawEndScreen(String msg, color c) {
  fill(0, 0, 0, 120);
  rect(0, 0, width, height);
  fill(c);
  textSize(32);
  text(msg, width / 2, height / 2 - 20);
  fill(255);
  textSize(18);
  text("Scores: " + score, width / 2, height / 2 + 20);
}
