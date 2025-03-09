import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;
import processing.sound.*;

// --- CAMERA & DETECTION VARIABLES ---
Capture cam;
OpenCV opencv;
boolean indicatorOn = false; // flag for a small contour detected near center
boolean previousDetection = false; // used to trigger only on new events

// --- GUITAR STRING SIMULATION VARIABLES ---
SinOsc[] chordOscs;
float[] chordFreqs;
float[] currentAmps;
float[] targetAmps;
int numOscs = 11;

// Global variable to track the current chord (no chord = -1)
int currentChordIndex = -1;
float masterVolume = 0.5;

// Chord pool (each sub-array contains chord frequencies in Hz)
float[][] chordPool = {
  // ===============================
  // Original Chords
  // ===============================
  {329.63, 415.30, 493.88, 587.33, 783.99, 0},
  {261.63, 370.00, 466.16, 329.63, 440.00, 293.66},
  {261.63, 329.63, 392.00, 370.00, 466.16, 554.37},
  {261.63, 329.63, 392.00, 293.66, 370.00, 440.00},
  {261.63, 329.63, 392.00, 466.16, 293.66, 370.00},
  {261.63, 329.63, 392.00, 493.88, 0, 0},
  {261.63, 311.13, 392.00, 466.16, 0, 0},
  {261.63, 329.63, 392.00, 466.16, 0, 0},
  {261.63, 311.13, 369.99, 466.16, 0, 0},
  {261.63, 311.13, 369.99, 207.65, 0, 0},
  {261.63, 329.63, 415.30, 493.88, 0, 0},
  {261.63, 293.66, 392.00, 0, 0, 0},
  {261.63, 349.23, 392.00, 0, 0, 0},
  {261.63, 329.63, 392.00, 293.66, 0, 0},
  {261.63, 329.63, 392.00, 440.00, 0, 0},
  {261.63, 311.13, 392.00, 493.88, 0, 0},
  {261.63, 329.63, 392.00, 466.16, 293.66, 0},
  {261.63, 329.63, 392.00, 466.16, 293.66, 440.00},
  {261.63, 329.63, 392.00, 466.16, 370.00, 0},
  {261.63, 329.63, 392.00, 466.16, 277.18, 369.99},
  {261.63, 329.63, 392.00, 466.16, 277.18, 311.13},
  {261.63, 293.66, 329.63, 369.99, 415.30, 466.16},
  {261.63, 349.23, 466.16, 622.25f, 0, 0},
  {261.63, 311.13, 369.99, 392.00, 0, 0},
  {261.63, 311.13, 349.23, 415.30, 0, 0},
  {261.63, 311.13, 369.99, 392.00, 0, 0},
  {261.63, 277.18, 329.63, 349.23, 415.30, 440.00},
  {261.63, 277.18, 329.63, 369.99, 415.30, 493.88},
  {261.63, 329.63, 392.00, 493.88, 370.00, 0},
  {261.63, 311.13, 392.00, 466.16, 293.66, 0},
  {261.63, 311.13, 392.00, 466.16, 293.66, 349.23},
  // ===============================
  // Easy Chords
  // ===============================
  {261.63, 329.63, 392.00, 0, 0, 0}, // C Major
  {293.66, 369.99, 440.00, 0, 0, 0}, // D Major
  {329.63, 415.30, 493.88, 0, 0, 0}, // E Major
  {349.23, 440.00, 523.25, 0, 0, 0}, // F Major
  {392.00, 493.88, 587.33, 0, 0, 0}, // G Major
  {440.00, 554.37, 659.26, 0, 0, 0}, // A Major
  {493.88, 622.25, 739.99, 0, 0, 0}, // B Major
  {261.63, 311.13, 392.00, 0, 0, 0}, // C Minor
  {293.66, 349.23, 440.00, 0, 0, 0}, // D Minor
  {329.63, 392.00, 493.88, 0, 0, 0}, // E Minor
  {349.23, 415.30, 523.25, 0, 0, 0}, // F Minor
  {392.00, 466.16, 587.33, 0, 0, 0}, // G Minor
  {440.00, 523.25, 659.26, 0, 0, 0}, // A Minor
  {493.88, 587.33, 739.99, 0, 0, 0}, // B Minor
  {261.63, 392.00, 0, 0, 0, 0}, // C5
  {293.66, 440.00, 0, 0, 0, 0}, // D5
  {329.63, 493.88, 0, 0, 0, 0}, // E5
  {349.23, 523.25, 0, 0, 0, 0}, // F5
  {392.00, 587.33, 0, 0, 0, 0}, // G5
  {440.00, 659.26, 0, 0, 0, 0}, // A5
  {493.88, 739.99, 0, 0, 0, 0}, // B5
  {261.63, 293.66, 392.00, 0, 0, 0}, // Csus2
  {261.63, 349.23, 392.00, 0, 0, 0}, // Csus4
  {261.63, 329.63, 392.00, 466.16, 0, 0}, // C7
  {261.63, 311.13, 392.00, 466.16, 0, 0}, // Cm7
  {261.63, 329.63, 392.00, 0, 0, 0}, // I - C Major
  {349.23, 440.00, 523.25, 0, 0, 0}, // IV - F Major
  {392.00, 493.88, 587.33, 0, 0, 0}, // V - G Major
  // ===============================
  // (Additional chords omitted for brevity; include as desired)
};

// String parameters
float centerY;        
float amplitude = 0.0;    
float dampening = 0.98;  
float pluckX = 0;  

// Particles for visualization
ArrayList<Particle> particles = new ArrayList<Particle>();

void setup() {
  size(1600, 900);
  
  // --- Initialize camera ---
  cam = new Capture(this, 1600, 900);
  cam.start();
  opencv = new OpenCV(this, 1600, 900);
  
  // --- Initialize guitar simulation ---
  centerY = height / 2.0;
  chordOscs   = new SinOsc[numOscs];
  chordFreqs  = new float[numOscs];
  currentAmps = new float[numOscs];
  targetAmps  = new float[numOscs];
  for (int i = 0; i < numOscs; i++) {
    chordOscs[i] = new SinOsc(this);
    chordOscs[i].freq(0);
    chordOscs[i].amp(0);
    chordOscs[i].play(); 
    chordFreqs[i]  = 0;
    currentAmps[i] = 0;
    targetAmps[i]  = 0;
  }
  smooth();
}

void draw() {
  // Clear background for the simulation
  background(248, 248, 240);
  
  // --- CAMERA PROCESSING & CONTOUR DETECTION ---
  if (cam.available()) {
    cam.read();
  }
  opencv.loadImage(cam);
  opencv.gray();
  opencv.invert();
  opencv.threshold(120);
  
  ArrayList<Contour> contours = opencv.findContours();
  indicatorOn = false;
  float detectedX = -1;
  for (Contour contour : contours) {
    if (contour.area() > 10) { // Filter out noise
      Rectangle boundingBox = contour.getBoundingBox();
      float x = (float) boundingBox.getX();
      float y = (float) boundingBox.getY();
      float w = (float) boundingBox.getWidth();
      float h = (float) boundingBox.getHeight();
      
      // Calculate contour center
      float contourCenterX = x + w / 2;
      float contourCenterY = y + h / 2;
      
      float tolerance = 50; // How near to the center?
      if (abs(contourCenterX - width / 2) < tolerance &&
          abs(contourCenterY - height / 2) < tolerance &&
          w < 100 && h < 100) {
        indicatorOn = true;
        detectedX = contourCenterX;
        break;  // Only need one valid detection
      }
    }
  }
  
  // Draw a thumbnail of the thresholded camera feed (upper-left)
  image(opencv.getOutput(), 0, 0, 320, 240);
  
  // Draw an indicator (green if detected, red otherwise) in the top right
  int indicatorSize = 50;
  noStroke();
  if (indicatorOn) fill(0, 255, 0);
  else fill(255, 0, 0);
  ellipse(width - indicatorSize/2 - 10, indicatorSize/2 + 10, indicatorSize, indicatorSize);
  
  // --- TRIGGER THE GUITAR STRING ---
  // If a valid contour appears (and it wasn’t already detected last frame)
  if (indicatorOn && !previousDetection) {
    pluckString(detectedX);
  }
  previousDetection = indicatorOn;
  
  // --- UPDATE THE GUITAR SIMULATION ---
  amplitude *= dampening;
  float mappedAmp = map(amplitude, 0, 15, 0, 0.2);
  mappedAmp = max(mappedAmp, 0);
  
  int activeOscs = 0;
  for (int i = 0; i < numOscs; i++) {
    if (chordFreqs[i] > 0) activeOscs++;
  }
  if (activeOscs == 0) activeOscs = 1;
  float scaledMasterVolume = masterVolume / (activeOscs + 10);
  
  for (int i = 0; i < numOscs; i++) {
    if (chordFreqs[i] > 0) {
      targetAmps[i] = mappedAmp * scaledMasterVolume;
    } else {
      targetAmps[i] = 0;
    }
    currentAmps[i] = lerp(currentAmps[i], targetAmps[i], 0.1);
    chordOscs[i].amp(currentAmps[i]);
  }
  
  drawVibratingString();
  updateParticles();
}

// ----------------------------------------------------------------
//         P L U C K   S T R I N G (TRIGGERED BY DETECTION)
// ----------------------------------------------------------------
void pluckString(float xLocation) {
  amplitude = 15; 
  pluckX = xLocation;
  
  // Choose next chord based on current chord and transition strategies
  int nextIndex = getNextChordIndex(currentChordIndex);
  currentChordIndex = nextIndex;
  
  float[] chosenChord = chordPool[currentChordIndex];
  for (int i = 0; i < numOscs; i++) {
    float freqVal = 0;
    if (i < chosenChord.length) {
      freqVal = chosenChord[i];
    }
    chordFreqs[i] = freqVal;
    chordOscs[i].freq(freqVal);
  }
  
  // Spawn particles for visual effect
  for (int i = 0; i < 30; i++) {
    float randX = random(width);
    particles.add(new Particle(randX, centerY));
  }
}

// ----------------------------------------------------------------
//              DRAW THE VIBRATING STRING
// ----------------------------------------------------------------
void drawVibratingString() {
  stroke(220);
  strokeWeight(5);
  noFill();
  
  float waveWidth = width;
  beginShape();
  for (int x = 0; x <= width; x += 5) {
    float distX = abs(x - pluckX);
    float distanceFactor = 1.0 - distX / waveWidth;
    distanceFactor = constrain(distanceFactor, 0, 1);
    float t = map(x, 0, width, 0, TWO_PI);
    float yOffset = amplitude * distanceFactor * sin(t + frameCount * 0.4);
    vertex(x, centerY + yOffset);
  }
  endShape();
}

// ----------------------------------------------------------------
//                   PARTICLE SYSTEM
// ----------------------------------------------------------------
void updateParticles() {
  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    p.display();
    if (p.isDead()) {
      particles.remove(i);
    }
  }
}

class Particle {
  float x, y;
  float vx, vy;
  float alpha;
  
  Particle(float x, float y) {
    this.x = x;
    this.y = y;
    vx = random(-1, 1);
    vy = random(-2, -0.5);
    alpha = 255;
  }
  
  void update() {
    x += vx;
    y += vy;
    alpha -= 5;
  }
  
  void display() {
    noStroke();
    fill(255, alpha);
    ellipse(x, y, 5, 5);
  }
  
  boolean isDead() {
    return alpha <= 0;
  }
}

// ----------------------------------------------------------------
//        THEORY-DRIVEN CHORD TRANSITION FUNCTIONS
// ----------------------------------------------------------------
int getNextChordIndex(int currentIndex) {
  if (currentIndex < 0 || currentIndex >= chordPool.length) {
    return pickRandomNonEmptyChord();
  }
  if (random(1) < 0.15) {
    println("===== BREAKOUT! Picking random chord + new strategy. =====");
    return pickRandomNonEmptyChord();
  }
  int strategy = int(random(7)); // 0..6
  int nextIndex = -1;
  switch(strategy) {
    case 0:
      nextIndex = findParallelMotionChord(currentIndex);
      break;
    case 1:
      nextIndex = findModalInterchangeChord(currentIndex);
      break;
    case 2:
      nextIndex = findDiminishedPivotChord(currentIndex);
      break;
    case 3:
      nextIndex = findTritoneSubstitutionChord(currentIndex);
      break;
    case 4:
      nextIndex = findSubdominantResolutionChord(currentIndex);
      break;
    case 5:
      nextIndex = findDominantResolutionChord(currentIndex);
      break;
    case 6:
      nextIndex = findStepwiseResolutionChord(currentIndex);
      break;
  }
  if (nextIndex < 0) {
    nextIndex = pickRandomNonEmptyChord();
  }
  return nextIndex;
}

int pickRandomNonEmptyChord() {
  ArrayList<Integer> validIndices = new ArrayList<Integer>();
  for (int i = 0; i < chordPool.length; i++) {
    if (!chordIsAllZero(chordPool[i])) {
      validIndices.add(i);
    }
  }
  if (validIndices.size() == 0) {
    return 0;
  }
  int idx = int(random(validIndices.size()));
  return validIndices.get(idx);
}

boolean chordIsAllZero(float[] chord) {
  for (float f : chord) {
    if (f > 1.0) {
      return false;
    }
  }
  return true;
}

float getChordRootFreq(float[] chord) {
  float minFreq = Float.MAX_VALUE;
  for (float f : chord) {
    if (f > 1.0 && f < minFreq) {
      minFreq = f;
    }
  }
  if (minFreq == Float.MAX_VALUE) {
    return -1;
  }
  return minFreq;
}

float freqToSemitone(float freq) {
  float base = 261.63; // C4 reference
  if (freq <= 0) return 0;
  return 12 * log(freq / base) / log(2);
}

float semitoneDistance(float freq1, float freq2) {
  return abs(freqToSemitone(freq1) - freqToSemitone(freq2));
}

int findParallelMotionChord(int currentIndex) {
  float[] chordA = chordPool[currentIndex];
  float rootA = getChordRootFreq(chordA);
  if (rootA < 0) return -1;
  
  float nextAboveRootA = 0;
  for (float f : chordA) {
    if (f > rootA + 1) {
      nextAboveRootA = f;
      break;
    }
  }
  if (nextAboveRootA <= 0) return -1;
  float intervalA = semitoneDistance(rootA, nextAboveRootA);
  
  ArrayList<Integer> candidates = new ArrayList<Integer>();
  for (int i = 0; i < chordPool.length; i++) {
    if (i == currentIndex) continue;
    float[] cB = chordPool[i];
    float rootB = getChordRootFreq(cB);
    if (rootB < 0) continue;
    
    float nextAboveRootB = 0;
    for (float f : cB) {
      if (f > rootB + 1) {
        nextAboveRootB = f;
        break;
      }
    }
    if (nextAboveRootB > 0) {
      float intervalB = semitoneDistance(rootB, nextAboveRootB);
      if (abs(intervalA - intervalB) < 0.5) {
        candidates.add(i);
      }
    }
  }
  if (candidates.size() == 0) return -1;
  return candidates.get(int(random(candidates.size())));
}

int findModalInterchangeChord(int currentIndex) {
  float[] chordA = chordPool[currentIndex];
  float rootA = getChordRootFreq(chordA);
  if (rootA < 0) return -1;
  
  boolean isMajorA = isProbablyMajor(chordA, rootA);
  ArrayList<Integer> candidates = new ArrayList<Integer>();
  for (int i = 0; i < chordPool.length; i++) {
    if (i == currentIndex) continue;
    float[] cB = chordPool[i];
    float rootB = getChordRootFreq(cB);
    if (abs(rootA - rootB) < 1.0) {
      boolean isMajorB = isProbablyMajor(cB, rootB);
      if (isMajorA != isMajorB) {
        candidates.add(i);
      }
    }
  }
  if (candidates.size() == 0) return -1;
  return candidates.get(int(random(candidates.size())));
}

boolean isProbablyMajor(float[] chord, float rootFreq) {
  for (float f : chord) {
    if (f <= rootFreq + 1) continue;
    float dist = semitoneDistance(rootFreq, f);
    if (abs(dist - 4) < 1.0) return true;
    if (abs(dist - 3) < 1.0) return false;
  }
  return true;
}

int findDiminishedPivotChord(int currentIndex) {
  float[] chordA = chordPool[currentIndex];
  float rootA = getChordRootFreq(chordA);
  if (rootA < 0) return -1;
  
  ArrayList<Integer> candidates = new ArrayList<Integer>();
  for (int i = 0; i < chordPool.length; i++) {
    if (isDiminishedChord(chordPool[i])) {
      candidates.add(i);
    }
  }
  if (candidates.size() == 0) return -1;
  return candidates.get(int(random(candidates.size())));
}

boolean isDiminishedChord(float[] chord) {
  float root = getChordRootFreq(chord);
  if (root < 0) return false;
  boolean found3 = false;
  boolean found6 = false;
  for (float f : chord) {
    if (f <= root + 1) continue;
    float dist = semitoneDistance(root, f);
    if (abs(dist - 3) < 1.0) found3 = true;
    if (abs(dist - 6) < 1.0) found6 = true;
  }
  return (found3 && found6);
}

int findTritoneSubstitutionChord(int currentIndex) {
  float[] chordA = chordPool[currentIndex];
  float rootA = getChordRootFreq(chordA);
  if (rootA < 0) return -1;
  float semA = freqToSemitone(rootA);
  float semTritone = semA + 6;
  
  ArrayList<Integer> candidates = new ArrayList<Integer>();
  for (int i = 0; i < chordPool.length; i++) {
    if (i == currentIndex) continue;
    float rootB = getChordRootFreq(chordPool[i]);
    if (rootB < 0) continue;
    float semB = freqToSemitone(rootB);
    if (abs(semB - semTritone) < 2.0) {
      candidates.add(i);
    }
  }
  if (candidates.size() == 0) return -1;
  return candidates.get(int(random(candidates.size())));
}

int findSubdominantResolutionChord(int currentIndex) {
  float[] chordA = chordPool[currentIndex];
  float rootA = getChordRootFreq(chordA);
  if (rootA < 0) return -1;
  float semA = freqToSemitone(rootA);
  float semSubdom = semA + 5;
  
  ArrayList<Integer> candidates = new ArrayList<Integer>();
  for (int i = 0; i < chordPool.length; i++) {
    if (i == currentIndex) continue;
    float rootB = getChordRootFreq(chordPool[i]);
    if (rootB < 0) continue;
    float semB = freqToSemitone(rootB);
    if (abs(semB - semSubdom) < 2.0) {
      candidates.add(i);
    }
  }
  if (candidates.size() == 0) return -1;
  return candidates.get(int(random(candidates.size())));
}

int findDominantResolutionChord(int currentIndex) {
  float[] chordA = chordPool[currentIndex];
  float rootA = getChordRootFreq(chordA);
  if (rootA < 0) return -1;
  float semA = freqToSemitone(rootA);
  float semDom = semA + 7;
  
  ArrayList<Integer> candidates = new ArrayList<Integer>();
  for (int i = 0; i < chordPool.length; i++) {
    if (i == currentIndex) continue;
    float rootB = getChordRootFreq(chordPool[i]);
    if (rootB < 0) continue;
    float semB = freqToSemitone(rootB);
    if (abs(semB - semDom) < 2.0) {
      candidates.add(i);
    }
  }
  if (candidates.size() == 0) return -1;
  return candidates.get(int(random(candidates.size())));
}

int findStepwiseResolutionChord(int currentIndex) {
  float[] chordA = chordPool[currentIndex];
  float rootA = getChordRootFreq(chordA);
  if (rootA < 0) return -1;
  float semA = freqToSemitone(rootA);
  
  float upStep = semA + 2;
  float downStep = semA - 2;
  
  ArrayList<Integer> candidates = new ArrayList<Integer>();
  for (int i = 0; i < chordPool.length; i++) {
    if (i == currentIndex) continue;
    float rootB = getChordRootFreq(chordPool[i]);
    if (rootB < 0) continue;
    float semB = freqToSemitone(rootB);
    if (abs(semB - upStep) < 1.0 || abs(semB - downStep) < 1.0) {
      candidates.add(i);
    }
  }
  if (candidates.size() == 0) return -1;
  return candidates.get(int(random(candidates.size())));
}

// ----------------------------------------------------------------
//                    KEY CONTROL (MASTER VOLUME)
// ----------------------------------------------------------------
void keyPressed() {
  if (keyCode == UP) {
    masterVolume += 0.05;
    masterVolume = constrain(masterVolume, 0.0, 1.0);
    println("Master Volume: " + masterVolume);
  } else if (keyCode == DOWN) {
    masterVolume -= 0.05;
    masterVolume = constrain(masterVolume, 0.0, 1.0);
    println("Master Volume: " + masterVolume);
  }
}
