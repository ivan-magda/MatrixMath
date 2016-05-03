package com.ivanmagda.matrixmath.model;

public class MatrixOperation {

    private String name;
    private String detailDescription;
    private MatrixOperationType type;

    public MatrixOperation(String name, String detailDescription, MatrixOperationType type) {
        this.name = name;
        this.detailDescription = detailDescription;
        this.type = type;
    }

    public MatrixOperation(String name, MatrixOperationType type) {
        this.name = name;
        this.type = type;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDetailDescription() {
        return detailDescription;
    }

    public void setDetailDescription(String detailDescription) {
        this.detailDescription = detailDescription;
    }

    public MatrixOperationType getType() {
        return type;
    }

    public void setType(MatrixOperationType type) {
        this.type = type;
    }

}
