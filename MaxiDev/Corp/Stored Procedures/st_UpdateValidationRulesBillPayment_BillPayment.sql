CREATE Procedure [Corp].[st_UpdateValidationRulesBillPayment_BillPayment]    
   (  
     @IdValidationRule  				int 
     , @idValidator							int
     , @idEntityToValidate  		int
     , @idStateConfig 					int
     , @Field      							nvarchar(255)
     , @ErrorSpanish						nvarchar(255)
     , @ErrorEnglish						nvarchar(255)
     , @OrderByEntityToValidate int
     , @isEnabled								bit = 1
     , @idUser                  int
     , @Minimum                 int = 0
     , @Maximo  								int = 0
		 , @FromValue								nvarchar(255) = ''
		 , @ToValue									nvarchar(255) = ''
		 , @Type 										nvarchar(255) = ''
		 , @Pattern									nvarchar(255) = ''
     , @ComparisonValue        	nvarchar(255) = ''
     , @TypeSimple             	nvarchar(255) = ''
     , @Expression 		         	nvarchar(255) = ''
   )
AS    
Set nocount on  

/********************************************************************
<Author> Amoreno </Author>
<app>Corporate </app>
<Description> Set Validation Rules BillPayment </Description>

<ChangeLog>
<log Date="01/15/2019" Author="Amoreno">Create</log>
</ChangeLog>
*********************************************************************/

declare 
 @ValidatorName nvarchar(255)

 set @ValidatorName =		
									 (select 
									   ValidatorName
										from 
										 BillPayment.Validator WITH(NOLOCK)
										where 
										 IdValidator = @idValidator		   
		                )
		                
  update 
   BillPayment.ValidationRules 
  set 
   ErrorMessageES=@ErrorSpanish
  , ErrorMessageUS= @ErrorEnglish
  , OrderByEntityToValidate= @OrderByEntityToValidate  
  , IdUser=@idUser
  , LastChange = Getdate()
   where IdValidationRule=@IdValidationRule
         
  if (@ValidatorName='LengthRule')
  begin
	  update 
	    BillPayment.LengthRule
	  set 
	   Minimum=@Minimum , Maximo=@Maximo
	  where IdValidationRule=@IdValidationRule
   
      
	 end   
	 	 
  if (@ValidatorName='RangeRule')
   begin 
	   update  BillPayment.RangeRule
	    set FromValue= @FromValue, ToValue= @ToValue, [Type]=@Type
	    where IdValidationRule=@IdValidationRule
	 end  

  if (@ValidatorName='RegularExpressionRule')
   begin  
	   update BillPayment.RegularExpressionRule
	   set Pattern= @Pattern
	   where IdValidationRule=@IdValidationRule
                      
	 end  	 

  if (@ValidatorName='SimpleComparison')
   begin   
     
     update 
       BillPayment.SimpleComparisonRule
     set ComparisonValue= @ComparisonValue,  [Type]=@TypeSimple, Expression= @Expression 
		 where IdValidationRule=@IdValidationRule
	 end  	 	
