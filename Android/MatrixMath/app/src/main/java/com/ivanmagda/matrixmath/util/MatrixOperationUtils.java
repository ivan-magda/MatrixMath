package com.ivanmagda.matrixmath.util;

import android.content.Context;

import com.ivanmagda.matrixmath.R;
import com.ivanmagda.matrixmath.model.MatrixOperation;
import com.ivanmagda.matrixmath.model.MatrixOperationType;

import java.util.ArrayList;
import java.util.List;

public class MatrixOperationUtils {

    private MatrixOperationUtils() {
    }

    public static List<MatrixOperation> getAllMethods(Context context) {
        List<MatrixOperation> operations = new ArrayList<>(8);

        operations.add(new MatrixOperation(context.getString(R.string.matrix_addition_operation),
                MatrixOperationType.ADDITION));
        operations.add(new MatrixOperation(context.getString(R.string.matrix_subtract_operation),
                MatrixOperationType.SUBTRACT));
        operations.add(new MatrixOperation(context.getString(R.string.matrix_multiply_operation),
                MatrixOperationType.MULTIPLY));
        operations.add(new MatrixOperation(context.getString(R.string.matrix_transpose_operation),
                MatrixOperationType.TRANSPOSE));
        operations.add(new MatrixOperation(context.getString(R.string.matrix_invert_operation),
                MatrixOperationType.INVERT));
        operations.add(new MatrixOperation(context.getString(R.string.matrix_determinant_operation),
                MatrixOperationType.DETERMINANT));
        operations.add(new MatrixOperation(context.getString(R.string.matrix_solve_operation),
                MatrixOperationType.SOLVE));
        operations.add(new MatrixOperation(context.getString(R.string.matrix_solve_operation),
                context.getString(R.string.matrix_solve_with_error_correction_description),
                MatrixOperationType.SOLVE_WITH_ERROR_CORRECTION));

        return operations;
    }

}
