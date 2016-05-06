package com.ivanmagda.matrixmath.ui.view;

import android.content.Context;
import android.text.InputType;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.EditText;

import com.ivanmagda.matrixmath.model.MatrixDimension;

import java.util.List;

public class MatrixAdapter extends BaseAdapter {

    private Context context;
    private MatrixDimension dimension;
    private List<Double> elements;

    public MatrixAdapter(Context context, MatrixDimension dimension, List<Double> elements) {
        if (dimension.getCount() != elements.size()) throw new AssertionError();

        this.context = context;
        this.dimension = dimension;
        this.elements = elements;
    }

    @Override
    public int getCount() {
        return dimension.getCount();
    }

    @Override
    public Object getItem(int position) {
        return elements.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        EditText editText;
        if (convertView == null) {
            editText = new EditText(context);
            editText.setInputType(InputType.TYPE_CLASS_NUMBER
                    | InputType.TYPE_NUMBER_FLAG_DECIMAL
                    | InputType.TYPE_NUMBER_FLAG_SIGNED);
            editText.setGravity(Gravity.CENTER_VERTICAL | Gravity.CENTER_HORIZONTAL);
        } else {
            editText = (EditText) convertView;
        }

        editText.setText(String.valueOf(getItem(position)));

        return editText;
    }

    public void updateWithNewData(MatrixDimension dimension, List<Double> elements) {
        this.dimension = dimension;
        this.elements = elements;
        notifyDataSetChanged();
    }
}
