package org.zapadlo.geodatacollect.utils;

import org.apache.log4j.Logger;

import java.util.Date;

/**
 * Created by int21h on 07.02.14.
 */
public class SimpleTimeMeasurer {
    static final Logger logger = Logger.getLogger(SimpleTimeMeasurer.class);
    private Date start;
    private String action;

    public SimpleTimeMeasurer(String action) {
        start = new Date();
        this.action = action;
        //logger.debug(String.format("Starting measurement of action: %s", action));
    }

    public void logStep(String stepName) {
        long millis = (new Date()).getTime() - start.getTime();
        start = new Date();
        logger.debug(String.format("Step of action: %s, name: %s, duration: %d ms", action, stepName, millis));
    }
    public void logFinish() {
        logStep("Finish");
    }
}
