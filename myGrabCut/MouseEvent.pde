//mosue event
boolean MP = false; // mouse pressed
boolean DLY = false; // delay for clearing the rectangle after mouse is released
int x_start , y_start , x_end,y_end; //global variables for drawing a rectangle

void mouseDragged()
{
  x_end = mouseX;
  y_end = mouseY;
  //print("Mouse Dragged");
}

void mousePressed()
{
  MP = true;
  x_end = x_start = mouseX;
  y_end = y_start = mouseY;

  //print("mouse press: row="+mouseY + " column="+mouseX + '\n' );
}
void mouseReleased()
{
  x_end = mouseX;
  y_end = mouseY;
  MP = false;
  DLY = true;
  //print("mouse released");
}