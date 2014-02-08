package org.zapadlo.geodatacollect.services;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.zapadlo.geodatacollect.dao.GDCDao;
import org.zapadlo.geodatacollect.entity.GeoData;

import javax.annotation.PostConstruct;
import java.util.*;
import java.util.concurrent.*;

/**
 * Created by int21h on 30.01.14.
 */
@Service
public class GDCService {
    @Autowired
    GDCDao gdcDao;

    static final Logger logger = Logger.getLogger(GDCService.class);

    static final int GEO_DATA_INSERT_BATCH_SIZE = 100;
    static final int GEO_DATA_INSERT_TASK_COUNT = 3;

    private volatile int count = 0;
    private volatile Date cut = new Date();

    private Random randomGenerator = new Random();

    private ApplicationContext applicationContext;

    private ScheduledExecutorService scheduledExecutor = Executors.newScheduledThreadPool(GEO_DATA_INSERT_TASK_COUNT);

    List<GeoDataInsertTask> insertTaskList = new ArrayList<GeoDataInsertTask>(GEO_DATA_INSERT_TASK_COUNT);

    @PostConstruct
    private void init() {
        for (int i = 0; i < GEO_DATA_INSERT_TASK_COUNT; i++) {
            GeoDataInsertTask task = new GeoDataInsertTask(i + 1);
            insertTaskList.add(task);
            scheduledExecutor.scheduleWithFixedDelay(task, 0, 10, TimeUnit.MILLISECONDS);
        }
    }

    private class GeoDataInsertTask implements Runnable {
        private BlockingQueue<GeoData> queue = new ArrayBlockingQueue<GeoData>(GEO_DATA_INSERT_BATCH_SIZE);
        private int id;

        private GeoDataInsertTask(int id) {
            this.id = id;
        }

        public void addItemToInsert(GeoData geoData) throws InterruptedException {
            queue.put(geoData);
        }

        @Override
        public void run() {
            try {
                //logger.debug(String.format("Task: %d : Firing", id));
                List<GeoData> toInsert = new ArrayList<GeoData>();
                while (toInsert.size() < GEO_DATA_INSERT_BATCH_SIZE) {
                    GeoData geoData = queue.poll();
                    if (geoData == null) break;
                    toInsert.add(geoData);
                }
                if (!toInsert.isEmpty()) {
                        count = count + toInsert.size();
                        gdcDao.addGeoData(toInsert);
                        //logger.debug(String.format("Task: %d : Inserted %s records", id, count));

                }
                //count inserted per second
                synchronized (cut) {
                    Date now = new Date();
                    if (now.getTime() - cut.getTime() > 10000) {
                        if (count > 0) {
                            logger.debug(String.format("Task: %d : Inserted %s records per second", id, (float)count / (now.getTime() - cut.getTime()) * 1000));
                        }
                        cut = new Date();
                        count = 0;
                    }
                }
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    @Transactional(readOnly = true)
    public Map<String, String> getProperties() {
        return gdcDao.getProperties();
    }

    @Transactional(readOnly = true)
    public List<GeoData> getObjectTrack(String objectId, Date from, Date to) {
        return gdcDao.getObjectTrack(objectId, from, to);
    }

    @Transactional(readOnly = true)
    public GeoData getObjectPosition(String objectId, Date byDate) {
        if (byDate != null) {
            return gdcDao.getObjectPosition(objectId, byDate);
        }
        else {
            return gdcDao.getObjectPosition(objectId);
        }
    }

    public void addGeoData(GeoData geoData) throws InterruptedException {
        //gdcDao.addGeoData(geoData);
        insertTaskList.get(randomGenerator.nextInt(insertTaskList.size())).addItemToInsert(geoData);
    }


}
