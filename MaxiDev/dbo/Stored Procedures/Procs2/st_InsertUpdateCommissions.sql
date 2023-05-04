/********************************************************************
<Author>smacias</Author>
<app>??</app>
<Description>??</Description>

<ChangeLog>
<log Date="04/12/2018" Author="smacias"> Creado </log>
<log Date="26/11/2019" Author="smacias"> Segundo Commit Transaction comentado </log>
</ChangeLog>

*********************************************************************/
CREATE procedure [dbo].[st_InsertUpdateCommissions]
(
	@IdCommission int = null out,
	@CommissionName nvarchar(max),
	@XmlCommissionDetails xml,
	@IdUser int,
	@HasError bit out
)
AS  
Declare @DateofLastChange datetime = GETDATE();
Set nocount on;
begin try
Begin Transaction;
if(@IdCommission = 0 or @IdCommission is null)
	begin
		insert into Commission (CommissionName, DateOfLastChange, EnterByIdUser) values (@CommissionName, @DateofLastChange, @IdUser);
		Set @IdCommission = (Select IdCommission from Commission with (nolock) where IdCommission = @@IDENTITY);
	end
else
	begin
		-- Begin Transaction;
		Update Commission set CommissionName = @CommissionName where IdCommission = @IdCommission;
		Delete CommissionDetail where IdCommission = @IdCommission;
	end
	Declare @DocHandle int  
	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @XmlCommissionDetails     
	insert into CommissionDetail
	(
		IdCommission,
		FromAmount,
		ToAmount,
		AgentCommissionInPercentage,
		CorporateCommissionInPercentage,
		DateOfLastChange,
		EnterByIdUser,
		ExtraAmount
	)
	Select @IdCommission,FromAmount,ToAmount,AgentCommissionPercentage,CorporateCommissionPercentage,@DateofLastChange,@IdUser,ExtraAmount
	From OPENXML (@DocHandle, '/CommissionDetail/Detail',5)    
		WITH (
		AgentCommissionPercentage money,
		CorporateCommissionPercentage money,
		FromAmount money,
		ToAmount money,
		ExtraAmount money	 
		)     
	Exec sp_xml_removedocument @DocHandle   
	Set @HasError = 0
	Commit Transaction;
end try
begin catch
	RollBack Transaction;
	Set @HasError = 1
	DECLARE @ErrorMessage varchar(max);
	Select @ErrorMessage = ERROR_MESSAGE();
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_InsertUpdateCommissions',Getdate(),@ErrorMessage);
end catch
