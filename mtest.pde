import java.util.concurrent.ConcurrentLinkedQueue;

boolean sketchFullScreen() {
  return true;
}

ArrayList<Landmark> landmarks;
ConcurrentLinkedQueue<Landmark> queue;

final static String API_URL = "http://192.168.1.10/WcfDemoService/DemoService.svc/getData/data";

void setup() {
  size(displayWidth, displayHeight);
  
  landmarks = new ArrayList();
  XML[] config = loadXML("config.xml").getChildren("PLAYGROUND")[0].getChildren("HOTSPOTS")[0].getChildren("CIRCLE")[0].getChildren("SPOT");
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
  return getCoordinates(url, ';');
}

String[] getCoordinates(String url, char delimiter) {
  try {
    String data = loadStrings(url)[0];
    println(data);
    String[] m = match(data, "<string.*>(.*)"+delimiter+"</string>");
    return split(m[1].replaceAll(",", "."), delimiter);
  } catch(Exception e) {
    String err[] = {"-1 -1"};
    return err;
  }
}

void checkLandmarks(String[] lines) {
  for(Landmark l: landmarks) {
    boolean anyMatch = false;
    for (String line: lines) {
      float[] xy = float(split(line, ' '));
      println(xy[0] + "   " + xy[1]);
      println();
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
  checkLandmarks(getCoordinates(API_URL));
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
