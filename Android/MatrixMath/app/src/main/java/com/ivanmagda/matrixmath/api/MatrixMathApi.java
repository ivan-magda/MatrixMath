package com.ivanmagda.matrixmath.api;

import com.ivanmagda.matrixmath.model.request.body.MatrixUnaryRequestBody;
import com.ivanmagda.matrixmath.model.request.body.SolveRequestBody;
import com.ivanmagda.matrixmath.model.request.body.MatrixBinaryRequestBody;
import com.ivanmagda.matrixmath.model.request.response.MatrixResponse;
import com.ivanmagda.matrixmath.model.request.response.MatrixSolveResponse;
import com.ivanmagda.matrixmath.model.request.response.MatrixValueResponse;

import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.POST;

public interface MatrixMathApi {

    String API_BASE_URL = "http://dota2begin.tk/server/api/";

    int SUCCESS_STATUS_CODE = 200;
    int FAIL_STATUS_CODE = 500;

    @POST("add")
    Call<MatrixResponse> add(@Body MatrixBinaryRequestBody body);

    @POST("sub")
    Call<MatrixResponse> sub(@Body MatrixBinaryRequestBody body);

    @POST("multiply")
    Call<MatrixResponse> multiply(@Body MatrixBinaryRequestBody body);

    @POST("transpose")
    Call<MatrixResponse> transpose(@Body MatrixUnaryRequestBody body);

    @POST("determinant")
    Call<MatrixValueResponse> determinant(@Body MatrixUnaryRequestBody body);

    @POST("invert")
    Call<MatrixResponse> invert(@Body MatrixUnaryRequestBody body);

    @POST("solve")
    Call<MatrixSolveResponse> solve(@Body SolveRequestBody body);

    @POST("solveec")
    Call<MatrixSolveResponse> solveWithErrorCorrection(@Body SolveRequestBody body);

}
