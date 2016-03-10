class GaussianComponent
{
  //thse 3 public members variables will be used by calcLLH to assign a probability for pixel belonging to this Gaussian Component 
  public double pi; // initially, equals total number of pixels beloning to the component, it divided by total number of components in code 
  public fColor _mean;
  public Matrix cov_inv;
  public double cov_det;
  private Matrix _cov;
  private ArrayList<fColor> comp_pixz; // arraylist of pixels currently belonging to this Gaussian Component
  
     // constructors:
  public GaussianComponent() //made private so that no one calls it by mistake
  {
    _mean = new fColor();
    _cov = new Matrix(3,3);
    comp_pixz = new ArrayList<fColor>();  
  }
     
  public GaussianComponent(ArrayList<fColor> pixz_list)
  {
    pi = pixz_list.size();
    _mean = new fColor();
    _cov = new Matrix(3,3);  
    comp_pixz = pixz_list;
    this.updateParams();
  }
  
      // methods:
      
  public void appendPix(fColor pix)
  {
    comp_pixz.add(pix);
  }
      
  public void updateParams() // calculates mean , deviation , covariance matrix and it's inverse ( call after setting new comp_pixz )
  {
    if ( comp_pixz.isEmpty() )
      throw new RuntimeException("GaussianComponent.updateParams: comp_pixz list is empty");
    pi = (float)comp_pixz.size();
    if (pi ==0 )
      throw new RuntimeException("GaussianComponent.updateParams: WTF?");
    _mean = colorMean(comp_pixz);
    _cov = calCov();
    if (_cov.det()==0)
      print("GMM updateParams WARNING: covariance determinant is zero,skipping cov_inverse update");
    else
    {
      cov_inv = _cov.inverse();
      cov_det = _cov.det();
    }
    
  }
  
  
  private Matrix calCov() //given comp_pixz and _mean, computes covariance matrix:
  {
    //fColor temp_color;
    double[] elems;
    Matrix color_vect;
    Matrix out = new Matrix(3,3);
    for (fColor cur_pix : comp_pixz)
    {
      //temp_color = cur_pix.getColor();
      elems = cur_pix.getDevArray(_mean);
      color_vect = new Matrix(elems , 3);
      color_vect = color_vect.times(new Matrix(elems,1));
      out.plusEquals(color_vect);
    }
    out.timesEquals(1./comp_pixz.size());
    //out.print(30,15);
    return out;
  }
}

// this function is called after all pixels are assigned to a set of GMMs , \pi_c is computed correctly after calling this
void normalizeCmpnP(GaussianComponent[] Gs)
{
  double sumP = 0.0;
  for (GaussianComponent G : Gs)
  {
    sumP += G.pi;
  }
  for (GaussianComponent G : Gs)
  {
    G.pi = G.pi/sumP;
  }
  
}