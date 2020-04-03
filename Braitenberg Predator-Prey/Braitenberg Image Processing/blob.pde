class blob{// create blob class
  // most top left coordiates
  float minx;
  float miny;
  // most bottom right coords
  float maxx;
  float maxy;
  
  int colour;
  float colourRGB[] = new float[3];

  
  int centre = video.width/2;  
  
  int area[] = new int[2];
  
    
  blob(float x, float y, int targetno,float targetRGB[]){// create a new blob of one given pixel
    minx = x;
    miny = y;
    maxx = x;
    maxy = y;
    colourRGB = targetRGB;
    colour = targetno;   
  }
  
  boolean isnear(float px, float py, float distThresh ){// check if new pixel is within distance threshhold to blob
    float cx = (minx + maxx)/2;// find centre of the blob
    float cy = (miny + maxy)/2;
    float dist = dist(px, py, cx, cy);// find distance between centre and new pixel
    
    if (dist < distThresh){//compare distance to threshhopld and return true or false value
      return true;
    }
    else{
      return false;
    }
  
  }
  void add(float x,float y){// increase blob size to include new pizel
    maxx = max(maxx, x);
    maxy = max(maxy, y);
    
  }
  
  void printblob(){// draw blob using top left and newest bottom right corner values
    stroke(0);
    fill(colourRGB[0], colourRGB[1], colourRGB[2]);
    strokeWeight(2);
    rectMode(CORNERS);
    rect(minx*scale, miny*scale, maxx*scale, maxy*scale);
  }
  
   
  int []sumBlob(int colourNo){
    if (colour == colourNo){ 
      if (minx < centre){// if some of the blob is to the left of the middle line...
        if(maxx < centre){//if all blob is left of the middle line, return total area of the blob 
          area[1] = 0;
          area[0] = int((maxx-minx)*(maxy-miny));
        }
        else
        {
          // return the area of the part of the blob on the left side of the screen
          area[1] = int((maxx - centre)*(maxy - miny));
          area[0] = int((centre - minx)*(maxy-miny)); 
        }
      }
      else
      {
        area[1] = int((maxx-minx)*(maxy-miny));
        area[0] = 0;
      }
      
    }
    else{
      area[1] = 0;
      area[0] = 0;
    }
     return area;
  }
}
