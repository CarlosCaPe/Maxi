CREATE procedure [Corp].[st_GetTransferOFACCheckInfo]
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
<log Date="13/01/2020" Author="esalazar">Add @IsOFACDoubleVerification required for [Corp].[st_SaveCheckOFACInfo_Checks]</log>
</ChangeLog>
*********************************************************************/
set @IsReviewByEnterByIdUser = isnull(@IsReviewByEnterByIdUser,0)
if not exists(select 1 from CheckOFACInfo with(nolock) where IdCheck=@IdTransfer) 
begin
        Declare @CustomerName nvarchar(max),
                @CustomerFirstLastName nvarchar(max),
                @CustomerSecondLastName nvarchar(max),    
                @BeneficiaryName nvarchar(max),
                @BeneficiaryFirstLastName nvarchar(max),
                @BeneficiarySecondLastName nvarchar(max),
                @IsOFAC bit,
                @IsOFACDoubleVerification bit

    if exists(select 1 from CheckDetails with(nolock) where idcheck=@IdTransfer and idstatus=15)
    begin        
        select 
            @CustomerName=Name,@CustomerFirstLastName=FirstLastName,@CustomerSecondLastName=SecondLastName,
            @BeneficiaryName=IssuerName,@BeneficiaryFirstLastName='',@BeneficiarySecondLastName=''
        from checks with(nolock)
        where IdCheck=@IdTransfer
        --Cambios para ofac transfer detail
           EXEC	[Corp].[st_SaveCheckOFACInfo_Checks]
		        @IdCheck = @IdTransfer,		        
		        @CustomerName = @CustomerName,
		        @CustomerFirstLastName = @CustomerFirstLastName,
		        @CustomerSecondLastName = @CustomerSecondLastName,		        
		        @IssuerName = @BeneficiaryName,
				@IsOFACDoubleVerification =  @IsOFACDoubleVerification OUTPUT,
                @IsOFAC =  @IsOFAC out;     
    end
    
end
if @EnterByIdUser is null
begin
    set @EnterByIdUser= dbo.GetGlobalAttributeByName('SystemUserID')
end

--verificar revision
if exists(select 1 from CheckOFACReview with(nolock) where IdUserReview=@EnterByIdUser and IdCheck=@IdTransfer)
begin 
    set @IsReviewByEnterByIdUser=1
end

--registrar revision
if exists(select 1 from CheckHolds with(nolock) where IdCheck=@IdTransfer and idstatus=15 and IsReleased is null)
begin

	if @InsertReview=1 and @IsReviewByEnterByIdUser= 0 --only when @InsertReview is turned on and this user has not been registered into de reviewed table
	begin
		insert into checkofacreview
			(IdCheck,IdUserReview,DateOfReview,IdOFACAction,Note)
		values
			(@IdTransfer,@EnterByIdUser,getdate(),1,'');
	end
end

select 
    i.IdCheck,
    t.IdCustomer,
    t.Name,
    t.FirstLastName,
    t.SecondLastName,
    round(CustomerOfacPercent,2) CustomerOfacPercent,
    CustomerMatch,
    IsCustomerFullMatch,
    '' as IdBeneficiary,
    '' as BeneficiaryName,
    '' as BeneficiaryFirstLastName,
    '' as BeneficiarySecondLastName,
    round(IssuerOfacPercent,2) as BeneficiaryOfacPercent,
    IssuerMatch as BeneficiaryMatch,
    IsIssuerFullMatch as IsBeneficiaryFullMatch,
    IdUserRelease1,
    isnull(u1.username,'') UserNameRelease1,
    isnull(UserNoteRelease1,'') UserNoteRelease1,
    DateOfRelease1,
    IdOFACAction1,
    isnull(a1.NameOFACAction,'') NameOFACAction1,
    '' as IdUserRelease2,
    isnull(u2.username,'') UserNameRelease2,
    '' as UserNoteRelease2,
    '' as DateOfRelease2,
   '' as  IdOFACAction2,
    isnull(a2.NameOFACAction,'') NameOFACAction2
from checkofacinfo i with(nolock)
left join users u1 with(nolock) on i.IdUserRelease1=u1.iduser
left join users u2 with(nolock) on i.IdUserRelease1=u2.iduser
left join OFACAction a1 with(nolock) on i.IdOFACAction1=a1.IdOFACAction
left join OFACAction a2 with(nolock) on i.IdOFACAction1=a2.IdOFACAction
join checks t with(nolock) on t.IdCheck=i.IdCheck
where i.IdCheck=@IdTransfer;
