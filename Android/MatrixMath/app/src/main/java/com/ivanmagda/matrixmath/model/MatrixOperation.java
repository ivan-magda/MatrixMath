package com.ivanmagda.matrixmath.model;

import java.io.Serializable;

public class MatrixOperation implements Serializable {

    private static final long serialVersionUID = 1L;

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

    @Override
    public String toString() {
        return "MatrixOperation{" +
                "name='" + name + '\'' +
                ", detailDescription='" + detailDescription + '\'' +
                ", type=" + type +
                '}';
    }

}
