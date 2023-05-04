CREATE Procedure [dbo].[st_UpdateOfacListCSV]    
   @FilesLocation  nvarchar(max)        
AS    

set @FilesLocation = 'C:\ofac\Unzip'

Truncate table OFAC_SDN  

begin try
BULK
INSERT OFAC_SDN
FROM 'C:\OFAC\Unzip\SDN.PIP'
 WITH (
    FORMATFILE = 'c:\ofac\sdn.fmt'    
    ,BATCHSIZE = 1
)       
end try
begin catch
end catch

Truncate table OFAC_ALT

begin try
BULK
INSERT OFAC_ALT
FROM 'C:\OFAC\Unzip\ALT.PIP'
 WITH (
 FORMATFILE = 'c:\ofac\alt.fmt' 
 ,BATCHSIZE = 1
 )       
end try
begin catch
end catch
/*
begin try
BULK
INSERT OFAC_ALT
FROM 'C:\OFAC\Unzip\CONS_ALT.PIP'
 WITH (
 FORMATFILE = 'c:\ofac\alt.fmt' 
 ,BATCHSIZE = 1
 )       
end try
begin catch
end catch
*/
exec [dbo].[OfacCompleteInfo]

begin try
DBCC DBREINDEX ('OFAC_ALT', OFAC_ALT_ENT_NUM,100) WITH NO_INFOMSGS;
DBCC DBREINDEX ('OFAC_SDN', OFAC_SDN_ENT_NUM,100) WITH NO_INFOMSGS;
end try
begin catch
end catch

if not exists (select top 1 1 from ofac_sdn) and not exists (select top 1 1 from ofac_alt)
begin
    RAISERROR (15600,-1,-1, 'Not OFAC Data');
end

Insert into [MAXILOG].[dbo].OfacLog (Process,RunDate) values(@FilesLocation,GETDATE())  
