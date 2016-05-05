package com.ivanmagda.matrixmath.ui.activity;

import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;

import com.ivanmagda.matrixmath.Extras;
import com.ivanmagda.matrixmath.R;
import com.ivanmagda.matrixmath.model.MatrixOperation;
import com.ivanmagda.matrixmath.ui.view.ExpandableHeightGridView;
import com.ivanmagda.matrixmath.ui.view.MatrixAdapter;

public class ComputeMatrixOperationActivity extends AppCompatActivity {

    // Properties.

    private static final String LOG_TAG = ComputeMatrixOperationActivity.class.getSimpleName();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_compute_matrix_operation);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        Intent intent = getIntent();
        MatrixOperation operation = (MatrixOperation) intent.getSerializableExtra(Extras.EXTRA_MATRIX_OPERATION_TRANSFER);
        assert operation != null;

        Log.d(LOG_TAG, "Selected operation: " + operation);

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Snackbar.make(view, "Replace with your own action", Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        });
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        configureUI();
    }

    private void configureUI() {
        ExpandableHeightGridView gridViewA = (ExpandableHeightGridView) findViewById(R.id.grid_view_a);
        ExpandableHeightGridView gridViewB = (ExpandableHeightGridView) findViewById(R.id.grid_view_b);

        assert gridViewA != null;
        assert gridViewB != null;

        gridViewA.setAdapter(new MatrixAdapter(this));
        gridViewA.setNumColumns(3);
        gridViewA.setExpanded(true);

        gridViewB.setAdapter(new MatrixAdapter(this));
        gridViewB.setNumColumns(3);
        gridViewB.setExpanded(true);
    }

}
