CREATE Procedure [dbo].[st_SaveCustomerID]      
(      
    @IdCustomer int,      
    @IdTransfer int,
    @IdCustomerIdentificationType int,      
    @SSNumber nvarchar(max),    
    @BornDate datetime,        
    @IdentificationNumber nvarchar(max),      
    @EnterByIdUser int,      
    @ExpirationIdentification datetime,
    @IdentificationIdCountry int,
    @IdentificationIdState int,
    @IdLenguage int,
    @Occupation nvarchar(max),
	@IdOccupation int = 0 out,/*M00207*/ 
	@IdSubcategoryOccupation int = 0 out,/*M00207*/ 
    @SubcategoryOccupationOther nvarchar(max)  = '' out ,/*M00207*/ 
    @HasError bit out,
    @ResultMessage nvarchar(max) out   
)      
AS    
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2020/10/04" Author="esalazar" Name="Occupations">-- CR M00207	</log>
<log Date="2021/01/02" Author="jcsierra" Name="Bug"> Se omite el update a la columna EnterByIdUser</log>
</ChangeLog>
********************************************************************/
if @IdLenguage is null 
    set @IdLenguage=2

Begin try


Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveCustomerID',Getdate(),CONCAT('@IdTransfer: ', @IdTransfer)) 


	exec st_SaveCustomerMirror @IdCustomer

	IF(
		Len(isnull(@IdCustomerIdentificationType,''))=0
		OR
		Len(isnull(@IdentificationNumber,''))=0
		OR
		Len(isnull(@BornDate,''))=0
	)
		BEGIN
			Update Customer Set       
				/*IdCustomerIdentificationType*/
				SSNumber=case when @SSNumber is null or len(@SSNumber) = 0 then SSNumber else @SSNumber end,
				Occupation=case when @Occupation is null or len(@Occupation) = 0 then Occupation else @Occupation end,
				IdOccupation =case when @IdOccupation = 0 then IdOccupation else @IdOccupation end  ,/*M00207*/ 
				IdSubcategoryOccupation = case when @IdSubcategoryOccupation = 0 then IdSubcategoryOccupation else @IdSubcategoryOccupation end  ,/*M00207*/ 
				SubcategoryOccupationOther =
					case 
					when @SubcategoryOccupationOther is null or len(@SubcategoryOccupationOther) = 0 
					then SubcategoryOccupationOther 
					else @SubcategoryOccupationOther end,  /*M00207*/ 
				/*IdentificationNumber*/
				--EnterByIdUser= case when @EnterByIdUser is null then EnterByIdUser else @EnterByIdUser end,		
				/*ExpirationIdentification*/
				/*IdentificationIdCountry*/
				/*IdentificationIdState*/
				/*BornDate*/
				DateOfLastChange=getdate()     
			Where IdCustomer=@IdCustomer;
		END
	ELSE
	BEGIN
		/*Actualizacion Original*/
		Update Customer Set       
			IdCustomerIdentificationType= case when @IdCustomerIdentificationType is null then IdCustomerIdentificationType else @IdCustomerIdentificationType end,
			SSNumber=case when @SSNumber is null or len(@SSNumber) = 0 then SSNumber else @SSNumber end,
			Occupation=case when @Occupation is null or len(@Occupation) = 0 then Occupation else @Occupation end,
			IdOccupation =case when @IdOccupation = 0 then IdOccupation else @IdOccupation end  ,/*M00207*/ 
			IdSubcategoryOccupation = case when @IdSubcategoryOccupation = 0 then IdSubcategoryOccupation else @IdSubcategoryOccupation end  ,/*M00207*/ 
			SubcategoryOccupationOther =
				case 
				when @SubcategoryOccupationOther is null or len(@SubcategoryOccupationOther) = 0 
				then SubcategoryOccupationOther 
				else @SubcategoryOccupationOther end,  /*M00207*/ 

			IdentificationNumber=case when @IdentificationNumber is null or len(@IdentificationNumber) = 0 then IdentificationNumber else @IdentificationNumber end,
			--EnterByIdUser= case when @EnterByIdUser is null then EnterByIdUser else @EnterByIdUser end,
			ExpirationIdentification=case when @ExpirationIdentification is null then ExpirationIdentification else @ExpirationIdentification end, 
			IdentificationIdCountry= case when @IdentificationIdCountry is null then IdentificationIdCountry else @IdentificationIdCountry end,
			IdentificationIdState= case when @IdentificationIdState is null then IdentificationIdState else @IdentificationIdState end ,
			BornDate= case when @BornDate is null then BornDate else @BornDate end,  
			DateOfLastChange=getdate()     
		Where IdCustomer=@IdCustomer;
	END 
 
 if (isnull(@IdTransfer,0)>0) and exists (select top 1 1 from transfer where idtransfer=isnull(@IdTransfer,0))
 begin
    Update transfer Set    
    CustomerIdCustomerIdentificationType= case when @IdCustomerIdentificationType is null then CustomerIdCustomerIdentificationType else @IdCustomerIdentificationType end,
    CustomerSSNumber=case when @SSNumber is null or len(@SSNumber) = 0 then CustomerSSNumber else @SSNumber end,
    CustomerOccupation=case when @Occupation is null or len(@Occupation) = 0 then CustomerOccupation else @Occupation end,
	CustomerIdOccupation =case when @IdOccupation = 0 then CustomerIdOccupation else @IdOccupation end  ,/*M00207*/ 
	CustomerIdSubOccupation = case when @IdSubcategoryOccupation = 0 then CustomerIdSubOccupation else @IdSubcategoryOccupation end  ,/*M00207*/ 
	CustomerSubOccupationOther =
		case 
		when @SubcategoryOccupationOther is null or len(@SubcategoryOccupationOther) = 0 
		then CustomerSubOccupationOther 
		else @SubcategoryOccupationOther end,  /*M00207*/  

    CustomerIdentificationNumber=case when @IdentificationNumber is null or len(@IdentificationNumber) = 0 then CustomerIdentificationNumber else @IdentificationNumber end,
    --EnterByIdUser= case when @EnterByIdUser is null then EnterByIdUser else @EnterByIdUser end,
    CustomerExpirationIdentification=case when @ExpirationIdentification is null then CustomerExpirationIdentification else @ExpirationIdentification end, 
    CustomerIdentificationIdCountry= case when @IdentificationIdCountry is null then CustomerIdentificationIdCountry else @IdentificationIdCountry end,
    CustomerIdentificationIdState= case when @IdentificationIdState is null then CustomerIdentificationIdState else @IdentificationIdState end ,
    CustomerBornDate= case when @BornDate is null then CustomerBornDate else @BornDate end--,  
    --DateOfLastChange=getdate()     
 Where IdTransfer=@IdTransfer  
 end
 else
 begin
    if (isnull(@IdTransfer,0)>0) and exists (select top 1 1 from transferclosed where idtransferclosed=isnull(@IdTransfer,0))
    begin        
        Update transferclosed Set    
            CustomerIdCustomerIdentificationType= case when @IdCustomerIdentificationType is null then CustomerIdCustomerIdentificationType else @IdCustomerIdentificationType end,
            CustomerSSNumber=case when @SSNumber is null or len(@SSNumber) = 0 then CustomerSSNumber else @SSNumber end,
            CustomerOccupation=case when @Occupation is null or len(@Occupation) = 0 then CustomerOccupation else @Occupation end,
			CustomerIdOccupation =case when @IdOccupation = 0 then CustomerIdOccupation else @IdOccupation end  ,/*M00207*/ 
			CustomerIdSubOccupation = case when @IdSubcategoryOccupation = 0 then CustomerIdSubOccupation else @IdSubcategoryOccupation end  ,/*M00207*/ 
			CustomerSubOccupationOther =
				case 
				when @SubcategoryOccupationOther is null or len(@SubcategoryOccupationOther) = 0 
				then CustomerSubOccupationOther 
				else @SubcategoryOccupationOther end,  /*M00207*/ 

            CustomerIdentificationNumber=case when @IdentificationNumber is null or len(@IdentificationNumber) = 0 then CustomerIdentificationNumber else @IdentificationNumber end,
            --EnterByIdUser= case when @EnterByIdUser is null then EnterByIdUser else @EnterByIdUser end,
            CustomerExpirationIdentification=case when @ExpirationIdentification is null then CustomerExpirationIdentification else @ExpirationIdentification end, 
            CustomerIdentificationIdCountry= case when @IdentificationIdCountry is null then CustomerIdentificationIdCountry else @IdentificationIdCountry end,
            CustomerIdentificationIdState= case when @IdentificationIdState is null then CustomerIdentificationIdState else @IdentificationIdState end ,
            CustomerBornDate= case when @BornDate is null then CustomerBornDate else @BornDate end--,  
            --DateOfLastChange=getdate() 
        Where IdTransferclosed=@IdTransfer  
    end
 end

   
set @HasError =0
SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE10')

End try
Begin Catch
              Declare @ErrorMessage nvarchar(max)         
               Select @ErrorMessage=ERROR_MESSAGE()        
               Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveCustomerID',Getdate(),@ErrorMessage) 
              set @HasError =1
        SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE11')           
End catch     

