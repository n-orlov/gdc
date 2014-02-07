package org.zapadlo.geodatacollect.web.controllers;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.zapadlo.geodatacollect.entity.GeoData;
import org.zapadlo.geodatacollect.services.GDCService;
import org.zapadlo.geodatacollect.utils.Utils;

import java.util.Date;
import java.util.List;

/**
 * Created by int21h on 05.02.14.
 */
@Controller
public class MainController {
    static final Logger logger = Logger.getLogger(MainController.class);

    @Autowired
    GDCService gdcService;

    @RequestMapping(value = "addGeoData")
    @ResponseStatus(HttpStatus.OK)
    public void addGeoData(
            @RequestParam String objectId,
            @RequestParam @DateTimeFormat(pattern=Utils.DATE_TIME_FORMAT) Date dateDevice,
            @RequestParam Double lon,
            @RequestParam Double lat,
            @RequestParam(required = false) Double speed,
            @RequestParam(required = false) Double degree
    ) {
        gdcService.addGeoData(new GeoData.Builder()
                .objectId(objectId)
                .dateDevice(dateDevice)
                .lon(lon)
                .lat(lat)
                .speed(speed)
                .degree(degree)
                .build());
    }

    @RequestMapping(value = "getObjectTrack")
    @ResponseBody
    List<GeoData> getObjectTrack(
            @RequestParam String objectId,
            @RequestParam @DateTimeFormat(pattern=Utils.DATE_TIME_FORMAT) Date from,
            @RequestParam @DateTimeFormat(pattern=Utils.DATE_TIME_FORMAT) Date to
    ) {
        return gdcService.getObjectTrack(objectId, from, to);
    }

    @RequestMapping(value = "getObjectPosition")
    @ResponseBody
    GeoData getObjectPosition(
            @RequestParam String objectId,
            @RequestParam(required = false) @DateTimeFormat(pattern=Utils.DATE_TIME_FORMAT) Date byDate
    ) {
        return gdcService.getObjectPosition(objectId, byDate);
    }

    @ExceptionHandler(Exception.class)
    @ResponseBody
    @ResponseStatus(value = HttpStatus.INTERNAL_SERVER_ERROR)
    public String handleCommonException(Exception ex) {
        ex.printStackTrace();
        return "Internal server error";
    }

}