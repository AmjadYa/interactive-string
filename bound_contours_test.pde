import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;

Capture cam;
OpenCV opencv;

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

  // Convert the image to grayscale
  opencv.gray();
 
  opencv.invert();
  opencv.threshold(120);

  // Get a list of contours
  ArrayList<Contour> contours = opencv.findContours();

  // Display the thresholded image
  image(opencv.getOutput(), 0, 0);

  // Draw the bounding boxes for each contour
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
    }
  }
}
