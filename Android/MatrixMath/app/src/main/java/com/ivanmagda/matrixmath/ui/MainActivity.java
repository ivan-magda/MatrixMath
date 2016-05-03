package com.ivanmagda.matrixmath.ui;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.widget.Toast;

import com.ivanmagda.matrixmath.R;
import com.ivanmagda.matrixmath.api.MatrixMathApi;
import com.ivanmagda.matrixmath.api.ServiceGenerator;
import com.ivanmagda.matrixmath.model.request.body.MatrixBinaryRequestBody;
import com.ivanmagda.matrixmath.model.request.body.MatrixUnaryRequestBody;
import com.ivanmagda.matrixmath.model.request.body.SolveRequestBody;
import com.ivanmagda.matrixmath.model.request.response.MatrixResponse;
import com.ivanmagda.matrixmath.model.request.response.MatrixSolveResponse;
import com.ivanmagda.matrixmath.model.request.response.MatrixValueResponse;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class MainActivity extends AppCompatActivity {

    private static final String LOG_TAG = MainActivity.class.getSimpleName();

    private MatrixMathApi matrixMathApi = ServiceGenerator.createService(MatrixMathApi.class,
            MatrixMathApi.API_BASE_URL);

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
    }

    @Override
    protected void onResume() {
        super.onResume();

        unaryTest();
        binaryTest();
        determinantTest();
        solveTest();
    }

    private void unaryTest() {
        Double[][] matrix = new Double[][]{
                {1.0, 3.0, 9.0, 6.0},
                {5.0, 8.0, 4.0, 6.0},
                {2.0, 9.0, 7.0, 6.0}
        };

        matrixMathApi.invert(new MatrixUnaryRequestBody(matrix)).enqueue(new Callback<MatrixResponse>() {
            @Override
            public void onResponse(Call<MatrixResponse> call, Response<MatrixResponse> response) {
                Log.d(LOG_TAG, "Status code: " + response.body().getStatusCode());
                Log.d(LOG_TAG, "Status message: " + response.body().getStatusMessage());
                Log.d(LOG_TAG, "Result: " + response.body().getResult());

                if (!response.body().isSuccess()) {
                    Toast.makeText(MainActivity.this, response.body().getStatusMessage(),
                            Toast.LENGTH_LONG).show();
                }
            }

            @Override
            public void onFailure(Call<MatrixResponse> call, Throwable t) {
                Log.e(LOG_TAG, "Error: " + t.getMessage());
                Toast.makeText(MainActivity.this, t.getMessage(), Toast.LENGTH_LONG).show();
            }
        });
    }

    private void binaryTest() {
        Double[][] lhs = new Double[][]{
                {1.0, 3.0, 9.0, 6.0},
                {5.0, 8.0, 4.0, 6.0},
                {2.0, 9.0, 7.0, 6.0},
                {4.0, 3.0, 4.0, 6.0}
        };

        Double[][] rhs = new Double[][]{
                {1.0, 3.0, 9.0, 6.0},
                {5.0, 8.0, 4.0, 6.0},
                {2.0, 9.0, 7.0, 6.0},
                {4.0, 3.0, 4.0, 6.0}
        };

        matrixMathApi.multiply(new MatrixBinaryRequestBody(lhs, rhs)).enqueue(new Callback<MatrixResponse>() {
            @Override
            public void onResponse(Call<MatrixResponse> call, Response<MatrixResponse> response) {
                Log.d(LOG_TAG, "Status code: " + response.body().getStatusCode());
                Log.d(LOG_TAG, "Status message: " + response.body().getStatusMessage());
                Log.d(LOG_TAG, "Result: " + response.body().getResult());

                if (!response.body().isSuccess()) {
                    Toast.makeText(MainActivity.this, response.body().getStatusMessage(),
                            Toast.LENGTH_LONG).show();
                }
            }

            @Override
            public void onFailure(Call<MatrixResponse> call, Throwable t) {
                Log.e(LOG_TAG, "Error: " + t.getMessage());
                Toast.makeText(MainActivity.this, t.getMessage(), Toast.LENGTH_LONG).show();
            }
        });
    }

    private void determinantTest() {
        Double[][] matrix = new Double[][]{
                {1.0, 3.0, 9.0, 6.0},
                {5.0, 8.0, 4.0, 6.0},
                {2.0, 9.0, 7.0, 6.0},
                {4.0, 3.0, 4.0, 6.0}
        };

        matrixMathApi.determinant(new MatrixUnaryRequestBody(matrix)).enqueue(new Callback<MatrixValueResponse>() {
            @Override
            public void onResponse(Call<MatrixValueResponse> call, Response<MatrixValueResponse> response) {
                Log.d(LOG_TAG, "Status code: " + response.body().getStatusCode());
                Log.d(LOG_TAG, "Status message: " + response.body().getStatusMessage());
                Log.d(LOG_TAG, "Result: " + response.body().getResult());

                if (!response.body().isSuccess()) {
                    Toast.makeText(MainActivity.this, response.body().getStatusMessage(),
                            Toast.LENGTH_LONG).show();
                }
            }

            @Override
            public void onFailure(Call<MatrixValueResponse> call, Throwable t) {
                Log.e(LOG_TAG, "Error: " + t.getMessage());
                Toast.makeText(MainActivity.this, t.getMessage(), Toast.LENGTH_LONG).show();
            }
        });
    }

    private void solveTest() {
        Double[][] matrix = new Double[][]{
                {1.0, 3.0, 9.0, 6.0},
                {5.0, 8.0, 4.0, 6.0},
                {2.0, 9.0, 7.0, 6.0},
                {4.0, 3.0, 4.0, 6.0}
        };
        Double[] vector = new Double[]{2.0, 3.0, 1.0, 5.0};

        matrixMathApi.solveWithErrorCorrection(new SolveRequestBody(matrix, vector)).enqueue(new Callback<MatrixSolveResponse>() {
            @Override
            public void onResponse(Call<MatrixSolveResponse> call, Response<MatrixSolveResponse> response) {
                Log.d(LOG_TAG, "Status code: " + response.body().getStatusCode());
                Log.d(LOG_TAG, "Status message: " + response.body().getStatusMessage());
                Log.d(LOG_TAG, "Result: " + response.body().getResult());

                if (!response.body().isSuccess()) {
                    Toast.makeText(MainActivity.this, response.body().getStatusMessage(),
                            Toast.LENGTH_LONG).show();
                }
            }

            @Override
            public void onFailure(Call<MatrixSolveResponse> call, Throwable t) {
                Log.e(LOG_TAG, "Error: " + t.getMessage());
                Toast.makeText(MainActivity.this, t.getMessage(), Toast.LENGTH_LONG).show();
            }
        });
    }

}
