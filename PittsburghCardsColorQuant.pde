import controlP5.*;

import java.awt.event.*;

import toxi.color.*;
import toxi.math.*;


ControlP5 cp5;

int MARGIN = 5;

int columns = 6;
float rowHeight = 70.0;
float tolerance = 0.66;
int samples = 10;
float scroll = 0.0;
String datafile = "";

ArrayList<String> imageIDs;
ArrayList<PImage> images;
ArrayList<Histogram> histograms;

void setup() {
  size(1024, 768);

  // Set up scrolling.
  addMouseWheelListener(new MouseWheelListener() { 
    public void mouseWheelMoved(MouseWheelEvent mwe) { 
      mouseWheel(mwe.getWheelRotation());
  }});

  cp5 = new ControlP5(this);
  
  // Tolerance slider
  cp5.addSlider("tolerance")
     .setPosition(5, height - 40)
     .setSize(200, 30)
     .setRange(0, 1);
  
  // Sampling slider
  cp5.addSlider("samples")
     .setPosition(215, height - 40)
     .setSize(200, 30)
     .setRange(0, 100);
  
  // Recalculate button
  cp5.addButton("recalculate")
     .setSize(100, 30)
     .setPosition(425, height - 40)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

  // Export controls
  cp5.addTextfield("datafile")
     .setPosition(530, height - 40)
     .setSize(155, 30)
     .setAutoClear(false);
     
  cp5.addButton("export")
     .setSize(100, 30)
     .setPosition(695, height - 40)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

  imageIDs = new ArrayList<String>();
  images = new ArrayList<PImage>();
  histograms = new ArrayList<Histogram>();

  // Load all the images in the img directory
  File folder = new File(dataPath("img"));
  File[] imageFiles = folder.listFiles();
  
  if (imageFiles != null) {
    for (int i = 0; i < imageFiles.length; i++) {
      PImage img = loadImage("img/" + imageFiles[i].getName());
      
      if (img != null) {
        if (img.height > rowHeight) {
          rowHeight = img.height;
        }
        
        imageIDs.add(stripExtension(imageFiles[i].getName()));
        images.add(img);
        
        // Get the initial histogram
        histograms.add(Histogram.newFromARGBArray(img.pixels, img.pixels.length / samples, tolerance, true));
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
  
  fill(255, 191.25);
  rect(0, height - 50, width, 50);
}

void mouseWheel(int delta) {
  scroll -= delta * 3;
  scroll = min(0, scroll);
}

public void recalculate() {
  if (histograms != null) {
    histograms.clear();
    
    for (int i = 0; i < images.size(); i++) {
      PImage img = images.get(i);
      histograms.add(Histogram.newFromARGBArray(img.pixels, img.pixels.length / samples, tolerance, true));
    }
  }
}

public void export() {
  datafile = cp5.get(Textfield.class, "datafile").getText();

  println("Save " + datafile);

  if (imageIDs != null && histograms != null) {
    PrintWriter writer = createWriter(datafile + ".csv");
    
    for (int i = 0; i < imageIDs.size(); i++) {
      String id = imageIDs.get(i);
      Histogram hist = histograms.get(i);
      String[] toks = new String[(hist.getEntries().size() * 2) + 1];
      
      toks[0] = id;
      
      int j = 1;
      for (HistEntry e : hist) {
        toks[j] = e.getColor().toHex();
        toks[j + 1] = str(e.getFrequency());
        j += 2;
      }
      
      writer.println(join(toks, ','));
    }
    
    writer.flush();
    writer.close();
  }
}

String stripExtension(String filename) {
  String[] toks = split(filename, '.');
  
  return join(shorten(toks), '.');
}
