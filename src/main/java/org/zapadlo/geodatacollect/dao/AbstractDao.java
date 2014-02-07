package org.zapadlo.geodatacollect.dao;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.support.JdbcDaoSupport;

import javax.annotation.PostConstruct;
import javax.sql.DataSource;

/**
 * Created by int21h on 30.01.14.
 */
public class AbstractDao extends JdbcDaoSupport {
    static final Logger logger = Logger.getLogger(AbstractDao.class);

    @Autowired
    @Qualifier("dataSource")
    private DataSource dataSource;

    @PostConstruct
    public final void init() {
        setDataSource(dataSource);
    }
}
