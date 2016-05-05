package com.ivanmagda.matrixmath.ui.activity;

import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.ivanmagda.matrixmath.Extras;
import com.ivanmagda.matrixmath.R;
import com.ivanmagda.matrixmath.model.MatrixDimension;
import com.ivanmagda.matrixmath.model.MatrixOperation;
import com.ivanmagda.matrixmath.ui.view.ExpandableHeightGridView;
import com.ivanmagda.matrixmath.ui.view.MatrixAdapter;
import com.ivanmagda.matrixmath.ui.view.ResultAdapter;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class ComputeMatrixOperationActivity extends AppCompatActivity {

    // Properties.

    private static final String LOG_TAG = ComputeMatrixOperationActivity.class.getSimpleName();
    private static final int REQUEST_CODE_MATRIX_DIMENSION_ACTIVITY = 1234;

    private TextView matrixADimensionTitle;
    private TextView matrixBDimensionTitle;
    private TextView matrixADimensionSizeText;
    private TextView matrixBDimensionSizeText;

    private MatrixOperation matrixOperation;

    private MatrixDimension lhsMatrixDimension;
    private MatrixDimension rhsMatrixDimension;
    private MatrixDimension resultMatrixDimension;

    private List<Double> lhsMatrixArray;
    private List<Double> rhsMatrixArray;
    private List<Double> resultMatrixArray;

    // Life Cycle.

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Intent intent = getIntent();
        matrixOperation = (MatrixOperation) intent.getSerializableExtra(Extras.EXTRA_MATRIX_OPERATION_TRANSFER);

        configureUI();
        setup();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode) {
            case REQUEST_CODE_MATRIX_DIMENSION_ACTIVITY:
                if (resultCode == RESULT_OK) {
                    MatrixDimension dimension = (MatrixDimension) data.getSerializableExtra(Extras.EXTRA_MATRIX_DIMENSION_TRANSFER);
                    Toast.makeText(ComputeMatrixOperationActivity.this, dimension.toString(),
                            Toast.LENGTH_LONG).show();
                }
        }
        super.onActivityResult(requestCode, resultCode, data);
    }

    // Helpers.

    private void configureUI() {
        setContentView(R.layout.activity_compute_matrix_operation);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        toolbar.setTitle(matrixOperation.getName());
        setSupportActionBar(toolbar);

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        if (fab != null) {
            fab.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Snackbar.make(view, "Replace with your own action", Snackbar.LENGTH_LONG)
                            .setAction("Action", null).show();
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
                presentMatrixDimensionActivtyForSelectedDimension(lhsMatrixDimension);
            }
        });
        matrixADimensionSizeText.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                presentMatrixDimensionActivtyForSelectedDimension(lhsMatrixDimension);
            }
        });

        matrixBDimensionTitle.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                presentMatrixDimensionActivtyForSelectedDimension(rhsMatrixDimension);
            }
        });
        matrixBDimensionSizeText.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                presentMatrixDimensionActivtyForSelectedDimension(rhsMatrixDimension);
            }
        });
    }

    private void setup() {
        ExpandableHeightGridView gridViewA = (ExpandableHeightGridView) findViewById(R.id.grid_view_a);
        ExpandableHeightGridView gridViewB = (ExpandableHeightGridView) findViewById(R.id.grid_view_b);
        ExpandableHeightGridView resultGridView = (ExpandableHeightGridView) findViewById(R.id.grid_view_result);

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

        gridViewA.setAdapter(new MatrixAdapter(this));
        gridViewA.setNumColumns(3);
        gridViewA.setExpanded(true);

        gridViewB.setAdapter(new MatrixAdapter(this));
        gridViewB.setNumColumns(3);
        gridViewB.setExpanded(true);

        resultGridView.setAdapter(new ResultAdapter(this));
        resultGridView.setNumColumns(3);
        resultGridView.setExpanded(true);
    }

    private void initMatrices() {
        lhsMatrixArray = new ArrayList<>(Collections.nCopies(lhsMatrixDimension.getCount(), 0.0));
        rhsMatrixArray = new ArrayList<>(Collections.nCopies(rhsMatrixDimension.getCount(), 0.0));
    }

    private void presentMatrixDimensionActivtyForSelectedDimension(MatrixDimension dimension) {
        Intent intent = new Intent(this, MatrixDimensionActivity.class);
        intent.putExtra(Extras.EXTRA_MATRIX_DIMENSION_TRANSFER, dimension);
        startActivityForResult(intent, REQUEST_CODE_MATRIX_DIMENSION_ACTIVITY);
    }

}
