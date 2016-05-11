package com.ivanmagda.matrixmath.ui.activity;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.GridView;
import android.widget.LinearLayout;
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

    private enum EditingDimension {LHS_MATRIX, RHS_MATRIX, NONE}

    // Properties.

    private static final String LOG_TAG = ComputeMatrixOperationActivity.class.getSimpleName();
    private static final int REQUEST_CODE_MATRIX_DIMENSION_ACTIVITY = 1234;

    private MatrixOperation matrixOperation;

    private ProgressDialog progressDialog;

    // Dimension TextViews.
    private TextView lhsMatrixDimensionTitle;
    private TextView rhsMatrixDimensionTitle;
    private TextView lhsMatrixDimensionSizeText;
    private TextView rhsMatrixDimensionSizeText;

    // Header TextViews.
    private TextView lhsMatrixHeaderTitle;
    private TextView rhsMatrixHeaderTitle;
    private TextView resultMatrixHeaderTitle;

    // GridViews.
    private ExpandableHeightGridView lhsGridView;
    private ExpandableHeightGridView rhsGridView;
    private ExpandableHeightGridView resultGridView;

    // Adapters.
    private MatrixAdapter lhsMatrixAdapter;
    private MatrixAdapter rhsMatrixAdapter;
    private ResultAdapter resultAdapter;

    // Dimensions.
    private MatrixDimension lhsMatrixDimension;
    private MatrixDimension rhsMatrixDimension;
    private MatrixDimension resultMatrixDimension;
    private EditingDimension editingDimension = EditingDimension.NONE;

    // DataSource.
    private List<Double> lhsMatrixArray;
    private List<Double> rhsMatrixArray;
    private List<Double> resultMatrixArray;

    // Api.
    private MatrixMathApi matrixMathApi = ServiceGenerator.createService(MatrixMathApi.class,
            MatrixMathApi.API_BASE_URL);

    // Life Cycle.

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setup();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode) {
            case REQUEST_CODE_MATRIX_DIMENSION_ACTIVITY:
                if (resultCode == RESULT_OK) {
                    MatrixDimension dimension = (MatrixDimension) data.getSerializableExtra(
                            Extras.EXTRA_MATRIX_DIMENSION_TRANSFER);
                    switch (editingDimension) {
                        case LHS_MATRIX:
                            lhsMatrixDimension = dimension;
                            lhsMatrixArray = arrayWithRepeatedValue(lhsMatrixDimension.getCount(), 0.0);
                            updateNumberOfColumnsForGridView(lhsGridView, lhsMatrixDimension);
                            lhsMatrixAdapter.updateWithNewData(lhsMatrixDimension,
                                    ListUtils.toListOfString(lhsMatrixArray));
                            lhsMatrixDimensionSizeText.setText(lhsMatrixDimension.dimensionString());
                            break;
                        case RHS_MATRIX:
                            rhsMatrixDimension = dimension;
                            rhsMatrixArray = arrayWithRepeatedValue(rhsMatrixDimension.getCount(), 0.0);
                            updateNumberOfColumnsForGridView(rhsGridView, rhsMatrixDimension);
                            rhsMatrixAdapter.updateWithNewData(rhsMatrixDimension,
                                    ListUtils.toListOfString(rhsMatrixArray));
                            rhsMatrixDimensionSizeText.setText(rhsMatrixDimension.dimensionString());
                            break;
                    }
                    editingDimension = EditingDimension.NONE;
                    setResultVisibility(View.INVISIBLE);
                }
        }
        super.onActivityResult(requestCode, resultCode, data);
    }

    // Helpers.

    private void setup() {
        Intent intent = getIntent();
        matrixOperation = (MatrixOperation) intent.getSerializableExtra(Extras.EXTRA_MATRIX_OPERATION_TRANSFER);

        setContentView(R.layout.activity_compute_matrix_operation);

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        if (toolbar != null) {
            toolbar.setTitle(matrixOperation.getName());
        }
        setSupportActionBar(toolbar);

        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setDisplayHomeAsUpEnabled(true);
        }

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

        lhsMatrixDimensionTitle = (TextView) findViewById(R.id.lhs_matrix_dimension_title);
        rhsMatrixDimensionTitle = (TextView) findViewById(R.id.rhs_matrix_dimension_title);
        lhsMatrixDimensionSizeText = (TextView) findViewById(R.id.lhs_matrix_dimension_text);
        rhsMatrixDimensionSizeText = (TextView) findViewById(R.id.rhs_matrix_dimension_text);

        lhsMatrixHeaderTitle = (TextView) findViewById(R.id.lhs_matrix_header_text_view);
        rhsMatrixHeaderTitle = (TextView) findViewById(R.id.rhs_matrix_header_text_view);
        resultMatrixHeaderTitle = (TextView) findViewById(R.id.computing_result_header_text_view);

        lhsMatrixDimensionTitle.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                editingDimension = EditingDimension.LHS_MATRIX;
                presentMatrixDimensionActivity(lhsMatrixDimension);
            }
        });
        lhsMatrixDimensionSizeText.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                editingDimension = EditingDimension.LHS_MATRIX;
                presentMatrixDimensionActivity(lhsMatrixDimension);
            }
        });

        rhsMatrixDimensionTitle.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                editingDimension = EditingDimension.RHS_MATRIX;
                presentMatrixDimensionActivity(rhsMatrixDimension);
            }
        });
        rhsMatrixDimensionSizeText.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                editingDimension = EditingDimension.RHS_MATRIX;
                presentMatrixDimensionActivity(rhsMatrixDimension);
            }
        });

        lhsGridView = (ExpandableHeightGridView) findViewById(R.id.lhs_grid_view);
        rhsGridView = (ExpandableHeightGridView) findViewById(R.id.rhs_grid_view);
        resultGridView = (ExpandableHeightGridView) findViewById(R.id.result_grid_view);

        assert lhsGridView != null;
        assert rhsGridView != null;
        assert resultGridView != null;

        // Configure matrix dimensions and data source.

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
                rhsMatrixDimension = new MatrixDimension(1, 3);
                break;
            default:
                rhsMatrixDimension = new MatrixDimension(0, 0);
                break;
        }

        initMatrices();

        lhsMatrixAdapter = new MatrixAdapter(this, lhsMatrixDimension,
                ListUtils.toListOfString(lhsMatrixArray));
        lhsGridView.setAdapter(lhsMatrixAdapter);
        updateNumberOfColumnsForGridView(lhsGridView, lhsMatrixDimension);
        lhsGridView.setExpanded(true);

        rhsMatrixAdapter = new MatrixAdapter(this, rhsMatrixDimension,
                ListUtils.toListOfString(rhsMatrixArray));
        rhsGridView.setAdapter(rhsMatrixAdapter);
        updateNumberOfColumnsForGridView(rhsGridView, rhsMatrixDimension);
        rhsGridView.setExpanded(true);

        resultMatrixDimension = MatrixDimension.zeroDimension();
        resultMatrixArray = new ArrayList<>(Collections.nCopies(resultMatrixDimension.getCount(), 0.0));
        resultAdapter = new ResultAdapter(this, resultMatrixDimension, resultMatrixArray);
        resultGridView.setAdapter(resultAdapter);
        updateNumberOfColumnsForGridView(resultGridView, resultMatrixDimension);
        resultGridView.setExpanded(true);

        lhsMatrixDimensionSizeText.setText(lhsMatrixDimension.dimensionString());
        rhsMatrixDimensionSizeText.setText(rhsMatrixDimension.dimensionString());

        switch (matrixOperation.getType()) {
            case TRANSPOSE:
            case INVERT:
            case DETERMINANT:
                lhsMatrixDimensionTitle.setText(R.string.matrix_dimension_text);
                lhsMatrixHeaderTitle.setText(R.string.fill_matrix_text);

                rhsMatrixDimensionTitle.setVisibility(View.GONE);
                rhsMatrixDimensionSizeText.setVisibility(View.GONE);
                rhsMatrixHeaderTitle.setVisibility(View.GONE);
                rhsGridView.setVisibility(View.GONE);
                break;
        }
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

    private void setResultVisibility(int visibility) {
        LinearLayout resultLayout = (LinearLayout) findViewById(R.id.result_linear_layout);
        assert resultLayout != null;

        resultLayout.setVisibility(visibility);
        resultMatrixHeaderTitle.setVisibility(visibility);
        resultGridView.setVisibility(visibility);
    }

    private void presentProgressIndicator() {
        if (progressDialog == null) {
            progressDialog = new ProgressDialog(this);
            progressDialog.setMessage(getString(R.string.computing_message));
            progressDialog.setCancelable(false);
        }

        progressDialog.show();
    }

    // Api Calls.

    private void computeOperation() {
        Matrix lhsMatrix;
        Matrix rhsMatrix;

        try {
            lhsMatrixArray = ListUtils.toListOfDoubles(lhsMatrixAdapter.getElements());
            rhsMatrixArray = ListUtils.toListOfDoubles(rhsMatrixAdapter.getElements());

            lhsMatrix = new Matrix(lhsMatrixArray, lhsMatrixDimension);
            rhsMatrix = new Matrix(rhsMatrixArray, rhsMatrixDimension);
        } catch (NumberFormatException exception) {
            Toast.makeText(ComputeMatrixOperationActivity.this, R.string.incorrect_input,
                    Toast.LENGTH_LONG).show();
            return;
        }

        presentProgressIndicator();

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
                        rhsMatrix.getOneDimensionArrayOfElements())).enqueue(new Callback<MatrixSolveResponse>() {
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
                        rhsMatrix.getOneDimensionArrayOfElements())).enqueue(new Callback<MatrixSolveResponse>() {
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

    private void updateResultWithNewDataSource() {
        updateNumberOfColumnsForGridView(resultGridView, resultMatrixDimension);
        resultAdapter.updateWithNewData(resultMatrixDimension, resultMatrixArray);
    }

    private void successMatrixResponse(Response<MatrixResponse> response) {
        Log.d(LOG_TAG, "Status code: " + response.body().getStatusCode());
        Log.d(LOG_TAG, "Status message: " + response.body().getStatusMessage());
        Log.d(LOG_TAG, "Result: " + response.body().getResult());

        progressDialog.dismiss();

        if (!response.body().isSuccess()) {
            Toast.makeText(ComputeMatrixOperationActivity.this, response.body().getStatusMessage(),
                    Toast.LENGTH_LONG).show();
        } else {
            Toast.makeText(ComputeMatrixOperationActivity.this, R.string.success, Toast.LENGTH_SHORT).show();
            setResultVisibility(View.VISIBLE);

            Matrix resultMatrix = new Matrix(response.body().getResult());
            resultMatrixArray = resultMatrix.getOneDimensionArrayOfElements();
            resultMatrixDimension = resultMatrix.getDimension();
            updateResultWithNewDataSource();
        }
    }

    private void successSolveResponse(Response<MatrixSolveResponse> response) {
        Log.d(LOG_TAG, "Status code: " + response.body().getStatusCode());
        Log.d(LOG_TAG, "Status message: " + response.body().getStatusMessage());
        Log.d(LOG_TAG, "Result: " + response.body().getResult());

        progressDialog.dismiss();

        if (!response.body().isSuccess()) {
            Toast.makeText(ComputeMatrixOperationActivity.this, response.body().getStatusMessage(),
                    Toast.LENGTH_LONG).show();
        } else {
            Toast.makeText(ComputeMatrixOperationActivity.this, R.string.success, Toast.LENGTH_SHORT).show();
            setResultVisibility(View.VISIBLE);

            resultMatrixArray = response.body().getResult();
            resultMatrixDimension = new MatrixDimension(1, resultMatrixArray.size());
            updateResultWithNewDataSource();
        }
    }

    private void successValueResponse(Response<MatrixValueResponse> response) {
        Log.d(LOG_TAG, "Status code: " + response.body().getStatusCode());
        Log.d(LOG_TAG, "Status message: " + response.body().getStatusMessage());
        Log.d(LOG_TAG, "Result: " + response.body().getResult());

        progressDialog.dismiss();

        if (!response.body().isSuccess()) {
            Toast.makeText(ComputeMatrixOperationActivity.this, response.body().getStatusMessage(),
                    Toast.LENGTH_LONG).show();
        } else {
            Toast.makeText(ComputeMatrixOperationActivity.this, R.string.success, Toast.LENGTH_SHORT).show();
            setResultVisibility(View.VISIBLE);

            resultMatrixArray = new ArrayList<>(Collections.nCopies(1, response.body().getResult()));
            resultMatrixDimension = new MatrixDimension(1, 1);
            updateResultWithNewDataSource();
        }
    }

    private void failureResponse(Throwable throwable) {
        Log.e(LOG_TAG, "Error: " + throwable.getMessage());

        progressDialog.dismiss();
        Toast.makeText(ComputeMatrixOperationActivity.this, throwable.getMessage(), Toast.LENGTH_LONG).show();
    }

}
