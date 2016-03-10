// Computer Vision Course Mini-Project
// Written by Karan Daei Mojdehi
// Fall 2015
// Email: karan7dm@gmail.com
 

import karan.grabcut.*;


PImage origIMG,untouchedIMG;
String filename;
fColor[] fimg;
int H,W;
// tune parameters:
int ITERS = 5;
float SIGMA = 1;  //factor affecting likelihood and smoothness 
float U_ALPHA = 1; // factor weighting initial loglikelihood of pixels belonging to bg or fg( for unary term tunning)
float P_ALPHA = 10; //factor weighting smoothness among pixels ( for pairwise term tunning)
int GC = 3 ; //number of gaussian components for fg and bg
void settings()
{
  filename = "input4.jpg";
  untouchedIMG = loadImage(filename);// untouched version of image for visualization
 size(untouchedIMG.width, untouchedIMG.height);
}
void setup()
{
    

    origIMG = loadImage(filename);
    H = untouchedIMG.height;
    W = untouchedIMG.width;
    rectMode(CORNERS);
    

    
    //TODO: set weight of selected pixels to huge number

    

    

}

void draw()
{
  if (origimgUPDATED) //show the segmented image if grabCut is done
  {
    origimgUPDATED = false;
    image(origIMG ,0 , 0);
    delay(5000);
    println("Make another selection for another segmentation ");
  }
  else // show the untouched img
    image(untouchedIMG , 0 , 0 );
  if (MP==true)
  {
     rect(x_start , y_start , x_end , y_end);
     fill(color(255,0,0),100);
  }
  if (DLY==true) 
  {
    
    performGrabCut();
    println("graphcut is done!");
    delay(1000);
    DLY = false;
    
    image(origIMG , 0 , 0 );
    
  }
  

}