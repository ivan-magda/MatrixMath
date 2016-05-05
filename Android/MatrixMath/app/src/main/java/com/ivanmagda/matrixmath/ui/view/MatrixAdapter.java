package com.ivanmagda.matrixmath.ui.view;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.EditText;

public class MatrixAdapter extends BaseAdapter {
    private Context context;

    public MatrixAdapter(Context context) {
        this.context = context;
    }

    @Override
    public int getCount() {
        return 9;
    }

    @Override
    public Object getItem(int position) {
        return null;
    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        EditText editText;
        if (convertView == null) {
            editText = new EditText(context);
        } else {
            editText = (EditText) convertView;
        }

        return editText;
    }
}
