CREATE PROCEDURE [dbo].[st_SaveCounty]
(
    @IdCounty int,     
    @IdState int,
    @CountyName nvarchar(max),
    @EnterByIdUser int,
    @IdLenguage int,
    @ZipCodes xml,
    @CountyClasses xml,
    @IdCountyOut int out,
    @HasError bit out,
    @Message nvarchar(max) out
) 
as

begin try

--County
if isnull(@IdCounty,0)=0
begin
    Insert Into County (IdState,CountyName,DateOfLastChange,EnterByIdUser) values
    (@IdState,@CountyName,getdate(),@EnterByIdUser)
    set @IdCountyOut = SCOPE_IDENTITY()
end
else
begin
    update county set CountyName=@CountyName, DateOfLastChange=getdate(), EnterByIdUser=@EnterByIdUser where IdCounty=@IdCounty
    set @IdCountyOut=@IdCounty
end

--Zipcode
Declare @tzipcode table    
      (    
       id int    
      )    
    
Declare @DocHandle int      

EXEC sp_xml_preparedocument @DocHandle OUTPUT, @ZipCodes      
    
insert into @tzipcode(id)     
select id    
FROM OPENXML (@DocHandle, '/zipcodes/zipcode',1)     
WITH (id int)   

EXEC sp_xml_removedocument @DocHandle   

--limpiar zipcodes del condado
update zipcode set idcounty=null where idcounty=@IdCountyOut
--actualizar zipcodes del condatp
update zipcode set idcounty=@IdCountyOut where zipcode in (select id from @tzipcode)

-- zonas de riesgo

Declare @tcountyclass table    
      (    
       id int    
      )   
      
Declare @DocHandle2 int              

EXEC sp_xml_preparedocument @DocHandle2 OUTPUT, @CountyClasses      
    
insert into @tcountyclass(id)     
select id    
FROM OPENXML (@DocHandle2, '/countyclasses/countyclass',1)     
WITH (id int)   

EXEC sp_xml_removedocument @DocHandle2   

delete from RelationCountyCountyClass where IdCounty=@IdCountyOut

insert into RelationCountyCountyClass
(idcounty,idcountyclass)
select @IdCountyOut,id from @tcountyclass

Set @HasError=0                                                                                                          
SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'COUNTY')

end try
begin catch
 Set @HasError=1                                                                                                             
 SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'COUNTYE1')
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select  @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveCounty',Getdate(),@ErrorMessage)
end catch
