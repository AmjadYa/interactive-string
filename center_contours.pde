import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;

Capture cam;
OpenCV opencv;
boolean indicatorOn = false;

void setup() {
  size(640, 480);
  
  // Initialize the camera
  cam = new Capture(this, 640, 480);
  cam.start();

  // Initialize OpenCV with the same dimensions as the camera
  opencv = new OpenCV(this, 640, 480);
}

void draw() {
  if (cam.available()) {
    cam.read(); // Read the camera frame
  }

  // Load the camera frame into OpenCV
  opencv.loadImage(cam);

  // Process the image: convert to grayscale, invert and threshold
  opencv.gray();
  opencv.invert();
  opencv.threshold(120);

  // Get a list of contours
  ArrayList<Contour> contours = opencv.findContours();

  // Display the thresholded image
  image(opencv.getOutput(), 0, 0);

  // Reset the indicator flag before checking contours
  indicatorOn = false;

  // Draw bounding boxes for each contour and check if any is near the center
  noFill();
  stroke(0, 255, 0);
  strokeWeight(2);
  for (Contour contour : contours) {
    if (contour.area() > 10) { // Ignore small areas to reduce noise
      // Get the bounding box as a Rectangle
      Rectangle boundingBox = contour.getBoundingBox();
      float x = (float) boundingBox.getX();
      float y = (float) boundingBox.getY();
      float w = (float) boundingBox.getWidth();
      float h = (float) boundingBox.getHeight();

      // Draw the bounding box
      rect(x, y, w, h);

      // Calculate the center of the contour's bounding box
      float contourCenterX = x + w / 2;
      float contourCenterY = y + h / 2;

      // Define tolerance for being "near" the absolute center of the screen
      float tolerance = 50; // Adjust this value as needed

      // Check if the contour's center is within the tolerance of the screen's center
      // and ensure the contour is relatively small
      if (abs(contourCenterX - width / 2) < tolerance &&
          abs(contourCenterY - height / 2) < tolerance &&
          w < 100 && h < 100) {  // You can adjust size thresholds as needed
        indicatorOn = true;
      }
    }
  }

  // Draw an indicator (circle) on the screen: green if detected, red otherwise
  int indicatorSize = 50;
  noStroke();
  if (indicatorOn) {
    fill(0, 255, 0); // Green indicates detection
  } else {
    fill(255, 0, 0); // Red indicates no detection
  }
  ellipse(width - indicatorSize/2 - 10, indicatorSize/2 + 10, indicatorSize, indicatorSize);
}
