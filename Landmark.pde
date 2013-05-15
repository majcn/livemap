import processing.video.*;

class Landmark {
  float x;
  float y;
  float r;
  String name;
  boolean waitQueue;
  Object media;
  
  Landmark(float x, float y, float r, String name, boolean waitQueue) {
    this.x = x;
    this.y = y;
    this.r = r;
    this.name = name;
    this.waitQueue = waitQueue;
  }
  
  boolean inCircle(float[] xy) {
    return (xy[0]-x)*(xy[0]-x) + (xy[1]-y)*(xy[1]-y) < r*r;
  }
  
  boolean play() {
    if(media instanceof Movie) {
      Movie m = (Movie)media;
      if(m.time() < 1) {
        m.play();
      }
      if(abs(m.time()-m.duration()) < 1) {
        return false;
      }
      image(m, 0, 0, displayWidth, displayHeight);
    } else if(media instanceof PImage) {
      image((PImage)media, 0, 0, displayWidth, displayHeight);      
    }
    return true;
  }
  
  void stop() {
    if(media instanceof Movie) {
      Movie m = (Movie)media;
      m.stop();
    }
  }
}
