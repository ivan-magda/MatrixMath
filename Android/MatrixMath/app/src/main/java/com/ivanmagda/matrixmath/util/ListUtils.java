package com.ivanmagda.matrixmath.util;

import java.util.ArrayList;
import java.util.List;

public class ListUtils {

    public static <T> List<String> toListOfString(List<T> list) {
        List<String> res = new ArrayList<>(list.size());
        for (T element : list)
            res.add(element.toString());
        return res;
    }

    public static List<Double> toListOfDoubles(List<String> list) {
        List<Double> res = new ArrayList<>(list.size());
        for (String string : list) {
            try {
                res.add(Double.parseDouble(string));
            } catch (NumberFormatException e) {
                res.add(0.0);
            }
        }
        return res;
    }

}
