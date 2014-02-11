package org.zapadlo.geodatacollect.dao;

import org.springframework.dao.IncorrectResultSizeDataAccessException;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import org.zapadlo.geodatacollect.entity.GeoData;
import org.zapadlo.geodatacollect.utils.SimpleTimeMeasurer;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.List;

/**
 * Created by int21h on 30.01.14.
 */
@Repository
public class GDCDao extends AbstractDao implements IGDCDao {

    @Override
    public void addGeoData(GeoData geoData) {
        SimpleTimeMeasurer measurer = new SimpleTimeMeasurer("addGeoData / DAO");
        getJdbcTemplate().update("INSERT INTO GEO_DATA " +
                "(OBJECT_ID, DATE_ADD, DATE_DEVICE, LON, LAT, SPEED, DEG) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)",
                geoData.getObjectId(), geoData.getDateAdd(), geoData.getDateDevice(),
                geoData.getLon(), geoData.getLat(), geoData.getSpeed(), geoData.getDegree());
        measurer.logFinish();
    }

    private String getBatchGeoDataInsertSQL(int recordCount) {
        StringBuilder builder = new StringBuilder();
        builder.append("INSERT INTO GEO_DATA (OBJECT_ID, DATE_ADD, DATE_DEVICE, LON, LAT, SPEED, DEG) ");
        for (int i = 0; i < recordCount; i++) {
            builder.append("SELECT CAST(? as D_GUID), CAST(? as D_TIMESTAMP), CAST(? as D_TIMESTAMP), " +
                    "CAST(? AS DOUBLE PRECISION), CAST(? AS DOUBLE PRECISION), " +
                    "CAST(? AS DOUBLE PRECISION), CAST(? AS DOUBLE PRECISION) FROM RDB$DATABASE");
            if (i < recordCount - 1) {
                builder.append(" UNION ");
            }
        }
        return builder.toString();
    }

    @Override
    public void addGeoData(List<GeoData> geoDataList) {
        SimpleTimeMeasurer measurer = new SimpleTimeMeasurer("addGeoData / DAO");
        Object[] params = new Object[7 * geoDataList.size()];
        int i = 0;
        for (GeoData geoData : geoDataList) {
            params[i++] = geoData.getObjectId();
            params[i++] = geoData.getDateAdd();
            params[i++] = geoData.getDateDevice();
            params[i++] = geoData.getLon();
            params[i++] = geoData.getLat();
            params[i++] = geoData.getSpeed();
            params[i++] = geoData.getDegree();
        }
        getJdbcTemplate().update(getBatchGeoDataInsertSQL(geoDataList.size()), params);
        measurer.logFinish();
    }

    @Override
    public GeoData getObjectPosition(String objectId, Date byDate) {
        try {
            GeoData result = getJdbcTemplate().queryForObject("select FIRST 1 " +
                "GD.ID," +
                "GD.OBJECT_ID," +
                "GD.DATE_ADD," +
                "GD.DATE_DEVICE," +
                "GD.LON," +
                "GD.LAT," +
                "GD.SPEED," +
                "GD.DEG " +
                "from GEO_DATA gd " +
                "where gd.OBJECT_ID = ? " +
                "and gd.DATE_DEVICE <= ? " +
                "order by gd.DATE_DEVICE desc",
                new GeoDataRowMapper(),
                objectId, byDate
            );
            return result;
        }
        catch (IncorrectResultSizeDataAccessException e) {
            return null;
        }
    }

    @Override
    public GeoData getObjectPosition(String objectId) {
        try {
            GeoData result = getJdbcTemplate().queryForObject("select FIRST 1 " +
                "GD.ID," +
                "GD.OBJECT_ID," +
                "GD.DATE_ADD," +
                "GD.DATE_DEVICE," +
                "GD.LON," +
                "GD.LAT," +
                "GD.SPEED," +
                "GD.DEG " +
                "from GEO_OBJECTS o " +
                "left join GEO_DATA gd on (o.LAST_GEO_DATA_ID = gd.ID) " +
                "where o.ID = ?",
                new GeoDataRowMapper(),
                objectId
            );
            return result;
        }
        catch (IncorrectResultSizeDataAccessException e) {
            return null;
        }
    }

    @Override
    public List<GeoData> getObjectTrack(String objectId, Date from, Date to) {
        List<GeoData> result = getJdbcTemplate().query("select " +
                "GD.ID," +
                "GD.OBJECT_ID," +
                "GD.DATE_ADD," +
                "GD.DATE_DEVICE," +
                "GD.LON," +
                "GD.LAT," +
                "GD.SPEED," +
                "GD.DEG " +
                "from GEO_DATA gd " +
                "where gd.OBJECT_ID = ? " +
                "and gd.DATE_DEVICE BETWEEN ? and ? " +
                "order by gd.DATE_DEVICE",
                new GeoDataRowMapper(),
                objectId, from, to);
        return  result;
    }

    private static class GeoDataRowMapper implements RowMapper<GeoData> {
        @Override
        public GeoData mapRow(ResultSet rs, int rowNum) throws SQLException {
            return new GeoData.Builder()
                    .id(rs.getInt("ID"))
                    .objectId(rs.getString("OBJECT_ID"))
                    .dateAdd(rs.getDate("DATE_ADD"))
                    .dateDevice(rs.getDate("DATE_DEVICE"))
                    .lon(rs.getDouble("LON"))
                    .lat(rs.getDouble("LAT"))
                    .speed(rs.getDouble("SPEED"))
                    .degree(rs.getDouble("DEG"))
                    .build();
        }
    }
}
