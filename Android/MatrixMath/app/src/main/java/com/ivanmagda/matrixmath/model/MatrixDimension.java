package com.ivanmagda.matrixmath.model;

import java.io.Serializable;

public class MatrixDimension implements Serializable {

    private static final long serialVersionUID = 1L;

    private int columns;
    private int rows;

    public MatrixDimension(int columns, int rows) {
        this.columns = columns;
        this.rows = rows;
    }

    public int getColumns() {
        return columns;
    }

    public void setColumns(int columns) {
        this.columns = columns;
    }

    public int getRows() {
        return rows;
    }

    public void setRows(int rows) {
        this.rows = rows;
    }

    public int getCount() {
        return columns * rows;
    }

    public boolean isNonZero() {
        return columns != 0 && rows != 0;
    }

    public String dimensionString() {
        return String.valueOf(columns) + "x" + String.valueOf(rows);
    }

    @Override
    public String toString() {
        return "MatrixDimension{" +
                "columns=" + columns +
                ", rows=" + rows +
                '}';
    }

    public static MatrixDimension zeroDimension() {
        return new MatrixDimension(0, 0);
    }

}
