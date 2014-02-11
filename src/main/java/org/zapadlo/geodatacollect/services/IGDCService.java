package org.zapadlo.geodatacollect.services;

import org.zapadlo.geodatacollect.entity.GeoData;

import java.util.Date;
import java.util.List;

/**
 * Created by int21h on 11.02.14.
 */
public interface IGDCService {
    List<GeoData> getObjectTrack(String objectId, Date from, Date to);

    GeoData getObjectPosition(String objectId, Date byDate);

    void addGeoData(GeoData geoData) throws InterruptedException;
}
