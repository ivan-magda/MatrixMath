package com.ivanmagda.matrixmath.model.request.response;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;
import com.ivanmagda.matrixmath.api.MatrixMathApi;

import java.util.ArrayList;
import java.util.List;

public class MatrixSolveResponse {

    @SerializedName("status_code")
    @Expose
    private int statusCode;
    @SerializedName("status_message")
    @Expose
    private String statusMessage;
    @SerializedName("result")
    @Expose
    private List<Double> result = new ArrayList<Double>();

    /**
     * @return The statusCode
     */
    public int getStatusCode() {
        return statusCode;
    }

    /**
     * @param statusCode The status_code
     */
    public void setStatusCode(int statusCode) {
        this.statusCode = statusCode;
    }

    /**
     * @return Was the request successful
     */
    public boolean isSuccess() {
        return statusCode == MatrixMathApi.SUCCESS_STATUS_CODE;
    }

    /**
     * @return The statusMessage
     */
    public String getStatusMessage() {
        return statusMessage;
    }

    /**
     * @param statusMessage The status_message
     */
    public void setStatusMessage(String statusMessage) {
        this.statusMessage = statusMessage;
    }

    /**
     * @return The result
     */
    public List<Double> getResult() {
        return result;
    }

    /**
     * @param result The result
     */
    public void setResult(List<Double> result) {
        this.result = result;
    }

}
