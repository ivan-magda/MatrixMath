package com.ivanmagda.matrixmath.model;

import java.util.ArrayList;
import java.util.List;

public class Matrix {

    private List<List<Double>> elements;
    private MatrixDimension dimension;

    public Matrix(List<List<Double>> elements) {
        this.elements = elements;

        int columns = elements.size();
        int rows = elements.get(0).size();
        this.dimension = new MatrixDimension(columns, rows);
    }

    public Matrix(List<Double> data, MatrixDimension dimension) {
        if (dimension.getCount() != data.size()) throw new AssertionError();

        List<List<Double>> res = new ArrayList<>(dimension.getRows());
        for (int columnIdx = 0; columnIdx < dimension.getColumns(); columnIdx++) {
            int elemIdx = columnIdx * dimension.getRows();
            List<Double> elements = new ArrayList<>(dimension.getColumns());
            for (int i = 0; i < dimension.getRows(); i++) {
                elements.add(data.get(elemIdx));
                elemIdx++;
            }
            res.add(elements);
        }

        this.elements = res;
        this.dimension = dimension;
    }

    public List<List<Double>> getElements() {
        return elements;
    }

    public MatrixDimension getDimension() {
        return dimension;
    }

    public List<Double> getOneDimensionArrayOfElements() {
        List<Double> result = new ArrayList<>(dimension.getCount());
        for (List<Double> anArray : elements)
            for (Double element : anArray)
                result.add(element);
        return result;
    }

}
