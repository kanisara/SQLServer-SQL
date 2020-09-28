/*******************************************************
Generate each Tables ROW Size on SQL ServerDataabse ( Table name , Primary key value ) *****
Author : Saravanakumar G
Date   :27-09-2020
***************************************************************/

IF object_id('sp_GetRowSize') is not null
drop procedure sp_GetRowSize
GO
CREATE procedure sp_GetRowSize(@Tablename varchar(100),@pkcol varchar(100))
AS 
BEGIN
declare @dynamicsql varchar(1000)

-- A @pkcol can be used to identify max/min length row
set @dynamicsql = 'select ' + @PkCol +' , (0'

-- traverse each record and calculate the datalength
select @dynamicsql = @dynamicsql + ' + isnull(datalength(' + name + '), 1)' 
	from syscolumns where id = object_id(@Tablename)
set @dynamicsql = @dynamicsql + ') as rowsize from ' + @Tablename --+ ' order by AddressID'


exec (@dynamicsql)

END

--exec sp_GetRowSize 'regions', 'region_id'


/*******************************************************
Generate each Tables ROW Size on SQL ServerDataabse *****
Author : Saravanakumar G
Date   :27-09-2020
***************************************************************/


declare @table nvarchar(128)
declare @sql nvarchar(max)
set @sql = ''
DECLARE tableCursor CURSOR FOR  
SELECT name from sys.tables

open tableCursor
fetch next from tableCursor into @table

CREATE TABLE #TempTable( Tablename nvarchar(max), Bytes int, RowCnt int)

WHILE @@FETCH_STATUS = 0  
begin
    set @sql = 'insert into #TempTable (Tablename, Bytes, RowCnt) '
    set @sql = @sql + 'select '''+@table+''' "Table", sum(t.rowsize) "Bytes", count(*) "RowCnt" from (select (0'

    select @sql = @sql + ' + isnull(datalength([' + name + ']), 1) ' 
        from sys.columns where object_id = object_id(@table)
    set @sql = @sql + ') as rowsize from ' + @table + ' ) t '
    exec (@sql)
    FETCH NEXT FROM tableCursor INTO @table  
end

PRINT @sql

CLOSE tableCursor   
DEALLOCATE tableCursor

select * from #TempTable
select sum(bytes) "Sum" from #TempTable