// Function Implementations file




// function that normalizes image pixels to a gaussian with mean of 0 and variance of 1 
fColor[] standardize(int[] img_pix)
{//call: fimg = standardize(origIMG.pixels)
  Integer r_sum,g_sum,b_sum;
  float r_mean,g_mean,b_mean;
  Float r_dev,g_dev,b_dev;  
  r_sum = g_sum = b_sum = 0;
  r_dev = g_dev = b_dev = 0.0; 
  int N = img_pix.length;
  fColor[] out;
  out = new fColor[img_pix.length];
  // init out:
  for (int i =0 ; i < out.length ; i++)
    out[i] =  new fColor();
  //compute mean for each color:
  for (int pix : img_pix)
  {
    r_sum += (int)red(pix);
    g_sum += (int)green(pix);
    b_sum += (int)blue(pix);
  }
  r_mean = r_sum/N;
  g_mean = g_sum/N;
  b_mean = b_sum/N;
  
  //compute variance:
  for (int pix : img_pix)
  {
    r_dev += pow( red(pix) - r_mean , 2 );
    g_dev += pow( green(pix) - g_mean , 2 );
    b_dev += pow( blue(pix) - b_mean , 2 );
  }
  r_dev = sqrt(r_dev/N);
  g_dev = sqrt(g_dev/N);
  b_dev = sqrt(b_dev/N);
  //print(r_dev,g_dev,b_dev);
  //Standardize all pixels:
  for (int i=0 ; i<img_pix.length ; i++)
  {
    out[i].r =  (red(img_pix[i])-r_mean)/r_dev ;
    out[i].g =  (green(img_pix[i])-g_mean)/g_dev ;
    out[i].b =  (blue(img_pix[i])-b_mean)/b_dev ;
  }
  return out;
}//standardize ends

// for test reasons, how would it perform if it was not standardized
fColor[] standardizeNOT(int[] img_pix)
{
  fColor[] out = new fColor[img_pix.length];
  // init out:
  for (int i =0 ; i < out.length ; i++)
    out[i] =  new fColor();
  for (int i=0 ; i<img_pix.length ; i++)
  {
    out[i].r =  red(img_pix[i]) ;
    out[i].g =  green(img_pix[i]) ;
    out[i].b =  blue(img_pix[i]) ;
  }
  return out;
  
}



//override red/green/bllue methods for three channel float type img:
float red(fColor cpix)
{
  return cpix.r;
}
float green(fColor cpix)
{
  return cpix.g;
}
float blue(fColor cpix)
{
  return cpix.b;
}
//float[] fcolor(float r,float g,float b)
//{
//  float[] out = new float[3];
//  out[0] = r;
//  out[1] = g;
//  out[2] = b;
//  return out;
//}



//@DEBUG simplify this if it takes too long
//function that returns the eculidean distance between rgb channels of image for loc1 and loc2 , uses global var img
float rgbDist(int loc1,int loc2){ 
  fColor c1,c2;
  //TODO should I load pixels again?
  c1 = fimg[loc1];
  c2 = fimg[loc2];
  //print("pixels:","c1:",red(c1),green(c1),blue(c1),"c2:",red(c2),green(c2),blue(c2),'\n');
  return ( pow(red(c1) - red(c2),2) + pow(blue(c1) - blue(c2),2) + pow(green(c1) - green(c2),2) );
}



//function that returns the eculidean distance between rgb channels of image between loc1 and MEAN color , uses global var img
float rgbDistM(int loc1,fColor c2){ 
  fColor c1;
  //TODO should I load pixels again?
  c1 = fimg[loc1];
  //print("pixels:","c1:",red(c1),green(c1),blue(c1),"c2:",red(c2),green(c2),blue(c2),'\n');
  return (pow(red(c1) - red(c2),2) + pow(blue(c1) - blue(c2),2) + pow(green(c1) - green(c2),2) ); 
}


//@DEBUG reduce to 4 neighbor if memory problems
//Function that will return array of location of 8-neighbor pixels(uses height and width of image as global var H , W):
int[] neighbLoc( int loc ){
  int row,column;
  row = loc/W;
  column = loc%W;
  IntList nLocs= new IntList();
  for (int j=-1;j<2 ; j++){ // j loops for rows
    if (row+j==H || row+j<0) {continue;}
    for (int i=-1;i<2;i++){ // i loops for columns
      if (column+i==W || column+i<0 || (i==0 && j==0) ) {continue;} // in order to avoid going out of image boundaries ,
      nLocs.append(loc+ i + W*j);                                   // also avoids returning current pixel as its own neighbor
    }
  }
  return nLocs.array();
}


//Function that returns mean color of a list of pixels:
fColor colorMean(ArrayList<fColor> fg_list)
{
  Float r_sum,g_sum,b_sum;
  r_sum = g_sum = b_sum = 0.0;
  int total_pix = fg_list.size();
  fColor mean;
  for (int i=0; i <total_pix;i++)
  {
    mean = fg_list.get(i);
    r_sum += red(mean);
    g_sum += green(mean);
    b_sum += blue(mean);
  }
  mean = new fColor(r_sum/total_pix,g_sum/total_pix,b_sum/total_pix);
  return mean;
}


// returns pixel location (1D) given row and column (uses global var W and H)
int cord2loc(int row, int column) 
{
  if (row>=H || column >= W)
  {
    print("H :" + H + " W : " + W + '\n');
    throw new RuntimeException("cord2loc: Out of Boundaries");
  }
return column+ row*W;
}

// compute euclidean distance between two coords by computing their row and column:
float locs_dist(int loc1 , int loc2)
{
  int row1,col1,row2,col2;
  row1 = loc1/W;
  row2 = loc2/W;
  col1 = loc1%W;
  col2 = loc2%W;
  return sqrt(pow(row1-row2,2) + pow(col1-col2,2));
}