package com.ivanmagda.matrixmath.ui.view;

import android.content.Context;
import android.text.Editable;
import android.text.InputType;
import android.text.TextWatcher;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.EditText;

import com.ivanmagda.matrixmath.model.MatrixDimension;

import java.util.List;

public class MatrixAdapter extends BaseAdapter {

    private static final String LOG_TAG = MatrixAdapter.class.getSimpleName();

    private Context context;
    private MatrixDimension dimension;
    private List<String> elements;

    public MatrixAdapter(Context context, MatrixDimension dimension, List<String> elements) {
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
    public View getView(final int position, View convertView, ViewGroup parent) {
        EditText editText;
        if (convertView == null) {
            editText = new EditText(context);
            editText.setInputType(InputType.TYPE_CLASS_NUMBER
                    | InputType.TYPE_NUMBER_FLAG_DECIMAL
                    | InputType.TYPE_NUMBER_FLAG_SIGNED);
            editText.setGravity(Gravity.CENTER_VERTICAL | Gravity.CENTER_HORIZONTAL);
            editText.setSelected(false);
            editText.addTextChangedListener(new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                }

                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {
                }

                @Override
                public void afterTextChanged(Editable s) {
                    elements.set(position, s.toString());
                }
            });
        } else {
            editText = (EditText) convertView;
        }

        editText.setText(String.valueOf(getItem(position)));

        return editText;
    }

    public List<String> getElements() {
        return elements;
    }

    public void updateWithNewData(MatrixDimension dimension, List<String> elements) {
        this.dimension = dimension;
        this.elements = elements;
        notifyDataSetChanged();
    }
}
