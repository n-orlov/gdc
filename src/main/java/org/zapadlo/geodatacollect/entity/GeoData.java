package org.zapadlo.geodatacollect.entity;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import org.zapadlo.geodatacollect.utils.JSONDateTimeSerializer;

import java.util.Date;

/**
 * Created by int21h on 05.02.14.
 */
public class GeoData {
    private final static String DATE_FORMAT = "dd-MM-yyyy hh:mm:ss";
    public static class Builder {
        private GeoData geoData = new GeoData();

        public Builder id(Integer id) {
            geoData.id = id;
            return this;
        }
        public Builder objectId(String objectId) {
            geoData.objectId = objectId;
            return this;
        }
        public Builder dateAdd(Date dateAdd) {
            geoData.dateAdd = dateAdd;
            return this;
        }
        public Builder dateDevice(Date dateDevice) {
            geoData.dateDevice = dateDevice;
            return this;
        }
        public Builder lon(Double lon) {
            geoData.lon = lon;
            return this;
        }
        public Builder lat(Double lat) {
            geoData.lat = lat;
            return this;
        }
        public Builder speed(Double speed) {
            geoData.speed = speed;
            return this;
        }
        public Builder degree(Double degree) {
            geoData.degree = degree;
            return this;
        }

        private void validate() {
            if (geoData.objectId == null) {
                throw new IllegalArgumentException();
            }
        }

        public GeoData build() {
            validate();
            return geoData;
        }
    }

    private Integer id;
    private String objectId;
    private Date dateAdd;
    private Date dateDevice;
    private Double lon;
    private Double lat;
    private Double speed;
    private Double degree;

    private GeoData() {
    }

    public Integer getId() {
        return id;
    }

    public String getObjectId() {
        return objectId;
    }

    @JsonSerialize(using = JSONDateTimeSerializer.class)
    public Date getDateAdd() {
        return dateAdd;
    }

    @JsonSerialize(using = JSONDateTimeSerializer.class)
    public Date getDateDevice() {
        return dateDevice;
    }

    public Double getLon() {
        return lon;
    }

    public Double getLat() {
        return lat;
    }

    public Double getSpeed() {
        return speed;
    }

    public Double getDegree() {
        return degree;
    }
}
