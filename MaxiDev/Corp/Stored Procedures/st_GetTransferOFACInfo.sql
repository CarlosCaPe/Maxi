CREATE procedure [Corp].[st_GetTransferOFACInfo]
(
    @IdTransfer int,
    @EnterByIdUser int = null,
	@InsertReview bit,
    @IsReviewByEnterByIdUser bit = null out
)
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/
SET NOCOUNT ON;
set @IsReviewByEnterByIdUser = isnull(@IsReviewByEnterByIdUser,0)
if not exists(select 1 from TransferOFACInfo with(nolock) where idtransfer=@IdTransfer) 
begin
        Declare @CustomerName nvarchar(max),
                @CustomerFirstLastName nvarchar(max),
                @CustomerSecondLastName nvarchar(max),    
                @BeneficiaryName nvarchar(max),
                @BeneficiaryFirstLastName nvarchar(max),
                @BeneficiarySecondLastName nvarchar(max),
                @IsOFAC bit,
                @IsOFACDoubleVerification bit
	
	DECLARE @PercentMatchOfac float /*Requerimiento_013017-2*/ 

    if exists(select 1 from transferdetail with(nolock) where idtransfer=@IdTransfer and idstatus=15)
    begin        
        select 
            @CustomerName=CustomerName,@CustomerFirstLastName=CustomerFirstLastName,@CustomerSecondLastName=CustomerSecondLastName,
            @BeneficiaryName=BeneficiaryName,@BeneficiaryFirstLastName=BeneficiaryFirstLastName,@BeneficiarySecondLastName=BeneficiarySecondLastName
        from [transfer] with(nolock)
        where idtransfer=@IdTransfer
        --Cambios para ofac transfer detail
           EXEC	[Corp].[st_SaveTransferOFACInfo]
		        @IdTransfer = @IdTransfer,		        
		        @CustomerName = @CustomerName,
		        @CustomerFirstLastName = @CustomerFirstLastName,
		        @CustomerSecondLastName = @CustomerSecondLastName,		        
		        @BeneficiaryName = @BeneficiaryName,
		        @BeneficiaryFirstLastName = @BeneficiaryFirstLastName,
		        @BeneficiarySecondLastName = @BeneficiarySecondLastName,		        
                @IsOLDTransfer = 1,
                @IsOFAC =  @IsOFAC out,
                @IsOFACDoubleVerification =  @IsOFACDoubleVerification out
				,@PercentMatchOfac = @PercentMatchOfac out; /*S09:Requerimiento_013017-2*/ 
    end
    else
    if exists(select 1 from transfercloseddetail with(nolock) where idtransferclosed=@IdTransfer and idstatus=15)
    begin
        select 
            @CustomerName=CustomerName,@CustomerFirstLastName=CustomerFirstLastName,@CustomerSecondLastName=CustomerSecondLastName,
            @BeneficiaryName=BeneficiaryName,@BeneficiaryFirstLastName=BeneficiaryFirstLastName,@BeneficiarySecondLastName=BeneficiarySecondLastName
        from transferclosed with(nolock)
        where idtransferclosed=@IdTransfer
        --Cambios para ofac transfer detail
           EXEC	[Corp].[st_SaveTransferOFACInfo]
		        @IdTransfer = @IdTransfer,		        
		        @CustomerName = @CustomerName,
		        @CustomerFirstLastName = @CustomerFirstLastName,
		        @CustomerSecondLastName = @CustomerSecondLastName,		        
		        @BeneficiaryName = @BeneficiaryName,
		        @BeneficiaryFirstLastName = @BeneficiaryFirstLastName,
		        @BeneficiarySecondLastName = @BeneficiarySecondLastName,		        
                @IsOLDTransfer = 1,
                @IsOFAC =  @IsOFAC out,
                @IsOFACDoubleVerification =  @IsOFACDoubleVerification out    
				,@PercentMatchOfac = @PercentMatchOfac out; /*S09:Requerimiento_013017-2*/    
    end
end

if @EnterByIdUser is null
begin
    set @EnterByIdUser= dbo.GetGlobalAttributeByName('SystemUserID')
end

--verificar revision
if exists(select 1 from TransferOFACReview with(nolock) where IdUserReview=@EnterByIdUser and idtransfer=@IdTransfer)
begin 
    set @IsReviewByEnterByIdUser=1
end

--registrar revision
if exists(select 1 from transferholds with(nolock) where idtransfer=@IdTransfer and idstatus=15 and IsReleased is null)
begin

	if @InsertReview=1 and @IsReviewByEnterByIdUser= 0 --only when @InsertReview is turned on and this user has not been registered into de reviewed table
	begin
		insert into TransferOFACReview
			(IdTransfer,IdUserReview,DateOfReview,IdOFACAction,Note)
		values
			(@IdTransfer,@EnterByIdUser,getdate(),1,'');
	end
end

select 
    i.IdTransfer,
    t.IdCustomer,
    t.CustomerName,
    t.CustomerFirstLastName,
    t.CustomerSecondLastName,
    round(CustomerOfacPercent,2) CustomerOfacPercent,
    CustomerMatch,
    IsCustomerFullMatch,
    t.IdBeneficiary,
    t.BeneficiaryName,
    t.BeneficiaryFirstLastName,
    t.BeneficiarySecondLastName,
    round(BeneficiaryOfacPercent,2) BeneficiaryOfacPercent,
    BeneficiaryMatch,
    IsBeneficiaryFullMatch,
    IdUserRelease1,
    isnull(u1.username,'') UserNameRelease1,
    isnull(UserNoteRelease1,'') UserNoteRelease1,
    DateOfRelease1,
    IdOFACAction1,
    isnull(a1.NameOFACAction,'') NameOFACAction1,
    IdUserRelease2,
    isnull(u2.username,'') UserNameRelease2,
    isnull(UserNoteRelease2,'') UserNoteRelease2,
    DateOfRelease2,
    IdOFACAction2,
    isnull(a2.NameOFACAction,'') NameOFACAction2,
    case when IsCustomerOldProccess=1 then 'Comparison' else 'Percentage' end CustomerMethod,
    case when IsBeneficiaryOldProccess =1 then 'Comparison' else 'Percentage' end  BeneficiaryMethod,
	IsCustomerOldProccess,
	IsBeneficiaryOldProccess
from TransferOFACInfo i with(nolock) 
join [transfer] t with(nolock) on t.idtransfer=i.idtransfer
left join users u1 with(nolock) on i.IdUserRelease1=u1.iduser
left join users u2 with(nolock) on i.IdUserRelease2=u2.iduser
left join OFACAction a1 with(nolock) on i.IdOFACAction1=a1.IdOFACAction
left join OFACAction a2 with(nolock) on i.IdOFACAction2=a2.IdOFACAction
where i.idtransfer=@IdTransfer
union all
select 
    i.IdTransfer,
    t.IdCustomer,
    t.CustomerName,
    t.CustomerFirstLastName,
    t.CustomerSecondLastName,
    round(CustomerOfacPercent,2) CustomerOfacPercent,
    CustomerMatch,
    IsCustomerFullMatch,
    t.IdBeneficiary,
    t.BeneficiaryName,
    t.BeneficiaryFirstLastName,
    t.BeneficiarySecondLastName,
    round(BeneficiaryOfacPercent,2) BeneficiaryOfacPercent,
    BeneficiaryMatch,
    IsBeneficiaryFullMatch,
    IdUserRelease1,
    isnull(u1.username,'') UserNameRelease1,
    isnull(UserNoteRelease1,'') UserNoteRelease1,
    DateOfRelease1,
    IdOFACAction1,
    isnull(a1.NameOFACAction,'') NameOFACAction1,
    IdUserRelease2,
    isnull(u2.username,'') UserNameRelease2,
    isnull(UserNoteRelease2,'') UserNoteRelease2,
    DateOfRelease2,
    IdOFACAction2,
    isnull(a2.NameOFACAction,'') NameOFACAction2,
    case when IsCustomerOldProccess=1 then 'Comparison' else 'Percentage' end CustomerMethod,
    case when IsBeneficiaryOldProccess =1 then 'Comparison' else 'Percentage' end  BeneficiaryMethod,
	IsCustomerOldProccess,
	IsBeneficiaryOldProccess
from TransferOFACInfo i with(nolock) 
join transferclosed t with(nolock) on t.idtransferclosed=i.idtransfer
left join users u1 with(nolock) on i.IdUserRelease1=u1.iduser
left join users u2 with(nolock) on i.IdUserRelease2=u2.iduser
left join OFACAction a1 with(nolock) on i.IdOFACAction1=a1.IdOFACAction
left join OFACAction a2 with(nolock) on i.IdOFACAction2=a2.IdOFACAction
where i.idtransfer=@IdTransfer
