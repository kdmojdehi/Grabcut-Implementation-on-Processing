import Jama.*;

class Pixel    // ( uses global variables fColor[] fimg , ) 
{
  private Trimap trimap;
  private Matte alpha;
  public int k; // Gaussian Mixture Component to which pixel belongs
  public final int row,column,loc;
  
  //Constructor:
  public Pixel(int _row , int _column)
  {
    if (_row >= H || _column >=W)
    {
      throw new RuntimeException("Pixel Constructor: Out of Boundaries");
    }
    row = _row;
    column = _column;
    loc = column + row*W; 
    trimap= Trimap.TU;
    k = 0;
    alpha = Matte.BG;
  }
  
  public Pixel(int _loc)
  {
    if (_loc >= W*H)
      throw new RuntimeException("Pixel Constructor: Out of Boundaries");
    loc = _loc;
    column = _loc%W;
    row = _loc/H;
    trimap= Trimap.TU;
    k = 0;
    alpha = Matte.BG;
  }
  
  
    //Methods:
    
  public void setMat(Matte mat) { alpha = mat; } 
  public void setTri(Trimap tri) { trimap = tri; }
  public Matte getMat() { return alpha; }
  public Trimap getTri() { return trimap; }
  //method that returns 3 channel color of the pixel from fimg:  
  public fColor getColor() { return fimg[loc]; }
}





// class for handling float colors:
public class fColor
{  
  public float r,g,b;
  public int k;
  private Matte alpha;
  private Trimap trimap;
  
  //constructors:
  public fColor()
  {
    r = 0.0;
    g = 0.0;
    b = 0.0;
    k = -1;
    setTri(Trimap.TU); // unknown trimap
  }
  public fColor(float _r , float _g , float _b)
  {
    r = _r;
    g = _g;
    b = _b;
    k = -1;
    setTri(Trimap.TU); // unknown trimap
  }
  
    //methods:
  
  // returns an array, from which mean color is subtracted  for covariance calculation):
  public double[] getDevArray(fColor mean)  
  {
    double[] out = {r - mean.r,g - mean.g, b - mean.b};
    return out;
  }
  
  //returns probability of pixel  color given a GaussianComponent:
  public double clusterLLH(GaussianComponent G )
  {
    Matrix tempMat;
    tempMat = new Matrix(this.getDevArray(G._mean),1);
    tempMat = tempMat.times(G.cov_inv);
    tempMat = tempMat.times( new Matrix(this.getDevArray(G._mean),3) );
    if (tempMat.getRowDimension()!=1 || tempMat.getColumnDimension()!=1)
      throw new RuntimeException("clusterLLH: dot productfailure\n");
    //println("clusterLLH: " + G.pi + "," + G.cov_det + ',' + tempMat.norm1());
    //return Math.exp(-( -Math.log(G.pi) + 0.5*Math.log(G.cov_det) + .5*tempMat.norm1() ));
    return ( (G.pi) * Math.pow(G.cov_det , -.5) * Math.exp(-.5*tempMat.norm1()) );
    
  }
  
  //returns probability of pixel  color given an Array of GaussianComponent:
  public double clusterLLH(GaussianComponent[] G_array )
  {
    double llh = 0;
    for (GaussianComponent G : G_array )
    {
      //Matrix tempMat;
      //tempMat = new Matrix(this.getDevArray(G._mean),1);
      //tempMat = tempMat.times(G.cov_inv);
      //tempMat = tempMat.times( new Matrix(this.getDevArray(G._mean),3) );
      //if (tempMat.getRowDimension()!=1 || tempMat.getColumnDimension()!=1)
      // throw new RuntimeException("clusterLLH: dot productfailure\n");
      ////println("clusterLLH: " + G.pi + "," + G.cov_det + ',' + tempMat.norm1());
      //llh += ( (G.pi) * Math.pow(G.cov_det,-0.5) * Math.exp(-0.5*tempMat.norm1()) );
      llh += this.clusterLLH(G);
    }
    return -Math.log(llh);
    
  }
  
  // (for E-step) sets matte and k of pixel to the most probable one
  void setCluster(GaussianComponent[] Fg , GaussianComponent[] Bg )
  {
    double max_llh = 0.0;
    double tempF_llh,tempB_llh; // likelihoods of belonging to current compoenent Foreground or Background
    for (int comp = 0 ; comp <GC ; comp++)
    {
      tempF_llh = this.clusterLLH(Fg[comp]);
      tempB_llh = this.clusterLLH(Bg[comp]);
      if (tempF_llh > max_llh)
      {
        max_llh = tempF_llh;
        k = comp;
        alpha = Matte.FG;
      }
      if (tempB_llh > max_llh)
      {
        max_llh = tempF_llh;
        k = comp;
        alpha = Matte.BG;
      }
    }
    
  }
  
  
  // (for E-step) sets matte and k of pixel to the most probable (only FG or BG) component
  void setCluster(GaussianComponent[] BorF)
  {
    double max_llh = 0.0;
    double temp_llh; // likelihoods of belonging to current component Foreground or Background
    for (int comp = 0 ; comp <GC ; comp++)
    {
      temp_llh = this.clusterLLH(BorF[comp]);
      if (temp_llh > max_llh)
      {
        max_llh = temp_llh;
        k = comp;
      }

    }
    
  }
  
  //Matte setters and getters:
  public void setMat(Matte mat) { alpha = mat; }
  public Matte getMat() { return alpha; }
  
  //Trimap stters and getters:
  public void setTri(Trimap tri) { trimap = tri; }
  public Trimap getTri() { return trimap; }
}

public enum Trimap
{
  TU, //unknown
  TF,//foregroudn
  TB;//background
}

public enum Matte
{
  BG, //background
  FG; //foreground
}