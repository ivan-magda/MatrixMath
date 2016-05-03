package com.ivanmagda.matrixmath.ui.view;

import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.ivanmagda.matrixmath.R;
import com.ivanmagda.matrixmath.model.MatrixOperation;

import java.util.List;

public class MatrixOperationsRecyclerViewAdapter extends RecyclerView.Adapter<MatrixOperationsRecyclerViewAdapter.MatrixOperationsViewHolder> {

    // MatrixOperationsViewHolder extends RecyclerView.ViewHolder

    public static class MatrixOperationsViewHolder extends RecyclerView.ViewHolder {

        // Properties.

        protected TextView title;
        protected TextView subtitle;

        // Constructor.

        public MatrixOperationsViewHolder(View itemView) {
            super(itemView);

            title = (TextView) itemView.findViewById(R.id.matrix_operation_title_text_view);
            subtitle = (TextView) itemView.findViewById(R.id.matrix_operation_subtitle_text_view);
        }

    }

    // Properties.

    private List<MatrixOperation> operations;

    // Constructor.

    public MatrixOperationsRecyclerViewAdapter(List<MatrixOperation> operations) {
        this.operations = operations;
    }

    // Getter.

    public List<MatrixOperation> getOperations() {
        return operations;
    }

    // Override.

    @Override
    public MatrixOperationsViewHolder onCreateViewHolder(ViewGroup viewGroup, int viewType) {
        View view = LayoutInflater.from(viewGroup.getContext())
                .inflate(R.layout.matrix_operation_item, viewGroup, false);
        return new MatrixOperationsViewHolder(view);
    }

    @Override
    public void onBindViewHolder(MatrixOperationsViewHolder matrixOperationsViewHolder, int position) {
        MatrixOperation operation = operations.get(position);

        matrixOperationsViewHolder.title.setText(operation.getName());

        matrixOperationsViewHolder.subtitle.setVisibility(
                operation.getDetailDescription() == null
                        ? View.GONE
                        : View.VISIBLE);

        if (operation.getDetailDescription() != null) {
            matrixOperationsViewHolder.subtitle.setText(operation.getDetailDescription());
        }

    }

    @Override
    public int getItemCount() {
        return (operations == null ? 0 : operations.size());
    }

}
