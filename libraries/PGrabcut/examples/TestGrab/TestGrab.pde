import karan.grabcut.*;

GraphCut myCut;
PImage img;
int H,W,dH;
void settings()
{
  size(1080 , int(displayHeight*.8));
  dH = int(displayHeight*.8);
}
void setup()
{
	img = loadImage("input2.jpg");
	H = img.height;
	W = img.width;
	img.loadPixels();
	myCut = new GraphCut(H*W , 4*H*W);
	print("created graph successfully\n");

}

void draw()
{
	image(img);
}