package com.ivanmagda.matrixmath.ui.activity;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.GridView;
import android.widget.TextView;
import android.widget.Toast;

import com.ivanmagda.matrixmath.Extras;
import com.ivanmagda.matrixmath.R;
import com.ivanmagda.matrixmath.api.MatrixMathApi;
import com.ivanmagda.matrixmath.api.ServiceGenerator;
import com.ivanmagda.matrixmath.model.Matrix;
import com.ivanmagda.matrixmath.model.MatrixDimension;
import com.ivanmagda.matrixmath.model.MatrixOperation;
import com.ivanmagda.matrixmath.model.request.body.MatrixBinaryRequestBody;
import com.ivanmagda.matrixmath.model.request.body.MatrixUnaryRequestBody;
import com.ivanmagda.matrixmath.model.request.body.SolveRequestBody;
import com.ivanmagda.matrixmath.model.request.response.MatrixResponse;
import com.ivanmagda.matrixmath.model.request.response.MatrixSolveResponse;
import com.ivanmagda.matrixmath.model.request.response.MatrixValueResponse;
import com.ivanmagda.matrixmath.ui.view.ExpandableHeightGridView;
import com.ivanmagda.matrixmath.ui.view.MatrixAdapter;
import com.ivanmagda.matrixmath.ui.view.ResultAdapter;
import com.ivanmagda.matrixmath.util.ListUtils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class ComputeMatrixOperationActivity extends AppCompatActivity {

    private enum EditingDimension {MATRIX_A, MATRIX_B, NONE}

    // Properties.

    private static final String LOG_TAG = ComputeMatrixOperationActivity.class.getSimpleName();
    private static final int REQUEST_CODE_MATRIX_DIMENSION_ACTIVITY = 1234;

    private TextView matrixADimensionTitle;
    private TextView matrixBDimensionTitle;
    private TextView matrixADimensionSizeText;
    private TextView matrixBDimensionSizeText;

    private MatrixOperation matrixOperation;

    private ExpandableHeightGridView gridViewA;
    private ExpandableHeightGridView gridViewB;
    private ExpandableHeightGridView resultGridView;

    private MatrixAdapter matrixAdapterA;
    private MatrixAdapter matrixAdapterB;
    private ResultAdapter resultAdapter;

    private MatrixDimension lhsMatrixDimension;
    private MatrixDimension rhsMatrixDimension;
    private MatrixDimension resultMatrixDimension;

    private List<Double> lhsMatrixArray;
    private List<Double> rhsMatrixArray;
    private List<Double> resultMatrixArray;

    private EditingDimension editingDimension = EditingDimension.NONE;

    private MatrixMathApi matrixMathApi = ServiceGenerator.createService(MatrixMathApi.class,
            MatrixMathApi.API_BASE_URL);

    // Life Cycle.

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Intent intent = getIntent();
        matrixOperation = (MatrixOperation) intent.getSerializableExtra(Extras.EXTRA_MATRIX_OPERATION_TRANSFER);

        setup();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode) {
            case REQUEST_CODE_MATRIX_DIMENSION_ACTIVITY:
                if (resultCode == RESULT_OK) {
                    MatrixDimension dimension = (MatrixDimension) data.getSerializableExtra(Extras.EXTRA_MATRIX_DIMENSION_TRANSFER);

                    switch (editingDimension) {
                        case MATRIX_A:
                            lhsMatrixDimension = dimension;
                            lhsMatrixArray = arrayWithRepeatedValue(lhsMatrixDimension.getCount(), 0.0);
                            updateNumberOfColumnsForGridView(gridViewA, lhsMatrixDimension);
                            matrixAdapterA.updateWithNewData(lhsMatrixDimension,
                                    ListUtils.toListOfString(lhsMatrixArray));
                            matrixADimensionSizeText.setText(lhsMatrixDimension.dimensionString());
                            break;
                        case MATRIX_B:
                            rhsMatrixDimension = dimension;
                            rhsMatrixArray = arrayWithRepeatedValue(rhsMatrixDimension.getCount(), 0.0);
                            updateNumberOfColumnsForGridView(gridViewB, rhsMatrixDimension);
                            matrixAdapterB.updateWithNewData(rhsMatrixDimension,
                                    ListUtils.toListOfString(rhsMatrixArray));
                            matrixBDimensionSizeText.setText(rhsMatrixDimension.dimensionString());
                            break;
                        default:
                            break;
                    }
                    editingDimension = EditingDimension.NONE;
                }
        }
        super.onActivityResult(requestCode, resultCode, data);
    }

    // Helpers.

    private void setup() {
        configureUI();

        gridViewA = (ExpandableHeightGridView) findViewById(R.id.grid_view_a);
        gridViewB = (ExpandableHeightGridView) findViewById(R.id.grid_view_b);
        resultGridView = (ExpandableHeightGridView) findViewById(R.id.grid_view_result);

        assert gridViewA != null;
        assert gridViewB != null;
        assert resultGridView != null;

        final MatrixDimension defaultMatrixDimension = new MatrixDimension(3, 3);
        lhsMatrixDimension = defaultMatrixDimension;

        switch (matrixOperation.getType()) {
            case ADDITION:
            case SUBTRACT:
            case MULTIPLY:
                rhsMatrixDimension = defaultMatrixDimension;
                break;
            case SOLVE:
            case SOLVE_WITH_ERROR_CORRECTION:
                rhsMatrixDimension = new MatrixDimension(3, 1);
                break;
            default:
                rhsMatrixDimension = new MatrixDimension(0, 0);
                break;
        }

        initMatrices();

        matrixAdapterA = new MatrixAdapter(this, lhsMatrixDimension,
                ListUtils.toListOfString(lhsMatrixArray));
        gridViewA.setAdapter(matrixAdapterA);
        updateNumberOfColumnsForGridView(gridViewA, lhsMatrixDimension);
        gridViewA.setExpanded(true);

        matrixAdapterB = new MatrixAdapter(this, rhsMatrixDimension,
                ListUtils.toListOfString(rhsMatrixArray));
        gridViewB.setAdapter(matrixAdapterB);
        updateNumberOfColumnsForGridView(gridViewB, rhsMatrixDimension);
        gridViewB.setExpanded(true);

        resultMatrixDimension = defaultMatrixDimension;
        resultMatrixArray = new ArrayList<>(Collections.nCopies(resultMatrixDimension.getCount(), 0.0));
        resultAdapter = new ResultAdapter(this, resultMatrixDimension, resultMatrixArray);
        resultGridView.setAdapter(resultAdapter);
        updateNumberOfColumnsForGridView(resultGridView, resultMatrixDimension);
        resultGridView.setExpanded(true);

        matrixADimensionSizeText.setText(lhsMatrixDimension.dimensionString());
        matrixBDimensionSizeText.setText(rhsMatrixDimension.dimensionString());
    }

    private void configureUI() {
        setContentView(R.layout.activity_compute_matrix_operation);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        if (toolbar != null) {
            toolbar.setTitle(matrixOperation.getName());
        }
        setSupportActionBar(toolbar);

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        if (fab != null) {
            fab.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    hideKeyboard();
                    computeOperation();
                }
            });
        }
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        matrixADimensionTitle = (TextView) findViewById(R.id.matrix_a_dimension_title);
        matrixBDimensionTitle = (TextView) findViewById(R.id.matrix_b_dimension_title);
        matrixADimensionSizeText = (TextView) findViewById(R.id.matrix_a_dimension_text);
        matrixBDimensionSizeText = (TextView) findViewById(R.id.matrix_b_dimension_text);

        matrixADimensionTitle.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                editingDimension = EditingDimension.MATRIX_A;
                presentMatrixDimensionActivity(lhsMatrixDimension);
            }
        });
        matrixADimensionSizeText.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                editingDimension = EditingDimension.MATRIX_A;
                presentMatrixDimensionActivity(lhsMatrixDimension);
            }
        });

        matrixBDimensionTitle.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                editingDimension = EditingDimension.MATRIX_B;
                presentMatrixDimensionActivity(rhsMatrixDimension);
            }
        });
        matrixBDimensionSizeText.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                editingDimension = EditingDimension.MATRIX_B;
                presentMatrixDimensionActivity(rhsMatrixDimension);
            }
        });
    }

    private void updateNumberOfColumnsForGridView(GridView gridView, MatrixDimension dimension) {
        gridView.setNumColumns(dimension.getColumns());
    }

    private void initMatrices() {
        lhsMatrixArray = arrayWithRepeatedValue(lhsMatrixDimension.getCount(), 0.0);
        rhsMatrixArray = arrayWithRepeatedValue(rhsMatrixDimension.getCount(), 0.0);
    }

    private List<Double> arrayWithRepeatedValue(int count, double value) {
        return new ArrayList<>(Collections.nCopies(count, value));
    }

    private void presentMatrixDimensionActivity(MatrixDimension dimension) {
        Intent intent = new Intent(this, MatrixDimensionActivity.class);
        intent.putExtra(Extras.EXTRA_MATRIX_DIMENSION_TRANSFER, dimension);
        startActivityForResult(intent, REQUEST_CODE_MATRIX_DIMENSION_ACTIVITY);
    }

    private void hideKeyboard() {
        View view = this.getCurrentFocus();
        if (view != null) {
            InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
            imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
        }
    }

    // Api Calls.

    private void computeOperation() {
        Matrix lhsMatrix = new Matrix(lhsMatrixArray, lhsMatrixDimension);
        Matrix rhsMatrix = new Matrix(rhsMatrixArray, rhsMatrixDimension);

        switch (matrixOperation.getType()) {
            case ADDITION:
                matrixMathApi.add(new MatrixBinaryRequestBody(lhsMatrix.getElements(),
                        rhsMatrix.getElements())).enqueue(new Callback<MatrixResponse>() {
                    @Override
                    public void onResponse(Call<MatrixResponse> call, Response<MatrixResponse> response) {
                        successMatrixResponse(response);
                    }

                    @Override
                    public void onFailure(Call<MatrixResponse> call, Throwable t) {
                        failureResponse(t);
                    }
                });
                break;
            case SUBTRACT:
                matrixMathApi.sub(new MatrixBinaryRequestBody(lhsMatrix.getElements(),
                        rhsMatrix.getElements())).enqueue(new Callback<MatrixResponse>() {
                    @Override
                    public void onResponse(Call<MatrixResponse> call, Response<MatrixResponse> response) {
                        successMatrixResponse(response);
                    }

                    @Override
                    public void onFailure(Call<MatrixResponse> call, Throwable t) {
                        failureResponse(t);
                    }
                });
                break;
            case MULTIPLY:
                matrixMathApi.multiply(new MatrixBinaryRequestBody(lhsMatrix.getElements(),
                        rhsMatrix.getElements())).enqueue(new Callback<MatrixResponse>() {
                    @Override
                    public void onResponse(Call<MatrixResponse> call, Response<MatrixResponse> response) {
                        successMatrixResponse(response);
                    }

                    @Override
                    public void onFailure(Call<MatrixResponse> call, Throwable t) {
                        failureResponse(t);
                    }
                });
                break;
            case TRANSPOSE:
                matrixMathApi.transpose(new MatrixUnaryRequestBody(lhsMatrix.getElements())).enqueue(new Callback<MatrixResponse>() {
                    @Override
                    public void onResponse(Call<MatrixResponse> call, Response<MatrixResponse> response) {
                        successMatrixResponse(response);
                    }

                    @Override
                    public void onFailure(Call<MatrixResponse> call, Throwable t) {
                        failureResponse(t);
                    }
                });
                break;
            case INVERT:
                matrixMathApi.invert(new MatrixUnaryRequestBody(lhsMatrix.getElements())).enqueue(new Callback<MatrixResponse>() {
                    @Override
                    public void onResponse(Call<MatrixResponse> call, Response<MatrixResponse> response) {
                        successMatrixResponse(response);
                    }

                    @Override
                    public void onFailure(Call<MatrixResponse> call, Throwable t) {
                        failureResponse(t);
                    }
                });
                break;
            case DETERMINANT:
                matrixMathApi.determinant(new MatrixUnaryRequestBody(lhsMatrix.getElements())).enqueue(new Callback<MatrixValueResponse>() {
                    @Override
                    public void onResponse(Call<MatrixValueResponse> call, Response<MatrixValueResponse> response) {
                        successValueResponse(response);
                    }

                    @Override
                    public void onFailure(Call<MatrixValueResponse> call, Throwable t) {
                        failureResponse(t);
                    }
                });
                break;
            case SOLVE:
                matrixMathApi.solve(new SolveRequestBody(lhsMatrix.getElements(),
                        rhsMatrix.getOneDimensionData())).enqueue(new Callback<MatrixSolveResponse>() {
                    @Override
                    public void onResponse(Call<MatrixSolveResponse> call, Response<MatrixSolveResponse> response) {
                        successSolveResponse(response);
                    }

                    @Override
                    public void onFailure(Call<MatrixSolveResponse> call, Throwable t) {
                        failureResponse(t);
                    }
                });
                break;
            case SOLVE_WITH_ERROR_CORRECTION:
                matrixMathApi.solveWithErrorCorrection(new SolveRequestBody(lhsMatrix.getElements(),
                        rhsMatrix.getOneDimensionData())).enqueue(new Callback<MatrixSolveResponse>() {
                    @Override
                    public void onResponse(Call<MatrixSolveResponse> call, Response<MatrixSolveResponse> response) {
                        successSolveResponse(response);
                    }

                    @Override
                    public void onFailure(Call<MatrixSolveResponse> call, Throwable t) {
                        failureResponse(t);
                    }
                });
                break;
        }
    }

    private void successMatrixResponse(Response<MatrixResponse> response) {
        Log.d(LOG_TAG, "Status code: " + response.body().getStatusCode());
        Log.d(LOG_TAG, "Status message: " + response.body().getStatusMessage());
        Log.d(LOG_TAG, "Result: " + response.body().getResult());

        if (!response.body().isSuccess()) {
            Toast.makeText(ComputeMatrixOperationActivity.this, response.body().getStatusMessage(),
                    Toast.LENGTH_LONG).show();
        } else {
            Toast.makeText(ComputeMatrixOperationActivity.this, "Success", Toast.LENGTH_SHORT).show();
        }
    }

    private void successSolveResponse(Response<MatrixSolveResponse> response) {
        Log.d(LOG_TAG, "Status code: " + response.body().getStatusCode());
        Log.d(LOG_TAG, "Status message: " + response.body().getStatusMessage());
        Log.d(LOG_TAG, "Result: " + response.body().getResult());

        if (!response.body().isSuccess()) {
            Toast.makeText(ComputeMatrixOperationActivity.this, response.body().getStatusMessage(),
                    Toast.LENGTH_LONG).show();
        } else {
            Toast.makeText(ComputeMatrixOperationActivity.this, "Success", Toast.LENGTH_SHORT).show();
        }
    }

    private void successValueResponse(Response<MatrixValueResponse> response) {
        Log.d(LOG_TAG, "Status code: " + response.body().getStatusCode());
        Log.d(LOG_TAG, "Status message: " + response.body().getStatusMessage());
        Log.d(LOG_TAG, "Result: " + response.body().getResult());

        if (!response.body().isSuccess()) {
            Toast.makeText(ComputeMatrixOperationActivity.this, response.body().getStatusMessage(),
                    Toast.LENGTH_LONG).show();
        } else {
            Toast.makeText(ComputeMatrixOperationActivity.this, "Success", Toast.LENGTH_SHORT).show();
        }
    }

    private void failureResponse(Throwable throwable) {
        Log.e(LOG_TAG, "Error: " + throwable.getMessage());
        Toast.makeText(ComputeMatrixOperationActivity.this, throwable.getMessage(), Toast.LENGTH_LONG).show();
    }

}
