CREATE procedure [dbo].[st_FindDenyListByName]  
(  
    @Name varchar(max),  
    @FirstLastName nvarchar(max),  
    @SecondLastName nvarchar(max),
    @IdLenguage int,
    @IsCustomer bit,
	@Id bigint = null,
    @HasError bit output,            
    @Message nvarchar(max) output    
)  
As
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="01/04/2019" Author="azavala">search first by ID :: Ref: 05062019_azavala</log>
<log Date="14/05/2019" Author="azavala">Add scenarie when search with ID + Names :: Ref: 15042019_azavala</log>
</ChangeLog>
********************************************************************/
Set nocount on  
declare @Tot int

if @IdLenguage is null 
    set @IdLenguage=2
set @HasError=0
set @Message ='Ok'

create table #result
(
     IdDenyGeneric int,
     IdClienteGeneric int,
     [Name] nvarchar(max),
     FirstLastName nvarchar(max),
     SecondLastName nvarchar(max),
     [Address] nvarchar(max),
     City nvarchar(max),
     [State] nvarchar(max),
     ZipCode nvarchar(max),
     PhoneNumber nvarchar(max),
     CelullarNumber nvarchar(max),
     Country nvarchar(max),
     NoteIntoList nvarchar(max),
     NoteOutFromList nvarchar(max)
)

/*INICIO - 05062019_azavala*/
declare @NameTmp varchar(500), @FirstLastNameTmp varchar(500), @SecondLastNameTmp varchar(500),  @AddressTmp varchar(500), @CityTmp varchar(500), @StateTmp varchar(500)
IF(@IsCustomer=1)
	BEGIN
		IF (ISNULL(@Id,0)=0)
			BEGIN
				select @Tot=count(1)
				from customer
				Where
					[Name] like '%'+@Name+'%' and FirstLastName like '%'+@FirstLastName+'%' and SecondLastName like '%'+ @SecondLastName+'%' and idcustomer in (select idcustomer from [dbo].[DenyListCustomer] with(nolock) where idgenericstatus=1)
			END
		ELSE
			BEGIN
			if(@Name='' and @FirstLastName='' and @SecondLastName='')
				begin
					select @NameTmp=[Name], @FirstLastNameTmp=[FirstLastName], @SecondLastNameTmp=[SecondLastName], @AddressTmp=[Address], @CityTmp=[City], @StateTmp=[State] from Customer with(nolock) where IdCustomer=@Id
					select @Tot=count(1) 
					from customer with(nolock) 
					Where (IdCustomer=@Id or 
					(IdCustomer!=@Id and [Name] = @NameTmp and FirstLastName = @FirstLastNameTmp and SecondLastName = @SecondLastNameTmp AND [Address]=@AddressTmp and City=@CityTmp and [State]=@StateTmp and idcustomer in (select idcustomer from [dbo].[DenyListCustomer] with(nolock) where idgenericstatus=1)))
				end
			else
				begin
					select @Tot=count(1) 
					from customer with(nolock) 
					Where (IdCustomer=@Id and [Name] like '%'+@Name+'%' and FirstLastName like '%'+@FirstLastName+'%' and SecondLastName like '%'+ @SecondLastName+'%' and idcustomer in (select idcustomer from [dbo].[DenyListCustomer] with(nolock) where idgenericstatus=1))
				end
			END
	END
ELSE
	BEGIN
		IF (ISNULL(@Id,0)=0)
			BEGIN
				select @Tot=count(1)
				from Beneficiary
				Where
					[Name] like '%'+@Name+'%' and FirstLastName like '%'+@FirstLastName+'%' and SecondLastName like '%'+ @SecondLastName+'%' and idbeneficiary in (select idbeneficiary from [dbo].[DenyListBeneficiary] with(nolock) where idgenericstatus=1)
			END
		ELSE
			BEGIN
			if(@Name='' and @FirstLastName='' and @SecondLastName='')
				begin
					select @NameTmp=[Name], @FirstLastNameTmp=[FirstLastName], @SecondLastNameTmp=[SecondLastName], @AddressTmp=[Address], @CityTmp=[City], @StateTmp=[State] from Beneficiary with(nolock) where IdBeneficiary=@Id
					select @Tot=count(1) 
					from Beneficiary with(nolock) 
					Where (IdBeneficiary=@Id or 
					(IdBeneficiary != @Id and [Name] = @NameTmp and FirstLastName = @FirstLastNameTmp and SecondLastName = @SecondLastNameTmp AND [Address]=@AddressTmp and City=@CityTmp and [State]=@StateTmp and idbeneficiary in (select idbeneficiary from [dbo].[DenyListBeneficiary] with(nolock) where idgenericstatus=1)))
				end
			else
				begin
					select @Tot=count(1) 
					from Beneficiary with(nolock) 
					Where (IdBeneficiary=@Id and [Name] like '%'+@Name+'%' and FirstLastName like '%'+@FirstLastName+'%' and SecondLastName like '%'+ @SecondLastName+'%' and idbeneficiary in (select idbeneficiary from [dbo].[DenyListBeneficiary] with(nolock) where idgenericstatus=1))
				end
			END
	END

if isnull(@Tot,0)>3000
begin 
    set @HasError=1
    set @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHERROR')         
end
else
begin
    if isnull(@Tot,0)=0
        begin 
            set @HasError=1
            set @Message=replace(replace([dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHNOFOUND'),'Transfers','Match'),'transferencias','coincidencias')
        end
    else
        begin
        if (@IsCustomer=1)
        begin
			IF (ISNULL(@Id,0)=0)
				BEGIN
					--insert into ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage) values ('st_FindDenyListByName', GETDATE(), 'Entro 1')
					insert into #result
						Select  distinct IdDenyListCustomer,c.IdCustomer,[Name],FirstLastName,SecondLastName,[Address],City,[State],ZipCode,PhoneNumber,CelullarNumber,Country,NoteIntoList,NoteOutFromList from customer c with (nolock)
						join [dbo].[DenyListCustomer] d with (nolock) on d.idgenericstatus=1 and c.IdCustomer=d.IdCustomer
						Where Name like '%'+@Name+'%' and FirstLastName like '%'+@FirstLastName+'%' and SecondLastName like '%'+ @SecondLastName+'%'
				END
			ELSE
				BEGIN
					if(@Name='' and @FirstLastName='' and @SecondLastName='')
					begin
						--insert into ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage) values ('st_FindDenyListByName', GETDATE(), 'Entro 2')
						insert into #result
							Select  distinct IdDenyListCustomer,c.IdCustomer,[Name],FirstLastName,SecondLastName,[Address],City,[State],ZipCode,PhoneNumber,CelullarNumber,Country,NoteIntoList,NoteOutFromList 
							from Customer c with(nolock)
							join [dbo].DenyListCustomer d with(nolock) on d.idgenericstatus=1 and c.idcustomer=d.IdCustomer
							Where (c.IdCustomer=@Id or (c.IdCustomer!=@Id and [Name] = @NameTmp and FirstLastName = @FirstLastNameTmp and SecondLastName = @SecondLastNameTmp AND [Address]=@AddressTmp and City=@CityTmp and [State]=@StateTmp and c.IdCustomer!=@Id))
					end
					Else
					begin/*Inicio 15042019_azavala*/
						--insert into ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage) values ('st_FindDenyListByName', GETDATE(), 'Entro 3')
						insert into #result
							Select  distinct IdDenyListCustomer,c.IdCustomer,[Name],FirstLastName,SecondLastName,[Address],City,[State],ZipCode,PhoneNumber,CelullarNumber,Country,NoteIntoList,NoteOutFromList 
							from Customer c with(nolock)
							join [dbo].DenyListCustomer d with(nolock) on d.idgenericstatus=1 and c.idcustomer=d.IdCustomer
							Where c.IdCustomer=@Id and [Name] like '%'+@Name+'%' and FirstLastName like '%'+@FirstLastName+'%' and SecondLastName like '%'+@SecondLastName+'%'
					end/*Fin 15042019_azavala*/
				END
        end
        else
        begin
			IF (ISNULL(@Id,0)=0)
				BEGIN
					insert into #result
						Select  distinct IdDenyListBeneficiary,c.IdBeneficiary,[Name],FirstLastName,SecondLastName,[Address],City,[State],ZipCode,PhoneNumber,CelullarNumber,Country,NoteIntoList,NoteOutFromList from beneficiary  c with (nolock)
						join [dbo].DenyListBeneficiary d with (nolock) on d.idgenericstatus=1 and c.IdBeneficiary=d.IdBeneficiary
						Where Name like '%'+@Name+'%' and FirstLastName like '%'+@FirstLastName+'%' and SecondLastName like '%'+ @SecondLastName+'%'
				END
			ELSE
				BEGIN
					if(@Name='' and @FirstLastName='' and @SecondLastName='')
						begin
							insert into #result
								Select  distinct IdDenyListBeneficiary,c.IdBeneficiary,[Name],FirstLastName,SecondLastName,[Address],City,[State],ZipCode,PhoneNumber,CelullarNumber,Country,NoteIntoList,NoteOutFromList 
								from beneficiary  c with(nolock)
								join [dbo].DenyListBeneficiary d with(nolock) on d.idgenericstatus=1 and c.IdBeneficiary=d.IdBeneficiary
								Where (c.IdBeneficiary=@Id or (c.IdBeneficiary!=@Id and [Name] = @NameTmp and FirstLastName = @FirstLastNameTmp and SecondLastName = @SecondLastName AND [Address]=@AddressTmp and City=@CityTmp and [State]=@StateTmp and c.IdBeneficiary=@Id))
						end
					Else
						begin/*Inicio 15042019_azavala*/
							insert into #result
								Select  distinct IdDenyListBeneficiary,c.IdBeneficiary,[Name],FirstLastName,SecondLastName,[Address],City,[State],ZipCode,PhoneNumber,CelullarNumber,Country,NoteIntoList,NoteOutFromList 
								from beneficiary  c with(nolock)
								join [dbo].DenyListBeneficiary d with(nolock) on d.idgenericstatus=1 and c.IdBeneficiary=d.IdBeneficiary
								Where c.IdBeneficiary=@Id and [Name] like '%'+@Name+'%' and FirstLastName like '%'+@FirstLastName+'%' and SecondLastName like '%'+@SecondLastName+'%'
						end/*Fin 15042019_azavala*/
				END
        end
        end
end
/*FIN - 05062019_azavala*/

select IdDenyGeneric,IdClienteGeneric,[Name],FirstLastName,SecondLastName,[Address],City,[State],ZipCode,PhoneNumber,CelullarNumber,Country,isnull(NoteIntoList,'') NoteIntoList,isnull(NoteOutFromList,'') NoteOutFromList 
from #result