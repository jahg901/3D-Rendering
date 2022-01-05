class Cube extends Solid {
  
  Cube(float x, float y, float z, float xSize, float ySize, float zSize, color col1, color col2, color col3, color col4, color col5, color col6) {  
    numFaces = 6;
    numVertices = 8;
    vertexMatches = new LinkedList<int[]>(Arrays.asList(new int[]{ 0, 1, 4, 2 }, new int[]{ 3, 5, 7, 6 }, new int[]{ 0, 1, 5, 3 },
                                                        new int[]{ 2, 4, 7, 6 }, new int[]{ 0, 2, 6, 3 }, new int[]{ 1, 4, 7, 5 }));
    
    vertices = new PVector[] { new PVector(x, y, z), new PVector(x + xSize, y, z), new PVector(x, y + ySize, z), new PVector(x, y, z + zSize),
                               new PVector(x + xSize, y + ySize, z), new PVector(x + xSize, y, z + zSize), new PVector(x, y + ySize, z + zSize),
                               new PVector(x + xSize, y + ySize, z + zSize)};
    
    cols = new color[] { col1, col2, col3, col4, col5, col6 };
  }
}
