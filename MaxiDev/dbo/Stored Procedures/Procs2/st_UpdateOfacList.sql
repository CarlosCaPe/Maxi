CREATE Procedure [dbo].[st_UpdateOfacList]    
   @FilesLocation  nvarchar(max)        
AS    
   
Truncate table OFAC_SDN  
BULK INSERT [dbo].OFAC_SDN FROM 'd:\Bozdata\ofac\unzipped\sdn.pip'  WITH (FORMATFILE = 'c:\ofac\sdn.fmt' )       
Truncate table OFAC_ALT
BULK INSERT [dbo].OFAC_ALT FROM 'd:\Bozdata\ofac\unzipped\alt.pip'  WITH (FORMATFILE = 'c:\ofac\alt.fmt' )       

Insert into [MAXILOG].[dbo].OfacLog (Process,RunDate) values(@FilesLocation,GETDATE())  
