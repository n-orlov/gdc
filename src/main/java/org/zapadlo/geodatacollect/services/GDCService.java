package org.zapadlo.geodatacollect.services;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.zapadlo.geodatacollect.dao.IGDCDao;
import org.zapadlo.geodatacollect.entity.GeoData;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import java.util.*;
import java.util.concurrent.*;

/**
 * Created by int21h on 30.01.14.
 */
@Service
public class GDCService implements IGDCService {
    static final Logger logger = Logger.getLogger(GDCService.class);

    @Value("${geoDataInsert.BatchSize}")
    private Integer geoDataInsertBatchSize;

    @Value("${geoDataInsert.TaskCount}")
    private Integer geoDataInsertTaskCount;

    @Resource
    IGDCDao gdcDao;

    private int count = 0;
    private volatile Date cut = new Date();
    private final Object countLock = new Object();

    private Random randomGenerator = new Random();

    private Map<String, Integer> objectThread = new ConcurrentHashMap<String, Integer>();

    private ScheduledExecutorService scheduledExecutor;

    List<GeoDataInsertTask> insertTaskList;

    @PostConstruct
    private void init() {
        scheduledExecutor = Executors.newScheduledThreadPool(geoDataInsertTaskCount);
        insertTaskList = new ArrayList<GeoDataInsertTask>(geoDataInsertTaskCount);
        for (int i = 0; i < geoDataInsertTaskCount; i++) {
            GeoDataInsertTask task = new GeoDataInsertTask(i + 1);
            insertTaskList.add(task);
            scheduledExecutor.scheduleWithFixedDelay(task, 0, 10, TimeUnit.MILLISECONDS);
        }
    }

    private class GeoDataInsertTask implements Runnable {
        private BlockingQueue<GeoData> queue = new ArrayBlockingQueue<GeoData>(geoDataInsertBatchSize);
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
                while (toInsert.size() < geoDataInsertBatchSize) {
                    GeoData geoData = queue.poll();
                    if (geoData == null) break;
                    toInsert.add(geoData);
                }
                if (!toInsert.isEmpty()) {
                        synchronized (countLock) {
                            count += toInsert.size();
                        }
                        gdcDao.addGeoData(toInsert);
                        //logger.debug(String.format("Task: %d : Inserted %s records", id, count));

                }
                //count inserted per second
                logPerformance();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }

        private  void logPerformance() {
            synchronized (countLock) {
                Date now = new Date();
                if (now.getTime() - cut.getTime() > 10000) {
                    if (count > 0) {
                        logger.debug(String.format("Task: %d : Inserted %s records per second", id, (float)count / (now.getTime() - cut.getTime()) * 1000));
                    }
                    cut = new Date();
                    count= 0;
                }
            }
        }
    }

    @Override
    @Transactional(readOnly = true)
    public List<GeoData> getObjectTrack(String objectId, Date from, Date to) {
        return gdcDao.getObjectTrack(objectId, from, to);
    }

    @Override
    @Transactional(readOnly = true)
    public GeoData getObjectPosition(String objectId, Date byDate) {
        if (byDate != null) {
            return gdcDao.getObjectPosition(objectId, byDate);
        }
        else {
            return gdcDao.getObjectPosition(objectId);
        }
    }

    @Override
    public void addGeoData(GeoData geoData) throws InterruptedException {
        //gdcDao.addGeoData(geoData);
        Integer threadId = objectThread.get(StringUtils.upperCase(geoData.getObjectId()));
        if (threadId == null) {
            threadId = randomGenerator.nextInt(insertTaskList.size());
            objectThread.put(StringUtils.upperCase(geoData.getObjectId()), threadId);
        }
        insertTaskList.get(threadId).addItemToInsert(geoData);
    }


}
