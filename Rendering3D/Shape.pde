import java.util.*;

public boolean isBetween(float x1, float y1, float x2, float y2, float x, float y) {
  if ((x == x1 && y == y1) || (x == x2 && y == y2)) return false;
  return ((y - y1)*(x2 - x1) == (x - x1)*(y2 - y1)
    && (x - x1)*(x - x2) <= 0 && (y - y1)*(y - y2) <= 0);
}

class Shape {

  class Point {
    float x, y;
    int vIndex;
    boolean used;
    LinkedList<Point> connections;

    public Point(float X, float Y) {
      x = X;
      y = Y;
      used = false;
      connections = new LinkedList<Point>();
    }

    public Point(float X, float Y, int VI) {
      this(X, Y);
      vIndex = VI;
    }

    public void add(Point p) {
      boolean addConfirm = true;
      if (!this.connections.contains(p)) {
        for (int i = 0; i < this.connections.size(); i++) {
          if ((this.connections.get(i).y - this.y) * (this.x - p.x) == (this.connections.get(i).x - this.x) * (this.y - p.y)) {
            float ratio;
            if (this.x == p.x) {
              ratio = (p.y - this.y) / (this.connections.get(i).y - this.y);
            } else {
              ratio = (p.x - this.x) / (this.connections.get(i).x - this.x);
            }
            if (0 < ratio && ratio < 1) {
              this.disconnect(this.connections.get(i));             
              break;
            } else if (ratio > 1) {
              addConfirm = false;
              break;
            }
          }
        }
        if (addConfirm) {
          this.connections.add(p);
        }
      }
    }

    public void connect(Point p) {
      if (!this.equals(p)) {
        this.add(p);
        p.add(this);
      }
    }

    public boolean disconnect(Point p) {
      boolean b = true;
      if (!this.connections.remove(p)) b = false;
      if (!p.connections.remove(this)) b = false;
      return b;
    }

    public final boolean equals(Object o) {
      if (o == this) return true;
      if (!(o instanceof Point)) return false;

      Point p = (Point) o;
      return this.x == p.x && this.y == p.y;
    }

    public final int hashCode() {
      return (int) (this.x * 1000000 + this.y);
    }

    public boolean between(Point p1, Point p2) {
      return isBetween(p1.x, p1.y, p2.x, p2.y, this.x, this.y);
    }

    public boolean insert(Point p1, Point p2) {
      int index1 = p1.connections.indexOf(p2);
      int index2 = p2.connections.indexOf(p1);
      if (index1 == -1 || index2 == -1) return false;

      p1.connections.set(index1, this);
      p2.connections.set(index2, this);
      this.connections.add(p1);
      this.connections.add(p2);

      return true;
    }

    public String toShortString() {
      return "(" + x + ", " + y + ")";
    }

    public String toString() {
      String s = this.toShortString() + " [";
      for (Point p : this.connections) {
        s += " " + p.toShortString() + " ;";
      }
      return s.substring(0, s.length() - (this.connections.size() == 0 ? 0 : 1)) + "]";
    }

    public void drawPoint(boolean includeConnections) {
      stroke(#ffffff);
      if (includeConnections) {
        for (Point p : this.connections) {
          line(this.x, this.y, p.x, p.y);
        }
      }
      stroke(#000000);
      fill(#ffffff);
      circle(this.x, this.y, 3);
    }
  }

  class SortPoints implements Comparator<Point> {
    public int compare(Point a, Point b) {
      if (a.x > b.x) return 1;
      if (a.x < b.x) return -1;
      if (a.y > b.y) return 1;
      if (a.y < b.y) return -1;
      return 0;
    }
  }

  class SortPOIs implements Comparator<float[]> {
    float[][] vertices;
    int sortIndex;

    public SortPOIs(float[][] v, int s) {
      vertices = v;
      sortIndex = s;
    }

    public int compare(float[] a, float[] b) {
      if (a[sortIndex] == b[sortIndex]) {
        float[] vertex = vertices[(int) a[sortIndex]];

        return pow(a[0] - vertex[0], 2) + pow(a[1] - vertex[1], 2)
          > pow(b[0] - vertex[0], 2) + pow(b[1] - vertex[1], 2) ? 1 : -1;
      }
      return a[sortIndex] > b[sortIndex] ? 1 : -1;
    }
  }

  public void removeDuplicates(LinkedList<Point> l) {
    Collections.sort(l, new SortPoints());
    for (int i = 0; i < l.size() - 1; i++) {
      if (l.get(i).equals(l.get(i + 1))) {
        Point p = l.get(i + 1);
        Point pCN;

        while (p.connections.size() > 0) {
          pCN = p.connections.get(0);
          while (pCN.disconnect(p));
          pCN.connect(l.get(i));
        }
        l.remove(i + 1);
        i--;
      }
    }
  }

  private float[][] vertices;
  private float minX, maxX, minY, maxY;
  private color col;

  public Shape(float ... v) {
    if (v.length % 2 == 0) {
      minX = Float.MAX_VALUE;
      maxX = Float.MIN_VALUE;
      minY = Float.MAX_VALUE;
      maxY = Float.MIN_VALUE;
      vertices = new float[v.length / 2][2];
      for (int i = 0; i < vertices.length; i++) {
        vertices[i][0] = v[2*i];
        vertices[i][1] = v[2*i + 1];

        if (vertices[i][0] > maxX) maxX = vertices[i][0];
        if (vertices[i][0] < minX) minX = vertices[i][0];
        if (vertices[i][1] > maxY) maxY = vertices[i][1];
        if (vertices[i][1] < minY) minY = vertices[i][1];
      }
    }
    col = #000000;
  }
  
  public Shape(Shape s) {
    vertices = s.vertices;
    minX = s.minX;
    minY = s.minY;
    maxX = s.maxX;
    maxY = s.maxY;
    col = s.col;
  }
  
  public float[] getVert(int index) {
    return vertices[index];
  }
  
  public void setCol(color c) {
    col = c;
  }
  
  public color getCol() {
    return col;
  }

  public void drawShape(boolean stroke) {
    fill(col);
    stroke(stroke ? #000000 : col);
    beginShape();
    for (float[] f : vertices) {
      vertex(f[0], f[1]);
    }
    endShape(CLOSE);
  }

  public int numVertices() {
    return vertices.length;
  }

  public void updateMaxMin() {
    minX = Float.MAX_VALUE;
    maxX = Float.MIN_VALUE;
    minY = Float.MAX_VALUE;
    maxY = Float.MIN_VALUE;
    for (float[] v : vertices) {
      if (v[0] > maxX) maxX = v[0];
      if (v[0] < minX) minX = v[0];
      if (v[1] > maxY) maxY = v[1];
      if (v[1] < minY) minY = v[1];
    }
  }
  
  public float[] centre() { //{ x, y }
    float totalX = 0, totalY = 0;
    for (float[] v : vertices) {
      totalX += v[0];
      totalY += v[1];
    }
    return new float[] { totalX/numVertices(), totalY/numVertices() };
  }

  public boolean contains(float x, float y) {
    if (x < minX || x > maxX || y < minY || y > maxY) return false;

    float[] outsidePt = { minX - 1, minY - 1 };
    float[] v, vNext;
    float xPOI;
    int numIntersections = 0;

    for (int i = 0; i < vertices.length; i++) {
      v = vertices[i];
      vNext = vertices[(i + 1) % vertices.length];

      if (x == v[0] && y == v[1]) return true;

      if ((y - v[1])*(vNext[0] - v[0]) == (x - v[0])*(vNext[1] - v[1])
        && (x - v[0])*(x - vNext[0]) <= 0 && (y - v[1])*(y - vNext[1]) <= 0) return true;

      //For each side, checking if a segment between the point and outsidePt intersects that side segment
      if (v[0] == vNext[0]) { //the line connecting the vertices is vertical
        float yPOI = (v[0] - outsidePt[0])*(y - outsidePt[1])/(x - outsidePt[0]) + outsidePt[1];
        if (yPOI > minY && yPOI < y && (yPOI - v[1])*(yPOI - vNext[1]) < 0) { //If the y-value of POI is inside both segments
          numIntersections++;
        }
      } else if ((y - outsidePt[1])*(vNext[0] - v[0]) != (x - outsidePt[0])*(vNext[1] - v[1])) { //If the two segments are NOT parallel
        xPOI = (outsidePt[0]*(y - outsidePt[1])/(x - outsidePt[0]) - v[0]*(vNext[1] - v[1])/(vNext[0] - v[0]) + v[1] - outsidePt[1])
          / ((y - outsidePt[1])/(x - outsidePt[0]) - (vNext[1] - v[1])/(vNext[0] - v[0])); //x-value of POI

        if (xPOI > minX && xPOI < x && (xPOI - v[0])*(xPOI - vNext[0]) < 0) {
          numIntersections++;
        } else if (xPOI == v[0] || xPOI == vNext[0]) {
          i = -1;
          outsidePt[1] -= 1;
        }
      }
    }
    return numIntersections % 2 == 1;
  }

  public LinkedList<Point> containedVertices(Shape s) {
    LinkedList<Point> cV = new LinkedList<Point>();
    int tempIndex;
    for (int i = 0; i < this.vertices.length; i++) {
      if (s.contains(vertices[i][0], vertices[i][1])) {
        cV.add(new Point(vertices[i][0], vertices[i][1], i));
        if (i > 0) {
          tempIndex = cV.indexOf(new Point(vertices[i - 1][0], vertices[i - 1][1]));
          if (tempIndex != -1) {
            cV.get(tempIndex).connect(cV.getLast());
          }
          if (i == this.vertices.length - 1) {
            tempIndex = cV.indexOf(new Point(vertices[0][0], vertices[0][1]));
            if (tempIndex != -1) {
              cV.get(tempIndex).connect(cV.getLast());
            }
          }
        }
      }
    }
    return cV;
  }

  float[] POICheck(float[] v1, float[] v1Next, float[] v2, float[] v2Next) {
    float xPOI, yPOI;
    if (((v1Next[0] - v1[0])*(v2Next[1] - v2[1]) != (v1Next[1] - v1[1])*(v2Next[0] - v2[0]))
      && !v1.equals(v2) && !v1.equals(v2Next) && !v1Next.equals(v2) && !v1Next.equals(v2Next)) { //if the two lines aren't parallel and share no vertex
      if (v1[0] == v1Next[0]) {
        xPOI = v1[0];
        yPOI = (xPOI - v2[0])*(v2Next[1] - v2[1])/(v2Next[0] - v2[0]) + v2[1];
        if ((yPOI - v1[1])*(yPOI - v1Next[1]) <= 0 && (xPOI - v2[0])*(xPOI - v2Next[0]) <= 0) { //check if y-value is within both segments
          return new float[] { xPOI, yPOI };
        }
      } else if (v2[0] == v2Next[0]) {
        xPOI = v2[0];
        yPOI = (xPOI - v1[0])*(v1Next[1] - v1[1])/(v1Next[0] - v1[0]) + v1[1];
        if ((xPOI - v1[0])*(xPOI - v1Next[0]) <= 0 && (yPOI - v2[1])*(yPOI - v2Next[1]) <= 0) { //check if y-value is within both segments
          return new float[] { xPOI, yPOI };
        }
      } else {
        xPOI = (v1[0]*(v1Next[1] - v1[1])/(v1Next[0] - v1[0]) - v2[0]*(v2Next[1] - v2[1])/(v2Next[0] - v2[0]) + v2[1] - v1[1])
          / ((v1Next[1] - v1[1])/(v1Next[0] - v1[0]) - (v2Next[1] - v2[1])/(v2Next[0] - v2[0]));
        if ((xPOI - v1[0])*(xPOI - v1Next[0]) <= 0 && (xPOI - v2[0])*(xPOI - v2Next[0]) <= 0) {
          yPOI = (xPOI - v1[0])*(v1Next[1] - v1[1])/(v1Next[0] - v1[0]) + v1[1];
          return new float[] { xPOI, yPOI };
        }
      }
    }
    return null;
  }

  public LinkedList<Point> overlapVertices(Shape s) {
    LinkedList<Point> cV1 = this.containedVertices(s);
    LinkedList<Point> cV2 = s.containedVertices(this);
    LinkedList<Point> oV = new LinkedList<Point>();

    oV.addAll(cV1);
    oV.addAll(cV2);

    removeDuplicates(oV);

    LinkedList<float[]> POIs = new LinkedList<float[]>();
    float[] v1, v1Next, v2, v2Next;
    for (int i = 0; i < this.vertices.length; i++) {
      v1 = this.vertices[i];
      v1Next = this.vertices[(i + 1) % this.vertices.length];
      for (int j = 0; j < s.numVertices(); j++) {
        v2 = s.vertices[j];
        v2Next = s.vertices[(j + 1) % s.vertices.length];

        float[] POI = POICheck(v1, v1Next, v2, v2Next); 
        if (POI != null) POIs.add(new float[] { POI[0], POI[1], i, j });
      }
    }

    if (POIs.size() > 0) {

      LinkedList<Point> POIPoints = new LinkedList<Point>();   

      Collections.sort(POIs, new SortPOIs(this.vertices, 2));

      int tempIndex;

      for (int i = 0; i < POIs.size(); i++) {
        POIPoints.add(new Point(POIs.get(i)[0], POIs.get(i)[1]));
        if (i > 0) {
          if (POIs.get(i - 1)[2] == POIs.get(i)[2]) {
            POIPoints.get(i).connect(POIPoints.get(i - 1));
          } else {
            tempIndex = cV1.indexOf(new Point(this.vertices[(int) POIs.get(i)[2]][0], this.vertices[(int) POIs.get(i)[2]][1]));
            if (tempIndex != -1) {
              POIPoints.get(i).connect(cV1.get(tempIndex));
            }
            if (POIs.get(i - 1)[2] + 1 == POIs.get(i)[2] && tempIndex != -1) {
              POIPoints.get(i - 1).connect(cV1.get(tempIndex));
            } else {

              tempIndex = cV1.indexOf(new Point(this.vertices[(int) POIs.get(i - 1)[2] + 1][0], this.vertices[(int) POIs.get(i - 1)[2] + 1][1]));
              if (tempIndex != -1) {
                POIPoints.get(i - 1).connect(cV1.get(tempIndex));
              }
            }
          }
        }
      }

      int vertexIndex = ((int) POIs.getLast()[2] + 1) % this.vertices.length;
      tempIndex = cV1.indexOf(new Point(this.vertices[vertexIndex][0], this.vertices[vertexIndex][1]));
      if (tempIndex != -1) {
        POIPoints.getLast().connect(cV1.get(tempIndex));
      }

      tempIndex = cV1.indexOf(new Point(this.vertices[(int) POIs.get(0)[2]][0], this.vertices[(int) POIs.get(0)[2]][1]));
      if (tempIndex != -1) {
        POIPoints.get(0).connect(cV1.get(tempIndex));
      }

      LinkedList<Point> POIPoints2 = new LinkedList<Point>();

      Collections.sort(POIs, new SortPOIs(s.vertices, 3));


      for (int i = 0; i < POIs.size(); i++) {
        POIPoints2.add(new Point(POIs.get(i)[0], POIs.get(i)[1]));
        if (i > 0) {
          if (POIs.get(i - 1)[3] == POIs.get(i)[3]) {
            POIPoints2.get(i).connect(POIPoints2.get(i - 1));
          } else {
            tempIndex = cV2.indexOf(new Point(s.vertices[(int) POIs.get(i)[3]][0], s.vertices[(int) POIs.get(i)[3]][1]));
            if (tempIndex != -1) {
              POIPoints2.get(i).connect(cV2.get(tempIndex));
            }
            if (POIs.get(i - 1)[3] + 1 == POIs.get(i)[3] && tempIndex != -1) {
              POIPoints2.get(i - 1).connect(cV2.get(tempIndex));
            } else {
              tempIndex = cV2.indexOf(new Point(s.vertices[(int) POIs.get(i - 1)[3] + 1][0], s.vertices[(int) POIs.get(i - 1)[3] + 1][1]));
              if (tempIndex != -1) {
                POIPoints2.get(i - 1).connect(cV2.get(tempIndex));
              }
            }
          }
        }
      }

      vertexIndex = ((int) POIs.getLast()[3] + 1) % s.vertices.length;
      tempIndex = cV2.indexOf(new Point(s.vertices[vertexIndex][0], s.vertices[vertexIndex][1]));
      if (tempIndex != -1) {
        POIPoints2.getLast().connect(cV2.get(tempIndex));
      }

      tempIndex = cV2.indexOf(new Point(s.vertices[(int) POIs.get(0)[3]][0], s.vertices[(int) POIs.get(0)[3]][1]));
      if (tempIndex != -1) {
        POIPoints2.get(0).connect(cV2.get(tempIndex));
      }

      POIPoints.addAll(POIPoints2);
      removeDuplicates(POIPoints);

      oV.addAll(POIPoints);
      removeDuplicates(oV);
    }

    return oV;
  }

  public LinkedList<Shape> overlap(Shape s) {
    LinkedList<Point> oV = this.overlapVertices(s);

    if (oV.size() == 0) {
      return new LinkedList<Shape>();
    }

    Point currentPoint;

    LinkedList<LinkedList<Point>> orderedOV = new LinkedList<LinkedList<Point>>();
    orderedOV.add(new LinkedList<Point>());
    orderedOV.getLast().add(oV.get(0));

    boolean exit = false;

    while (!exit) {
      currentPoint = orderedOV.getLast().getLast();
      if (currentPoint == null) {
        orderedOV.getLast().removeLast();
        orderedOV.add(new LinkedList<Point>());
        for (Point p : oV) {
          if (!p.used) {
            orderedOV.getLast().add(p);
            p.used = true;
            break;
          }
        }
        if (orderedOV.getLast().size() == 0) exit = true;
      } else {
        for (Point p : currentPoint.connections) {
          float midX = 0.5*(currentPoint.x + p.x);
          float midY = 0.5*(currentPoint.y + p.y);
          if (orderedOV.getLast().size() < 2 || p != orderedOV.getLast().get(orderedOV.getLast().size() - 2)) {
            float dX = 0;
            float dY = 0;
            if (midX == p.x) {
              dX = 0.0001;
            } else {
              dY = 0.0001;
            }
            if ((this.contains(midX + dX, midY + dY) && s.contains(midX + dX, midY + dY))
              || (this.contains(midX - dX, midY - dY) && s.contains(midX - dX, midY - dY))) {
              if (p.used) {
                orderedOV.getLast().add(null);
              } else {
                orderedOV.getLast().add(p);
                p.used = true;
                //println(p);
              }
              break;
            }
          }
        }
        if (orderedOV.getLast().getLast() == currentPoint) {
          orderedOV.getLast().add(null);
        }
      }
    }
    LinkedList<Shape> overlapShapes = new LinkedList<Shape>();
    float[] shapeArgs;
    for (int i = 0; i < orderedOV.size(); i++) {
      if (orderedOV.get(i).size() < 3) {
        orderedOV.remove(i);
        i--;
      } else {
        shapeArgs = new float[orderedOV.get(i).size() * 2];
        for (int j = 0; j < orderedOV.get(i).size(); j++) {
          shapeArgs[2*j] = (orderedOV.get(i).get(j).x);
          shapeArgs[2*j + 1] = (orderedOV.get(i).get(j).y);
        }

        overlapShapes.add(new Shape(shapeArgs));
      }
    }
    return overlapShapes;
  }
}
