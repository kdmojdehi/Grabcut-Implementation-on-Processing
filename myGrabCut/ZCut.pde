import java.util.Random;
import java.util.Collections;
int totzero , totnonzero;
boolean origimgUPDATED = false;
//this function is called after user selects a region, uses x(and y)_start(and end) global vars to select the region for Tu
void performGrabCut()
{
  GaussianComponent[] FrG = new GaussianComponent[GC] ; // 
  GaussianComponent[] BckG = new GaussianComponent[GC] ; //
  GraphCut myCut;
  int[] n_locs; // list that will be holding location of neighbors of iterating pixel
  // if user starts from right to left or bottom to up, start and end points must be swaped:
  int loctemp;
  if (x_start > x_end)
  {
    println(x_start,x_end);
    loctemp = x_start;
    
    x_start = x_end;
    println(loctemp , x_start , x_end);
    x_end = loctemp;
    
  }
  if (y_start > y_end)
  {
    loctemp = y_end;
    y_end = y_start;
    y_start = loctemp;
  }
  println("recieved user selection, starting grabCut. x_start="+x_start + " y_start =" + y_start + " x_end="+x_end + "y_end=" + y_end );
  totzero = 0;
  totnonzero=  0;  
  origIMG = loadImage(filename);
  origIMG.loadPixels();
  fimg = standardize(origIMG.pixels);
  myCut = new GraphCut(H*W , 8*H*W);
  print("created graph successfully\n");
  
  // putting apropriate regions of image into relevant trimap lists:
  ArrayList<fColor> Tu =  new ArrayList<fColor>(); // for GrabCut, pixels selected by the user , includes bg and fg , but outside of it 
  ArrayList<fColor> Tb =  new ArrayList<fColor>(); // for GrabCut, pixels not selected by user => definitely background
  //println("Assigning Tu and Tb...");
  int p_loc = 0;
  for (int frow =0; frow<H ; frow++ )        // is definitely bg
  {
    for (int fcol = 0 ; fcol<W ; fcol++)
    {
      p_loc = cord2loc(frow,fcol);
      if ( ( frow >= y_start && frow< y_end  )&&( fcol >= x_start && fcol<x_end ) )
      {
        Tu.add(fimg[p_loc]);
        fimg[p_loc].setMat(Matte.FG);
        fimg[p_loc].setTri(Trimap.TU); //set trimap to unknown
      }
      else //it definitely belongs to background
      {
        Tb.add(fimg[p_loc]);
        fimg[p_loc].setMat(Matte.BG);
        fimg[p_loc].setTri(Trimap.TB);
      }
    }
  }
  //println("TBSIZE:"+Tb.size());
  //println("TUSIZE:"+Tu.size());
  //println("TOTPIXZ:" + fimg.length);
      
    //Trimaps are set by here
    
    // initialization of Gaussian Components:
  println("Starting Random GC initialization");  
  //shuffle Tu and Tb lists and randomly assign regions of it to Gaussian Components:
  //TODO: make this random assignment based on eigenvalues (Orchard and Bouman [1991])
  Collections.shuffle(Tu, new Random() );
  Collections.shuffle(Tb, new Random() );
  int Tu_subsize = Tu.size()/GC;
  int Tb_subsize = Tb.size()/GC;
  for (int gaus_comp=0 ; gaus_comp <GC ; gaus_comp++)
  {
    BckG[gaus_comp] = new GaussianComponent();
    for (int sub_pix= Tb_subsize*gaus_comp ; sub_pix < Tb_subsize*(gaus_comp+1) ; sub_pix++ )
    {
      BckG[gaus_comp].appendPix(Tb.get(sub_pix));
    }
    //println("Updating Parameter of Backgroud # " + gaus_comp );
    BckG[gaus_comp].updateParams();
    
    FrG[gaus_comp] = new GaussianComponent();
    for (int sub_pix= Tu_subsize*gaus_comp ; sub_pix < Tu_subsize*(gaus_comp+1) ; sub_pix++ )
    {
      FrG[gaus_comp].appendPix(Tu.get(sub_pix));
    }
    //println("Updating Parameter of Foregroud # " + gaus_comp );
    FrG[gaus_comp].updateParams();
  } // random gaussian components initialization is done
  normalizeCmpnP(FrG);
  normalizeCmpnP(BckG);
  println("done with random init");
    
   
  // iterations begin here:
  
  for (int iteration=0; iteration<ITERS ; iteration++)
  {       
    
        // E - step:
        
    println("(E-Step)performing setClusterzz ");
    for (int node=0;node<H*W ; node++)
    {
      if (fimg[node].getMat() == Matte.BG)
      {
        fimg[node].setCluster(BckG); // which GMM cluster in BackGround set assigns most probability to this pixel
      }
      else
      {
        fimg[node].setCluster(FrG); // which GMM cluster in ForeGround set assigns most probability to this pixel
      }
    }
    
    // flash Gaussian Components Array:
    for (int gc=0 ; gc < GC ; gc++)
    {
    BckG[gc] = new GaussianComponent();
    FrG[gc] = new GaussianComponent();
    }
    //assign new pixles to Gaussian Components:
    for (int node=0;node<H*W ; node++)
    {
      if ( fimg[node].getMat() == Matte.FG )
        FrG[fimg[node].k].appendPix(fimg[node]);
      else
        BckG[fimg[node].k].appendPix(fimg[node]);
    }
        
    
        // M - Step :
    
    //update parameters considering that gaussian components' pixels have changed
    for (int gc=0 ; gc < GC ; gc++)
    {
    BckG[gc].updateParams();
    FrG[gc].updateParams();
    }
    normalizeCmpnP(FrG);
    normalizeCmpnP(BckG);

        
        
        // GraphCut step:
    
    // set unary and pairwise weights between pixels:
    myCut = new GraphCut(H*W , 8*H*W);
    print("created graph successfully\n");
    for (int node=0;node<H*W ; node++)
    {
      fimg[node].setCluster(FrG , BckG);
      float fg_lh = (float) fimg[node].clusterLLH(FrG);
      float bg_lh = (float) fimg[node].clusterLLH(BckG);
      myCut.setTerminalWeights(node , U_ALPHA*(bg_lh) , U_ALPHA*(fg_lh));
      // setting unary weights:
      n_locs = neighbLoc(node);
      
      //compute expected variance in neighbours area
      float expct_var = 0.;
      for (int neiz:n_locs)
      {
        expct_var += rgbDist(node,neiz);
      }
      expct_var = (float)expct_var/n_locs.length;
      if (expct_var != 0 )
        totnonzero += 1;
      if (expct_var == 0 )  // for neighbour pixels that are completely alike, make sure they get a high edge weight, but no infinite
       {
         expct_var = .001;
         totzero += 1;
       }
      
      // set pairwise weights:
      for (int neighb : n_locs)
      {
        if (rgbDist(node,neighb) < 0 )
          println("Setting Graph Weights: Warning sub-zero rgb_Dist");
          
        myCut.setEdgeWeight(node,neighb , P_ALPHA*(exp( -rgbDist(node,neighb)/(2*expct_var) ))/locs_dist(node,neighb) );
      }
    
    }    
    print("Created distances,Performing MinCut/MaxFlow...");
    myCut.computeMaximumFlow(false , null );
    print("Done!\n");
        
    // use the cut to update pixels Matte( in the Unknow Trimap ):
    print("updating Tu and Tb lists for next iteration...");
    for (int pix_loc=0 ; pix_loc < H*W ; pix_loc ++)
    {
      if (myCut.getTerminal(pix_loc) == Terminal.FOREGROUND)
      {
        //Tu.add(fimg[pix_loc]);
        if (fimg[pix_loc].getTri() != Trimap.TB) // pixels in TB list definitely belong to background , therefore we don't want to change their matte 
        {
          fimg[pix_loc].setTri(Trimap.TU);
          fimg[pix_loc].setMat(Matte.FG);
        }
      }
      else
      {
          fimg[pix_loc].setMat(Matte.BG);
      }
    }
    
    // GraphCut Step ends here 
    
    println("End of Iteration "+ (iteration+1));
    //println("Total pixels with completely alike neighbours(x2) = " + totzero + ", total pixels with expct_var > 0 = " + totnonzero);
    
  }// end of iterations for loop
  
  
  //*** Last Visualization:
  print("updating image...");
  origIMG = loadImage(filename);
  origIMG.loadPixels();  
    for (int pix_loc=0 ; pix_loc < H*W ; pix_loc ++)
    {
      if (myCut.getTerminal(pix_loc) == Terminal.BACKGROUND || fimg[pix_loc].getTri() == Trimap.TB)
      {
        origIMG.pixels[pix_loc] = color(255,255,255);
      }
    }
    origIMG.updatePixels();
    origimgUPDATED = true;
    //** End of Last Visual
  println("Done!");
  
}//performGrabCut end