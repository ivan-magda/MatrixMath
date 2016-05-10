package com.ivanmagda.matrixmath.ui.activity;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;

import com.ivanmagda.matrixmath.Extras;
import com.ivanmagda.matrixmath.R;
import com.ivanmagda.matrixmath.api.MatrixMathApi;
import com.ivanmagda.matrixmath.api.ServiceGenerator;
import com.ivanmagda.matrixmath.model.MatrixOperation;
import com.ivanmagda.matrixmath.ui.view.DividerItemDecoration;
import com.ivanmagda.matrixmath.ui.view.MatrixOperationsRecyclerViewAdapter;
import com.ivanmagda.matrixmath.ui.view.RecyclerItemClickListener;
import com.ivanmagda.matrixmath.util.MatrixOperationUtils;

public class MatrixOperationsActivity extends AppCompatActivity {

    // Properties.

    private static final String LOG_TAG = MatrixOperationsActivity.class.getSimpleName();

    private RecyclerView recyclerView;
    private MatrixOperationsRecyclerViewAdapter recyclerViewAdapter;

    private MatrixMathApi matrixMathApi = ServiceGenerator.createService(MatrixMathApi.class,
            MatrixMathApi.API_BASE_URL);

    // Life Cycle.

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_matrix_operations);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        configureUI();
    }

    // Configure UI.

    private void configureUI() {
        recyclerView = (RecyclerView) findViewById(R.id.matrix_operations_recycler_view);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        recyclerView.addItemDecoration(new DividerItemDecoration(this, R.drawable.divider));

        recyclerViewAdapter = new MatrixOperationsRecyclerViewAdapter(MatrixOperationUtils.getAllMethods(this));
        recyclerView.setAdapter(recyclerViewAdapter);

        recyclerView.addOnItemTouchListener(new RecyclerItemClickListener(this, recyclerView,
                new RecyclerItemClickListener.OnItemClickListener() {
                    @Override
                    public void onItemClick(View view, int position) {
                        onMethodSelected(recyclerViewAdapter.getOperations().get(position));
                    }
                }));
    }

    // Actions.

    private void onMethodSelected(MatrixOperation operation) {
        Intent detailIntent = new Intent(this, ComputeMatrixOperationActivity.class);
        detailIntent.putExtra(Extras.EXTRA_MATRIX_OPERATION_TRANSFER, operation);
        startActivity(detailIntent);

        Log.d(LOG_TAG, "Did select " + operation.getName());
    }

}
