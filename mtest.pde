import java.util.concurrent.ConcurrentLinkedQueue;

boolean sketchFullScreen() {
  return true;
}

ArrayList<Landmark> landmarks;
ConcurrentLinkedQueue<Landmark> queue;

void setup() {
  size(displayWidth, displayHeight);
  
  landmarks = new ArrayList();
  XML[] config = loadXML("config.xml").getChildren("landmark");
  for(XML element: config) {
    float x = element.getFloat("x");
    float y = element.getFloat("y");
    float r = element.getFloat("r");
    String name = element.getString("name");
    boolean waitQueue = boolean(element.getString("queue"));
    Landmark l = new Landmark(x, y, r, name, waitQueue);
    l.media = new Movie(this, name);
    landmarks.add(l);
  }
  
  queue = new ConcurrentLinkedQueue<Landmark>() {
    public boolean offer(Landmark e) {
      if (contains(e)) {
        return false; 
      } else {
        return super.offer(e);
      }
    }
  };
}

String[] getCoordinates(String url) {
  String[] m = match(loadStrings(url)[0], "<string.*>(.*),</string>");
  if (m != null) {
      return split(m[1], ',');
  }
  String err[] = {"-1 -1"};
  return err;
}

void checkLandmarks(String[] lines) {
  for(Landmark l: landmarks) {
    boolean anyMatch = false;
    for (String line: lines) {
      float[] xy = float(split(line, ' '));
      if(l.inCircle(xy)) {
        anyMatch = true;
        break;
      }
    }
    if(anyMatch) {
      queue.offer(l);
    } else {
      queue.remove(l);
      l.stop();
    }
  }
}

void draw() {
  background(0);
  checkLandmarks(getCoordinates("http://192.168.1.10/WcfDemoService/DemoService.svc/getData/data"));
  boolean playQueued = false;
  boolean playThis = false;
  for(Landmark l: queue) {
    playThis = false;
    if(l.waitQueue && !playQueued) {
      playQueued = true;
      playThis = true;
    }
    if(!l.waitQueue) {
      playThis = true;
    }
    if(playThis && !l.play()) {
      queue.remove(l);
      l.stop();
    }
  }
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}
