create procedure [TransFerTo].[st_ProductEnableDisableForService]
(    
    @IdProduct int,
    @IdGenericStatus int
)
as
declare @SystemUser int

select @SystemUser=[dbo].[GetGlobalAttributeByName] ( 'SystemUserID' ) 

update [TransFerTo].[Product] 
set
   IdGenericStatus = @IdGenericStatus,
   EnterByIdUser = @SystemUser,
   DateOfLastChange = getdate()
where 
   IdProduct=@IdProduct