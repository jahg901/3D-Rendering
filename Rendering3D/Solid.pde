public class Solid {
  int numVertices, numFaces;
  LinkedList<int[]> vertexMatches;
  
  PVector[] vertices;
  color[] cols;
  
  public Solid(int[][] vertexMatches0, PVector[] vertices0, color[] cols0) {
    this();
    if (cols0.length == vertexMatches0.length) {
      vertexMatches = new LinkedList(Arrays.asList(vertexMatches0));
      vertices = vertices0;
      cols = cols0;
      
      numVertices = vertices.length;
      numFaces = vertexMatches.size();
    }
  }
  
  public Solid() {
    numVertices = 0;
    numFaces = 0;
    vertexMatches = new LinkedList<int[]>();
    vertices = null;
    cols = null;
  }
    
}
