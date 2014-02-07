package org.zapadlo.geodatacollect.dao;

import junit.framework.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.test.context.ContextConfiguration;

/**
 * Created by int21h on 05.02.14.
 */
@RunWith(org.springframework.test.context.junit4.SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = {"classpath:../test-classes/applicationContext.xml"})
public class GDCDaoTest extends Assert{
    private GDCDao GDCDao;

    @Before
    public void init() {
        GDCDao = new GDCDao();
//        GDCDao.setJdbcTemplate(new JdbcTemplate());
    }

    @Test
    public void testGetProperties() throws Exception {
        assertEquals("test", "test");
    }
}
