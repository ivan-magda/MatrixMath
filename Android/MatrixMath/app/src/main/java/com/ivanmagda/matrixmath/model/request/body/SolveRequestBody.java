package com.ivanmagda.matrixmath.model.request.body;

public class SolveRequestBody {

    final Double[][] matrix;
    final Double[] vector;

    public SolveRequestBody(Double[][] matrix, Double[] vector) {
        this.matrix = matrix;
        this.vector = vector;
    }

}
