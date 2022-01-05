class Face extends Shape {
  
  Solid parentSolid;
  int faceIndex;
  
  public Face(Solid sol0, int index0, float ... v) {
    super(v);
    parentSolid = sol0;
    faceIndex = index0;
    setCol(parentSolid.cols[index0]);
  }
  
  public Face(Solid sol0, int index0, Shape s) {
    super(s);
    parentSolid = sol0;
    faceIndex = index0;
    setCol(parentSolid.cols[index0]);
  }
  
}
