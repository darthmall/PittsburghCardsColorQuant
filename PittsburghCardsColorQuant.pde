import toxi.data.csv.*;
import toxi.data.feeds.*;
import toxi.data.feeds.util.*;

import toxi.color.*;
import toxi.color.theory.*;

import toxi.math.*;

import java.awt.event.*;

int MARGIN = 5;

int columns = 6;
float rowHeight = 70.0;
float tolerance = 0.33;
float scroll = 0.0;

ArrayList<PImage> images;

void setup() {
  size(1024, 768);

  addMouseWheelListener(new MouseWheelListener() { 
    public void mouseWheelMoved(MouseWheelEvent mwe) { 
      mouseWheel(mwe.getWheelRotation());
  }});

  images = new ArrayList<PImage>();  
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
  }
  
  popMatrix();
}

void mouseWheel(int delta) {
  scroll -= delta;
  scroll = min(0, scroll);
}

