//fix viewDirection in order to find closest distance and solve overlaps

final int NUM_SOLIDS = 1;
final float ANGLE_WIDTH = 60;
final float ANGLE_HEIGHT = 60;
final float maxLR = radians(ANGLE_WIDTH / 2 + 1);
final float maxUD = radians(ANGLE_HEIGHT / 2 + 1);

float viewWidth, viewHeight;
float angleFlat, angleIncline, angleRotate, angleRot, angleAdjusted;
PVector location, viewVector, viewVecUnit, viewLRVec, viewUDVec;
int moveFB, moveLR, moveUD, changeFlat, changeIncline, changeRotate;

Solid[] sol = new Solid[NUM_SOLIDS];
Face[] f;
int[] dist;

PVector rotateVector(PVector v, PVector perpAxis, float ang) {
  return PVector.add(PVector.mult(v, cos(ang)), perpAxis.cross(v).mult(sin(ang)));
}

void findAllOverlaps(Shape[] shapes, LinkedList<Shape> totalOverlaps, LinkedList<LinkedList<Integer>> totalIndexList) {

   LinkedList<Shape> overlaps = new LinkedList<Shape>(Arrays.asList(shapes));
   LinkedList<LinkedList<Integer>> indexList = new LinkedList<LinkedList<Integer>>();
   for (int i = 1; i < shapes.length; i++) {
     indexList.add(new LinkedList<Integer>(Arrays.asList(i)));
   }
   
   for (int size = 1; size < shapes.length; size++) {
     LinkedList<Shape> newOverlaps = new LinkedList<Shape>();
     LinkedList<LinkedList<Integer>> newIndexList = new LinkedList<LinkedList<Integer>>();
     
     for (int overlapIndex = 0; overlapIndex < overlaps.size(); overlapIndex++) {
       for (int shapeIndex = indexList.get(overlapIndex).getLast() + 1; shapeIndex < shapes.length; shapeIndex++) {
         LinkedList<Shape> currentOverlap = overlaps.get(overlapIndex).overlap(shapes[shapeIndex]);
         newOverlaps.addAll(currentOverlap);
         for (Shape s : currentOverlap) {
           newIndexList.add(new LinkedList<Integer>(indexList.get(overlapIndex)));
           newIndexList.getLast().add(shapeIndex);
         }
       }
     }
     
     totalOverlaps.addAll(newOverlaps);
     totalIndexList.addAll(newIndexList);
     overlaps = newOverlaps;
     indexList = newIndexList;
   }
}

int closestFace(Shape overlap, LinkedList<Integer> indices, Face[] faces) {
  float minDist = 1e12;
  int closeFace = 0;
  float[] comparePoint = overlap.centre();
  
  for (int index : indices) {
    int[] vMatches = faces[index].parentSolid.vertexMatches.get(faces[index].faceIndex);
    
    PVector[] refVertices = new PVector[3];
    for (int i = 0; i < 3; i++) refVertices[i] = faces[index].parentSolid.vertices[vMatches[i]];
    
    
  }
  
  return closeFace;
}

float add(float a, float b, float boundary) {
  a = (a + b) % boundary;
  if (a < 0) {
    a += boundary;
  }
  return a;
}

int add(int a, int b, int boundary) {
  a = (a + b) % boundary;
  if (a < 0) {
    a += boundary;
  }
  return a;
}

void setAngleRot() {
  if (angleIncline > 90 && angleIncline <= 270) {
    angleRot = -angleRotate;
  } else {
    angleRot = angleRotate;
  }
}

void setView() {
  if (angleIncline == 90) {
    viewVector.set(0, 0, 1);
  } else if (angleIncline == 270) {
    viewVector.set(0, 0, -1);
  } else {
    viewVector.set(cos(radians(angleFlat)), sin(radians(angleFlat)), tan(radians(angleIncline)));
  }

  if (angleIncline > 90 && angleIncline < 270) {
    viewVector.mult(-1.0);
  }
}

void setAngle() {
  if (angleIncline == 90 || angleIncline == 270) {
    angleAdjusted = angleRot + angleFlat;
  } else if (angleFlat == 90 || angleFlat == 270) {
    angleAdjusted = angleRot + angleFlat;
    if ((angleIncline > 90 && angleIncline < 180) || angleIncline > 270) {
      angleAdjusted += 180;
    }
  } else {
    angleAdjusted = angleRot + degrees(atan(tan(radians(angleFlat)) * tan(radians(angleIncline)) / viewVector.mag()));
    if (90 < angleFlat && angleFlat < 270) {
      angleAdjusted += 180;
    }
  }

  angleAdjusted = angleAdjusted % 360;
  if (angleAdjusted < 0) {
    angleAdjusted += 360;
  }
}

void setScope() {
  if ((angleFlat == 90 || angleFlat == 270) && (angleIncline == 0 || angleIncline == 180)) {
    int A, B, C, D;
    B = -1;
    if (angleFlat == 90) {
      A = 1;
      C = D = (angleIncline == 0 ? -1 : 1);
    } else {
      A = -1;
      C = angleIncline == 0 ? 1 : -1;
      D = -C;
    }

    viewLRVec.set(A * cos(radians(angleRot)), 0, B * sin(radians(angleRot)));
    viewUDVec.set(C * sin(radians(angleRot)), 0, D * cos(radians(angleRot)));
  } else {
    float X = viewVector.x;
    float Y = viewVector.y;
    float Z = viewVector.z;
    float mag = viewVector.mag();
    float angle = radians(angleAdjusted);

    viewUDVec.set(Z*cos(angle) - (X*Y*sin(angle)/mag), (pow(X, 2) + pow(Z, 2))*sin(angle)/mag, - X*cos(angle) - (Y*Z*sin(angle)/mag));
    viewLRVec.set(X*Y*cos(angle) + mag*Z*sin(angle), -(pow(X, 2) + pow(Z, 2))*cos(angle), Y*Z*cos(angle) - mag*X*sin(angle));

    if (angleIncline > 90 && angleIncline <= 270) {
      viewUDVec.mult(-1.0);
    }
  }

  viewLRVec.setMag(viewWidth);
  viewUDVec.setMag(viewHeight);
}

float[] projectedPixel(PVector vertex, PVector lastVertex) { //Make a projectedShape function based on this; we need it now
  PVector v = PVector.sub(vertex, location); 
  PVector vUD = viewUDVec.normalize(null);
  PVector vLR = viewLRVec.normalize(null).mult(-1);
  
  float angleLR = PVector.angleBetween(viewVecUnit, PVector.sub(v, PVector.mult(vUD, PVector.dot(v, vUD)))) * (PVector.dot(v, vLR) > 0 ? 1 : -1);
  float angleUD = PVector.angleBetween(viewVecUnit, PVector.sub(v, PVector.mult(vLR, PVector.dot(v, vLR)))) * (PVector.dot(v, vUD) > 0 ? 1 : -1);
  
  return new float[] { (angleLR / radians(ANGLE_WIDTH) + 0.5) * width, (angleUD / radians(ANGLE_HEIGHT) + 0.5) * height };
}

float[] projAngle(PVector vertex) {
  PVector v = PVector.sub(vertex, location); 
  PVector vUD = viewUDVec.normalize(null);
  PVector vLR = viewLRVec.normalize(null).mult(-1);
  
  float angleLR = PVector.angleBetween(viewVecUnit, PVector.sub(v, PVector.mult(vUD, PVector.dot(v, vUD)))) * (PVector.dot(v, vLR) > 0 ? 1 : -1);
  float angleUD = PVector.angleBetween(viewVecUnit, PVector.sub(v, PVector.mult(vLR, PVector.dot(v, vLR)))) * (PVector.dot(v, vUD) > 0 ? 1 : -1);
  
  return new float[] { angleLR, angleUD };
}

PVector segmentPlanePOI(PVector planeNormal, PVector startPoint, PVector direction, float maxAngle, int angleIndex) {
  float intersect = PVector.dot(planeNormal, PVector.sub(location, startPoint)) / PVector.dot(planeNormal, direction);
  if (!(intersect > 1e-5 && intersect < 1 - 1e-5)) return null;
  
  PVector POI = PVector.add(startPoint, PVector.mult(direction, intersect));
  if (maxAngle != 0 && abs(projAngle(POI)[angleIndex]) > maxAngle) return null;
  
  return POI;
}

Shape projection(PVector[] vertices3D) { //figure out case where object takes up full screen
  PVector[] allCorners = { viewDirection(width+width/ANGLE_WIDTH, -height/ANGLE_HEIGHT).mult(100), viewDirection(width+width/ANGLE_WIDTH, height+height/ANGLE_HEIGHT).mult(100), viewDirection(-width/ANGLE_WIDTH, height+height/ANGLE_HEIGHT).mult(100), viewDirection(-width/ANGLE_WIDTH, -height/ANGLE_HEIGHT).mult(100) }; //figure out where the corners are; corners[i] stores corner between plane i and plane i+1

  float[][] cornerAngles = new float[4][2];
  print("Corners: ");
  for (int i = 0; i < 4; i++) {
    cornerAngles[i] = projAngle(PVector.add(location, allCorners[i]));
    cornerAngles[i][0] = degrees(cornerAngles[i][0]);
    cornerAngles[i][1] = degrees(cornerAngles[i][1]);
    print(Arrays.toString(cornerAngles[i]) + " ");
  }
  println();
  
  LinkedList<PVector> addCorners = new LinkedList<PVector>();
  
  PVector vUD = viewUDVec.normalize(null);
  PVector vLR = viewLRVec.normalize(null).mult(-1);  
  
  // { top, right, bottom, left }
  PVector[] boundPlaneNormals = { vLR.cross(rotateVector(viewVecUnit, vLR, -maxUD)), vUD.cross(rotateVector(viewVecUnit, vUD, -maxLR)), vLR.cross(rotateVector(viewVecUnit, vLR, maxUD)), vUD.cross(rotateVector(viewVecUnit, vUD, maxLR)) };
  
  int exitPlane = 0; //0 is top, 1 is right, 2 is bottom, 3 is left, n is n % 4
  int planeChange = 0;
  boolean nextNull = false;
  
  int k = -1;
  float[] angle;
  do {
    k++;
    angle = k == vertices3D.length ? new float[] { 0, 0 } : projAngle(vertices3D[k]);
  } while ((abs(angle[0]) > maxLR || abs(angle[1]) > maxUD) && k < vertices3D.length);
  if (k == vertices3D.length) {
    k = 0;
    boolean intersectionFound = false;
    do {
      PVector prevVec =  PVector.sub(vertices3D[add(k, -1, vertices3D.length)], vertices3D[k]);
      for (int i = 0; i < 4; i++) {
        int angleIndex = i % 2;
        if (segmentPlanePOI(boundPlaneNormals[i], vertices3D[k], prevVec, angleIndex == 0 ? maxLR : maxUD, angleIndex) != null) intersectionFound = true;
      }
      if (!intersectionFound) k++;
    } while (!intersectionFound && k < vertices3D.length);
    if (k == vertices3D.length) return null; 
  }
  
  println("Offset: " + k);

  LinkedList<PVector> verts = new LinkedList<PVector>(); 
  for (int i = 0; i < vertices3D.length; i++) verts.add(vertices3D[add(i, k, vertices3D.length)]);
  
  for (int i = 0; i < verts.size(); i++) { //issue with catching corners at the end of loop
    angle = projAngle(verts.get(i));
  
    int boundLR = angle[0] < -maxLR ? -1 : (angle[0] > maxLR ? 1 : 0);
    int boundUD = angle[1] < -maxUD ? 1 : (angle[1] > maxUD ? -1 : 0);
    
    if (boundLR == 0 && boundUD == 0) {
      planeChange = 0;
    } else {
      PVector prevVec = PVector.sub(verts.get(add(i, -1, verts.size())), verts.get(i)),
              nextVec = PVector.sub(verts.get(add(i, 1, verts.size())), verts.get(i));
      PVector prevPOI, nextPOI;
      int prevPlane, nextPlane = 0;
      
      if (boundUD == 0 || boundLR == 0) {
        if (boundLR == -1) {          
          prevPlane = nextPlane = 3;
        } else if (boundLR == 1) {
          prevPlane = nextPlane = 1;
        } else if (boundUD == -1) {
          prevPlane = nextPlane = 2;
        } else {
          prevPlane = nextPlane = 0;
        }
        int angleIndex = prevPlane % 2;
        prevPOI = segmentPlanePOI(boundPlaneNormals[prevPlane], verts.get(i), prevVec, angleIndex == 0 ? maxLR : maxUD, angleIndex);
        nextPOI = segmentPlanePOI(boundPlaneNormals[nextPlane], verts.get(i), nextVec, angleIndex == 0 ? maxLR : maxUD, angleIndex);
        
      } else {
        PVector prevHorPOI, prevVertPOI, nextHorPOI, nextVertPOI;
        int horPlane, vertPlane;
        
        horPlane = boundLR == -1 ? 3 : 1;
        vertPlane = boundUD == -1 ? 2 : 0;
        
        prevHorPOI = segmentPlanePOI(boundPlaneNormals[horPlane], verts.get(i), prevVec, maxUD, 1);
        nextHorPOI = segmentPlanePOI(boundPlaneNormals[horPlane], verts.get(i), nextVec, maxUD, 1);
        prevVertPOI = segmentPlanePOI(boundPlaneNormals[vertPlane], verts.get(i), prevVec, maxLR, 0);
        nextVertPOI = segmentPlanePOI(boundPlaneNormals[vertPlane], verts.get(i), nextVec, maxLR, 0);
        
        if (prevHorPOI == null) {
          prevPOI = prevVertPOI;
          prevPlane = vertPlane;
        } else {
          prevPOI = prevHorPOI;
          prevPlane = horPlane;
        }
        
        if (nextHorPOI == null) {
          nextPOI = nextVertPOI;
          nextPlane = vertPlane;
        } else {
          nextPOI = nextHorPOI;
          nextPlane = horPlane;
        }
      }
      
      if (nextNull) prevPOI = null;
      
      if (prevPOI != null) {
        exitPlane = prevPlane;
        planeChange = 0;
      }
      
      if (nextPOI != null) {
        if (add(nextPlane, -exitPlane - planeChange, 4) == 1) planeChange++;
        println(planeChange + " " + exitPlane);
        
        for (int j = 0; j < abs(planeChange); j++) {
          if (planeChange > 0) addCorners.add(allCorners[add(exitPlane, j, 4)]);
          else addCorners.add(allCorners[add(exitPlane, -j - 1, 4)]);
        }
        exitPlane = 0;
        planeChange = 0;
      } else {
        int currentPlane = add(exitPlane, planeChange, 4);
        float[] nextAngle = projAngle(verts.get(add(i, 1, verts.size())));
        int nextBoundLR = nextAngle[0] < -maxLR ? -1 : (nextAngle[0] > maxLR ? 1 : 0);
        int nextBoundUD = nextAngle[1] < -maxUD ? -1 : (nextAngle[1] > maxUD ? 1 : 0);

        if (boundLR == 0 || boundUD == 0) {   
          switch (currentPlane) {
            case 0:
              if (nextBoundLR == 1 && nextBoundUD != -1) planeChange++;
              if (nextBoundLR == -1) planeChange -= nextBoundUD == 1 ? 2 : 1;
              break;
            case 1:
              if (nextBoundUD == 1 && (nextBoundLR != 1)) planeChange++;
              if (nextBoundUD == -1) planeChange -= nextBoundLR == -1 ? 2 : 1;
              break;
            case 2:
              if (nextBoundLR == -1 && nextBoundUD != 1) planeChange++;
              if (nextBoundLR == 1) planeChange -= nextBoundUD == -1 ? 2 : 1;
              break;
            case 3:
              if (nextBoundUD == -1 && nextBoundLR != -1) planeChange++;
              if (nextBoundUD == 1) planeChange -= nextBoundLR == 1 ? 2 : 1;
              break;
          }
          
        } else {
          switch (currentPlane) {
            case 0:
              if (nextBoundLR == 1 && nextBoundUD != -1) planeChange++;
              else if (nextBoundLR == -1 && nextBoundUD != 1) planeChange--;
              else if (nextBoundLR == 0 && nextBoundUD == 1) planeChange += 2;
              else if (nextBoundLR == -1 && nextBoundUD == 1) {
                if (projAngle(segmentPlanePOI(boundPlaneNormals[currentPlane], verts.get(i), nextVec, 0, 0))[0] > 0) planeChange += 2;
                else planeChange -= 2;
              }
              break;
            case 1:
              if (nextBoundUD == 1 && nextBoundLR != 1) planeChange++;
              else if (nextBoundUD == -1 && nextBoundLR != -1) planeChange--;
              else if (nextBoundUD == 0 && nextBoundLR == -1) planeChange += 2;
              else if (nextBoundUD == -1 && nextBoundLR == -1) {
                if (projAngle(segmentPlanePOI(boundPlaneNormals[currentPlane], verts.get(i), nextVec, 0, 0))[1] < 0) planeChange += 2;
                else planeChange -= 2;
              }
              break;
            case 2:
              if (nextBoundLR == -1 && nextBoundUD != 1) planeChange++;
              else if (nextBoundLR == 1 && nextBoundUD != -1) planeChange--;
              else if (nextBoundLR == 0 && nextBoundUD == -1) planeChange += 2;
              else if (nextBoundLR == 1 && nextBoundUD == -1) {
                if (projAngle(segmentPlanePOI(boundPlaneNormals[currentPlane], verts.get(i), nextVec, 0, 0))[0] < 0) planeChange += 2;
                else planeChange -= 2;
              }
              break;
            case 3:
              if (nextBoundUD == -1 && nextBoundLR != -1) planeChange++;
              else if (nextBoundUD == 1 && nextBoundLR != 1) planeChange--;
              else if (nextBoundUD == 0 && nextBoundLR == 1) planeChange += 2;
              else if (nextBoundUD == 1 && nextBoundLR == 1) {
                if (projAngle(segmentPlanePOI(boundPlaneNormals[currentPlane], verts.get(i), nextVec, 0, 0))[1] > 0) planeChange += 2;
                else planeChange -= 2;
              }
              break;
          }
        }
      }
      
      float[][] ang = {projAngle(verts.get(i)), prevPOI == null ? null : projAngle(prevPOI), nextPOI == null ? null : projAngle(nextPOI)};
      for (float[] f : ang) {
        if (f != null) {
          f[0] = round(degrees(f[0]) * 10000) / 10000.0;
          f[1] = round(degrees(f[1]) * 10000) / 10000.0;
        }
      }
      println(Arrays.toString(ang[0]) + " -> " + (ang[1] == null ? null : Arrays.toString(ang[1])) + ", " + (ang[2] == null ? null : Arrays.toString(ang[2])));
           
      verts.remove(i);
      i--;
      if (prevPOI != null) {
        i++;
        verts.add(i, prevPOI);
      }
      if (nextPOI != null) {
        for (PVector c : addCorners) {
          i++;
          verts.add(i, PVector.add(c, location));
        }
        i++;
        verts.add(i, nextPOI);
      }
      nextNull = nextPOI == null;
    }
  }
  
  float[][] angles = new float[verts.size()][2];
  for (int i = 0; i < angles.length; i++) {
    angles[i] = projAngle(verts.get(i));
    angles[i][0] = round(degrees(angles[i][0]) * 100) / 100.0;
    angles[i][1] = round(degrees(angles[i][1]) * 100) / 100.0;
  }
  float[][] oldAngles = new float[vertices3D.length][2];
  for (int i = 0; i < oldAngles.length; i++) {
    oldAngles[i] = projAngle(vertices3D[i]);
    oldAngles[i][0] = round(degrees(oldAngles[i][0]) * 100) / 100.0;
    oldAngles[i][1] = round(degrees(oldAngles[i][1]) * 100) / 100.0;
  }
  print("Before: "); for (float[] a : oldAngles) print(Arrays.toString(a) + " ");
  println();
  print("After: "); for (float[] a : angles) print(Arrays.toString(a) + " ");
  println();
  println();
  
  return null;
}

PVector viewDirection(float ... pixel) { //Something wrong here?
  PVector vLR = viewLRVec.normalize(null).mult(-1);
  PVector vUD = viewUDVec.normalize(null);
  
  float angleLR = radians(ANGLE_WIDTH)*(pixel[0]/width - 0.5);
  float angleUD = radians(ANGLE_HEIGHT)*(pixel[1]/height - 0.5);
  
  PVector p = vUD.cross(rotateVector(viewVecUnit, vUD, -angleLR)).cross(vLR.cross(rotateVector(viewVecUnit, vLR, angleUD))).normalize();
  //p.x = -p.x;
  return p;
}

void vision() {

  int totalFaces = 0;
  for (Solid s : sol) {
    totalFaces += s.numFaces;
  }

  Face[] faces = new Face[totalFaces];

  int faceIndex = 0;

  for (int j = 0; j < sol.length; j++) {
    viewVecUnit.set(viewVector);
    viewVecUnit.normalize();

    PVector[] vertices = sol[j].vertices;
    float[][] vertexPixels = new float[8][2];

    for (int i = 0; i < sol[j].numVertices; i++) {
      vertexPixels[i] = projectedPixel(vertices[i], vertices[add(i, -1, sol[j].numVertices)]);
    }

    for (int i = 0; i < sol[j].numFaces; i++) {
      int[] matches = sol[j].vertexMatches.get(i);
      float[] faceParams = new float[matches.length * 2];
      for (int k = 0; k < matches.length; k++) {
        faceParams[2 * k] = vertexPixels[matches[k]][0];
        faceParams[2 * k + 1] = vertexPixels[matches[k]][1];
      }

      faces[faceIndex] = new Face(sol[j], i, faceParams);

      faces[faceIndex].drawShape(true);
      faceIndex++;
    }
  }

  f = faces;
  dist = new int[f.length];
}

void move() {
  if (moveFB != 0) {
    location.add(PVector.mult(viewVecUnit, moveFB));
  }
  if (moveLR != 0) {
    location.add(PVector.mult(viewLRVec, moveLR));
  }
  if (moveUD != 0) {
    location.add(PVector.mult(viewUDVec, -moveUD));
  }
  angleFlat = add(angleFlat, changeFlat, 360);
  angleIncline = add(angleIncline, changeIncline, 360);
  angleRotate = add(angleRotate, changeRotate, 360);
}

void setup() {
  frameRate(60);
  size(200, 200);
  location = new PVector(-200, 0, 0);
  angleFlat = 0;
  angleIncline = 0;
  angleRotate = 0;
  viewWidth = 0.5;
  viewHeight = 0.5;

  viewVector = new PVector();
  viewVecUnit = new PVector();
  viewLRVec = new PVector();
  viewUDVec = new PVector();

  //sol[0] = new Cube(0, 0, 0, 80, 80, 80, #cc0000, #00cc00, #0000cc, #cccc00, #cc00cc, #00cccc);
  //sol[1] = new Solid(new int[][] {{0, 1, 2}, {0, 2, 3}, {0, 1, 3}, {1, 2, 3}}, new PVector[] {new PVector(85, 85, 85), new PVector(100, 86, 85), new PVector(85, 100, 86), new PVector(86, 85, 120)}, new color[] {#ff0000, #00ff00, #0000ff, #ffff00});
  sol[0] = new Solid(new int[][] {{0, 1, 2, 3}}, new PVector[] {new PVector(0, 0, 0), new PVector(0, 80, 0), new PVector(0, 80, 80), new PVector(0, 0, 80)}, new color[] {#ff0000});
  //sol[1] = new Solid(new int[][] {{0, 1, 2, 3}}, new PVector[] {new PVector(80, 0, 0), new PVector(80, 80, 0), new PVector(80, 80, 80), new PVector(80, 0, 80)}, new color[] {#0000ff});
}

void draw() {
  background(#ffffff);
  setAngleRot();
  setView();
  setAngle();
  setScope();
  vision();
  move();
}

void keyPressed() {
  switch (keyCode) {
  case UP:
    moveFB = 1;
    break;
  case DOWN:
    moveFB = -1;
    break;
  case LEFT:
    moveLR = 1;
    break;
  case RIGHT:
    moveLR = -1;
    break;
  case 'W':
    changeIncline = 1;
    break;
  case 'A':
    changeFlat = -1;
    break;
  case 'S':
    changeIncline = -1;
    break;
  case 'D':
    changeFlat = 1;
    break;
  case 'K':
    moveUD = 1;
    break;
  case 'M':
    moveUD = -1;
    break;
  }
}

void keyReleased() {
  switch (keyCode) {
  case UP:
  case DOWN:
    moveFB = 0;
    break;
  case LEFT:
  case RIGHT:
    moveLR = 0;
    break;
  case 'W':
  case 'S':
    changeIncline = 0;
    break;
  case 'A':
  case 'D':
    changeFlat = 0;
    break;
  case 'K':
  case 'M':
    moveUD = 0;
    break;
  case ' ':
    /*println();
    for (Face F : f) {
      for (int i = 0; i < F.numVertices(); i++) {
        print(Arrays.toString(F.getVert(i)) + " ");
      }
      println();
    }*/
    projection(sol[0].vertices);
    break;
  }
}
