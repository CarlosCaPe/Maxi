
CREATE Procedure [BillPayment].[st_SaveValidationRulesBillPayment]    
   (  
     @Id  											int =null
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
 ,@IdValidationRule int
 
 set @ValidatorName =		
									 (select 
									   ValidatorName
										from 
										 BillPayment.Validator 
										where 
										 IdValidator = @idValidator
		                )
    
	   insert into BillPayment.ValidationRules 
	    (IdEntityToValidate
	    , IdValidator
	    , IdStateConfig
	    , Field
	    , ErrorMessageES
	    , ErrorMessageUS
	    , OrderByEntityToValidate
	    , IdGenericStatus
	    , IsAllowedToEdit
	    , IdUser
	    , LastChange
	    )
	    values 
	    (@idEntityToValidate
	    , @idValidator
	    , @idStateConfig
	    , @Field
	    , @ErrorSpanish
	    , @ErrorEnglish
	    , @OrderByEntityToValidate
	    , @isEnabled
	    , 1
	    , @idUser
	    , Getdate()
	    )
	    
	  set @IdValidationRule= (select max(IdValidationRule) from BillPayment.ValidationRules with (nolock))

	    
  if (@ValidatorName='LengthRule')
   begin
       insert into BillPayment.LengthRule
        (IdValidationRule
        , Minimum
        , Maximo        
        )
       values
        ( @IdValidationRule
          , @Minimum
          , @Maximo        
        )
   
      
	 end   
	 	 
  if (@ValidatorName='RangeRule')
   begin 
       insert into BillPayment.RangeRule
        (IdValidationRule
        , FromValue
        , ToValue  
        , Type      
        )
       values
        ( @IdValidationRule
          , @FromValue
          , @ToValue
          , @Type        
        )

	 end  

  if (@ValidatorName='RegularExpressionRule')
   begin  
       insert into BillPayment.RegularExpressionRule
        (IdValidationRule
        , Pattern    
        )
       values
        ( @IdValidationRule
          , @Pattern     
        )  
                      
	 end  	 

  if (@ValidatorName='SimpleComparison')
   begin   
     
       insert into BillPayment.SimpleComparisonRule
        (IdValidationRule
        , ComparisonValue
        , Type
        , Expression  
    
        )
       values
        ( @IdValidationRule
          , @ComparisonValue
          , @TypeSimple
          , @Expression     
        ) 
       
	 end  	 	  
 /*
	    
select * from BillPayment.RangeRule	    
	    
select * from  BillPayment.ValidationRules  
					 

select * from BillPayment.Validator
select * from BillPayment.EntityToValidate 
select * from BillPayment.FieldToValidate
select * from BillPayment.LengthRule


select * from LengthRule where idvalidationRule= 2683
select * from RangeRule where idvalidationRule= 2683
select * from RegularExpressionRule where idvalidationRule= 2683
select * from ValidationRules where idvalidationRule= 2683  --'RequiredRule'
select * from SimpleComparisonRule where idvalidationRule= 2683
*/
