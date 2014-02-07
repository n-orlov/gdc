package org.zapadlo.geodatacollect.services;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.zapadlo.geodatacollect.dao.GDCDao;
import org.zapadlo.geodatacollect.entity.GeoData;

import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * Created by int21h on 30.01.14.
 */
@Service
public class GDCService {
    static final Logger logger = Logger.getLogger(GDCService.class);

    @Autowired
    GDCDao GDCDao;

    @Transactional(readOnly = true)
    public Map<String, String> getProperties() {
        return GDCDao.getProperties();
    }

    @Transactional(readOnly = true)
    public List<GeoData> getObjectTrack(String objectId, Date from, Date to) {
        return GDCDao.getObjectTrack(objectId, from, to);
    }

    @Transactional(readOnly = true)
    public GeoData getObjectPosition(String objectId, Date byDate) {
        if (byDate != null) {
            return GDCDao.getObjectPosition(objectId, byDate);
        }
        else {
            return GDCDao.getObjectPosition(objectId);
        }
    }

    @Transactional
    public void addGeoData(GeoData geoData) {
        GDCDao.addGeoData(geoData);
    }


}
