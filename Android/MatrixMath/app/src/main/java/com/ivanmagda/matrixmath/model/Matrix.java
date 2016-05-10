package com.ivanmagda.matrixmath.model;

import java.util.ArrayList;
import java.util.List;

public class Matrix {

    private List<List<Double>> elements;
    private MatrixDimension dimension;

    public List<List<Double>> getElements() {
        return elements;
    }

    public MatrixDimension getDimension() {
        return dimension;
    }

    public Matrix(List<Double> data, MatrixDimension dimension) {
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

    public List<Double> getOneDimensionData() {
        List<Double> result = new ArrayList<>(dimension.getCount());
        for (List<Double> anArray : elements) {
            for (Double element : anArray) {
                result.add(element);
            }
        }

        return result;
    }

}
