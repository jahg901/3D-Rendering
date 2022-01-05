//fix viewDirection in order to find closest distance and solve overlaps

final int NUM_SOLIDS = 1;
final float ANGLE_WIDTH = 60;
final float ANGLE_HEIGHT = 60;

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

int closestFace0(Shape overlap, LinkedList<Integer> indices, Face[] faces) {
  float minDist = 1e12;
  int closeFace = 0;
  float[] comparePoint = overlap.centre();
  
  for (int index : indices) {
    int[] vMatches = faces[index].parentSolid.vertexMatches.get(faces[index].faceIndex);
    
    PVector[] refVertices = new PVector[3];
    float[][] projVertices = new float[3][2];
    for (int i = 0; i < 3; i++) {
      refVertices[i] = faces[index].parentSolid.vertices[vMatches[i]];
      projVertices[i] = projectedPixel(refVertices[i]);
    }
    
    float coeff1 = (projVertices[0][0] * (projVertices[2][1] - comparePoint[1])) + (projVertices[2][0] * (comparePoint[1] - projVertices[0][1])) + comparePoint[0] * (projVertices[0][1] - projVertices[2][1]);
    float coeff2 = (projVertices[0][0] * (comparePoint[1] - projVertices[1][1])) + (projVertices[1][0] * (projVertices[0][1] - comparePoint[1])) + comparePoint[0] * (projVertices[1][1] - projVertices[0][1]);
    float divisor = (projVertices[0][0] * (projVertices[2][1] - projVertices[1][1])) + (projVertices[1][0] * (projVertices[0][1] - projVertices[2][1])) + (projVertices[2][0] * (projVertices[1][1] - projVertices[0][1]));
    
    PVector point3D = PVector.add(PVector.add(PVector.mult(refVertices[0], 1 - (coeff1 + coeff2)/divisor), PVector.mult(refVertices[1], coeff1/divisor)), PVector.mult(refVertices[2], coeff2/divisor));
  }
  
  return closeFace;
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
      if (angleIncline == 0) {
        C = -1;
        D = -1;
      } else {
        C = 1;
        D = 1;
      }
    } else {
      A = -1;
      if (angleIncline == 0) {
        C = 1;
        D = -1;
      } else {
        C = -1;
        D = 1;
      }
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

/*float[] projectedPixel0(PVector vertex) {

  PVector v = PVector.sub(vertex, location);
  float vF = PVector.dot(v, viewVecUnit);
  float vLR = PVector.dot(v, viewLRVec) / viewWidth;
  float vUD = PVector.dot(v, viewUDVec) / viewHeight;

  return new float[] { (vLR / (vF * viewWidth) + 1) * width/2.0, (vUD / (vF * viewHeight) + 1) * height/2.0 };
} */

float[] projectedPixel(PVector vertex) {
  PVector v = PVector.sub(vertex, location);
  PVector vUD = viewUDVec.normalize(null);
  PVector vLR = viewLRVec.normalize(null).mult(-1);
  
  float angleLR = PVector.angleBetween(viewVecUnit, PVector.sub(v, PVector.mult(vUD, PVector.dot(v, vUD))));
  float angleUD = PVector.angleBetween(viewVecUnit, PVector.sub(v, PVector.mult(vLR, PVector.dot(v, vLR))));
  angleLR = PVector.dot(v, vLR) > 0 ? abs(angleLR) : -abs(angleLR);
  angleUD = PVector.dot(v, vUD) > 0 ? abs(angleUD) : -abs(angleUD);
  
  return new float[] { (angleLR / radians(ANGLE_WIDTH) + 0.5) * width, (angleUD / radians(ANGLE_HEIGHT) + 0.5) * height };
}

PVector viewDirection(float[] pixel) {
  PVector vLR = viewLRVec.normalize(null).mult(-1);
  PVector vUD = viewUDVec.normalize(null);
  
  float angleLR = radians(ANGLE_WIDTH)*(pixel[0]/width - 0.5);
  float angleUD = radians(ANGLE_HEIGHT)*(pixel[1]/height - 0.5);
  
  println();
  println(degrees(angleLR));
  println(degrees(angleUD));
  
  return rotateVector(rotateVector(viewVecUnit, vUD, angleLR), vLR, -angleUD).normalize(); //issue here
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
      vertexPixels[i] = projectedPixel(vertices[i]);
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
  solveOverlaps(faces, 0);
}

void solveOverlaps(Face[] faces, int abc) { //Shit
  LinkedList<Shape> overlaps = new LinkedList<Shape>();
  LinkedList<int[]> indices = new LinkedList<int[]>();

  LinkedList<Face> overlapFaces = new LinkedList<Face>();

  for (int i = 0; i < faces.length; i++) {
    for (int j = 0; j < i; j++) {
      LinkedList<Shape> currentOverlaps = faces[i].overlap(faces[j]);
      overlaps.addAll(currentOverlaps);
      for (Shape s : currentOverlaps) {
        indices.add(new int[] {i, j});
      }
    }
  }

  if (overlaps.size() > 0) {
    for (int i = 0; i < overlaps.size(); i++) {
      float[] distances = new float[2];
      float[] overlapCentre = overlaps.get(i).centre();

      for (int k = 0; k < 2; k++) {
        float[][] coords = new float[3][2];
        float[] coordDistances = new float[3];

        for (int j = 0; j < 3; j++) {
          Face face0 = faces[indices.get(i)[k]];
          PVector vertex = face0.parentSolid.vertices[face0.parentSolid.vertexMatches.get(face0.faceIndex)[j]];
          coords[j] = projectedPixel(vertex);
          coordDistances[j] = PVector.sub(vertex, location).mag();
        }

        float u1 = (coords[1][1] - coords[0][1])*(coordDistances[2] - coordDistances[0]) - (coordDistances[1] - coordDistances[0])*(coords[2][1] - coords[0][1]);
        float u2 = (coordDistances[1] - coordDistances[0])*(coords[2][0] - coords[0][0]) - (coords[1][0] - coords[0][0])*(coordDistances[2] - coordDistances[0]);
        float u3 = (coords[1][0] - coords[0][0])*(coords[2][1] - coords[0][1]) - (coords[1][1] - coords[0][1])*(coords[2][0] - coords[0][0]);

        distances[k] = u1/u3*(coords[0][0] - overlapCentre[0]) + u2/u3*(coords[0][1] - overlapCentre[1]) + coordDistances[0];
      }

      int closerShape = distances[0] < distances[1] ? 0 : 1;
      overlaps.get(i).setCol(faces[indices.get(i)[closerShape]].getCol());
      overlaps.get(i).drawShape(false);

      overlapFaces.add(new Face(faces[indices.get(i)[closerShape]].parentSolid, faces[indices.get(i)[closerShape]].faceIndex, overlaps.get(i)));
    }

    solveOverlaps(overlapFaces.toArray(new Face[overlapFaces.size()]), abc + 1);
  }
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
  location = new PVector(-400, 0, 0);
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
    println();
    for (Face F : f) {
      for (int i = 0; i < F.numVertices(); i++) {
        print(Arrays.toString(F.getVert(i)) + " ");
      }
      println();
    }
    break;
  }
}
