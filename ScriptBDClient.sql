USE RSFACCAR
GO

ALTER DATABASE RSFACCAR
SET COMPATIBILITY_LEVEL = 100 -- For SQL Server 2008 R2
GO

--NORMALIZANDO LA BASE DE LA EMPRESA UNO
ALTER TABLE FT0001FACC
	ADD F5_COD_ESTADO_SUNAT INT
ALTER TABLE FT0001FACC
	ADD F5_MENSAJE_SUNAT VARCHAR(500)
ALTER TABLE FT0001FACC
	ADD F5_ESTADO_ENVIO INT
ALTER TABLE FT0001FACC
	ADD F5_XML VARCHAR(250)
ALTER TABLE FT0001FACC
	ADD F5_CDR VARCHAR(250)
ALTER TABLE FT0001FACC
	ADD F5_PDF VARCHAR(250)
GO

CREATE FUNCTION STRING_SPLIT ( @stringToSplit VARCHAR(MAX), @delimiter CHAR(1) )
RETURNS
@returnList TABLE ([value] [nvarchar] (1500))
AS
BEGIN

 DECLARE @name NVARCHAR(255)
 DECLARE @pos INT

 WHILE CHARINDEX(@delimiter, @stringToSplit) > 0
 BEGIN
  SELECT @pos  = CHARINDEX(@delimiter, @stringToSplit)  
  SELECT @name = SUBSTRING(@stringToSplit, 1, @pos-1)

  INSERT INTO @returnList 
  SELECT @name

  SELECT @stringToSplit = SUBSTRING(@stringToSplit, @pos+1, LEN(@stringToSplit)-@pos)
 END

 INSERT INTO @returnList
 SELECT @stringToSplit

 RETURN
END
GO

CREATE PROCEDURE SPS_TABFACCAB_BY_ESTDOCELE(
	@TX_ESTDOCELE VARCHAR(150),
	@NO_DOCELECAB VARCHAR(50)
)
AS
BEGIN
	DECLARE @TBL_DOCELECAB NVARCHAR(MAX);
	SET @TBL_DOCELECAB = 'SELECT * FROM ' + @NO_DOCELECAB + ' WHERE F5_ESTADO_ENVIO NOT IN(
		SELECT value  
		FROM STRING_SPLIT(''' + @TX_ESTDOCELE + ''', '','')  
		WHERE RTRIM(value) <> ''''
	)'
	EXEC SP_EXECUTESQL @TBL_DOCELECAB
END
GO

CREATE PROCEDURE SPS_TABFACDET_BY_TABFACCAB(
	@CO_DETALTIDO CHAR(2),
	@NU_DETSERSUN CHAR(4),
	@NU_DETNUMSUN CHAR(7),
	@NO_DOCELEDET VARCHAR(50)
)
AS
BEGIN
	DECLARE @TBL_DOCELEDET NVARCHAR(MAX);
	SET @TBL_DOCELEDET = 'SELECT * FROM ' + @NO_DOCELEDET +
	' WHERE F6_CTD = ''' + @CO_DETALTIDO + '''' +
	' AND F6_CNUMSER = ''' + @NU_DETSERSUN + '''' +
	' AND F6_CNUMDOC = ''' + @NU_DETNUMSUN + ''''
	EXEC SP_EXECUTESQL @TBL_DOCELEDET
END
GO

CREATE PROCEDURE SPU_TABFACCAB_MIG(
	@CO_DOCALTIDO CHAR(2),
	@NU_DOCSERSUN CHAR(4),
	@NU_DOCNUMSUN CHAR(7),
	@NO_DOCELECAB VARCHAR(50)
)
AS
BEGIN
	DECLARE @UPD_DOCELECAB NVARCHAR(MAX);
	SET @UPD_DOCELECAB = 'UPDATE ' +  @NO_DOCELECAB +
	' SET F5_ESTADO_ENVIO = 4' +
	' WHERE F5_CTD = ''' + @CO_DOCALTIDO + '''' +
	' AND F5_CNUMSER = ''' + @NU_DOCSERSUN + '''' +
	' AND F5_CNUMDOC = ''' + @NU_DOCNUMSUN + ''''
	EXEC SP_EXECUTESQL @UPD_DOCELECAB
END