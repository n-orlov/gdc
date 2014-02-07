package org.zapadlo.geodatacollect.utils;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Created by int21h on 06.02.14.
 */
public class Utils {
    public final static String DATE_TIME_FORMAT = "dd-MM-yyyy HH:mm:ss:SSS ZZZ";
    public final static String DATE_FORMAT = "dd-MM-yyyy HH:mm:ss:SSS";

    private final static SimpleDateFormat SIMPLE_DATE_TIME_FORMAT = new SimpleDateFormat(DATE_TIME_FORMAT);
    private final static SimpleDateFormat SIMPLE_DATE_FORMAT = new SimpleDateFormat(DATE_FORMAT);

    public static String getDateTimeString(Date date) {
        return SIMPLE_DATE_TIME_FORMAT.format(date);
    }
    public static String getDateString(Date date) {
        return SIMPLE_DATE_FORMAT.format(date);
    }
}
