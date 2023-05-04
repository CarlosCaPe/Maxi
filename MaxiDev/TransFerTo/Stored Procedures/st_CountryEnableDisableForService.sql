create procedure [TransFerTo].[st_CountryEnableDisableForService]
(    
    @IdCountry int,
    @IdGenericStatus int
)
as
declare @SystemUser int

select @SystemUser=[dbo].[GetGlobalAttributeByName] ( 'SystemUserID' ) 

update [TransFerTo].[Country] 
set
   IdGenericStatus = @IdGenericStatus,
   EnterByIdUser = @SystemUser,
   DateOfLastChange = getdate()
where 
   IdCountry=@IdCountry