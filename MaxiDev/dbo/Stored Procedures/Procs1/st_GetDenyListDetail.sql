/********************************************************************
<Author>smacias</Author>
<app>??</app>
<Description>??</Description>

<ChangeLog>
<log Date="06/12/2018" Author="smacias"> Creado </log>
</ChangeLog>

*********************************************************************/
CREATE procedure [dbo].[st_GetDenyListDetail]
(
	@idDenyListItem int,
	@isCustomer bit
)
AS  

Set nocount on;
Begin try
	if (@isCustomer = 1)
		Select 
		IdDenyListCustomerAction,
        dc.IdKYCAction,
        [Action],
        MessageInEnglish,
        MessageInSpanish,
        IdTypeRequired,
        OccupationRequired,
        SSNRequired,
        DateOfBirthRequired,
        IdNumberRequired,
        IdExpirationDateRequired,
        IdStateCountryRequired
		from DenyListCustomerActions dc with(nolock)
		join KYCAction k with(nolock) on dc.IdKYCAction = k.IdKYCAction
		where IdDenyListCustomer = @idDenyListItem
		
	else -- Update
		Select 
		IdDenyListBeneficiaryAction,
        db.IdKYCAction,
        [Action],
        MessageInEnglish,
        MessageInSpanish,
        IdTypeRequired,
        OccupationRequired,
        SSNRequired,
        DateOfBirthRequired,
        IdNumberRequired,
        IdExpirationDateRequired,
        IdStateCountryRequired
		from DenyListBeneficiaryActions db with(nolock) join KYCAction k with(nolock) on db.IdKYCAction = k.IdKYCAction
		where IdDenyListBeneficiary = @idDenyListItem
End try
Begin Catch
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetDenyListDetail',Getdate(),@ErrorMessage);
End catch
