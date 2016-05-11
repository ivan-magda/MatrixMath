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

    public static List<Double> toListOfDoubles(List<String> list) throws NumberFormatException {
        List<Double> res = new ArrayList<>(list.size());
        for (String string : list) {
            res.add(Double.parseDouble(string));
        }
        return res;
    }

}
