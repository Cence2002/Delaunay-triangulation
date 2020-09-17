PVector[] p;
ArrayList<ArrayList<Integer>> w;
ArrayList<ArrayList<Integer>> c;

int inCircleCount=0;
int sameSideCount=0;

void setup() {
  size(800, 600);
  frameRate(60);
  colorMode(RGB, 1);
  background(0);
  p=new PVector[1000];
  w=new ArrayList<ArrayList<Integer>>();
  c=new ArrayList<ArrayList<Integer>>();
  c.add(new ArrayList<Integer>());
  for (int i=0; i<p.length; i++) {
    p[i]=new PVector(map(random(1), 0, 1, 20, width-20), map(random(1), 1, 0, 15, height-15));
    w.add(new ArrayList<Integer>());
  }
  connectNearest();
}

void draw() {
  background(0);
  drawLines();
  noStroke();
  fill(0, 0, 1);
  int count=0;
  for (int i=0; i<w.size(); i++) {
    if (w.get(i).size()==0) {
      count++;
      circle(p[i].x, p[i].y, 10);
    }
  }
  drawPoints();
  int start=millis();
  for (int i=0; i<10; i++) {
    connectNext();
  }
  println("time: "+(millis()-start));
  println("icC: "+inCircleCount);
  println("ssC: "+sameSideCount);
  sameSideCount=0;
  println(c);
  println(count);
  println();
}

void drawPoints() {
  noStroke();
  fill(0, 1, 0);
  for (int i=0; i<p.length; i++) {
    circle(p[i].x, p[i].y, 4);
  }
}

void drawLines() {
  stroke(1, 0, 0.3, 0.6);
  strokeWeight(2);
  for (int i=0; i<w.size(); i++) {
    for (int j=0; j<w.get(i).size(); j++) {
      if (w.get(i).get(j)<i) {
        line(p[i].x, p[i].y, p[w.get(i).get(j)].x, p[w.get(i).get(j)].y);
      }
    }
  }
}

void connect(int a, int b) {
  if (w.get(a).indexOf(b)==-1) {
    w.get(a).add(b);
    w.get(b).add(a);
  }
}

void connectNearest() {
  float min=Float.MAX_VALUE;
  int a=-1;
  int b=-1;
  float dist=-1;
  for (int i=0; i<p.length-1; i++) {
    for (int j=i+1; j<p.length; j++) {
      dist=PVector.dist(p[i], p[j]);
      if (dist<min) {
        min=dist;
        a=i;
        b=j;
      }
    }
  }
  connect(a, b);
  c.get(0).add(a);
  c.get(0).add(b);
}

int partner(int a, int b) {
  for (int i=0; i<w.get(a).size(); i++) {
    if (w.get(b).indexOf(w.get(a).get(i))!=-1) {
      return w.get(a).get(i);
    }
  }
  return -1;
}

int next(int a, int b) {
  int partner=partner(a, b);
  int best=-1;
  if (partner==-1) {
    best=0;
    if (a==0) {
      if (b==1) {
        best=2;
      } else {
        best=1;
      }
    } else if (b==0) {
      if (a==1) {
        best=2;
      } else {
        best=1;
      }
    }
    for (int i=0; i<p.length; i++) {
      if (i!=a&&i!=b) {
        inCircleCount++;
        if (inCircle(p[a], p[b], p[best], p[i])) {
          best=i;
        }
      }
    }
  } else {
    for (int i=0; i<p.length; i++) {
      if (i!=a&&i!=b) {
        sameSideCount++;
        if (!sameSide(p[a], p[b], p[partner], p[i])) {
          inCircleCount++;
          if (best==-1||inCircle(p[a], p[b], p[best], p[i])) {
            best=i;
          }
        }
      }
    }
  }
  return best;
}

boolean sameSide(PVector a, PVector b, PVector c, PVector d) {
  return clockWise(a, b, c)==clockWise(a, b, d);
}

boolean clockWise(PVector a, PVector b, PVector c) {
  return (b.x-a.x)*(c.y-a.y)-(c.x-a.x)*(b.y-a.y)>0;
}

boolean inCircle(PVector a, PVector b, PVector c, PVector d) {
  float ax=a.x-d.x;
  float ay=a.y-d.y;
  float bx=b.x-d.x;
  float by=b.y-d.y;
  float cx=c.x-d.x;
  float cy=c.y-d.y;
  boolean inCircle=(ax*ax+ay*ay)*(bx*cy-cx*by)-(bx*bx+by*by)*(ax*cy-cx*ay)+(cx*cx+cy*cy)*(ax*by-bx*ay)>0;
  if ((b.x-a.x)*(c.y-a.y)-(c.x-a.x)*(b.y-a.y)>0) {
    return inCircle;
  }
  return !inCircle;
}

void connectNext() {
  int i=0;
  int j=-1;
  int next;
  do {
    j++;
    if (j==c.get(i).size()) {
      j=0;
      i++;
    }
    if (i<c.size()) {
      next=next(c.get(i).get(j), c.get(i).get((j+1)%c.get(i).size()));
    } else {
      next=-2;
    }
  } while (next==-1);
  if (next!=-2) {
    int k=(j+1)%c.get(i).size();
    if (w.get(c.get(i).get(j)).indexOf(next)!=-1) {
      if (w.get(c.get(i).get(k)).indexOf(next)!=-1) {
        c.remove(i);
      } else {
        connect(c.get(i).get(k), next);
        c.get(i).remove(j);
        deleteC(i);
      }
    } else {
      if (w.get(c.get(i).get(k)).indexOf(next)!=-1) {
        connect(c.get(i).get(j), next);
        c.get(i).remove(k);
        deleteC(i);
      } else {
        connect(c.get(i).get(j), next);
        connect(c.get(i).get(k), next);
        c.get(i).add(k, next);
        splitC(i, k);
      }
    }
  }
}

void deleteC(int i) {
  if (c.get(i).size()<3) {
    c.remove(i);
  }
}

void splitC(int i, int j) {
  int ij=c.get(i).get(j);
  for (int k=0; k<c.get(i).size(); k++) {
    if (k!=j) {
      if (ij==c.get(i).get(k)) {
        if (k<j) {
          int temp=j;
          j=k;
          k=temp;
        }
        c.add(new ArrayList<Integer>());
        for (int l=j; l<k; l++) {
          c.get(c.size()-1).add(c.get(i).get(j));
          c.get(i).remove(j);
        }
      }
    }
  }
}
