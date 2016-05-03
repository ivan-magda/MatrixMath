package com.ivanmagda.matrixmath.model.request.body;

public class MatrixBinaryRequestBody {

    final Double[][] left;
    final Double[][] right;

    public MatrixBinaryRequestBody(Double[][] left, Double[][] right) {
        this.left = left;
        this.right = right;
    }
}
