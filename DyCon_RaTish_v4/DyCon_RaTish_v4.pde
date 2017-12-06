import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

PImage one, two, three;

ArrayList<PVector> staff1_vertices = new ArrayList<PVector>();
ArrayList<PVector> staff2_vertices = new ArrayList<PVector>();

// document margins around staves
int margin = 50;
int staff_leftMargin;
int staff_rightMargin;
int staff1_topMargin;
int staff2_topMargin;
int staff1_bottomMargin;
int staff2_bottomMargin;

// These values are used to change the tracking pitch line, both current and new
int setIndex = 0;
int setPitch;
int addPitch;

float staff_height;
float staff_width;

ArrayList<Integer> staff1_morphology = new ArrayList<Integer>();
ArrayList<Integer> staff2_morphology = new ArrayList<Integer>();
ArrayList<Integer> staff1_morphology_tracking = new ArrayList<Integer>();
ArrayList<Integer> staff2_morphology_tracking = new ArrayList<Integer>();

int[] gamaka_array_staff1 = new int[15];
int[] gamaka_array_staff2 = new int[15];

int drawStaffLines = 0; //turn off and on the staff lines

//int morphGrey = 20;

int numberOfSvara_staff1_osc; // For some reason it seems necissary to declare a new variable
int numberOfSvara_staff2_osc; // to hold the OSC value. Later set to the other numSvara_staff.

String staff1_morphList = "0 11 3 4 6 3";
String staff2_morphList = "0 11 3 4 6 3";
//String staff1_morphList_tracking = "0 11 3 4 6 3";
//String staff2_morphList_tracking = "0 11 3 4 6 3";

String gamaka_staff1 = "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0";
String gamaka_staff2 = "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0";

/* How many lines devide each staff?
   These values are initialized as a large arbitrary number to set a "buffer size" 
   for the array. Later these values are changed dynamicly in the void draw() 
*/
int numberOfStaffLines = 100;

/* How many notes are on each staff?
   These values are initialized as a large arbitrary number to set a "buffer size" 
   for the array. Later these values are changed dynamicly in the void draw() 
 */
int numberOfSvara_staff1 = 100;
int numberOfSvara_staff2 = 100;

// create two arrays to hold the location of each staff line
float[] y_staff1 = new float[numberOfStaffLines];
float[] y_staff2 = new float[numberOfStaffLines];

float[] x_staff1 = new float[numberOfSvara_staff1];
float[] x_staff2 = new float[numberOfSvara_staff2];

// two variable used to read coordinates into the "vertices" PVector arrays
PVector staff1_v;
PVector staff2_v;

//**********************************************************************************************************
// ------- SETUP SECTION -------
//**********************************************************************************************************

void setup () {
  size(1365, 715);
  oscP5 = new OscP5(this, 8000);
  
  staff1_morphology_tracking = new ArrayList();
  staff1_morphology_tracking.add(null);
  staff1_morphology_tracking.set(setIndex, setPitch);

  staff2_morphology_tracking = new ArrayList();
  staff2_morphology_tracking.add(null);
  staff2_morphology_tracking.set(setIndex, setPitch);
  
  one = loadImage("one.png");
  two = loadImage("two.png");
  three = loadImage("three.png");

}

//**********************************************************************************************************
// ------- DRAW SECTION -------
//**********************************************************************************************************

void draw () {
  background(255);
  
  // set the document margins
  // comment-out this line to set margin via OSC
  // -------------------------------------------------------------------------------------------------------
  // margin = 50;
  // -------------------------------------------------------------------------------------------------------
  
  
  // Morphologies are sent through OSC via space delimited strings. This code first clears the ArrayLists,
  // then each string is read into indices of the array one number at a time.
  // -------------------------------------------------------------------------------------------------------

  staff1_morphology.clear();
  staff2_morphology.clear();
  //staff1_morphology_tracking.clear();
  //staff2_morphology_tracking.clear();
  
  String[] parts = staff1_morphList.split(" ");
  for (String part : parts) {
    staff1_morphology.add(new Integer(part));
  }
  String[] parts2 = staff2_morphList.split(" ");
  for (String part : parts2) {
    staff2_morphology.add(new Integer(part));
  }
  //String[] parts3 = staff1_morphList_tracking.split(" ");
  //for (String part : parts3) {
    //staff1_morphology_tracking.add(new Integer(part));
  //}
  //String[] parts4 = staff2_morphList_tracking.split(" ");
  //for (String part : parts4) {
    //staff2_morphology_tracking.add(new Integer(part));
  //}

  // -------------------------------------------------------------------------------------------------------
  
  String[] gamaka_string1 = gamaka_staff1.split(" ");
  for (int i=0; i < 15; i++) {
    gamaka_array_staff1[i] = int(gamaka_string1[i]);
  } 
  String[] gamaka_string2 = gamaka_staff2.split(" ");
  for (int i=0; i < 15; i++) {
    gamaka_array_staff2[i] = int(gamaka_string2[i]);
  }  
  
  
  if (staff2_morphology_tracking.size() < 2) {
      staff1_morphology_tracking.set(setIndex, setPitch);
      }
  else {
      staff2_morphology_tracking.set(setIndex, setPitch);
      }
  
  
  


  //set variables for document margins
  // -------------------------------------------------------------------------------------------------------
  staff_leftMargin = 0 + margin;
  staff_rightMargin = width - margin;
  staff1_topMargin = 0 + margin;
  staff2_topMargin = (height/2) + margin;
  staff1_bottomMargin = (height/2) - margin;
  staff2_bottomMargin = height - margin;
  staff_height = abs(staff1_topMargin - staff1_bottomMargin);
  staff_width = abs(staff_rightMargin - staff_leftMargin);
  // -------------------------------------------------------------------------------------------------------
   
  // how many lines devide each staff?
  // -------------------------------------------------------------------------------------------------------
  // numberOfStaffLines = 7;
  // -------------------------------------------------------------------------------------------------------
  
  // how many notes are on each staff?
  // -------------------------------------------------------------------------------------------------------
  numberOfSvara_staff1 = numberOfSvara_staff1_osc; // MUST be greater than "staff1_morphology.length"
  numberOfSvara_staff2 = numberOfSvara_staff2_osc;  // MUST be greater than "staff_morphology.length"
  // -------------------------------------------------------------------------------------------------------
  
  // Read matrix values into an array
  // -------------------------------------------------------------------------------------------------------
  readStaffAndSvaraIntoArray(numberOfStaffLines, numberOfSvara_staff1, numberOfSvara_staff2, 
     staff1_bottomMargin, staff2_bottomMargin, staff_leftMargin, staff_height, staff_width);
  // -------------------------------------------------------------------------------------------------------
  
  // Read the various x-y points into PVector arrays called "staff1_vertices" and "staff2_vertices."
  // -------------------------------------------------------------------------------------------------------
  staff1_vertices.clear(); // These ".clear" statments are very very VERY important. Without this the PVector 
  staff2_vertices.clear(); // meirly ADDS a new vertex to the array...
  readIntoPVector();
  // -------------------------------------------------------------------------------------------------------

  //drawMargins();
  
  if (drawStaffLines == 1) {
  drawStaves(numberOfStaffLines, staff_height);
  }
  
  
  // Draw shadow lines and verteces
  // -------------------------------------------------------------------------------------------------------
  for (int i=1; i < staff1_morphology.size(); i++) {
    stroke(193, 193, 193);
    strokeWeight(4);
    line(staff1_vertices.get(i).x, staff1_vertices.get(staff1_morphology.get(i)).y, staff1_vertices.get(i-1).x, staff1_vertices.get(staff1_morphology.get(i - 1)).y);
  }
  for (int i=1; i < staff2_morphology.size(); i++) {
    stroke(193, 193, 193);
    strokeWeight(4);
    line(staff2_vertices.get(i).x, staff2_vertices.get(staff2_morphology.get(i)).y, staff2_vertices.get(i-1).x, staff2_vertices.get(staff2_morphology.get(i - 1)).y);
  }
  for (int i = 0; i < staff1_morphology.size(); i++) {
     
     if (gamaka_array_staff1[i] == 1) {
       one.resize(30, 30);
       image(one, (staff1_vertices.get(i).x - 15), (staff1_vertices.get(staff1_morphology.get(i)).y) - 60);
     }
     if (gamaka_array_staff1[i] == 2) {
       two.resize(30, 30);
       image(two, (staff1_vertices.get(i).x - 15), (staff1_vertices.get(staff1_morphology.get(i)).y) - 60);
     }
     if (gamaka_array_staff1[i] == 3) {
       three.resize(30, 30);
       image(three, (staff1_vertices.get(i).x - 15), (staff1_vertices.get(staff1_morphology.get(i)).y) - 60);
     }
     
     strokeWeight(3);
     stroke(193, 193, 193);
     fill(255, 255, 255);
     ellipse(staff1_vertices.get(i).x, staff1_vertices.get(staff1_morphology.get(i)).y, 20, 20);
  }
  for (int i = 0; i < staff2_morphology.size(); i++) {
    
    if (gamaka_array_staff2[i] == 1) {
       one.resize(30, 30);
       image(one, (staff2_vertices.get(i).x - 15), (staff2_vertices.get(staff2_morphology.get(i)).y) - 60);
     }
     if (gamaka_array_staff2[i] == 2) {
       two.resize(30, 30);
       image(two, (staff2_vertices.get(i).x - 15), (staff2_vertices.get(staff2_morphology.get(i)).y) - 60);
     }
     if (gamaka_array_staff2[i] == 3) {
       three.resize(30, 30);
       image(three, (staff2_vertices.get(i).x - 15), (staff2_vertices.get(staff2_morphology.get(i)).y) - 60);
     }
    
     strokeWeight(3);
     stroke(193, 193, 193);
     fill(255, 255, 255);
     ellipse(staff2_vertices.get(i).x, staff2_vertices.get(staff2_morphology.get(i)).y, 20, 20);
  }
  // -------------------------------------------------------------------------------------------------------



 // Draw tracking lines and verteces
 // -------------------------------------------------------------------------------------------------------
 for (int i=1; i < staff1_morphology_tracking.size(); i++) {
    stroke(0);
    strokeWeight(4);
    line(staff1_vertices.get(i).x, staff1_vertices.get(staff1_morphology_tracking.get(i)).y, staff1_vertices.get(i-1).x, staff1_vertices.get(staff1_morphology_tracking.get(i - 1)).y);
  }
  if ((staff1_morphology_tracking.size() != staff1_morphology.size()) || (setIndex != 0)) {
  for (int i=1; i < staff2_morphology_tracking.size(); i++) {
    stroke(0);
    strokeWeight(4);
    line(staff2_vertices.get(i).x, staff2_vertices.get(staff2_morphology_tracking.get(i)).y, staff2_vertices.get(i-1).x, staff2_vertices.get(staff2_morphology_tracking.get(i - 1)).y);
  }
  }
  for (int i = 0; i < staff1_morphology_tracking.size(); i++) {
             if (i < setIndex){
               fill(255, 0, 0);
             }
             else if (staff1_morphology_tracking.size() == staff1_morphology.size() && (staff1_morphology.size() != setIndex + 1)) {
               fill(255, 0, 0);
             }  
             else {
               fill(255, 255, 255);
             }
     strokeWeight(3);
     stroke(0);
     println(staff1_morphology_tracking);
     ellipse(staff1_vertices.get(i).x, staff1_vertices.get(staff1_morphology_tracking.get(i)).y, 20, 20);
     fill(255, 255, 255);
  }
  if ((staff1_morphology_tracking.size() != staff1_morphology.size()) || (setIndex != 0)) {
  for (int i = 0; i < staff2_morphology_tracking.size(); i++) {
            if ((i < setIndex) && (setIndex != 0) && (staff2_morphology_tracking.size() > 1))  {
               println("second red ball!",  setIndex);
               fill(255, 0, 0);
            }
            else {
               fill(255, 255, 255);
            }
     strokeWeight(3);
     stroke(0);
     ellipse(staff2_vertices.get(i).x, staff2_vertices.get(staff2_morphology_tracking.get(i)).y, 20, 20);
  }
  }
  else {
     strokeWeight(3);
     stroke(0);
     ellipse(staff2_vertices.get(0).x, staff2_vertices.get(staff2_morphology_tracking.get(0)).y, 20, 20);
  }
  // -------------------------------------------------------------------------------------------------------


}


//**********************************************************************************************************
// ------- FUNCTIONS SECTION -------
//**********************************************************************************************************



// document margins around staves; used for testing
// -------------------------------------------------------------------------------------------------------
void drawMargins() { 
  //stroke(0);
  strokeWeight(1);
  //line(0, height/2, width, height/2);
  stroke(255, 0, 0, 50);
  line(0, staff1_topMargin, width, staff1_topMargin);
  line(0, staff1_bottomMargin, width, staff1_bottomMargin);
  line(0, staff2_topMargin, width, staff2_topMargin);
  line(0, staff2_bottomMargin, width, staff2_bottomMargin);
  line(staff_leftMargin, 0, staff_leftMargin, height);
  line(staff_rightMargin, 0, staff_rightMargin, height);
}
// -------------------------------------------------------------------------------------------------------


//a function to draw a single staff line at a y-axis location
// -------------------------------------------------------------------------------------------------------
void staffLine(float y_value) {
  strokeWeight(1);
  stroke(0, 100);
  line(staff_leftMargin, y_value, staff_rightMargin, y_value);
}
// -------------------------------------------------------------------------------------------------------


// draw a single vertical line at the location of a savara (note) on the top staff
// -------------------------------------------------------------------------------------------------------
void svara_top(float x_value) {
  strokeWeight(1);
  stroke(0, 100);
  line(x_value, staff1_topMargin, x_value, staff1_bottomMargin);
}


// draw a single vertical line at the location of a savara (note) on the bottom staff
void svara_bottom(float x_value) {
  strokeWeight(1);
  stroke(0, 100);
  line(x_value, staff2_topMargin, x_value, staff2_bottomMargin);
}
// -------------------------------------------------------------------------------------------------------


// draw all staff lines between top and bottom margins
// -------------------------------------------------------------------------------------------------------
void drawStaves(int numStaffLines, float staffHeight) {
    for (int i = 0; i < numStaffLines; i++) {
      staffLine(staff1_bottomMargin - (i * (staffHeight/(numStaffLines - 1))));
  }
  
  for (int i = 0; i < numStaffLines; i++) {
      staffLine(staff2_bottomMargin - (i * (staffHeight/(numStaffLines - 1))));
  }
}
// -------------------------------------------------------------------------------------------------------


// draw all Svara lines according to the number of svaras in the staff
// -------------------------------------------------------------------------------------------------------
void setSvara(int numOfSvara_staff1, int numOfSvara_staff2, float staffWidth) {
    for (int i = 0; i < numberOfSvara_staff1; i++) {
      svara_top(staff_leftMargin + (i * (staffWidth/(numOfSvara_staff1 - 1))));
  }
  
  for (int i = 0; i < numberOfSvara_staff2; i++) {
      svara_bottom(staff_leftMargin + (i * (staffWidth/(numOfSvara_staff2 - 1))));
  }
// -------------------------------------------------------------------------------------------------------
}


// Read matrix values into an array
// -------------------------------------------------------------------------------------------------------
void readStaffAndSvaraIntoArray(int numStaffLines, int numSvara_staff1, int numSvara_staff2, 
int staff1_bMargin, int staff2_bMargin, int staff_lMargin, float staffHeight, float staffWidth) {
  
  // Read the locations of the staff lines into the array
  for (int i = 0; i < numStaffLines; i++) {
      y_staff1[i] = (staff1_bMargin - (i * (staffHeight/(numStaffLines - 1))));
  }
  for (int i = 0; i < numStaffLines; i++) {
      y_staff2[i] = (staff2_bMargin - (i * (staffHeight/(numStaffLines - 1))));
  }
  
  // Read the locations of the svaras into the array
  for (int i = 0; i < numSvara_staff1; i++) {
      x_staff1[i] = (staff_lMargin + (i * (staffWidth/(numSvara_staff1 - 1))));
  }
  for (int i = 0; i < numSvara_staff2; i++) {
      x_staff2[i] = (staff_lMargin + (i * (staffWidth/(numSvara_staff2 - 1))));
  }
}
// -------------------------------------------------------------------------------------------------------


// Read all Vertices into a PVector array for easy access
// -------------------------------------------------------------------------------------------------------
void readIntoPVector() {
  for (int i = 0; i < max(numberOfStaffLines, numberOfSvara_staff1, numberOfSvara_staff2); i++) {
    staff1_v = new PVector(x_staff1[i], y_staff1[i]);
    staff1_vertices.add(staff1_v);
  }
  for (int i = 0; i < max(numberOfStaffLines, numberOfSvara_staff1, numberOfSvara_staff2); i++) {
    staff2_v = new PVector(x_staff2[i], y_staff2[i]);
    staff2_vertices.add(staff2_v);
  }
}
// -------------------------------------------------------------------------------------------------------





//**********************************************************************************************************
// ------- OPEN SOUND CONTROL SECTION -------
//**********************************************************************************************************

void oscEvent(OscMessage theOscMessage)  {
 
 // set the staff margin dynamicly
 if(theOscMessage.checkAddrPattern("/margin")==true)
  {
    margin = (theOscMessage.get(0).intValue());
  }
 
 // set the number of staff lines
 if(theOscMessage.checkAddrPattern("/numStaff")==true)
  {
    numberOfStaffLines = (theOscMessage.get(0).intValue());
  }
 
 // set staff morphology dynamicly
 if(theOscMessage.checkAddrPattern("/morphList")==true)
  {
    staff1_morphList = (theOscMessage.get(0).stringValue());
    staff2_morphList = (theOscMessage.get(1).stringValue());
    // staff1_morphList_tracking = (theOscMessage.get(2).stringValue());
    // staff2_morphList_tracking = (theOscMessage.get(3).stringValue());
  }
  if(theOscMessage.checkAddrPattern("/setCurrentTrackPitch")==true)
  {
    setPitch = (theOscMessage.get(0).intValue());
  }
  if(theOscMessage.checkAddrPattern("/addTrackPitch")==true)
  {
    addPitch = (theOscMessage.get(0).intValue());
    //println(staff1_morphology_tracking);
    //println(staff2_morphology_tracking);
    
    if (staff1_morphology_tracking.size() < staff1_morphology.size()) {
        staff1_morphology_tracking.add(addPitch); // Add pitch to the tracked array
        }
    else if ((staff1_morphology_tracking.size() == staff1_morphology.size()) && (setIndex == 0)) {
         }
    else {
        staff2_morphology_tracking.add(addPitch); // Add pitch to the tracked array
         }
    
    if (setIndex < (staff1_morphology.size() - 1)) {
    setIndex += 1;
    }
    else {
      setIndex = 0;
    }
    
    
  }

  // set staff2 morphology dynamicly
 if(theOscMessage.checkAddrPattern("/numberOfSvara_staff1")==true)
  {
    numberOfSvara_staff1_osc = (theOscMessage.get(0).intValue());
  }
  
  if(theOscMessage.checkAddrPattern("/numberOfSvara_staff2")==true)
  {
    numberOfSvara_staff2_osc = (theOscMessage.get(0).intValue());
  }
  
  if(theOscMessage.checkAddrPattern("/drawStaffLines")==true)
  {
    drawStaffLines = (theOscMessage.get(0).intValue());
  }
  
  if(theOscMessage.checkAddrPattern("/gamaka")==true)
  {
    gamaka_staff1 = (theOscMessage.get(0).stringValue());
    gamaka_staff2 = (theOscMessage.get(1).stringValue());
  }
}