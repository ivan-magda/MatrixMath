package com.ivanmagda.matrixmath.ui.view;

import android.content.Context;
import android.support.v4.content.ContextCompat;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.ivanmagda.matrixmath.model.MatrixDimension;

import java.util.List;

public class ResultAdapter extends BaseAdapter {

    private Context context;
    private MatrixDimension dimension;
    private List<Double> elements;

    public ResultAdapter(Context context, MatrixDimension dimension, List<Double> elements) {
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
        TextView textView;
        if (convertView == null) {
            textView = new TextView(context);
            textView.setGravity(Gravity.CENTER_VERTICAL | Gravity.CENTER_HORIZONTAL);
            textView.setTextColor(ContextCompat.getColor(context, android.R.color.black));
            textView.setTextSize(19);
        } else {
            textView = (TextView) convertView;
        }

        textView.setText(String.valueOf(getItem(position)));

        return textView;
    }

    public void updateWithNewData(MatrixDimension dimension, List<Double> elements) {
        this.dimension = dimension;
        this.elements = elements;
        notifyDataSetChanged();
    }

}
