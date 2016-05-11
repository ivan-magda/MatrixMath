package com.ivanmagda.matrixmath.ui.activity;

import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.ivanmagda.matrixmath.Extras;
import com.ivanmagda.matrixmath.R;
import com.ivanmagda.matrixmath.model.MatrixDimension;

import biz.kasual.materialnumberpicker.MaterialNumberPicker;


public class MatrixDimensionActivity extends AppCompatActivity {

    private static final String LOG_TAG = MatrixDimensionActivity.class.getSimpleName();

    private static final int MIN_VALUE = 1;
    private static final int MAX_VALUE = 7;

    private TextView columnsSizeTextView;
    private TextView rowsSizeTextView;
    private TextView columnsTitleTextView;
    private TextView rowsTitleTextView;
    private Button doneButton;

    private MatrixDimension dimension;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_matrix_dimension);

        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setTitle(R.string.title_matrix_dimension_activity);
        }

        Intent intent = getIntent();
        dimension = (MatrixDimension) intent.getSerializableExtra(Extras.EXTRA_MATRIX_DIMENSION_TRANSFER);
        assert dimension != null;

        doneButton = (Button) findViewById(R.id.dimension_done_button);
        columnsTitleTextView = (TextView) findViewById(R.id.number_of_columns);
        rowsTitleTextView = (TextView) findViewById(R.id.number_of_rows);
        columnsSizeTextView = (TextView) findViewById(R.id.number_of_columns_text);
        rowsSizeTextView = (TextView) findViewById(R.id.number_of_rows_text);

        columnsSizeTextView.setText(String.valueOf(dimension.getColumns()));
        rowsSizeTextView.setText(String.valueOf(dimension.getRows()));

        doneButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onActivityResult();
            }
        });

        columnsTitleTextView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final MaterialNumberPicker numberPicker = numberPickerWithDefaultValue(dimension.getColumns());

                new AlertDialog.Builder(MatrixDimensionActivity.this)
                        .setTitle(getString(R.string.columns))
                        .setView(numberPicker)
                        .setPositiveButton(getString(android.R.string.ok), new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                int value = numberPicker.getValue();
                                dimension.setColumns(value);
                                columnsSizeTextView.setText(String.valueOf(value));
                            }
                        })
                        .show();
            }
        });
        columnsSizeTextView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final MaterialNumberPicker numberPicker = numberPickerWithDefaultValue(dimension.getColumns());

                new AlertDialog.Builder(MatrixDimensionActivity.this)
                        .setTitle(getString(R.string.columns))
                        .setView(numberPicker)
                        .setPositiveButton(getString(android.R.string.ok), new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                int value = numberPicker.getValue();
                                dimension.setColumns(value);
                                columnsSizeTextView.setText(String.valueOf(value));
                            }
                        })
                        .show();
            }
        });

        rowsTitleTextView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final MaterialNumberPicker numberPicker = numberPickerWithDefaultValue(dimension.getRows());

                new AlertDialog.Builder(MatrixDimensionActivity.this)
                        .setTitle(getString(R.string.rows))
                        .setView(numberPicker)
                        .setPositiveButton(getString(android.R.string.ok), new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                int value = numberPicker.getValue();
                                dimension.setRows(value);
                                rowsSizeTextView.setText(String.valueOf(value));
                            }
                        })
                        .show();
            }
        });
        rowsSizeTextView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final MaterialNumberPicker numberPicker = numberPickerWithDefaultValue(dimension.getRows());

                new AlertDialog.Builder(MatrixDimensionActivity.this)
                        .setTitle(getString(R.string.rows))
                        .setView(numberPicker)
                        .setPositiveButton(getString(android.R.string.ok), new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                int value = numberPicker.getValue();
                                dimension.setRows(value);
                                rowsSizeTextView.setText(String.valueOf(value));
                            }
                        })
                        .show();
            }
        });
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        setResult(RESULT_CANCELED);
        finish();
    }

    private void onActivityResult() {
        Intent data = new Intent();
        if (dimension != null) {
            data.putExtra(Extras.EXTRA_MATRIX_DIMENSION_TRANSFER, dimension);
            setResult(RESULT_OK, data);
        } else {
            setResult(RESULT_CANCELED);
        }

        finish();
    }

    private MaterialNumberPicker numberPickerWithDefaultValue(int value) {
        return new MaterialNumberPicker.Builder(MatrixDimensionActivity.this)
                .minValue(MIN_VALUE)
                .maxValue(MAX_VALUE)
                .defaultValue(value)
                .backgroundColor(Color.WHITE)
                .separatorColor(Color.TRANSPARENT)
                .textColor(Color.BLACK)
                .textSize(19)
                .enableFocusability(false)
                .wrapSelectorWheel(true)
                .build();
    }

}
