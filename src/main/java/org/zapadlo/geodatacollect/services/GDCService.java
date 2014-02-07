package org.zapadlo.geodatacollect.services;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.zapadlo.geodatacollect.dao.GDCDao;
import org.zapadlo.geodatacollect.entity.GeoData;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.concurrent.*;

/**
 * Created by int21h on 30.01.14.
 */
@Service
public class GDCService {
    static final Logger logger = Logger.getLogger(GDCService.class);

    static final int GEO_DATA_INSERT_BATCH_SIZE = 100;

    BlockingQueue<GeoData> newData = new ArrayBlockingQueue<GeoData>(GEO_DATA_INSERT_BATCH_SIZE);

    ScheduledExecutorService scheduledExecutor = Executors.newSingleThreadScheduledExecutor();


    {
        scheduledExecutor.scheduleWithFixedDelay(new GeoDataInsertTask(),0, 10, TimeUnit.MILLISECONDS);
    }

    @Autowired
    GDCDao GDCDao;

    private class GeoDataInsertTask implements Runnable {
        @Override
        public void run() {
            List<GeoData> toInsert = new ArrayList<GeoData>();
            while (toInsert.size() < GEO_DATA_INSERT_BATCH_SIZE) {
                GeoData geoData = newData.poll();
                if (geoData == null) break;
                toInsert.add(geoData);
            }
            if (!toInsert.isEmpty()) {
                try {
                    GDCDao.addGeoData(toInsert);
                }
                catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }

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

    public void addGeoData(GeoData geoData) {
        //GDCDao.addGeoData(geoData);
        newData.offer(geoData);
    }


}
