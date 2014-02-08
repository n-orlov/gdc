/******************************************************************************/
/***         Generated by IBExpert 2013.12.27.1 08.02.2014 6:28:09          ***/
/******************************************************************************/

/******************************************************************************/
/***      Following SET SQL DIALECT is just for the Database Comparer       ***/
/******************************************************************************/
SET SQL DIALECT 3;



/******************************************************************************/
/***                                Domains                                 ***/
/******************************************************************************/

CREATE DOMAIN D_DESC_512 AS
VARCHAR(512);

CREATE DOMAIN D_GUID AS
VARCHAR(32);

CREATE DOMAIN D_INTEGER AS
INTEGER;

CREATE DOMAIN D_INTEGER_ID AS
INTEGER
NOT NULL;

CREATE DOMAIN D_TIMESTAMP AS
TIMESTAMP;



/******************************************************************************/
/***                               Generators                               ***/
/******************************************************************************/

CREATE GENERATOR GEN_GEO_DATA_ID;
SET GENERATOR GEN_GEO_DATA_ID TO 541725;

CREATE GENERATOR GEN_PROPERTIES_ID;
SET GENERATOR GEN_PROPERTIES_ID TO 0;



SET TERM ^ ; 



/******************************************************************************/
/***                           Stored Procedures                            ***/
/******************************************************************************/

CREATE PROCEDURE GET_HEX_UUID
RETURNS (
    REAL_UUID CHAR(16) CHARACTER SET OCTETS,
    HEX_UUID VARCHAR(32))
AS
BEGIN
  SUSPEND;
END^






SET TERM ; ^



/******************************************************************************/
/***                                 Tables                                 ***/
/******************************************************************************/



CREATE TABLE GEO_DATA (
    ID           D_INTEGER_ID NOT NULL,
    OBJECT_ID    D_GUID,
    DATE_ADD     D_TIMESTAMP,
    DATE_DEVICE  D_TIMESTAMP,
    LON          DOUBLE PRECISION,
    LAT          DOUBLE PRECISION,
    SPEED        DOUBLE PRECISION,
    DEG          DOUBLE PRECISION
);


CREATE TABLE GEO_OBJECTS (
    ID                D_GUID NOT NULL,
    DESCRIPTION       D_DESC_512,
    LAST_GEO_DATA_ID  D_INTEGER
);


CREATE TABLE PROPERTIES (
    ID    INTEGER NOT NULL,
    NAME  VARCHAR(255) NOT NULL,
    VAL   BLOB SUB_TYPE 0 SEGMENT SIZE 80
);




/******************************************************************************/
/***                              Primary Keys                              ***/
/******************************************************************************/

ALTER TABLE GEO_DATA ADD CONSTRAINT PK_GEO_DATA PRIMARY KEY (ID);
ALTER TABLE GEO_OBJECTS ADD CONSTRAINT PK_GEO_OBJECTS PRIMARY KEY (ID);
ALTER TABLE PROPERTIES ADD CONSTRAINT PK_PROPERTIES PRIMARY KEY (ID);


/******************************************************************************/
/***                              Foreign Keys                              ***/
/******************************************************************************/

ALTER TABLE GEO_DATA ADD CONSTRAINT FK_GEO_DATA_1 FOREIGN KEY (OBJECT_ID) REFERENCES GEO_OBJECTS (ID);
ALTER TABLE GEO_OBJECTS ADD CONSTRAINT FK_GEO_OBJECTS_1 FOREIGN KEY (LAST_GEO_DATA_ID) REFERENCES GEO_DATA (ID);


/******************************************************************************/
/***                                Indices                                 ***/
/******************************************************************************/

CREATE INDEX GEO_DATA_OBJECT_DATE ON GEO_DATA (OBJECT_ID, DATE_DEVICE);


/******************************************************************************/
/***                                Triggers                                ***/
/******************************************************************************/


SET TERM ^ ;



/******************************************************************************/
/***                          Triggers for tables                           ***/
/******************************************************************************/



/* Trigger: GEO_DATA_AI0 */
CREATE TRIGGER GEO_DATA_AI0 FOR GEO_DATA
ACTIVE AFTER INSERT POSITION 0
AS
begin
  UPDATE GEO_OBJECTS SET LAST_GEO_DATA_ID = NEW.ID WHERE ID = NEW.OBJECT_ID;
end
^


/* Trigger: GEO_DATA_BI */
CREATE TRIGGER GEO_DATA_BI FOR GEO_DATA
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(GEN_GEO_DATA_ID,1);
  IF ((NEW.DATE_ADD IS NULL)) THEN
    NEW.DATE_ADD = 'now';
END
^


/* Trigger: GEO_OBJECTS_BI0 */
CREATE TRIGGER GEO_OBJECTS_BI0 FOR GEO_OBJECTS
ACTIVE BEFORE INSERT POSITION 0
AS
DECLARE VARIABLE NEWID D_GUID;
BEGIN
  IF (NEW.ID IS NULL) THEN
  BEGIN
    SELECT G.HEX_UUID
    FROM GET_HEX_UUID G
    INTO :NEWID;
    NEW.ID = NEWID;
  END
END
^


/* Trigger: PROPERTIES_BI */
CREATE TRIGGER PROPERTIES_BI FOR PROPERTIES
ACTIVE BEFORE INSERT POSITION 0
as
begin
  if (new.id is null) then
    new.id = gen_id(gen_properties_id,1);
end
^


SET TERM ; ^



/******************************************************************************/
/***                           Stored Procedures                            ***/
/******************************************************************************/


SET TERM ^ ;

ALTER PROCEDURE GET_HEX_UUID
RETURNS (
    REAL_UUID CHAR(16) CHARACTER SET OCTETS,
    HEX_UUID VARCHAR(32))
AS
declare variable i integer;
declare variable c integer;
BEGIN
real_uuid = GEN_UUID();
hex_uuid = '';
i = 0;
while (i < 16) do
begin
c = ascii_val(substring(real_uuid from i+1 for 1));
if (c < 0) then c = 256 + c;
hex_uuid = hex_uuid 
|| substring('0123456789abcdef' from bin_shr(c, 4) + 1 for 1) 
|| substring('0123456789abcdef' from bin_and(c, 15) + 1 for 1); 
i = i + 1;
end
suspend;
END^



SET TERM ; ^