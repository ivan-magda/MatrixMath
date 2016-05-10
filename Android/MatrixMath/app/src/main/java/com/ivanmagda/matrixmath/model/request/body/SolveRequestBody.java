package com.ivanmagda.matrixmath.model.request.body;

import java.util.List;

public class SolveRequestBody {

    final List<List<Double>> matrix;
    final List<Double> vector;

    public SolveRequestBody(List<List<Double>> matrix, List<Double> vector) {
        this.matrix = matrix;
        this.vector = vector;
    }

}
