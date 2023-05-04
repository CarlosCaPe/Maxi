
CREATE PROCEDURE [BillPayment].[st_UpdateBillerRelation]
   @IdBiller int --200620191732_azavala
   , @IdBillerAggregator int
   , @Relationship varchar(250)
   , @IdUser int
   , @IdAggregator int
   , @ChoiseData nvarchar(150) --200620191732_azavala
   , @HasError int out
   , @Message nvarchar(max) out
as

/********************************************************************
<Author>Amoreno</Author>
<app>MaxiCorp</app>
<Description>Actualizar el nombre del Biller</Description>

<ChangeLog>

<log Date="20/06/2018" Author="amoreno">Creation</log>
<log Date="20/06/2019" Author="azavala">Add Parameters as IdBiller and ChoiseData to identify the correct biller for the new Fiserv's Process:: Ref: 200620191732_azavala</log>
</ChangeLog>

*********************************************************************/
begin try 
--insert into ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage) values ('BillPayment.st_UpdateBillerRelation', GETDATE(), 'IdBiller: ' + Convert(varchar(max), @IdBiller) + '; IdBillerAggregator: ' + Convert(varchar(max), @idBillerAggregator) + '; ChoiseData: ' + @ChoiseData)

set @HasError = 0
set @Message=''

declare 
 @RelationshipSelect varchar(100)


		if  exists (select 1 from BillPayment.Billers with (nolock) where IdAggregator=@IdAggregator and idBillerAggregator=@IdBillerAggregator and IdBiller=@IdBiller) --200620191732_azavala
			begin 
				UPDATE BillPayment.Billers SET Relationship=@Relationship WHERE IdAggregator=@IdAggregator and idBillerAggregator=@IdBillerAggregator and IdBiller=@IdBiller --200620191732_azavala
				  				  
			 insert into 
			  BillPayment.LogForBillers	
			   ( IdBiller	
			     , IdUser
			     , MovementType
			     , DateLastChangue
			     , Description
			    )
			  Values 
				 ( @IdBiller
				   , @IdUser
				   , 'Update Info'
				   , Getdate()
				   , 'Relationship change' +' ' + @Relationship
				  )
			end 
		else 
		 begin 
			 set @HasError = 1
			 set @Message='Error Update Relationship'
		 end  

		  
End Try
Begin Catch 
 set @HasError = 1
 set @Message='Error'
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateBillerRelation',Getdate(),ERROR_MESSAGE())    
End Catch

