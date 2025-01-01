/**
 * Single Guitar String Simulation in Processing
 * with Thematically-Driven Chord Transitions + Chance to "Break Out"
 *
 * Features:
 * - Gentle amplitude ramp.
 * - Particles for visualization.
 * - Master volume control.
 * - Thematically chosen chord progressions (not purely random).
 * - 15% chance to "break out" of the chord strategy and pick a random chord.
 */

import processing.sound.*;

SinOsc[] chordOscs;
float[] chordFreqs;
float[] currentAmps;
float[] targetAmps;
int numOscs = 11;

// ========== GLOBAL VARIABLE TO TRACK THE CURRENT CHORD ==========
int currentChordIndex = -1; // -1 means "no chord has been chosen yet"

// Master volume control
float masterVolume = 0.5;

// Potential chords (in Hz)
float[][] chordPool = {
    // ===============================
    // Original Chords
    // ===============================

    // Dominant 7#9 (Hendrix Chord) - E7#9: E, G#, B, D, G
    {329.63f, 415.30f, 493.88f, 587.33f, 783.99f, 0},

    // Mystic Chord - C, F#, Bb, E, A, D
    {261.63f, 370.00f, 466.16f, 329.63f, 440.00f, 293.66f},

    // Petrushka Chord - C major and F# major triads combined
    // C major: C, E, G  |  F# major: F#, A#, C#
    {261.63f, 329.63f, 392.00f, 370.00f, 466.16f, 554.37f},

    // Polychord - C major over D major
    // C major: C, E, G  |  D major: D, F#, A
    {261.63f, 329.63f, 392.00f, 293.66f, 370.00f, 440.00f},

    // Augmented 11th Chord - C, E, G, Bb, D, F#
    {261.63f, 329.63f, 392.00f, 466.16f, 293.66f, 370.00f},

    // Major Seventh (Cmaj7) - C, E, G, B
    {261.63f, 329.63f, 392.00f, 493.88f, 0, 0},

    // Minor Seventh (Cm7) - C, Eb, G, Bb
    {261.63f, 311.13f, 392.00f, 466.16f, 0, 0},

    // Dominant Seventh (C7) - C, E, G, Bb
    {261.63f, 329.63f, 392.00f, 466.16f, 0, 0},

    // Half-Diminished Seventh (Cm7b5) - C, Eb, Gb, Bb
    {261.63f, 311.13f, 369.99f, 466.16f, 0, 0},

    // Diminished Seventh (Cdim7) - C, Eb, Gb, Bbb (A)
    {261.63f, 311.13f, 369.99f, 207.65f, 0, 0},

    // Augmented Major Seventh (CaugMaj7) - C, E, G#, B
    {261.63f, 329.63f, 415.30f, 493.88f, 0, 0},

    // Suspended Second (Csus2) - C, D, G
    {261.63f, 293.66f, 392.00f, 0, 0, 0},

    // Suspended Fourth (Csus4) - C, F, G
    {261.63f, 349.23f, 392.00f, 0, 0, 0},

    // Added Ninth (Cadd9) - C, E, G, D
    {261.63f, 329.63f, 392.00f, 293.66f, 0, 0},

    // Sixth Chord (C6) - C, E, G, A
    {261.63f, 329.63f, 392.00f, 440.00f, 0, 0},

    // Minor Major Seventh (CmMaj7) - C, Eb, G, B
    {261.63f, 311.13f, 392.00f, 493.88f, 0, 0},

    // Dominant Ninth (C9) - C, E, G, Bb, D
    {261.63f, 329.63f, 392.00f, 466.16f, 293.66f, 0},

    // Dominant Thirteenth (C13) - C, E, G, Bb, D, A
    {261.63f, 329.63f, 392.00f, 466.16f, 293.66f, 440.00f},

    // Lydian Dominant (C7#11) - C, E, G, Bb, F#
    {261.63f, 329.63f, 392.00f, 466.16f, 370.00f, 0},

    // Altered Dominant (C7alt) - C, E, G, Bb, Db, Gb
    {261.63f, 329.63f, 392.00f, 466.16f, 277.18f, 369.99f},

    // Hexatonic Blues (C7b9#9) - C, E, G, Bb, Db, D#
    {261.63f, 329.63f, 392.00f, 466.16f, 277.18f, 311.13f},

    // Whole Tone Scale Chord - C, D, E, F#, G#, A#
    {261.63f, 293.66f, 329.63f, 369.99f, 415.30f, 466.16f},

    // Quartal Chord (C, F, Bb, Eb)
    {261.63f, 349.23f, 466.16f, 622.25f, 0, 0},

    // French Sixth (C, Eb, F#, G)
    {261.63f, 311.13f, 369.99f, 392.00f, 0, 0},

    // German Sixth (C, Eb, F, Ab)
    {261.63f, 311.13f, 349.23f, 415.30f, 0, 0},

    // Italian Sixth (C, D#, F#, G)
    {261.63f, 311.13f, 369.99f, 392.00f, 0, 0},

    // Byzantine Scale Chord - C, C#, E, F, G#, A
    {261.63f, 277.18f, 329.63f, 349.23f, 415.30f, 440.00f},

    // Enigmatic Chord - C, Db, E, F#, Ab, B
    {261.63f, 277.18f, 329.63f, 369.99f, 415.30f, 493.88f},

    // Added Sharp Eleventh (Cmaj7#11) - C, E, G, B, F#
    {261.63f, 329.63f, 392.00f, 493.88f, 370.00f, 0},

    // Minor Ninth (Cm9) - C, Eb, G, Bb, D
    {261.63f, 311.13f, 392.00f, 466.16f, 293.66f, 0},

    // Minor Eleventh (Cm11) - C, Eb, G, Bb, D, F
    {261.63f, 311.13f, 392.00f, 466.16f, 293.66f, 349.23f},

    // ===============================
    // Easy Chords
    // ===============================

    // Major Triads
    {261.63f, 329.63f, 392.00f, 0, 0, 0}, // C Major: C, E, G
    {293.66f, 369.99f, 440.00f, 0, 0, 0}, // D Major: D, F#, A
    {329.63f, 415.30f, 493.88f, 0, 0, 0}, // E Major: E, G#, B
    {349.23f, 440.00f, 523.25f, 0, 0, 0}, // F Major: F, A, C
    {392.00f, 493.88f, 587.33f, 0, 0, 0}, // G Major: G, B, D
    {440.00f, 554.37f, 659.26f, 0, 0, 0}, // A Major: A, C#, E
    {493.88f, 622.25f, 739.99f, 0, 0, 0}, // B Major: B, D#, F#

    // Minor Triads
    {261.63f, 311.13f, 392.00f, 0, 0, 0}, // C Minor: C, Eb, G
    {293.66f, 349.23f, 440.00f, 0, 0, 0}, // D Minor: D, F, A
    {329.63f, 392.00f, 493.88f, 0, 0, 0}, // E Minor: E, G, B
    {349.23f, 415.30f, 523.25f, 0, 0, 0}, // F Minor: F, Ab, C
    {392.00f, 466.16f, 587.33f, 0, 0, 0}, // G Minor: G, Bb, D
    {440.00f, 523.25f, 659.26f, 0, 0, 0}, // A Minor: A, C, E
    {493.88f, 587.33f, 739.99f, 0, 0, 0}, // B Minor: B, D, F#

    // Power Chords (Fifth Chords)
    {261.63f, 392.00f, 0, 0, 0, 0}, // C5: C, G
    {293.66f, 440.00f, 0, 0, 0, 0}, // D5: D, A
    {329.63f, 493.88f, 0, 0, 0, 0}, // E5: E, B
    {349.23f, 523.25f, 0, 0, 0, 0}, // F5: F, C
    {392.00f, 587.33f, 0, 0, 0, 0}, // G5: G, D
    {440.00f, 659.26f, 0, 0, 0, 0}, // A5: A, E
    {493.88f, 739.99f, 0, 0, 0, 0}, // B5: B, F#

    // Suspended Chords
    {261.63f, 293.66f, 392.00f, 0, 0, 0}, // Csus2: C, D, G
    {261.63f, 349.23f, 392.00f, 0, 0, 0}, // Csus4: C, F, G

    // Seventh Chords
    {261.63f, 329.63f, 392.00f, 466.16f, 0, 0}, // C7: C, E, G, Bb
    {261.63f, 311.13f, 392.00f, 466.16f, 0, 0}, // Cm7: C, Eb, G, Bb

    // Major Scale Chords (1st, 4th, and 5th degree)
    {261.63f, 329.63f, 392.00f, 0, 0, 0}, // I - C Major: C, E, G
    {349.23f, 440.00f, 523.25f, 0, 0, 0}, // IV - F Major: F, A, C
    {392.00f, 493.88f, 587.33f, 0, 0, 0}, // V - G Major: G, B, D

    // ===============================
    // Stravinsky Chords
    // ===============================

    // Petrushka Polychord - C Major and F# Major
    {261.63f, 329.63f, 392.00f, 370.00f, 466.16f, 554.37f},

    // Octatonic Scale Harmony - C, D, Eb, F, F#, G#, A, B
    {261.63f, 293.66f, 311.13f, 349.23f, 369.99f, 415.30f, 440.00f, 493.88f, 0, 0, 0},

    // Stacked Fourths - Quartal Harmony
    {261.63f, 349.23f, 466.16f, 622.25f, 0, 0},

    // Polychord with Bitonality - C Major over G Major
    {261.63f, 329.63f, 392.00f, 196.00f, 246.94f, 392.00f},

    // Tritone-based Chord - C, E, F#, Bb
    {261.63f, 329.63f, 370.00f, 466.16f, 0, 0},

    // Bi-Modal Harmony - A Minor and F# Major
    {440.00f, 261.63f, 349.23f, 370.00f, 466.16f, 554.37f},

    // Lydian Dominant Harmony
    {261.63f, 329.63f, 392.00f, 466.16f, 370.00f, 0},

    // Stacked Seconds
    {261.63f, 277.18f, 293.66f, 311.13f, 329.63f, 0},

    // Polychord - D Major over Bb Major
    {293.66f, 370.00f, 440.00f, 233.08f, 293.66f, 349.23f},

    // "Rite of Spring" Chord (Eleven-note stack)
    {261.63f, 293.66f, 329.63f, 349.23f, 370.00f, 415.30f, 440.00f, 466.16f, 493.88f, 554.37f, 622.25f},

    // Mystic Chord (Scriabin-inspired but relevant for Stravinsky)
    {261.63f, 370.00f, 466.16f, 329.63f, 440.00f, 293.66f},

    // Whole Tone Scale
    {261.63f, 293.66f, 329.63f, 369.99f, 415.30f, 466.16f},

    // Byzantine Scale Chord - C, C#, E, F, G#, A
    {261.63f, 277.18f, 329.63f, 349.23f, 415.30f, 440.00f},

    // Altered Polychord - C Minor Triad over E Major Triad
    {261.63f, 311.13f, 392.00f, 329.63f, 415.30f, 493.88f},

    // ===============================
    // Additional Non-Equal Division Chords
    // ===============================

    // Microtonal Chord - C, C#, D#, F, G, G#, B
    {261.63f, 277.18f, 311.13f, 349.23f, 392.00f, 415.30f, 493.88f, 0, 0, 0, 0},

    // Multi-Octave Cluster - C2, E3, G4, Bb5
    {65.41f, 164.81f, 392.00f, 932.33f, 0, 0},

    // Asymmetric Spanning Chord - C3, D#4, F#5, A6
    {130.81f, 155.56f, 369.99f, 880.00f, 0, 0},

    // Just Intonation Chord - C, E, G, B
    {261.63f, 327.03f, 392.00f, 493.88f, 0, 0},

    // Non-Equal Octave Chord - C, C, C, C
    {261.63f, 523.25f, 1046.50f, 2093.00f, 0, 0},

    // Custom Cluster - C, C#, D, D#, E, F, F#, G
    {261.63f, 277.18f, 293.66f, 311.13f, 329.63f, 349.23f, 369.99f, 392.00f, 0, 0, 0},
};

// String parameters
float centerY;        
float amplitude = 0.0;    
float dampening = 0.98;  
float hoverThreshold = 10; 
boolean isHovering = false;
float pluckX = 0;  

// Particles
ArrayList<Particle> particles = new ArrayList<Particle>();

void setup() {
  fullScreen(P2D, 2); 
  background(248, 248, 240);

  centerY = height / 2.0;

  // Initialize arrays for oscillators, frequencies, and amplitudes
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
  background(248, 248, 240);

  // Hover detection
  float distFromString = abs(mouseY - centerY);
  if (distFromString < hoverThreshold) {
    if (!isHovering) {
      pluckString(mouseX); 
      isHovering = true;
    }
  } else {
    isHovering = false;
  }

  // Decay amplitude
  amplitude *= dampening;

  // Map amplitude
  float mappedAmp = map(amplitude, 0, 15, 0, 0.2);
  mappedAmp = max(mappedAmp, 0); 

  // Count active oscillators
  int activeOscs = 0;
  for (int i = 0; i < numOscs; i++) {
    if (chordFreqs[i] > 0) {
      activeOscs++;
    }
  }
  if (activeOscs == 0) activeOscs = 1;

  // Scale masterVolume to reduce clipping
  float scaledMasterVolume = masterVolume / (activeOscs + 10);

  // Ramp each oscillator amplitude
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

// ===========================
//   P L U C K   S T R I N G
// ===========================
void pluckString(float xLocation) {
  amplitude = 15; 
  pluckX = xLocation;

  // ========== PICK NEXT CHORD BASED ON PREVIOUS CHORD & THEORY STRATEGY + 15% BREAKOUT ==========
  int nextIndex = getNextChordIndex(currentChordIndex);
  currentChordIndex = nextIndex; // store which chord we just picked

  // Get the chosen chord from chordPool
  float[] chosenChord = chordPool[currentChordIndex];

  // Assign frequencies to our chord oscillators
  for (int i = 0; i < numOscs; i++) {
    float freqVal = 0;
    if (i < chosenChord.length) {
      freqVal = chosenChord[i];
    }
    chordFreqs[i] = freqVal;
    chordOscs[i].freq(freqVal);
  }

  // Spawn particles along the string
  for (int i = 0; i < 30; i++) {
    float randX = random(width);
    particles.add(new Particle(randX, centerY));
  }
}

// ===========================
//   D R A W   S T R I N G
// ===========================
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

// ===========================
//   P A R T I C L E S
// ===========================
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

// ===========================
//  K E Y   P R E S S E D
// ===========================
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

// =====================================================================
//         T H E M A T I C   C H O R D   T R A N S I T I O N S
// =====================================================================
/**
 * getNextChordIndex() returns the index of the chord we want to play next,
 * given the current chord's index. It randomly picks one of seven
 * "strategies" (parallel motion, modal interchange, diminished pivot chord,
 * tritone sub, subdominant resolution, dominant resolution, stepwise resolution),
 * BUT there's also a 15% chance to "break out" entirely and pick a random chord.
 */
int getNextChordIndex(int currentIndex) {
  // If no chord has been chosen yet, just pick a valid chord at random.
  if (currentIndex < 0 || currentIndex >= chordPool.length) {
    return pickRandomNonEmptyChord();
  }

  // -----------------------------------------
  // 15% CHANCE TO BREAK OUT OF THE STRATEGY
  // -----------------------------------------
  if (random(1) < 0.15) {
    println("===== BREAKOUT! Picking random chord + new strategy. =====");
    return pickRandomNonEmptyChord();
  }

  // Otherwise, proceed with theory-based transition
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

  // If the chosen strategy couldn't find a chord, pick random
  if (nextIndex < 0) {
    nextIndex = pickRandomNonEmptyChord();
  }
  return nextIndex;
}

/**
 * pickRandomNonEmptyChord() picks a chord from chordPool that isn't "all zeros."
 */
int pickRandomNonEmptyChord() {
  ArrayList<Integer> validIndices = new ArrayList<Integer>();
  for (int i = 0; i < chordPool.length; i++) {
    if (!chordIsAllZero(chordPool[i])) {
      validIndices.add(i);
    }
  }
  if (validIndices.size() == 0) {
    // fallback
    return 0;
  }
  int idx = int(random(validIndices.size()));
  return validIndices.get(idx);
}

/**
 * chordIsAllZero() checks if a chord has no nonzero frequencies.
 */
boolean chordIsAllZero(float[] chord) {
  for (float f : chord) {
    if (f > 1.0) {
      return false;
    }
  }
  return true;
}

/**
 * getChordRootFreq() returns the lowest nonzero frequency in the chord as the "root."
 */
float getChordRootFreq(float[] chord) {
  float minFreq = Float.MAX_VALUE;
  for (float f : chord) {
    if (f > 1.0 && f < minFreq) {
      minFreq = f;
    }
  }
  if (minFreq == Float.MAX_VALUE) {
    return -1; // chord was empty
  }
  return minFreq;
}

/**
 * Approximate "semitones above reference" from a frequency.
 */
float freqToSemitone(float freq) {
  float base = 261.63f; // C4 reference
  if (freq <= 0) return 0;
  return 12 * log(freq / base) / log(2);
}

/**
 * semitoneDistance() gets the difference in semitones between freq1 and freq2.
 */
float semitoneDistance(float freq1, float freq2) {
  return abs(freqToSemitone(freq1) - freqToSemitone(freq2));
}

// =================================================================
//      E X A M P L E   S T R A T E G Y   F U N C T I O N S
// =================================================================
int findParallelMotionChord(int currentIndex) {
  float[] chordA = chordPool[currentIndex];
  float rootA = getChordRootFreq(chordA);
  if (rootA < 0) return -1;

  // find a second note above root
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
      // Check if intervals are close => parallel
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
      // Opposite tonality
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
    if (abs(dist - 4) < 1.0) return true;  // ~Major 3rd
    if (abs(dist - 3) < 1.0) return false; // ~Minor 3rd
  }
  // default guess
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
    if (f <= root+1) continue;
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
  float semTritone = semA + 6; // half an octave up

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
  float semSubdom = semA + 5; // perfect 4th up

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
  float semDom = semA + 7; // perfect 5th up

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
