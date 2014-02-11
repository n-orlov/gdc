package org.zapadlo.geodatacollect.dao;

import org.zapadlo.geodatacollect.entity.GeoData;

import java.util.Date;
import java.util.List;

/**
 * Created by int21h on 11.02.14.
 */
public interface IGDCDao {
    void addGeoData(GeoData geoData);

    void addGeoData(List<GeoData> geoDataList);

    GeoData getObjectPosition(String objectId, Date byDate);

    GeoData getObjectPosition(String objectId);

    List<GeoData> getObjectTrack(String objectId, Date from, Date to);
}
