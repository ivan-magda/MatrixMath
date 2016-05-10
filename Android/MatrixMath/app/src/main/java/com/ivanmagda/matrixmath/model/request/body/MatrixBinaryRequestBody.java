package com.ivanmagda.matrixmath.model.request.body;

import java.util.List;

public class MatrixBinaryRequestBody {

    final List<List<Double>> left;
    final List<List<Double>> right;

    public MatrixBinaryRequestBody(List<List<Double>> left, List<List<Double>> right) {
        this.left = left;
        this.right = right;
    }
}
