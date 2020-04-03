class colour{
  int colourNo;
  
  float targetRGB[] = {0,0,0};  
  float upperRGB[] = {0,0,0};
  float lowerRGB[] = {0,0,0};
  
  int blobArea[] = new int[2];

  int thresh = 5;
  int distThresh = 20;
  int behaviour = 1;
  float priority = pow(maxTarget, -1);
  int priorityPercent  = int(map(priority, 0,1,0,100));;
  int click;
  int pointX[] = new int[2];
  int pointY[] = new int[2];

  colour(int colour){
   colourNo = colour;

   // colour values: throwaway, threshhold, distance threshhold, behaviour, priority
   
  }
  
  void defineTarget(){
  // get target rgb values from pixel clicked
    
    if(callibration == 0){
      for(int i = 0; i < pointX.length; i ++){
        pointX[i] = 0;
        pointY[i] = 0;
      }
      click = 0;
      targetRGB[0]= red(video.get(mouseX/scale,mouseY/scale));
      targetRGB[1]= green(video.get(mouseX/scale,mouseY/scale));
      targetRGB[2]= blue(video.get(mouseX/scale,mouseY/scale));
    
    }
    else{
      
      if(click == 0){  
        pointX[0] = int(mouseX/scale);
        pointY[0] = int(mouseY/scale);
        point(pointX[0]*scale, pointY[0]*scale);
        click = 1;
      }
      else{
        pointX[1] = int(mouseX/scale);
        pointY[1] = int(mouseY/scale);        
        click = 0;
        stroke(0);
        fill(255);
        rect(pointX[0]*scale, pointY[0]*scale, pointX[1]*scale,pointY[1]*scale);
        delay(100);
        int loopX[] = new int[2];
        int loopY[] = new int[2];
        if(pointX[0] <= pointX[1]){
          loopX[0] = pointX[0];
          loopX[1] = pointX[1];
        }
        else{
          loopX[0] = pointX[1];
          loopX[1] = pointX[0];
        }
        if(pointY[0] <= pointY[1]){
          loopY[0] = pointY[0];
          loopY[1] = pointY[1];
        }
        else{
          loopY[0] = pointY[1];
          loopY[1] = pointY[0];
        }
        if(callibration == 1){
          float sumRGB[] = {0, 0, 0};
          float currRGB[] = {0,0,0};
          int targetArea = 0;
          for(int x = loopX[0]; x < loopX[1]; x++){
            for(int y = loopY[0]; y < loopY[1]; y++){
              currRGB[0] = red(video.get(x,y));
              currRGB[1] = green(video.get(x,y));
              currRGB[2] = blue(video.get(x,y));
              
              sumRGB [0] += currRGB[0];
              sumRGB[1] += currRGB[1];
              sumRGB [2] += currRGB[2];
              targetArea ++;
            }
          }
          targetRGB[0] = int(sumRGB[0]/targetArea);
          targetRGB[1] = int(sumRGB[1]/targetArea);
          targetRGB[2] = int(sumRGB[2]/targetArea);
          
        }
        if(callibration == 2){
          float currRGB[] = {0,0,0};
          int counter = 0;
          for(int x = loopX[0]; x < loopX[1]; x++){
            for(int y = loopY[0]; y < loopY[1]; y++){
         
              currRGB[0] = red(video.get(x,y));
              currRGB[1] = green(video.get(x,y));
              currRGB[2] = blue(video.get(x,y));
              for(int i = 0; i < targetRGB.length; i ++){
                if(counter == 0){
                  upperRGB[i] = currRGB[i];
                  lowerRGB[i] = currRGB[i];
                }
                else{
             
                  if(currRGB[i] > upperRGB[i]){
                    upperRGB[i] = currRGB[i];
                  }
                  
                  if(currRGB[i] < lowerRGB[i]){
                    lowerRGB[i] = currRGB[i];
                  }
                }
              }
              counter ++;
            }
          }
          for(int i = 0; i < targetRGB.length; i ++){
            targetRGB[i] = (upperRGB[i] + lowerRGB[i])/2;  
          }
        }
      }
      
    }
  }
  void colourRGB(float frameRGB[], int x, int y){
    if (targetRGB[0] !=0 && targetRGB[1] !=0 && targetRGB[2] !=0){
      if (callibration == 2){
        boolean checkRGB[] = {false, false, false};
        if (frameRGB[0]>= lowerRGB[0] && frameRGB[0]<= upperRGB[0]){
          checkRGB[0] = true;
        }
        if (frameRGB[1]>= lowerRGB[1] && frameRGB[1]<= upperRGB[1]){
          checkRGB[1] = true;
        }
        if (frameRGB[2]>= lowerRGB[2] && frameRGB[2]<= upperRGB[2]){
          checkRGB[2] = true;
        }
        if (checkRGB[0] == true && checkRGB[1] == true && checkRGB[2] == true){
          boolean found = false;
          
          for (blob b : blobx){// check if pixel is within range of any blob
            if(b.isnear(x,y, distThresh)){
              // if pixel is within range, add to blob
              b.add(x,y);
              found = true;
              break;
            }
            
          }
          // if pixel is not within any blob range, create a nwe blob
          if (found == false){
            blob b = new blob(x,y,colourNo, targetRGB);
            blobx.add(b);
          }
          // prevents a pixel registering as two colours
          
        }
      }
      else{
        float dist= dist(frameRGB[0], frameRGB[1], frameRGB[2], targetRGB[0], targetRGB[1], targetRGB[2]);
          // compare current pixels to target pixels
          
        if (dist < thresh){// if pixel is similar colour to target pixel
          boolean found = false;
          
          for (blob b : blobx){// check if pixel is within range of any blob
            if(b.isnear(x,y, distThresh)){
              // if pixel is within range, add to blob
              b.add(x,y);
              found = true;
              break;
            }
            
          }
          // if pixel is not within any blob range, create a nwe blob
          if (found == false){
            blob b = new blob(x,y,colourNo,targetRGB);
            blobx.add(b);
          }
          // prevents a pixel registering as two colours
          
        }
      }
      
    }
  }
int[] processBlob(){
    int blobAreaLeft = 0;
    int blobAreaRight = 0;
    for(blob b : blobx){
      int blobAreaChange[] = b.sumBlob(colourNo);
      blobAreaLeft += blobAreaChange[0];
      blobAreaRight += blobAreaChange[1];
    }
    
      float mappedLeft = map(blobAreaLeft * priority, 0, ((vidWidth/2)*vidHeight), 0, range);
      float mappedRight = map(blobAreaRight * priority, 0, ((vidWidth/2)*vidHeight), 0, range);
      float sigmoidLeft = tanh(mappedLeft);
      float sigmoidRight = tanh(mappedRight);
      int processedLeft = int(map(sigmoidLeft, -0, 1, 0, 100));
      int processedRight = int(map(sigmoidRight, 0, 1, 0, 100));           
       
      if (behaviour == 1 ){

         int processed[] = {processedLeft, processedRight};
         return processed;
      }
      else{
        if(behaviour == 2){
          
         int processed[] = {processedRight, processedLeft};
         return processed;
        } 
        else{
        //if(behaviour ==3)    
         int processed[] = {-processedRight, -processedLeft};
         return processed;
           
        } 
      }
  }
  float tanh(float a){
  float b = (exp(a) - exp(-a))/ (exp(a) + exp(-a));
  return b;
  }
}
