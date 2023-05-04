create procedure [TransFerTo].[st_CarrierEnableDisableForService]
(    
    @IdCarrier int,
    @IdGenericStatus int
)
as
declare @SystemUser int

select @SystemUser=[dbo].[GetGlobalAttributeByName] ( 'SystemUserID' ) 

update [TransFerTo].[Carrier] 
set
   IdGenericStatus = @IdGenericStatus,
   EnterByIdUser = @SystemUser,
   DateOfLastChange = getdate()
where 
   IdCarrier=@IdCarrier