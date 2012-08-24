import toxi.color.*;
import toxi.math.*;

import java.awt.event.*;

int MARGIN = 5;

int columns = 6;
float rowHeight = 70.0;
float tolerance = 0.66;
float scroll = 0.0;

ArrayList<PImage> images;
ArrayList<Histogram> histograms;

void setup() {
  size(1024, 768);

  addMouseWheelListener(new MouseWheelListener() { 
    public void mouseWheelMoved(MouseWheelEvent mwe) { 
      mouseWheel(mwe.getWheelRotation());
  }});

  images = new ArrayList<PImage>();
  histograms = new ArrayList<Histogram>();

  File folder = new File(dataPath("img"));
  File[] imageFiles = folder.listFiles();
  
  if (imageFiles != null) {
    for (int i = 0; i < imageFiles.length; i++) {
      PImage img = loadImage("img/" + imageFiles[i].getName());
      
      if (img != null) {
        if (img.height > rowHeight) {
          rowHeight = img.height;
        }
        
        images.add(img);
        histograms.add(Histogram.newFromARGBArray(img.pixels, img.pixels.length/10, tolerance, true));
      }
    }
  }
}

void draw() {
  background(255);

  float colW = width / float(columns);
  float rowH = rowHeight / float(columns);

  pushMatrix();
  translate(0, scroll);
  
  for (int i = 0; i < images.size(); i++) {
    PImage img = images.get(i);

    float x = MARGIN + (i % columns) * colW;
    float y = MARGIN + (i / columns) * rowH;
    float aspect = float(img.width) / img.height;
    float w = colW - (2 * MARGIN);
    float h = (w / aspect) - (2 * MARGIN);

    image(img, x, y, w, h);
    
    noStroke();

    Histogram hist = histograms.get(i);
    int numColors = hist.getEntries().size();

    for (HistEntry e : hist) {
      TColor c = e.getColor();

      fill(c.toARGB());

      rect(x, y + h + MARGIN, w * e.getFrequency(), 20);
      x += w * e.getFrequency();
    }
  }
  
  popMatrix();
}

void mouseWheel(int delta) {
  scroll -= delta;
  scroll = min(0, scroll);
}

