package com.ivanmagda.matrixmath.model.request.body;

public class MatrixUnaryRequestBody {
    final Double[][] matrix;

    public MatrixUnaryRequestBody(Double[][] matrix) {
        this.matrix = matrix;
    }
}
