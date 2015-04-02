import com.temboo.core.*;
import com.temboo.Library.Google.Spreadsheets.*;

// Create a session using your Temboo account application details
TembooSession session = new TembooSession("katewallace", "myFirstApp", "f553e5f9236347eab73d3203d52e12f9");

// The name of your Temboo Google Profile 
String googleProfile = "katewallace";

// Declare global variables that will be saved to spreadsheet
int xPos, yPos;
String currentTime;

// Set up color and size of click circles
color clickColor = color(0, 255, 0);
color saveColor = color(255, 0, 0);
int circleSize = 0;

///

//Camera Capture
import processing.video.*;
Capture cam;
int picture; 
PImage img;
boolean camReady = false; 

//Naming Image 
int mo = month();
int d = day(); 
int m = minute();
int s = second(); 

//Buttons 
PImage XButton;
int XButtonXPos, XButtonYPos; 
int XButtonSize; 
boolean XButtonOver;

PImage eatButton;
int eatButtonXPos, eatButtonYPos; 
int eatButtonSize; 
boolean eatButtonOver;

int stage = 0; 
int lastTime = millis();
//font 
PFont font;

//score
int score;

//saving Data 
String scoreList =""+score;
String[] list = split(scoreList, ' ');

void setup() {
  size(500, 700);

  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }

    cam = new Capture(this, cameras[0]);
    cam.start();
  }

  //Buttons 
  eatButton = loadImage("eatButton.png");
  XButton = loadImage("XButton.png");

  XButtonXPos = 270;
  XButtonYPos = 420;
  XButtonSize = 155;

  eatButtonXPos = 70;
  eatButtonYPos = 420;
  eatButtonSize = 155;

  font = loadFont("AvenirNext-Bold-48.vlw");

  score = 0;
} 

void draw() {

  background(#3B97C9); 

  update(mouseX, mouseY);

  image(eatButton, eatButtonXPos, eatButtonYPos);
  image(XButton, XButtonXPos, XButtonYPos);


  if ( XButtonOver) {
    if (mousePressed) {
      fill(#ffffff, 50);
      noStroke();
      image(XButton, XButtonXPos, XButtonYPos);
      rect(XButtonXPos, XButtonYPos, XButtonSize, XButtonSize, 7);

      // Change cursor to wait
      cursor(WAIT);

      // Get x and y position values of click
      xPos = mouseX;
      yPos = mouseY;

      // Draw circle where click occurred
      fill(clickColor);
      ellipse(xPos, yPos, circleSize, circleSize);
    }
  }

  if ( eatButtonOver) {
    fill(#ffffff, 50);
    noStroke();
    image(eatButton, eatButtonXPos, eatButtonYPos);
    rect(eatButtonXPos, eatButtonYPos, eatButtonSize, eatButtonSize, 7);

    if (mousePressed) {
      if (cam.available() == true) {
        cam.read();
      }
      image(cam, 0, 0);
      cam.stop();
      save("food" + "/" + score + mo + d + m + s + ".jpg" );

      // Change cursor to wait
      cursor(WAIT);

      // Get x and y position values of click
      xPos = mouseX;
      yPos = mouseY;

      // Draw circle where click occurred
      fill(clickColor);
      ellipse(xPos, yPos, circleSize, circleSize);
    }
  }

  saveStrings("score.txt", list);



  //telling you when to eat 
  switchNotifications();

  //scoreBoard 
  noStroke();
  fill(#93C8E6);
  rect(100, 170, 300, 200, 7);
  fill(255);
  textFont(font);
  textSize(50);
  text(score, width/2 - 25, 275);
  textSize(25);
  text("reward points", 125, 320);
}



void switchNotifications() {

  int m = minute();  // Values from 0 - 59
  int h = hour();    // Values from 0 - 23

  if (h == 8 && m == 0) {
    notificationRect();
  } else if (h == 10 && m == 0) {
    notificationRect();
  } else if (h == 12 && m == 30) {
    notificationRect();
  } else if (h == 15 && m == 30) {
    notificationRect();
  } else if (h == 17 && m == 47) {
    notificationRect();
  } else if (h == 21 && m == 0) {
    notificationRect();
  } else {
  }
}

void notificationRect() {
  fill(#000000);
  textFont(font, 32);
  text("Record Your Meal", 45, height/2); 
  noStroke();
  fill(#E8F6FD, 80);
  rect(25, height/3, width-50, height/3);
}



void update(int x, int y) {
  if ( XButtonOver(XButtonXPos, XButtonYPos, XButtonSize, XButtonSize) ) {
    XButtonOver = true;
    eatButtonOver = false;
  } else if ( eatButtonOver(eatButtonXPos, eatButtonYPos, eatButtonSize, eatButtonSize) ) {
    eatButtonOver = true;
    XButtonOver = false;
  } else {
    XButtonOver = eatButtonOver = false;
  }
}

boolean XButtonOver(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && 
    mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

boolean eatButtonOver(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && 
    mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}


//scoring system 

void mouseReleased() {
  if ( eatButtonOver) {
    // Write an in-progress message to console
    println("Writing to your Google Spreadsheet..."); 

    // Get current time
    currentTime = year()+"/"+month()+"/"+day()+" "+hour()+":"+minute()+":"+second()+"."+millis();

    // Run the AppendRow Choreo function
    runAppendRowChoreo();

    // Write a finished message to console
    println("done!");

    // Change cursor back to normal
    cursor(ARROW);

    score += 10;
  } else if ( XButtonOver) {

    // Get current time
    currentTime = year()+"/"+month()+"/"+day()+" "+hour()+":"+minute()+":"+second()+"."+millis();

    // Run the AppendRow Choreo function
    runAppendRowChoreo();

    // Write a finished message to console
    println("done!");

    // Change cursor back to normal
    cursor(ARROW);

    score -= 10;
  }
}

void runAppendRowChoreo() {
  // Create the Choreo object using your Temboo session
  AppendRow appendRowChoreo = new AppendRow(session);

  // Set Profile
  appendRowChoreo.setCredential(googleProfile);

  // Set inputs

  if ( eatButtonOver) {
    appendRowChoreo.setRowData(currentTime + "," + (score + 10));
    appendRowChoreo.setSpreadsheetTitle("mouseClicks");
  } else if (XButtonOver) {
    appendRowChoreo.setRowData(currentTime + "," + (score - 10));
    appendRowChoreo.setSpreadsheetTitle("mouseClicks");
  }
  // Run the Choreo and store the results
  AppendRowResultSet appendRowResults = appendRowChoreo.run();
}

