package com.ivanmagda.matrixmath.model.request.body;

import java.util.List;

public class MatrixUnaryRequestBody {
    final List<List<Double>> matrix;

    public MatrixUnaryRequestBody(List<List<Double>> matrix) {
        this.matrix = matrix;
    }
}
